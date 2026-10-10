// Ported from wotr-access tests/GraphBuilderTests.cs (xUnit -> doctest). Every case is carried over.
// Exception mapping: InvalidOperationException -> std::logic_error, ArgumentException -> std::invalid_argument.
#include <doctest/doctest.h>

#include <stdexcept>
#include <string>
#include <unordered_set>

#include "ui/graph_builder.h"

using fa::ui::ControlId;
using fa::ui::GraphBuilder;
using fa::ui::GraphDir;
using fa::ui::GraphRenderPtr;
using fa::ui::Key;
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

}  // namespace

TEST_CASE("single items form a vertical menu") {
  const GraphRenderPtr render = GraphBuilder()
                                    .add_item(id("a"), vt("A"))
                                    .add_item(id("b"), vt("B"))
                                    .add_item(id("c"), vt("C"))
                                    .build();

  CHECK(render->start_key == id("a"));
  CHECK(render->node_at(id("a"))->transition(GraphDir::Down)->destination == id("b"));
  CHECK(render->node_at(id("b"))->transition(GraphDir::Up)->destination == id("a"));
  CHECK(render->node_at(id("b"))->transition(GraphDir::Down)->destination == id("c"));
  CHECK_FALSE(render->node_at(id("a"))->has_transition(GraphDir::Up));
  CHECK_FALSE(render->node_at(id("a"))->has_transition(GraphDir::Left));
  CHECK_FALSE(render->node_at(id("a"))->has_transition(GraphDir::Right));
}

TEST_CASE("rows wire horizontally") {
  const GraphRenderPtr render =
      GraphBuilder().start_row().add_item(id("a"), vt("A")).add_item(id("b"), vt("B")).end_row().build();

  CHECK(render->node_at(id("a"))->transition(GraphDir::Right)->destination == id("b"));
  CHECK(render->node_at(id("b"))->transition(GraphDir::Left)->destination == id("a"));
}

TEST_CASE("shared row keys preserve the column") {
  const GraphRenderPtr render = GraphBuilder()
                                    .start_row(Key("grid"))
                                    .add_item(id("a1"), vt("A1"))
                                    .add_item(id("a2"), vt("A2"))
                                    .end_row()
                                    .start_row(Key("grid"))
                                    .add_item(id("b1"), vt("B1"))
                                    .add_item(id("b2"), vt("B2"))
                                    .end_row()
                                    .build();

  CHECK(render->node_at(id("a2"))->transition(GraphDir::Down)->destination == id("b2"));
  CHECK(render->node_at(id("b2"))->transition(GraphDir::Up)->destination == id("a2"));
}

TEST_CASE("unkeyed rows land on the first item") {
  const GraphRenderPtr render = GraphBuilder()
                                    .start_row()
                                    .add_item(id("a1"), vt("A1"))
                                    .add_item(id("a2"), vt("A2"))
                                    .end_row()
                                    .start_row()
                                    .add_item(id("b1"), vt("B1"))
                                    .add_item(id("b2"), vt("B2"))
                                    .end_row()
                                    .build();

  CHECK(render->node_at(id("a2"))->transition(GraphDir::Down)->destination == id("b1"));
}

TEST_CASE("a ragged keyed row falls back to the first item") {
  const GraphRenderPtr render = GraphBuilder()
                                    .start_row(Key("grid"))
                                    .add_item(id("a1"), vt("A1"))
                                    .add_item(id("a2"), vt("A2"))
                                    .add_item(id("a3"), vt("A3"))
                                    .end_row()
                                    .start_row(Key("grid"))
                                    .add_item(id("b1"), vt("B1"))
                                    .end_row()
                                    .build();

  // Column 2 doesn't exist below -> first item.
  CHECK(render->node_at(id("a3"))->transition(GraphDir::Down)->destination == id("b1"));
}

TEST_CASE("arrows never cross stops") {
  const GraphRenderPtr render =
      GraphBuilder().add_item(id("a"), vt("A")).begin_stop().add_item(id("b"), vt("B")).build();

  CHECK_FALSE(render->node_at(id("a"))->has_transition(GraphDir::Down));
  CHECK_FALSE(render->node_at(id("b"))->has_transition(GraphDir::Up));
  CHECK(render->node_at(id("a"))->stop_key != render->node_at(id("b"))->stop_key);
}

