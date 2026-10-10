#pragma once
// Screen framework, ported from wotr-access (src/Screens/Screen.cs, ScreenManager.cs).
//
// Ownership model (decided 2026-08-21): WE own the UI state. A Screen is a dedicated class per game
// screen, declaring a graph over OUR model of that screen (the controls we know it has, in the order that
// makes sense to a player) and activating through synthesized clicks/keys or exported game calls. The
// game's drawn UI is never the state store; it is read only at defined checkpoints (is_active, "did the
// dialog open"). No generic crawlers: an unknown screen gets the honest UnsupportedScreen fallback.
#include <functional>
#include <memory>
#include <string>
#include <string_view>
#include <vector>
#include "ui/input.h"

namespace fa::ui {
class GraphBuilder;

// A screen-level command dispatched by string id (Back/Escape handlers and the like).
struct ScreenAction {
  std::string id;
  std::function<void()> execute;
};
namespace action_ids { inline constexpr std::string_view Back = "back"; }

// Base for a navigable screen. Lifecycle (from the stack diff): on_push (entered the stack) -> on_focus
// (became active); on_unfocus -> on_pop on the way out. The push/focus split enables focus restoration:
// a covered screen gets on_unfocus then, when re-exposed, on_focus without another on_push, so its
// remembered focus survives.
class Screen {
 public:
  virtual ~Screen() = default;
  // Stable identity used for stack diffing.
  virtual std::string_view key() const = 0;
  // Is this screen currently showing? Evaluated every frame -- against OUR checkpoints of game state.
  virtual bool is_active() = 0;
  // Graph declaration, IMMEDIATE MODE: called on every render; declare controls fresh each call (no
  // retained tree); focus persists by ControlId identity. Declare nothing while content does not exist.
  virtual void build(GraphBuilder&) {}
  // Spoken when the screen gains focus. Empty = silent.
  virtual std::string screen_name() const { return {}; }
  // Stack layer: higher sits on top. 0 = base context, 10 = service windows, 20+ = overlays/modals.
  virtual int layer() const { return 0; }
  // Whether Tab wraps from the last stop back to the first.
  virtual bool wrap() const { return false; }
  // Keep per-screen nav state (focus, stop memory, expansion) when the screen pops off the stack.
  virtual bool keep_state_on_pop() const { return false; }
  // Start with no focused element: arrows bubble to global handlers (exploration) and Tab ENTERS the tree.
  virtual bool start_unfocused() const { return false; }
  // Stand down input dispatch entirely while focused (a key-capture dialog reads raw keys itself).
  virtual bool captures_raw_input() const { return false; }
  // Whether typing letters runs type-ahead over the focused stop (off in-game: letters are hotkeys).
  virtual bool allows_typeahead() const { return true; }
  // Input categories this screen uses while it is the top screen, in priority order.
  virtual std::vector<InputCategory> input_categories() const { return {InputCategory::UI}; }
  // Whether the mod takes the keyboard while this screen is current (the game then sees no key events; we
  // drive it by clicks and calls). False = pass every key through to the game: the screen is not modelled,
  // or the game itself must handle the keys (in-game movement, a text field being typed into).
  virtual bool owns_keyboard() const { return true; }
  // While this screen owns the keyboard: key codes it still lets through to the game (a text field being
  // typed into gets the letters; our navigation keys stay ours).
  virtual bool passes_key(int /*code*/) const { return false; }
  // A true modal: blocks the categories of screens below it. (Any screen that owns_keyboard() already does
  // that for key actions -- see ScreenManager::live_categories; exclusive also marks intent for the stack.)
  virtual bool exclusive() const { return false; }
  // Ctrl+Tab / Ctrl+Shift+Tab: switch the screen's tab (dir +1 / -1) from anywhere in it. False = no tabs.
  virtual bool switch_tab(int /*dir*/) { return false; }
  // Screen-level actions by id.
  virtual std::vector<ScreenAction> actions() { return {}; }
  bool invoke_action(std::string_view id);

  virtual void on_push() {}
  virtual void on_focus();    // default: speaks screen_name() (queued, never interrupting)
  virtual void on_unfocus() {}
  virtual void on_pop() {}
  virtual void on_update() {}  // per-frame, for the ACTIVE (focused) screen only

  // ---- child screen chain (mod-driven sub-screens: a dropdown's list, a confirm, a tooltip page) ----
  Screen* parent() const { return parent_; }
  Screen* active_child() const { return child_.get(); }
  Screen* deepest();
  void push_child(std::unique_ptr<Screen> child);
  void remove_child();  // disposes the whole subtree, deepest first

  // Host hooks (set once by the mod): speech and "a screen closed, drop its nav state".
  static void set_host(std::function<void(std::string_view)> speak, std::function<void(Screen*)> screen_closed);

 protected:
  static std::function<void(std::string_view)> speak_;
  static std::function<void(Screen*)> screen_closed_;

 private:
  friend class ScreenManager;
  Screen* parent_ = nullptr;
  std::unique_ptr<Screen> child_;
};

// A trivial screen: "this context is showing when this predicate is true".
class PredicateScreen : public Screen {
 public:
  PredicateScreen(std::string key, std::string name, int layer, std::function<bool()> pred)
      : key_(std::move(key)), name_(std::move(name)), layer_(layer), pred_(std::move(pred)) {}
  std::string_view key() const override { return key_; }
  bool is_active() override { return pred_ && pred_(); }
  std::string screen_name() const override { return name_; }
  int layer() const override { return layer_; }
 private:
  std::string key_, name_;
  int layer_;
  std::function<bool()> pred_;
};

// Resolves the active screen stack every frame (poll-and-diff) and dispatches lifecycle events. The stack
// is ordered bottom -> top by layer; current() is the focused screen (top outer screen's deepest child).
class ScreenManager {
 public:
  void register_screen(std::unique_ptr<Screen> s) { registered_.push_back(std::move(s)); }
  Screen* current();
  const std::vector<Screen*>& stack() const { return stack_; }
  // Active screens in focus-priority order: focused screen first, then outward/down to the base context.
  std::vector<Screen*> focused_first();
  // Live input categories for this frame, per the claim walk (stops at an exclusive screen); Global always.
  std::vector<InputCategory> live_categories();
  // Whether the current screen takes the keyboard away from the game this frame (false with no screen).
  bool owns_keyboard();
  // Host hooks: navigator attach/ensure-focus.
  void set_navigator(std::function<void(Screen*)> attach, std::function<void()> ensure_focus) { attach_ = std::move(attach); ensure_focus_ = std::move(ensure_focus); }
  void tick();

 private:
  std::vector<Screen*> resolve();
  void apply_diff(std::vector<Screen*> desired);
  void pop_tree(Screen* s);
  void sync_focus();
  std::vector<std::unique_ptr<Screen>> registered_;
  std::vector<Screen*> stack_;
  Screen* focused_ = nullptr;
  std::function<void(Screen*)> attach_;
  std::function<void()> ensure_focus_;
};

}  // namespace fa::ui
