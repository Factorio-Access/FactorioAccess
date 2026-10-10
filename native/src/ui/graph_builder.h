#pragma once
#include <memory>
#include <optional>
#include <string>
#include <string_view>
#include <unordered_map>
#include <unordered_set>
#include <vector>

#include "ui/graph_types.h"

namespace fa::ui {

/// Builds a GraphRender. Two construction styles, freely mixable in one build:
///
/// **Menu mode** -- rows of controls, wired automatically: left/right within a row, up/down between
/// consecutive rows (two rows sharing a non-empty row key get column navigation -- up/down preserves
/// the position instead of snapping to the first item; ported from Tanglebeep's MenuBuilder, itself
/// from Factorio Access's menu.lua). Items added outside an explicit row become single-item rows (a
/// plain vertical menu).
///
/// **Raw mode** -- add_node() + connect() for arbitrary topologies.
///
/// Orthogonal to both: begin_stop() groups nodes into Tab-stops (arrows never cross a stop; Tab cycles
/// them), set_region() tags nodes with a region for Ctrl+arrow jumps, and the PARENT STACK builds the
/// presentation hierarchy: push_context() pushes a non-focusable structural level ("Difficulty
/// settings, list" -- announced when focus enters from outside), while begin_group() pushes a
/// focusable, EXPANDABLE group header (a tree section) whose children only emit while it's expanded --
/// expansion state lives in the persistent set the builder is constructed with (GraphState::expanded),
/// so screens hold no tree state of their own. Nesting recurses; a collapsed ancestor suppresses
/// everything beneath it.
///
/// Ownership note (C++ addition): every node the builder makes -- including the non-focusable context
/// parents that are never published -- is owned by the builder until build() hands the whole arena to
/// the render, which then owns it. Parent pointers therefore stay valid exactly as long as the render.
///
/// Misuse throws, as in the C#: std::invalid_argument for the ArgumentNullException/ArgumentException
/// cases, std::logic_error for the InvalidOperationException cases.
class GraphBuilder {
 public:
  /// `expansion` is the persistent expanded-group set (GraphState::expanded); null = every group must
  /// pass its state explicitly. The builder does not own it and must not outlive it.
  explicit GraphBuilder(std::unordered_set<ControlId>* expansion = nullptr) : expansion_(expansion) {}

  GraphBuilder(const GraphBuilder&) = delete;
  GraphBuilder& operator=(const GraphBuilder&) = delete;

  // ---- stops / regions ----

  /// Start a new Tab-stop; nodes added from here belong to it. `key` must be stable across rebuilds
  /// (it keys the stop's remembered position); an empty key auto-assigns by index, which is stable when
  /// the screen builds its stops in a fixed order.
  GraphBuilder& begin_stop(Key key = {});

  /// Tag nodes added from here with a region (Ctrl+arrow jump target) within the current stop; an empty
  /// key clears. Region keys must be stable across rebuilds.
  GraphBuilder& set_region(Key key);

  // ---- the parent stack: contexts + groups ----

  /// Push one NON-FOCUSABLE level of presentation hierarchy ("Difficulty settings", "list") onto nodes
  /// added from here -- pure structure: never navigable, announced when focus enters from outside.
  /// Close with pop_context().
  GraphBuilder& push_context(std::string_view label, std::string_view role = {}, bool positions = true);

  GraphBuilder& pop_context();

  /// Push a FOCUSABLE, expandable group header (a tree section): the header emits as a navigable node
  /// here, and the children declared before end_group() emit only while the group is expanded (a
  /// collapsed ancestor suppresses the whole subtree -- recursion just works). Expansion state:
  /// `expanded` when given (the adapter passes the retained container's state), else the persistent
  /// expansion set the builder was constructed with, else `default_expanded`. The engine's tree
  /// operations (Right/Left) expand/collapse via the vtable's on_expand/on_collapse overrides when set,
  /// else by mutating the persistent set.
  GraphBuilder& begin_group(ControlId id, NodeVtablePtr vtable,
                            std::optional<bool> expanded = std::nullopt, bool default_expanded = false);

  GraphBuilder& end_group() { return pop_context(); }

