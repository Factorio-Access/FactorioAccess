#include "app.h"
#include <windows.h>
#include <chrono>
#include <memory>
#include "audio/audio.h"
#include "game.h"
#include "hooks.h"
#include "input.h"
#include "log.h"
#include "screens/dialogs.h"
#include "speech.h"
#include "ui/graph_announcer.h"
#include "ui/navigator.h"
#include "ui/screen.h"
#include "ui/strings.h"
#include "update_check.h"

namespace fa::app {
using namespace fa::ui;

static InputManager g_input;
static ScreenManager g_screens;
static std::unique_ptr<GraphNavigator> g_nav;
static bool g_inited = false;
static bool g_owned = false;
static double g_last_tick = 0;

static double now() {
  using namespace std::chrono;
  return duration<double>(steady_clock::now().time_since_epoch()).count();
}

// Typematic at the user's own OS keyboard settings, so navigation repeat feels like the rest of the system.
static InputManager::Typematic os_typematic() {
  InputManager::Typematic t;
  int delay = 0, speed = 0;
  if (SystemParametersInfoW(SPI_GETKEYBOARDDELAY, 0, &delay, 0) && SystemParametersInfoW(SPI_GETKEYBOARDSPEED, 0, &speed, 0)) {
    delay = delay < 0 ? 0 : delay > 3 ? 3 : delay;  // 0..3 -> 250..1000 ms
    speed = speed < 0 ? 0 : speed > 31 ? 31 : speed;  // 0..31 -> 2.5..30 per second
    t.initial_delay = (delay + 1) * 0.25;
    t.repeat_interval = 1.0 / (2.5 + (speed / 31.0) * 27.5);
  }
  return t;
}

static void register_actions() {
  namespace sc = input::sc;
  struct Ui {
    std::string_view id;
    const char* label;
    int key;
    bool shift, ctrl;
    bool repeat;
  };
  const Ui ui[] = {
      {ui_actions::Up, "Previous item", sc::Up, false, false, true},
      {ui_actions::Down, "Next item", sc::Down, false, false, true},
      {ui_actions::Left, "Left", sc::Left, false, false, true},
      {ui_actions::Right, "Right", sc::Right, false, false, true},
      {ui_actions::Next, "Next panel", sc::Tab, false, false, true},
      {ui_actions::Prev, "Previous panel", sc::Tab, true, false, true},
      {ui_actions::Home, "First", sc::Home, false, false, false},
      {ui_actions::End, "Last", sc::End, false, false, false},
      {ui_actions::Activate, "Activate", sc::Enter, false, false, false},
      {ui_actions::Back, "Back", sc::Escape, false, false, false},
      // The mod's config makes Shift+Escape the game's menu key: it closes the pause menu it opened.
      {ui_actions::Back, "Back", sc::Escape, true, false, false},
      {ui_actions::Tooltip, "Tooltip", sc::Space, false, false, false},
      {ui_actions::Increase, "Increase", sc::PageUp, false, false, true},
      {ui_actions::Decrease, "Decrease", sc::PageDown, false, false, true},
      {ui_actions::IncreaseLarge, "Increase a lot", sc::PageUp, true, false, true},
      {ui_actions::DecreaseLarge, "Decrease a lot", sc::PageDown, true, false, true},
  };
  for (const Ui& u : ui) {
    auto& a = g_input.register_action(std::string(u.id), u.label, InputCategory::UI).bind(u.key, u.ctrl, u.shift, false);
    if (u.repeat) a.repeating();
  }
}

void init() {
  if (g_inited) return;
  g_inited = true;
  g_input.set_typematic(os_typematic());
  GraphAnnouncer::position_text = [](int i, int n) {
    MessageBuilder m;
    strings::push_position(m, i, n);
    return m.build();
  };
  GraphAnnouncer::row_text = [] { return std::string(strings::kRow); };
  g_nav = std::make_unique<GraphNavigator>(NavigatorHost{
      [](std::string_view t, bool interrupt) { speech::speak(t, interrupt); },
      {},
      [] { return g_screens.owns_keyboard(); },
      [] { return (int)hooks::frame(); }});
  Screen::set_host([](std::string_view s) { speech::speak(s, false); }, [](Screen* s) {
    if (g_nav) g_nav->screen_closed(s);
  });
  g_screens.set_navigator([](Screen* s) { if (g_nav) g_nav->attach(s); }, [] { if (g_nav) g_nav->ensure_focus(); });
  register_actions();
  g_screens.register_screen(screens::make_dialogs());
  g_last_tick = now();
  log::writef("app: initialized with {} actions", g_input.actions().size());
}

void focus_stop(const Key& stop) {
  if (g_nav) g_nav->focus_stop(stop);
}

void announce_change(std::string_view text) {
  if (g_nav) g_nav->announce_change(text);
}

std::string dump() { return g_nav ? g_nav->dump() : "(no navigator)\n"; }

// Every save (auto or not) clicks as it starts and as it finishes, as the launcher did from the game's log. A save
// spans several frames of the game's saving state.
static bool g_saving = false;
static double g_saving_since = 0;

static void watch_saves(double t) {
  bool saving = game::saving();
  if (saving == g_saving) return;
  g_saving = saving;
  if (saving) g_saving_since = t;
  else log::writef("save finished after {:.0f} ms", (t - g_saving_since) * 1000);
  audio::submit(R"({"command":"patch","id":"fa-save","source":{"kind":"encoded_bytes","name":"save-shh.wav"}})");
}

void tick() {
  if (!g_inited) return;
  double t = now();
  watch_saves(t);
  double dt = g_last_tick > 0 ? t - g_last_tick : 0;
  g_last_tick = t;
  Screen* before = g_screens.current();
  bool owned_before = g_owned;
  bool raw_before = before && before->captures_raw_input();
  g_screens.tick();
  bool owns = g_screens.owns_keyboard();
  if (owns != g_owned) {
    g_owned = owns;
    input::set_owned(owns);
    Screen* s = g_screens.current();
    log::writef("keyboard: {} ({})", owns ? "native" : "game", s ? s->key() : "no screen");
  }
  g_input.set_live_categories(g_screens.live_categories());
  Screen* cur = g_screens.current();
  update::tick(cur && cur->key() == "dialogs" && screens::on_main_menu(), t);
  // The keys of the frame a screen became current, or the keyboard changed hands, belong to whoever had the
  // keyboard before (the Enter that ends a text edit must not also activate the field again).
  if (!owns || !owned_before || cur != before) return;
  // A screen reading raw keys this frame (typing a value) handles them in on_update; navigation stays out, also
  // on the frame the screen stopped (the Enter that set the value must not activate the slider again).
  if (raw_before || (cur && cur->captures_raw_input())) return;
  const KeySource& ks = input::key_source();
  g_input.tick(t, ks, [](InputAction& a) { return g_nav && g_nav->on_action(a.key()); });
  TypeaheadInput in;
  in.typed = input::typed_chars();
  in.ctrl = ks.ctrl();
  in.alt = ks.alt();
  in.shift = ks.shift();
  in.escape_pressed = ks.just_pressed(input::sc::Escape);
  in.up_held = ks.held(input::sc::Up);
  in.down_held = ks.held(input::sc::Down);
  in.dt = dt;
  g_nav->tick_typeahead(in);
}

void shutdown() {
  g_inited = false;
  g_nav.reset();
  input::set_owned(false);
  g_owned = false;
}
}  // namespace fa::app
