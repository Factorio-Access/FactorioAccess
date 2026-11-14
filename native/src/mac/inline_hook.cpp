#include "mac/inline_hook.h"
#include <libkern/OSCacheControl.h>
#include <mach/mach.h>
#include <sys/mman.h>
#include <array>
#include <cstring>
#include <format>
#include <map>
#include <mutex>
#include "log.h"

namespace fa::mac::inline_hook {
namespace {
constexpr uint32_t kLdrX16Lit8 = 0x58000050;  // ldr x16, #8
constexpr uint32_t kBrX16 = 0xd61f0200;       // br x16
constexpr uint32_t kBlrX16 = 0xd63f0200;      // blr x16

int64_t sext(uint64_t v, int bits) {
  uint64_t m = 1ull << (bits - 1);
  v &= (1ull << bits) - 1;
  return (int64_t)((v ^ m) - m);
}

void push_u64(std::vector<uint32_t>& out, uint64_t v) {
  out.push_back((uint32_t)v);
  out.push_back((uint32_t)(v >> 32));
}

// ldr x<rd>, #8; b #12; .quad value  -- materialise a 64-bit constant into rd.
void load_const(std::vector<uint32_t>& out, int rd, uint64_t value) {
  out.push_back(0x58000040u | (uint32_t)rd);  // ldr xRd, #8
  out.push_back(0x14000003u);                 // b #12
  push_u64(out, value);
}

void jump_abs(std::vector<uint32_t>& out, uint64_t to) {
  out.push_back(kLdrX16Lit8);
  out.push_back(kBrX16);
  push_u64(out, to);
}
}  // namespace

bool relocate(const uint32_t* insns, int count, uint64_t pc, uint64_t resume, std::vector<uint32_t>& out, std::string& error) {
  for (int i = 0; i < count; ++i, pc += 4) {
    uint32_t in = insns[i];
    if ((in & 0x1f000000) == 0x10000000) {  // adr / adrp
      int rd = in & 0x1f;
      int64_t imm = sext(((in >> 5) & 0x7ffff) << 2 | ((in >> 29) & 3), 21);
      uint64_t value = (in & 0x80000000) ? ((pc & ~0xfffull) + (uint64_t)(imm << 12)) : pc + imm;
      load_const(out, rd, value);
    } else if ((in & 0x7c000000) == 0x14000000) {  // b / bl
      uint64_t to = pc + sext(in & 0x3ffffff, 26) * 4;
      if (in & 0x80000000) {
        // bl: the call returns just after blr, so a branch there steps over the literal.
        out.push_back(0x58000070u);  // ldr x16, #12
        out.push_back(kBlrX16);
        out.push_back(0x14000003u);  // b #12
        push_u64(out, to);
      } else {
        jump_abs(out, to);
      }
    } else if ((in & 0xff000010) == 0x54000000 ||  // b.cond
               (in & 0x7e000000) == 0x34000000 ||  // cbz / cbnz
               (in & 0x7e000000) == 0x36000000) {  // tbz / tbnz
      uint64_t to;
      uint32_t retarget;
      if ((in & 0x7e000000) == 0x36000000) {
        to = pc + sext((in >> 5) & 0x3fff, 14) * 4;
        retarget = (in & ~(0x3fffu << 5)) | (2u << 5);
      } else {
        to = pc + sext((in >> 5) & 0x7ffff, 19) * 4;
        retarget = (in & ~(0x7ffffu << 5)) | (2u << 5);
      }
      out.push_back(retarget);     // taken: +8, the absolute jump below
      out.push_back(0x14000005u);  // not taken: b #20, past the jump
      jump_abs(out, to);
    } else if ((in & 0x3b000000) == 0x18000000) {  // ldr (literal), all register kinds
      int rt = in & 0x1f;
      uint64_t addr = pc + sext((in >> 5) & 0x7ffff, 19) * 4;
      uint32_t opc = in >> 30, v = (in >> 26) & 1;
      load_const(out, 16, addr);
      if (!v && opc == 0) out.push_back(0xb9400200u | rt);       // ldr wt, [x16]
      else if (!v && opc == 1) out.push_back(0xf9400200u | rt);  // ldr xt, [x16]
      else if (!v && opc == 2) out.push_back(0xb9800200u | rt);  // ldrsw xt, [x16]
      else if (v && opc == 0) out.push_back(0xbd400200u | rt);   // ldr st, [x16]
      else if (v && opc == 1) out.push_back(0xfd400200u | rt);   // ldr dt, [x16]
      else if (v && opc == 2) out.push_back(0x3dc00200u | rt);   // ldr qt, [x16]
      else {
        error = std::format("unsupported literal load {:08x}", in);
        return false;
      }
    } else {
      out.push_back(in);
    }
  }
  jump_abs(out, resume);
  return true;
}

namespace {
std::mutex g_mu;
// Constructed on first use: hooks attach from the library's initializer, which may run before this file's own.
std::map<void*, std::array<uint32_t, kPatchedInsns>>& saved_bytes() {
  static std::map<void*, std::array<uint32_t, kPatchedInsns>> m;
  return m;
}

bool write_code(void* at, const void* bytes, size_t n) {
  const uintptr_t page = vm_page_size;
  uintptr_t start = (uintptr_t)at & ~(page - 1);
  uintptr_t end = ((uintptr_t)at + n + page - 1) & ~(page - 1);
  // VM_PROT_COPY: the signed file pages become a private copy we may change (the hardened runtime allows it here).
  if (vm_protect(mach_task_self(), start, end - start, 0, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY) != KERN_SUCCESS) return false;
  std::memcpy(at, bytes, n);
  bool ok = vm_protect(mach_task_self(), start, end - start, 0, VM_PROT_READ | VM_PROT_EXECUTE) == KERN_SUCCESS;
  sys_icache_invalidate(at, n);
  return ok;
}

void* make_trampoline(const std::vector<uint32_t>& code) {
  size_t size = (code.size() * 4 + vm_page_size - 1) & ~(vm_page_size - 1);
  void* p = mmap(nullptr, size, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANON, -1, 0);
  if (p == MAP_FAILED) return nullptr;
  std::memcpy(p, code.data(), code.size() * 4);
  if (mprotect(p, size, PROT_READ | PROT_EXEC) != 0) return nullptr;
  sys_icache_invalidate(p, code.size() * 4);
  return p;
}
}  // namespace

bool attach(void* target, void* detour, void** original, const char* label) {
  std::lock_guard lk(g_mu);
  if (!target) {
    log::writef("hook {}: no target", label);
    return false;
  }
  auto* insns = static_cast<const uint32_t*>(target);
  std::array<uint32_t, kPatchedInsns> saved;
  std::memcpy(saved.data(), insns, sizeof saved);
  std::vector<uint32_t> tramp;
  std::string err;
  if (!relocate(saved.data(), kPatchedInsns, (uint64_t)target, (uint64_t)target + kPatchedInsns * 4, tramp, err)) {
    log::writef("hook {}: {}", label, err);
    return false;
  }
  void* t = make_trampoline(tramp);
  if (!t) {
    log::writef("hook {}: no trampoline memory", label);
    return false;
  }
  *original = t;
  uint32_t patch[kPatchedInsns] = {kLdrX16Lit8, kBrX16, (uint32_t)(uint64_t)detour, (uint32_t)((uint64_t)detour >> 32)};
  if (!write_code(target, patch, sizeof patch)) {
    log::writef("hook {}: could not write the game's code", label);
    *original = nullptr;
    return false;
  }
  saved_bytes()[target] = saved;
  return true;
}

void detach(void* target) {
  std::lock_guard lk(g_mu);
  auto it = saved_bytes().find(target);
  if (it == saved_bytes().end()) return;
  write_code(target, it->second.data(), sizeof(uint32_t) * kPatchedInsns);
  saved_bytes().erase(it);
}
}  // namespace fa::mac::inline_hook
