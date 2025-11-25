local TestRegistry = require("scripts.test-registry")
local RichText = require("scripts.rich-text")
local describe, it = TestRegistry.describe, TestRegistry.it

describe("Rich Text Processing", function()
   it("should verbalize item tags", function(ctx)
      local result = RichText.verbalize_rich_text("[item=iron-plate] foo")
      -- Based on actual output from MessageBuilder
      local expected = {
         "",
         " ",
         "",
         { "fa.rich-text-item", { "?", { "item-name.iron-plate" }, "iron-plate" } },
         "",
         " ",
         "",
         " foo",
      }
      ctx:assert_table_equals(expected, result)
   end)

   it("should verbalize fluid tags", function(ctx)
      local result = RichText.verbalize_rich_text("bar [fluid=water] baz")
      local expected = {
         "",
         " ",
         "",
         "bar ",
         "",
         " ",
         "",
         { "fa.rich-text-fluid", { "?", { "fluid-name.water" }, "water" } },
         "",
         " ",
         "",
         " baz",
      }
      ctx:assert_table_equals(expected, result)
   end)

   it("should verbalize virtual signal tags", function(ctx)
      local result = RichText.verbalize_rich_text("[virtual-signal=signal-A]")
      local expected = {
         "",
         " ",
         "",
         { "fa.rich-text-virtual-signal", { "?", { "virtual-signal-name.signal-A" }, "signal-A" } },
      }
      ctx:assert_table_equals(expected, result)
   end)

   it("should verbalize wildcard signals", function(ctx)
      local result = RichText.verbalize_rich_text("[virtual-signal=signal-item-parameter]")
      local expected = { "", " ", "", { "fa.rich-text-wildcard-item" } }
      ctx:assert_table_equals(expected, result)
   end)

   it("should handle space-age tag", function(ctx)
      local result = RichText.verbalize_rich_text("[space-age] label")
      local expected = { "", " ", "", { "fa.rich-text-space-age" }, "", " ", "", " label" }
      ctx:assert_table_equals(expected, result)
   end)

   it("should pass through unknown tags", function(ctx)
      local result = RichText.verbalize_rich_text("[unknown-tag=foo] bar")
      local expected = { "", " ", "", "[unknown-tag=foo]", "", " ", "", " bar" }
      ctx:assert_table_equals(expected, result)
   end)

   it("should handle malformed tags", function(ctx)
      local result = RichText.verbalize_rich_text("[item=iron-plate bar")
      local expected = { "", " ", "", "[item=iron-plate bar" }
      ctx:assert_table_equals(expected, result)
   end)

   it("should ignore color and font tags", function(ctx)
      local result = RichText.verbalize_rich_text("[color=red]text[/color]")
      local expected = { "", " ", "", "text" }
      ctx:assert_table_equals(expected, result)
   end)

   it("should parse item shorthand", function(ctx)
      local expanded, errors = RichText.parse_rich_text_shorthand(":i.iron-plate foo")
      ctx:assert_equals("[item=iron-plate] foo", expanded)
      ctx:assert_equals(nil, errors)
   end)

   it("should parse fluid shorthand", function(ctx)
      local expanded, errors = RichText.parse_rich_text_shorthand(":f.water test")
      ctx:assert_equals("[fluid=water] test", expanded)
      ctx:assert_equals(nil, errors)
   end)

   it("should parse signal shorthand", function(ctx)
      local expanded, errors = RichText.parse_rich_text_shorthand(":s.signal-A")
      ctx:assert_equals("[virtual-signal=signal-A]", expanded)
      ctx:assert_equals(nil, errors)
   end)

   it("should parse wildcard item shorthand", function(ctx)
      local expanded, errors = RichText.parse_rich_text_shorthand(":*i station")
      ctx:assert_equals("[virtual-signal=signal-item-parameter] station", expanded)
      ctx:assert_equals(nil, errors)
   end)

   it("should parse wildcard fluid shorthand", function(ctx)
      local expanded, errors = RichText.parse_rich_text_shorthand(":*f depot")
      ctx:assert_equals("[virtual-signal=signal-fluid-parameter] depot", expanded)
      ctx:assert_equals(nil, errors)
   end)

   it("should parse wildcard fuel shorthand", function(ctx)
      local expanded, errors = RichText.parse_rich_text_shorthand(":*fu loading")
      ctx:assert_equals("[virtual-signal=signal-fuel-parameter] loading", expanded)
      ctx:assert_equals(nil, errors)
   end)

   it("should parse wildcard signal shorthand", function(ctx)
      local expanded, errors = RichText.parse_rich_text_shorthand(":*s handler")
      ctx:assert_equals("[virtual-signal=signal-signal-parameter] handler", expanded)
      ctx:assert_equals(nil, errors)
   end)

   it("should error on invalid prototype", function(ctx)
      local expanded, errors = RichText.parse_rich_text_shorthand(":i.invalid-item-name")
      ctx:assert_equals(":i.invalid-item-name", expanded)
      ctx:assert(errors ~= nil, "Should have errors")
      ctx:assert_equals(1, #errors)
   end)

   it("should handle multiple shorthands", function(ctx)
      local expanded, errors = RichText.parse_rich_text_shorthand(":i.iron-plate and :f.water")
      ctx:assert_equals("[item=iron-plate] and [fluid=water]", expanded)
      ctx:assert_equals(nil, errors)
   end)

   it("should preserve non-shorthand colons", function(ctx)
      local expanded, errors = RichText.parse_rich_text_shorthand("foo: bar")
      ctx:assert_equals("foo: bar", expanded)
      ctx:assert_equals(nil, errors)
   end)

   it("should handle text with no shorthands", function(ctx)
      local expanded, errors = RichText.parse_rich_text_shorthand("plain text")
      ctx:assert_equals("plain text", expanded)
      ctx:assert_equals(nil, errors)
   end)

   it("should handle mixed valid and invalid shorthands", function(ctx)
      local expanded, errors = RichText.parse_rich_text_shorthand(":i.iron-plate :i.bad-item :f.water")
      ctx:assert(errors ~= nil, "Should have errors")
      ctx:assert_equals(1, #errors)
   end)
end)
