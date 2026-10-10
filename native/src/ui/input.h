#pragma once
// Input layer, ported from wotr-access (src/Input/*). Engine-free: key state comes from a KeySource the
// host provides (in the game: the ButtonEvent stream we see in the device poll).
#include <functional>
#include <memory>
#include <string>
#include <string_view>
#include <vector>

namespace fa::ui {

// The input layer an action belongs to. Screens declare which categories they use, in priority order,
// and the live set each frame is the union of every active screen's declaration walked focus-first (a
// deeper screen ranks higher) until an Exclusive screen, plus Global. Within the live set an identical
// chord bound in two categories resolves to the higher-ranked one (shadowing): the in-game screen flips
// [UI, Exploration] <-> [Exploration, UI] with HUD focus, so the same arrows navigate the HUD when
// focused and move the world cursor when not. Conflict prevention therefore only applies WITHIN a category.
enum class InputCategory {
  Global,       // always live, even with focus mode off (focus toggle, mod menu)
  UI,           // screen/menu navigation, live when the focused screen declares it
  Exploration,  // the in-game world: cursor, interaction, scanner, overlays; control-gated
  InGame,       // base in-game keys that must work even without control (pause menu, cancel targeting)
  Windows,      // service-window hotkeys (inventory, character, skills...)
  Lifted,       // the game's own functions lifted to Ctrl chords (open a window, map, pause...): live in the world AND in its windows
  Count,
};
std::string_view category_name(InputCategory c);

// Modifier-aware key combo. Keys are the game's Button codes (DIK scancodes for plain keys).
struct Chord {
  int key = -1;
  bool ctrl = false, shift = false, alt = false;
  bool operator==(const Chord&) const = default;
  std::string display(const std::function<std::string(int)>& key_name) const;  // "Ctrl+Shift+A"
  std::string serialize() const;                                                // "0x1e|ctrl,shift"
  static Chord deserialize(std::string_view s);                                 // key -1 on failure
};

// What the host knows about the keyboard this frame. Modifier state is folded in by the host.
class KeySource {
 public:
  virtual ~KeySource() = default;
  virtual bool just_pressed(int key) const = 0;  // went down this frame
  virtual bool held(int key) const = 0;          // down now
  virtual bool released(int key) const = 0;      // went up this frame
  virtual bool ctrl() const = 0;
  virtual bool shift() const = 0;
  virtual bool alt() const = 0;
};

// A named mod command with one or more chords. Per-frame phase state is polled by InputManager.
class InputAction {
 public:
  InputAction(std::string key, std::string label, InputCategory category) : key_(std::move(key)), label_(std::move(label)), category_(category) {}
  const std::string& key() const { return key_; }
  const std::string& label() const { return label_; }
  InputCategory category() const { return category_; }
  const std::vector<Chord>& bindings() const { return bindings_; }

  InputAction& bind(int key, bool ctrl = false, bool shift = false, bool alt = false) { bindings_.push_back({key, ctrl, shift, alt}); changed(); return *this; }
  InputAction& bind(const Chord& c) { bindings_.push_back(c); changed(); return *this; }
  void clear_bindings() { bindings_.clear(); changed(); }
  bool remove_binding(const Chord& c);
  // Whether this action auto-repeats while held (nav directions + Tab).
  InputAction& repeating() { repeats_ = true; return *this; }
  bool repeats() const { return repeats_; }
  // Display-only subgroup within the category's settings tree; dispatch ignores it.
  InputAction& grouped(std::string g) { group_ = std::move(g); return *this; }
  const std::string& group() const { return group_; }
  InputAction& on_performed(std::function<void()> fn) { performed_ = std::move(fn); return *this; }
  void on_bindings_changed(std::function<void()> fn) { bindings_changed_ = std::move(fn); }

  // phase queries against a source, honoring exact modifier match (Ctrl+A does not fire bare A)
  bool just_pressed(const KeySource& s, const std::vector<bool>* live) const;
  bool held(const KeySource& s, const std::vector<bool>* live) const;

  // internal to InputManager
  double next_repeat_time = 0;
  void invoke_performed() { if (performed_) performed_(); }

 private:
  void changed() { if (bindings_changed_) bindings_changed_(); }
  std::string key_, label_, group_;
  InputCategory category_;
  std::vector<Chord> bindings_;
  bool repeats_ = false;
  std::function<void()> performed_;
  std::function<void()> bindings_changed_;
};

// Registry + per-frame poll with category shadowing and typematic repeat.
class InputManager {
 public:
  struct Typematic { double initial_delay = 0.4, repeat_interval = 0.06; };  // seconds; host overrides from the OS
  InputAction& register_action(std::string key, std::string label, InputCategory category, std::function<void()> on_performed = {});
  InputAction* find(std::string_view key);
  const std::vector<std::unique_ptr<InputAction>>& actions() const { return actions_; }

  // Live categories this frame, in priority order (host computes from the screen stack; Global is appended).
  void set_live_categories(std::vector<InputCategory> cats);
  void set_typematic(Typematic t) { typematic_ = t; }

  // Whether the action is currently held via a LIVE (unshadowed) binding -- for per-frame polling
  // (a held arrow stops counting the instant a higher claim takes the chord).
  bool held(std::string_view key, const KeySource& s) const;

  // One frame: fires Performed for JustPressed actions (and typematic repeats). `ui_dispatch`, if set,
  // gets UI-category presses first and returns true when it consumed the press.
  void tick(double now, const KeySource& s, const std::function<bool(InputAction&)>& ui_dispatch);

 private:
  void rebuild_live();
  std::vector<std::unique_ptr<InputAction>> actions_;
  std::vector<InputCategory> live_cats_;
  std::vector<std::vector<bool>> live_;  // per action, per binding: live this frame
  Typematic typematic_;
};

}  // namespace fa::ui
