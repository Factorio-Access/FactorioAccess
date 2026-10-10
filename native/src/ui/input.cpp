#include "ui/input.h"
#include <charconv>
#include <format>
#include <map>

namespace fa::ui {

std::string_view category_name(InputCategory c) {
  switch (c) {
    case InputCategory::Global: return "global";
    case InputCategory::UI: return "ui";
    case InputCategory::Exploration: return "exploration";
    case InputCategory::InGame: return "ingame";
    case InputCategory::Windows: return "windows";
    case InputCategory::Lifted: return "lifted";
    default: return "?";
  }
}

std::string Chord::display(const std::function<std::string(int)>& key_name) const {
  std::string s;
  if (ctrl) s += "Ctrl+";
  if (shift) s += "Shift+";
  if (alt) s += "Alt+";
  return s + (key_name ? key_name(key) : std::format("{:#x}", key));
}

// "0x1e|ctrl,shift": the key code, then a comma list of held modifiers (omitted if none).
std::string Chord::serialize() const {
  std::string s = std::format("{:#x}", key);
  std::string mods;
  if (ctrl) mods += "ctrl,";
  if (shift) mods += "shift,";
  if (alt) mods += "alt,";
  if (!mods.empty()) { mods.pop_back(); s += "|" + mods; }
  return s;
}

Chord Chord::deserialize(std::string_view s) {
  Chord c;
  size_t bar = s.find('|');
  std::string_view k = s.substr(0, bar);
  int v = -1;
  if (k.rfind("0x", 0) == 0) std::from_chars(k.data() + 2, k.data() + k.size(), v, 16);
  else std::from_chars(k.data(), k.data() + k.size(), v, 10);
  c.key = v;
  if (bar != std::string_view::npos) {
    std::string_view mods = s.substr(bar + 1);
    size_t p = 0;
    while (p <= mods.size()) {
      size_t e = mods.find(',', p); if (e == std::string_view::npos) e = mods.size();
      std::string_view m = mods.substr(p, e - p);
      if (m == "ctrl") c.ctrl = true; else if (m == "shift") c.shift = true; else if (m == "alt") c.alt = true;
      p = e + 1;
    }
  }
  return c;
}

bool InputAction::remove_binding(const Chord& c) {
  for (size_t i = 0; i < bindings_.size(); ++i)
    if (bindings_[i] == c) { bindings_.erase(bindings_.begin() + (long)i); changed(); return true; }
  return false;
}

static bool modifiers_match(const Chord& c, const KeySource& s) { return c.ctrl == s.ctrl() && c.shift == s.shift() && c.alt == s.alt(); }

bool InputAction::just_pressed(const KeySource& s, const std::vector<bool>* live) const {
  for (size_t i = 0; i < bindings_.size(); ++i)
    if ((!live || (i < live->size() && (*live)[i])) && modifiers_match(bindings_[i], s) && s.just_pressed(bindings_[i].key)) return true;
  return false;
}
bool InputAction::held(const KeySource& s, const std::vector<bool>* live) const {
  for (size_t i = 0; i < bindings_.size(); ++i)
    if ((!live || (i < live->size() && (*live)[i])) && modifiers_match(bindings_[i], s) && s.held(bindings_[i].key)) return true;
  return false;
}

InputAction& InputManager::register_action(std::string key, std::string label, InputCategory category, std::function<void()> on_performed) {
  actions_.push_back(std::make_unique<InputAction>(std::move(key), std::move(label), category));
  if (on_performed) actions_.back()->on_performed(std::move(on_performed));
  return *actions_.back();
}

InputAction* InputManager::find(std::string_view key) {
  for (auto& a : actions_) if (a->key() == key) return a.get();
  return nullptr;
}

void InputManager::set_live_categories(std::vector<InputCategory> cats) {
  bool has_global = false;
  for (auto c : cats) if (c == InputCategory::Global) has_global = true;
  if (!has_global) cats.push_back(InputCategory::Global);
  live_cats_ = std::move(cats);
}

bool InputManager::held(std::string_view key, const KeySource& s) const {
  for (size_t i = 0; i < actions_.size(); ++i)
    if (actions_[i]->key() == key) return actions_[i]->held(s, i < live_.size() ? &live_[i] : nullptr);
  return false;
}

// Walk categories in priority order marking bindings live, shadowing any identical chord already claimed
// by an earlier (higher-priority) category. Same-category duplicates are both live (first wins; the
// rebind capture prevents them).
void InputManager::rebuild_live() {
  live_.assign(actions_.size(), {});
  if (live_cats_.empty()) live_cats_ = {InputCategory::Global};  // Global is always live
  std::map<std::string, size_t> chord_rank;
  for (size_t rank = 0; rank < live_cats_.size(); ++rank) {
    for (size_t i = 0; i < actions_.size(); ++i) {
      auto& a = *actions_[i];
      if (a.category() != live_cats_[rank]) continue;
      auto& mine = live_[i];
      mine.assign(a.bindings().size(), false);
      for (size_t j = 0; j < a.bindings().size(); ++j) {
        std::string chord = a.bindings()[j].serialize();
        auto it = chord_rank.find(chord);
        if (it != chord_rank.end()) { if (it->second < rank) continue; }
        else chord_rank[chord] = rank;
        mine[j] = true;
      }
    }
  }
}

void InputManager::tick(double now, const KeySource& s, const std::function<bool(InputAction&)>& ui_dispatch) {
  rebuild_live();
  for (size_t i = 0; i < actions_.size(); ++i) {
    auto& a = *actions_[i];
    const std::vector<bool>* live = &live_[i];
    bool is_held = a.held(s, live);
    bool fire = false;
    if (a.just_pressed(s, live)) {
      fire = true;
      a.next_repeat_time = now + typematic_.initial_delay;
    } else if (a.repeats() && is_held && a.next_repeat_time > 0 && now >= a.next_repeat_time) {
      // Held past the delay -> auto-repeat, at most one step per frame. The next_repeat_time > 0 guard means
      // only an action that was actually JustPressed in this hold repeats -- not one that just became held
      // because a shared key's modifier was released (releasing Shift while holding Tab must not fire Tab).
      fire = true;
      a.next_repeat_time = now + typematic_.repeat_interval;
    }
    if (!is_held) a.next_repeat_time = 0;
    if (!fire) continue;
    bool consumed = a.category() == InputCategory::UI && ui_dispatch && ui_dispatch(a);
    if (!consumed) a.invoke_performed();
  }
}

}  // namespace fa::ui
