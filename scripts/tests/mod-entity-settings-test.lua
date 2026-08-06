--[[
Tests for the settings other mods describe to us over the fa_settings_*
interface.

A schema is data from a mod we know nothing about, so validation is what stands
between that mod and the form builder.  These cover both sides of it: the field
kinds we render, and the malformed fields that must be refused by name rather
than crashing somewhere inside the UI.
]]

local ModEntitySettings = require("scripts.mod-entity-settings")
local TestRegistry = require("scripts.test-registry")
local describe = TestRegistry.describe
local it = TestRegistry.it

local INTERFACE = "test-provider"

local function boolean_field(name)
   return { kind = "boolean", name = name, label = { "fa.mod-entity-settings-title" } }
end

local function choice_field(name)
   return {
      kind = "choice",
      name = name,
      label = { "fa.mod-entity-settings-title" },
      choices = {
         { value = "basic", label = { "fa.mod-entity-settings-title" } },
         { value = "fast", label = { "fa.mod-entity-settings-title" } },
      },
   }
end

local function validate(...)
   ModEntitySettings.validate_schema(INTERFACE, { fields = { ... } })
end

describe("Mod Entity Settings", function()
   it("accepts the kinds we render", function(ctx)
      ctx:init(function()
         validate(boolean_field("landfill"), choice_field("belt_speed"))
      end)
   end)

   it("accepts an empty schema", function(ctx)
      ctx:init(function()
         validate()
      end)
   end)

   it("refuses kinds we do not render", function(ctx)
      ctx:init(function()
         -- number and label were offered once and are gone; nothing should be
         -- able to reach the form builder by asking for them again
         for _, kind in ipairs({ "number", "label", "textfield", "" }) do
            ctx:assert_error(function()
               validate({ kind = kind, name = "weight", label = { "fa.mod-entity-settings-title" }, min = 1, max = 10 })
            end, "expected the " .. kind .. " kind to be refused")
         end

         ctx:assert_error(function()
            validate({ name = "weight", label = { "fa.mod-entity-settings-title" } })
         end, "expected a field with no kind to be refused")
      end)
   end)

   it("names the interface at fault", function(ctx)
      ctx:init(function()
         local ok, err = pcall(validate, { kind = "number", name = "weight", label = { "x" } })
         ctx:assert_equals(false, ok, "expected validation to fail")
         ctx:assert_not_equals(nil, string.find(err, INTERFACE, 1, true), "error should name the interface")
         ctx:assert_not_equals(nil, string.find(err, "weight", 1, true), "error should name the field")
      end)
   end)

   it("requires a name and a label on every field", function(ctx)
      ctx:init(function()
         ctx:assert_error(function()
            validate({ kind = "boolean", label = { "fa.mod-entity-settings-title" } })
         end, "expected a field with no name to be refused")

         ctx:assert_error(function()
            validate({ kind = "boolean", name = "landfill" })
         end, "expected a field with no label to be refused")
      end)
   end)

   it("requires a choice field to offer choices", function(ctx)
      ctx:init(function()
         local empty = choice_field("belt_speed")
         empty.choices = {}
         ctx:assert_error(function()
            validate(empty)
         end, "expected an empty choice list to be refused")

         local missing = choice_field("belt_speed")
         missing.choices = nil
         ctx:assert_error(function()
            validate(missing)
         end, "expected a choice field with no list to be refused")

         local no_value = choice_field("belt_speed")
         no_value.choices[1].value = nil
         ctx:assert_error(function()
            validate(no_value)
         end, "expected a choice with no value to be refused")

         local no_label = choice_field("belt_speed")
         no_label.choices[2].label = nil
         ctx:assert_error(function()
            validate(no_label)
         end, "expected a choice with no label to be refused")
      end)
   end)

   it("offers only the kinds it validates", function(ctx)
      ctx:init(function()
         local sample = { boolean = boolean_field, choice = choice_field }
         local kinds = {}

         for _, kind in pairs(ModEntitySettings.FIELD_KIND) do
            -- every advertised kind must survive validation, or the enum and the
            -- boundary disagree about what a provider may send.  A kind added
            -- without a sample here fails rather than passing untested.
            ctx:assert_not_nil(sample[kind], "no sample field for advertised kind " .. kind)
            validate(sample[kind]("f"))
            kinds[kind] = true
         end

         ctx:assert_not_nil(kinds["boolean"], "boolean should be offered")
         ctx:assert_not_nil(kinds["choice"], "choice should be offered")
         ctx:assert_nil(kinds["number"], "number should no longer be offered")
         ctx:assert_nil(kinds["label"], "label should no longer be offered")
      end)
   end)
end)
