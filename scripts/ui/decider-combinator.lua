--Decider combinator UI for Factorio 2.0
--Provides editing interface for decider combinator conditions and outputs

local TabList = require("scripts.ui.tab-list")
local Router = require("scripts.ui.router")
local Menu = require("scripts.ui.menu")
local KeyGraph = require("scripts.ui.key-graph")
local CircuitNetworkSignals = require("scripts.ui.tabs.circuit-network-signals")
local CircuitNetwork = require("scripts.circuit-network")
local Speech = require("scripts.speech")
local MessageBuilder = Speech.MessageBuilder
local Help = require("scripts.ui.help")

local mod = {}

---Patch decider combinator parameters by getting, modifying, and setting
---@param entity LuaEntity
---@param closure fun(params: DeciderCombinatorParameters)
local function patch_parameters(entity, closure)
   local cb = entity.get_control_behavior()
   local params = cb.parameters
   closure(params)
   cb.parameters = params
end

---Get the key for a condition at index i
---@param i number
---@return string
local function get_condition_key(i)
   return "cond_" .. tostring(i)
end

---Get the key for an output at index i
---@param i number
---@return string
local function get_output_key(i)
   return "out_" .. tostring(i)
end

---Localise a CircuitNetworkSelection (red/green, or nothing for both)
---@param networks CircuitNetworkSelection?
---@return LocalisedString
local function localise_networks(networks)
   if not networks then return "" end
   local red = networks.red ~= false
   local green = networks.green ~= false
   if red and green then
      return "" -- Both is default, don't announce
   elseif red then
      return { "fa.decider-red-network" }
   elseif green then
      return { "fa.decider-green-network" }
   else
      return "" -- Both is default
   end
end

---Cycle to next network selection
---@param networks CircuitNetworkSelection?
---@return CircuitNetworkSelection
local function cycle_networks(networks)
   local red = not networks or networks.red ~= false
   local green = not networks or networks.green ~= false

   if red and green then
      return { red = true, green = false }
   elseif red then
      return { red = false, green = true }
   else
      return { red = true, green = true }
   end
end

---Localise a comparator string
---@param comparator ComparatorString?
---@return LocalisedString
local function localise_comparator(comparator)
   local comp = comparator or "<"
   local key_map = {
      ["<"] = "lt",
      ["≤"] = "lte",
      ["<="] = "lte",
      ["="] = "eq",
      ["≠"] = "ne",
      ["!="] = "ne",
      ["≥"] = "gte",
      [">="] = "gte",
      [">"] = "gt",
   }
   local key = "fa.comparator-" .. (key_map[comp] or "lt")
   return { key }
end

