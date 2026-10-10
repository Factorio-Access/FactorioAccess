#include "ui/graph_announcer.h"

#include <algorithm>

#include "ui/message_builder.h"

namespace fa::ui {
namespace {

// The node's path: ancestors outermost-first, then the node itself.
std::vector<const GraphNode*> path_of(const GraphNode* node) {
  std::vector<const GraphNode*> path;
  for (const GraphNode* n = node; n != nullptr; n = n->parent) path.push_back(n);
  std::reverse(path.begin(), path.end());
  return path;
}

bool has_kind(const std::vector<NodeAnnouncement>& anns, const std::string& kind) {
  if (kind.empty()) return false;  // the C# null kind never matches
  for (const NodeAnnouncement& a : anns)
    if (a.kind == kind) return true;
  return false;
}

// Sort key: declared kinds by their order index; everything else after (one shared bucket, with the
// stable sort below keeping their declaration order).
std::size_t order_index(const std::vector<std::string>& order, const std::string& kind) {
  if (!kind.empty())
    for (std::size_t i = 0; i < order.size(); i++)
      if (order[i] == kind) return i;
  return order.size();
}

// The next part "starts as" this label: equal, or its first comma-separated segment is the label (a
// control's readout leads with its label: "Game difficulty, menu button").
bool duplicates_next(const std::string& label, const std::string& next) {
  if (next.rfind(label, 0) != 0) return false;
  return next.size() == label.size() || next[label.size()] == ',';
}

// A stand-in part handed to the part filter so the user's position-kind toggle governs the
// auto-stamped position too.
const NodeAnnouncement& auto_position_probe() {
  static const NodeAnnouncement probe(nullptr, false, announcement_kinds::kPosition);
  return probe;
}

}  // namespace

std::vector<ControlId> GraphAnnouncer::path_ids(const GraphNode* node) {
  std::vector<ControlId> ids;
  for (const GraphNode* n : path_of(node)) ids.push_back(n->id);
  return ids;
}

std::optional<std::string> GraphAnnouncer::compose(const GraphNode* from, const GraphNode* to,
                                                  std::string_view transition_label) {
  return compose_from_path(path_ids(from), to, transition_label);
}

std::optional<std::string> GraphAnnouncer::compose_from_path(const std::vector<ControlId>& from_path, const GraphNode* to,
                                                            std::string_view transition_label) {
  if (to == nullptr) return std::nullopt;

  const std::vector<const GraphNode*> to_path = path_of(to);

  // Common prefix by identity -- levels we were already inside (or ON: descending from a group onto its
  // child keeps the group in the prefix) stay silent.
  std::size_t i = 0;
  while (i < from_path.size() && i < to_path.size() && from_path[i] == to_path[i]->id) i++;

  MessageBuilder message;
  bool any = false;
  auto push = [&message, &any](std::string_view part) {
    if (part.empty()) return;
    message.list_item().fragment(part);
    any = true;
  };

  push(transition_label);

  if (i >= to_path.size()) {
    // Ascended (or same node): announce just the now-innermost focus.
    const std::optional<std::string> text = leaf_text(to);
    if (text) push(*text);
  } else {
    for (std::size_t j = i; j < to_path.size(); j++) {
      const std::optional<std::string> text = leaf_text(to_path[j]);
      if (!text || text->empty()) continue;
      // Dedupe: a level whose label just duplicates the next level down (or the control itself --
      // "a 'Game difficulty' section wrapping the 'Game difficulty' control").
      if (j + 1 < to_path.size()) {
        const std::optional<std::string> label = first_part_text(to_path[j]);
        const std::optional<std::string> next = first_part_text(to_path[j + 1]);
        if (label && !label->empty() && next && !next->empty() && duplicates_next(*label, *next)) continue;
      }
      push(*text);
    }
  }

  if (!any) return std::nullopt;
  return message.build();
}

std::vector<NodeAnnouncement> GraphAnnouncer::effective_announcements(const GraphNode* node) {
  std::vector<NodeAnnouncement> result;
  const NodeVtable* vt = node != nullptr ? node->vtable.get() : nullptr;
  if (vt == nullptr) return result;
  const ControlType* type = vt->control_type;

  if (type != nullptr && type->common) {
    for (const NodeAnnouncement& c : type->common())
      if (!has_kind(vt->announcements, c.kind)) result.push_back(c);
  }
  for (const NodeAnnouncement& a : vt->announcements) result.push_back(a);

  if (type != nullptr && !type->order.empty() && result.size() > 1) {
    // Stable by construction: the C# built a composite (kind order index, declaration index) key
    // because List.Sort is unstable and would have scrambled same-bucket (kindless) parts.
    std::stable_sort(result.begin(), result.end(),
                     [type](const NodeAnnouncement& x, const NodeAnnouncement& y) {
                       return order_index(type->order, x.kind) < order_index(type->order, y.kind);
                     });
  }

  if (part_filter) {
    auto filter = part_filter;  // a part's resolver must not see a half-swapped hook
    result.erase(std::remove_if(result.begin(), result.end(),
                                [&filter, type](const NodeAnnouncement& a) { return !filter(type, a); }),
                 result.end());
  }
  return result;
}

std::optional<std::string> GraphAnnouncer::leaf_text(const GraphNode* node) {
  const std::vector<NodeAnnouncement> anns = effective_announcements(node);
  MessageBuilder message;
  bool any = false;
  auto push = [&message, &any](const std::string& part) {
    if (part.empty()) return;
    message.list_item().fragment(part);
    any = true;
  };

  for (const NodeAnnouncement& a : anns)
    if (a.text) push(a.text());

  const NodeVtable* vt = node != nullptr ? node->vtable.get() : nullptr;
  // (The C# dereferenced node.Vtable unguarded on both branches below; a node with no vtable has no
  // announcements to speak either, so guarding is a strict improvement.)
  if (node != nullptr && node->expandable && vt != nullptr && !vt->speaks_own_expansion &&
      expanded_state_text) {
    push(expanded_state_text(node->expanded));
  }

  // The auto-stamped sibling position, unless the node carries its own (an explicit position-kind part,
  // or the adapter's composed message). Honors the user's per-kind setting.
  if (node != nullptr && node->position_count > 1 && position_text && vt != nullptr &&
      !vt->speaks_own_position && !has_kind(vt->announcements, std::string(announcement_kinds::kPosition)) &&
      (!part_filter || part_filter(vt->control_type, auto_position_probe()))) {
    push(position_text(node->position_index, node->position_count));
  }

  if (!any) return std::nullopt;
  return message.build();
}

std::optional<std::string> GraphAnnouncer::first_part_text(const GraphNode* node) {
  const NodeVtable* vt = node != nullptr ? node->vtable.get() : nullptr;
  if (vt == nullptr || vt->announcements.empty()) return std::nullopt;
  const NodeAnnouncement& first = vt->announcements.front();
  if (!first.text) return std::nullopt;
  return first.text();
}

}  // namespace fa::ui
