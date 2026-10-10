#include "input.h"
#include <atomic>
#include <cstring>
#include <mutex>
#include <vector>
#include "log.h"

namespace fa::input {
static std::atomic<bool> g_owned{false};
void set_owned(bool o) { g_owned = o; }
bool owned() { return g_owned; }

namespace {
struct Pending {
  bool is_text;
  KeyEvent key;
  std::u32string text;
};
std::mutex g_mu;
std::vector<Pending> g_pending;

struct FrameKeys : fa::ui::KeySource {
  bool down[512] = {}, pressed[512] = {}, up[512] = {};
  bool mshift = false, malt = false, mctrl = false;
  std::u16string typed;
  void apply(const KeyEvent& e) {
    // Modifier state comes from the event's own flags (the game reads the real keyboard state), not from our
    // down[] tracking: a release delivered to another window would otherwise leave a modifier held forever.
    mshift = e.shift;
    mctrl = e.ctrl;
    malt = e.alt;
    int k = e.scancode;
    if (k < 0 || k >= 512) return;
    if (!e.down) {
      down[k] = false;
      up[k] = true;
    } else {
      // A typematic repeat counts as a fresh press: the InputManager's own repeat only runs for actions marked
      // repeating, and the OS repeat is what the player expects for navigation keys anyway.
      if (!down[k] || e.repeat) pressed[k] = true;
      down[k] = true;
    }
  }
  void clear_edges() {
    memset(pressed, 0, sizeof pressed);
    memset(up, 0, sizeof up);
    typed.clear();
  }
  bool just_pressed(int k) const override { return k >= 0 && k < 512 && pressed[k]; }
  bool held(int k) const override { return k >= 0 && k < 512 && down[k]; }
  bool released(int k) const override { return k >= 0 && k < 512 && up[k]; }
  bool ctrl() const override { return mctrl; }
  bool shift() const override { return mshift; }
  bool alt() const override { return malt; }
} g_frame;
}  // namespace

void record_key(const KeyEvent& e) {
  std::lock_guard lk(g_mu);
  g_pending.push_back({false, e, {}});
}

void record_text(std::u32string_view text) {
  std::lock_guard lk(g_mu);
  g_pending.push_back({true, {}, std::u32string(text)});
}

void begin_frame() {
  std::vector<Pending> p;
  {
    std::lock_guard lk(g_mu);
    p.swap(g_pending);
  }
  for (auto& e : p) {
    if (!e.is_text) {
      log::writef("[key] {} {}{}{}{}{}", e.key.scancode, e.key.down ? "down" : "up", e.key.repeat ? " repeat" : "", e.key.ctrl ? " ctrl" : "",
                  e.key.shift ? " shift" : "", e.key.alt ? " alt" : "");
      g_frame.apply(e.key);
      continue;
    }
    for (char32_t c : e.text)
      if (c >= 0x20 && c != 0x7f && c < 0x10000) g_frame.typed.push_back((char16_t)c);
  }
}

void end_frame() { g_frame.clear_edges(); }
const fa::ui::KeySource& key_source() { return g_frame; }
std::u16string_view typed_chars() { return g_frame.typed; }
}  // namespace fa::input
