#include <doctest/doctest.h>
#include <cstring>
#include "mac/inline_hook.h"

using fa::mac::inline_hook::relocate;

namespace {
uint64_t literal(const std::vector<uint32_t>& out, size_t at) { return out[at] | (uint64_t)out[at + 1] << 32; }
}  // namespace

TEST_CASE("relocate: plain instructions are copied, then a jump back") {
  const uint32_t in[] = {0xa9be4ff4, 0xa9017bfd, 0x910043fd, 0xaa0003f3};  // initLuaState's prologue
  std::vector<uint32_t> out;
  std::string err;
  REQUIRE(relocate(in, 4, 0x1005eb47c, 0x1005eb48c, out, err));
  REQUIRE(out.size() == 8);
  CHECK(std::memcmp(out.data(), in, sizeof in) == 0);
  CHECK(out[4] == 0x58000050);  // ldr x16, #8
  CHECK(out[5] == 0xd61f0200);  // br x16
  CHECK(literal(out, 6) == 0x1005eb48c);
}

TEST_CASE("relocate: adrp becomes a load of the page it named") {
  const uint32_t in[] = {0xb0015e88};  // at 0x1005eb48c: adrp x8, 0x1031bc000
  std::vector<uint32_t> out;
  std::string err;
  REQUIRE(relocate(in, 1, 0x1005eb48c, 0x1005eb490, out, err));
  CHECK(out[0] == 0x58000048);  // ldr x8, #8
  CHECK(out[1] == 0x14000003);  // b #12
  CHECK(literal(out, 2) == 0x1031bc000);
}

TEST_CASE("relocate: bl calls the same target and comes back past the literal") {
  const uint32_t in[] = {0x9490e3c5};  // at 0x1005eb498: bl 0x102a243ac
  std::vector<uint32_t> out;
  std::string err;
  REQUIRE(relocate(in, 1, 0x1005eb498, 0x1005eb49c, out, err));
  CHECK(out[0] == 0x58000070);  // ldr x16, #12
  CHECK(out[1] == 0xd63f0200);  // blr x16
  CHECK(out[2] == 0x14000003);  // b #12
  CHECK(literal(out, 3) == 0x102a243ac);
}

TEST_CASE("relocate: b.cond keeps its condition and reaches the original target") {
  const uint32_t in[] = {0x54000124};  // at 0x1027cb7fc: b.mi 0x1027cb820
  std::vector<uint32_t> out;
  std::string err;
  REQUIRE(relocate(in, 1, 0x1027cb7fc, 0x1027cb800, out, err));
  CHECK(out[0] == 0x54000044);  // b.mi #8
  CHECK(out[1] == 0x14000005);  // b #20
  CHECK(out[2] == 0x58000050);
  CHECK(literal(out, 4) == 0x1027cb820);
}

// A hook on a function of this test binary, end to end: the detour runs and the trampoline reaches the original.
namespace {
__attribute__((noinline)) int target_fn(int a, int b) {
  volatile int x = a * 3;
  return x + b * 7;
}
using fn_t = int (*)(int, int);
fn_t g_orig;
int detour_fn(int a, int b) { return g_orig(a, b) + 1000; }
}  // namespace

TEST_CASE("attach: detour runs and calls through the trampoline") {
  fn_t f = target_fn;
  CHECK(f(2, 3) == 27);
  REQUIRE(fa::mac::inline_hook::attach((void*)f, (void*)&detour_fn, (void**)&g_orig, "test"));
  CHECK(f(2, 3) == 1027);
  CHECK(g_orig(2, 3) == 27);
  fa::mac::inline_hook::detach((void*)f);
  CHECK(f(2, 3) == 27);
}
