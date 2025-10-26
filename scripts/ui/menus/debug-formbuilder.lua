local TabList = require("scripts.ui.tab-list")
local UiRouter = require("scripts.ui.router")
local FormBuilder = require("scripts.ui.form-builder")
local KeyGraph = require("scripts.ui.key-graph")
local Speech = require("scripts.speech")
local MessageBuilder = Speech.MessageBuilder

local mod = {}

---@param ctx fa.ui.graph.Ctx
local function build_test_form(ctx)
   -- Initialize state if not present
   if not ctx.state.form_values then
      ctx.state.form_values = {
         test_checkbox = false,
         test_textfield = "Initial text",
         test_choice = "option1",
         test_checkbox2 = true,
         test_textfield2 = "",
         test_numbers = 10,
      }
   end

   -- Create builder (no state needed)
   local builder = FormBuilder.FormBuilder.new()

   -- Add a checkbox with getter and setter closures
   builder:add_checkbox(
      "test_checkbox",
      { "fa.form-test-checkbox" },
      function()
         return ctx.state.form_values.test_checkbox
      end, -- getter
      function(new_value) -- setter
         ctx.state.form_values.test_checkbox = new_value
      end
   )

   -- Add a textfield
   builder:add_textfield("test_textfield", {
      label = { "fa.form-test-textfield" },
      get_value = function()
         return ctx.state.form_values.test_textfield
      end,
      set_value = function(new_text)
         ctx.state.form_values.test_textfield = new_text
      end,
   })

   -- Add a choice field with several options
   builder:add_choice_field(
      "test_choice",
      { "fa.form-test-choice-label" },
      function()
         return ctx.state.form_values.test_choice
      end, -- getter
      function(new_value) -- setter
         ctx.state.form_values.test_choice = new_value
      end,
      {
         { label = { "fa.form-test-option1" }, value = "option1" },
         { label = { "fa.form-test-option2" }, value = "option2" },
         { label = { "fa.form-test-option3" }, value = "option3" },
         { label = { "fa.form-test-option4" }, value = "option4" },
      }
   )

   -- Add an action button that opens a child UI
   builder:add_action("test_action", { "fa.form-test-action" }, function(controller)
      ctx.controller.message:fragment({ "fa.debug-formbuilder-action-clicked" })
      controller:open_child_ui(UiRouter.UI_NAMES.ITEM_CHOOSER)
   end)

   -- Add another action that just announces
   builder:add_action("test_announce", { "fa.form-test-announce" }, function(controller)
      ctx.controller.message:fragment({ "fa.debug-formbuilder-announce" })
   end)

   -- Add another checkbox to test multiple checkboxes
   builder:add_checkbox(
      "test_checkbox2",
      { "fa.form-test-checkbox2" },
      function()
         return ctx.state.form_values.test_checkbox2
      end, -- getter
      function(new_value) -- setter
         ctx.state.form_values.test_checkbox2 = new_value
      end
   )

   -- Add a second textfield
   builder:add_textfield("test_textfield2", {
      label = { "fa.form-test-textfield2" },
      get_value = function()
         return ctx.state.form_values.test_textfield2
      end,
      set_value = function(new_text)
         ctx.state.form_values.test_textfield2 = new_text
      end,
   })

   -- Add a choice field with different types of values
   builder:add_choice_field(
      "test_numbers",
      { "fa.form-test-numbers-label" },
      function()
         return ctx.state.form_values.test_numbers
      end, -- getter
      function(new_value) -- setter
         ctx.state.form_values.test_numbers = new_value
      end,
      {
         { label = { "fa.form-test-ten" }, value = 10 },
         { label = { "fa.form-test-twenty" }, value = 20 },
         { label = { "fa.form-test-thirty" }, value = 30 },
      }
   )

   return builder:build()
end

local test_form_tab = KeyGraph.declare_graph({
   name = "debug_formbuilder",
   render_callback = build_test_form,
   title = { "fa.form-builder-test-title" },
})

mod.debug_formbuilder = TabList.declare_tablist({
   ui_name = UiRouter.UI_NAMES.DEBUG_FORMBUILDER,
   resets_to_first_tab_on_open = true,
   tabs_callback = function()
      return {
         {
            name = "form_test",
            tabs = { test_form_tab },
         },
      }
   end,
   on_child_result = function(self, pindex, result, context, controller)
      -- Results from child UIs (the form builder handles textbox results internally)
      if result then
         -- Handle results from other child UIs like item chooser
         controller.message:fragment({ "fa.debug-formbuilder-child-result", tostring(result) })
      end
   end,
})

UiRouter.register_ui(mod.debug_formbuilder)

return mod
