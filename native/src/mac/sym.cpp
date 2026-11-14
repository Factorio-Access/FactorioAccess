// fa::sym on macOS: function and variable addresses from the executable's own symbol table (mac/image.cpp), field
// offsets from code (mac/layout.cpp), virtual slots by finding a method's address in its class's vtable.
#include "sym.h"
#include <mach/mach.h>
#include <format>
#include "log.h"
#include "mac/image.h"
#include "mac/layout.h"

namespace fa::sym {
namespace {
std::vector<std::string_view> split(std::string_view q) {
  std::vector<std::string_view> parts;
  for (size_t p; (p = q.find("::")) != std::string_view::npos; q.remove_prefix(p + 2)) parts.push_back(q.substr(0, p));
  parts.push_back(q);
  return parts;
}

std::string encode(const std::vector<std::string_view>& parts, size_t n) {
  std::string out;
  for (size_t i = 0; i < n; ++i) out += std::to_string(parts[i].size()) + std::string(parts[i]);
  return out;
}

// Mangled-name prefixes a qualified name can have, in order of preference. A nested name's prefix ends at the `E`
// closing the name, so it matches every overload and nothing else.
std::vector<std::string> candidates(std::string_view name) {
  auto parts = split(name);
  // Mach-O prefixes every name with `_`; image.cpp strips that one, so C++ names start "_Z".
  if (parts.size() == 1) return {std::string(name), "_Z" + std::to_string(name.size()) + std::string(name)};
  std::string_view last = parts.back();
  std::string outer = encode(parts, parts.size() - 1);
  if (last.starts_with("~")) return {"_ZN" + outer + "D1E", "_ZN" + outer + "D2E", "_ZN" + outer + "D0E"};
  // Constructors: the base-object constructor (C2) first; the complete-object one (C1) usually just calls it.
  if (last == parts[parts.size() - 2]) return {"_ZN" + outer + "C2E", "_ZN" + outer + "C1E"};
  std::string all = encode(parts, parts.size());
  return {"_ZN" + all + "E", "_ZNK" + all + "E"};
}

std::vector<uintptr_t> all_addrs(const char* name) {
  std::vector<uintptr_t> out;
  // An already mangled name ("_ZN5EventC2Ed...") names one overload exactly.
  if (std::string_view(name).starts_with("_Z")) {
    if (uintptr_t a = mac::image::exact(name)) out.push_back(a);
    return out;
  }
  auto c = candidates(name);
  // A bare name is exact first (C functions, variables); its C++ form is a prefix.
  if (split(name).size() == 1) {
    if (uintptr_t a = mac::image::exact(c[0])) out.push_back(a);
    c.erase(c.begin());
  }
  for (auto& p : c)
    for (auto& [n, a] : mac::image::with_prefix(p)) out.push_back(a);
  return out;
}
}  // namespace

bool init() {
  if (!mac::image::init()) return false;
  if (!addr("luaD_throw")) {
    log::write("sym: the game's symbol table lacks luaD_throw");
    return false;
  }
  log::write("sym: symbol table loaded");
  return true;
}

void shutdown() {}

void* addr(const char* name) {
  auto a = all_addrs(name);
  if (a.empty()) {
    log::writef("sym: '{}' not found", name);
    return nullptr;
  }
  return reinterpret_cast<void*>(a.front());
}

std::optional<std::size_t> offset(const char* type, const char* member) {
  auto r = mac::layout::offset(type, member);
  if (!r) log::writef("sym: offset {}::{} not resolved", type, member);
  return r;
}

std::optional<std::size_t> type_size(const char* type) {
  auto r = mac::layout::type_size(type);
  if (!r) log::writef("sym: size of {} not resolved", type);
  return r;
}

std::optional<std::size_t> vtable_offset(const char* type, const char* method) {
  uintptr_t vt = mac::image::exact("_ZTV" + mac::image::mangle_type(type));
  auto targets = all_addrs(std::format("{}::{}", type, method).c_str());
  if (!vt || targets.empty()) {
    log::writef("sym: vtable slot {}::{} not resolved (vtable {}, {} candidates)", type, method, vt ? "found" : "missing", targets.size());
    return std::nullopt;
  }
  // Itanium vtable: offset-to-top, typeinfo, then the slots the object's vptr points at.
  auto* slots = reinterpret_cast<const uintptr_t*>(vt + 2 * sizeof(void*));
  std::optional<std::size_t> found;
  int matches = 0;
  for (int i = 0; i < 1024 && mac::image::in_text(slots[i]); ++i)
    for (uintptr_t t : targets)
      if (slots[i] == t) {
        if (!found) found = i * sizeof(void*);
        ++matches;
      }
  if (!found) log::writef("sym: {}::{} is not in {}'s vtable", type, method, type);
  else if (matches > 1) log::writef("sym: {}::{} fills {} vtable slots; using the first", type, method, matches);
  return found;
}

std::vector<std::string> thread_stack(void* thread) {
  // Frame-pointer walk of a suspended thread (the game is built with frame pointers, as arm64 macOS requires).
  std::vector<std::string> out;
  auto t = static_cast<thread_act_t>(reinterpret_cast<uintptr_t>(thread));
  if (thread_suspend(t) != KERN_SUCCESS) return out;
  arm_thread_state64_t st{};
  mach_msg_type_number_t count = ARM_THREAD_STATE64_COUNT;
  if (thread_get_state(t, ARM_THREAD_STATE64, reinterpret_cast<thread_state_t>(&st), &count) == KERN_SUCCESS) {
    auto describe = [&](uintptr_t pc) {
      if (mac::image::in_text(pc)) {
        auto [name, off] = mac::image::nearest(pc);
        out.push_back(std::format("{}+{:#x}", mac::image::demangle(name), off));
      } else {
        out.push_back(std::format("{:#x}", pc));
      }
    };
    describe(arm_thread_state64_get_pc(st));
    describe(arm_thread_state64_get_lr(st));
    auto* fp = reinterpret_cast<const uintptr_t*>(arm_thread_state64_get_fp(st));
    for (int i = 0; fp && i < 64; ++i) {
      vm_size_t got = 0;
      uintptr_t frame[2];
      if (vm_read_overwrite(mach_task_self(), (vm_address_t)fp, sizeof frame, (vm_address_t)frame, &got) != KERN_SUCCESS) break;
      if (!frame[1]) break;
      describe(frame[1]);
      if (frame[0] <= (uintptr_t)fp) break;
      fp = reinterpret_cast<const uintptr_t*>(frame[0]);
    }
  }
  thread_resume(t);
  return out;
}
}  // namespace fa::sym
