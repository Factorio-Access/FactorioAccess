#include "ui/navigator.h"
#include <algorithm>
#include "ui/graph_announcer.h"
#include "ui/graph_builder.h"
#include "ui/strings.h"

namespace fa::ui {

GraphNavigator::GraphNavigator(NavigatorHost host) : host_(std::move(host)) {
  search_.on_no_match = [this](const std::string& text) {
    MessageBuilder m;
    m.fragment(strings::kNoMatch).fragment(text);
    speak(m.build(), true);
  };
}

void GraphNavigator::speak(std::string_view text, bool interrupt) {
  if (!text.empty() && host_.speak) host_.speak(text, interrupt);
}

// Screens declare fresh from live state on every render (immediate mode).
GraphRenderPtr GraphNavigator::build_render(Screen* screen) {
  GraphBuilder b(&state_->expanded);  // groups consult the persistent expansion set
  screen->build(b);
  return b.build();
}

void GraphNavigator::attach(Screen* screen) {
  bool same = screen == screen_;
  screen_ = screen;
  clear_search(false);
  if (!same) {
    // Swap to this screen's own state (creating it on first attach). The differ memory resets so the
    // (possibly restored) landing announces itself on return.
    if (screen) state_ = &states_[screen];
    else { scratch_state_ = GraphState{}; state_ = &scratch_state_; }
    last_spoken_key_.reset();
    pending_focus_.reset();
    pending_stop_.reset();
    live_key_.reset();
  }
  if (!state_) { scratch_state_ = GraphState{}; state_ = &scratch_state_; }
  graph_ = screen ? std::make_unique<KeyGraph>([this, screen] { return build_render(screen); }, state_) : nullptr;
}

void GraphNavigator::screen_closed(Screen* screen) {
  if (!screen) return;
  if (state_ == &states_[screen]) { scratch_state_ = GraphState{}; state_ = &scratch_state_; graph_.reset(); if (screen_ == screen) screen_ = nullptr; }
  states_.erase(screen);
}

void GraphNavigator::focus_node(const ControlId& id, bool announce) {
  pending_focus_ = id;
  pending_announce_ = announce;
}

void GraphNavigator::focus_stop(Key stop_key) { pending_stop_ = std::move(stop_key); }

std::optional<Key> GraphNavigator::focused_stop_key() const {
  const GraphNode* n = graph_ ? graph_->current_node() : nullptr;
  if (!n) return std::nullopt;
  return n->stop_key;
}

void GraphNavigator::blur() {
  if (state_) state_->cur_key.reset();
  last_spoken_key_.reset();
  pending_focus_.reset();
  live_key_.reset();
}

void GraphNavigator::mark_spoken(const GraphNode* node) {
  last_spoken_key_ = node ? std::optional<ControlId>(node->id) : std::nullopt;
  last_spoken_path_ = GraphAnnouncer::path_ids(node);
}

// The per-frame pull. This single path replaces the initial-focus debt, the per-callsite announce
// decisions, and the stranded-panel special case of the old navigator.
void GraphNavigator::ensure_focus() {
  if (!screen_ || !graph_) return;
  // Throttle the IDLE rebuild: every input path rerenders on its own before acting, so this per-frame
  // pull only needs to catch content appearing, external focus drift, and live-state flips -- none of
  // which need 60 Hz. (A full build each frame burned ~6 ms on big item tables in wotr-access.) On
  // throttled frames still watch the focused node's live parts against the cached render.
  int frame = host_.frame_count ? host_.frame_count() : 0;
  bool must_render = !state_->cur_key || pending_focus_ || pending_stop_;
  if (!must_render && frame - last_idle_render_ < kIdleRenderEvery) {
    if (const GraphNode* cached = graph_->current_node()) watch_live(cached);
    return;
  }
  last_idle_render_ = frame;

  if (!state_->cur_key && !pending_focus_) {
    // Unfocused screens (exploration) stay unfocused until Tab seats a cursor.
    if (screen_->start_unfocused()) return;
    if (!graph_->rerender()) return;  // no content yet; reconcile seats the start node once there is
  } else {
    if (!graph_->rerender()) return;  // nothing focusable this frame; retry
    if (pending_focus_) {
      // One retry frame for a target focused mid-build; a target still not in the render was removed --
      // drop the request rather than re-seating every frame.
      if (graph_->current()->contains(*pending_focus_)) {
        graph_->focus(*pending_focus_);
        if (!pending_announce_) mark_spoken(graph_->current_node());
      }
      pending_focus_.reset();
    }
    if (pending_stop_) {
      if (GraphNode* land = graph_->stop_landing(*pending_stop_)) graph_->focus(land->id);
      pending_stop_.reset();  // the announce rides the normal differ below
    }
  }

  const GraphNode* node = graph_->current_node();
  if (!node) return;
  if (!last_spoken_key_ || *last_spoken_key_ != node->id) {
    // Queued (not interrupting): landings follow the screen name / preceding feedback.
    if (!host_.focus_mode_active || host_.focus_mode_active()) {
      if (auto t = compose_move(last_spoken_node(), node, !last_spoken_key_)) speak(*t, false);
    }
    mark_spoken(node);
  }
  watch_live(node);
}

// Watch the FOCUSED node's Live parts and speak a part when its value changes (an async toggle settling,
// the game flipping a state). Baselines silently whenever focus lands on a new identity.
void GraphNavigator::watch_live(const GraphNode* node) {
  auto anns = GraphAnnouncer::effective_announcements(node);
  if (anns.empty()) return;
  bool baseline = !live_key_ || *live_key_ != node->id || live_values_.size() != anns.size();
  if (baseline) { live_key_ = node->id; live_values_.clear(); }
  for (size_t i = 0; i < anns.size(); ++i) {
    if (!anns[i].live) { if (baseline) live_values_.push_back(std::nullopt); continue; }
    std::optional<std::string> v;
    if (anns[i].text) { try { v = anns[i].text(); } catch (...) {} }
    if (baseline) { live_values_.push_back(v); continue; }
    if (live_values_[i] != v) {
      live_values_[i] = v;
      if (v && !v->empty() && (!host_.focus_mode_active || host_.focus_mode_active())) speak(*v, false);
    }
  }
}

void GraphNavigator::announce_current() {
  if (!graph_) return;
  // An unfocused screen with nothing focused has nothing to announce, and rerender would auto-seat a
  // phantom focus at the start node.
  if (!state_->cur_key && screen_ && screen_->start_unfocused()) return;
  if (!graph_->rerender()) return;
  const GraphNode* node = graph_->current_node();
  if (!node) return;
  if (auto t = compose_move(nullptr, node, true)) speak(*t, false);
  mark_spoken(node);
}

// ---- input ----

std::optional<ControlId> GraphNavigator::focused_id() const {
  const GraphNode* n = graph_ ? graph_->current_node() : nullptr;
  if (!n) return std::nullopt;
  return n->id;
}

bool GraphNavigator::on_action(std::string_view key) {
  using namespace ui_actions;
  if (search_.is_search_active()) {
    const GraphNode* cur = graph_ ? graph_->current_node() : nullptr;
    if (search_focus_id_ && (!cur || *search_focus_id_ != cur->id)) clear_search(false);  // focus moved under us
    else if (key == Home && search_.result_count() > 0) { search_.jump_to_first_result(); return true; }
    else if (key == End && search_.result_count() > 0) { search_.jump_to_last_result(); return true; }
    else if (fired_from_search_key(key)) return true;  // reserved key: tick_typeahead owns it
    else clear_search(false);
  }
  if (key == Up) return arrow(GraphDir::Up);
  if (key == Down) return arrow(GraphDir::Down);
  if (key == Left) return arrow(GraphDir::Left);
  if (key == Right) return arrow(GraphDir::Right);
  if (key == Increase || key == Decrease || key == IncreaseLarge || key == DecreaseLarge)
    return vtable_adjust(key == Increase || key == IncreaseLarge ? 1 : -1, key == IncreaseLarge || key == DecreaseLarge);
  if (key == Next) return tab(1);
  if (key == Prev) return tab(-1);
  if (key == Home) return jump_edge(true);
  if (key == End) return jump_edge(false);
  const GraphNode* node = graph_ ? graph_->current_node() : nullptr;
  // Region jumps consume only when the focused node is IN a region; elsewhere Ctrl+arrows bubble.
  if (key == RegionPrev) return node && !node->region_key.empty() && region_jump(-1);
  if (key == RegionNext) return node && !node->region_key.empty() && region_jump(1);
  if (key == Activate) { if (!node) return false; vtable_activate(); return true; }
  if (key == Secondary) { if (!node) return false; if (node->vtable && node->vtable->on_secondary) graph_->secondary(); return true; }
  if (key == Back) return screen_ && screen_->invoke_action(action_ids::Back);
  if (key == Tooltip) {
    if (!node) return false;
    if (node->vtable && node->vtable->on_tooltip) { graph_->tooltip(); return true; }
    speak(strings::kNoTooltip, false);
    return true;
  }
  if (key == TooltipDetail) {   // the long form; the short one when the control has no long form
    if (!node) return false;
    if (node->vtable && node->vtable->on_tooltip_detail) { node->vtable->on_tooltip_detail(); return true; }
    if (node->vtable && node->vtable->on_tooltip) { graph_->tooltip(); return true; }
    speak(strings::kNoTooltip, false);
    return true;
  }
  if (key == Compare) {
    if (!node) return false;
    if (node->vtable && node->vtable->on_compare) { graph_->compare(); return true; }
    speak(strings::kNothingToCompare, false);
    return true;
  }
  return false;
}

bool GraphNavigator::arrow(GraphDir dir) {
  const GraphNode* focus_node = graph_ ? graph_->current_node() : nullptr;
  if (!focus_node) return false;
  // A focused slider/dropdown alone in its row adjusts on Left/Right. In a row with neighbours (a table of sliders)
  // Left/Right move between them, and Page Up/Down adjust (ui.increase / ui.decrease).
  if ((dir == GraphDir::Left || dir == GraphDir::Right) && !focus_node->transition(GraphDir::Left) && !focus_node->transition(GraphDir::Right))
    if (vtable_adjust(dir == GraphDir::Right ? 1 : -1)) return true;
  // Edge-wired movement first (rows/grids/flattened tree rows all ride edges).
  MoveResult move = graph_->move(dir);
  if (move.moved) { announce_move(move); return true; }
  focus_node = graph_->current_node();  // move() rerendered: the node captured above may be a stale render's
  if (!focus_node) return false;
  // At an edge. Left/Right get tree semantics: expand/collapse a group, descend into an expanded one,
  // ascend from a child -- generic engine operations over parent/expandable.
  if (dir == GraphDir::Left || dir == GraphDir::Right) {
    KeyGraph::TreeResult tr = dir == GraphDir::Right ? graph_->tree_right() : graph_->tree_left();
    switch (tr.kind) {
      case KeyGraph::TreeMove::Expanded:
      case KeyGraph::TreeMove::Collapsed: speak_focused_state(); return true;
      case KeyGraph::TreeMove::EmptyGroup: speak(strings::kNoDetails, true); return true;
      case KeyGraph::TreeMove::Descended:
      case KeyGraph::TreeMove::Ascended: announce_move(tr.move); return true;
      case KeyGraph::TreeMove::Leaf: return true;
      case KeyGraph::TreeMove::None: break;
    }
  }
  // Nothing moved: at the edge of the list, repeat the focused item rather than go silent (the user,
  // 2026-08-22; wotr's sibling games do this). Only along the list's own axis: Left/Right in a vertical
  // list are not an edge, they are nothing -- and Up/Down in a pure row likewise.
  if (on_list_axis(focus_node, dir)) repeat_focused();
  // Consume edges inside trees; bubble from plain lists so an unfocused screen's arrows fall through to
  // the overlay.
  return KeyGraph::in_tree(graph_->current_node());
}

bool GraphNavigator::on_list_axis(const GraphNode* node, GraphDir dir) {
  bool vertical = node->has_transition(GraphDir::Up) || node->has_transition(GraphDir::Down);
  bool horizontal = node->has_transition(GraphDir::Left) || node->has_transition(GraphDir::Right);
  if (dir == GraphDir::Up || dir == GraphDir::Down) return vertical || !horizontal;  // a lone item counts as vertical
  return horizontal;
}

// The focused item's own readout again, as a fresh landing (hover sound, interrupting).
void GraphNavigator::repeat_focused() {
  const GraphNode* node = graph_ ? graph_->current_node() : nullptr;
  if (!node) return;
  play_hover(node);
  if (auto t = GraphAnnouncer::leaf_text(node)) speak(*t, true);
  mark_spoken(node);
}

// Speak the focused group's post-toggle state and rebaseline the differ + live watch.
void GraphNavigator::speak_focused_state() {
  const GraphNode* node = graph_->current_node();
  if (!node) return;
  if (auto t = GraphAnnouncer::leaf_text(node)) speak(*t, true);
  mark_spoken(node);
  live_key_.reset();
}

bool GraphNavigator::tab(int step) {
  // Snapshot BEFORE rerendering: reconcile auto-seats a null cursor at the start node, and an unfocused
  // screen's Tab must enter at the first stop, not step from that phantom seat.
  bool was_unfocused = !state_->cur_key;
  if (!graph_ || !graph_->rerender()) return false;
  std::vector<Key> stops;
  for (GraphNode* n : graph_->current()->order())
    if (!n->stop_key.empty() && std::find(stops.begin(), stops.end(), n->stop_key) == stops.end()) stops.push_back(n->stop_key);
  if (stops.empty()) return false;
  const GraphNode* cur = was_unfocused ? nullptr : graph_->current_node();
  int idx = -1;
  if (cur) { auto it = std::find(stops.begin(), stops.end(), cur->stop_key); if (it != stops.end()) idx = (int)(it - stops.begin()); }
  if (idx < 0) return land_on_stop(stops[step >= 0 ? 0 : stops.size() - 1]);  // unfocused: enter at first/last
  int ni = idx + step;
  int n = (int)stops.size();
  if (ni < 0 || ni >= n) {
    if (screen_ && screen_->start_unfocused()) {
      blur();  // truly unfocused: a later re-entry stays in exploration
      std::string name = screen_->screen_name();
      if (!name.empty()) speak(name, true);
      return true;
    }
    if (screen_ && screen_->wrap()) ni = ((ni % n) + n) % n;
    else return true;  // at the end; consume, no wrap
  }
  return land_on_stop(stops[(size_t)ni]);
}

// Remembered position -> SELECTED member -> first node (so Tab into a radio/tab group lands on the current pick).
bool GraphNavigator::land_on_stop(const Key& stop_key) {
  GraphNode* land = graph_->stop_landing(stop_key);
  if (!land || !graph_->focus(land->id)) return true;
  const GraphNode* node = graph_->current_node();
  play_hover(node);
  fire_focus(node);
  if (auto t = compose_move(last_spoken_node(), node, false)) speak(*t, true);
  mark_spoken(node);
  return true;
}

void GraphNavigator::play_hover(const GraphNode* node) {
  if (node && node->vtable && node->vtable->hover_sound) { try { node->vtable->hover_sound(); } catch (...) {} }
  else if (host_.hover_sound) host_.hover_sound();
}
// A user landing on a node: the node's on_focus (a tab strip opens the tab under the cursor). Only on a CHANGE of
// node -- repeating the focused item at a list edge is not a landing.
void GraphNavigator::fire_focus(const GraphNode* node) {
  if (!node || !node->vtable || !node->vtable->on_focus) return;
  if (last_spoken_key_ && *last_spoken_key_ == node->id) return;
  try { node->vtable->on_focus(); } catch (...) {}
}

bool GraphNavigator::jump_edge(bool first) {
  const GraphNode* focus_node = graph_ ? graph_->current_node() : nullptr;
  if (!focus_node) return false;
  if (KeyGraph::in_tree(focus_node)) {  // first/last sibling at the current depth
    MoveResult sib = graph_->move_to_sibling_edge(first);
    if (sib.moved) announce_move(sib); else repeat_focused();  // already there: say so by repeating it
    return true;
  }
  // Home/End run along the list; in a row (no vertical edges) that is left/right.
  bool vertical = focus_node->has_transition(GraphDir::Up) || focus_node->has_transition(GraphDir::Down);
  MoveResult move = graph_->move_to_edge(vertical ? (first ? GraphDir::Up : GraphDir::Down) : (first ? GraphDir::Left : GraphDir::Right));
  if (move.moved) announce_move(move); else repeat_focused();
  return true;
}

bool GraphNavigator::region_jump(int dir) {
  MoveResult r = graph_->move_region(dir);
  if (!r.moved) return true;  // no region that way: consume
  announce_move(r);
  return true;
}

void GraphNavigator::announce_move(const MoveResult& r) {
  if (!r.to) return;
  play_hover(r.to);
  fire_focus(r.to);
  if (auto t = compose_move(r.from, r.to, false, r.transition_label)) speak(*t, true);
  mark_spoken(r.to);
}

// Run the focused node's activation; speak its state_text as immediate feedback when it declares one,
// and rebaseline the live watch so the same change is not spoken twice. The rebaseline must see the
// post-activation values: the current render still carries the old ones (its announcements captured them
// at build time), so rerender first -- otherwise the next tick baselines on the stale render and then
// announces the change a second time.
void GraphNavigator::announce_change(std::string_view text) {
  speak(text, true);
  if (graph_) graph_->rerender();
  live_key_.reset();  // the next watch re-baselines silently
}

void GraphNavigator::feedback_after_change() {
  const GraphNode* node = graph_->current_node();
  if (!node || !node->vtable || !node->vtable->state_text) return;
  speak(node->vtable->state_text(), true);
  graph_->rerender();
  live_key_.reset();
}
bool GraphNavigator::vtable_activate() {
  const GraphNode* node = graph_->current_node();
  if (!node || !node->vtable || !node->vtable->on_activate) return false;
  graph_->activate();
  // An activation that opened a typed entry (the screen now reads raw keys, or lent the keyboard to a game text
  // field) has spoken its own prompt.
  if (!(screen_ && (screen_->captures_raw_input() || !screen_->owns_keyboard()))) feedback_after_change();
  return true;
}

bool GraphNavigator::vtable_adjust(int sign, bool large) {
  const GraphNode* node = graph_->current_node();
  if (!node || !node->vtable || !node->vtable->on_adjust) return false;
  graph_->try_adjust(sign, large);
  feedback_after_change();
  return true;
}

std::optional<std::string> GraphNavigator::compose_move(const GraphNode* from, const GraphNode* to, bool entry, std::string_view transition) {
  if (entry) return GraphAnnouncer::compose(nullptr, to, transition);
  // The node last spoken may have vanished (its row was removed by the action it just ran): its remembered path
  // still says which levels we were inside, so the landing reads as a sibling move (2026-09-04: every Enter in a
  // list repeated the list's title).
  if (from == nullptr && last_spoken_key_ && !last_spoken_path_.empty()) return GraphAnnouncer::compose_from_path(last_spoken_path_, to, transition);
  return GraphAnnouncer::compose(from, to, transition);
}

// ---- type-ahead search ----

void GraphNavigator::tick_typeahead(const TypeaheadInput& in) {
  bool focus_mode = !host_.focus_mode_active || host_.focus_mode_active();
  if (!screen_ || screen_->captures_raw_input() || !screen_->allows_typeahead() || !focus_mode || !graph_ || !graph_->current_node()) {
    if (search_.is_search_active() || search_.has_buffer()) clear_search(false);
    last_typeahead_screen_ = screen_;
    return;
  }
  if (screen_ != last_typeahead_screen_) {
    last_typeahead_screen_ = screen_;
    if (search_.is_search_active() || search_.has_buffer()) clear_search(false);
    return;
  }
  if (in.ctrl || in.alt) return;
  if (search_.is_search_active() && !in.shift) {
    if (in.escape_pressed) { clear_search(true); return; }
    if (search_.result_count() > 0 && tick_result_arrows(in)) return;
  } else {
    search_held_dir_ = 0;
  }
  // Typed text is UTF-16: a non-ASCII letter ("é", "ü", Cyrillic) is searched as itself -- it used to become '?'
  // and match nothing (a non-English player's report, 2026-09-22). A surrogate pair is combined into one code point.
  for (size_t k = 0; k < in.typed.size(); ++k) {
    std::uint32_t cp = in.typed[k];
    if (cp >= 0xD800 && cp <= 0xDBFF && k + 1 < in.typed.size() && in.typed[k + 1] >= 0xDC00 && in.typed[k + 1] <= 0xDFFF)
      cp = 0x10000 + ((cp - 0xD800) << 10) + (std::uint32_t)(in.typed[++k] - 0xDC00);
    else if (cp >= 0xD800 && cp <= 0xDFFF) continue;   // a lone surrogate: nothing to type
    if ((cp >= u'a' && cp <= u'z') || (cp >= u'A' && cp <= u'Z') || (cp >= u'0' && cp <= u'9') || cp > 0x7f) type_char(cp);
    else if (cp == u' ' && search_.has_buffer()) type_char(' ');  // space only with an existing buffer: alone it stays the tooltip key
  }
}

bool GraphNavigator::tick_result_arrows(const TypeaheadInput& in) {
  int dir = in.up_held ? -1 : in.down_held ? 1 : 0;
  if (dir == 0) { search_held_dir_ = 0; return false; }
  if (dir != search_held_dir_) {
    search_held_dir_ = dir;
    search_repeat_in_ = in.repeat_initial_delay;
    search_.navigate_results(dir);
    return true;
  }
  search_repeat_in_ -= in.dt;
  if (search_repeat_in_ <= 0) { search_repeat_in_ = in.repeat_interval; search_.navigate_results(dir); }
  return true;
}

// Keys the live search owns (letters, space, up/down, escape): an action bound to one of them must not
// fire its nav meaning while a search is active. Decided by action id here (the host binds ids to keys).
bool GraphNavigator::fired_from_search_key(std::string_view key) const {
  using namespace ui_actions;
  return key == Up || key == Down || key == Tooltip;
}

void GraphNavigator::type_char(std::uint32_t cp) {
  // A fresh search remembers the column you are on: every result lands there.
  if (!search_.has_buffer()) { const GraphNode* n = graph_->current_node(); search_column_ = n && n->vtable ? n->vtable->column : -1; }
  rebuild_search_scope();
  if (search_nodes_.empty()) return;
  search_.add_codepoint(cp);
  search_.search((int)search_nodes_.size(), [this](int i) { return search_nodes_[(size_t)i].text; }, [this](int i) { search_focus_result(i); });
}

std::string GraphNavigator::search_text_of(const GraphNode* n) {
  if (!n || !n->vtable) return {};
  if (n->vtable->search_text) return n->vtable->search_text();
  if (!n->vtable->announcements.empty() && n->vtable->announcements[0].text) return n->vtable->announcements[0].text();
  return {};
}

// The searchable scope is the focused node's Tab-stop. Tabular rows contribute ONE result (the primary).
void GraphNavigator::rebuild_search_scope() {
  search_nodes_.clear();
  const GraphNode* node = graph_ ? graph_->current_node() : nullptr;
  if (!node || !graph_->current()) return;
  for (GraphNode* n : graph_->current()->order())
    if (n->stop_key == node->stop_key && n->vtable && !n->vtable->exclude_from_search && n->vtable->column <= 0) search_nodes_.push_back({n->id, search_text_of(n)});
}

void GraphNavigator::search_focus_result(int index) {
  if (index < 0 || (size_t)index >= search_nodes_.size()) return;
  if (!graph_->focus_at_column(search_nodes_[(size_t)index].id, search_column_)) return;   // resolves in the CURRENT render
  const GraphNode* node = graph_->current_node();
  play_hover(node);
  fire_focus(node);
  if (auto t = compose_move(last_spoken_node(), node, false)) speak(*t, true);
  mark_spoken(node);
  search_focus_id_ = node->id;
}

void GraphNavigator::clear_search(bool announce) {
  bool had = search_.is_search_active() || search_.has_buffer();
  search_.clear();
  search_nodes_.clear();
  search_focus_id_.reset();
  search_held_dir_ = 0;
  search_column_ = -1;
  if (announce && had) speak(strings::kSearchCleared, true);
}

std::string GraphNavigator::dump() {
  if (!graph_ || !screen_) return "(no screen)\n";
  if (!graph_->rerender()) return "(no content)\n";
  std::string out;
  const GraphNode* cur = graph_->current_node();
  Key last_stop;
  for (const GraphNode* n : graph_->current()->order()) {
    if (n->stop_key != last_stop) { out += "-- stop " + n->stop_key.to_string() + "\n"; last_stop = n->stop_key; }
    auto t = GraphAnnouncer::leaf_text(n);
    out += std::string(n == cur ? "> " : "  ") + (t ? *t : std::string("(silent)")) + "\n";
  }
  return out;
}

}  // namespace fa::ui
