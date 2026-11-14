// fa::agui on macOS: the same reads as win/agui.cpp, with the game's libc++ layouts (mac/abi.h), Itanium RTTI for
// class names, and field offsets from mac/layout.cpp. Where the game has a small accessor that hides a layout
// detail (the focus manager stores a pointer 8 bytes into the widget), it is called instead of read around.
#include "agui.h"
#include <cxxabi.h>
#include <cmath>
#include <cstdint>
#include <cstdlib>
#include <cstring>
#include <map>
#include "log.h"
#include "mac/abi.h"
#include "mac/image.h"
#include "sym.h"

namespace fa::agui {
namespace {
using mac::abi::String;
using WidgetVector = mac::abi::Vector<Widget*>;

struct Layout {
  void* global_var = nullptr;  // GlobalContext* global
  size_t global_gui = 0;       // GlobalContext::gui (unique_ptr<agui::Gui>)
  size_t gui_base = 0;         // agui::Gui::baseWidget
  Widget* (*gui_focused)(void* gui) = nullptr;  // agui::Gui::getFocusedWidget
  size_t w_parent = 0, w_children = 0, w_private = 0, w_usage = 0;
  size_t button_toggled = 0, checked_state = 0;
  size_t vt_mouse_click = 0, vt_get_text = 0, vt_focus = 0, vt_get_style = 0;
  size_t style_parent = 0, style_info = 0, style_tooltip = 0, info_name = 0;
  size_t w_tooltip_creator = 0, plain_tip_title = 0, plain_tip_text = 0;
  void* get_abs_rect = nullptr;
  void* dispatch_click = nullptr;
  size_t me_position = 0, me_button = 0, me_type = 0, me_source = 0, me_size = 0;
  int (*dd_count)(Widget*) = nullptr;
  int (*dd_selected)(Widget*) = nullptr;
  void (*dd_edit)(Widget*, int) = nullptr;
  bool (*dd_showing)(Widget*) = nullptr;
  void (*dd_hide)(Widget*) = nullptr;
  int (*lb_selected)(Widget*) = nullptr;
  bool (*tab_selected)(Widget*) = nullptr;
  size_t table_columns = 0, table_headers = 0;
  size_t slider_value = 0, slider_min = 0, slider_max = 0, slider_step = 0, slider_notches = 0;
  void (*slider_set)(Widget*, double, bool, bool) = nullptr;
  int (*lb_index_of)(Widget*, Widget*) = nullptr;
  size_t tws_selected = 0;
  void (*tws_edit)(Widget*, unsigned, int) = nullptr;
  // libc++abi's type_info classes, as linked into the game: how a class's bases are recorded.
  uintptr_t ti_si = 0, ti_vmi = 0;
} L;

template <typename T>
T& at(void* base, size_t off) {
  return *reinterpret_cast<T*>(reinterpret_cast<char*>(base) + off);
}

bool resolve(size_t& out, const char* type, const char* member) {
  auto r = sym::offset(type, member);
  if (r) out = *r;
  return r.has_value();
}
bool resolve_virtual(size_t& out, const char* type, const char* method) {
  auto r = sym::vtable_offset(type, method);
  if (r) out = *r;
  return r.has_value();
}
template <typename F>
bool resolve_fn(F& out, const char* name) {
  out = sym::fn<F>(name);
  return out != nullptr;
}

template <typename Fn>
Fn virtual_fn(Widget* w, size_t slot_offset) {
  void** vtable = *reinterpret_cast<void***>(w);
  return reinterpret_cast<Fn>(vtable[slot_offset / sizeof(void*)]);
}
}  // namespace

bool init() {
  bool ok = true;
  L.global_var = sym::addr("global");
  ok &= L.global_var != nullptr;
  ok &= resolve(L.global_gui, "GlobalContext", "gui");
  ok &= resolve(L.gui_base, "agui::Gui", "baseWidget");
  ok &= resolve_fn(L.gui_focused, "agui::Gui::getFocusedWidget");
  ok &= resolve(L.w_parent, "agui::Widget", "parentWidget");
  ok &= resolve(L.w_children, "agui::Widget", "children");
  ok &= resolve(L.w_private, "agui::Widget", "privateChildren");
  ok &= resolve(L.w_usage, "agui::Widget", "usageBitMask");
  ok &= resolve(L.button_toggled, "agui::Button", "toggled");
  ok &= resolve(L.checked_state, "agui::ToggleButton", "checkedState");
  ok &= resolve_virtual(L.vt_mouse_click, "agui::Widget", "mouseClick");
  ok &= resolve_virtual(L.vt_get_text, "agui::Widget", "getText");
  ok &= resolve_virtual(L.vt_focus, "agui::Widget", "focus");
  ok &= resolve_virtual(L.vt_get_style, "agui::Widget", "getStyle");
  ok &= (L.dispatch_click = sym::addr("agui::Widget::dispatchClick")) != nullptr;
  ok &= resolve(L.style_parent, "agui::Style", "parent");
  ok &= resolve(L.style_info, "agui::Style", "styleInfo");
  ok &= resolve(L.style_tooltip, "agui::Style", "tooltip");
  if (!resolve(L.w_tooltip_creator, "agui::Widget", "toolTipCreator") || !resolve(L.plain_tip_title, "agui::PlainToolTipCreator", "title") ||
      !resolve(L.plain_tip_text, "agui::PlainToolTipCreator", "text"))
    L.w_tooltip_creator = 0;
  ok &= resolve(L.info_name, "agui::StyleInfo", "name");
  ok &= (L.get_abs_rect = sym::addr("agui::Widget::getAbsoluteRectangle")) != nullptr;
  ok &= resolve_fn(L.dd_count, "agui::DropDown::getItemCount");
  ok &= resolve_fn(L.dd_selected, "agui::DropDown::getSelectedIndex");
  ok &= resolve_fn(L.dd_edit, "agui::DropDown::editSelectedIndex");
  ok &= resolve_fn(L.dd_showing, "agui::DropDown::isDropDownShowing");
  ok &= resolve_fn(L.dd_hide, "agui::DropDown::hideDropDown");
  ok &= resolve_fn(L.lb_selected, "agui::ListBox::getSelectedIndex");
  ok &= resolve_fn(L.tab_selected, "agui::Tab::isSelectedTab");
  ok &= resolve(L.table_columns, "agui::Table", "columnCount");
  ok &= resolve(L.table_headers, "agui::Table", "hasHeaders");
  ok &= resolve(L.slider_value, "agui::Slider", "value");
  ok &= resolve(L.slider_min, "agui::Slider", "min");
  ok &= resolve(L.slider_max, "agui::Slider", "max");
  ok &= resolve(L.slider_step, "agui::Slider", "valueStep");
  ok &= resolve(L.slider_notches, "agui::Slider", "notchTooltips");
  ok &= resolve_fn(L.slider_set, "agui::Slider::setValue");
  ok &= resolve_fn(L.lb_index_of, "agui::ListBox::getIndexOfWidget");
  ok &= resolve(L.tws_selected, "agui::TableWithSelection", "selectedIndex");
  ok &= resolve_fn(L.tws_edit, "agui::TableWithSelection::editSelectedIndex");
  ok &= resolve(L.me_position, "agui::MouseEvent", "position");
  ok &= resolve(L.me_button, "agui::MouseEvent", "button");
  ok &= resolve(L.me_type, "agui::MouseEvent", "eventType");
  ok &= resolve(L.me_source, "agui::MouseEvent", "source");
  ok &= resolve(L.me_size, "agui::MouseEvent", "previous");  // the last member: size = its offset + 8
  L.me_size += sizeof(void*);
  // Each type_info's own vptr points two slots into its class's vtable.
  uintptr_t si = mac::image::exact("_ZTVN10__cxxabiv120__si_class_type_infoE");
  uintptr_t vmi = mac::image::exact("_ZTVN10__cxxabiv121__vmi_class_type_infoE");
  ok &= si && vmi;
  L.ti_si = si + 2 * sizeof(void*);
  L.ti_vmi = vmi + 2 * sizeof(void*);
  log::writef("agui: layout {} (children +{:#x}, usage +{:#x}, getText vtable +{:#x})", ok ? "resolved" : "INCOMPLETE", L.w_children,
              L.w_usage, L.vt_get_text);
  return ok;
}

static void* gui() {
  void* global = *reinterpret_cast<void**>(L.global_var);
  return global ? at<void*>(global, L.global_gui) : nullptr;
}

Widget* root() {
  void* g = gui();
  return g ? at<Widget*>(g, L.gui_base) : nullptr;
}

Widget* focused() {
  void* g = gui();
  return g ? L.gui_focused(g) : nullptr;
}

static std::vector<Widget*> ptr_vector(Widget* w, size_t off) {
  auto& v = at<WidgetVector>(w, off);
  return std::vector<Widget*>(v.first, v.last);
}
std::vector<Widget*> children(Widget* w) { return ptr_vector(w, L.w_children); }
std::vector<Widget*> private_children(Widget* w) { return ptr_vector(w, L.w_private); }
Widget* parent(Widget* w) { return at<Widget*>(w, L.w_parent); }

// The bits of Widget::usageBitMask, the same as on Windows (agui::Widget::isEnabled is `mask >> 3 & 1`; isVisible is
// `(mask & 0x20004) == 4`).
constexpr uint32_t kVisible = 0x4, kHiddenOverride = 0x20000, kEnabled = 0x8;
bool visible(Widget* w) { return (at<uint32_t>(w, L.w_usage) & (kVisible | kHiddenOverride)) == kVisible; }
bool enabled(Widget* w) { return (at<uint32_t>(w, L.w_usage) & kEnabled) != 0; }
bool toggled(Widget* w) { return at<bool>(w, L.button_toggled); }
bool checked(Widget* w) { return at<int>(w, L.checked_state) == 1; }

static void* style(Widget* w) { return virtual_fn<void* (*)(Widget*)>(w, L.vt_get_style)(w); }

std::string style_name(Widget* w) {
  for (void* s = style(w); s; s = at<void*>(s, L.style_parent))
    if (void* info = at<void*>(s, L.style_info)) return at<String>(info, L.info_name).str();
  return {};
}

std::string tooltip(Widget* w) {
  void* s = style(w);
  auto* t = s ? at<String*>(s, L.style_tooltip) : nullptr;  // unique_ptr<std::string>
  if (t && !t->str().empty()) return t->str();
  if (!L.w_tooltip_creator) return {};
  void* creator = at<void*>(w, L.w_tooltip_creator);
  if (!creator || !is_a(static_cast<Widget*>(creator), "agui::PlainToolTipCreator")) return {};
  std::string title = at<String>(creator, L.plain_tip_title).str();
  std::string text = at<String>(creator, L.plain_tip_text).str();
  if (title.empty()) return text;
  return text.empty() ? title : title + "\n" + text;
}

std::string text(Widget* w) { return virtual_fn<const String* (*)(Widget*)>(w, L.vt_get_text)(w)->str(); }

Rect rect(Widget* w) {
  // agui::Rectangle is four ints: returned in x0/x1, which is what returning this struct compiles to.
  struct AguiRect {
    int x, y, w, h;
  };
  AguiRect r = reinterpret_cast<AguiRect (*)(Widget*)>(L.get_abs_rect)(w);
  return {r.x, r.y, r.w, r.h};
}

// agui::MouseEvent::Type::MOUSE_CLICK and agui::MouseButton::LEFT, as on Windows.
constexpr int kMouseClick = 4;
constexpr uint16_t kLeftButton = 2;

void click(Widget* w) {
  alignas(8) unsigned char ev[128] = {};
  if (L.me_size > sizeof ev) return;
  Rect r = rect(w);
  at<int>(ev, L.me_position) = r.w / 2;  // agui positions are relative to the source widget
  at<int>(ev, L.me_position + 4) = r.h / 2;
  at<uint16_t>(ev, L.me_button) = kLeftButton;
  at<int>(ev, L.me_type) = kMouseClick;
  at<Widget*>(ev, L.me_source) = w;
  reinterpret_cast<void (*)(Widget*, void*)>(L.dispatch_click)(w, ev);
}

void toggle(Widget* w) {
  alignas(8) unsigned char ev[128] = {};
  at<int>(ev, L.me_type) = kMouseClick;
  at<uint16_t>(ev, L.me_button) = kLeftButton;
  at<Widget*>(ev, L.me_source) = w;
  virtual_fn<bool (*)(Widget*, void*)>(w, L.vt_mouse_click)(w, ev);
}

void focus(Widget* w) {
  // virtual void focus(NamedBool<TabbedInTag>): a one-byte struct, passed in w1.
  virtual_fn<void (*)(Widget*, uint8_t)>(w, L.vt_focus)(w, 0);
}

int dropdown_count(Widget* w) { return L.dd_count(w); }
int dropdown_selected(Widget* w) { return L.dd_selected(w); }
void dropdown_select(Widget* w, int index) { L.dd_edit(w, index); }

bool tab_selected(Widget* w) { return L.tab_selected(w); }
int table_columns(Widget* w) { return (int)at<unsigned>(w, L.table_columns); }
bool table_has_headers(Widget* w) { return at<bool>(w, L.table_headers); }
bool is_selection_table(Widget* w) { return is_a(w, "agui::TableWithSelection"); }
int table_selected_row(Widget* w) {
  unsigned r = at<unsigned>(w, L.tws_selected);
  return r == ~0u ? -1 : (int)r;
}
void table_select_row(Widget* w, int row) { L.tws_edit(w, (unsigned)row, 0); }
double slider_value(Widget* w) { return at<double>(w, L.slider_value); }
double slider_min(Widget* w) { return at<double>(w, L.slider_min); }
double slider_max(Widget* w) { return at<double>(w, L.slider_max); }
double slider_step(Widget* w) { return at<double>(w, L.slider_step); }
void slider_set(Widget* w, double value) { L.slider_set(w, value, true, true); }

std::vector<std::string> slider_notch_texts(Widget* w) {
  auto& v = at<mac::abi::Vector<String>>(w, L.slider_notches);
  std::vector<std::string> out;
  for (const String* s = v.first; s != v.last; ++s) out.push_back(s->str());
  return out;
}

std::string slider_notch_text(Widget* w) {
  auto& v = at<mac::abi::Vector<String>>(w, L.slider_notches);
  double step = slider_step(w);
  if (v.first == v.last || step <= 0) return {};
  long long index = std::llround((slider_value(w) - slider_min(w)) / step);
  if (index < 0 || index >= v.last - v.first) return {};
  return v.first[index].str();
}

std::optional<bool> list_row_selected(Widget* w) {
  // A row sits a few levels under its list (list -> scroll pane -> flow -> row).
  Widget* lb = parent(w);
  for (int depth = 0; lb && depth < 4 && !is_a(lb, "agui::ListBox"); ++depth) lb = parent(lb);
  if (!lb || !is_a(lb, "agui::ListBox")) return std::nullopt;
  int index = L.lb_index_of(lb, w);
  if (index < 0) return std::nullopt;
  return L.lb_selected(lb) == index;
}

static bool close_popups(Widget* w) {
  bool closed = false;
  for (bool priv : {false, true})
    for (auto* c : priv ? private_children(w) : children(w)) {
      if (is_a(c, "agui::DropDown") && L.dd_showing(c)) {
        L.dd_hide(c);
        closed = true;
      }
      closed |= close_popups(c);
    }
  return closed;
}
bool close_dropdown_popup() {
  Widget* r = root();
  return r && close_popups(r);
}

static bool find(Widget* at_w, Widget* target) {
  if (at_w == target) return true;
  for (auto* c : children(at_w))
    if (find(c, target)) return true;
  for (auto* c : private_children(at_w))
    if (find(c, target)) return true;
  return false;
}
bool in_tree(Widget* w) {
  Widget* r = root();
  return r && w && find(r, w);
}

// ---- Itanium RTTI ----
// vptr[-1] is the class's std::type_info: {vptr, mangled name}. On arm64 Apple platforms the name pointer's top bit
// marks a type_info that may not be unique across images, so names are compared, never type_info addresses. A
// __si_class_type_info adds one base pointer at +16; a __vmi_class_type_info adds flags and a base count at +16 and
// +20, then {base type_info*, offset flags} pairs from +24.
namespace {
const void* type_info_of(Widget* w) { return (*reinterpret_cast<const void* const* const*>(w))[-1]; }
const char* ti_name(const void* ti) {
  uintptr_t p = reinterpret_cast<const uintptr_t*>(ti)[1] & ~(uintptr_t(1) << 63);
  return reinterpret_cast<const char*>(p);
}
std::string demangled(const char* mangled) {
  int status = 0;
  char* d = abi::__cxa_demangle(mangled, nullptr, nullptr, &status);
  if (!d) return mangled;
  std::string s(d);
  std::free(d);
  return s;
}
bool derives(const void* ti, const std::string& mangled_target, int depth) {
  if (!ti || depth > 32) return false;
  if (mangled_target == ti_name(ti)) return true;
  uintptr_t kind = *reinterpret_cast<const uintptr_t*>(ti);
  if (kind == L.ti_si) return derives(reinterpret_cast<const void* const*>(ti)[2], mangled_target, depth + 1);
  if (kind == L.ti_vmi) {
    uint32_t count = reinterpret_cast<const uint32_t*>(ti)[5];
    auto* bases = reinterpret_cast<const uintptr_t*>(reinterpret_cast<const char*>(ti) + 24);
    for (uint32_t i = 0; i < count && i < 64; ++i)
      if (derives(reinterpret_cast<const void*>(bases[2 * i]), mangled_target, depth + 1)) return true;
  }
  return false;
}
}  // namespace

std::string class_name(Widget* w) { return demangled(ti_name(type_info_of(w))); }

bool is_a(Widget* w, std::string_view qualified) {
  // Main thread only. Answers are kept per (class, target): the dialogs screen asks the same few questions of every
  // widget every frame.
  static std::map<std::pair<const void*, std::string>, bool> cache;
  const void* ti = type_info_of(w);
  auto key = std::make_pair(ti, std::string(qualified));
  auto it = cache.find(key);
  if (it != cache.end()) return it->second;
  bool r = derives(ti, mac::image::mangle_type(qualified), 0);
  cache.emplace(std::move(key), r);
  return r;
}
}  // namespace fa::agui
