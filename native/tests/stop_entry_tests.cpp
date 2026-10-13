// A stop's entry (GraphBuilder::set_stop_entry): where focus lands entering a stop with nothing remembered or
// selected -- a dialog's button bar lands on its confirm button rather than the leftmost Exit.
#include <doctest/doctest.h>

#include <string>

#include "ui/graph_builder.h"
#include "ui/key_graph.h"

using fa::ui::ControlId;
using fa::ui::GraphBuilder;
using fa::ui::GraphNode;
using fa::ui::GraphRenderPtr;
using fa::ui::GraphState;
using fa::ui::Key;
using fa::ui::KeyGraph;
using fa::ui::NodeAnnouncement;
using fa::ui::NodeVtable;
using fa::ui::NodeVtablePtr;

namespace {

NodeVtablePtr vt(std::string label) {
  auto v = std::make_shared<NodeVtable>();
  v->announcements.push_back(NodeAnnouncement::fixed(std::move(label)));
  return v;
}

ControlId id(std::string key) { return ControlId::structural(Key(std::move(key))); }

// A content stop, then a button bar: Exit, Load game, Respawn (the entry when `entry`).
GraphRenderPtr dialog(bool entry) {
  GraphBuilder b;
  b.begin_stop(Key("content")).add_item(id("field"), vt("Name"));
  b.begin_stop(Key("buttons")).start_row();
  b.add_item(id("exit"), vt("Exit"));
  b.add_item(id("load"), vt("Load game"));
  b.add_item(id("respawn"), vt("Respawn"));
  if (entry) b.set_stop_entry(id("respawn"));
  b.end_row();
  return b.build();
}

ControlId landing(const GraphRenderPtr& render, const GraphState& state, const char* stop) {
  const GraphNode* n = KeyGraph::stop_landing(*render, state, Key(stop));
  REQUIRE(n != nullptr);
  return n->id;
}

}  // namespace

TEST_CASE("a stop without an entry lands on its first node") {
  CHECK(landing(dialog(false), GraphState{}, "buttons") == id("exit"));
}

TEST_CASE("a stop lands on its entry") {
  CHECK(landing(dialog(true), GraphState{}, "buttons") == id("respawn"));
}

TEST_CASE("a remembered position beats the entry") {
  GraphState state;
  state.stop_memory.insert_or_assign(Key("buttons"), id("load"));
  CHECK(landing(dialog(true), state, "buttons") == id("load"));
}

TEST_CASE("an entry belongs to the stop it was set in") {
  GraphRenderPtr render = dialog(true);
  CHECK(landing(render, GraphState{}, "content") == id("field"));
}

TEST_CASE("an entry naming a node of another stop is dropped") {
  GraphBuilder b;
  b.begin_stop(Key("a")).add_item(id("x"), vt("X"));
  b.begin_stop(Key("b")).add_item(id("y"), vt("Y"));
  b.add_item(id("z"), vt("Z"));
  b.set_stop_entry(id("x"));
  GraphRenderPtr render = b.build();
  CHECK(landing(render, GraphState{}, "b") == id("y"));
  CHECK(landing(render, GraphState{}, "a") == id("x"));
}
