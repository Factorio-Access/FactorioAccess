#include "ui/graph_builder.h"

#include <stdexcept>
#include <utility>

namespace fa::ui {
namespace {

// (parent, stop) -- the sibling group an auto-stamped "n of m" position counts within.
struct GroupKey {
  const GraphNode* parent;
  Key stop;
  friend bool operator==(const GroupKey& a, const GroupKey& b) {
    return a.parent == b.parent && a.stop == b.stop;
  }
};

struct GroupKeyHash {
  std::size_t operator()(const GroupKey& k) const noexcept {
    return std::hash<const void*>{}(k.parent) * 31u + k.stop.hash();
  }
};

}  // namespace

Key GraphBuilder::auto_stop_key(int index) { return Key("stop#" + std::to_string(index)); }

GraphNode* GraphBuilder::own(std::unique_ptr<GraphNode> node) {
  owned_.push_back(std::move(node));
  return owned_.back().get();
}

// ---- stops / regions ----

GraphBuilder& GraphBuilder::begin_stop(Key key) {
  if (current_row_ != nullptr) throw std::logic_error("Cannot begin a stop inside an open row");
  stop_key_ = key.empty() ? auto_stop_key(stop_auto_) : std::move(key);
  stop_auto_++;
  region_key_ = Key();  // regions are per-stop
  return *this;
}

GraphBuilder& GraphBuilder::set_region(Key key) {
  region_key_ = std::move(key);
  return *this;
}

// ---- the parent stack: contexts + groups ----

GraphBuilder& GraphBuilder::push_context(std::string_view label, std::string_view role, bool positions) {
  GraphNode* parent = current_parent();
  auto vtable = std::make_shared<NodeVtable>();
  vtable->announcements.push_back(NodeAnnouncement::fixed(std::string(label)));
  if (!role.empty()) vtable->announcements.push_back(NodeAnnouncement::fixed(std::string(role)));

  // Stable synthetic identity so cross-render chain diffs match up -- SCOPED BY THE STOP: a purely
  // label-pathed id collided for same-named contexts on different stops (two "Corpse of Mongrel" loot
  // lists), so the announcer's prefix diff thought focus never left the first one and tabbing spoke
  // just the bare item.
  std::string id = "ctx:" + stop_key_.to_string() + ":" +
                   (parent != nullptr ? parent->id.structural_key().to_string() : std::string()) + "/" +
                   std::string(label);
  GraphNode* node = own(std::make_unique<GraphNode>(ControlId::structural(Key(id)), std::move(vtable)));
  node->parent = parent;
  node->focusable = false;
  node->suppress_child_positions = !positions;
  parents_.push_back(ParentFrame{node, suppressed()});
  return *this;
}

GraphBuilder& GraphBuilder::pop_context() {
  if (parents_.empty()) throw std::logic_error("No context/group to pop");
  parents_.pop_back();
  return *this;
}

GraphBuilder& GraphBuilder::begin_group(ControlId id, NodeVtablePtr vtable, std::optional<bool> expanded,
                                        bool default_expanded) {
  if (current_row_ != nullptr) throw std::logic_error("Cannot begin a group inside an open row");
  const bool is_expanded =
      expanded ? *expanded
               : (expansion_ != nullptr ? expansion_->count(id) != 0 : default_expanded);

  GraphNode* header = nullptr;
  if (!suppressed()) {
    header = make_node(std::move(id), std::move(vtable));
    header->expandable = true;
    header->expanded = is_expanded;
    owned_rows_.push_back(std::make_unique<Row>());
    Row* row = owned_rows_.back().get();
    row->stop_key = stop_key_;
    row->items.push_back(header);
    rows_.push_back(row);
    row_of_[header] = row;
  }
  parents_.push_back(ParentFrame{
      // Suppressed subtree: keep chaining from the outer parent so the stack stays coherent.
      header != nullptr ? header : current_parent(),
      suppressed() || !is_expanded,
  });
  return *this;
}

bool GraphBuilder::is_expanded(const ControlId& id) const {
  return expansion_ != nullptr && expansion_->count(id) != 0;
}

GraphBuilder& GraphBuilder::set_start(ControlId id) {
  start_ = std::move(id);
  return *this;
}

GraphBuilder& GraphBuilder::set_stop_entry(ControlId id) {
  stop_entries_.insert_or_assign(stop_key_, std::move(id));
  return *this;
}

// ---- menu mode ----

GraphBuilder& GraphBuilder::start_row(Key row_key) {
  if (current_row_ != nullptr) throw std::logic_error("Cannot start a row while another is open");
  owned_rows_.push_back(std::make_unique<Row>());
  current_row_ = owned_rows_.back().get();
  current_row_->key = std::move(row_key);
  current_row_->stop_key = stop_key_;
  return *this;
}

GraphBuilder& GraphBuilder::end_row() {
  if (current_row_ == nullptr) throw std::logic_error("No row to end");
  if (current_row_->items.empty() && !suppressed()) throw std::logic_error("Row cannot be empty");
  if (!current_row_->items.empty()) rows_.push_back(current_row_);
  current_row_ = nullptr;
  return *this;
}

GraphBuilder& GraphBuilder::add_item(ControlId id, NodeVtablePtr vtable) {
  if (suppressed()) return *this;
  // An actionable node belongs to its Tab stop's landing group unless the screen said otherwise: when it vanishes
  // on the rebuild its action caused (an item moved, sold, used), focus lands on the next row of the same list,
  // not on the previous stop's last node (2026-09-04: Enter on the first row of a list bounced to the tab strip).
  // Lead lines and headers have no action and keep no group, so they are never the landing.
  if (vtable && vtable->land_group.empty() && vtable->on_activate) vtable->land_group = stop_key_.to_string();
  GraphNode* node = make_node(std::move(id), std::move(vtable));
  if (current_row_ != nullptr) {
    current_row_->items.push_back(node);
    row_of_[node] = current_row_;
  } else {
    owned_rows_.push_back(std::make_unique<Row>());
    Row* row = owned_rows_.back().get();
    row->stop_key = stop_key_;
    row->items.push_back(node);
    rows_.push_back(row);
    row_of_[node] = row;
  }
  return *this;
}

GraphBuilder& GraphBuilder::add_label(ControlId id, std::function<std::string()> label) {
  auto vtable = std::make_shared<NodeVtable>();
  vtable->announcements.push_back(NodeAnnouncement(std::move(label)));
  return add_item(std::move(id), std::move(vtable));
}

// ---- raw mode ----

GraphBuilder& GraphBuilder::add_node(ControlId id, NodeVtablePtr vtable) {
  if (suppressed()) return *this;
  raw_nodes_.push_back(make_node(std::move(id), std::move(vtable)));
  return *this;
}

GraphBuilder& GraphBuilder::connect(ControlId from, GraphDir dir, ControlId to, std::string label) {
  raw_edges_.push_back(RawEdge{std::move(from), dir, std::move(to), std::move(label)});
  return *this;
}

GraphNode* GraphBuilder::make_node(ControlId id, NodeVtablePtr vtable) {
  if (vtable == nullptr || vtable->announcements.empty())
    throw std::invalid_argument("A control must have at least one announcement");
  if (!ids_.insert(id).second)
    throw std::logic_error("Duplicate control id: " + id.to_string());
  GraphNode* node = own(std::make_unique<GraphNode>(std::move(id), std::move(vtable)));
  node->parent = current_parent();
  node->stop_key = stop_key_;
  node->region_key = region_key_;
  declared_.push_back(node);
  return node;
}

// ---- build ----

GraphRenderPtr GraphBuilder::build() {
  if (current_row_ != nullptr) throw std::logic_error("Unclosed row - call EndRow()");
  if (raw_nodes_.empty() && rows_.empty()) return nullptr;

  auto render = std::make_unique<GraphRender>();
  // Hand the whole node arena over first: the render owns every node from here on, including the
  // non-focusable context parents that are reachable only through parent pointers.
  for (auto& node : owned_) render->adopt(std::move(node));
  owned_.clear();
  for (GraphNode* node : declared_) render->publish(node);

  wire_menu_edges();
  for (const RawEdge& e : raw_edges_) {
    GraphNode* from = render->node_at(e.from);
    if (from != nullptr && render->contains(e.to)) from->set_transition(e.dir, Transition(e.to, e.label));
  }
  stitch_mode_boundaries();

  render->start_key = (start_ && render->contains(*start_)) ? *start_ : render->order()[0]->id;
  for (auto& [stop, entry] : stop_entries_) {
    const GraphNode* n = render->node_at(entry);
    if (n != nullptr && n->stop_key == stop) render->stop_entries.emplace(stop, entry);
  }
  stamp_positions();
  return render;
}

// Where a stop mixes MENU rows with RAW content (search/sort/filter controls above a sheet), the two
// wiring systems don't see each other: menu auto-wiring connects only menu rows, and the raw content's
// explicit edges stop at its own borders -- leaving a vertical gap arrows can't cross. Stitch it: at
// each menu->raw boundary (declaration order, same stop), the menu row's cells gain Down edges into the
// first raw node still missing an Up edge, and that node gains the Up back; at raw->menu boundaries the
// reverse. Only MISSING edges are filled -- the raw content's own wiring is never overridden.
void GraphBuilder::stitch_mode_boundaries() {
  std::unordered_map<Key, std::vector<GraphNode*>> by_stop;
  std::vector<Key> stops;
  for (GraphNode* n : declared_) {
    auto it = by_stop.find(n->stop_key);
    if (it == by_stop.end()) {
      it = by_stop.emplace(n->stop_key, std::vector<GraphNode*>()).first;
      stops.push_back(n->stop_key);
    }
    it->second.push_back(n);
  }

  for (const Key& stop : stops) {
    const std::vector<GraphNode*>& nodes = by_stop[stop];
    for (std::size_t i = 1; i < nodes.size(); i++) {
      GraphNode* prev = nodes[i - 1];
      GraphNode* cur = nodes[i];
      const bool prev_menu = row_of_.count(prev) != 0;
      const bool cur_menu = row_of_.count(cur) != 0;
      if (prev_menu == cur_menu) continue;  // same mode -- its own wiring covers it

      if (prev_menu) {  // menu row above raw content: row cells down into first raw node without an Up
        if (cur->has_transition(GraphDir::Up)) continue;
        Row* row = row_of_[prev];
        for (GraphNode* cell : row->items)
          if (!cell->has_transition(GraphDir::Down))
            cell->set_transition(GraphDir::Down, Transition(cur->id));
        cur->set_transition(GraphDir::Up, Transition(row->items[0]->id));
      } else {  // raw content above a menu row: last raw node without a Down links both ways to the row
        Row* row = row_of_[cur];
        // The raw side's bottom = the latest raw node (walking back) missing a Down.
        GraphNode* bottom = nullptr;
        for (std::size_t j = i; j-- > 0 && row_of_.count(nodes[j]) == 0;)
          if (!nodes[j]->has_transition(GraphDir::Down)) {
            bottom = nodes[j];
            break;
          }
        if (bottom == nullptr) continue;
        bottom->set_transition(GraphDir::Down, Transition(row->items[0]->id));
        for (GraphNode* cell : row->items)
          if (!cell->has_transition(GraphDir::Up))
            cell->set_transition(GraphDir::Up, Transition(bottom->id));
      }
    }
  }
}

// Auto-stamp "n of m" positions the way the old containers did: a multi-item row's members are
// positioned within their ROW (a bar); single-item-row nodes among the siblings sharing their
// (parent, stop) -- the vertical list/tree level arrows actually traverse. Raw/grid nodes get none.
// Announced only when m > 1 (a lone button reads no position).
void GraphBuilder::stamp_positions() {
  std::unordered_map<GroupKey, std::vector<GraphNode*>, GroupKeyHash> groups;
  std::vector<GroupKey> keys;
  for (Row* row : rows_) {
    if (row->items.size() > 1) {
      stamp(row->items, true);
      continue;
    }
    GraphNode* node = row->items[0];
    if (node->parent != nullptr && node->parent->suppress_child_positions) continue;
    GroupKey key{node->parent, node->stop_key};
    auto it = groups.find(key);
    if (it == groups.end()) {
      it = groups.emplace(key, std::vector<GraphNode*>()).first;
      keys.push_back(key);
    }
    it->second.push_back(node);
  }
  for (const GroupKey& key : keys) stamp(groups[key]);
}

void GraphBuilder::stamp(const std::vector<GraphNode*>& siblings, bool row) {
  if (siblings.size() < 2) return;
  for (std::size_t i = 0; i < siblings.size(); i++) {
    siblings[i]->position_index = static_cast<int>(i) + 1;
    siblings[i]->position_count = static_cast<int>(siblings.size());
    siblings[i]->row_member = row;
  }
}

// Left/right within a row; up/down between consecutive rows OF THE SAME STOP (arrows never cross a
// Tab-stop). Shared non-empty row keys preserve the column; otherwise vertical lands on first item.
void GraphBuilder::wire_menu_edges() {
  // Segment rows in DECLARATION order: within a stop, consecutive menu rows chain vertically only when
  // no raw node was declared between them. Interleaved raw content (a sheet between menu controls, e.g.
  // the class progression grid between the skills list and the auto-level button) BREAKS the chain --
  // stitch_mode_boundaries wires the seams. Without the break, menu edges would skip straight over the
  // raw block; the stitcher (which only fills missing edges) would find the gap already bridged,
  // leaving the block an unreachable island.
  std::vector<std::vector<Row*>> segments;
  std::unordered_map<Key, std::size_t> open_segment;  // stop -> index of its currently-open segment
  for (GraphNode* node : declared_) {
    auto row_it = row_of_.find(node);
    if (row_it != row_of_.end()) {
      Row* row = row_it->second;
      auto seg_it = open_segment.find(node->stop_key);
      if (seg_it == open_segment.end()) {
        segments.emplace_back();
        seg_it = open_segment.emplace(node->stop_key, segments.size() - 1).first;
      }
      std::vector<Row*>& seg = segments[seg_it->second];
      if (seg.empty() || seg.back() != row) seg.push_back(row);
    } else {
      open_segment.erase(node->stop_key);  // raw node: close this stop's segment
    }
  }

  for (const std::vector<Row*>& rows : segments) {
    for (std::size_t r = 0; r < rows.size(); r++) {
      Row* row = rows[r];
      for (std::size_t pos = 0; pos < row->items.size(); pos++) {
        GraphNode* node = row->items[pos];
        if (r > 0) node->set_transition(GraphDir::Up, Transition(vertical_target(*row, *rows[r - 1], pos)));
        if (r + 1 < rows.size())
          node->set_transition(GraphDir::Down, Transition(vertical_target(*row, *rows[r + 1], pos)));
        if (pos > 0) node->set_transition(GraphDir::Left, Transition(row->items[pos - 1]->id));
        if (pos + 1 < row->items.size())
          node->set_transition(GraphDir::Right, Transition(row->items[pos + 1]->id));
      }
    }
  }
}

// Where vertical navigation from position pos lands in the adjacent row: the same position when the
// rows share a non-empty key (column nav) and it exists there, else the first item.
ControlId GraphBuilder::vertical_target(const Row& from, const Row& to, std::size_t pos) {
  if (!from.key.empty() && !to.key.empty() && from.key == to.key && pos < to.items.size())
    return to.items[pos]->id;
  return to.items[0]->id;
}

}  // namespace fa::ui
