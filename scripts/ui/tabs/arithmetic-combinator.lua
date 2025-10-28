---@diagnostic disable: inject-field
-- LuaLS incorrectly believes ArithmeticCombinatorParameters fields cannot be modified.

--[[
Arithmetic combinator configuration tab for Factorio 2.0.

Provides a configuration form for arithmetic combinators.
]]

local FormBuilder = require("scripts.ui.form-builder")
local UiKeyGraph = require("scripts.ui.key-graph")
local UiRouter = require("scripts.ui.router")
local UiSounds = require("scripts.ui.sounds")
local CircuitNetwork = require("scripts.circuit-network")

local mod = {}

-- Arithmetic operations in order for cycling
local OPERATIONS = { "*", "/", "+", "-", "%", "^", "<<", ">>", "AND", "OR", "XOR" }

-- Map operations to locale keys
local OPERATION_LOCALE_KEYS = {
   ["*"] = { "fa.arithmetic-op-multiply" },
   ["/"] = { "fa.arithmetic-op-divide" },
   ["+"] = { "fa.arithmetic-op-add" },
   ["-"] = { "fa.arithmetic-op-subtract" },
   ["%"] = { "fa.arithmetic-op-modulo" },
   ["^"] = { "fa.arithmetic-op-power" },
   ["<<"] = { "fa.arithmetic-op-left-shift" },
   [">>"] = { "fa.arithmetic-op-right-shift" },
   ["AND"] = { "fa.arithmetic-op-and" },
   ["OR"] = { "fa.arithmetic-op-or" },
   ["XOR"] = { "fa.arithmetic-op-xor" },
}

---Add signal or constant input with network selection
---@param builder fa.ui.form.FormBuilder
---@param params ArithmeticCombinatorParameters
---@param cb LuaArithmeticCombinatorControlBehavior
---@param is_first boolean True for first input, false for second
local function add_input_field(builder, params, cb, is_first)
   local prefix = is_first and "first" or "second"
   local field_name = prefix .. "_input"
   local signal_field = prefix .. "_signal"
   local constant_field = prefix .. "_constant"
   local networks_field = prefix .. "_signal_networks"

   builder:start_row(field_name .. "_row")

   -- Input value (signal or constant)
   builder:add_item(field_name, {
      label = function(ctx)
         local label_key = is_first and "fa.arithmetic-first-input" or "fa.arithmetic-second-input"
         ctx.message:fragment({ label_key })

         if params[signal_field] and params[signal_field].name then
            local signal_name = CircuitNetwork.localise_signal(params[signal_field])
            ctx.message:fragment(signal_name)
         else
            local value = params[constant_field] or 0
            ctx.message:fragment(tostring(value))
         end
         ctx.message:fragment({ "fa.arithmetic-input-instructions" })
      end,
      on_click = function(ctx)
         ctx.controller:open_child_ui(UiRouter.UI_NAMES.SIGNAL_CHOOSER, {}, { node = field_name })
      end,
      on_child_result = function(ctx, result)
         if type(result) == "string" then
            local num = tonumber(result)
            if num and math.floor(num) == num then
               params[constant_field] = num
               params[signal_field] = nil
               cb.parameters = params
               ctx.controller.message:fragment(tostring(num))
            else
               UiSounds.play_ui_edge(ctx.pindex)
               ctx.controller.message:fragment({ "fa.arithmetic-input-invalid" })
            end
         else
            params[signal_field] = result
            params[constant_field] = 0
            cb.parameters = params
            if result and result.name then
               ctx.controller.message:fragment(CircuitNetwork.localise_signal(result))
            else
               ctx.controller.message:fragment({ "fa.empty" })
            end
         end
      end,
      on_action1 = function(ctx)
         local current_value = params[constant_field] or 0
         ctx.controller:open_textbox(tostring(current_value), field_name)
      end,
      on_clear = function(ctx)
         params[signal_field] = nil
         params[constant_field] = 0
         cb.parameters = params
         ctx.controller.message:fragment("0")
      end,
   })

   -- Only show network selection if a signal is selected
   if params[signal_field] and params[signal_field].name then
      local networks = params[networks_field] or { red = true, green = true }

      builder:add_checkbox(field_name .. "_red", { "fa.arithmetic-red-network" }, function()
         return networks.red ~= false
      end, function(value)
         if not params[networks_field] then params[networks_field] = { red = true, green = true } end
         params[networks_field].red = value
         cb.parameters = params
      end)

      builder:add_checkbox(field_name .. "_green", { "fa.arithmetic-green-network" }, function()
         return networks.green ~= false
      end, function(value)
         if not params[networks_field] then params[networks_field] = { red = true, green = true } end
         params[networks_field].green = value
         cb.parameters = params
      end)
   end

   builder:end_row()
