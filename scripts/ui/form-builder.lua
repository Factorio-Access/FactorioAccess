---@diagnostic disable: inject-field
-- LuaLS incorrectly believes CircuitConditionDefinition lacks first_signal, second_signal,
-- constant, and comparator fields. These fields are documented in the Factorio API and exist
-- as optional fields on CircuitConditionDefinition. See llm-docs/api-reference/runtime/concepts/CircuitConditionDefinition.md

local Menu = require("scripts.ui.menu")
local UiUtils = require("scripts.ui.ui-utils")
local UiSounds = require("scripts.ui.sounds")
local Speech = require("scripts.speech")
local UiRouter = require("scripts.ui.router")
local CircuitNetwork = require("scripts.circuit-network")

local mod = {}

---@class (exact) fa.ui.form.BarConfig
---@field label LocalisedString | fun(fa.ui.graph.Ctx): LocalisedString
---@field get_value fun(): number
---@field set_value fun(number)
---@field min_value number
---@field max_value number
---@field small_step number?
---@field large_step number?

---@class (exact) fa.FormBuilder.TextBoxParams
---@field label LocalisedString | fun(fa.ui.graph.Ctx): LocalisedString
---@field get_value fun(): string
---@field set_value fun(string)
---@field on_clear (fun(fa.ui.graph.Ctx))? Optional clear callback (triggered by backspace)

---@class fa.ui.form.FormBuilder
---@field operations fun(fa.ui.menu.MenuBuilder)[] Sequence of closures to apply to MenuBuilder
---@field vtables fa.ui.graph.NodeVtable[] Vtables for accelerator handler attachment
---@field accelerator_handler fun(ctx: fa.ui.graph.Ctx, accelerator_name: string)? Form-wide accelerator handler
local FormBuilder = {}
local FormBuilder_meta = { __index = FormBuilder }

---Create a new form builder
---@return fa.ui.form.FormBuilder
function FormBuilder.new()
   return setmetatable({
      operations = {},
      vtables = {},
      accelerator_handler = nil,
   }, FormBuilder_meta)
end

---Set a form-wide accelerator handler that will be attached to all nodes
---@param handler fun(ctx: fa.ui.graph.Ctx, accelerator_name: string)
---@return fa.ui.form.FormBuilder
function FormBuilder:set_accelerator_handler(handler)
   self.accelerator_handler = handler
   return self
end

---Add a label (non-interactive display item)
---@param key string Unique identifier
---@param label LocalisedString | fun(fa.ui.graph.Ctx): LocalisedString
---@return fa.ui.form.FormBuilder
function FormBuilder:add_label(key, label)
   self:add_item(key, {
      label = UiUtils.to_label_function(label),
   })
   return self
end

---Add a checkbox control
---@param name string Unique identifier for this control
---@param label LocalisedString | fun(fa.ui.graph.Ctx): LocalisedString
---@param get_value fun(): boolean Function that returns the current value
---@param set_value fun(boolean) Function that sets the new value
---@return fa.ui.form.FormBuilder
function FormBuilder:add_checkbox(name, label, get_value, set_value)
   -- Create label builder function that uses the getter
   local function build_label(message, ctx)
      local base_label = UiUtils.to_label_function(label)(ctx)
      local state_text = get_value() and { "fa.checked" } or { "fa.unchecked" }
      message:fragment(state_text)
      message:fragment(base_label)
   end

   self:add_item(name, {
      label = function(ctx)
         build_label(ctx.message, ctx)
      end,
      on_click = function(ctx)
         local new_val = not get_value()
         set_value(new_val)
         UiSounds.play_menu_move(ctx.pindex)
         -- Only announce the new state, not the label
         local state_text = new_val and { "fa.checked" } or { "fa.unchecked" }
         ctx.controller.message:fragment(state_text)
      end,
   })

   return self
end

