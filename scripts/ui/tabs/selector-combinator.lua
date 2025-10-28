---@diagnostic disable: inject-field
-- LuaLS incorrectly believes SelectorCombinatorParameters fields cannot be modified.
-- These fields are documented in the Factorio API and can be set on the parameters object.
-- See llm-docs/api-reference/runtime/concepts/SelectorCombinatorParameters.md

--[[
Selector combinator configuration tab for Factorio 2.0.

Provides a configuration form for selector combinators with mode-dependent parameters.
The form re-renders based on the selected operation mode.
]]

local FormBuilder = require("scripts.ui.form-builder")
local CombinatorUtils = require("scripts.ui.combinator-utils")
local UiKeyGraph = require("scripts.ui.key-graph")
local UiRouter = require("scripts.ui.router")
local UiSounds = require("scripts.ui.sounds")
local CircuitNetwork = require("scripts.circuit-network")

local mod = {}

-- Build mode choices once at module load time (feature flags don't change at runtime)
local MODE_CHOICES = {
   { label = { "fa.selector-mode-select" }, value = "select", default = true },
   { label = { "fa.selector-mode-count" }, value = "count" },
   { label = { "fa.selector-mode-random" }, value = "random" },
   { label = { "fa.selector-mode-stack-size" }, value = "stack-size" },
}

-- Add quality modes if quality is enabled
if script.feature_flags.quality then
   table.insert(MODE_CHOICES, { label = { "fa.selector-mode-quality-transfer" }, value = "quality-transfer" })
   table.insert(MODE_CHOICES, { label = { "fa.selector-mode-quality-filter" }, value = "quality-filter" })
end

-- Add space travel modes if space travel is enabled
if script.feature_flags.space_travel then
   table.insert(MODE_CHOICES, { label = { "fa.selector-mode-rocket-capacity" }, value = "rocket-capacity" })
end

-- Selection mode choices (max/min)
local SELECTION_MODE_CHOICES = {
   { label = { "fa.selector-select-maximum" }, value = true, default = true },
   { label = { "fa.selector-select-minimum" }, value = false },
}

---Add select mode parameters (max/min and index)
---@param builder fa.ui.form.FormBuilder
---@param params SelectorCombinatorParameters
---@param cb LuaSelectorCombinatorControlBehavior
local function add_select_mode_params(builder, params, cb)
   -- Select mode (max/min)
   builder:add_choice_field("select_max", { "fa.selector-select-mode" }, function()
      return params.select_max ~= false
   end, function(value)
      params.select_max = value
      cb.parameters = params
   end, SELECTION_MODE_CHOICES)

   -- Index (signal or constant, toggled with 'm' key)
   builder:add_item("index", {
      label = function(ctx)
         ctx.message:fragment({ "fa.selector-index-label" })
         if params.index_signal and params.index_signal.name then
            -- Signal mode
            local signal_name = CircuitNetwork.localise_signal(params.index_signal)
            ctx.message:fragment(signal_name)
         else
            -- Constant mode
            local value = params.index_constant or 0
            ctx.message:fragment(tostring(value))
         end
         ctx.message:fragment({ "fa.selector-index-instructions" })
      end,
      on_click = function(ctx)
         -- Click always opens signal chooser
         ctx.controller:open_child_ui(UiRouter.UI_NAMES.SIGNAL_CHOOSER, {}, { node = "index" })
      end,
      on_child_result = function(ctx, result)
         if type(result) == "string" then
            -- Textbox result (constant)
            local num = tonumber(result)
            if num and math.floor(num) == num then
               params.index_constant = num
               params.index_signal = nil
               cb.parameters = params
               ctx.controller.message:fragment(tostring(num))
            else
               UiSounds.play_ui_edge(ctx.pindex)
               ctx.controller.message:fragment({ "fa.selector-index-invalid" })
            end
         else
            -- Signal chooser result (SignalID or nil)
            params.index_signal = result
            params.index_constant = 0
            cb.parameters = params
            if result and result.name then
               ctx.controller.message:fragment(CircuitNetwork.localise_signal(result))
            else
               ctx.controller.message:fragment({ "fa.empty" })
            end
         end
      end,
      on_action1 = function(ctx)
         -- M key always opens textbox for constant
         local current_value = params.index_constant or 0
         ctx.controller:open_textbox(tostring(current_value), "index")
      end,
      on_clear = function(ctx)
         params.index_signal = nil
         params.index_constant = 0
         cb.parameters = params
         ctx.controller.message:fragment("0")
      end,
   })
end

---Add count mode parameters
---@param builder fa.ui.form.FormBuilder
---@param params SelectorCombinatorParameters
---@param cb LuaSelectorCombinatorControlBehavior
local function add_count_mode_params(builder, params, cb)
   builder:add_signal("count_signal", { "fa.selector-count-signal" }, function()
      return params.count_signal
   end, function(value)
      params.count_signal = value
      cb.parameters = params
   end)
end

---Add random mode parameters
---@param builder fa.ui.form.FormBuilder
---@param params SelectorCombinatorParameters
---@param cb LuaSelectorCombinatorControlBehavior
local function add_random_mode_params(builder, params, cb)
   builder:add_item("random_update_interval", {
      label = function(ctx)
         local value = params.random_update_interval or 0
         ctx.message:fragment(tostring(value))
         ctx.message:fragment({ "fa.selector-random-update-interval" })
      end,
      on_click = function(ctx)
         local current_value = params.random_update_interval or 0
         ctx.controller:open_textbox(tostring(current_value), "random_update_interval")
      end,
      on_child_result = function(ctx, result)
         local num = tonumber(result)
         if num and num >= 0 and math.floor(num) == num then
            params.random_update_interval = num
            cb.parameters = params
            ctx.controller.message:fragment(tostring(num))
         else
            UiSounds.play_ui_edge(ctx.pindex)
            ctx.controller.message:fragment({ "fa.selector-random-interval-invalid" })
         end
      end,
   })
end

---Add quality transfer mode parameters
---@param builder fa.ui.form.FormBuilder
---@param params SelectorCombinatorParameters
---@param cb LuaSelectorCombinatorControlBehavior
local function add_quality_transfer_mode_params(builder, params, cb)
   builder:add_checkbox("select_quality_from_signal", { "fa.selector-quality-from-signal" }, function()
      return params.select_quality_from_signal or false
   end, function(value)
      params.select_quality_from_signal = value
      cb.parameters = params
   end)

   builder:add_signal("quality_destination_signal", { "fa.selector-quality-destination-signal" }, function()
      return params.quality_destination_signal
   end, function(value)
      params.quality_destination_signal = value
      cb.parameters = params
   end)
end

---Add quality filter mode parameters
---@param builder fa.ui.form.FormBuilder
local function add_quality_filter_mode_params(builder)
   builder:add_label("quality_filter_note", { "fa.selector-quality-filter-note" })
end

---@class fa.ui.SelectorCombinatorTabContext: fa.ui.TabContext
---@field tablist_shared_state fa.ui.EntityUI.SharedState

---Render the selector combinator configuration form
---@param ctx fa.ui.SelectorCombinatorTabContext
---@return fa.ui.graph.Render?
local function render_selector_config(ctx)
   local entity = ctx.tablist_shared_state.entity
   if not entity or not entity.valid then return nil end
   assert(entity.type == "selector-combinator", "render: entity is not a selector-combinator")

   local cb = entity.get_control_behavior() --[[@as LuaSelectorCombinatorControlBehavior]]
   if not cb then return nil end

   local builder = FormBuilder.FormBuilder.new()

   -- Add common combinator settings (description)
   CombinatorUtils.common_settings(builder, entity)

   -- Get current parameters or create default
   local params = cb.parameters or { operation = "select" }

   builder:add_choice_field("operation", { "fa.selector-combinator-mode" }, function()
      return params.operation or "select"
   end, function(value)
      params.operation = value
      cb.parameters = params
   end, MODE_CHOICES)

   -- Mode-specific parameters (form re-renders when mode changes)
   local operation = params.operation or "select"

   if operation == "select" then
      add_select_mode_params(builder, params, cb)
   elseif operation == "count" then
      add_count_mode_params(builder, params, cb)
   elseif operation == "random" then
      add_random_mode_params(builder, params, cb)
   elseif operation == "quality-transfer" then
      add_quality_transfer_mode_params(builder, params, cb)
   elseif operation == "quality-filter" then
      add_quality_filter_mode_params(builder)
   end
   -- rocket-capacity and stack-size modes have no additional parameters

   return builder:build()
end

-- Create the tab descriptor
mod.selector_combinator_tab = UiKeyGraph.declare_graph({
   name = "selector-combinator-config",
   title = { "fa.selector-combinator-config-title" },
   render_callback = render_selector_config,
})

return mod
