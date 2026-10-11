#include "screens/dialogs.h"
#include <algorithm>
#include <chrono>
#include <cmath>
#include <cstdlib>
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

// A widget's address: "<dialog key>|<steps>". The dialog key is the top-level dialog's class and its
// occurrence among visible dialogs of that class ("MainMenuGui#0"), so it survives other top-level widgets
// coming and going. Each step is "c<i>" (a public child) or "p<i>" (a private one), joined with '.'. Node
// closures hold paths, never widget pointers: a pointer read in one frame may be freed by the next.
using Path = std::string;

// Decorations: the background image, the logo, the version label, empty placeholder windows.
bool is_dialog(agui::Widget* w) {
  if (!agui::visible(w)) return false;
  if (agui::is_a(w, "agui::ImageWidget") || agui::is_a(w, "agui::Label")) return false;
  auto r = agui::rect(w);
  return r.w > 0 && r.h > 0;
}

struct Dialog {
  std::string key;
  agui::Widget* widget;
};
// The visible top-level dialogs, bottom to top.
std::vector<Dialog> dialogs() {
  std::vector<Dialog> out;
  agui::Widget* root = agui::root();
  if (!root) return out;
  for (agui::Widget* w : agui::children(root)) {
    if (!is_dialog(w)) continue;
    std::string cls = agui::class_name(w);
    int n = 0;
    for (auto& d : out)
      if (d.key.starts_with(cls + "#")) ++n;
    out.push_back({std::format("{}#{}", cls, n), w});
  }
  return out;
}

// The dialog the player is in: the topmost real window. Overlays drawn in an invisible frame (the main
// menu's language selector sits above the menu in z-order) only win when nothing else is open.
const Dialog* top_dialog(const std::vector<Dialog>& ds) {
  for (size_t i = ds.size(); i-- > 0;)
    if (agui::style_name(ds[i].widget) != "invisible_frame") return &ds[i];
  return ds.empty() ? nullptr : &ds.back();
}

agui::Widget* resolve(const Path& full) {
  size_t bar = full.find('|');
  if (bar == std::string::npos) return nullptr;
  std::string key = full.substr(0, bar);
  agui::Widget* w = nullptr;
  for (auto& d : dialogs())
    if (d.key == key) w = d.widget;
  std::string path = full.substr(bar + 1);
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
  return parent + (parent.ends_with("|") ? "" : ".") + (priv ? "p" : "c") + std::to_string(index);
}

// Speech text from a game caption: no rich-text markup, and no list bullet ("• Freeplay" reads "bullet Freeplay").
std::string plain(const std::string& s) {
  std::string t = strip_rich_text(s);
  static const std::string kBullet = "\xE2\x80\xA2";  // U+2022
  if (t.starts_with(kBullet)) t = strip_rich_text(t.substr(kBullet.size()));
  return t;
}

enum class Kind { Container, Skip, Label, Button, CheckBox, Radio, DropDown, TextField, Tab, Slider, ModRow };

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
const ControlType kModRowType{"mod", {"label", "value", "enabled", "position"}, {}};

// The spoken label of a control: its caption, else its tooltip's first line (icon buttons have no caption).
std::string label_of(agui::Widget* w) {
  std::string t = plain(agui::text(w));
  if (!t.empty()) return t;
  std::string tip = plain(agui::tooltip(w));
  return tip.substr(0, tip.find('\n'));
}

// A label used to name the control after it: "Seed" for the seed field, "Version:" before a dropdown.
std::string as_label(const std::string& s) {
  std::string t = s;
  while (!t.empty() && (t.back() == ':' || t.back() == ' ')) t.pop_back();
  return t;
}

bool is_control(Kind k) { return k != Kind::Container && k != Kind::Skip && k != Kind::Label; }
// Controls whose caption is their value, so they need a name from elsewhere (a label beside them, a table header).
bool needs_name(Kind k) { return k == Kind::TextField || k == Kind::DropDown || k == Kind::Slider; }

struct Entry {
  Path path;
  Kind kind;
  std::string name;  // composed by the walker (a neighbouring label, table headers); empty = the widget's own
  // A slider's companion text field, whose text is the readable value ("10 min" for 36000 ticks); a label's value
  // beside it in a two-column table of labels ("Version" and "2.1.21").
  Path value_path;
  // A mod row: the labels it reads (name, version), and its row in the selection table.
  std::vector<Path> text_paths;
  Path table_path;
  int table_row = -1;
};
struct Row {
  std::vector<Entry> cells;
  std::string key;      // shared by the rows of one table: up and down keep the column
  std::string context;  // the row's own label ("Move up" before its key buttons): said when focus enters the row
  int section = 0;      // the panel it is in, when a list and its details sit side by side (see Walker)
};

