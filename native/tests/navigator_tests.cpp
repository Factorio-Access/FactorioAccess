// GraphNavigator through a real Screen: edges of a list repeat the focused item instead of going silent.
#include <doctest/doctest.h>
#include <algorithm>
#include <memory>
#include <string>
#include <vector>
#include "ui/graph_builder.h"
#include "ui/navigator.h"
#include "ui/screen.h"

using namespace fa::ui;

namespace {
ControlId id(const char* s) { return ControlId::structural(s); }
std::shared_ptr<NodeVtable> vt(std::string label) {
  auto v = std::make_shared<NodeVtable>();
  v->announcements = {NodeAnnouncement([label] { return label; }, false, announcement_kinds::kLabel)};
  return v;
}

struct ListScreen : Screen {
  bool row = false;
  std::string_view key() const override { return "list"; }
  bool is_active() override { return true; }
  std::string screen_name() const override { return "list"; }
  void build(GraphBuilder& b) override {
    b.begin_stop("items");
    if (row) b.start_row("items");
    b.add_item(id("a"), vt("a"));
    b.add_item(id("b"), vt("b"));
    b.add_item(id("c"), vt("c"));
    if (row) b.end_row();
  }
};

struct Harness {
  std::vector<std::string> spoken;
  int frame = 0;
  ListScreen screen;
  GraphNavigator nav{NavigatorHost{[this](std::string_view t, bool) { spoken.emplace_back(t); }, {}, [] { return true; }, [this] { return frame; }}};
  Harness() { nav.attach(&screen); nav.ensure_focus(); }
  std::string act(std::string_view key) { spoken.clear(); nav.on_action(key); return spoken.empty() ? std::string() : spoken.back(); }
};
}  // namespace

TEST_CASE("vertical list: Up at the top and Down at the bottom repeat the item; Left/Right say nothing") {
  Harness h;
  CHECK(h.spoken.back().find("a") != std::string::npos);
  CHECK(h.act(ui_actions::Up) == "a");        // already at the top: repeated
  CHECK(h.act(ui_actions::Down) == "b");
  CHECK(h.act(ui_actions::Down) == "c");
  CHECK(h.act(ui_actions::Down) == "c");      // bottom: repeated
  CHECK(h.act(ui_actions::Left) == "");       // not this list's axis
  CHECK(h.act(ui_actions::Right) == "");
  CHECK(h.act(ui_actions::End) == "c");       // Home/End at the edge repeat too
  CHECK(h.act(ui_actions::Home) == "a");
  CHECK(h.act(ui_actions::Home) == "a");
}

TEST_CASE("row: Left/Right repeat at the ends, Up/Down say nothing") {
  Harness h;
  h.screen.row = true;
  h.nav.attach(&h.screen);   // content changed: rebuild as a row
  h.frame += 100; h.nav.ensure_focus();
  CHECK(h.act(ui_actions::Left) == "a");
  CHECK(h.act(ui_actions::Right) == "b");
  CHECK(h.act(ui_actions::Right) == "c");
  CHECK(h.act(ui_actions::Right) == "c");
  CHECK(h.act(ui_actions::Up) == "");
  CHECK(h.act(ui_actions::Down) == "");
}

// Regression (2026-08-26): the search scope used to hold GraphNode* from the render you typed in; every arrow
// through the results rerenders (focus_at_column), so by the second arrow those pointers were freed arena memory
// and the focus landed on whatever the stale id resolved to (the tab row included). The scope is by ControlId now.
namespace {
struct WordsScreen : Screen {
  int builds = 0;
  std::string_view key() const override { return "words"; }
  bool is_active() override { return true; }
  std::string screen_name() const override { return "words"; }
  void build(GraphBuilder& b) override {
    ++builds;
    b.begin_stop("items");
    b.add_item(id("apple"), vt("apple"));
    b.add_item(id("banana"), vt("banana"));
    b.add_item(id("avocado"), vt("avocado"));
    b.add_item(id("apricot"), vt("apricot"));
  }
};
}  // namespace

TEST_CASE("type-ahead results survive rerenders between the typing and the arrows") {
  std::vector<std::string> spoken;
  int frame = 0;
  WordsScreen screen;
  GraphNavigator nav{NavigatorHost{[&](std::string_view t, bool) { spoken.emplace_back(t); }, {}, [] { return true; }, [&] { return frame; }}};
  nav.attach(&screen); nav.ensure_focus();
  auto tick = [&](std::u16string_view typed, bool down) {
    TypeaheadInput in; in.typed = typed; in.down_held = down; in.dt = 0.016; ++frame;
    spoken.clear(); nav.tick_typeahead(in);
    return spoken.empty() ? std::string() : spoken.back();
  };
  tick(u"", false);                        // the first tick only registers the screen for type-ahead
  CHECK(tick(u"a", false) == "apple");
  // Many rerenders before the first arrow: the render the scope was built from is long retired.
  for (int i = 0; i < 5; ++i) nav.announce_current();
  CHECK(tick(u"", true) == "avocado");
  CHECK(tick(u"", false) == "");           // arrow released: no step
  for (int i = 0; i < 5; ++i) nav.announce_current();
  CHECK(tick(u"", true) == "apricot");
  CHECK(tick(u"", false) == "");
  CHECK(tick(u"", true) == "banana");      // the substring tier (the a in banana) ranks last
  CHECK(tick(u"", false) == "");
  CHECK(tick(u"", true) == "apple");       // and the results wrap
  CHECK(screen.builds > 10);
}