TEST_CASE("a context builds a non-focusable parent chain") {
  const GraphRenderPtr render = GraphBuilder()
                                    .push_context("Settings", "list")
                                    .add_item(id("a"), vt("A"))
                                    .push_context("Advanced")
                                    .add_item(id("b"), vt("B"))
                                    .pop_context()
                                    .add_item(id("c"), vt("C"))
                                    .build();

  const auto* a = render->node_at(id("a"));
  const auto* b2 = render->node_at(id("b"));
  const auto* c2 = render->node_at(id("c"));
  CHECK(a->parent != nullptr);
  CHECK_FALSE(a->parent->focusable);
  CHECK(a->parent->parent == nullptr);
  CHECK(a->parent == b2->parent->parent);              // Advanced nests under Settings
  CHECK(a->parent == c2->parent);                      // c popped back out to Settings
  CHECK_FALSE(render->contains(a->parent->id));        // context nodes are never navigable
}

TEST_CASE("groups emit headers and suppress collapsed subtrees") {
  std::unordered_set<ControlId> expansion;
  auto build = [&expansion] {
    return GraphBuilder(&expansion)
        .begin_group(id("combat"), vt("Combat"))
        .add_item(id("pause"), vt("Auto pause"))
        .begin_group(id("nested"), vt("Nested"))
        .add_item(id("deep"), vt("Deep"))
        .end_group()
        .end_group()
        .add_item(id("after"), vt("After"))
        .build();
  };

  const GraphRenderPtr collapsed = build();
  CHECK(collapsed->contains(id("combat")));
  CHECK(collapsed->node_at(id("combat"))->expandable);
  CHECK_FALSE(collapsed->node_at(id("combat"))->expanded);
  CHECK_FALSE(collapsed->contains(id("pause")));  // collapsed -> children swallowed
  CHECK_FALSE(collapsed->contains(id("nested")));
  CHECK(collapsed->contains(id("after")));

  expansion.insert(id("combat"));
  const GraphRenderPtr expanded = build();
  CHECK(expanded->contains(id("pause")));
  CHECK(expanded->node_at(id("combat")) == expanded->node_at(id("pause"))->parent);
  CHECK(expanded->contains(id("nested")));    // nested header visible...
  CHECK_FALSE(expanded->contains(id("deep")));  // ...but its own subtree still collapsed

  expansion.insert(id("nested"));
  const GraphRenderPtr deep = build();
  CHECK(deep->contains(id("deep")));
  CHECK(deep->node_at(id("nested")) == deep->node_at(id("deep"))->parent);
}

TEST_CASE("positions auto-stamp by sibling group") {
  std::unordered_set<ControlId> expansion;
  expansion.insert(id("g"));
  const GraphRenderPtr render = GraphBuilder(&expansion)
                                    .add_item(id("a"), vt("A"))  // top level: a, g = 2 siblings
                                    .begin_group(id("g"), vt("G"))
                                    .add_item(id("c1"), vt("C1"))  // group level: 3 siblings
                                    .add_item(id("c2"), vt("C2"))
                                    .add_item(id("c3"), vt("C3"))
                                    .end_group()
                                    .begin_stop()
                                    .add_item(id("lone"), vt("Lone"))  // single sibling -> no position
                                    .begin_stop()
                                    .start_row()
                                    .add_item(id("r1"), vt("R1"))
                                    .add_item(id("r2"), vt("R2"))
                                    .end_row()  // row members
                                    .build();

  CHECK(render->node_at(id("a"))->position_index == 1);
  CHECK(render->node_at(id("a"))->position_count == 2);
  CHECK(render->node_at(id("g"))->position_index == 2);
  CHECK(render->node_at(id("c2"))->position_index == 2);
  CHECK(render->node_at(id("c2"))->position_count == 3);
  CHECK(render->node_at(id("lone"))->position_count == 0);
  CHECK(render->node_at(id("r1"))->position_index == 1);
  CHECK(render->node_at(id("r2"))->position_index == 2);
  CHECK(render->node_at(id("r2"))->position_count == 2);
}