// Visible controls (non-containers) under `w`, counting up to `limit`.
int count_controls(agui::Widget* w, int limit) {
  int n = 0;
  for (bool priv : {false, true})
    for (agui::Widget* c : priv ? agui::private_children(w) : agui::children(w)) {
      if (n >= limit) return n;
      if (!agui::visible(c)) continue;
      Kind k = classify(c);
      if (k == Kind::Skip) continue;
      n += k == Kind::Container ? count_controls(c, limit - n) : 1;
    }
  return n;
}

bool cells_are_single(agui::Widget* w) {
  for (bool priv : {false, true})
    for (agui::Widget* c : priv ? agui::private_children(w) : agui::children(w))
      if (agui::visible(c) && classify(c) == Kind::Container && count_controls(c, 2) > 1) return false;
  return true;
}

bool contains_selection_table(agui::Widget* w) {
  if (agui::is_selection_table(w)) return true;
  for (bool priv : {false, true})
    for (agui::Widget* c : priv ? agui::private_children(w) : agui::children(w))
      if (agui::visible(c) && contains_selection_table(c)) return true;
  return false;
}

// The first non-empty label in a table cell.
Path first_label(agui::Widget* w, const Path& path) {
  if (!agui::visible(w)) return {};
  if (agui::is_a(w, "agui::Label") || agui::is_a(w, "agui::TextBox")) return plain(agui::text(w)).empty() ? Path() : path;
  for (bool priv : {false, true}) {
    auto kids = priv ? agui::private_children(w) : agui::children(w);
    for (size_t i = 0; i < kids.size(); ++i)
      if (Path p = first_label(kids[i], child_path(path, priv, i)); !p.empty()) return p;
  }
  return {};
}

std::string join_name(const std::string& a, const std::string& b) {
  if (a.empty()) return b;
  if (b.empty()) return a;
  MessageBuilder m;
  m.fragment(a).list_item().fragment(b);
  return m.build();
}

class Walker {
 public:
  std::vector<Row> rows;
  Path title_path;

  // After walk(): a label alone on its row names the unnamed control on the row below it ("Preferred screen"
  // over its dropdown) and stops being a node; then sliders pair with their value fields. A label followed by
  // controls that carry their own names (a section heading over checkboxes) stays.
  void finish() {
    for (size_t i = 0; i + 1 < rows.size(); ++i) {
      Row& above = rows[i];
      Row& below = rows[i + 1];
      if (above.cells.size() != 1 || above.cells[0].kind != Kind::Label || below.cells.empty()) continue;
      Entry& first = below.cells[0];
      if (!needs_name(first.kind) || !first.name.empty()) continue;
      agui::Widget* w = resolve(above.cells[0].path);
      first.name = w ? as_label(plain(agui::text(w))) : std::string();
      rows.erase(rows.begin() + (long long)i);
      --i;
    }
    for (Row& row : rows) pair_sliders(row);
  }

  // `split`: w holds panels side by side around a selection list (the mods list beside the selected mod's details).
  // Each panel's rows get a section of their own, and so does what follows, so the dialog can make each a Tab stop.
  void walk(agui::Widget* w, const Path& path, bool in_row, bool split = false) {
    auto visit = [&](bool priv) {
      auto kids = priv ? agui::private_children(w) : agui::children(w);
      for (size_t i = 0; i < kids.size(); ++i) {
        agui::Widget* c = kids[i];
        if (!agui::visible(c)) continue;
        Path p = child_path(path, priv, i);
        Kind k = classify(c);
        if (k == Kind::Skip) continue;
        if (split) section_ = ++sections_;
        if (k == Kind::Container) {
          if (!in_row && agui::is_a(c, "agui::Table") && agui::table_columns(c) > 1) {
            grid(c, p);
            continue;
          }
          // A horizontal flow or table is a row when each of its cells holds at most one control (a button
          // bar, a tab strip, "label: dropdown"). One holding whole panels side by side (a list beside its
          // details) is columns: each column is walked on its own, top to bottom.
          bool flow = agui::is_a(c, "agui::HorizontalFlow") || agui::is_a(c, "agui::Table");
          bool row = !in_row && flow && cells_are_single(c);
          bool columns = !in_row && flow && !row && contains_selection_table(c);
          if (row) new_row();
          walk(c, p, in_row || row, columns);
          if (row) {
            name_from_labels(rows.back());
            if (rows.back().cells.empty()) rows.pop_back();
          }
          continue;
        }
        if (!keep(c, k, p)) continue;
        if (!in_row) new_row();
        rows.back().cells.push_back({p, k, {}});
      }
    };
    visit(false);
    visit(true);
    if (split) section_ = ++sections_;
  }

