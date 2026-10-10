#include <doctest/doctest.h>
#include "ui/message_builder.h"
#include "ui/strings.h"

using fa::ui::MessageBuilder;

TEST_CASE("fragments are space-joined") {
  MessageBuilder m;
  m.fragment("a").fragment("b").fragment("");
  CHECK(m.build() == "a b");
}

TEST_CASE("list items are comma-joined, fragments inside an item space-joined") {
  MessageBuilder m;
  m.list_item().fragment("Create").list_item().fragment("button").fragment("x").list_item().fragment("1 of 7");
  CHECK(m.build() == "Create, button x, 1 of 7");
}

TEST_CASE("no leading comma before the first item, empty fragments ignored") {
  MessageBuilder m;
  m.list_item().fragment("").list_item().fragment("only");
  CHECK(m.build() == "only");
}

TEST_CASE("single use") {
  MessageBuilder m;
  m.fragment("x");
  (void)m.build();
  CHECK_THROWS(m.fragment("y"));
  CHECK_THROWS(m.build());
}

TEST_CASE("a lone space fragment is rejected") {
  MessageBuilder m;
  CHECK_THROWS(m.fragment(" "));
}

TEST_CASE("push_control shape") {
  MessageBuilder m;
  fa::strings::push_control(m, "Delete", fa::strings::kButton, false, true);
  fa::strings::push_position(m, 2, 7);
  CHECK(m.build() == "Delete, button, disabled, 2 of 7");
}

