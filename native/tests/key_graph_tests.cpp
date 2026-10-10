// Ported from wotr-access tests/KeyGraphTests.cs (xUnit -> doctest). Every case is carried over.
#include <doctest/doctest.h>

#include <string>
#include <vector>

#include "ui/graph_builder.h"
#include "ui/key_graph.h"

using fa::ui::ControlId;
using fa::ui::GraphBuilder;
using fa::ui::GraphDir;
using fa::ui::GraphRenderPtr;
using fa::ui::GraphState;
using fa::ui::Key;
using fa::ui::KeyGraph;
using fa::ui::MoveResult;
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

NodeVtablePtr radio(std::string label, bool selected) {
  auto v = std::make_shared<NodeVtable>();
  v->announcements.push_back(NodeAnnouncement::fixed(std::move(label)));
  v->announcements.push_back(NodeAnnouncement(
      [selected] { return selected ? std::string("selected") : std::string(); }, false,
      fa::ui::announcement_kinds::kSelected));
  return v;
}

}  // namespace

TEST_CASE("first render lands on start") {
  GraphState state;
  KeyGraph g(
      [] {
        return GraphBuilder().add_item(id("a"), vt("a")).add_item(id("b"), vt("b")).build();
      },
      &state);
  CHECK(g.rerender());
  CHECK(state.cur_key == id("a"));
}

TEST_CASE("move steps and stops at edges") {
  GraphState state;
  KeyGraph g(
      [] {
        return GraphBuilder().add_item(id("a"), vt("a")).add_item(id("b"), vt("b")).build();
      },
      &state);

  MoveResult r = g.move(GraphDir::Down);
  CHECK(r.moved);
  CHECK(r.to->id == id("b"));

  r = g.move(GraphDir::Down);  // at the end
  CHECK_FALSE(r.moved);
  CHECK(r.to->id == id("b"));
  CHECK(r.from == r.to);
}

TEST_CASE("move to edge goes all the way") {
  GraphState state;
  KeyGraph g(
      [] {
        return GraphBuilder()
            .add_item(id("a"), vt("a"))
            .add_item(id("b"), vt("b"))
            .add_item(id("c"), vt("c"))
            .add_item(id("d"), vt("d"))
            .build();
      },
      &state);
  const MoveResult r = g.move_to_edge(GraphDir::Down);
  CHECK(r.moved);
  CHECK(r.to->id == id("d"));
}

TEST_CASE("transition label is reported") {
  GraphState state;
  KeyGraph g(
      [] {
        return GraphBuilder()
            .add_node(id("a"), vt("A"))
            .add_node(id("b"), vt("B"))
            .connect(id("a"), GraphDir::Right, id("b"), "lane change")
            .build();
      },
      &state);

  const MoveResult r = g.move(GraphDir::Right);
  CHECK(r.moved);
  CHECK(r.transition_label == "lane change");
}

TEST_CASE("reconcile tier 2 follows the structural key across rebuilds") {
  GraphState state;
  int generation = 0;
  KeyGraph g(
      [&generation] {
        generation++;  // fresh vtables/nodes each render -- only the structural keys repeat
        return GraphBuilder()
            .add_item(id("a"), vt("A" + std::to_string(generation)))
            .add_item(id("b"), vt("B" + std::to_string(generation)))
            .build();
      },
      &state);

  g.move(GraphDir::Down);
  CHECK(state.cur_key == id("b"));
  CHECK(g.rerender());  // a whole new render
  CHECK(state.cur_key == id("b"));
}

TEST_CASE("reconcile tier 1 follows a moved object") {
  GraphState state;
  int backing = 0;
  const void* thing = &backing;  // the backing domain object
  int slot = 1;                  // its structural position, which will change

  KeyGraph g(
      [thing, &slot] {
        return GraphBuilder()
            .add_item(ControlId::structural(Key("header")), vt("Header"))
            .add_item(ControlId::referenced(thing, Key("slot" + std::to_string(slot))), vt("Thing"))
            .build();
      },
      &state);

  g.move(GraphDir::Down);  // focus the thing (at slot1)
  CHECK(state.cur_key->structural_key().text() == "slot1");

  slot = 2;  // the object moves to a different slot
  CHECK(g.rerender());
  CHECK(state.cur_key->structural_key().text() == "slot2");  // followed the reference, not the old key
}

