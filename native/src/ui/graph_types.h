#pragma once
#include <array>
#include <functional>
#include <memory>
#include <optional>
#include <string>
#include <string_view>
#include <unordered_map>
#include <unordered_set>
#include <vector>

#include "ui/control_id.h"

// The data model of the UI navigation graph, ported from wotr-access (C#) src/UI/Graph/GraphTypes.cs.
// Engine-free by construction: nothing here knows a game type. Where the C# used `object` for a
// backing widget we use `const void*` (identity only); where it used Func/Action we use std::function.
//
// Nullable-string convention across this port: a C# `string` that could be null is a std::string here,
// and EMPTY means null. Every consumer in the C# tested it with string.IsNullOrEmpty (or compared it
// to another possibly-null string), so the two states were never distinguished. Nullable RETURN values
// of the announcer (compose/leaf_text/first_part_text) keep the distinction as std::optional<std::string>,
// because there "nothing to say" is the documented result the caller branches on.
namespace fa::ui {

/// The four navigable directions between graph nodes (explicit edges). Tab-stop cycling and region
/// jumps are OPERATIONS over node metadata (GraphNode::stop_key / GraphNode::region_key), not edges --
/// they carry per-stop remembered positions, which a static edge can't express.
enum class GraphDir : int { Up = 0, Right = 1, Down = 2, Left = 3 };
inline constexpr int kGraphDirCount = 4;

/// The well-known announcement-part kinds. A part's kind is its identity for control-type ordering,
/// node-over-type overriding, and the user's per-kind announcement settings -- the same keys the legacy
/// per-announcement settings used, so the global toggles cover both systems.
namespace announcement_kinds {
inline constexpr std::string_view kLabel = "label";
inline constexpr std::string_view kRole = "role";
inline constexpr std::string_view kValue = "value";
inline constexpr std::string_view kSelected = "selected";
inline constexpr std::string_view kEnabled = "enabled";
inline constexpr std::string_view kTooltip = "tooltip";
inline constexpr std::string_view kPosition = "position";
}  // namespace announcement_kinds

/// One part of a control's spoken focus readout ("Hold position" / "toggle" / "on"), resolved live at
/// speak time. A LIVE part is additionally watched while its node is focused: when its resolved text
/// changes (an async toggle settling, a value the game flips), the navigator speaks just that part
/// immediately -- state feedback without re-reading the whole control, and without per-element watcher
/// machinery.
struct NodeAnnouncement {
  /// The part's text, resolved live. An empty result (or an empty std::function -- the C# null Text)
  /// at speak time = the part stays silent.
  std::function<std::string()> text;
  /// Watch this part while the node is focused and speak it when its value changes.
  bool live = false;
  /// The part's kind (announcement_kinds), or EMPTY for a custom one-off part. Kinds drive the control
  /// type's speak order, let a node's part override the type's common part of the same kind, and key
  /// the user's per-kind announcement settings.
  std::string kind;

  NodeAnnouncement() = default;
  explicit NodeAnnouncement(std::function<std::string()> text_fn, bool is_live = false,
                            std::string_view part_kind = {})
      : text(std::move(text_fn)), live(is_live), kind(part_kind) {}