TEST_CASE("regions are stamped") {
  const GraphRenderPtr render = GraphBuilder()
                                    .set_region(Key("filters"))
                                    .add_item(id("a"), vt("A"))
                                    .set_region(Key("items"))
                                    .add_item(id("b"), vt("B"))
                                    .build();

  CHECK(render->node_at(id("a"))->region_key == Key("filters"));
  CHECK(render->node_at(id("b"))->region_key == Key("items"));
}

TEST_CASE("mixed modes keep declaration order") {
  // A screen declaring list -> raw grid -> button must keep that Tab-stop order (raw nodes must NOT be
  // appended after all menu rows -- that displaced sheet stops behind later buttons).
  const GraphRenderPtr render = GraphBuilder()
                                    .add_item(id("list1"), vt("L1"))
                                    .begin_stop()
                                    .add_node(id("cell1"), vt("C1"))
                                    .begin_stop()
                                    .add_item(id("button"), vt("B"))
                                    .build();

  CHECK(render->order()[0]->id == id("list1"));
  CHECK(render->order()[1]->id == id("cell1"));
  CHECK(render->order()[2]->id == id("button"));
}

TEST_CASE("a mixed stop stitches menu to raw vertically") {
  // A stop with menu controls above raw sheet content (the inventory stash: search/sort/filters over the
  // item table) must be arrow-traversable across the mode boundary.
  const GraphRenderPtr render = GraphBuilder()
                                    .add_item(id("search"), vt("Search"))
                                    .start_row()
                                    .add_item(id("f1"), vt("F1"))
                                    .add_item(id("f2"), vt("F2"))
                                    .end_row()
                                    .add_node(id("r0"), vt("Row0"))
                                    .add_node(id("r1"), vt("Row1"))
                                    .connect(id("r0"), GraphDir::Down, id("r1"))
                                    .connect(id("r1"), GraphDir::Up, id("r0"))
                                    .build();

  // Filter cells drop into the sheet's first row; the sheet's top links back up.
  CHECK(render->node_at(id("f1"))->transition(GraphDir::Down)->destination == id("r0"));
  CHECK(render->node_at(id("f2"))->transition(GraphDir::Down)->destination == id("r0"));
  CHECK(render->node_at(id("r0"))->transition(GraphDir::Up)->destination == id("f1"));
  // The sheet's own wiring is untouched.
  CHECK(render->node_at(id("r0"))->transition(GraphDir::Down)->destination == id("r1"));
}

TEST_CASE("raw mode wires explicit edges") {
  const GraphRenderPtr render = GraphBuilder()
                                    .add_node(id("a"), vt("A"))
                                    .add_node(id("b"), vt("B"))
                                    .connect(id("a"), GraphDir::Right, id("b"), "crossing the aisle")
                                    .connect(id("a"), GraphDir::Down, id("ghost"))  // undeclared -> dropped
                                    .set_start(id("b"))
                                    .build();

  CHECK(render->start_key == id("b"));
  CHECK(render->node_at(id("a"))->transition(GraphDir::Right)->label == "crossing the aisle");
  CHECK_FALSE(render->node_at(id("a"))->has_transition(GraphDir::Down));
}

TEST_CASE("guards reject misuse") {
  CHECK(GraphBuilder().build() == nullptr);  // empty = closed

  GraphBuilder dup;
  dup.add_item(id("a"), vt("A"));
  CHECK_THROWS_AS(dup.add_item(id("a"), vt("A2")), std::logic_error);

  GraphBuilder bare;
  CHECK_THROWS_AS(bare.add_item(id("x"), std::make_shared<NodeVtable>()), std::invalid_argument);
}

TEST_CASE("menu rows and raw nodes mix") {
  // A screen mixing an auto-wired list with a computed-topology grid: raw edges may reference menu nodes.
  const GraphRenderPtr render = GraphBuilder()
                                    .add_item(id("list1"), vt("List1"))
                                    .add_node(id("cell1"), vt("Cell1"))
                                    .add_node(id("cell2"), vt("Cell2"))
                                    .connect(id("cell1"), GraphDir::Right, id("cell2"))
                                    .connect(id("cell1"), GraphDir::Up, id("list1"))
                                    .build();

  CHECK(render->order().size() == 3);
  CHECK(render->node_at(id("cell1"))->transition(GraphDir::Right)->destination == id("cell2"));
  CHECK(render->node_at(id("cell1"))->transition(GraphDir::Up)->destination == id("list1"));
}
