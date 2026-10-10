#include "screens/dialogs.h"
#include <format>
#include <optional>
#include <string>
#include <vector>
#include "agui.h"
#include "app.h"
#include "game.h"
#include "input.h"
#include "log.h"
#include "speech.h"
#include "ui/graph_builder.h"
#include "ui/rich_text.h"
#include "ui/strings.h"

namespace fa::screens {
using namespace fa::ui;
namespace {

// A widget's address in the tree: one step per level, "c<i>" a public child, "p<i>" a private one, joined
// with '.'. Node closures hold paths, never widget pointers: a pointer read in one frame may be freed by the next.
using Path = std::string;

agui::Widget* resolve(const Path& path) {
  agui::Widget* w = agui::root();
  size_t i = 0;
  while (w && i < path.size()) {
    size_t dot = path.find('.', i);
    if (dot == std::string::npos) dot = path.size();
    bool priv = path[i] == 'p';
    size_t idx = std::stoul(path.substr(i + 1, dot - i - 1));
    auto kids = priv ? agui::private_children(w) : agui::children(w);
    w = idx < kids.size() ? kids[idx] : nullptr;
    i = dot + 1;
  }
  return w;
}

Path child_path(const Path& parent, bool priv, size_t index) {
  return (parent.empty() ? "" : parent + ".") + (priv ? "p" : "c") + std::to_string(index);
}

std::string plain(const std::string& s) { return strip_rich_text(s); }

enum class Kind { Container, Skip, Label, Button, CheckBox, Radio, DropDown, TextField, Tab, Slider };

Kind classify(agui::Widget* w) {
  // Most specific first: a CheckBox is also a Button.
  if (agui::is_a(w, "agui::ScrollBar")) return Kind::Skip;
  if (agui::is_a(w, "agui::CheckBox")) return Kind::CheckBox;
  if (agui::is_a(w, "agui::RadioButton")) return Kind::Radio;
  if (agui::is_a(w, "agui::DropDown")) return Kind::DropDown;
  if (agui::is_a(w, "agui::TextField")) return Kind::TextField;
  if (agui::is_a(w, "agui::Tab")) return Kind::Tab;
  if (agui::is_a(w, "agui::Slider")) return Kind::Slider;
  if (agui::is_a(w, "agui::Button")) return Kind::Button;
  if (agui::is_a(w, "agui::Label") || agui::is_a(w, "agui::TextBox")) return Kind::Label;
  return Kind::Container;
}

const ControlType kLabelType{"label", {"label"}, {}};
ControlType role_type(std::string key, std::string_view role) {
  return ControlType{key, {"label", "role", "value", "selected", "enabled", "position"},
                     [r = std::string(role)] { return std::vector<NodeAnnouncement>{NodeAnnouncement([r] { return r; }, false, announcement_kinds::kRole)}; }};
}
const ControlType kButtonType = role_type("button", strings::kButton);
const ControlType kCheckType = role_type("checkbox", strings::kCheckbox);
const ControlType kRadioType = role_type("radio", "radio button");
const ControlType kDropdownType = role_type("dropdown", strings::kDropdown);
const ControlType kTextType = role_type("edit", strings::kTextField);
const ControlType kTabType = role_type("tab", strings::kTab);
const ControlType kSliderType = role_type("slider", strings::kSlider);

// The spoken label of a control: its caption, else its tooltip's first line (icon buttons have no caption).
std::string label_of(agui::Widget* w) {
  std::string t = plain(agui::text(w));
  if (!t.empty()) return t;
  std::string tip = plain(agui::tooltip(w));
  return tip.substr(0, tip.find('\n'));
}

struct Entry {
  Path path;
  Kind kind;
};
using Row = std::vector<Entry>;

// Decorations: the background image, the logo, the version label, empty placeholder windows.
bool is_dialog(agui::Widget* w) {
  if (!agui::visible(w)) return false;
  if (agui::is_a(w, "agui::ImageWidget") || agui::is_a(w, "agui::Label")) return false;
  auto r = agui::rect(w);
  return r.w > 0 && r.h > 0;
}

class Walker {
 public:
  std::vector<Row> rows;
  Path title_path;