 private:
  // Whether a leaf becomes a node. The dialog's first label is its title (the stop's context, not a row); a
  // control with neither caption nor tooltip (a bare icon button) has nothing to say. A dropdown's or text
  // field's caption is its value, which may legitimately be empty.
  int section_ = 0, sections_ = 0;

  void new_row() {
    rows.emplace_back();
    rows.back().section = section_;
  }

  bool keep(agui::Widget* c, Kind k, const Path& p) {
    if ((k == Kind::Button || k == Kind::Tab || k == Kind::CheckBox || k == Kind::Radio) && label_of(c).empty()) return false;
    if (k == Kind::Label) {
      if (plain(agui::text(c)).empty()) return false;
      if (title_path.empty()) {
        title_path = p;
        return false;
      }
    }
    return true;
  }

  // In a row, a label directly before a field, dropdown or slider names it ("Seed" + the seed field) instead of
  // being a stop of its own.
  static void name_from_labels(Row& row) {
    for (size_t i = 0; i + 1 < row.cells.size(); ++i) {
      Entry& label = row.cells[i];
      Entry& next = row.cells[i + 1];
      if (label.kind != Kind::Label || !needs_name(next.kind) || !next.name.empty()) continue;
      agui::Widget* w = resolve(label.path);
      next.name = w ? as_label(plain(agui::text(w))) : std::string();
      row.cells.erase(row.cells.begin() + (long long)i);
    }
    // A label leading a row of controls that name themselves ("Move up" + its key buttons, "Input method" + its
    // radio buttons) is the row's context rather than a stop of its own.
    if (row.cells.size() > 1 && row.cells[0].kind == Kind::Label) {
      bool all_controls = true;
      for (size_t i = 1; i < row.cells.size(); ++i) all_controls &= is_control(row.cells[i].kind);
      if (all_controls) {
        agui::Widget* w = resolve(row.cells[0].path);
        row.context = w ? as_label(plain(agui::text(w))) : std::string();
        row.cells.erase(row.cells.begin());
      }
    }
    // A checkbox that switches the thing a slider sets ("Game effects" before its volume slider) also names it.
    for (size_t i = 0; i + 1 < row.cells.size(); ++i) {
      Entry& toggle = row.cells[i];
      Entry& next = row.cells[i + 1];
      if ((toggle.kind != Kind::CheckBox && toggle.kind != Kind::Radio) || !needs_name(next.kind) || !next.name.empty()) continue;
      agui::Widget* w = resolve(toggle.path);
      next.name = w ? as_label(label_of(w)) : std::string();
    }
  }

  // A slider with a text field beside it (the game's "slider + exact value" pair): the field's text is the
  // slider's readable value, and the field shares the slider's name.
  static void pair_sliders(Row& row) {
    for (size_t i = 0; i + 1 < row.cells.size(); ++i) {
      Entry& slider = row.cells[i];
      Entry& field = row.cells[i + 1];
      if (slider.kind != Kind::Slider || field.kind != Kind::TextField) continue;
      slider.value_path = field.path;
      if (field.name.empty()) field.name = slider.name;
    }
  }

  // The controls inside one table cell (a cell can be a flow holding several).
  void collect(agui::Widget* w, const Path& path, std::vector<Entry>& out) {
    Kind k = classify(w);
    if (k == Kind::Skip || !agui::visible(w)) return;
    if (k != Kind::Container) {
      if (k == Kind::Label ? !plain(agui::text(w)).empty() : keep(w, k, path)) out.push_back({path, k, {}});
      return;
    }
    for (bool priv : {false, true}) {
      auto kids = priv ? agui::private_children(w) : agui::children(w);
      for (size_t i = 0; i < kids.size(); ++i) collect(kids[i], child_path(path, priv, i), out);
    }
  }

