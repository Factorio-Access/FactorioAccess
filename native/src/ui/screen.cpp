#include "ui/screen.h"
#include <algorithm>

namespace fa::ui {

std::function<void(std::string_view)> Screen::speak_;
std::function<void(Screen*)> Screen::screen_closed_;

void Screen::set_host(std::function<void(std::string_view)> speak, std::function<void(Screen*)> screen_closed) {
  speak_ = std::move(speak);
  screen_closed_ = std::move(screen_closed);
}

bool Screen::invoke_action(std::string_view id) {
  for (auto& a : actions())
    if (a.id == id) { if (a.execute) a.execute(); return true; }
  return false;
}

// Screen-change announcement: never interrupt (carried SayTheSpire preference). The navigator separately
// announces the focused element within the screen.
void Screen::on_focus() {
  std::string n = screen_name();
  if (!n.empty() && speak_) speak_(n);
}

Screen* Screen::deepest() {
  Screen* s = this;
  while (s->child_) s = s->child_.get();
  return s;
}

void Screen::push_child(std::unique_ptr<Screen> child) {
  if (!child) return;
  if (child_) remove_child();
  child->parent_ = this;
  child_ = std::move(child);
  child_->on_push();
}

void Screen::remove_child() {
  if (!child_) return;
  if (child_->child_) child_->remove_child();  // grandchildren first
  child_->on_pop();
  if (screen_closed_) screen_closed_(child_.get());
  child_->parent_ = nullptr;
  child_.reset();
}

Screen* ScreenManager::current() { return stack_.empty() ? nullptr : stack_.back()->deepest(); }

std::vector<Screen*> ScreenManager::focused_first() {
  std::vector<Screen*> out;
  for (size_t i = stack_.size(); i-- > 0;) {
    std::vector<Screen*> chain;
    for (Screen* s = stack_[i]; s; s = s->active_child()) chain.push_back(s);
    for (size_t j = chain.size(); j-- > 0;) out.push_back(chain[j]);
  }
  return out;
}

std::vector<InputCategory> ScreenManager::live_categories() {
  std::vector<InputCategory> cats;
  for (Screen* s : focused_first()) {
    for (auto c : s->input_categories())
      if (std::find(cats.begin(), cats.end(), c) == cats.end()) cats.push_back(c);
    // A modal, or any screen that takes the keyboard, is the end of the walk: nothing beneath it hears keys.
    // (Only a pass-through overlay -- owns_keyboard() false -- lets the screens under it keep their keys; a
    // window over the world must NOT leave the world's letter keys live while the player types ahead in it,
    // which is what happened before 2026-08-26.)
    if (s->exclusive() || s->owns_keyboard()) break;
  }
  if (std::find(cats.begin(), cats.end(), InputCategory::Global) == cats.end()) cats.push_back(InputCategory::Global);
  return cats;
}

bool ScreenManager::owns_keyboard() {
  Screen* c = current();
  return c && c->owns_keyboard();
}

std::vector<Screen*> ScreenManager::resolve() {
  std::vector<Screen*> active;
  for (auto& s : registered_) if (s->is_active()) active.push_back(s.get());
  std::stable_sort(active.begin(), active.end(), [](Screen* a, Screen* b) { return a->layer() < b->layer(); });
  return active;
}

// Diff the polled active set against the persistent stack: pop outer screens that went inactive (each
// with its whole child subtree, top -> bottom) and push newly-active ones (bottom -> top).
void ScreenManager::apply_diff(std::vector<Screen*> desired) {
  for (size_t i = stack_.size(); i-- > 0;)
    if (std::find(desired.begin(), desired.end(), stack_[i]) == desired.end()) pop_tree(stack_[i]);
  for (Screen* s : desired)
    if (std::find(stack_.begin(), stack_.end(), s) == stack_.end()) s->on_push();
  stack_ = std::move(desired);
}

void ScreenManager::pop_tree(Screen* s) {
  // Unfocus before the subtree is destroyed, so sync_focus never touches a dead screen.
  for (Screen* c = s; c; c = c->active_child())
    if (c == focused_) { focused_->on_unfocus(); focused_ = nullptr; }
  s->remove_child();
  s->on_pop();
  // Closing a screen clears its nav state (reopening starts fresh) unless it opts out.
  if (!s->keep_state_on_pop() && Screen::screen_closed_) Screen::screen_closed_(s);
}

// Re-attach the navigator whenever the deepest (focused) screen changes, from an outer push/pop OR a child
// push/remove. Idempotent.
void ScreenManager::sync_focus() {
  Screen* cur = current();
  if (cur == focused_) return;
  // The previously focused screen may have been destroyed with its subtree (a popped outer screen, a
  // replaced child): only unfocus it if it is still reachable from the stack.
  if (focused_) {
    auto alive = focused_first();
    if (std::find(alive.begin(), alive.end(), focused_) != alive.end()) focused_->on_unfocus();
  }
  focused_ = cur;
  if (cur) cur->on_focus();
  if (attach_) attach_(cur);
}

void ScreenManager::tick() {
  apply_diff(resolve());
  sync_focus();
  if (Screen* c = current()) c->on_update();  // may push/remove child screens
  sync_focus();
  if (ensure_focus_) ensure_focus_();
}

}  // namespace fa::ui
