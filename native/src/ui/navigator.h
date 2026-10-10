#pragma once
// The graph-based navigator, ported from wotr-access src/UI/GraphNavigator.cs (+ Navigator.cs, Navigation.cs).
//
// Runs every screen on the key-graph core: the graph is rebuilt per operation and per frame, focus is
// reconciled by identity, and a focus change is announced exactly once no matter what caused it (input,
// a screen moving focus, a content rebuild, the game yanking a widget). Announcements are PULL-based:
// screens never make per-callsite announce decisions. Engine-free: speech, hover sounds, the focus-mode
// flag and the per-frame typed characters come from the host through NavigatorHost.
#include <functional>
#include <optional>
#include <string>
#include <string_view>
#include <unordered_map>
#include <vector>
#include "ui/graph_types.h"
#include "ui/key_graph.h"
#include "ui/screen.h"
#include "ui/typeahead.h"

namespace fa::ui {

struct NavigatorHost {
  std::function<void(std::string_view text, bool interrupt)> speak;
  std::function<void()> hover_sound;        // the default landing sound (a node's own hover_sound overrides)
  std::function<bool()> focus_mode_active;  // false = the mod does not own the keyboard; stay silent
  std::function<int()> frame_count;         // for the idle-rebuild throttle
};

// What the typeahead needs from the keyboard this frame (the C# polled Unity directly).
struct TypeaheadInput {
  std::u16string_view typed;  // printable characters pressed this frame
  bool ctrl = false, alt = false, shift = false;
  bool escape_pressed = false;
  bool up_held = false, down_held = false;
  double dt = 0;              // unscaled seconds since last frame
  double repeat_initial_delay = 0.4, repeat_interval = 0.06;
};

// The UI action ids the navigator understands (InputManager actions in the UI category use these keys).
namespace ui_actions {
inline constexpr std::string_view Up = "ui.up", Down = "ui.down", Left = "ui.left", Right = "ui.right";
inline constexpr std::string_view Next = "ui.next", Prev = "ui.prev", Home = "ui.home", End = "ui.end";
inline constexpr std::string_view RegionPrev = "ui.regionPrev", RegionNext = "ui.regionNext";
inline constexpr std::string_view Activate = "ui.activate", Secondary = "ui.secondary", Back = "ui.back";
inline constexpr std::string_view Tooltip = "ui.tooltip", TooltipDetail = "ui.tooltipDetail", Compare = "ui.compare";
}  // namespace ui_actions

class GraphNavigator {
 public:
  explicit GraphNavigator(NavigatorHost host);

  // Focus = a focused NODE.
  bool has_focus() const { return graph_ && graph_->current_node() != nullptr; }
  Screen* screen() const { return screen_; }

  // Bind to a screen. Re-attaching the SAME screen means "content changed" (focus and announce memory
  // survive); a new screen swaps to its own persistent state (created on first attach).
  void attach(Screen* screen);
  // A screen closed (popped without keep_state_on_pop, or a child removed): drop its state.
  void screen_closed(Screen* screen);
  // Drop focus back to the screen's unfocused state (exploration).
  void blur();
  // The per-frame pull: rebuild + reconcile, establish initial focus when content appears, apply pending
  // focus requests, announce any focus-identity change exactly once, watch live parts.
  void ensure_focus();
  // Announce the current focus in full (e.g. when focus mode engages).
  void announce_current();
  // Move focus to a node by id when it exists in a render (one retry frame for content appearing).
  void focus_node(const ControlId& id, bool announce = true);
  // Land on the first/remembered/selected node of a Tab-stop once it has nodes.
  void focus_stop(Key stop_key);
  std::optional<Key> focused_stop_key() const;
  std::optional<ControlId> focused_id() const;  // identity of the focused node, if any

  // Input: returns true when consumed. Called by InputManager's UI dispatch with the action key.
  bool on_action(std::string_view action_key);
  // Per-frame type-ahead feed (after on_action dispatch).
  void tick_typeahead(const TypeaheadInput& in);

  // Debug inspection (the /gui dump): one line per node as the announcer reads it, focused one prefixed '>'.
  std::string dump();

 private:
  GraphRenderPtr build_render(Screen* screen);
  bool arrow(GraphDir dir);
  bool tab(int step);
  bool land_on_stop(const Key& stop_key);
  bool jump_edge(bool first);
  static bool on_list_axis(const GraphNode* node, GraphDir dir);  // is `dir` along the list the node sits in
  void repeat_focused();                                           // the edge case: say the focused item again
  bool region_jump(int dir);
  void announce_move(const MoveResult& r);
  bool vtable_activate();
  bool vtable_adjust(int sign);
  void feedback_after_change();  // speak state_text, rerender, rebaseline the live watch
  void speak_focused_state();
  void play_hover(const GraphNode* node);
  void fire_focus(const GraphNode* node);                          // the node's on_focus on a user landing (a change of node)
  void speak(std::string_view text, bool interrupt);
  std::optional<std::string> compose_move(const GraphNode* from, const GraphNode* to, bool entry, std::string_view transition = {});
  void watch_live(const GraphNode* node);
  void mark_spoken(const GraphNode* node);

  // typeahead glue
  void type_char(std::uint32_t cp);   // one Unicode code point
  void rebuild_search_scope();
  static std::string search_text_of(const GraphNode* n);
  void search_focus_result(int index);
  void clear_search(bool announce);
  bool tick_result_arrows(const TypeaheadInput& in);
  bool fired_from_search_key(std::string_view action_key) const;

  NavigatorHost host_;
  Screen* screen_ = nullptr;
  std::unordered_map<Screen*, GraphState> states_;
  GraphState* state_ = nullptr;
  GraphState scratch_state_;
  std::unique_ptr<KeyGraph> graph_;
  std::optional<ControlId> last_spoken_key_;
  std::vector<ControlId> last_spoken_path_;   // its context path, for when the node itself has vanished
  // The last spoken node, resolved by id in the CURRENT render. Never keep a GraphNode* across frames: the
  // graph is rebuilt immediate-mode and a stored pointer dangles (crashed the game in the announcer's path
  // walk, 2026-08-21). Null when that node is not in this render.
  const GraphNode* last_spoken_node() const { return graph_ && graph_->current() ? graph_->current()->node_at(last_spoken_key_) : nullptr; }
  std::optional<ControlId> pending_focus_;
  bool pending_announce_ = true;
  std::optional<Key> pending_stop_;
  int last_idle_render_ = -1000000;
  static constexpr int kIdleRenderEvery = 6;  // ~100 ms at 60 fps
  // live watch
  std::optional<ControlId> live_key_;
  std::vector<std::optional<std::string>> live_values_;
  // typeahead
  TypeAheadSearch search_;
  // The search scope is captured by IDENTITY + text, never by node pointer: the graph is immediate-mode and a
  // GraphNode* from the render you typed in is freed two rerenders later (arrowing through the results used to
  // read freed memory and focus whatever the stale id resolved to -- the tab row included; fixed 2026-08-26).
  struct SearchEntry { ControlId id; std::string text; };
  std::vector<SearchEntry> search_nodes_;
  std::optional<ControlId> search_focus_id_;
  Screen* last_typeahead_screen_ = nullptr;
  int search_held_dir_ = 0;
  double search_repeat_in_ = 0;
  int search_column_ = -1;
  bool last_shift_ = false;
};

}  // namespace fa::ui
