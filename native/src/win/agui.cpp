#include "agui.h"
#include <windows.h>
#include <cstdint>
#include <cstring>
#include "log.h"
#include "sym.h"

namespace fa::agui {
namespace {
// MSVC std::string: a 16-byte union of inline buffer / heap pointer, then size, then capacity.
struct MsvcString {
  union {
    char buf[16];
    const char* ptr;
  };
  size_t size;
  size_t cap;
  std::string str() const { return std::string(cap > 15 ? ptr : buf, size); }
};
// MSVC std::vector<T*>: first, last, end.
struct MsvcPtrVector {
  void** first;
  void** last;
  void** end;
};

// Resolved by name from the PDB at init; a missing name means the build changed under us.
struct Layout {
  void* global_var = nullptr;  // GlobalContext* global
  size_t global_gui = 0;       // GlobalContext::gui (UniquePointer<agui::Gui>, one pointer)
  size_t gui_base = 0;         // agui::Gui::baseWidget
  size_t gui_focus = 0;        // agui::Gui::focusManager + FocusManager::focusedWidget (GenericTargeter: target first)
  size_t w_parent = 0, w_children = 0, w_private = 0, w_usage = 0;
  size_t button_toggled = 0;  // agui::Button::toggled (toggle button state)
  size_t checked_state = 0;   // agui::ToggleButton::checkedState (enum CheckedState: UNCHECKED 0, CHECKED 1, INTERMEDIATE 2)
  size_t vt_mouse_click = 0;  // virtual bool agui::Widget::mouseClick(agui::MouseEvent const&)
  size_t vt_get_text = 0, vt_focus = 0, vt_get_style = 0;
  size_t style_parent = 0, style_info = 0, style_tooltip = 0, info_name = 0;
  void* get_abs_rect = nullptr;    // Rectangle agui::Widget::getAbsoluteRectangle() const
  void* dispatch_click = nullptr;  // void agui::Widget::dispatchClick(agui::MouseEvent const&)
  size_t me_position = 0, me_button = 0, me_type = 0, me_source = 0, me_size = 0;
  int (*dd_count)(Widget*) = nullptr;           // agui::DropDown::getItemCount
  int (*dd_selected)(Widget*) = nullptr;        // agui::DropDown::getSelectedIndex
  void (*dd_edit)(Widget*, int) = nullptr;      // agui::DropDown::editSelectedIndex (dispatches item-select)
  bool (*dd_showing)(Widget*) = nullptr;        // agui::DropDown::isDropDownShowing
  void (*dd_hide)(Widget*) = nullptr;           // agui::DropDown::hideDropDown
  int (*lb_selected)(Widget*) = nullptr;        // agui::ListBox::getSelectedIndex
  int (*lb_index_of)(Widget*, Widget*) = nullptr;  // agui::ListBox::getIndexOfWidget
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
  size_t fm = 0, fw = 0;
  ok &= resolve(fm, "agui::Gui", "focusManager");
  ok &= resolve(fw, "agui::FocusManager", "focusedWidget");
  L.gui_focus = fm + fw;
  ok &= resolve(L.w_parent, "agui::Widget", "parentWidget");
  ok &= resolve(L.w_children, "agui::Widget", "children");
  ok &= resolve(L.w_private, "agui::Widget", "privateChildren");
  ok &= resolve(L.w_usage, "agui::Widget", "usageBitMask");
  ok &= resolve(L.button_toggled, "agui::Button", "toggled");
  ok &= resolve(L.checked_state, "agui::ToggleButton", "checkedState");
  ok &= resolve_virtual(L.vt_mouse_click, "agui::Widget", "mouseClick");
  ok &= resolve_virtual(L.vt_get_text, "agui::Widget", "getText");
  L.dispatch_click = sym::addr("agui::Widget::dispatchClick");
  ok &= L.dispatch_click != nullptr;
  ok &= resolve_virtual(L.vt_focus, "agui::Widget", "focus");
  ok &= resolve_virtual(L.vt_get_style, "agui::Widget", "getStyle");
  ok &= resolve(L.style_parent, "agui::Style", "parent");
  ok &= resolve(L.style_info, "agui::Style", "styleInfo");
  ok &= resolve(L.style_tooltip, "agui::Style", "tooltip");
  ok &= resolve(L.info_name, "agui::StyleInfo", "name");
  L.get_abs_rect = sym::addr("agui::Widget::getAbsoluteRectangle");
  ok &= L.get_abs_rect != nullptr;
  ok &= (L.dd_count = sym::fn<decltype(L.dd_count)>("agui::DropDown::getItemCount")) != nullptr;
  ok &= (L.dd_selected = sym::fn<decltype(L.dd_selected)>("agui::DropDown::getSelectedIndex")) != nullptr;
  ok &= (L.dd_edit = sym::fn<decltype(L.dd_edit)>("agui::DropDown::editSelectedIndex")) != nullptr;
  ok &= (L.dd_showing = sym::fn<decltype(L.dd_showing)>("agui::DropDown::isDropDownShowing")) != nullptr;
  ok &= (L.dd_hide = sym::fn<decltype(L.dd_hide)>("agui::DropDown::hideDropDown")) != nullptr;
  ok &= (L.lb_selected = sym::fn<decltype(L.lb_selected)>("agui::ListBox::getSelectedIndex")) != nullptr;
  ok &= (L.lb_index_of = sym::fn<decltype(L.lb_index_of)>("agui::ListBox::getIndexOfWidget")) != nullptr;
  ok &= resolve(L.me_position, "agui::MouseEvent", "position");
  ok &= resolve(L.me_button, "agui::MouseEvent", "button");
  ok &= resolve(L.me_type, "agui::MouseEvent", "eventType");
  ok &= resolve(L.me_source, "agui::MouseEvent", "source");
  ok &= resolve(L.me_size, "agui::MouseEvent", "previous");  // the last member: size = its offset + 8
  L.me_size += sizeof(void*);
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
  return g ? at<Widget*>(g, L.gui_focus) : nullptr;
}

static std::vector<Widget*> ptr_vector(Widget* w, size_t off) {
  auto& v = at<MsvcPtrVector>(w, off);
  return std::vector<Widget*>(reinterpret_cast<Widget**>(v.first), reinterpret_cast<Widget**>(v.last));
}
std::vector<Widget*> children(Widget* w) { return ptr_vector(w, L.w_children); }
std::vector<Widget*> private_children(Widget* w) { return ptr_vector(w, L.w_private); }
Widget* parent(Widget* w) { return at<Widget*>(w, L.w_parent); }

// The bits of Widget::usageBitMask, read off the accessors (agui::Widget::isEnabled is `mask >> 3 & 1`;
// setVisible treats the widget as visible when `(mask & 0x20004) == 4`).
constexpr uint32_t kVisible = 0x4, kHiddenOverride = 0x20000, kEnabled = 0x8;
bool visible(Widget* w) { return (at<uint32_t>(w, L.w_usage) & (kVisible | kHiddenOverride)) == kVisible; }
bool enabled(Widget* w) { return (at<uint32_t>(w, L.w_usage) & kEnabled) != 0; }
bool toggled(Widget* w) { return at<bool>(w, L.button_toggled); }
bool checked(Widget* w) { return at<int>(w, L.checked_state) == 1; }

static void* style(Widget* w) { return virtual_fn<void* (*)(Widget*)>(w, L.vt_get_style)(w); }

std::string style_name(Widget* w) {
  for (void* s = style(w); s; s = at<void*>(s, L.style_parent))
    if (void* info = at<void*>(s, L.style_info)) return at<MsvcString>(info, L.info_name).str();
  return {};
}

std::string tooltip(Widget* w) {
  void* s = style(w);
  auto* t = s ? at<MsvcString*>(s, L.style_tooltip) : nullptr;  // unique_ptr<std::string>
  return t ? t->str() : std::string();
}

std::string text(Widget* w) { return virtual_fn<const MsvcString* (*)(Widget*)>(w, L.vt_get_text)(w)->str(); }

Rect rect(Widget* w) {
  struct AguiRect {
    int x, y, w, h;
  } r{};
  reinterpret_cast<AguiRect* (*)(Widget*, AguiRect*)>(L.get_abs_rect)(w, &r);
  return {r.x, r.y, r.w, r.h};
}

// agui::MouseEvent::Type::MOUSE_CLICK and agui::MouseButton::LEFT (enums in the PDB).
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
  // The click listeners (what the game attached to the button). The virtual mouseDown/mouseUp/mouseClick
  // path does not fire them: agui::Gui's own state (which widget took the mouse down) gates it.
  reinterpret_cast<void (*)(Widget*, void*)>(L.dispatch_click)(w, ev);
}

void toggle(Widget* w) {
  // agui::ToggleButton::mouseClick ignores the event apart from passing it through: it notifies the parent and
  // advances the check state (which dispatches the check listeners). Unlike agui::Button::mouseClick it does
  // not depend on agui::Gui's mouse-down bookkeeping, so it can be called directly.
  alignas(8) unsigned char ev[128] = {};
  at<int>(ev, L.me_type) = kMouseClick;
  at<uint16_t>(ev, L.me_button) = kLeftButton;
  at<Widget*>(ev, L.me_source) = w;
  virtual_fn<bool (*)(Widget*, void*)>(w, L.vt_mouse_click)(w, ev);
}

void focus(Widget* w) {
  // virtual void focus(NamedBool<TabbedInTag>): the flag is one byte, passed by value.
  virtual_fn<void (*)(Widget*, uint8_t)>(w, L.vt_focus)(w, 0);
}

int dropdown_count(Widget* w) { return L.dd_count(w); }
int dropdown_selected(Widget* w) { return L.dd_selected(w); }
void dropdown_select(Widget* w, int index) { L.dd_edit(w, index); }

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

// ---- MSVC RTTI ----
// The CompleteObjectLocator sits just before the vtable. On x64 its pointers are image-relative:
// +0x0c TypeDescriptor (name at +0x10, decorated: ".?AVTextButton@agui@@"), +0x10 ClassHierarchyDescriptor
// (+0x08 base count, +0x0c BaseClassDescriptor array; each descriptor starts with its TypeDescriptor RVA).
static const char* image() { return reinterpret_cast<const char*>(GetModuleHandleW(nullptr)); }
static const uint32_t* locator(Widget* w) { return reinterpret_cast<const uint32_t*>((*reinterpret_cast<void***>(w))[-1]); }

static std::string undecorate(std::string_view d) {
  if (d.size() < 4 || d.substr(0, 4) != ".?AV") return std::string(d);
  d.remove_prefix(4);
  if (d.ends_with("@@")) d.remove_suffix(2);
  std::vector<std::string_view> parts;
  for (size_t p; (p = d.find('@')) != std::string_view::npos; d.remove_prefix(p + 1)) parts.push_back(d.substr(0, p));
  parts.push_back(d);
  std::string out;
  for (auto it = parts.rbegin(); it != parts.rend(); ++it) out += (out.empty() ? "" : "::") + std::string(*it);
  return out;
}

std::string class_name(Widget* w) { return undecorate(image() + locator(w)[3] + 0x10); }

bool is_a(Widget* w, std::string_view qualified) {
  const uint32_t* col = locator(w);
  auto* hierarchy = reinterpret_cast<const uint32_t*>(image() + col[4]);
  uint32_t count = hierarchy[2];
  auto* bases = reinterpret_cast<const uint32_t*>(image() + hierarchy[3]);
  for (uint32_t i = 0; i < count; ++i) {
    auto* descriptor = reinterpret_cast<const uint32_t*>(image() + bases[i]);
    if (undecorate(image() + descriptor[0] + 0x10) == qualified) return true;
  }
  return false;
}
}  // namespace fa::agui
