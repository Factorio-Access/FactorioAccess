#pragma once
// A minimal arm64 inline hook: the target's first four instructions become a jump to the detour, and a trampoline
// runs those four (relocated where they are PC-relative) before jumping back. Enough for the handful of game
// functions the native code hooks, whose prologues are plain stack setup.
#include <cstdint>
#include <string>
#include <vector>

namespace fa::mac::inline_hook {
constexpr int kPatchedInsns = 4;  // ldr x16, #8; br x16; .quad detour

// Rewrite `insns` (originally at address `pc`) to run from anywhere, followed by a jump to `resume`.
// Returns false (with `error` set) for an instruction it cannot relocate. Pure, so it is unit-testable.
bool relocate(const uint32_t* insns, int count, uint64_t pc, uint64_t resume, std::vector<uint32_t>& out, std::string& error);

// Patch `target` to jump to `detour`; `*original` receives a callable trampoline. False (logged) on failure.
bool attach(void* target, void* detour, void** original, const char* label);
// Restore the original bytes. The trampoline is leaked on purpose: a thread may still be inside it.
void detach(void* target);
}  // namespace fa::mac::inline_hook