  // A table with columns: its visible children are cells, row by row. The first row is column headers when the
  // table says so or it holds nothing but labels. Each data row's first cell names the row; a control without a
  // name of its own is named "<row>, <column>" ("Iron ore, Frequency").
  void grid(agui::Widget* table, const Path& path) {
    int columns = agui::table_columns(table);
    std::vector<std::pair<agui::Widget*, Path>> cells;
    auto kids = agui::children(table);
    for (size_t i = 0; i < kids.size(); ++i)
      if (agui::visible(kids[i])) cells.push_back({kids[i], child_path(path, false, i)});
    if (mod_rows(table, path, columns, cells) || key_values(columns, cells)) return;
    size_t first = 0;
    std::vector<std::string> headers(columns);
    bool header_row = agui::table_has_headers(table);
    if (!header_row && (int)cells.size() > columns) {
      header_row = true;
      for (int j = 0; j < columns; ++j)
        if (is_control(classify(cells[j].first)) || count_controls(cells[j].first, 1) > 0) header_row = false;
    }
    if (header_row) {
      for (int j = 0; j < columns && j < (int)cells.size(); ++j) headers[j] = as_label(plain(agui::text(cells[j].first)));
      first = columns;
    }
    for (size_t r = first; r < cells.size(); r += columns) {
      Row row;
      row.key = path;
      std::string row_name;
      if (Path l = first_label(cells[r].first, cells[r].second); !l.empty())
        if (agui::Widget* lw = resolve(l)) row_name = as_label(plain(agui::text(lw)));
      bool label_names_row = false, name_used = false;
      for (int j = 0; j < columns && r + j < cells.size(); ++j) {
        std::vector<Entry> found;
        collect(cells[r + j].first, cells[r + j].second, found);
        for (Entry& e : found) {
          agui::Widget* w = resolve(e.path);
          if (j == 0 && row_name.empty() && w) row_name = as_label(label_of(w));
          // A label in the first column only names the row.
          if (j == 0 && e.kind == Kind::Label && columns > 1) {
            label_names_row = true;
            continue;
          }
          if (needs_name(e.kind) || (w && label_of(w).empty())) {
            e.name = join_name(row_name, headers[j]);
            name_used = true;
          }
          row.cells.push_back(e);
        }
      }
      // Controls that name themselves ("Keep enabled" beside a mod in the sync-mods table) still need the row's
      // name: it becomes the row's context, said when focus enters the row.
      if (label_names_row && !name_used) row.context = row_name;
      row.section = section_;
      if (!row.cells.empty()) rows.push_back(std::move(row));
    }
  }

  // The mods list: each mod is one node reading "<name> <version>, enabled" instead of a checkbox and two labels.
  bool mod_rows(agui::Widget* table, const Path& path, int columns, const std::vector<std::pair<agui::Widget*, Path>>& cells) {
    if (!path.starts_with("ModsGui#") || !agui::is_selection_table(table)) return false;
    size_t first = agui::table_has_headers(table) ? (size_t)columns : 0;
    for (size_t r = first; r < cells.size(); r += columns) {
      Entry e{{}, Kind::ModRow, {}};
      for (int j = 0; j < columns && r + j < cells.size(); ++j) {
        auto& [w, p] = cells[r + j];
        if (classify(w) == Kind::CheckBox) e.path = p;
        else if (Path l = first_label(w, p); !l.empty()) e.text_paths.push_back(l);
      }
      if (e.text_paths.empty()) continue;
      e.table_path = path;
      e.table_row = (int)(r / columns);
      new_row();
      rows.back().cells.push_back(std::move(e));
    }
    return true;
  }

  // A table of nothing but labels in two columns (the selected mod's "Version" and "2.1.21"): each row is one node
  // reading the pair.
  bool key_values(int columns, const std::vector<std::pair<agui::Widget*, Path>>& cells) {
    if (columns != 2 || cells.size() < 2) return false;
    for (auto& [w, p] : cells) {
      if (is_control(classify(w))) return false;
      std::vector<Entry> found;
      collect(w, p, found);
      for (auto& f : found)
        if (f.kind != Kind::Label) return false;
    }
    for (size_t r = 0; r + 1 < cells.size(); r += 2) {
      Path key = first_label(cells[r].first, cells[r].second);
      Path value = first_label(cells[r + 1].first, cells[r + 1].second);
      if (key.empty() && value.empty()) continue;
      Entry e{key.empty() ? value : key, Kind::Label, {}};
      if (!key.empty()) e.value_path = value;
      new_row();
      rows.back().cells.push_back(std::move(e));
    }
    return true;
  }
};

