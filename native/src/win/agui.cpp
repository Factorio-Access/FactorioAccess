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
  size_t vt_get_text = 0;
  void* get_abs_rect = nullptr;  // Rectangle agui::Widget::getAbsoluteRectangle() const
  void* dispatch_click = nullptr;  // void agui::Widget::dispatchClick(agui::MouseEvent const&)
  size_t me_position = 0, me_button = 0, me_type = 0, me_source = 0, me_size = 0;
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
  if (auto v = sym::vtable_offset("agui::Widget", "getText")) L.vt_get_text = *v;
  else ok = false;
  L.get_abs_rect = sym::addr("agui::Widget::getAbsoluteRectangle");
  ok &= L.get_abs_rect != nullptr;
  L.dispatch_click = sym::addr("agui::Widget::dispatchClick");
  ok &= L.dispatch_click != nullptr;
  ok &= resolve(L.me_position, "agui::MouseEvent", "position");
  ok &= resolve(L.me_button, "agui::MouseEvent", "button");
  ok &= resolve(L.me_type, "agui::MouseEvent", "eventType");
  ok &= resolve(L.me_source, "agui::MouseEvent", "source");
  ok &= resolve(L.me_size, "agui::MouseEvent", "previous");  // the last member: size = its offset + 8
  L.me_size += sizeof(void*);
  log::writef("agui: layout {} (children +{:#x}, usage +{:#x}, getText vtable +{:#x})", ok ? "resolved" : "INCOMPLETE", L.w_children, L.w_usage,
              L.vt_get_text);
  return ok;
}

Widget* root() {
  void* global = *reinterpret_cast<void**>(L.global_var);
  if (!global) return nullptr;
  void* gui = at<void*>(global, L.global_gui);
  return gui ? at<Widget*>(gui, L.gui_base) : nullptr;
}

Widget* focused() {
  void* global = *reinterpret_cast<void**>(L.global_var);
  void* gui = global ? at<void*>(global, L.global_gui) : nullptr;
  return gui ? at<Widget*>(gui, L.gui_focus) : nullptr;
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

std::string text(Widget* w) {
  void** vtable = *reinterpret_cast<void***>(w);
  auto get_text = reinterpret_cast<const MsvcString* (*)(Widget*)>(vtable[L.vt_get_text / sizeof(void*)]);
  return get_text(w)->str();
}

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
  reinterpret_cast<void (*)(Widget*, void*)>(L.dispatch_click)(w, ev);
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

// MSVC RTTI: the CompleteObjectLocator sits just before the vtable; its TypeDescriptor (image-relative on
// x64) holds the decorated name ".?AVTextButton@agui@@", turned here into "agui::TextButton".
std::string class_name(Widget* w) {
  void** vtable = *reinterpret_cast<void***>(w);
  auto* col = reinterpret_cast<const uint32_t*>(vtable[-1]);
  auto image = reinterpret_cast<const char*>(GetModuleHandleW(nullptr));
  const char* decorated = image + col[3] + 0x10;  // COL::pTypeDescriptor (RVA) -> TypeDescriptor::name
  std::string_view d(decorated);
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
}  // namespace fa::agui