  void walk(agui::Widget* w, const Path& path, bool in_row) {
    auto visit = [&](bool priv) {
      auto kids = priv ? agui::private_children(w) : agui::children(w);
      for (size_t i = 0; i < kids.size(); ++i) {
        agui::Widget* c = kids[i];
        if (!agui::visible(c)) continue;
        Path p = child_path(path, priv, i);
        Kind k = classify(c);
        if (k == Kind::Skip) continue;
        if (k == Kind::Container) {
          bool row = !in_row && (agui::is_a(c, "agui::HorizontalFlow") || agui::is_a(c, "agui::Table"));
          if (row) rows.emplace_back();
          walk(c, p, in_row || row);
          if (row && rows.back().empty()) rows.pop_back();
          continue;
        }
        if (k == Kind::Label) {
          if (plain(agui::text(c)).empty()) continue;
          if (title_path.empty()) {
            title_path = p;  // the first label is the dialog's title: spoken as the stop's context, not as a row
            continue;
          }
        }
        if (!in_row) rows.emplace_back();
        rows.back().push_back({p, k});
      }
    };
    visit(false);
    visit(true);
  }
};

NodeVtablePtr make_node(const Entry& e, std::function<void(const Path&)> start_editing) {
  auto v = std::make_shared<NodeVtable>();
  Path p = e.path;
  auto label = [p] {
    agui::Widget* w = resolve(p);
    return w ? label_of(w) : std::string();
  };
  auto disabled = [p] {
    agui::Widget* w = resolve(p);
    return w && !agui::enabled(w) ? std::string(strings::kDisabled) : std::string();
  };
  v->announcements = {NodeAnnouncement(label, false, announcement_kinds::kLabel), NodeAnnouncement(disabled, true, announcement_kinds::kEnabled)};
  auto tip = [p] {
    agui::Widget* w = resolve(p);
    std::string t = w ? plain(agui::tooltip(w)) : std::string();
    speech::speak(t.empty() ? std::string(strings::kNoTooltip) : t, true);
  };
  auto click = [p] {
    agui::Widget* w = resolve(p);
    if (!w) return;
    if (!agui::enabled(w)) {
      speech::speak(strings::kDisabled, true);
      return;
    }
    agui::click(w);
  };
  switch (e.kind) {
    case Kind::Label:
      v->control_type = &kLabelType;
      v->announcements.resize(1);
      return v;
    case Kind::Button: v->control_type = &kButtonType; break;
    case Kind::Tab: v->control_type = &kTabType; break;
    case Kind::Slider: v->control_type = &kSliderType; break;
    case Kind::Radio:
    case Kind::CheckBox: {
      v->control_type = e.kind == Kind::Radio ? &kRadioType : &kCheckType;
      auto state = [p] {
        agui::Widget* w = resolve(p);
        return w ? std::string(agui::toggled(w) ? strings::kChecked : strings::kUnchecked) : std::string();
      };
      v->announcements.push_back(NodeAnnouncement(state, true, announcement_kinds::kValue));
      v->state_text = state;
      break;
    }
    case Kind::DropDown:
      // The caption of a dropdown is its selected item: speak it as the value, without a separate label.
      v->control_type = &kDropdownType;
      v->announcements[0].kind = std::string(announcement_kinds::kValue);
      v->announcements[0].live = true;
      break;
    case Kind::TextField:
      v->control_type = &kTextType;
      v->announcements[0].kind = std::string(announcement_kinds::kValue);
      v->announcements[0].live = true;
      v->on_activate = [p, start_editing] { start_editing(p); };
      v->on_tooltip = tip;
      return v;
    default: break;
  }
  v->on_activate = click;
  v->on_tooltip = tip;
  return v;
}

class DialogsScreen : public Screen {
 public:
  std::string_view key() const override { return "dialogs"; }

  bool is_active() override {
    if (game::in_game()) return false;
    return !dialogs().empty();
  }

  std::string screen_name() const override { return {}; }  // each dialog announces itself when it comes up

  bool owns_keyboard() const override { return editing_.empty(); }