TEST_CASE("reconcile falls back to the nearest survivor") {
  GraphState state;
  std::vector<std::string> items{"a", "b", "c", "d"};
  KeyGraph g(
      [&items] {
        GraphBuilder b;
        for (const std::string& i : items) b.add_item(id(i), vt(i));
        return b.build();
      },
      &state);

  g.move_to_edge(GraphDir::Down);  // on "d"
  items.pop_back();                // remove "d"
  items.pop_back();                // remove "c"
  CHECK(g.rerender());
  CHECK(state.cur_key == id("b"));  // nearest earlier survivor
}

TEST_CASE("suggested move is honored and consumed") {
  GraphState state;
  KeyGraph g(
      [] {
        return GraphBuilder()
            .add_item(id("a"), vt("a"))
            .add_item(id("b"), vt("b"))
            .add_item(id("c"), vt("c"))
            .build();
      },
      &state);
  state.next_suggested_move = id("c");
  CHECK(g.rerender());
  CHECK(state.cur_key == id("c"));
  CHECK_FALSE(state.next_suggested_move.has_value());
}

TEST_CASE("compute order covers all stops") {
  GraphState state;
  KeyGraph g(
      [] {
        return GraphBuilder()
            .add_item(id("a"), vt("A"))
            .begin_stop()
            .add_item(id("b"), vt("B"))
            .begin_stop()
            .add_item(id("c"), vt("C"))
            .build();
      },
      &state);

  CHECK(g.rerender());
  CHECK(state.key_order.size() == 3);  // later stops appended despite no cross-stop edges
}

TEST_CASE("stop cycling remembers the position per stop") {
  GraphState state;
  KeyGraph g(
      [] {
        return GraphBuilder()
            .add_item(id("a1"), vt("A1"))
            .add_item(id("a2"), vt("A2"))
            .begin_stop()
            .add_item(id("b1"), vt("B1"))
            .add_item(id("b2"), vt("B2"))
            .build();
      },
      &state);

  g.move(GraphDir::Down);  // a2 (remembered for stop 1)
  MoveResult r = g.move_stop(+1, false);
  CHECK(r.moved);
  CHECK(r.to->id == id("b1"));
  g.move(GraphDir::Down);  // b2

  r = g.move_stop(-1, false);
  CHECK(r.to->id == id("a2"));  // remembered, not the stop's first node

  r = g.move_stop(-1, false);  // at the first stop, no wrap
  CHECK_FALSE(r.moved);

  r = g.move_stop(-1, true);  // wraps to the last stop's memory
  CHECK(r.moved);
  CHECK(r.to->id == id("b2"));
}

TEST_CASE("region jumps within a stop") {
  GraphState state;
  KeyGraph g(
      [] {
        return GraphBuilder()
            .set_region(Key("filters"))
            .add_item(id("f1"), vt("F1"))
            .set_region(Key("items"))
            .add_item(id("i1"), vt("I1"))
            .add_item(id("i2"), vt("I2"))
            .set_region(Key("footer"))
            .add_item(id("z1"), vt("Z1"))
            .build();
      },
      &state);

  MoveResult r = g.move_region(+1);
  CHECK(r.to->id == id("i1"));
  r = g.move_region(+1);
  CHECK(r.to->id == id("z1"));
  r = g.move_region(+1);  // at the last region
  CHECK_FALSE(r.moved);
  r = g.move_region(-1);
  CHECK(r.to->id == id("i1"));
}

TEST_CASE("behavior invokers report absence") {
  GraphState state;
  bool clicked = false;
  bool adjusted = false;
  KeyGraph g(
      [&clicked, &adjusted] {
        auto v = std::make_shared<NodeVtable>();
        v->announcements.push_back(NodeAnnouncement::fixed("A"));
        v->on_activate = [&clicked] { clicked = true; };
        v->on_adjust = [&adjusted](int sign, bool) { adjusted = sign > 0; };
        return GraphBuilder().add_item(id("a"), v).build();
      },
      &state);

  CHECK(g.activate());
  CHECK(clicked);
  CHECK(g.try_adjust(+1, false));
  CHECK(adjusted);
  CHECK_FALSE(g.secondary());
  CHECK_FALSE(g.tooltip());
}