---Add a textfield control
---@param name string Unique identifier for this control
---@param params fa.FormBuilder.TextBoxParams
---@return fa.ui.form.FormBuilder
function FormBuilder:add_textfield(name, params)
   -- Create label builder function that uses the getter
   local function build_label(message, ctx)
      local base_label = UiUtils.to_label_function(params.label)(ctx)
      local val = params.get_value()
      local value_text = val and val ~= "" and val or { "fa.empty" }
      message:fragment(value_text)
      message:fragment(base_label)
   end

   local vtable = {
      label = function(ctx)
         build_label(ctx.message, ctx)
      end,
      on_click = function(ctx)
         -- Pass the node key as the context so Graph can route the result back
         ctx.controller:open_textbox(params.get_value() or "", name)
      end,
      on_child_result = function(ctx, result)
         -- This will be called when textbox returns
         params.set_value(result)
         -- Only announce the new value
         local value_text = result ~= "" and result or { "fa.empty" }
         ctx.controller.message:fragment(value_text)
      end,
   }

   -- Add clear callback if provided
   if params.on_clear then vtable.on_clear = params.on_clear end

   self:add_item(name, vtable)

   return self
end

---Add a choice field control
---@param name string Unique identifier for this control
---@param label LocalisedString | fun(fa.ui.graph.Ctx): LocalisedString
---@param get_value fun(): any Function that returns the current value
---@param set_value fun(any) Function that sets the new value
---@param choices {label: LocalisedString, value: any, default: boolean?}[] Array of choices
---@return fa.ui.form.FormBuilder
function FormBuilder:add_choice_field(name, label, get_value, set_value, choices)
   assert(#choices > 0, "Choice field must have at least one choice")

   local function find_current_index()
      local current = get_value()
      for i, choice in ipairs(choices) do
         if choice.value == current then return i end
      end
      -- Value not found, look for default
      for i, choice in ipairs(choices) do
         if choice.default then
            set_value(choice.value)
            return i
         end
      end
      error(string.format("Current value '%s' not found in choices for field '%s'", tostring(current), name))
   end

   local function get_current_label()
      local index = find_current_index()
      return choices[index].label
   end

   -- Create label builder function that uses the getter
   local function build_label(message, ctx)
      local base_label = UiUtils.to_label_function(label)(ctx)
      message:fragment(get_current_label())
      message:fragment(base_label)
   end

   self:add_item(name, {
      label = function(ctx)
         build_label(ctx.message, ctx)
      end,
      on_click = function(ctx)
         local current_index = find_current_index()
         local direction = (ctx.modifiers and ctx.modifiers.shift) and -1 or 1
         local new_index = current_index + direction

         if new_index > #choices then
            new_index = 1
         elseif new_index < 1 then
            new_index = #choices
         end

         set_value(choices[new_index].value)
         UiSounds.play_menu_move(ctx.pindex)
         -- Only announce the new choice, not the full label
         ctx.controller.message:fragment(choices[new_index].label)
      end,
   })

   return self
end

---Add an action button
---@param name string Unique identifier for this control
---@param label LocalisedString | fun(fa.ui.graph.Ctx): LocalisedString
---@param callback fun(fa.ui.RouterController) Called when clicked, receives the controller
---@return fa.ui.form.FormBuilder
function FormBuilder:add_action(name, label, callback)
   self:add_item(name, {
      label = UiUtils.to_label_function(label),
      on_click = function(ctx)
         UiSounds.play_menu_move(ctx.pindex)
         callback(ctx.controller)
      end,
   })

   return self
end

---Add a bar control (numeric value adjustable with +/- keys)
---@param name string Unique identifier for this control
---@param config fa.ui.form.BarConfig
---@return fa.ui.form.FormBuilder
function FormBuilder:add_bar(name, config)
   local small_step = config.small_step or 1
   local large_step = config.large_step or 5

   -- Helper to announce value change
   local function announce_value(ctx, new_value)
      ctx.controller.message:fragment(tostring(new_value))
   end

   -- Helper to adjust value
   local function adjust_value(ctx, delta)
      local current = config.get_value()
      local new_value = math.max(config.min_value, math.min(config.max_value, current + delta))
      if new_value ~= current then
         config.set_value(new_value)
         UiSounds.play_menu_move(ctx.pindex)
         announce_value(ctx, new_value)
      else
         UiSounds.play_ui_edge(ctx.pindex)
         announce_value(ctx, new_value)
      end
   end

   -- Create label builder function
   local function build_label(message, ctx)
      local base_label = UiUtils.to_label_function(config.label)(ctx)
      local value = config.get_value()
      message:fragment(tostring(value))
      message:fragment(base_label)
   end

   self:add_item(name, {
      label = function(ctx)
         build_label(ctx.message, ctx)
      end,
      on_bar_up_small = function(ctx)
         adjust_value(ctx, small_step)
      end,
      on_bar_down_small = function(ctx)
         adjust_value(ctx, -small_step)
      end,
      on_bar_up_large = function(ctx)
         adjust_value(ctx, large_step)
      end,
      on_bar_down_large = function(ctx)
         adjust_value(ctx, -large_step)
      end,
      on_bar_max = function(ctx)
         local current = config.get_value()
         if current ~= config.max_value then
            config.set_value(config.max_value)
            UiSounds.play_menu_move(ctx.pindex)
            announce_value(ctx, config.max_value)
         else
            UiSounds.play_ui_edge(ctx.pindex)
            announce_value(ctx, config.max_value)
         end
      end,
      on_bar_min = function(ctx)
         local current = config.get_value()
         if current ~= config.min_value then
            config.set_value(config.min_value)
            UiSounds.play_menu_move(ctx.pindex)
            announce_value(ctx, config.min_value)
         else
            UiSounds.play_ui_edge(ctx.pindex)
            announce_value(ctx, config.min_value)
         end
      end,
   })

   return self
end

---Add a signal selector field
---@param name string Unique identifier for this control
---@param label LocalisedString | fun(fa.ui.graph.Ctx): LocalisedString
---@param get_value fun(): SignalID? Function that returns the current signal
---@param set_value fun(SignalID?) Function that sets the new signal
---@return fa.ui.form.FormBuilder
function FormBuilder:add_signal(name, label, get_value, set_value)
   -- Create label builder function that uses the getter
   local function build_label(message, ctx)
      local base_label = UiUtils.to_label_function(label)(ctx)
      local signal = get_value()
      local value_text
      if signal and signal.name then
         -- Show signal type and name
         local signal_type = signal.type or "item"
         value_text = { "fa.signal-type-name", signal_type, signal.name }
      else
         value_text = { "fa.empty" }
      end
      message:fragment(value_text)
      message:fragment(base_label)
   end

   self:add_item(name, {
      label = function(ctx)
         build_label(ctx.message, ctx)
      end,
      on_click = function(ctx)
         -- Open signal chooser
         ctx.controller:open_child_ui(UiRouter.UI_NAMES.SIGNAL_CHOOSER, {}, { node = name })
      end,
      on_child_result = function(ctx, result)
         -- Signal chooser returns SignalID or nil
         set_value(result)
         -- Announce the new value
         if result and result.name then
            local signal_type = result.type or "item"
            ctx.controller.message:fragment({ "fa.signal-type-name", signal_type, result.name })
         else
            ctx.controller.message:fragment({ "fa.empty" })
         end
      end,
      on_clear = function(ctx)
         -- Clear the signal
         set_value(nil)
         ctx.controller.message:fragment({ "fa.empty" })
      end,
   })

   return self
end

---Add a circuit condition field (complex row with 4 items)
---@param name string Unique identifier for this control
---@param get_value fun(): CircuitConditionDefinition? Function that returns the current condition
---@param set_value fun(CircuitConditionDefinition?) Function that sets the new condition
---@return fa.ui.form.FormBuilder
function FormBuilder:add_condition(name, get_value, set_value)
   -- Helper to build a description of the condition
   local function describe_condition(condition)
      local mb = Speech.MessageBuilder.new()
      CircuitNetwork.read_condition(mb, condition)
      return mb:build()
   end

   -- Item 1: Overview
   self:start_row(name)
   self:add_item(name .. "_overview", {
      label = function(ctx)
         local condition = get_value()
         ctx.message:fragment(describe_condition(condition))
         if not condition or not condition.first_signal or not condition.first_signal.name then
            ctx.message:fragment({ "fa.condition-move-right-to-configure" })
         end
      end,
   })

   -- Item 2: First signal
   self:add_item(name .. "_first", {
      label = function(ctx)
         local condition = get_value() or {}
         local signal = condition.first_signal
         if signal and signal.name then
            local signal_type = signal.type or "item"
            ctx.message:fragment({ "fa.signal-type-name", signal_type, signal.name })
            ctx.message:fragment({ "fa.condition-first-signal" })
         else
            ctx.message:fragment({ "fa.condition-first-signal-empty" })
         end
      end,
      on_click = function(ctx)
         ctx.controller:open_child_ui(UiRouter.UI_NAMES.SIGNAL_CHOOSER, {}, { node = name .. "_first" })
      end,
      on_child_result = function(ctx, result)
         local condition = get_value() or {}
         condition.first_signal = result
         set_value(condition)
         if result and result.name then
            local signal_type = result.type or "item"
            ctx.controller.message:fragment({ "fa.signal-type-name", signal_type, result.name })
         else
            ctx.controller.message:fragment({ "fa.empty" })
         end
      end,
      on_clear = function(ctx)
         local condition = get_value() or {}
         ---@diagnostic disable-next-line: inject-field
         condition.first_signal = nil
         set_value(condition)
         ctx.controller.message:fragment({ "fa.empty" })
      end,
   })

   -- Item 3: Operator
   self:add_item(name .. "_op", {
      label = function(ctx)
         local condition = get_value() or {}
         ctx.message:fragment({ "fa.condition-operator" })

         ctx.message:fragment(CircuitNetwork.localise_comparator(condition.comparator or "<"))
      end,
      on_click = function(ctx)
         local condition = get_value() or {}

         -- Check if first signal is configured
         if not condition.first_signal or not condition.first_signal.name then
            UiSounds.play_ui_edge(ctx.pindex)
            ctx.controller.message:fragment({ "fa.condition-error-first-signal-required" })
            return
         end

         -- Cycle comparator
         local current = condition.comparator or "<"
         local new_comparator
         if ctx.modifiers and ctx.modifiers.shift then
            new_comparator = CircuitNetwork.get_prev_comparison_operator(current)
         else
            new_comparator = CircuitNetwork.get_next_comparison_operator(current)
         end

         ---@diagnostic disable-next-line: inject-field
         condition.comparator = new_comparator
         set_value(condition)
         UiSounds.play_menu_move(ctx.pindex)
         ctx.controller.message:fragment(CircuitNetwork.localise_comparator(new_comparator))
      end,
   })

   -- Item 4: Second signal/constant (hybrid)
   self:add_item(name .. "_second", {
      label = function(ctx)
         local condition = get_value() or {}
         if condition.second_signal and condition.second_signal.name then
            local signal_type = condition.second_signal.type or "item"
            ctx.message:fragment({ "fa.signal-type-name", signal_type, condition.second_signal.name })
         elseif condition.constant then
            ctx.message:fragment(tostring(condition.constant))
         else
            ctx.message:fragment("0")
         end

         ctx.message:fragment({ "fa.condition-second" })
         -- Always show help text
         ctx.message:fragment({ "fa.condition-second-help" })
      end,
      on_child_result = function(ctx, result)
         local condition = get_value() or {}

         -- Check context to determine if this is constant or signal
         if type(ctx.child_context) == "table" and ctx.child_context.type == "constant" then
            -- Result is a string from textbox
            local num = tonumber(result)
            if num then
               ---@diagnostic disable-next-line: inject-field
               condition.constant = num
               ---@diagnostic disable-next-line: inject-field
               condition.second_signal = nil
               set_value(condition)
               ctx.controller.message:fragment(tostring(num))
            else
               UiSounds.play_ui_edge(ctx.pindex)
               ctx.controller.message:fragment({ "fa.condition-error-invalid-number" })
            end
         else
            -- Result is a SignalID from signal chooser
            ---@diagnostic disable-next-line: inject-field
            condition.second_signal = result
            ---@diagnostic disable-next-line: inject-field
            condition.constant = nil
            set_value(condition)
            if result and result.name then
               local signal_type = result.type or "item"
               ctx.controller.message:fragment({ "fa.signal-type-name", signal_type, result.name })
            else
               ctx.controller.message:fragment({ "fa.empty" })
            end
         end
      end,
      on_click = function(ctx)
         local condition = get_value() or {}

         -- Check prerequisites
         if not condition.first_signal or not condition.first_signal.name then
            UiSounds.play_ui_edge(ctx.pindex)
            ctx.controller.message:fragment({ "fa.condition-error-first-signal-required" })
            return
         end
         if not condition.comparator then
            UiSounds.play_ui_edge(ctx.pindex)
            ctx.controller.message:fragment({ "fa.condition-error-operator-required" })
            return
         end

         -- Open signal selector
         ctx.controller:open_child_ui(
            UiRouter.UI_NAMES.SIGNAL_CHOOSER,
            {},
            { node = name .. "_second", type = "signal" }
         )
      end,
      on_action1 = function(ctx)
         local condition = get_value() or {}

         -- Check prerequisites
         if not condition.first_signal or not condition.first_signal.name then
            UiSounds.play_ui_edge(ctx.pindex)
            ctx.controller.message:fragment({ "fa.condition-error-first-signal-required" })
            return
         end
         if not condition.comparator then
            UiSounds.play_ui_edge(ctx.pindex)
            ctx.controller.message:fragment({ "fa.condition-error-operator-required" })
            return
         end

         -- Open textbox for constant
         local current_value = condition.constant or 0
         ctx.controller:open_textbox(tostring(current_value), { node = name .. "_second", type = "constant" })
      end,
      on_clear = function(ctx)
         local condition = get_value() or {}
         ---@diagnostic disable-next-line: inject-field
         condition.second_signal = nil
         ---@diagnostic disable-next-line: inject-field
         condition.constant = 0
         set_value(condition)
         ctx.controller.message:fragment("0")
      end,
   })
   self:end_row()

   return self
end

---Add a circuit condition with enable/disable toggle (complex row with 4 items)
---@param name string Unique identifier for this control
---@param get_enabled fun(): boolean Function that returns whether condition is enabled
---@param set_enabled fun(boolean) Function that sets whether condition is enabled
---@param get_condition fun(): CircuitConditionDefinition? Function that returns the current condition
---@param set_condition fun(CircuitConditionDefinition?) Function that sets the new condition
---@return fa.ui.form.FormBuilder
function FormBuilder:add_condition_with_enable(name, label, get_enabled, set_enabled, get_condition, set_condition)
   -- Helper to build a description of the condition
   local function describe_condition(condition)
      local mb = Speech.MessageBuilder.new()
      CircuitNetwork.read_condition(mb, condition)
      return mb:build()
   end

   -- Item 1: Overview + enable/disable toggle
   self:start_row(name)
   self:add_item(name .. "_overview", {
      label = function(ctx)
         local base_label = UiUtils.to_label_function(label)(ctx)
         local enabled = get_enabled()
         local state_text = enabled and { "fa.checked" } or { "fa.unchecked" }
         local condition = get_condition()

         ctx.message:fragment(state_text)
         ctx.message:fragment(base_label)
         ctx.message:fragment(describe_condition(condition))
         if not condition or not condition.first_signal or not condition.first_signal.name then
            ctx.message:fragment({ "fa.condition-move-right-to-configure" })
         end
      end,
      on_click = function(ctx)
         local new_val = not get_enabled()
         set_enabled(new_val)
         UiSounds.play_menu_move(ctx.pindex)
         local state_text = new_val and { "fa.checked" } or { "fa.unchecked" }
         ctx.controller.message:fragment(state_text)
      end,
   })

   -- Item 2: First signal
   self:add_item(name .. "_first", {
      label = function(ctx)
         local condition = get_condition() or {}
         local signal = condition.first_signal
         if signal and signal.name then
            local signal_type = signal.type or "item"
            ctx.message:fragment({ "fa.signal-type-name", signal_type, signal.name })
            ctx.message:fragment({ "fa.condition-first-signal" })
         else
            ctx.message:fragment({ "fa.condition-first-signal-empty" })
         end
      end,
      on_click = function(ctx)
         ctx.controller:open_child_ui(UiRouter.UI_NAMES.SIGNAL_CHOOSER, {}, { node = name .. "_first" })
      end,
      on_child_result = function(ctx, result)
         local condition = get_condition() or {}
         ---@diagnostic disable-next-line: inject-field
         condition.first_signal = result
         set_condition(condition)
         if result and result.name then
            local signal_type = result.type or "item"
            ctx.controller.message:fragment({ "fa.signal-type-name", signal_type, result.name })
         else
            ctx.controller.message:fragment({ "fa.empty" })
         end
      end,
      on_clear = function(ctx)
         local condition = get_condition() or {}
         ---@diagnostic disable-next-line: inject-field
         condition.first_signal = nil
         set_condition(condition)
         ctx.controller.message:fragment({ "fa.empty" })
      end,
   })

   -- Item 3: Operator
   self:add_item(name .. "_op", {
      label = function(ctx)
         local condition = get_condition() or {}
         ctx.message:fragment({ "fa.condition-operator" })

         ctx.message:fragment(CircuitNetwork.localise_comparator(condition.comparator or "<"))
      end,
      on_click = function(ctx)
         local condition = get_condition() or {}

         -- Check if first signal is configured
         if not condition.first_signal or not condition.first_signal.name then
            UiSounds.play_ui_edge(ctx.pindex)
            ctx.controller.message:fragment({ "fa.condition-error-first-signal-required" })
            return
         end

         -- Cycle comparator
         local current = condition.comparator or "<"
         local new_comparator
         if ctx.modifiers and ctx.modifiers.shift then
            new_comparator = CircuitNetwork.get_prev_comparison_operator(current)
         else
            new_comparator = CircuitNetwork.get_next_comparison_operator(current)
         end

         ---@diagnostic disable-next-line: inject-field
         condition.comparator = new_comparator
         set_condition(condition)
         UiSounds.play_menu_move(ctx.pindex)
         ctx.controller.message:fragment(CircuitNetwork.localise_comparator(new_comparator))
      end,
   })

   -- Item 4: Second signal/constant (hybrid)
   self:add_item(name .. "_second", {
      label = function(ctx)
         local condition = get_condition() or {}
         if condition.second_signal and condition.second_signal.name then
            local signal_type = condition.second_signal.type or "item"
            ctx.message:fragment({ "fa.signal-type-name", signal_type, condition.second_signal.name })
         elseif condition.constant then
            ctx.message:fragment(tostring(condition.constant))
         else
            ctx.message:fragment("0")
         end

         ctx.message:fragment({ "fa.condition-second" })
         -- Always show help text
         ctx.message:fragment({ "fa.condition-second-help" })
      end,
      on_child_result = function(ctx, result)
         local condition = get_condition() or {}

         -- Check context to determine if this is constant or signal
         if type(ctx.child_context) == "table" and ctx.child_context.type == "constant" then
            -- Result is a string from textbox
            local num = tonumber(result)
            if num then
               ---@diagnostic disable-next-line: inject-field
               condition.constant = num
               ---@diagnostic disable-next-line: inject-field
               condition.second_signal = nil
               set_condition(condition)
               ctx.controller.message:fragment(tostring(num))
            else
               UiSounds.play_ui_edge(ctx.pindex)
               ctx.controller.message:fragment({ "fa.condition-error-invalid-number" })
            end
         else
            -- Result is a SignalID from signal chooser
            ---@diagnostic disable-next-line: inject-field
            condition.second_signal = result
            ---@diagnostic disable-next-line: inject-field
            condition.constant = nil
            set_condition(condition)
            if result and result.name then
               local signal_type = result.type or "item"
               ctx.controller.message:fragment({ "fa.signal-type-name", signal_type, result.name })
            else
               ctx.controller.message:fragment({ "fa.empty" })
            end
         end
      end,
      on_click = function(ctx)
         local condition = get_condition() or {}

         -- Check prerequisites
         if not condition.first_signal or not condition.first_signal.name then
            UiSounds.play_ui_edge(ctx.pindex)
            ctx.controller.message:fragment({ "fa.condition-error-first-signal-required" })
            return
         end
         if not condition.comparator then
            UiSounds.play_ui_edge(ctx.pindex)
            ctx.controller.message:fragment({ "fa.condition-error-operator-required" })
            return
         end

         -- Open signal selector
         ctx.controller:open_child_ui(
            UiRouter.UI_NAMES.SIGNAL_CHOOSER,
            {},
            { node = name .. "_second", type = "signal" }
         )
      end,
      on_action1 = function(ctx)
         local condition = get_condition() or {}

         -- Check prerequisites
         if not condition.first_signal or not condition.first_signal.name then
            UiSounds.play_ui_edge(ctx.pindex)
            ctx.controller.message:fragment({ "fa.condition-error-first-signal-required" })
            return
         end
         if not condition.comparator then
            UiSounds.play_ui_edge(ctx.pindex)
            ctx.controller.message:fragment({ "fa.condition-error-operator-required" })
            return
         end

         -- Open textbox for constant
         local current_value = condition.constant or 0
         ctx.controller:open_textbox(tostring(current_value), { node = name .. "_second", type = "constant" })
      end,
      on_clear = function(ctx)
         local condition = get_condition() or {}
         ---@diagnostic disable-next-line: inject-field
         condition.second_signal = nil
         ---@diagnostic disable-next-line: inject-field
         condition.constant = 0
         set_condition(condition)
         ctx.controller.message:fragment("0")
      end,
   })
   self:end_row()

   return self
end

---Start a row (forwards to MenuBuilder)
---@param key string Row identifier
---@return fa.ui.form.FormBuilder
function FormBuilder:start_row(key)
   table.insert(self.operations, function(menu_builder)
      menu_builder:start_row(key)
   end)
   return self
end

---End the current row (forwards to MenuBuilder)
---@return fa.ui.form.FormBuilder
function FormBuilder:end_row()
   table.insert(self.operations, function(menu_builder)
      menu_builder:end_row()
   end)
   return self
end

---Internal method to add an item (delegates to menu builder pattern)
---@param key string
---@param vtable fa.ui.graph.NodeVtable
---@return fa.ui.form.FormBuilder
function FormBuilder:add_item(key, vtable)
   table.insert(self.vtables, vtable)
   table.insert(self.operations, function(menu_builder)
      menu_builder:add_item(key, vtable)
   end)
   return self
end

---Build the form into a key graph render
---@return fa.ui.graph.Render
function FormBuilder:build()
   local menu_builder = Menu.MenuBuilder.new()

   -- Attach accelerator handler to all vtables if one is set
   if self.accelerator_handler then
      for _, vtable in ipairs(self.vtables) do
         if not vtable.on_accelerator then vtable.on_accelerator = self.accelerator_handler end
      end
   end

   -- Execute operations on menu builder
   for _, op in ipairs(self.operations) do
      op(menu_builder)
   end

   return menu_builder:build()
end

mod.FormBuilder = FormBuilder

return mod
