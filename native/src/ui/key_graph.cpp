#include "ui/key_graph.h"

#include <unordered_set>
#include <utility>

namespace fa::ui {
namespace {

int index_of(const std::vector<ControlId>& order, const ControlId& key) {
  for (std::size_t i = 0; i < order.size(); i++)
    if (order[i] == key) return static_cast<int>(i);
  return -1;
}

// A survivor at a previous-order index belonging to the remembered landing group, else none.
std::optional<ControlId> group_survivor_at(const GraphRender& render, const GraphState& state, int index) {
  if (index < 0 || index >= static_cast<int>(state.key_order.size())) return std::nullopt;
  GraphNode* n = render.node_at(state.key_order[static_cast<std::size_t>(index)]);
  if (n == nullptr) return std::nullopt;
  if (n->vtable != nullptr && n->vtable->land_group == state.last_land_group) return n->id;
  return std::nullopt;
}

// Track the focused node's landing group (empty when it has none) for the row-vanish rule.
void remember_land_group(const GraphRender& render, GraphState& state, const std::optional<ControlId>& key) {
  GraphNode* node = render.node_at(key);
  if (node != nullptr) state.last_land_group = node->vtable != nullptr ? node->vtable->land_group : std::string();
}

// Track the tabular column focus sits on (nodes outside tables leave it untouched, so a detour through
// a header row or another stop doesn't forget the working column).
void remember_column(const GraphRender& render, GraphState& state, const std::optional<ControlId>& key) {
  GraphNode* node = render.node_at(key);
  if (node != nullptr && node->vtable != nullptr && node->vtable->column >= 0)
    state.last_column = node->vtable->column;
}

void remember_stop(const GraphRender& render, GraphState& state, const std::optional<ControlId>& key) {
  GraphNode* node = render.node_at(key);
  if (node != nullptr && !node->stop_key.empty()) state.stop_memory.insert_or_assign(node->stop_key, *key);
}

}  // namespace

bool KeyGraph::rerender() {
  // Retire the render one generation at a time: callers (and tree_right below) legitimately keep
  // reading nodes they read before the rebuild.
  previous_ = std::move(current_);
  current_ = render_callback_();
  if (current_ == nullptr || current_->node_count() == 0) {
    current_ = nullptr;
    return false;
  }
  reconcile(*current_, *state_);
  return true;
}

void KeyGraph::reconcile(GraphRender& render, GraphState& state) {
  // Honor a pending suggested move first, if its target still exists (consumed either way).
  if (state.next_suggested_move) {
    GraphNode* suggested = render.node_at(*state.next_suggested_move);
    if (suggested != nullptr) state.cur_key = suggested->id;
    state.next_suggested_move.reset();
  }

  const std::optional<ControlId> old = state.cur_key;
  std::optional<ControlId> resolved;

  if (old) {
    // Tier 1: the same backing object, even if its structural key changed (it moved).
    // (The C# scanned the node dictionary in hash order; declaration order is used here so a render
    // that somehow carried the same reference twice resolves deterministically.)
    if (old->reference() != nullptr) {
      for (GraphNode* n : render.order())
        if (n->id.reference_matches(old->reference())) {
          resolved = n->id;
          break;
        }
    }

    // Tier 2: the same structural key, even if the backing object was rebuilt.
    if (!resolved) {
      GraphNode* structural = render.node_at(*old);
      if (structural != nullptr) resolved = structural->id;
    }

    // Tier 3 -- the GENERAL row-vanish rule: land on the nearest survivor OF THE SAME LANDING GROUP
    // (this list's rows), next-first then previous -- never a header, a lead line (the vendor's gold
    // row) or another panel. Only nodes stamped with a land_group participate; the vanished node's
    // group was remembered at focus time.
    if (!resolved && !state.key_order.empty() && !state.last_land_group.empty()) {
      const int old_index = index_of(state.key_order, *old);
      if (old_index >= 0) {
        const int count = static_cast<int>(state.key_order.size());
        for (int off = 1; off < count && !resolved; off++) {
          resolved = group_survivor_at(render, state, old_index + off);  // next row first
          if (!resolved) resolved = group_survivor_at(render, state, old_index - off);
        }
        if (resolved) resolved = slide_to_column(render, *resolved, state.last_column);
      }
    }

    // Fallback: nearest survivor walking the previous order backward. The order interleaves row cells,
    // so when a whole row vanished (an equipped item's row) the walk lands on the previous row's LAST
    // cell -- a different column. Slide along that row to the column focus was on, so acting on rows in
    // sequence keeps your place in the table.
    if (!resolved && !state.key_order.empty()) {
      const int old_index = index_of(state.key_order, *old);
      if (old_index >= 0)
        for (int i = old_index; i >= 0; i--) {
          GraphNode* survivor = render.node_at(state.key_order[static_cast<std::size_t>(i)]);
          if (survivor != nullptr) {
            resolved = slide_to_column(render, survivor->id, state.last_column);
            break;
          }
        }
    }
  }

  // Nothing matched (or first render): the start node -- but prefer the SELECTED member of its stop
  // (initial focus lands on the checked radio/tab, not the top of a long list).
  if (!resolved) {
    GraphNode* start_node = render.node_at(render.start_key);
    GraphNode* sel = start_node != nullptr ? selected_node_in_stop(render, start_node->stop_key, start_node) : nullptr;
    if (sel != nullptr) resolved = sel->id;
    else if (start_node != nullptr) resolved = start_node->id;
    else resolved = render.start_key;  // a hand-built render with no start key leaves focus unset
  }

  state.cur_key = resolved;
  remember_stop(render, state, resolved);
  remember_column(render, state, resolved);
  remember_land_group(render, state, resolved);
  state.key_order = compute_order(render);
}

ControlId KeyGraph::slide_to_column(const GraphRender& render, const ControlId& start, int pref_col) {
  GraphNode* node = render.node_at(start);
  if (node == nullptr || pref_col < 0) return start;
  const int col = node->vtable != nullptr ? node->vtable->column : -1;
  if (col < 0 || col == pref_col) return start;

  const GraphDir dir = col < pref_col ? GraphDir::Right : GraphDir::Left;
  GraphNode* cur = node;
  while (cur->vtable->column != pref_col) {
    const Transition* t = cur->transition(dir);
    if (t == nullptr) break;
    GraphNode* next = render.node_at(t->destination);
    if (next == nullptr || next->vtable == nullptr || next->vtable->column < 0) break;
    if (dir == GraphDir::Right && next->vtable->column > pref_col) break;  // sparse: stop below pref
    if (dir == GraphDir::Left && next->vtable->column < pref_col) {        // overshot: nearest below
      cur = next;
      break;
    }
    cur = next;
  }
  return cur->id;
}

std::vector<ControlId> KeyGraph::compute_order(const GraphRender& render) {
  std::vector<ControlId> order;
  std::unordered_set<ControlId> seen;
  std::vector<ControlId> down_fringe;
  if (render.start_key) down_fringe.push_back(*render.start_key);

  std::size_t i = 0;
  while (i < down_fringe.size()) {
    ControlId k = down_fringe[i];
    while (seen.count(k) == 0) {
      seen.insert(k);
      order.push_back(k);

      GraphNode* n = render.node_at(k);
      if (n == nullptr) break;

      const Transition* d = n->transition(GraphDir::Down);
      if (d != nullptr) down_fringe.push_back(d->destination);
      const Transition* t = n->transition(GraphDir::Right);
      if (t == nullptr) break;
      k = t->destination;
    }
    i++;
  }

  for (GraphNode* node : render.order())
    if (seen.insert(node->id).second) order.push_back(node->id);

  return order;
}

void KeyGraph::set_current(GraphNode* node) {
  state_->cur_key = node->id;
  if (!node->stop_key.empty()) state_->stop_memory.insert_or_assign(node->stop_key, node->id);
  if (node->vtable != nullptr && node->vtable->column >= 0) state_->last_column = node->vtable->column;
  // Row-vanish rule (see reconcile tier 3).
  state_->last_land_group = node->vtable != nullptr ? node->vtable->land_group : std::string();
}

bool KeyGraph::focus_at_column(const ControlId& id, int pref_col) {
  if (!rerender()) return false;
  const ControlId target = slide_to_column(*current_, id, pref_col);
  GraphNode* node = current_->node_at(target);
  if (node == nullptr) return false;
  set_current(node);
  return true;
}

// ---- navigation operations ----

MoveResult KeyGraph::move(GraphDir dir) {
  MoveResult result;
  if (!rerender()) return result;

  GraphNode* node = current_node();
  result.from = node;
  result.to = node;
  if (node == nullptr) return result;

  const Transition* t = node->transition(dir);
  GraphNode* dest = t != nullptr ? current_->node_at(t->destination) : nullptr;
  if (dest == nullptr || dest == node) return result;

  set_current(dest);
  result.to = dest;
  result.moved = true;
  result.transition_label = t->label;
  return result;
}

MoveResult KeyGraph::move_to_edge(GraphDir dir) {
  MoveResult result;
  if (!rerender()) return result;

  GraphNode* node = current_node();
  result.from = node;
  result.to = node;
  if (node == nullptr) return result;

  GraphNode* cur = node;
  while (true) {
    const Transition* t = cur->transition(dir);
    if (t == nullptr) break;
    GraphNode* next = current_->node_at(t->destination);
    if (next == nullptr || next == cur) break;
    cur = next;
  }

  if (cur != node) {
    set_current(cur);
    result.to = cur;
    result.moved = true;
  }
  return result;
}

MoveResult KeyGraph::move_stop(int dir, bool wrap) {
  MoveResult result;
  if (!rerender()) return result;

  GraphNode* node = current_node();
  result.from = node;
  result.to = node;
  if (node == nullptr) return result;

  const std::vector<Key> stops = stop_order();
  if (stops.size() <= 1) return result;

  int idx = -1;
  for (std::size_t i = 0; i < stops.size(); i++)
    if (stops[i] == node->stop_key) {
      idx = static_cast<int>(i);
      break;
    }
  if (idx < 0) return result;
  const int count = static_cast<int>(stops.size());
  int ni = idx + dir;
  if (wrap) ni = ((ni % count) + count) % count;
  if (ni < 0 || ni >= count || ni == idx) return result;

  GraphNode* dest = stop_landing(stops[static_cast<std::size_t>(ni)]);
  if (dest == nullptr) return result;

  set_current(dest);
  result.to = dest;
  result.moved = true;
  return result;
}

MoveResult KeyGraph::move_region(int dir) {
  MoveResult result;
  if (!rerender()) return result;

  GraphNode* node = current_node();
  result.from = node;
  result.to = node;
  if (node == nullptr || node->region_key.empty()) return result;

  std::vector<Key> regions;
  for (GraphNode* n : current_->order()) {
    if (!(n->stop_key == node->stop_key) || n->region_key.empty()) continue;
    bool known = false;
    for (const Key& r : regions)
      if (r == n->region_key) {
        known = true;
        break;
      }
    if (!known) regions.push_back(n->region_key);
  }

  int idx = -1;
  for (std::size_t i = 0; i < regions.size(); i++)
    if (regions[i] == node->region_key) {
      idx = static_cast<int>(i);
      break;
    }
  const int ni = idx + dir;
  if (idx < 0 || ni < 0 || ni >= static_cast<int>(regions.size())) return result;

  for (GraphNode* n : current_->order())
    if (n->stop_key == node->stop_key && n->region_key == regions[static_cast<std::size_t>(ni)]) {
      set_current(n);
      result.to = n;
      result.moved = true;
      return result;
    }
  return result;
}

bool KeyGraph::focus(const ControlId& id) {
  if (!rerender()) return false;
  GraphNode* node = current_->node_at(id);
  if (node == nullptr) return false;
  set_current(node);
  return true;
}

bool KeyGraph::focus_by_reference(const void* reference) {
  if (reference == nullptr || current_ == nullptr) return false;
  for (GraphNode* n : current_->order())
    if (n->id.reference_matches(reference)) {
      const bool changed = !state_->cur_key || !(*state_->cur_key == n->id);
      set_current(n);
      return changed;
    }
  return false;
}

std::vector<Key> KeyGraph::stop_order() const {
  std::vector<Key> stops;
  for (GraphNode* n : current_->order()) {
    if (n->stop_key.empty()) continue;
    bool known = false;
    for (const Key& s : stops)
      if (s == n->stop_key) {
        known = true;
        break;
      }
    if (!known) stops.push_back(n->stop_key);
  }
  return stops;
}

GraphNode* KeyGraph::stop_landing(const Key& stop_key) const {
  return stop_landing(*current_, *state_, stop_key);
}

GraphNode* KeyGraph::stop_landing(const GraphRender& render, const GraphState& state, const Key& stop_key) {
  auto it = state.stop_memory.find(stop_key);
  if (it != state.stop_memory.end()) {
    GraphNode* node = render.node_at(it->second);
    if (node != nullptr && node->stop_key == stop_key) return node;
  }
  GraphNode* first = nullptr;
  for (GraphNode* n : render.order())
    if (n->stop_key == stop_key) { first = n; break; }
  if (first == nullptr) return nullptr;
  GraphNode* selected = selected_node_in_stop(render, stop_key, first);
  return selected != nullptr ? selected : first;
}

GraphNode* KeyGraph::selected_node_in_stop(const GraphRender& render, const Key& stop_key, const GraphNode* sibling_of) {
  for (GraphNode* n : render.order()) {
    if (!(n->stop_key == stop_key)) continue;
    if (sibling_of != nullptr && n->parent != sibling_of->parent) continue;
    if (n->vtable == nullptr) continue;
    for (const NodeAnnouncement& a : n->vtable->announcements) {
      if (std::string_view(a.kind) != announcement_kinds::kSelected) continue;
      std::string t;
      // A part's text resolver runs game code; a throwing one must not break stop entry.
      try {
        if (a.text) t = a.text();
      } catch (...) {
      }
      if (!t.empty()) return n;
    }
  }
  return nullptr;
}

// ---- tree operations ----

bool KeyGraph::in_tree(const GraphNode* node) {
  for (const GraphNode* n = node; n != nullptr; n = n->parent)
    if (n->expandable) return true;
  return false;
}

KeyGraph::TreeResult KeyGraph::tree_right() {
  TreeResult result;
  if (!rerender()) return result;
  GraphNode* node = current_node();
  if (node == nullptr) return result;

  if (node->expandable && !node->expanded) {
    const ControlId group_id = node->id;  // the node itself belongs to the render we are about to retire
    set_expanded(node, true);
    if (!rerender()) return result;
    GraphNode* header = current_->node_at(group_id);
    if (header == nullptr) return result;
    if (first_child_of(header) == nullptr) {
      // A lazy drill-in that resolved to nothing: don't leave a silent empty-expanded node.
      set_expanded(header, false);
      rerender();
      result.kind = TreeMove::EmptyGroup;
      return result;
    }
    result.kind = TreeMove::Expanded;
    return result;
  }

  if (node->expandable && node->expanded) {
    GraphNode* child = first_child_of(node);
    if (child == nullptr) {
      result.kind = TreeMove::Leaf;
      return result;
    }
    result.move.from = node;
    set_current(child);
    result.move.to = child;
    result.move.moved = true;
    result.kind = TreeMove::Descended;
    return result;
  }

  result.kind = in_tree(node) ? TreeMove::Leaf : TreeMove::None;
  return result;
}

KeyGraph::TreeResult KeyGraph::tree_left() {
  TreeResult result;
  if (!rerender()) return result;
  GraphNode* node = current_node();
  if (node == nullptr) return result;

  if (node->expandable && node->expanded) {
    set_expanded(node, false);
    rerender();  // focus stays on the header by identity
    result.kind = TreeMove::Collapsed;
    return result;
  }

  for (GraphNode* p = node->parent; p != nullptr; p = p->parent) {
    if (!p->focusable || !current_->contains(p->id)) continue;
    result.move.from = node;
    GraphNode* target = current_->node_at(p->id);
    set_current(target);
    result.move.to = target;
    result.move.moved = true;
    result.kind = TreeMove::Ascended;
    return result;
  }

  result.kind = in_tree(node) ? TreeMove::Leaf : TreeMove::None;
  return result;
}

MoveResult KeyGraph::move_to_sibling_edge(bool first) {
  MoveResult result;
  if (!rerender()) return result;
  GraphNode* node = current_node();
  result.from = node;
  result.to = node;
  if (node == nullptr) return result;

  GraphNode* target = nullptr;
  for (GraphNode* n : current_->order()) {
    if (n->parent != node->parent) continue;
    // Same Tab-stop only: a top-level group and the tab strip share a null parent, and Home from a
    // constellation header used to land on the first tab (2026-08-27).
    if (n->stop_key != node->stop_key) continue;
    if (first) {
      target = n;
      break;
    }
    target = n;  // last match wins
  }
  if (target == nullptr || target == node) return result;
  set_current(target);
  result.to = target;
  result.moved = true;
  return result;
}

// Change a group's expansion: through its vtable override when declared (the adapter driving a retained
// container), else the persistent set.
void KeyGraph::set_expanded(GraphNode* group, bool expanded) {
  if (group->vtable != nullptr) {
    if (expanded && group->vtable->on_expand) {
      group->vtable->on_expand();
      return;
    }
    if (!expanded && group->vtable->on_collapse) {
      group->vtable->on_collapse();
      return;
    }
  }
  if (expanded) state_->expanded.insert(group->id);
  else state_->expanded.erase(group->id);
}

GraphNode* KeyGraph::first_child_of(const GraphNode* group) const {
  for (GraphNode* n : current_->order())
    if (n->parent == group) return n;
  return nullptr;
}

// ---- behavior invokers ----

bool KeyGraph::activate() {
  if (!rerender()) return false;
  GraphNode* node = current_node();
  if (node == nullptr || node->vtable == nullptr || !node->vtable->on_activate) return false;
  node->vtable->on_activate();
  return true;
}

bool KeyGraph::secondary() {
  if (!rerender()) return false;
  GraphNode* node = current_node();
  if (node == nullptr || node->vtable == nullptr || !node->vtable->on_secondary) return false;
  node->vtable->on_secondary();
  return true;
}

bool KeyGraph::tooltip() {
  if (!rerender()) return false;
  GraphNode* node = current_node();
  if (node == nullptr || node->vtable == nullptr || !node->vtable->on_tooltip) return false;
  node->vtable->on_tooltip();
  return true;
}

bool KeyGraph::compare() {
  if (!rerender()) return false;
  GraphNode* node = current_node();
  if (node == nullptr || node->vtable == nullptr || !node->vtable->on_compare) return false;
  node->vtable->on_compare();
  return true;
}

bool KeyGraph::try_adjust(int sign, bool large) {
  if (!rerender()) return false;
  GraphNode* node = current_node();
  if (node == nullptr || node->vtable == nullptr || !node->vtable->on_adjust) return false;
  node->vtable->on_adjust(sign, large);
  return true;
}

}  // namespace fa::ui
