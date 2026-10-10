// Ported from wotr-access tests/GraphAnnouncerTests.cs (xUnit -> doctest). Every case is carried over.
#include <doctest/doctest.h>

#include <memory>
#include <optional>
#include <string>
#include <string_view>
#include <vector>

#include "ui/graph_announcer.h"

using fa::ui::ControlId;
using fa::ui::ControlType;
using fa::ui::GraphAnnouncer;
using fa::ui::GraphNode;
using fa::ui::Key;
using fa::ui::NodeAnnouncement;
using fa::ui::NodeVtable;
namespace kinds = fa::ui::announcement_kinds;

namespace {

// The announcer works on raw GraphNode chains, which a render normally owns; these tests build them by
// hand, so this arena plays that role (stable addresses, parent pointers stay valid).
class Arena {
 public:
  GraphNode* node(const std::string& label, GraphNode* parent = nullptr) {
    auto vt = std::make_shared<NodeVtable>();
    vt->announcements.push_back(NodeAnnouncement::fixed(label));
    return add(ControlId::structural(Key(label)), std::move(vt), parent);
  }

  GraphNode* context(const std::string& label, const std::string& role = std::string(),
                     GraphNode* parent = nullptr) {
    auto vt = std::make_shared<NodeVtable>();
    vt->announcements.push_back(NodeAnnouncement::fixed(label));
    if (!role.empty()) vt->announcements.push_back(NodeAnnouncement::fixed(role));
    GraphNode* n = add(ControlId::structural(Key("ctx:" + label)), std::move(vt), parent);
    n->focusable = false;
    return n;
  }

  GraphNode* typed(const ControlType* type, std::vector<NodeAnnouncement> parts) {
    auto vt = std::make_shared<NodeVtable>();
    vt->control_type = type;
    vt->announcements = std::move(parts);
    return add(ControlId::structural(Key("typed")), std::move(vt), nullptr);
  }

  GraphNode* custom(const std::string& key, std::vector<NodeAnnouncement> parts) {
    auto vt = std::make_shared<NodeVtable>();
    vt->announcements = std::move(parts);
    return add(ControlId::structural(Key(key)), std::move(vt), nullptr);
  }

 private:
  GraphNode* add(ControlId id, fa::ui::NodeVtablePtr vt, GraphNode* parent) {
    nodes_.push_back(std::make_unique<GraphNode>(std::move(id), std::move(vt)));
    GraphNode* n = nodes_.back().get();
    n->parent = parent;
    return n;
  }
  std::vector<std::unique_ptr<GraphNode>> nodes_;
};

// Readable failure output: the announcer returns nullopt for "nothing to say".
std::string spoken(const std::optional<std::string>& s) { return s ? *s : std::string("<nothing>"); }

// The announcer's hooks are process-wide statics (as in the C#); restore them however a case exits.
struct ScopedHooks {
  ScopedHooks()
      : part_filter(GraphAnnouncer::part_filter),
        position_text(GraphAnnouncer::position_text),
        expanded_state_text(GraphAnnouncer::expanded_state_text) {}
  ~ScopedHooks() {
    GraphAnnouncer::part_filter = part_filter;
    GraphAnnouncer::position_text = position_text;
    GraphAnnouncer::expanded_state_text = expanded_state_text;
  }
  decltype(GraphAnnouncer::part_filter) part_filter;
  decltype(GraphAnnouncer::position_text) position_text;
  decltype(GraphAnnouncer::expanded_state_text) expanded_state_text;
};

const ControlType& test_button() {
  static const ControlType type = [] {
    ControlType t;
    t.key = "button";
    t.order = {std::string(kinds::kLabel), std::string(kinds::kRole), std::string(kinds::kValue),
               std::string(kinds::kEnabled), std::string(kinds::kPosition)};
    t.common = [] {
      return std::vector<NodeAnnouncement>{
          NodeAnnouncement([] { return std::string("button"); }, false, kinds::kRole)};
    };
    return t;
  }();
  return type;
}

}  // namespace

TEST_CASE("entry from nothing reads the full chain") {
  Arena a;
  GraphNode* options = a.context("Options");
  GraphNode* list = a.context("Difficulty settings", "list", options);
  GraphNode* node = a.node("Normal, radio button, selected", list);

  CHECK(spoken(GraphAnnouncer::compose_full(node)) ==
        "Options, Difficulty settings, list, Normal, radio button, selected");
}

TEST_CASE("a sibling move reads the leaf only") {
  Arena a;
  GraphNode* list = a.context("Difficulty settings", "list");
  GraphNode* from = a.node("Easy", list);
  GraphNode* to = a.node("Hard", list);

  CHECK(spoken(GraphAnnouncer::compose(from, to)) == "Hard");
}

TEST_CASE("entering a nested context reads the entered levels") {
  Arena a;
  GraphNode* outer = a.context("Options");
  GraphNode* from = a.node("Back", outer);
  GraphNode* list = a.context("Difficulty settings", "list", outer);
  GraphNode* to = a.node("Normal", list);

  CHECK(spoken(GraphAnnouncer::compose(from, to)) == "Difficulty settings, list, Normal");
}

TEST_CASE("an ascend reads the leaf only") {
  Arena a;
  GraphNode* outer = a.context("Options");
  GraphNode* list = a.context("Difficulty settings", "list", outer);
  GraphNode* from = a.node("Normal", list);
  GraphNode* to = a.node("Back", outer);

  CHECK(spoken(GraphAnnouncer::compose(from, to)) == "Back");
}