TEST_CASE("initial focus lands on the selected member") {
  GraphState state;
  KeyGraph g(
      [] {
        return GraphBuilder()
            .add_item(id("a"), radio("A", false))
            .add_item(id("b"), radio("B", false))
            .add_item(id("c"), radio("C", true))  // the checked radio, deep in the list
            .add_item(id("d"), radio("D", false))
            .build();
      },
      &state);

  CHECK(g.rerender());
  CHECK(state.cur_key == id("c"));  // not the first node
}

TEST_CASE("tab into a stop lands on the selected member when there is no memory") {
  GraphState state;
  KeyGraph g(
      [] {
        return GraphBuilder()
            .add_item(id("a1"), vt("A1"))
            .begin_stop()
            .add_item(id("b1"), radio("B1", false))
            .add_item(id("b2"), radio("B2", true))  // selected in the second stop
            .build();
      },
      &state);

  MoveResult r = g.move_stop(+1, false);
  CHECK(r.moved);
  CHECK(r.to->id == id("b2"));  // landed on the checked one, not b1

  // But remembered position wins on return.
  g.move(GraphDir::Up);   // b1
  g.move_stop(-1, false);  // to stop 1
  r = g.move_stop(+1, false);
  CHECK(r.to->id == id("b1"));  // memory beats selection
}

TEST_CASE("a raw block between menu rows stays reachable") {
  // Menu row, raw block (its own internal wiring), menu row -- all one stop. Menu wiring must BREAK at
  // the raw block (declaration order), and the stitcher wires the seams; otherwise the menu edges skip
  // over the block and it becomes an unreachable island (the class progression grid between the skills
  // list and the auto-level button).
  GraphState state;
  KeyGraph g(
      [] {
        return GraphBuilder()
            .add_item(id("above"), vt("Above"))
            .add_node(id("raw1"), vt("Raw 1"))
            .add_node(id("raw2"), vt("Raw 2"))
            .connect(id("raw1"), GraphDir::Down, id("raw2"))
            .connect(id("raw2"), GraphDir::Up, id("raw1"))
            .add_item(id("below"), vt("Below"))
            .build();
      },
      &state);

  CHECK(g.rerender());
  CHECK(state.cur_key == id("above"));
  g.move(GraphDir::Down);
  CHECK(state.cur_key == id("raw1"));  // into the block, not over it
  g.move(GraphDir::Down);
  CHECK(state.cur_key == id("raw2"));
  g.move(GraphDir::Down);
  CHECK(state.cur_key == id("below"));  // out the bottom
  g.move(GraphDir::Up);
  CHECK(state.cur_key == id("raw2"));  // and back in
}

TEST_CASE("tree ops expand, collapse, descend, ascend") {
  GraphState state;
  KeyGraph g(
      [&state] {
        return GraphBuilder(&state.expanded)
            .begin_group(id("combat"), vt("Combat"))
            .add_item(id("pause"), vt("Auto pause"))
            .add_item(id("delay"), vt("Delay"))
            .end_group()
            .build();
      },
      &state);

  CHECK(g.rerender());  // focus lands on the collapsed header
  CHECK(state.cur_key == id("combat"));
  CHECK(KeyGraph::in_tree(g.current_node()));

  KeyGraph::TreeResult r = g.tree_right();  // collapsed -> expand
  CHECK(r.kind == KeyGraph::TreeMove::Expanded);
  CHECK(state.cur_key == id("combat"));  // focus stays on the header
  CHECK(g.current_node()->expanded);
  CHECK(g.current()->contains(id("pause")));

  r = g.tree_right();  // expanded -> descend to first child
  CHECK(r.kind == KeyGraph::TreeMove::Descended);
  CHECK(state.cur_key == id("pause"));

  r = g.tree_right();  // a leaf inside the tree -- consume
  CHECK(r.kind == KeyGraph::TreeMove::Leaf);

  r = g.tree_left();  // child -> ascend to the header
  CHECK(r.kind == KeyGraph::TreeMove::Ascended);
  CHECK(state.cur_key == id("combat"));

  r = g.tree_left();  // expanded header -> collapse
  CHECK(r.kind == KeyGraph::TreeMove::Collapsed);
  CHECK(state.cur_key == id("combat"));
  CHECK_FALSE(g.current()->contains(id("pause")));
}