TEST_CASE("on_focus fires on a user landing, once per change of node, not on an edge repeat") {
  struct FocusScreen : Screen {
    int fired = 0;
    std::string_view key() const override { return "f"; }
    bool is_active() override { return true; }
    std::string screen_name() const override { return "f"; }
    void build(GraphBuilder& b) override {
      b.begin_stop("items");
      b.start_row("items");
      b.add_item(id("a"), vt("a"));
      auto v = vt("b"); v->on_focus = [this] { ++fired; };
      b.add_item(id("b"), v);
      b.add_item(id("c"), vt("c"));
      b.end_row();
    }
  };
  std::vector<std::string> spoken; int frame = 0;
  FocusScreen screen;
  GraphNavigator nav{NavigatorHost{[&](std::string_view t, bool) { spoken.emplace_back(t); }, {}, [] { return true; }, [&] { return frame; }}};
  nav.attach(&screen); nav.ensure_focus();
  CHECK(screen.fired == 0);          // the initial seat is not a user landing
  nav.on_action(ui_actions::Right);  // a -> b
  CHECK(screen.fired == 1);
  nav.on_action(ui_actions::Right);  // b -> c
  nav.on_action(ui_actions::Left);   // c -> b
  CHECK(screen.fired == 2);
  nav.on_action(ui_actions::Home);   // b -> a
  nav.on_action(ui_actions::End);    // a -> c
  CHECK(screen.fired == 2);
}

namespace {
// A tab strip stop, then a page stop holding a plain line and two top-level tree groups (the skills window's
// Constellations tab). Home/End on a group must stay inside the page stop: the groups and the tab nodes share a
// null parent, and the sibling walk once ran into the tab strip (2026-08-27).
struct TabbedTreeScreen : Screen {
  std::string_view key() const override { return "tabbed"; }
  bool is_active() override { return true; }
  std::string screen_name() const override { return "tabbed"; }
  void build(GraphBuilder& b) override {
    b.begin_stop("tabs");
    b.start_row("tabs");
    b.add_item(id("t1"), vt("t1"));
    b.add_item(id("t2"), vt("t2"));
    b.end_row();
    b.begin_stop("page");
    b.add_item(id("hdr"), vt("hdr"));
    b.begin_group(id("g1"), vt("g1"));
    b.add_item(id("g1.s1"), vt("g1s1"));
    b.end_group();
    b.begin_group(id("g2"), vt("g2"));
    b.add_item(id("g2.s1"), vt("g2s1"));
    b.end_group();
  }
};
}  // namespace

TEST_CASE("Home/End on a top-level tree group stay within the page stop, never the tab strip") {
  std::vector<std::string> spoken;
  int frame = 0;
  TabbedTreeScreen screen;
  GraphNavigator nav{NavigatorHost{[&](std::string_view t, bool) { spoken.emplace_back(t); }, {}, [] { return true; }, [&] { return frame; }}};
  nav.attach(&screen); nav.ensure_focus();
  auto act = [&](std::string_view k) { spoken.clear(); nav.on_action(k); return spoken.empty() ? std::string() : spoken.back(); };
  CHECK(act(ui_actions::Next).find("hdr") != std::string::npos);   // into the page stop
  CHECK(act(ui_actions::Down).find("g1") != std::string::npos);
  CHECK(act(ui_actions::Down).find("g2") != std::string::npos);
  std::string home = act(ui_actions::Home);
  CHECK(home.find("hdr") != std::string::npos);
  CHECK(home.find("t1") == std::string::npos);
  CHECK(act(ui_actions::End).find("g2") != std::string::npos);
}

namespace {
// A titled list whose rows remove themselves on Enter (the stash screen's "your items").
struct VanishScreen : Screen {
  std::vector<std::string> items{"a", "b", "c"};
  std::string_view key() const override { return "vanish"; }
  bool is_active() override { return true; }
  std::string screen_name() const override { return "vanish"; }
  void build(GraphBuilder& b) override {
    b.begin_stop("tabs");
    auto tab = vt("stash"); tab->on_activate = [] {};
    b.add_item(id("tab0"), tab);
    b.begin_stop("mine");
    b.push_context("your items", "list");
    for (const std::string& i : items) {
      auto v = vt(i);
      v->on_activate = [this, i] { items.erase(std::find(items.begin(), items.end(), i)); };
      b.add_item(ControlId::structural(i), v);
    }
    b.pop_context();
  }
};
}  // namespace

TEST_CASE("Enter that removes the focused row lands on the next row and reads it as a sibling, not the title again") {
  std::vector<std::string> spoken;
  int frame = 0;
  VanishScreen screen;
  GraphNavigator nav{NavigatorHost{[&](std::string_view t, bool) { spoken.emplace_back(t); }, {}, [] { return true; }, [&] { return frame; }}};
  nav.attach(&screen); nav.ensure_focus();
  nav.focus_node(id("a"), false); frame += 100; nav.ensure_focus();
  spoken.clear();
  nav.on_action("ui.activate");   // removes "a"
  frame += 100; nav.ensure_focus();      // past the idle-render throttle: the rebuild, focus must land on "b"
  REQUIRE(!spoken.empty());
  CHECK(spoken.back() == "b");           // not "your items, b"
  spoken.clear();
  nav.on_action("ui.activate");   // removes "b"
  frame += 100; nav.ensure_focus();
  REQUIRE(!spoken.empty());
  CHECK(spoken.back() == "c");
}
