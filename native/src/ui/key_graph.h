#pragma once
#include <functional>
#include <optional>
#include <string>
#include <vector>

#include "ui/graph_types.h"

namespace fa::ui {

/// The outcome of a navigation operation, for the caller (navigator) to announce. The core never
/// speaks -- it returns what happened.
///
/// `from`/`to` point into the render they were read from. KeyGraph keeps the previous render alive
/// across exactly one rebuild (see KeyGraph::rerender), so a result stays readable until the operation
/// after the one that produced it -- which is all the C#'s GC-backed usage ever needed.
struct MoveResult {
  bool moved = false;          // focus actually changed nodes
  GraphNode* from = nullptr;   // node before the operation (null on first landing)
  GraphNode* to = nullptr;     // node after (== from when at an edge; null when the graph is empty)
  std::string transition_label;  // the crossed edge's spoken line, when it had one (empty = none)
};

/// The navigation engine: a directed graph of controls rebuilt from a render callback on each
/// operation, with focus persisting in an external GraphState. Ported from Tanglebeep (with
/// permission), itself from Factorio Access's key-graph.lua. Two invariants carry over:
///
/// **Down-right total order** (compute_order): from the start node, go right until stuck, queueing each
/// down -- visits a planar UI in reading order. Nodes down-right can't reach (later Tab-stops) are
/// appended in declaration order, keeping the order total.
///
/// **Focus recovery on rebuild** (reconcile): if the focused control vanished, land on the nearest
/// survivor rather than jumping to the start -- following the backing object that moved (tier 1) or the
/// logical control whose backing object was rebuilt (tier 2) first.
///
/// Extensions over the original: Tab-stop cycling and region jumps as operations over node metadata
/// (with per-stop remembered positions), and per-node secondary/tooltip/adjust behaviors.
class KeyGraph {
 public:
  /// `state` is external and must outlive the graph (the screen owns it; it is the only thing that
  /// survives a rebuild).
  KeyGraph(std::function<GraphRenderPtr()> render_callback, GraphState* state)
      : render_callback_(std::move(render_callback)), state_(state) {}

  KeyGraph(const KeyGraph&) = delete;
  KeyGraph& operator=(const KeyGraph&) = delete;

  GraphState& state() { return *state_; }

  /// The most recently built render, or null if not yet rendered / empty.
  GraphRender* current() const { return current_.get(); }

  /// The focused node in the current render, or null.
  GraphNode* current_node() const { return current_ ? current_->node_at(state_->cur_key) : nullptr; }

  /// Rebuild the render and reconcile focus into it. False when the callback produced nothing (the
  /// caller should treat the graph as closed/empty).
  bool rerender();

  /// Move focus from the cached GraphState::cur_key to a valid control in `render`, then recompute the
  /// traversal order.
  static void reconcile(GraphRender& render, GraphState& state);

  /// From `start`, walk its row's Left/Right edges to the cell at `pref_col` -- or the nearest cell
  /// BELOW it in a sparse row. Returns `start` unchanged when either side isn't tabular (column < 0) or
  /// the column already matches. Horizontal edges never leave a row, so the walk can't escape it.
  static ControlId slide_to_column(const GraphRender& render, const ControlId& start, int pref_col);

  /// The down-right total order: go right until stuck (recording each node), queue every down for a
  /// later pass, repeat -- then append any node the walk never reached (e.g. later Tab-stops, which
  /// have no cross-stop edges) in declaration order, so the order is total.
  static std::vector<ControlId> compute_order(const GraphRender& render);

  /// Focus `id` slid to `pref_col` within its row (the type-ahead landing: match the row, land on the
  /// column you were working in).
  bool focus_at_column(const ControlId& id, int pref_col);

  // ---- navigation operations ----

  /// One step in `dir`. Not moved (at an edge / empty) -> to == from.
  MoveResult move(GraphDir dir);

  /// As far as possible in `dir` (Home/End within a row or column).
  MoveResult move_to_edge(GraphDir dir);

  /// Cycle to the next/previous Tab-stop (declaration order), landing on the stop's remembered position
  /// (else its first node). `wrap` continues past the ends; without it, at the last/first stop the
  /// result is not-moved (the caller may blur instead).
  MoveResult move_stop(int dir, bool wrap);

