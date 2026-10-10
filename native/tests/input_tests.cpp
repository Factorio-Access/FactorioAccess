#include <doctest/doctest.h>
#include <set>
#include "ui/input.h"

using namespace fa::ui;

struct FakeKeys : KeySource {
  std::set<int> down, pressed, up;
  bool c = false, s = false, a = false;
  bool just_pressed(int k) const override { return pressed.count(k) > 0; }
  bool held(int k) const override { return down.count(k) > 0; }
  bool released(int k) const override { return up.count(k) > 0; }
  bool ctrl() const override { return c; }
  bool shift() const override { return s; }
  bool alt() const override { return a; }
  void press(int k) { pressed = {k}; down.insert(k); }
  void hold_only() { pressed.clear(); }
  void release(int k) { down.erase(k); up = {k}; pressed.clear(); }
};

TEST_CASE("exact modifier match: Ctrl+A does not fire bare A") {
  InputManager m;
  int bare = 0, ctrl = 0;
  m.register_action("a", "A", InputCategory::Global, [&] { ++bare; }).bind(0x1e);
  m.register_action("ca", "Ctrl A", InputCategory::Global, [&] { ++ctrl; }).bind(0x1e, true);
  m.set_live_categories({});
  FakeKeys k; k.c = true; k.press(0x1e);
  m.tick(0.0, k, {});
  CHECK(bare == 0); CHECK(ctrl == 1);
}

TEST_CASE("chord shadowing: the higher-ranked category owns an identical chord") {
  InputManager m;
  int ui = 0, expl = 0;
  m.register_action("ui.down", "", InputCategory::UI, [&] { ++ui; }).bind(0x79);
  m.register_action("explore.down", "", InputCategory::Exploration, [&] { ++expl; }).bind(0x79);
  FakeKeys k; k.press(0x79);
  m.set_live_categories({InputCategory::UI, InputCategory::Exploration});
  m.tick(0.0, k, {});
  CHECK(ui == 1); CHECK(expl == 0);
  m.set_live_categories({InputCategory::Exploration, InputCategory::UI});
  m.tick(1.0, k, {});
  CHECK(ui == 1); CHECK(expl == 1);
}

TEST_CASE("categories not live do not fire; Global always does") {
  InputManager m;
  int g = 0, u = 0;
  m.register_action("g", "", InputCategory::Global, [&] { ++g; }).bind(0x3b);
  m.register_action("u", "", InputCategory::UI, [&] { ++u; }).bind(0x3c);
  m.set_live_categories({});
  FakeKeys k; k.pressed = {0x3b, 0x3c}; k.down = {0x3b, 0x3c};
  m.tick(0.0, k, {});
  CHECK(g == 1); CHECK(u == 0);
}

TEST_CASE("typematic repeat fires after the delay, only for an action pressed in this hold") {
  InputManager m;
  int n = 0;
  m.register_action("down", "", InputCategory::Global, [&] { ++n; }).bind(0x79).repeating();
  m.set_typematic({0.4, 0.1});
  FakeKeys k; k.press(0x79);
  m.tick(0.0, k, {});  CHECK(n == 1);
  k.hold_only();
  m.tick(0.3, k, {});  CHECK(n == 1);
  m.tick(0.45, k, {}); CHECK(n == 2);
  m.tick(0.5, k, {});  CHECK(n == 2);
  m.tick(0.56, k, {}); CHECK(n == 3);
  k.release(0x79);
  m.tick(0.6, k, {});  CHECK(n == 3);
  // held without a press (modifier released on a shared key) must not repeat
  k.down = {0x79}; k.pressed.clear();
  m.tick(1.5, k, {});  CHECK(n == 3);
}

TEST_CASE("UI dispatch consumes before Performed") {
  InputManager m;
  int performed = 0;
  m.register_action("enter", "", InputCategory::UI, [&] { ++performed; }).bind(0x1c);
  m.set_live_categories({InputCategory::UI});
  FakeKeys k; k.press(0x1c);
  m.tick(0.0, k, [](InputAction&) { return true; });
  CHECK(performed == 0);
  m.tick(1.0, k, [](InputAction&) { return false; });
  CHECK(performed == 1);
}

TEST_CASE("chord round-trips through serialize") {
  Chord c{0x1e, true, false, true};
  CHECK(c.serialize() == "0x1e|ctrl,alt");
  CHECK(Chord::deserialize("0x1e|ctrl,alt") == c);
  CHECK(Chord::deserialize("0x79") == Chord{0x79});
  CHECK(Chord::deserialize("garbage").key == -1);
}