end

---@class fa.ui.ArithmeticCombinatorTabContext: fa.ui.TabContext
---@field tablist_shared_state fa.ui.EntityUI.SharedState

---Render the arithmetic combinator configuration form
---@param ctx fa.ui.ArithmeticCombinatorTabContext
---@return fa.ui.graph.Render?
local function render_arithmetic_config(ctx)
   local entity = ctx.tablist_shared_state.entity
   if not entity or not entity.valid then return nil end
   assert(entity.type == "arithmetic-combinator", "render: entity is not an arithmetic-combinator")

   local cb = entity.get_control_behavior() --[[@as LuaArithmeticCombinatorControlBehavior]]
   if not cb then return nil end

   local builder = FormBuilder.FormBuilder.new()

   -- Description field
   builder:add_textfield("description", {
      label = { "fa.combinator-description" },
      get_value = function()
         return entity.combinator_description or ""
      end,
      set_value = function(value)
         entity.combinator_description = value
      end,
      on_clear = function(ctx)
         entity.combinator_description = ""
         ctx.controller.message:fragment({ "fa.cleared" })
      end,
   })

   -- Get current parameters or create default
   local params = cb.parameters or { operation = "*" }

   -- First input
   add_input_field(builder, params, cb, true)

   -- Operation selector
   builder:add_item("operation", {
      label = function(ctx)
         local op = params.operation or "*"
         local locale_key = OPERATION_LOCALE_KEYS[op] or { "fa.arithmetic-op-multiply" }
         ctx.message:fragment({ "fa.arithmetic-operation" })
         ctx.message:fragment(locale_key)
         ctx.message:fragment({ "fa.arithmetic-operation-instructions" })
      end,
      on_click = function(ctx)
         local current_op = params.operation or "*"
         local current_index = 1
         for i, op in ipairs(OPERATIONS) do
            if op == current_op then
               current_index = i
               break
            end
         end
         local next_index = (current_index % #OPERATIONS) + 1
         params.operation = OPERATIONS[next_index]
         cb.parameters = params
         local locale_key = OPERATION_LOCALE_KEYS[params.operation]
         ctx.controller.message:fragment(locale_key)
      end,
      on_right_click = function(ctx)
         local current_op = params.operation or "*"
         local current_index = 1
         for i, op in ipairs(OPERATIONS) do
            if op == current_op then
               current_index = i
               break
            end
         end
         local prev_index = ((current_index - 2) % #OPERATIONS) + 1
         params.operation = OPERATIONS[prev_index]
         cb.parameters = params
         local locale_key = OPERATION_LOCALE_KEYS[params.operation]
         ctx.controller.message:fragment(locale_key)
      end,
   })

   -- Second input
   add_input_field(builder, params, cb, false)

   -- Output signal
   builder:add_signal("output_signal", { "fa.arithmetic-output-signal" }, function()
      return params.output_signal
   end, function(value)
      params.output_signal = value
      cb.parameters = params
   end)

   return builder:build()
end

-- Create the tab descriptor
mod.arithmetic_combinator_tab = UiKeyGraph.declare_graph({
   name = "arithmetic-combinator-config",
   title = { "fa.arithmetic-combinator-config-title" },
   render_callback = render_arithmetic_config,
})

return mod