// Text a button carries besides its caption: labels inside it (a save row's "3 months ago").
std::string inner_labels(agui::Widget* w, const std::string& caption) {
  MessageBuilder m;
  std::function<void(agui::Widget*)> visit = [&](agui::Widget* c) {
    if (!agui::visible(c)) return;
    if (agui::is_a(c, "agui::Label")) {
      std::string t = plain(agui::text(c));
      if (!t.empty() && t != caption) m.list_item().fragment(t);
      return;
    }
    for (bool priv : {false, true})
      for (agui::Widget* g : priv ? agui::private_children(c) : agui::children(c)) visit(g);
  };
  for (bool priv : {false, true})
    for (agui::Widget* c : priv ? agui::private_children(w) : agui::children(w)) visit(c);
  return m.build();
}

// The readable value of a slider: the game's own text for the current notch when it has one, else the number.
std::string slider_text(agui::Widget* w) {
  std::string notch = plain(agui::slider_notch_text(w));
  if (!notch.empty()) return notch;
  std::string n = std::format("{:.2f}", agui::slider_value(w));
  while (n.ends_with('0')) n.pop_back();
  if (n.ends_with('.')) n.pop_back();
  return n;
}

struct Editors {
  std::function<void(const Path&)> text_field;  // lend the keyboard to the game's text field
  std::function<void(const Path&)> slider;      // take a typed value for a slider ourselves
};

