#include <algorithm>
#include <ostream>
#include <doctest/doctest.h>
#include <memory>
#include <string>
#include <vector>
#include "ui/screen.h"

using namespace fa::ui;

namespace {
struct Log { std::vector<std::string> events; };

struct TestScreen : Screen {
  TestScreen(std::string k, int layer, bool* active, Log* log) : k_(std::move(k)), layer_(layer), active_(active), log_(log) {}
  std::string_view key() const override { return k_; }
  bool is_active() override { return *active_; }
  int layer() const override { return layer_; }
  std::string screen_name() const override { return k_; }
  void on_push() override { log_->events.push_back("push " + k_); }
  void on_focus() override { Screen::on_focus(); log_->events.push_back("focus " + k_); }
  void on_unfocus() override { log_->events.push_back("unfocus " + k_); }
  void on_pop() override { log_->events.push_back("pop " + k_); }
  std::vector<InputCategory> input_categories() const override { return cats_; }
  bool exclusive() const override { return exclusive_; }
  bool owns_keyboard() const override { return owns_keyboard_; }
  std::vector<InputCategory> cats_{InputCategory::UI};
  bool exclusive_ = false;
  bool owns_keyboard_ = true;
 private:
  std::string k_; int layer_; bool* active_; Log* log_;
};
}  // namespace

TEST_CASE("stack diff: push bottom-up, pop top-down, focus follows the top; covered screens keep state") {
  Log log; bool menu = true, modal = false;
  std::vector<std::string> spoken;
  Screen::set_host([&](std::string_view s) { spoken.emplace_back(s); }, [&](Screen* s) { log.events.push_back("closed " + std::string(s->key())); });
  ScreenManager sm;
  sm.register_screen(std::make_unique<TestScreen>("menu", 0, &menu, &log));
  sm.register_screen(std::make_unique<TestScreen>("modal", 30, &modal, &log));
  sm.tick();
  CHECK(sm.current()->key() == "menu");
  CHECK(spoken == std::vector<std::string>{"menu"});
  modal = true;
  sm.tick();
  CHECK(sm.current()->key() == "modal");
  CHECK(log.events == std::vector<std::string>{"push menu", "focus menu", "push modal", "unfocus menu", "focus modal"});
  modal = false;
  sm.tick();
  CHECK(sm.current()->key() == "menu");
  CHECK(log.events.back() == "focus menu");
  // the modal was popped (and its nav state dropped), the menu was never re-pushed
  CHECK(std::count(log.events.begin(), log.events.end(), "push menu") == 1);
  CHECK(std::count(log.events.begin(), log.events.end(), "closed modal") == 1);
}

TEST_CASE("live categories: a keyboard-owning or exclusive screen ends the walk; a pass-through overlay unions; Global always appended") {
  Screen::set_host({}, {});  // the previous test's hooks captured locals that are gone
  Log log; bool a = true, b = true;
  ScreenManager sm;
  auto base = std::make_unique<TestScreen>("base", 0, &a, &log); base->cats_ = {InputCategory::Exploration, InputCategory::InGame};
  auto top = std::make_unique<TestScreen>("top", 10, &b, &log); top->cats_ = {InputCategory::UI};
  TestScreen* top_raw = top.get();
  sm.register_screen(std::move(base)); sm.register_screen(std::move(top));
  sm.tick();
  // A window over the world takes the keyboard: the world's keys are NOT live under it (type-ahead letters
  // must not fire the world's review/action keys).
  CHECK(sm.live_categories() == std::vector<InputCategory>{InputCategory::UI, InputCategory::Global});
  // A pass-through overlay (the game keeps the keys) leaves the screens beneath it live.
  top_raw->owns_keyboard_ = false;
  CHECK(sm.live_categories() == std::vector<InputCategory>{InputCategory::UI, InputCategory::Exploration, InputCategory::InGame, InputCategory::Global});
  top_raw->exclusive_ = true;
  CHECK(sm.live_categories() == std::vector<InputCategory>{InputCategory::UI, InputCategory::Global});
}

TEST_CASE("keyboard ownership follows the current screen; no screen = the game keeps it") {
  Screen::set_host({}, {});
  Log log; bool base_on = true, top_on = false;
  ScreenManager sm;
  CHECK_FALSE(sm.owns_keyboard());
  auto base = std::make_unique<TestScreen>("base", 0, &base_on, &log); base->owns_keyboard_ = false;
  auto top = std::make_unique<TestScreen>("top", 10, &top_on, &log);
  sm.register_screen(std::move(base)); sm.register_screen(std::move(top));
  sm.tick();
  CHECK_FALSE(sm.owns_keyboard());  // pass-through base screen
  top_on = true; sm.tick();
  CHECK(sm.owns_keyboard());        // a modelled screen on top takes the keyboard
  top_on = false; sm.tick();
  CHECK_FALSE(sm.owns_keyboard());
}

TEST_CASE("child chain: deepest child is current; removing the outer screen disposes the subtree") {
  Screen::set_host({}, {});
  Log log; bool a = true;
  ScreenManager sm;
  sm.register_screen(std::make_unique<TestScreen>("outer", 0, &a, &log));
  sm.tick();
  Screen* outer = sm.current();
  outer->push_child(std::make_unique<TestScreen>("child", 0, &a, &log));
  sm.tick();
  CHECK(sm.current()->key() == "child");
  auto order = sm.focused_first();
  CHECK(order.size() == 2); CHECK(order[0]->key() == "child"); CHECK(order[1]->key() == "outer");
  a = false;
  sm.tick();
  CHECK(sm.current() == nullptr);
  CHECK(log.events.back() == "pop outer");
  CHECK(std::count(log.events.begin(), log.events.end(), "pop child") == 1);
}
