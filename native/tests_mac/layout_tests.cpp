// Encodings are copied from the 2.1.24 game binary (objdump), with the instruction each one is.
#include <doctest/doctest.h>
#include "mac/layout.h"

using fa::mac::layout::decode;
using fa::mac::layout::nth_access;

TEST_CASE("decode: unsigned-immediate loads of each width") {
  auto d = decode(0xfd41cc00);  // ldr d0, [x0, #0x398]
  REQUIRE(d);
  CHECK(d->load);
  CHECK(d->rn == 0);
  CHECK(d->offset == 0x398);
  CHECK(d->size == 8);
  auto b = decode(0x39437400);  // ldrb w0, [x0, #0xdd]
  REQUIRE(b);
  CHECK(b->offset == 0xdd);
  CHECK(b->size == 1);
  auto h = decode(0x79401800);  // ldrh w0, [x0, #0xc]
  REQUIRE(h);
  CHECK(h->offset == 0xc);
  CHECK(h->size == 2);
}

TEST_CASE("decode: stores and pairs") {
  auto s = decode(0xfd01d000);  // str d0, [x0, #0x3a0]
  REQUIRE(s);
  CHECK_FALSE(s->load);
  CHECK(s->offset == 0x3a0);
  auto p = decode(0xa9472009);  // ldp x9, x8, [x0, #0x70]
  REQUIRE(p);
  CHECK(p->pair);
  CHECK(p->load);
  CHECK(p->offset == 0x70);
  CHECK(p->size == 8);
  CHECK(p->rt == 9);
  auto sp = decode(0xa9017bfd);  // stp x29, x30, [sp, #0x10]
  REQUIRE(sp);
  CHECK(sp->rn == 31);
  CHECK_FALSE(sp->load);
}

TEST_CASE("decode: not a memory access") {
  CHECK_FALSE(decode(0xd65f03c0));  // ret
  CHECK_FALSE(decode(0x1e602020));  // fcmp d1, d0
  CHECK_FALSE(decode(0xa9be4ff4));  // stp x20, x19, [sp, #-0x20]! (pre-index: stack, not a field)
}

TEST_CASE("nth_access: agui::Slider::setMinValue's first store is min") {
  const uint32_t code[] = {0xa9be4ff4, 0xa9017bfd, 0x910043fd, 0xfd41d401, 0x1e602020, 0x54000124, 0xfd01d000, 0xfd41cc01};
  auto st = nth_access(code, 8, 0, false, true, 0);
  REQUIRE(st);
  CHECK(st->offset == 0x3a0);
  auto ld = nth_access(code, 8, 0, true, false, 0);
  REQUIRE(ld);
  CHECK(ld->offset == 0x3a8);
}

TEST_CASE("nth_access: follows a mov of the base and drops a register a load overwrote") {
  const uint32_t code[] = {
      0xaa0003f3,  // mov x19, x0
      0xf9400a68,  // ldr x8, [x19, #0x10]
      0xf9400660,  // ldr x0, [x19, #0x8]   (x0 now holds another object)
      0xf9400c00,  // ldr x0, [x0, #0x18]   (not the base any more)
  };
  auto a = nth_access(code, 4, 0, true, false, 0);
  REQUIRE(a);
  CHECK(a->offset == 0x10);
  auto b = nth_access(code, 4, 0, true, false, 1);
  REQUIRE(b);
  CHECK(b->offset == 0x8);
  CHECK_FALSE(nth_access(code, 4, 0, true, false, 2));
}

TEST_CASE("nth_access: a vector load does not lose the base (agui::MouseEvent::copyWithNewType)") {
  const uint32_t code[] = {
      0xad400001,  // ldp q1, q0, [x0]
      0xad000101,  // stp q1, q0, [x8]
      0x3dc00800,  // ldr q0, [x0, #0x20]
      0x3d800900,  // str q0, [x8, #0x20]
      0xf9401809,  // ldr x9, [x0, #0x30]
  };
  auto a = nth_access(code, 5, 0, true, false, 0, 8);
  REQUIRE(a);
  CHECK(a->offset == 0x30);
}