NodeVtablePtr make_node(const Entry& e, const Editors& editors) {
  auto v = std::make_shared<NodeVtable>();
  Path p = e.path;
  std::string name = e.name;
  auto own = [p] {
    agui::Widget* w = resolve(p);
    return w ? label_of(w) : std::string();
  };
  auto disabled = [p] {
    agui::Widget* w = resolve(p);
    return w && !agui::enabled(w) ? std::string(strings::kDisabled) : std::string();
  };
  // A control whose caption is its value: the walker's name as the label, the caption as the live value.
  auto named_value = [&](std::function<std::string()> value) {
    v->announcements = {NodeAnnouncement([name] { return name; }, false, announcement_kinds::kLabel),
                        NodeAnnouncement(std::move(value), true, announcement_kinds::kValue),
                        NodeAnnouncement(disabled, true, announcement_kinds::kEnabled)};
  };
  auto label = name.empty() ? std::function<std::string()>(own) : std::function<std::string()>([name] { return name; });
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
      if (!e.value_path.empty()) {
        v->announcements[0] = NodeAnnouncement(
            [p, vp = e.value_path] {
              agui::Widget* k = resolve(p);
              agui::Widget* w = resolve(vp);
              return join_name(k ? as_label(plain(agui::text(k))) : std::string(), w ? plain(agui::text(w)) : std::string());
            },
            false, announcement_kinds::kLabel);
      }
      return v;
    case Kind::ModRow: {
      v->control_type = &kModRowType;
      auto text = [paths = e.text_paths] {
        std::string out;
        for (const Path& tp : paths)
          if (agui::Widget* w = resolve(tp)) {
            std::string t = plain(agui::text(w));
            if (!t.empty()) out += (out.empty() ? "" : " ") + t;
          }
        return out;
      };
      auto state = [p] {
        agui::Widget* w = p.empty() ? nullptr : resolve(p);
        if (!w) return std::string();
        return std::string(agui::checked(w) ? strings::kEnabled : strings::kDisabled);
      };
      v->announcements = {NodeAnnouncement(text, false, announcement_kinds::kLabel),
                          NodeAnnouncement(state, true, announcement_kinds::kValue)};
      v->state_text = state;
      v->search_text = text;
      // Landing on a mod selects it, so the details panel shows that mod.
      v->on_focus = [tp = e.table_path, row = e.table_row] {
        agui::Widget* t = resolve(tp);
        if (t && agui::table_selected_row(t) != row) agui::table_select_row(t, row);
      };
      v->on_activate = [p] {
        agui::Widget* w = p.empty() ? nullptr : resolve(p);
        if (!w) return;
        if (agui::enabled(w)) agui::toggle(w);
        else speech::speak(strings::kCannotChange, true);
      };
      return v;
    }
    case Kind::Button: {
      v->control_type = &kButtonType;
      // A row of a list: say whether it is the selected one.
      auto selected = [p] {
        agui::Widget* w = resolve(p);
        auto s = w ? agui::list_row_selected(w) : std::nullopt;
        return s && *s ? std::string(strings::kSelected) : std::string();
      };
      v->announcements.push_back(NodeAnnouncement(selected, true, announcement_kinds::kSelected));
      auto details = [p] {
        agui::Widget* w = resolve(p);
        return w ? inner_labels(w, label_of(w)) : std::string();
      };
      v->announcements.push_back(NodeAnnouncement(details, false, announcement_kinds::kValue));
      break;
    }
    case Kind::Tab: {
      v->control_type = &kTabType;
      auto selected = [p] {
        agui::Widget* w = resolve(p);
        return w && agui::tab_selected(w) ? std::string(strings::kSelected) : std::string();
      };
      v->announcements.push_back(NodeAnnouncement(selected, true, announcement_kinds::kSelected));
      // A tab strip is its own Tab stop; "row" there says nothing.
      v->speaks_own_position = true;
      break;
    }
    case Kind::Slider: {
      v->control_type = &kSliderType;
      auto value = [p, vp = e.value_path] {
        if (!vp.empty())
          if (agui::Widget* f = resolve(vp)) return plain(agui::text(f));
        agui::Widget* w = resolve(p);
        return w ? slider_text(w) : std::string();
      };
      named_value(value);
      // One notch per step (a tenth of the range when the slider is continuous); shift for five.
      v->on_adjust = [p](int sign, bool large) {
        agui::Widget* w = resolve(p);
        if (!w || !agui::enabled(w)) return;
        double lo = agui::slider_min(w), hi = agui::slider_max(w), step = agui::slider_step(w);
        if (step <= 0) step = (hi - lo) / 10;
        double next = agui::slider_value(w) + sign * step * (large ? 5 : 1);
        next = next < lo ? lo : next > hi ? hi : next;
        agui::slider_set(w, next);
      };
      v->state_text = value;
      v->on_tooltip = tip;
      // Enter types an exact value: into the game's own value field when the slider has one, else into ours.
      v->on_activate = [p, vp = e.value_path, editors] {
        if (!vp.empty()) editors.text_field(vp);
        else editors.slider(p);
      };
      return v;
    }
    case Kind::Radio:
    case Kind::CheckBox: {
      v->control_type = e.kind == Kind::Radio ? &kRadioType : &kCheckType;
      auto state = [p] {
        agui::Widget* w = resolve(p);
        return w ? std::string(agui::checked(w) ? strings::kChecked : strings::kUnchecked) : std::string();
      };
      v->announcements.push_back(NodeAnnouncement(state, true, announcement_kinds::kValue));
      v->state_text = state;
      v->on_activate = [p] {
        agui::Widget* w = resolve(p);
        if (w && agui::enabled(w)) agui::toggle(w);
        else if (w) speech::speak(strings::kDisabled, true);
      };
      v->on_tooltip = tip;
      return v;
    }
    case Kind::DropDown:
      // The caption of a dropdown is its selected item: its value. The game's popup list is never opened: left
      // and right pick the previous / next item directly.
      v->control_type = &kDropdownType;
      named_value(own);
      v->on_adjust = [p](int sign, bool large) {
        agui::Widget* w = resolve(p);
        if (!w || !agui::enabled(w)) return;
        int n = agui::dropdown_count(w), cur = agui::dropdown_selected(w);
        int next = cur + sign * (large ? 10 : 1);
        next = next < 0 ? 0 : next >= n ? n - 1 : next;
        if (next != cur) agui::dropdown_select(w, next);
      };
      v->state_text = own;
      v->on_tooltip = tip;
      return v;
    case Kind::TextField:
      v->control_type = &kTextType;
      named_value(own);
      v->on_activate = [p, editors] { editors.text_field(p); };
      v->on_tooltip = tip;
      return v;
    default: break;
  }
  v->on_activate = click;
  v->on_tooltip = tip;
  return v;
}

bool g_main_menu = false;