  /// C#: NodeAnnouncement.Static -- a part whose text never changes.
  static NodeAnnouncement fixed(std::string text_value) {
    return NodeAnnouncement([t = std::move(text_value)] { return t; });
  }
};

/// A CONTROL TYPE -- "button", "toggle", "slider" -- as a registry value rather than a class (the
/// legacy system derived type identity from proxy classes via attributes, which forced attribute unions
/// and class collapsing to share settings). A type owns the speak ORDER of its announcement kinds and
/// the parts COMMON to every control of the type (the localized role word); nodes contribute their
/// specific parts, overriding a common part of the same kind. The user's per-type announcement settings
/// key off `key`. Types are registry values outliving any render -- nodes point at them.
struct ControlType {
  /// Stable settings/registry key ("button", "toggle", "slider").
  std::string key;
  /// The announcement kinds in speak order; parts with unknown/absent kinds append after, in
  /// declaration order.
  std::vector<std::string> order;
  /// The parts every control of this type shares (the role word), resolved per compose. Empty
  /// std::function = none.
  std::function<std::vector<NodeAnnouncement>()> common;
};

/// The behaviors of a control, as data. `announcements` is required (its parts compose the spoken focus
/// readout; the first part is the control's label for search/dedupe purposes); the rest are optional --
/// an empty slot means the control doesn't have that behavior and the navigator speaks its "nothing
/// there" feedback instead.
struct NodeVtable {
  /// Required, at least one part. The control's spoken focus readout. Parts marked `live` re-speak on
  /// change while focused. When `control_type` is set, the type's common parts merge in and the type's
  /// kind order applies; otherwise parts speak in declaration order.
  std::vector<NodeAnnouncement> announcements;

  /// The control's type (registry value) -- supplies the role word, the speak order, and the per-type
  /// announcement settings identity. Null = an untyped one-off.
  const ControlType* control_type = nullptr;

  /// Optional. The node's LANDING group -- the general row-vanish rule: when the focused node
  /// disappears on a rebuild, the reconcile fallback lands on the nearest surviving node of the SAME
  /// group (next first, then previous), never on a header, lead line or another panel. Sheets stamp
  /// their data rows with their key automatically; nodes without a group use the plain
  /// nearest-survivor walk.
  std::string land_group;

  /// Optional. Fires when the USER's movement lands on this node (arrows, Home/End, Tab into a stop, a type-ahead
  /// result) -- not on a rebaseline or a programmatic focus. A tab strip uses it to open the tab under the cursor.
  std::function<void()> on_focus;
  /// Optional. Primary activation -- the left-click equivalent (Enter).
  std::function<void()> on_activate;
  /// Optional. Secondary activation -- the right-click equivalent (Backspace).
  std::function<void()> on_secondary;
  /// Optional. Read / open the control's tooltip (Space, F1). The action owns the whole behavior
  /// (speak, or open the drill-in tooltip reader), so the core stays game-agnostic.
  std::function<void()> on_tooltip;
  /// Optional. The long form of the tooltip (Ctrl+Space) -- what the game shows with its modifier held.
  /// Falls back to on_tooltip when unset.
  std::function<void()> on_tooltip_detail;
  /// Optional. Compare (Backslash): speak the equipped counterpart of this item (the slot it would go to). The
  /// screen decides what "equipped counterpart" means; the core only dispatches.
  std::function<void()> on_compare;
  /// Optional. Horizontal value adjust (a slider): sign is -1 (decrease) / +1 (increase), large
  /// requests a coarse step. When set, left/right do NOT navigate.
  std::function<void(int sign, bool large)> on_adjust;

  /// Optional. The control's state line, spoken IMMEDIATELY (interrupting) after an activation/adjust
  /// that changes state -- the synchronous feedback path for rapid key repeats. Asynchronous /
  /// game-driven changes ride the Live announcement watch instead.
  std::function<std::string()> state_text;
  /// Optional. Plays this control's hover sound when focus lands on it, replacing the navigator's
  /// default. A plain action so the core stays game-agnostic (some game views assign non-default hover
  /// sounds in code, e.g. dialogue answers).
  std::function<void()> hover_sound;
  /// Optional. The text type-ahead matches against; empty = the first announcement part (the label).
  /// (A cell whose label is a bare number can search as its row's name, etc.)
  std::function<std::string()> search_text;
  /// If true, type-ahead never matches this control.
  bool exclude_from_search = false;

  /// Optional (expandable groups): override HOW expansion state changes. When empty the engine mutates
  /// the persistent expansion set (GraphState::expanded); the adapter wires these to the retained
  /// container's Expand/Collapse instead.
  std::function<void()> on_expand;
  std::function<void()> on_collapse;