  std::vector<ScreenAction> actions() override {
    return {{std::string(action_ids::Back), [this] { back(); }}};
  }

  void build(GraphBuilder& b) override {
    auto ds = dialogs();
    std::optional<ControlId> start;
    for (size_t i = 0; i < ds.size(); ++i) {
      Walker walker;
      walker.walk(ds[i].second, ds[i].first, false);
      if (walker.rows.empty()) continue;
      b.begin_stop(Key(stop_key(ds[i])));
      std::string title;
      if (agui::Widget* t = resolve(walker.title_path)) title = plain(agui::text(t));
      if (!title.empty()) b.push_context(title);
      for (const Row& row : walker.rows) {
        if (row.size() > 1) b.start_row();
        for (const Entry& e : row) {
          ControlId id = ControlId::structural(Key(e.path));
          b.add_item(id, make_node(e, [this](const Path& p) { start_editing(p); }));
          if (i + 1 == ds.size() && !start && e.kind != Kind::Label) start = id;
        }
        if (row.size() > 1) b.end_row();
      }
      if (!title.empty()) b.pop_context();
    }
    if (start) b.set_start(*start);
  }

  void on_update() override {
    if (!editing_.empty()) {
      tick_editing();
      return;
    }
    // A new dialog on top (the game opened one, or one closed): land on it and say its title.
    auto ds = dialogs();
    std::string top = ds.empty() ? std::string() : stop_key(ds.back());
    if (top != top_) {
      bool first = top_.empty();
      top_ = top;
      if (!first && !top.empty()) app::focus_stop(Key(top));
    }
  }

 private:
  std::string editing_;  // path of the text field the game is typing into; empty = the native UI has the keyboard
  std::string top_;

  using Dialog = std::pair<Path, agui::Widget*>;
  static std::vector<Dialog> dialogs() {
    std::vector<Dialog> out;
    agui::Widget* root = agui::root();
    if (!root) return out;
    auto kids = agui::children(root);
    for (size_t i = 0; i < kids.size(); ++i)
      if (is_dialog(kids[i])) out.push_back({child_path("", false, i), kids[i]});
    return out;
  }
  static std::string stop_key(const Dialog& d) { return d.first + ":" + agui::class_name(d.second); }

  void back() {
    auto ds = dialogs();
    if (ds.empty()) return;
    // The dialog's own Back (or Exit) button, by style: back_button, red_back_button, ...
    std::function<agui::Widget*(agui::Widget*)> find = [&](agui::Widget* w) -> agui::Widget* {
      for (bool priv : {false, true})
        for (auto* c : priv ? agui::private_children(w) : agui::children(w)) {
          if (!agui::visible(c)) continue;
          if (agui::is_a(c, "agui::Button") && agui::enabled(c) && agui::style_name(c).ends_with("back_button")) return c;
          if (auto* r = find(c)) return r;
        }
      return nullptr;
    };
    if (agui::Widget* b = find(ds.back().second)) agui::click(b);
  }

  void start_editing(const Path& p) {
    agui::Widget* w = resolve(p);
    if (!w || !agui::enabled(w)) return;
    agui::focus(w);
    editing_ = p;
    MessageBuilder m;
    m.fragment("editing").list_item().fragment("enter or escape to finish");
    speech::speak(m.build(), true);
    log::writef("dialogs: editing {}", p);
  }

  // While editing, the game has the keyboard; we only watch for the keys that end it.
  void tick_editing() {
    const KeySource& ks = input::key_source();
    agui::Widget* w = resolve(editing_);
    bool done = !w || ks.just_pressed(input::sc::Enter) || ks.just_pressed(input::sc::Escape) || ks.just_pressed(input::sc::Tab);
    if (!done) return;
    std::string value = w ? plain(agui::text(w)) : std::string();
    editing_.clear();
    log::write("dialogs: editing done");
    speech::speak(value.empty() ? std::string("blank") : value, true);
  }
};
}  // namespace

std::unique_ptr<Screen> make_dialogs() { return std::make_unique<DialogsScreen>(); }
}  // namespace fa::screens