TEST_CASE("an empty group re-collapses on expand") {
  GraphState state;
  KeyGraph g(
      [&state] {
        return GraphBuilder(&state.expanded)
            .begin_group(id("dud"), vt("Dud"))  // no children declared
            .end_group()
            .build();
      },
      &state);

  CHECK(g.rerender());
  const KeyGraph::TreeResult r = g.tree_right();
  CHECK(r.kind == KeyGraph::TreeMove::EmptyGroup);
  CHECK_FALSE(g.current_node()->expanded);  // auto-recollapsed
  CHECK(state.expanded.count(id("dud")) == 0);
}

TEST_CASE("collapsing while inside lands on the nearest survivor") {
  GraphState state;
  state.expanded.insert(id("combat"));
  KeyGraph g(
      [&state] {
        return GraphBuilder(&state.expanded)
            .begin_group(id("combat"), vt("Combat"))
            .add_item(id("pause"), vt("Auto pause"))
            .end_group()
            .build();
      },
      &state);

  g.rerender();
  g.focus(id("pause"));
  state.expanded.erase(id("combat"));  // collapsed externally while focus was inside
  CHECK(g.rerender());
  CHECK(state.cur_key == id("combat"));  // nearest survivor = the header
}

TEST_CASE("sibling edge jump stays at depth") {
  GraphState state;
  state.expanded.insert(id("g"));
  KeyGraph g(
      [&state] {
        return GraphBuilder(&state.expanded)
            .add_item(id("top"), vt("Top"))
            .begin_group(id("g"), vt("Group"))
            .add_item(id("c1"), vt("C1"))
            .add_item(id("c2"), vt("C2"))
            .add_item(id("c3"), vt("C3"))
            .end_group()
            .build();
      },
      &state);

  g.rerender();
  g.focus(id("c2"));
  MoveResult r = g.move_to_sibling_edge(false);
  CHECK(r.moved);
  CHECK(state.cur_key == id("c3"));  // last SIBLING, not the last visible row overall

  r = g.move_to_sibling_edge(true);
  CHECK(state.cur_key == id("c1"));
}

TEST_CASE("focus and focus-by-reference work") {
  GraphState state;
  int storage = 0;
  const void* backing = &storage;
  KeyGraph g(
      [backing] {
        return GraphBuilder()
            .add_item(id("a"), vt("A"))
            .add_item(ControlId::referenced(backing, Key("b")), vt("B"))
            .build();
      },
      &state);

  CHECK(g.rerender());
  CHECK(g.focus_by_reference(backing));
  CHECK(state.cur_key->structural_key().text() == "b");
  CHECK_FALSE(g.focus_by_reference(backing));  // already there -- not a change

  CHECK(g.focus(id("a")));
  CHECK(state.cur_key == id("a"));
  CHECK_FALSE(g.focus(id("nope")));
}

TEST_CASE("a vanished first row lands on the next row of its own stop, not the previous stop's last node") {
  GraphState state;
  std::vector<std::string> items{"a", "b", "c"};
  auto actionable = [](std::string label) { NodeVtablePtr v = vt(std::move(label)); v->on_activate = [] {}; return v; };
  KeyGraph g(
      [&] {
        GraphBuilder b;
        b.begin_stop("tabs");
        b.add_item(id("tab0"), actionable("stash"));
        b.begin_stop("mine");
        for (const std::string& i : items) b.add_item(id(i), actionable(i));
        return b.build();
      },
      &state);
  CHECK(g.rerender());
  CHECK(g.focus(id("a")));
  items.erase(items.begin());   // Enter moved "a" away
  CHECK(g.rerender());
  CHECK(state.cur_key == id("b"));   // the builder stamped the rows with their stop: the row-vanish rule applies
}
