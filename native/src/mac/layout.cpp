#include "mac/layout.h"
#include <cstring>
#include <string>
#include <string_view>
#include "log.h"
#include "sym.h"

namespace fa::mac::layout {
namespace {
int64_t sext(uint64_t v, int bits) {
  uint64_t m = 1ull << (bits - 1);
  v &= (1ull << bits) - 1;
  return (int64_t)((v ^ m) - m);
}
}  // namespace

std::optional<Access> decode(uint32_t in) {
  Access a;
  a.rn = (in >> 5) & 31;
  a.rt = in & 31;
  uint32_t size = in >> 30, v = (in >> 26) & 1, opc = (in >> 22) & 3;
  a.fp = v;
  auto scale_of = [&] { return (v && (opc & 2)) ? 4u : size; };  // a q register is 16 bytes
  if ((in & 0x3b000000) == 0x39000000) {  // ldr/str (unsigned immediate)
    if (!v && size == 3 && opc == 2) return std::nullopt;  // prfm
    uint32_t scale = scale_of();
    a.load = v ? (opc & 1) : opc != 0;
    a.offset = (int64_t)(((in >> 10) & 0xfff) << scale);
    a.size = 1 << scale;
    return a;
  }
  if ((in & 0x3b200c00) == 0x38000000) {  // ldur/stur (unscaled)
    uint32_t scale = scale_of();
    a.load = v ? (opc & 1) : opc != 0;
    a.offset = sext((in >> 12) & 0x1ff, 9);
    a.size = 1 << scale;
    return a;
  }
  if ((in & 0x3b800000) == 0x29000000) {  // ldp/stp (signed offset; not the pre/post-indexed stack forms)
    uint32_t scale = v ? 2 + (in >> 30) : ((in >> 31) ? 3 : 2);
    a.pair = true;
    a.load = (in >> 22) & 1;
    a.offset = sext((in >> 15) & 0x7f, 7) << scale;
    a.size = 1 << scale;
    return a;
  }
  return std::nullopt;
}

namespace {
// What an instruction does to the set of registers holding the base pointer.
void track(uint32_t in, uint32_t& aliases) {
  if ((in & 0xffe0ffe0) == 0xaa0003e0) {  // mov xd, xm (orr xd, xzr, xm)
    int rd = in & 31, rm = (in >> 16) & 31;
    if (aliases & (1u << rm)) aliases |= 1u << rd;
    else aliases &= ~(1u << rd);
    return;
  }
  if ((in & 0xfc000000) == 0x94000000 || (in & 0xfffffc1f) == 0xd63f0000) {  // bl, blr: x0-x18 are the callee's
    aliases &= ~0x7ffffu;
    return;
  }
  // Data processing (immediate: op0 100x, register: x101) writes the general register in bits 4:0.
  uint32_t op0 = (in >> 25) & 0xf;
  if ((op0 & 0xe) == 0x8 || (op0 & 0x7) == 0x5) aliases &= ~(1u << (in & 31));
}

bool is_add_imm(uint32_t in) { return (in & 0xff800000) == 0x91000000; }  // add xd, xn, #imm{, lsl #12}
bool is_sub_imm(uint32_t in) { return (in & 0xff800000) == 0xd1000000; }
int64_t addsub_imm(uint32_t in) { return (int64_t)((in >> 10) & 0xfff) << ((in >> 22) & 1 ? 12 : 0); }
}  // namespace

std::optional<Access> nth_access(const uint32_t* code, int limit, int base, bool load, bool store, int nth, int size) {
  uint32_t aliases = 1u << base;
  for (int i = 0; i < limit; ++i) {
    uint32_t in = code[i];
    auto a = decode(in);
    if (!a) {
      track(in, aliases);
      continue;
    }
    if ((aliases & (1u << a->rn)) && ((a->load && load) || (!a->load && store)) && (!size || a->size == size)) {
      if (nth-- == 0) return a;
    }
    // A load into an alias replaces it (ldr x0, [x0, #8] walks to another object).
    if (a->load && !a->fp) {
      aliases &= ~(1u << a->rt);
      if (a->pair) aliases &= ~(1u << ((in >> 10) & 31));
    }
  }
  return std::nullopt;
}

std::optional<int64_t> nth_add(const uint32_t* code, int limit, int base, int nth) {
  uint32_t aliases = 1u << base;
  for (int i = 0; i < limit; ++i) {
    uint32_t in = code[i];
    if (is_add_imm(in) && (aliases & (1u << ((in >> 5) & 31))) && nth-- == 0) return addsub_imm(in);
    if (auto a = decode(in)) {
      if (a->load && !a->fp) aliases &= ~(1u << a->rt);
    } else {
      track(in, aliases);
    }
  }
  return std::nullopt;
}

std::optional<int64_t> first_self_sub(const uint32_t* code, int limit) {
  for (int i = 0; i < limit; ++i) {
    uint32_t in = code[i];
    int rd = in & 31, rn = (in >> 5) & 31;
    if (is_sub_imm(in) && rd == rn && rd != 31) return addsub_imm(in);
  }
  return std::nullopt;
}

namespace {
enum Kind { Load, Store, Any, AddImm, StoreFrom };

// One field: read off the nth access of `kind` through `base` (the register holding the object pointer at entry)
// in `func`, counting only accesses of `size` bytes when set. `add` is added to the decoded offset (a string's
// last byte read for its length, the second register of a pair). StoreFrom takes the first store of register `nth`
// (an argument being written into the object). `minus` ("Type::member") makes the result relative to that field:
// a member of a struct embedded in another. `func` may be a mangled name, to pick one overload.
struct Recipe {
  const char* type;
  const char* member;
  const char* func;
  Kind kind = Load;
  int nth = 0;
  int size = 0;
  int64_t add = 0;
  const char* minus = nullptr;
  int base = 0;
};

// Read off the 2.1.24 arm64 build. The comment on each line is the instruction the offset comes from.
const Recipe kRecipes[] = {
    {"GlobalContext", "gui", "GlobalContext::unloadAgui", Load, 0, 8},                              // ldr x0, [x0, #0x60]
    {"GlobalContext", "appManager", "GlobalContext::getGameSafe", Load, 0, 8},                      // ldr x8, [x0, #0x168]
    {"agui::Gui", "baseWidget", "agui::Gui::getTop", Load, 0, 8},                                   // ldr x0, [x0, #0x70]
    {"agui::Widget", "parentWidget", "agui::Widget::getParent", Load, 0, 8},                        // ldr x0, [x0, #0x50]
    {"agui::Widget", "children", "agui::Widget::getChildCount", Load, 0, 8},                        // ldp x9, x8, [x0, #0x58]
    {"agui::Widget", "privateChildren", "agui::Widget::getPrivateChildCount", Load, 0, 8},          // ldp x9, x8, [x0, #0x70]
    {"agui::Widget", "usageBitMask", "agui::Widget::isVisible", Load, 0, 4},                        // ldr w8, [x0, #0x88]
    {"agui::Widget", "toolTipCreator", "agui::Widget::setToolTipCreator", Store, 0, 8},             // str x20, [x19, #0x30]
    {"agui::Button", "toggled", "agui::Button::isToggled", Load, 0, 1},                             // ldrb w0, [x0, #0xdd]
    {"agui::ToggleButton", "checkedState", "agui::ToggleButton::getCheckedState", Load, 0, 4},      // ldr w0, [x0, #0x124]
    {"agui::Style", "tooltip", "agui::Style::getToolTip", Load, 0, 8},                              // ldr x8, [x0, #0x60]
    {"agui::Style", "parent", "agui::Style::getToolTip", Load, 1, 8},                               // ldr x0, [x0, #0x8]
    {"agui::Style", "styleInfo", "agui::Style::~Style", Load, 1, 8},                                // ldr x20, [x19, #0x18]
    {"agui::PlainToolTipCreator", "title", "agui::PlainToolTipCreator::createToolTip", Load, 0, 1, -0x17},  // ldrb w8, [x0, #0x1f]
    {"agui::PlainToolTipCreator", "text", "agui::PlainToolTipCreator::createToolTip", Load, 1, 1, -0x17},   // ldrsb w8, [x20, #0x37]
    {"agui::Table", "columnCount", "agui::Table::getColumnCount", Load, 0, 4},                      // ldr w0, [x0, #0x284]
    {"agui::Table", "hasHeaders", "agui::TableWithSelection::getSelectedIndex", Load, 0, 1},        // ldrb w9, [x0, #0x281]
    {"agui::TableWithSelection", "selectedIndex", "agui::TableWithSelection::getRawSelectedIndex", Load, 0, 4},  // ldr w0, [x0, #0x288]
    {"agui::Slider", "value", "agui::Slider::getValue", Load, 0, 8},                                // ldr d0, [x0, #0x398]
    {"agui::Slider", "valueStep", "agui::Slider::getValueStep", Load, 0, 8},                        // ldr d0, [x0, #0x3b0]
    {"agui::Slider", "min", "agui::Slider::setMinValue", Store, 0, 8},                              // str d0, [x0, #0x3a0]
    {"agui::Slider", "max", "agui::Slider::setMaxValue", Store, 0, 8},                              // str d0, [x0, #0x3a8]
    {"agui::Slider", "notchTooltips", "agui::Slider::setNotchTooltips", Load, 0, 8},                // ldr x22, [x0, #0x180]
    {"agui::MouseEvent", "position", "agui::MouseEvent::getPosition", Load, 0, 8},                  // ldr x0, [x0]
    {"agui::MouseEvent", "button", "agui::MouseEvent::getButton", Load, 0, 2},                      // ldrh w0, [x0, #0xc]
    {"agui::MouseEvent", "eventType", "agui::MouseEvent::getEvent", Load, 0, 4},                    // ldr w0, [x0, #0x10]
    {"agui::MouseEvent", "source", "agui::MouseEvent::getSourceWidget", Load, 0, 8},                // ldr x0, [x0, #0x28]
    // The last member: copyWithNewType copies the event field by field, ending with it.
    {"agui::MouseEvent", "previous", "agui::MouseEvent::copyWithNewType", Load, 0, 8},              // ldr x8, [x0, #0x30]
    {"Mod", "package", "Mod::getModPath", Load, 0, 8},                                              // ldr x9, [x0]
    {"Package", "packagePath_", "Package::init", AddImm, 0},                                        // add x0, x0, #0x40
    {"SDLWindow", "window", "SDLWindow::getWindow", Load, 0, 8},                                    // ldr x0, [x0, #0x18]
    // Event::Event(double, Event::Type, KeyboardEvent): the 16-byte KeyboardEvent arrives in x2 (scancode, mod) and
    // x3 (unichar, repeat).
    {"Event", "type", "_ZN5EventC2EdNS_4TypeE13KeyboardEvent", Store, 0, 4},                         // str w1, [x0]
    {"Event", "keyboard", "_ZN5EventC2EdNS_4TypeE13KeyboardEvent", StoreFrom, 2, 8},                // str x2, [x0, #0x10]
    {"KeyboardEvent", "unichar", "_ZN5EventC2EdNS_4TypeE13KeyboardEvent", StoreFrom, 3, 4, 0, "Event::keyboard"},  // str w3, [x0, #0x18]
};

// Members no function reaches on its own; each with where it was read.
struct Fixed {
  const char* type;
  const char* member;
  std::size_t offset;
};
const Fixed kFixed[] = {
    // std::unique_ptr<agui::StyleInfo>::~unique_ptr frees the string at +0 (ldrsb [x20, #0x17]; ldr x0, [x20]), and
    // Style::getParentPathString reads its size and data at +0x17 and +8.
    {"agui::StyleInfo", "name", 0},
    // KeyboardEvent is {u32 scancode, u16 mod, u32 unichar, bool repeat}: Event::Event stores the first two as one
    // register (str x2) and the last two from x3 with `lsr x8, x3, #32; strb w8, [x0, #0x1c]`.
    {"KeyboardEvent", "scancode", 0},
    {"KeyboardEvent", "mod", 4},
    {"KeyboardEvent", "repeat", 0xc},
};

struct SizeRecipe {
  const char* type;
  const char* func;  // steps back over an array of the type: `sub xd, xd, #sizeof`
};
const SizeRecipe kSizeRecipes[] = {
    {"LocalisedString", "LocalisedString::~LocalisedString"},  // sub x0, x0, #0x58 (destroying its children)
};

struct Size {
  const char* type;
  std::size_t size;
};
// Public ABIs, not the game's own types: these do not move.
const Size kSizes[] = {
    {"z_stream_s", 112},  // zlib's z_stream on LP64
};

constexpr int kScanLimit = 96;
}  // namespace

std::optional<std::size_t> offset(const char* type, const char* member) {
  for (const Fixed& f : kFixed)
    if (!std::strcmp(f.type, type) && !std::strcmp(f.member, member)) return f.offset;
  for (const Recipe& r : kRecipes) {
    if (std::strcmp(r.type, type) || std::strcmp(r.member, member)) continue;
    auto* code = static_cast<const uint32_t*>(sym::addr(r.func));
    if (!code) return std::nullopt;
    if (r.kind == AddImm) {
      auto imm = nth_add(code, kScanLimit, r.base, r.nth);
      if (!imm) log::writef("layout: {}::{}: add {} not found in {}", type, member, r.nth, r.func);
      return imm ? std::optional<std::size_t>(*imm + r.add) : std::nullopt;
    }
    std::optional<Access> a;
    if (r.kind == StoreFrom) {
      for (int n = 0; (a = nth_access(code, kScanLimit, r.base, false, true, n, r.size)); ++n)
        if (a->rt == r.nth) break;
    } else {
      a = nth_access(code, kScanLimit, r.base, r.kind != Store, r.kind != Load, r.nth, r.size);
    }
    if (!a) {
      log::writef("layout: {}::{}: access {} not found in {}", type, member, r.nth, r.func);
      return std::nullopt;
    }
    int64_t result = a->offset + r.add;
    if (r.minus) {
      std::string_view m(r.minus);
      size_t sep = m.rfind("::");
      std::string t(m.substr(0, sep)), f(m.substr(sep + 2));
      auto base = offset(t.c_str(), f.c_str());
      if (!base) return std::nullopt;
      result -= (int64_t)*base;
    }
    return (std::size_t)result;
  }
  log::writef("layout: no recipe for {}::{}", type, member);
  return std::nullopt;
}

std::optional<std::size_t> type_size(const char* type) {
  for (const Size& s : kSizes)
    if (!std::strcmp(s.type, type)) return s.size;
  for (const SizeRecipe& r : kSizeRecipes) {
    if (std::strcmp(r.type, type)) continue;
    auto* code = static_cast<const uint32_t*>(sym::addr(r.func));
    auto imm = code ? first_self_sub(code, kScanLimit) : std::nullopt;
    if (!imm) log::writef("layout: size of {}: no array step in {}", type, r.func);
    return imm ? std::optional<std::size_t>(*imm) : std::nullopt;
  }
  log::writef("layout: no size for {}", type);
  return std::nullopt;
}
}  // namespace fa::mac::layout