  /// Set when this group's own announcements already include its expanded/collapsed state (the
  /// adapter's composed element messages do), so the announcer doesn't append it again.
  bool speaks_own_expansion = false;
  /// Set when this node's announcements already include its list position (the adapter's composed
  /// element messages do), so the announcer doesn't append the auto-stamped one.
  bool speaks_own_position = false;

  /// The node's LOGICAL COLUMN in a tabular row (0 = the row's primary), or -1 when not tabular.
  /// Stamped by the sheet builder; the engine uses it to PRESERVE the column when focus jumps
  /// non-directionally -- the reconcile fallback after a row vanishes, and type-ahead landings -- by
  /// sliding along the destination row's Left/Right edges to the same column.
  int column = -1;
};

using NodeVtablePtr = std::shared_ptr<NodeVtable>;

/// A directed edge to another node, with an optional spoken transition line (a "lane change" -- e.g.
/// crossing into a new column band). Kept as plain data; contextual announcements are composed from
/// node metadata by the announcer, not per-edge closures (GC discipline in the original; here it keeps
/// renders cheap to throw away).
struct Transition {
  ControlId destination;
  std::string label;  // spoken only while crossing this edge; empty = silent edge

  explicit Transition(ControlId dest, std::string edge_label = {})
      : destination(std::move(dest)), label(std::move(edge_label)) {}
};

/// A control: identity, behaviors, directional transitions, and structural metadata (its parent chain,
/// tab-stop and region membership, expandability).
///
/// Nodes are heap-allocated and owned by their GraphRender: several relations here are IDENTITY
/// relations in the C# (`ReferenceEquals(n.Parent, group)`, "the group is the from-node"), so the
/// addresses must be stable for the render's lifetime and comparable by pointer.
class GraphNode {
 public:
  GraphNode(ControlId node_id, NodeVtablePtr node_vtable)
      : id(std::move(node_id)), vtable(std::move(node_vtable)) {}

  ControlId id;
  NodeVtablePtr vtable;  // null is legal (the C# allowed a null Vtable on hand-built nodes)

  const Transition* transition(GraphDir dir) const {
    const auto& slot = transitions_[static_cast<std::size_t>(dir)];
    return slot ? &*slot : nullptr;
  }
  bool has_transition(GraphDir dir) const {
    return transitions_[static_cast<std::size_t>(dir)].has_value();
  }
  void set_transition(GraphDir dir, Transition t) {
    transitions_[static_cast<std::size_t>(dir)] = std::move(t);
  }

  /// The node's structural parent within THIS render, or null at screen level. The parent chain IS the
  /// presentation hierarchy: the announcer prefix-diffs old/new chains by identity, so entering a group
  /// reads its levels outermost-first and descending from a group onto its own child re-announces
  /// nothing (the group is on the chain and is the from-node). A parent may be non-focusable pure
  /// structure (a labeled panel -- `focusable` false, never in the render's nodes/order) or a real
  /// control (a tree group header).
  GraphNode* parent = nullptr;

  /// False for a pure-structure parent node (a labeled panel): it exists only on parent chains for
  /// announcements -- never navigable, never in the render's nodes/order.
  bool focusable = true;

  /// This node is a group that can expand/collapse (a tree section header). The engine's tree
  /// operations (expand/collapse/descend/ascend) key off this.
  bool expandable = false;
  /// An expandable group's state AT THIS RENDER (stamped by the builder from the persistent expansion
  /// set, or the explicit value the declarer passed).
  bool expanded = false;

  /// The Tab-stop this node belongs to. Nodes sharing a stop key form one stop; Tab cycles stops in
  /// first-appearance order, landing on the stop's remembered position.
  Key stop_key;
  /// The region (within a stop) this node belongs to, or empty. Ctrl+Up/Down jumps between regions in
  /// first-appearance order.
  Key region_key;

  /// Auto-stamped sibling position (1-based) and count, from the builder: menu-mode nodes grouped by
  /// (parent, stop) -- "3 of 10" among the siblings arrows actually reach. 0 = none (single sibling,
  /// raw/grid nodes, or a multi-item row member positioned within its row).
  int position_index = 0;
  int position_count = 0;
  /// A member of a multi-item row: the announcer says GraphAnnouncer::row_text instead of "n of m", which is
  /// kept for counts in a list.
  bool row_member = false;