---Get next comparator (cycle forward)
---@param current ComparatorString?
---@return ComparatorString
local function next_comparator(current)
   local comparators = { "<", "≤", "=", "≠", "≥", ">" }
   local curr = current or "<"
   for i, comp in ipairs(comparators) do
      if comp == curr then return comparators[(i % #comparators) + 1] end
   end
   return "<"
end

---Get previous comparator (cycle backward)
---@param current ComparatorString?
---@return ComparatorString
local function prev_comparator(current)
   local comparators = { "<", "≤", "=", "≠", "≥", ">" }
   local curr = current or "<"
   for i, comp in ipairs(comparators) do
      if comp == curr then
         local prev_idx = i - 1
         if prev_idx < 1 then prev_idx = #comparators end
         return comparators[prev_idx]
      end
   end
   return "<"
end

---Read a single condition into a message builder
---@param mb fa.MessageBuilder
---@param condition DeciderCombinatorCondition
---@param include_connector boolean If true, prepends "and" or "or"
local function read_condition(mb, condition, include_connector)
   if include_connector then
      local connector = condition.compare_type or "or"
      mb:fragment({ "fa.decider-connector-" .. connector })
   end

   -- First signal with network
   if condition.first_signal and condition.first_signal.name then
      mb:fragment(CircuitNetwork.localise_signal(condition.first_signal))
      mb:fragment(localise_networks(condition.first_signal_networks))
   else
      mb:fragment({ "fa.decider-no-signal" })
   end

   -- Comparator
   mb:fragment(localise_comparator(condition.comparator))

   -- Second signal or constant
   if condition.second_signal and condition.second_signal.name then
      mb:fragment(CircuitNetwork.localise_signal(condition.second_signal))
      mb:fragment(localise_networks(condition.second_signal_networks))
   else
      local constant = condition.constant or 0
      mb:fragment(tostring(constant))
   end
end

---Read all conditions into a summary
---@param mb fa.MessageBuilder
---@param conditions DeciderCombinatorCondition[]
local function read_conditions_summary(mb, conditions)
   if #conditions == 0 then
      mb:list_item({ "fa.decider-no-conditions" })
      return
   end

   for i, condition in ipairs(conditions) do
      local include_connector = i > 1
      read_condition(mb, condition, include_connector)
      mb:list_item()
   end
end

---Read a single output into a message builder
---@param mb fa.MessageBuilder
---@param output DeciderCombinatorOutput
local function read_output(mb, output)
   -- Signal
   if output.signal and output.signal.name then
      mb:fragment(CircuitNetwork.localise_signal(output.signal))
   else
      mb:fragment({ "fa.decider-no-signal" })
   end

   -- Value source
   if output.copy_count_from_input ~= false then
      mb:fragment({ "fa.decider-copy-from-input" })
      mb:fragment(localise_networks(output.networks))
   else
      local constant = output.constant or 1
      mb:fragment(tostring(constant))
   end
end

---Read all outputs into a summary
---@param mb fa.MessageBuilder
---@param outputs DeciderCombinatorOutput[]
local function read_outputs_summary(mb, outputs)
   if #outputs == 0 then
      mb:list_item({ "fa.decider-no-outputs" })
      return
   end

   for _, output in ipairs(outputs) do
      read_output(mb, output)
      mb:list_item()
   end
end

---Read overall summary of decider combinator
---@param mb fa.MessageBuilder
---@param conditions DeciderCombinatorCondition[]
---@param outputs DeciderCombinatorOutput[]
local function read_overall_summary(mb, conditions, outputs)
   -- Outputs first
   mb:fragment({ "fa.decider-outputs-label" })
   read_outputs_summary(mb, outputs)

   -- Then conditions
   mb:fragment({ "fa.decider-if-label" })
   read_conditions_summary(mb, conditions)
end

---Render the decider combinator configuration
---@param ctx fa.ui.graph.Ctx
---@return fa.ui.graph.Render?
local function render_decider_config(ctx)
   local entity = ctx.global_parameters and ctx.global_parameters.entity
   assert(entity and entity.valid, "render_decider_config: entity is nil or invalid")

   local cb = entity.get_control_behavior() --[[@as LuaDeciderCombinatorControlBehavior]]
   assert(cb, "render_decider_config: no control behavior found")

   local params = cb.parameters
   local conditions = params and params.conditions or {}
   local outputs = params and params.outputs or {}

   local menu = Menu.MenuBuilder.new()

   -- Row 1: Overall summary
   menu:add_label("overall_summary", function(ctx)
      local mb = MessageBuilder.new()
      read_overall_summary(mb, conditions, outputs)
      ctx.message:fragment(mb:build())
   end)

   -- Row 2: Description
   menu:add_clickable("description", function(ctx)
      local desc = entity.combinator_description or ""
      ctx.message:fragment({ "fa.combinator-description" })
      ctx.message:fragment(desc)
   end, {
      on_click = function(ctx)
         local current_value = entity.combinator_description or ""
         ctx.controller:open_textbox(current_value, "description")
      end,
      on_child_result = function(ctx, result)
         entity.combinator_description = result
         ctx.controller.message:fragment({ "fa.combinator-description-updated" })
      end,
      on_clear = function(ctx)
         entity.combinator_description = ""
         ctx.controller.message:fragment({ "fa.cleared" })
      end,
   })

   -- Rows 2+: Conditions row
   menu:start_row("conditions_row")
   if #conditions == 0 then
      -- Empty placeholder - can add first condition with /
      menu:add_item("empty_conditions", {
         label = function(ctx)
            ctx.message:fragment({ "fa.decider-no-conditions" })
         end,
         on_add_to_row = function(ctx, modifiers)
            -- Add first condition with defaults
            patch_parameters(entity, function(params)
               table.insert(params.conditions, 1, {
                  comparator = "<",
                  constant = 0,
                  compare_type = "or",
               })
            end)
            ctx.controller.message:fragment({ "fa.decider-condition-added" })
            ctx.graph_controller:suggest_move(get_condition_key(1))
         end,
      })
   else
      -- Individual conditions
      for i, condition in ipairs(conditions) do
         local row_key = get_condition_key(i)

         -- Condition display and editing
         menu:add_item(row_key, {
            label = function(ctx)
               local mb = MessageBuilder.new()
               read_condition(mb, condition, i > 1)
               ctx.message:fragment(mb:build())
            end,

            -- n: Toggle conjunction (only for non-first conditions)
            on_conjunction_modification = function(ctx)
               if i == 1 then
                  ctx.controller.message:fragment({ "fa.error-cannot-modify-first-condition" })
                  return
               end

               patch_parameters(entity, function(params)
                  local cond = params.conditions[i]
                  cond.compare_type = (cond.compare_type == "and") and "or" or "and"
                  ctx.controller.message:fragment({ "fa.decider-connector-" .. cond.compare_type })
               end)
            end,

            -- m: Select first signal
            on_action1 = function(ctx, modifiers)
               if modifiers and modifiers.ctrl then
                  -- Ctrl+m: Cycle first signal networks
                  patch_parameters(entity, function(params)
                     local cond = params.conditions[i]
                     cond.first_signal_networks = cycle_networks(cond.first_signal_networks)
                     ctx.controller.message:fragment(localise_networks(cond.first_signal_networks))
                  end)
               else
                  -- m: Select first signal
                  ctx.controller:open_child_ui(
                     Router.UI_NAMES.SIGNAL_CHOOSER,
                     {},
                     { node = row_key, target = "first_signal" }
                  )
               end
            end,

            -- ,: Cycle comparator
            on_action2 = function(ctx, modifiers)
               patch_parameters(entity, function(params)
                  local cond = params.conditions[i]
                  if modifiers and modifiers.shift then
                     cond.comparator = prev_comparator(cond.comparator)
                  else
                     cond.comparator = next_comparator(cond.comparator)
                  end
                  ctx.controller.message:fragment(localise_comparator(cond.comparator))
               end)
            end,

            -- .: Set second parameter
            on_action3 = function(ctx, modifiers)
               if modifiers and modifiers.ctrl then
                  -- Ctrl+.: Cycle second signal networks
                  patch_parameters(entity, function(params)
                     local cond = params.conditions[i]
                     cond.second_signal_networks = cycle_networks(cond.second_signal_networks)
                     ctx.controller.message:fragment(localise_networks(cond.second_signal_networks))
                  end)
               elseif modifiers and modifiers.shift then
                  -- Shift+.: Set constant
                  local current_value = tostring(condition.constant or 0)
                  ctx.controller:open_textbox(
                     current_value,
                     { node = row_key, target = "constant" },
                     { "fa.decider-enter-constant" }
                  )
               else
                  -- .: Select second signal
                  ctx.controller:open_child_ui(
                     Router.UI_NAMES.SIGNAL_CHOOSER,
                     {},
                     { node = row_key, target = "second_signal" }
                  )
               end
            end,

            -- /: Add condition after this one
            on_add_to_row = function(ctx, modifiers)
               local compare_type = "and"
               if modifiers and modifiers.ctrl then compare_type = "or" end

               patch_parameters(entity, function(params)
                  table.insert(params.conditions, i + 1, {
                     comparator = "<",
                     constant = 0,
                     compare_type = compare_type,
                  })
               end)

               ctx.controller.message:fragment({ "fa.decider-connector-" .. compare_type })
               ctx.graph_controller:suggest_move(get_condition_key(i + 1))
            end,

            -- Backspace: Remove condition
            on_clear = function(ctx)
               patch_parameters(entity, function(params)
                  table.remove(params.conditions, i)
               end)
               ctx.controller.message:fragment({ "fa.decider-condition-removed" })
            end,

            -- Handle child results (signal selection or textbox)
            on_child_result = function(ctx, result)
               if not ctx.child_context then return end

               local target = ctx.child_context.target
               patch_parameters(entity, function(params)
                  local cond = params.conditions[i]

                  if target == "first_signal" then
                     cond.first_signal = result
                     ctx.controller.message:fragment(CircuitNetwork.localise_signal(result))
                  elseif target == "second_signal" then
                     cond.second_signal = result
                     cond.constant = nil
                     ctx.controller.message:fragment(CircuitNetwork.localise_signal(result))
                  elseif target == "constant" then
                     local num_value = tonumber(result)
                     if num_value then
                        cond.second_signal = nil
                        cond.constant = math.floor(num_value)
                        ctx.controller.message:fragment(tostring(cond.constant))
                     else
                        ctx.controller.message:fragment({ "fa.error-invalid-number" })
                     end
                  end
               end)
            end,
         })
      end
   end
   menu:end_row()

   -- Outputs row
   menu:start_row("outputs_row")
   if #outputs == 0 then
      -- Empty placeholder - can add first output with /
      menu:add_item("empty_outputs", {
         label = function(ctx)
            ctx.message:fragment({ "fa.decider-no-outputs" })
         end,
         on_add_to_row = function(ctx)
            patch_parameters(entity, function(params)
               table.insert(params.outputs, 1, {
                  constant = 1,
                  copy_count_from_input = false,
               })
            end)
            ctx.controller.message:fragment({ "fa.decider-output-added" })
            ctx.graph_controller:suggest_move(get_output_key(1))
         end,
      })
   else
      -- Individual outputs
      for i, output in ipairs(outputs) do
         local row_key = get_output_key(i)

         -- Output display and editing
         menu:add_item(row_key, {
            label = function(ctx)
               local mb = MessageBuilder.new()
               read_output(mb, output)
               ctx.message:fragment(mb:build())
            end,

            -- m: Select signal
            on_action1 = function(ctx)
               ctx.controller:open_child_ui(Router.UI_NAMES.SIGNAL_CHOOSER, {}, { node = row_key })
            end,

            -- ,: Cycle networks (only when copying from input)
            on_action2 = function(ctx, modifiers)
               patch_parameters(entity, function(params)
                  local out = params.outputs[i]
                  if out.copy_count_from_input ~= false then
                     out.networks = cycle_networks(out.networks)
                     ctx.controller.message:fragment(localise_networks(out.networks))
                  else
                     ctx.controller.message:fragment({ "fa.error-networks-only-when-copying" })
                  end
               end)
            end,

            -- .: Toggle copy from input or set constant
            on_action3 = function(ctx, modifiers)
               if modifiers and modifiers.shift then
                  -- Shift+.: Set constant (automatically clears copy_from_input)
                  local current_value = tostring(output.constant or 1)
                  ctx.controller:open_textbox(current_value, { node = row_key }, { "fa.decider-enter-constant" })
               else
                  -- .: Toggle copy from input
                  patch_parameters(entity, function(params)
                     local out = params.outputs[i]
                     out.copy_count_from_input = not (out.copy_count_from_input ~= false)
                     if out.copy_count_from_input then
                        out.networks = cycle_networks({})
                        out.constant = nil
                        ctx.controller.message:fragment({ "fa.decider-copy-from-input" })
                        ctx.controller.message:fragment(localise_networks(out.networks))
                     else
                        ctx.controller.message:fragment({ "fa.decider-constant-mode" })
                     end
                  end)
               end
            end,

            -- /: Add output after this one
            on_add_to_row = function(ctx)
               patch_parameters(entity, function(params)
                  table.insert(params.outputs, i + 1, {
                     constant = 1,
                     copy_count_from_input = false,
                  })
               end)

               ctx.controller.message:fragment({ "fa.decider-output-added" })
               ctx.graph_controller:suggest_move(get_output_key(i + 1))
            end,

            -- Backspace: Remove output
            on_clear = function(ctx)
               patch_parameters(entity, function(params)
                  table.remove(params.outputs, i)
               end)
               ctx.controller.message:fragment({ "fa.decider-output-removed" })
            end,

            -- Handle child results (signal selection or textbox)
            on_child_result = function(ctx, result)
               patch_parameters(entity, function(params)
                  local out = params.outputs[i]

                  if type(result) == "table" and result.name then
                     -- Signal selected
                     out.signal = result
                     ctx.controller.message:fragment(CircuitNetwork.localise_signal(result))
                  elseif type(result) == "string" then
                     -- Constant set from textbox (automatically clears copy_from_input)
                     local num_value = tonumber(result)
                     if num_value then
                        out.constant = math.floor(num_value)
                        out.copy_count_from_input = false
                        ctx.controller.message:fragment(tostring(out.constant))
                     else
                        ctx.controller.message:fragment({ "fa.error-invalid-number" })
                     end
                  end
               end)
            end,
         })
      end
   end
   menu:end_row()

   return menu:build()
end

---Build tabs for the decider combinator
---@param pindex number
---@param parameters any
---@return fa.ui.TabstopDescriptor[]
local function build_decider_combinator_tabs(pindex, parameters)
   assert(parameters, "build_decider_combinator_tabs: parameters is nil")
   local entity = parameters.entity
   assert(entity, "build_decider_combinator_tabs: entity is nil")
   assert(entity.valid, "build_decider_combinator_tabs: entity is not valid")

   -- Tabstop 1: Main (Config, Circuit signals)
   local main_tabs = {}

   -- Config tab (conditions and outputs in one view)
   table.insert(
      main_tabs,
      KeyGraph.declare_graph({
         name = "config",
         title = { "fa.decider-config-title" },
         render_callback = render_decider_config,
         get_help_metadata = function()
            return {
               Help.message_list("decider-combinator-conditions"),
               Help.message_list("decider-combinator-outputs"),
            }
         end,
      })
   )

   -- Circuit network signals tabs (red and green)
   table.insert(
      main_tabs,
      CircuitNetworkSignals.create_signals_tab(
         { "fa.circuit-network-signals-red" },
         false,
         defines.wire_connector_id.circuit_red
      )
   )
   table.insert(
      main_tabs,
      CircuitNetworkSignals.create_signals_tab(
         { "fa.circuit-network-signals-green" },
         false,
         defines.wire_connector_id.circuit_green
      )
   )

   return {
      {
         name = "main",
         tabs = main_tabs,
      },
   }
end

---Create and register the decider combinator UI
mod.decider_combinator_ui = TabList.declare_tablist({
   ui_name = Router.UI_NAMES.DECIDER_COMBINATOR,
   resets_to_first_tab_on_open = true,
   tabs_callback = build_decider_combinator_tabs,
})

Router.register_ui(mod.decider_combinator_ui)

return mod