class DialogsScreen : public Screen {
 public:
  std::string_view key() const override { return "dialogs"; }

  bool is_active() override {
    // in_game() reads false for a moment while a loaded game switches surfaces or opens remote view, and the game's
    // own windows then look like dialogs. Only take over once the game has been out of a world for a while.
    auto now = std::chrono::steady_clock::now();
    if (game::in_game()) {
      last_in_game_ = now;
      return false;
    }
    if (last_in_game_ && now - *last_in_game_ < std::chrono::milliseconds(500)) return false;
    return !dialogs().empty();
  }

  std::string screen_name() const override { return {}; }  // each dialog announces itself when it comes up

  bool owns_keyboard() const override { return editing_.empty(); }
  bool wrap() const override { return true; }  // Tab from a dialog's last stop goes back to its first
  bool captures_raw_input() const override { return !entering_.empty(); }

  std::vector<ScreenAction> actions() override {
    return {{std::string(action_ids::Back), [this] { back(); }}};
  }

  void build(GraphBuilder& b) override {
    auto ds = dialogs();
    const Dialog* top = top_dialog(ds);
    std::optional<ControlId> start;
    for (size_t i = 0; i < ds.size(); ++i) {
      Walker walker;
      walker.walk(ds[i].widget, ds[i].key + "|", false);
      walker.finish();
      if (walker.rows.empty()) continue;
      auto stops = stop_keys(ds[i].key, walker.rows);
      std::string title;
      if (agui::Widget* t = resolve(walker.title_path)) title = plain(agui::text(t));
      if (!title.empty()) b.push_context(title);
      for (size_t r = 0; r < walker.rows.size(); ++r) {
        const Row& row = walker.rows[stops[r].first];
        if (r == 0 || stops[r].second != stops[r - 1].second) b.begin_stop(Key(stops[r].second));
        bool open_row = row.cells.size() > 1 || !row.key.empty();
        if (!row.context.empty()) b.push_context(row.context);
        if (open_row) b.start_row(row.key.empty() ? Key() : Key(row.key));
        for (const Entry& e : row.cells) {
          ControlId id = ControlId::structural(Key(e.path));
          b.add_item(id, make_node(e, Editors{[this](const Path& p) { start_editing(p); }, [this](const Path& p) { start_value_entry(p); }}));
          if (&ds[i] == top && !start && e.kind != Kind::Label) start = id;
        }
        if (open_row) b.end_row();
        if (!row.context.empty()) b.pop_context();
      }
      if (!title.empty()) b.pop_context();
    }
    if (start) b.set_start(*start);
  }

  // A dialog is one Tab stop, unless it has tabs: then its tab strip, the settings around it (one stop per panel when
  // a list and its details sit side by side) and its closing button bar are each a stop, in that order. Returns the
  // rows in stop order (a row's index and its stop key), each stop's rows in their own order. The first stop keeps
  // the dialog's own key, so a new dialog can be focused by it.
  static std::vector<std::pair<size_t, std::string>> stop_keys(const std::string& dialog, const std::vector<Row>& rows) {
    auto all_of = [](const Row& row, Kind k) {
      for (const Entry& e : row.cells)
        if (e.kind != k) return false;
      return !row.cells.empty();
    };
    bool tabbed = false;
    for (const Row& row : rows) tabbed |= all_of(row, Kind::Tab);
    std::vector<std::string> groups(rows.size());
    if (tabbed) {
      size_t buttons = rows.size();
      while (buttons > 0 && all_of(rows[buttons - 1], Kind::Button)) --buttons;
      for (size_t r = 0; r < rows.size(); ++r)
        groups[r] = r >= buttons ? "buttons" : all_of(rows[r], Kind::Tab) ? "tabs" : std::format("s{}", rows[r].section);
    }
    std::vector<std::string> order;
    auto add = [&](const std::string& g) {
      if (std::find(order.begin(), order.end(), g) == order.end()) order.push_back(g);
    };
    if (tabbed) add("tabs");
    for (const std::string& g : groups)
      if (g != "buttons") add(g);
    add("buttons");
    std::vector<std::pair<size_t, std::string>> out;
    for (const std::string& g : order)
      for (size_t r = 0; r < rows.size(); ++r)
        if (groups[r] == g) out.push_back({r, g == order.front() ? dialog : dialog + "|" + g});
    return out;
  }