  /// On a parent (context/group) node: its direct children get NO auto position -- for log-like streams
  /// where "37 of 200" is noise.
  bool suppress_child_positions = false;

 private:
  std::array<std::optional<Transition>, kGraphDirCount> transitions_;
};

/// One built snapshot of a graph: the nodes (keyed by structural identity), their order of declaration,
/// and where focus starts when there is no prior position. Rebuilt per operation and thrown away --
/// live state belongs in the node callbacks, not here. Owns every node it was built with, INCLUDING
/// the non-focusable context nodes that appear only on parent chains.
class GraphRender {
 public:
  /// Where focus starts with no prior position. Always set by GraphBuilder::build(); unset only on a
  /// hand-built render (where the C# would have thrown on the first dictionary lookup).
  std::optional<ControlId> start_key;

  /// Per stop, where focus lands entering it with nothing remembered or selected (GraphBuilder::set_stop_entry);
  /// a stop without one lands on its first node.
  std::unordered_map<Key, ControlId> stop_entries;

  /// Take ownership of a node without publishing it (the non-focusable context parents).
  GraphNode* adopt(std::unique_ptr<GraphNode> node) {
    arena_.push_back(std::move(node));
    return arena_.back().get();
  }
  /// Publish an already-adopted node: navigable, in declaration order.
  void publish(GraphNode* node) {
    nodes_.emplace(node->id, node);
    order_.push_back(node);
  }

  GraphNode* node_at(const ControlId& key) const {
    auto it = nodes_.find(key);
    return it == nodes_.end() ? nullptr : it->second;
  }
  GraphNode* node_at(const std::optional<ControlId>& key) const { return key ? node_at(*key) : nullptr; }
  bool contains(const ControlId& key) const { return nodes_.count(key) != 0; }
  bool contains(const std::optional<ControlId>& key) const { return key && contains(*key); }

  /// Declaration order -- drives stop/region cycling and type-ahead scan order.
  const std::vector<GraphNode*>& order() const { return order_; }
  std::size_t node_count() const { return nodes_.size(); }

 private:
  std::vector<std::unique_ptr<GraphNode>> arena_;
  std::unordered_map<ControlId, GraphNode*> nodes_;
  std::vector<GraphNode*> order_;
};

using GraphRenderPtr = std::unique_ptr<GraphRender>;

/// The persistent cursor for a graph -- the only thing that survives between renders. Holds where focus
/// is, the last computed traversal order (for closest-survivor recovery), per-stop remembered positions
/// (so Tab returns to where you were in a stop), and a one-shot move request.
struct GraphState {
  /// The focused control's id (carries its reference for tier-1 recovery). Unset until first render.
  std::optional<ControlId> cur_key;

  /// The down-right total order from the previous render. EMPTY on first render (the C# null: every use
  /// was a null test followed by an index-of that returns -1 on an empty list anyway).
  std::vector<ControlId> key_order;

  /// If set, focus jumps here on the next render when present (consumed either way).
  std::optional<ControlId> next_suggested_move;

  /// The logical column focus last sat on in a tabular row (see NodeVtable::column), or -1. The
  /// reconcile fallback slides to this column when the focused row vanished.
  int last_column = -1;

  /// The focused node's NodeVtable::land_group (empty when it had none) -- the row-vanish fallback
  /// prefers survivors of this group.
  std::string last_land_group;

  /// Remembered position per Tab-stop: where Tab lands when cycling back into a stop.
  std::unordered_map<Key, ControlId> stop_memory;

  /// The expanded groups (by id). The builder consults this for groups declared without an explicit
  /// state; the engine's expand/collapse operations mutate it. Screens hold NO expansion state.
  std::unordered_set<ControlId> expanded;
};

}  // namespace fa::ui
