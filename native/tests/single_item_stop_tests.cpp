// Ported from wotr-access tests/SingleItemStopTests.cs (xUnit -> doctest). Every case is carried over.
//
// Repro for the user report: tabbing into a labeled list that holds a SINGLE item skipped the list's
// context (spoke just the item) -- the loot-window case. The context chain must announce regardless of
// how many items the stop holds.
#include <doctest/doctest.h>

#include <optional>
#include <string>

#include "ui/graph_announcer.h"
#include "ui/graph_builder.h"
#include "ui/key_graph.h"

using fa::ui::ControlId;
using fa::ui::GraphAnnouncer;
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

std::string spoken(const std::optional<std::string>& s) { return s ? *s : std::string("<nothing>"); }

GraphRenderPtr two_stops(int items_in_b) {
  GraphBuilder b;
  b.begin_stop(Key("a")).add_item(id("back"), vt("Back"));
  b.begin_stop(Key("b")).push_context("Corpse of Mongrel", "list");
  for (int i = 0; i < items_in_b; i++)
    b.add_item(id("item" + std::to_string(i)), vt("Longsword " + std::to_string(i)));
  b.pop_context();
  return b.build();
}

// Installs the host's "n of m" wording for the duration of a case (the announcer's hooks are statics).
struct ScopedPositions {
  ScopedPositions() : previous(GraphAnnouncer::position_text) {
    GraphAnnouncer::position_text = [](int i, int n) {
      return std::to_string(i) + " of " + std::to_string(n);
    };
  }
  ~ScopedPositions() { GraphAnnouncer::position_text = previous; }
  decltype(GraphAnnouncer::position_text) previous;
};

}  // namespace

TEST_CASE("tab into a multi-item stop speaks the context") {
  const GraphRenderPtr render = two_stops(2);
  const GraphNode* from = render->node_at(id("back"));
  const GraphState state;
  const GraphNode* land = KeyGraph::stop_landing(*render, state, Key("b"));
  REQUIRE(land != nullptr);
  CHECK(land->id == id("item0"));
  ScopedPositions positions;
  CHECK(spoken(GraphAnnouncer::compose(from, land)) == "Corpse of Mongrel, list, Longsword 0, 1 of 2");
}

TEST_CASE("tab into a single-item stop speaks the context") {
  const GraphRenderPtr render = two_stops(1);
  const GraphNode* from = render->node_at(id("back"));
  const GraphState state;
  const GraphNode* land = KeyGraph::stop_landing(*render, state, Key("b"));
  REQUIRE(land != nullptr);
  CHECK(land->id == id("item0"));
  ScopedPositions positions;
  CHECK(spoken(GraphAnnouncer::compose(from, land)) == "Corpse of Mongrel, list, Longsword 0");
}

TEST_CASE("tab between same-named contexts speaks the new context") {
  // Two containers with the SAME display name (two mongrel corpses), one item each -- the label-pathed
  // ctx ids collide, the prefix diff thinks focus never left the first container, and tabbing speaks
  // just the bare item.
  GraphBuilder b;
  b.begin_stop(Key("s1")).push_context("Corpse of Mongrel", "list");
  b.add_item(id("i1"), vt("Longsword"));
  b.pop_context();
  b.begin_stop(Key("s2")).push_context("Corpse of Mongrel", "list");
  b.add_item(id("i2"), vt("Dagger"));
  b.pop_context();
  const GraphRenderPtr render = b.build();

  const GraphNode* from = render->node_at(id("i1"));
  const GraphState state;
  const GraphNode* land = KeyGraph::stop_landing(*render, state, Key("s2"));
  REQUIRE(land != nullptr);
  CHECK(land->id == id("i2"));
  ScopedPositions positions;
  CHECK(spoken(GraphAnnouncer::compose(from, land)) == "Corpse of Mongrel, list, Dagger");
}

TEST_CASE("members of a multi-item row say the row wording, list items keep n of m") {
  GraphBuilder b;
  b.begin_stop(Key("s"));
  b.add_item(id("a"), vt("Apple"));
  b.add_item(id("b"), vt("Pear"));
  b.start_row(Key("bar"));
  b.add_item(id("back"), vt("Back"));
  b.add_item(id("ok"), vt("Confirm"));
  b.end_row();
  const GraphRenderPtr render = b.build();

  ScopedPositions positions;
  auto previous = GraphAnnouncer::row_text;
  GraphAnnouncer::row_text = [] { return std::string("row"); };
  CHECK(spoken(GraphAnnouncer::compose(nullptr, render->node_at(id("b")))) == "Pear, 2 of 2");
  CHECK(spoken(GraphAnnouncer::compose(nullptr, render->node_at(id("ok")))) == "Confirm, row");
  GraphAnnouncer::row_text = previous;
}