  void on_update() override {
    if (!editing_.empty()) {
      tick_editing();
      return;
    }
    if (!entering_.empty()) {
      tick_value_entry();
      return;
    }
    // A new dialog on top (the game opened one, or one closed): land on it and say its title.
    auto ds = dialogs();
    const Dialog* td = top_dialog(ds);
    std::string top = td ? td->key : std::string();
    g_main_menu = top.starts_with("MainMenuGui#");
    if (top != top_) {
      top_ = top;
      if (!top.empty()) app::focus_stop(Key(top));
    }
  }

 private:
  std::optional<std::chrono::steady_clock::time_point> last_in_game_;  // nullopt: never in a world yet
  std::string editing_;  // path of the text field the game is typing into; empty = the native UI has the keyboard
  std::string top_;
  std::string entering_;  // path of the slider a value is being typed for; empty = none
  std::string typed_;

  void back() {
    if (agui::close_dropdown_popup()) return;
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
    if (agui::Widget* b = find(top_dialog(ds)->widget)) agui::click(b);
  }

  void start_editing(const Path& p) {
    agui::Widget* w = resolve(p);
    if (!w || !agui::enabled(w)) return;
    agui::focus(w);
    editing_ = p;
    input::set_reserved({input::sc::Enter, input::sc::Escape, input::sc::Tab});
    speech::speak(strings::kEditing, true);
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
    input::set_reserved({});
    log::write("dialogs: editing done");
    app::announce_change(value.empty() ? std::string(strings::kBlank) : value);
  }

  // Typing an exact value for a slider that has no value field of its own: digits, '.', '-', Backspace; Enter
  // sets, Escape cancels.
  void start_value_entry(const Path& p) {
    agui::Widget* w = resolve(p);
    if (!w || !agui::enabled(w)) return;
    entering_ = p;
    typed_.clear();
    speech::speak(strings::kTypeValue, true);
  }

  void tick_value_entry() {
    const KeySource& ks = input::key_source();
    for (char16_t c : input::typed_chars()) {
      if ((c >= u'0' && c <= u'9') || c == u'.' || c == u'-') {
        typed_ += (char)c;
        speech::speak(std::string(1, (char)c), true);
      }
    }
    if (ks.just_pressed(input::sc::Backspace) && !typed_.empty()) {
      typed_.pop_back();
      speech::speak(typed_.empty() ? std::string(strings::kBlank) : typed_, true);
    }
    agui::Widget* w = resolve(entering_);
    if (!w || ks.just_pressed(input::sc::Escape)) {
      entering_.clear();
      speech::speak(strings::kCancelled, true);
      return;
    }
    if (!ks.just_pressed(input::sc::Enter)) return;
    entering_.clear();
    char* end = nullptr;
    double t = std::strtod(typed_.c_str(), &end);
    if (typed_.empty() || end == typed_.c_str()) {
      speech::speak(strings::kCancelled, true);
      return;
    }
    agui::slider_set(w, slider_value_for(w, t));
    app::announce_change(slider_text(w));
  }

  // What a typed number means for a slider: on a slider with notch texts ("100%", "133%", ...) the notch whose
  // number is closest; otherwise a percentage of the slider's range.
  static double slider_value_for(agui::Widget* w, double typed) {
    double lo = agui::slider_min(w), hi = agui::slider_max(w), step = agui::slider_step(w);
    auto notches = agui::slider_notch_texts(w);
    if (!notches.empty() && step > 0) {
      size_t best = 0;
      double best_diff = 1e300;
      for (size_t i = 0; i < notches.size(); ++i) {
        const char* s = notches[i].c_str();
        while (*s && !((*s >= '0' && *s <= '9') || *s == '-' || *s == '.')) ++s;
        char* end = nullptr;
        double n = std::strtod(s, &end);
        if (end == s) continue;
        double diff = n > typed ? n - typed : typed - n;
        if (diff < best_diff) {
          best_diff = diff;
          best = i;
        }
      }
      return lo + (double)best * step;
    }
    double v = lo + (hi - lo) * typed / 100.0;
    if (step > 0) v = lo + std::round((v - lo) / step) * step;
    return v < lo ? lo : v > hi ? hi : v;
  }
};
}  // namespace

std::unique_ptr<Screen> make_dialogs() { return std::make_unique<DialogsScreen>(); }
bool on_main_menu() { return g_main_menu; }
}  // namespace fa::screens