  /// Jump to the next/previous region within the current stop (declaration order), landing on the
  /// region's first node.
  MoveResult move_region(int dir);

  /// Move focus to a specific control (a node just revealed, a screen's chosen landing). False when it
  /// isn't in the render.
  bool focus(const ControlId& id);

  /// Tier-1 focus sync from the game: if a node's backing object is `reference`, move focus there.
  /// True if focus changed nodes.
  bool focus_by_reference(const void* reference);

  /// Where focus lands when entering a stop with no active cursor: the remembered position, else the
  /// SELECTED member (a radio/tab/list item currently checked -- the old RepresentativeChild behavior;
  /// a boon on long lists), else the stop's first node.
  GraphNode* stop_landing(const Key& stop_key) const;
  static GraphNode* stop_landing(const GraphRender& render, const GraphState& state, const Key& stop_key);

  /// The first node in a stop that reads as SELECTED -- carries a non-empty selected-kind announcement
  /// part (SelectionItem / ChoiceOption / Tab / radio all declare one), or null.
  // The node of the stop whose `selected` part is non-empty, among the siblings of `sibling_of` (a form's
  // checked radio must not steal the landing from the edit field above it).
  static GraphNode* selected_node_in_stop(const GraphRender& render, const Key& stop_key, const GraphNode* sibling_of);

  // ---- tree operations (Right/Left semantics for expandable groups) ----

  /// What a tree side-step did (the caller composes the speech).
  enum class TreeMove {
    None,        // not applicable here (not in a tree / nothing to do) -- caller decides consume/bubble
    Expanded,    // the focused group expanded (focus unchanged; speak its new state)
    Collapsed,   // the focused group collapsed (focus unchanged; speak its new state)
    EmptyGroup,  // expanding found no children -- auto-recollapsed (speak "no details")
    Descended,   // moved to the group's first child (announce as a move)
    Ascended,    // moved to the nearest focusable ancestor (announce as a move)
    Leaf,        // Right on a non-group inside a tree -- consumed, nothing to descend into
  };

  struct TreeResult {
    TreeMove kind = TreeMove::None;
    MoveResult move;  // valid for Descended/Ascended
  };

  /// Is this node part of an expandable structure (itself a group, or under one)? The navigator uses
  /// this to decide whether Left/Right get tree semantics.
  static bool in_tree(const GraphNode* node);

  /// Right on a group: expand (auto-recollapse when it turns out empty), or descend into an expanded
  /// one. Right elsewhere in a tree: Leaf (consume). Assumes a current render.
  TreeResult tree_right();

  /// Left on an expanded group: collapse. Left elsewhere in a tree: ascend to the nearest focusable
  /// ancestor. Assumes a current render.
  TreeResult tree_left();

  /// Home/End inside a tree: the first/last node sharing the focused node's parent (its siblings at the
  /// current depth). Assumes a current render.
  MoveResult move_to_sibling_edge(bool first);

  // ---- behavior invokers (the caller announces fallbacks / state) ----

  /// Run the focused control's primary activation. False = it has none.
  bool activate();
  /// Run the focused control's secondary activation. False = it has none.
  bool secondary();
  /// Run the focused control's tooltip behavior. False = it has none.
  bool tooltip();
  /// Run the focused control's drag behavior. False = it has none.
  bool compare();
  /// If the focused control adjusts horizontally (a slider), adjust and return true; false = the caller
  /// should navigate instead.
  bool try_adjust(int sign, bool large);

 private:
  void set_current(GraphNode* node);
  void set_expanded(GraphNode* group, bool expanded);
  GraphNode* first_child_of(const GraphNode* group) const;
  std::vector<Key> stop_order() const;

  std::function<GraphRenderPtr()> render_callback_;
  GraphState* state_;
  GraphRenderPtr current_;
  // The render before `current_`, kept alive for one more operation. The C# leaned on the GC here: an
  // operation reads a node, rebuilds, and then keeps using the node it read (tree_right does exactly
  // that, and every MoveResult hands the caller nodes that a later rebuild would otherwise free).
  GraphRenderPtr previous_;
};

}  // namespace fa::ui