TEST_CASE("descending from a group onto its child reads the child only") {
  // The group is ON the child's chain AND is the from-node: the prefix swallows it -- the old retained-
  // path behavior (stepping into your own group never re-announces the group).
  Arena a;
  GraphNode* group = a.node("Combat");
  group->expandable = true;
  group->expanded = true;
  GraphNode* child = a.node("Auto pause on combat start, toggle, on", group);

  CHECK(spoken(GraphAnnouncer::compose(group, child)) == "Auto pause on combat start, toggle, on");
}

TEST_CASE("entering a group from outside reads the group") {
  Arena a;
  GraphNode* group = a.node("Combat");
  group->expandable = true;
  group->expanded = true;
  GraphNode* child = a.node("Auto pause on combat start, toggle, on", group);
  GraphNode* elsewhere = a.node("Tabs");

  CHECK(spoken(GraphAnnouncer::compose(elsewhere, child)) ==
        "Combat, Auto pause on combat start, toggle, on");
}

TEST_CASE("the expanded state word appends to groups") {
  Arena a;
  GraphNode* group = a.node("Combat");
  group->expandable = true;
  group->expanded = false;
  ScopedHooks hooks;
  GraphAnnouncer::expanded_state_text = [](bool e) { return std::string(e ? "expanded" : "collapsed"); };
  CHECK(spoken(GraphAnnouncer::compose_full(group)) == "Combat, collapsed");
  group->expanded = true;
  CHECK(spoken(GraphAnnouncer::compose_full(group)) == "Combat, expanded");
  group->vtable->speaks_own_expansion = true;  // adapter nodes carry their own state word
  CHECK(spoken(GraphAnnouncer::compose_full(group)) == "Combat");
}

TEST_CASE("a duplicate container label is skipped") {
  // A "Game difficulty" section wrapping the "Game difficulty" control: the section stays silent.
  Arena a;
  GraphNode* section = a.context("Game difficulty");
  GraphNode* to = a.node("Game difficulty, menu button", section);
  CHECK(spoken(GraphAnnouncer::compose_full(to)) == "Game difficulty, menu button");

  // But a control that merely STARTS with different text keeps its container.
  Arena b;
  GraphNode* other = b.node("Game difficulty presets, menu button", b.context("Game difficulty"));
  CHECK(spoken(GraphAnnouncer::compose_full(other)) ==
        "Game difficulty, Game difficulty presets, menu button");
}

TEST_CASE("a control type supplies the role and the ordering") {
  // Parts declared out of order -- the type's kind order sorts them; the common role merges in.
  Arena a;
  GraphNode* node = a.typed(&test_button(),
                            {NodeAnnouncement([] { return std::string("on"); }, false, kinds::kValue),
                             NodeAnnouncement([] { return std::string("Hold position"); }, false,
                                              kinds::kLabel)});

  CHECK(spoken(GraphAnnouncer::compose_full(node)) == "Hold position, button, on");
}

TEST_CASE("a node part overrides a common part of the same kind") {
  Arena a;
  GraphNode* node =
      a.typed(&test_button(),
              {NodeAnnouncement([] { return std::string("Continue"); }, false, kinds::kLabel),
               NodeAnnouncement([] { return std::string("menu button"); }, false, kinds::kRole)});

  CHECK(spoken(GraphAnnouncer::compose_full(node)) == "Continue, menu button");
}

TEST_CASE("kindless parts keep declaration order after the known kinds") {
  Arena a;
  GraphNode* node =
      a.typed(&test_button(),
              {NodeAnnouncement([] { return std::string("custom one"); }),
               NodeAnnouncement([] { return std::string("Continue"); }, false, kinds::kLabel),
               NodeAnnouncement([] { return std::string("custom two"); })});

  CHECK(spoken(GraphAnnouncer::compose_full(node)) == "Continue, button, custom one, custom two");
}

TEST_CASE("the part filter drops parts") {
  Arena a;
  GraphNode* node = a.typed(
      &test_button(), {NodeAnnouncement([] { return std::string("Continue"); }, false, kinds::kLabel)});
  ScopedHooks hooks;
  GraphAnnouncer::part_filter = [](const ControlType*, const NodeAnnouncement& part) {
    return std::string_view(part.kind) != kinds::kRole;
  };
  CHECK(spoken(GraphAnnouncer::compose_full(node)) == "Continue");
}

TEST_CASE("leaf text joins the announcement parts") {
  Arena a;
  GraphNode* node = a.custom("x", {
                                      NodeAnnouncement::fixed("Hold position"),
                                      NodeAnnouncement::fixed("toggle"),
                                      NodeAnnouncement([] { return std::string("on"); }, true),
                                      NodeAnnouncement([] { return std::string(); }),  // silent
                                  });
  CHECK(spoken(GraphAnnouncer::compose_full(node)) == "Hold position, toggle, on");
}

TEST_CASE("the transition label leads") {
  Arena a;
  GraphNode* from = a.node("A");
  GraphNode* to = a.node("B");
  CHECK(spoken(GraphAnnouncer::compose(from, to, "next column")) == "next column, B");
}

TEST_CASE("a context change at the same depth reads the new level") {
  Arena a;
  GraphNode* from = a.node("Fireball", a.context("Level 1 spells", "table"));
  GraphNode* to = a.node("Haste", a.context("Level 2 spells", "table"));

  CHECK(spoken(GraphAnnouncer::compose(from, to)) == "Level 2 spells, table, Haste");
}
