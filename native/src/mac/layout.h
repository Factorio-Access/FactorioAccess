#pragma once
// Field offsets and type sizes for the Mac build, which ships symbols but no type information (the Windows build
// reads these from factorio.pdb). Each field is read off a named game function that accesses it, by decoding that
// function's arm64 code at startup: a getter's load, a setter's store. So a game update that moves a field moves
// the answer with it, and one that changes the function's shape fails the lookup (logged) instead of reading
// garbage. Recipes are in layout.cpp, each with the instruction it was read from.
#include <cstddef>
#include <cstdint>
#include <optional>

namespace fa::mac::layout {
std::optional<std::size_t> offset(const char* type, const char* member);
std::optional<std::size_t> type_size(const char* type);

// The decoder, exposed for tests: one arm64 load or store off a base register.
struct Access {
  bool load = false;
  bool pair = false;  // ldp / stp: `offset` is the first of the two
  bool fp = false;    // a floating-point / vector register (it never holds the base pointer)
  int rn = 0, rt = 0;
  int64_t offset = 0;
  int size = 0;  // bytes per register
};
std::optional<Access> decode(uint32_t insn);
// The nth (0-based) access off `base` (or a register a `mov` copied it to) in the first `limit` instructions,
// counting only accesses of `size` bytes when size is nonzero.
std::optional<Access> nth_access(const uint32_t* code, int limit, int base, bool load, bool store, int nth, int size = 0);
// The immediate of the nth `add xd, x<base>, #imm` (a field's address taken), same base tracking.
std::optional<int64_t> nth_add(const uint32_t* code, int limit, int base, int nth);
// The immediate of the first `sub xd, xd, #imm` on a register other than sp (a loop stepping back over an array).
std::optional<int64_t> first_self_sub(const uint32_t* code, int limit);
}  // namespace fa::mac::layout
