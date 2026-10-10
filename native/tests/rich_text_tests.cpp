#include "doctest/doctest.h"
#include "ui/rich_text.h"

using fa::ui::strip_rich_text;

TEST_CASE("rich text tags are removed and whitespace collapsed") {
  CHECK(strip_rich_text("[font=default-dialog-button]Continue [font=default]test[/font][/font]") == "Continue test");
  CHECK(strip_rich_text("Language [img=restart_required]") == "Language");
  CHECK(strip_rich_text("  plain   text \n") == "plain text");
}

TEST_CASE("brackets that are not rich text survive") {
  CHECK(strip_rich_text("slot [3]") == "slot [3]");
  CHECK(strip_rich_text("unclosed [font=x") == "unclosed [font=x");
}