  /// Whether a group id is expanded in the persistent set -- for screens that must avoid even BUILDING
  /// a collapsed group's children (a lazy hierarchy whose child VMs materialize on first access).
  /// Groups with an explicit `expanded` argument manage their own state instead.
  bool is_expanded(const ControlId& id) const;

  /// Focus starts here when the graph has no prior position (defaults to the first node).
  GraphBuilder& set_start(ControlId id);

  // ---- menu mode ----

  /// Open a horizontal row. Rows sharing a non-empty `row_key` with the row above/below get
  /// column-preserving vertical navigation.
  GraphBuilder& start_row(Key row_key = {});
  GraphBuilder& end_row();

  /// Add a control -- into the open row, or as its own single-item row. A no-op inside a collapsed
  /// group's subtree.
  GraphBuilder& add_item(ControlId id, NodeVtablePtr vtable);

  /// Add a read-only line (label only; no actions).
  GraphBuilder& add_label(ControlId id, std::function<std::string()> label);

  // ---- raw mode ----

  /// Add a node with no automatic wiring (raw mode; wire with connect()). A no-op inside a collapsed
  /// group's subtree.
  GraphBuilder& add_node(ControlId id, NodeVtablePtr vtable);

  /// Directed edge from -> to, with an optional spoken transition line ("lane change"). Edges to/from
  /// undeclared nodes are dropped at build.
  GraphBuilder& connect(ControlId from, GraphDir dir, ControlId to, std::string label = {});

  // ---- build ----

  /// Finalize into a render, or null when nothing was declared (treat as "closed"). Menu rows and raw
  /// nodes/edges may coexist in one build (a screen mixing lists with a grid whose topology is
  /// computed): rows wire themselves; raw edges may reference any node.
  GraphRenderPtr build();

 private:
  struct Row {
    std::vector<GraphNode*> items;
    Key key;
    Key stop_key;
  };

  struct RawEdge {
    ControlId from;
    GraphDir dir;
    ControlId to;
    std::string label;
  };

  // The parent stack: structural levels (push_context) and group headers (begin_group). A frame whose
  // group is collapsed suppresses every declaration beneath it (the stack stays balanced regardless).
  struct ParentFrame {
    GraphNode* node;   // the parent node (non-focusable context, or the group header)
    bool suppressed;   // this frame's subtree is swallowed (collapsed, or under a collapsed ancestor)
  };

  static Key auto_stop_key(int index);
  GraphNode* current_parent() const { return parents_.empty() ? nullptr : parents_.back().node; }
  bool suppressed() const { return !parents_.empty() && parents_.back().suppressed; }
  GraphNode* make_node(ControlId id, NodeVtablePtr vtable);
  GraphNode* own(std::unique_ptr<GraphNode> node);

  void wire_menu_edges();
  void stitch_mode_boundaries();
  void stamp_positions();
  static void stamp(const std::vector<GraphNode*>& siblings);
  static ControlId vertical_target(const Row& from, const Row& to, std::size_t pos);

  std::unordered_set<ControlId>* expansion_;  // persistent expanded-group set (null = all explicit)

  // Every node this builder made, in creation order; handed to the render at build().
  std::vector<std::unique_ptr<GraphNode>> owned_;
  std::vector<std::unique_ptr<Row>> owned_rows_;

  // Menu mode.
  std::vector<Row*> rows_;
  Row* current_row_ = nullptr;

  // Raw mode.
  std::vector<GraphNode*> raw_nodes_;
  std::vector<RawEdge> raw_edges_;

  // Every node in DECLARATION order regardless of mode -- the render's node order (and so the Tab-stop
  // cycle) must interleave menu rows and raw nodes as the screen declared them, not rows-then-raw
  // (which shoved sheet stops behind later buttons).
  std::vector<GraphNode*> declared_;

  // The menu row each menu-mode node belongs to (absent for raw nodes) -- for stitching the vertical
  // gap where a stop mixes menu rows with raw content (a sheet below filter controls).
  std::unordered_map<const GraphNode*, Row*> row_of_;

  // Shared.
  std::unordered_set<ControlId> ids_;
  std::optional<ControlId> start_;

  // Stop / region / parent state applied to nodes as they are added.
  Key stop_key_ = auto_stop_key(0);
  int stop_auto_ = 1;
  Key region_key_;
  std::vector<ParentFrame> parents_;
};

}  // namespace fa::ui
