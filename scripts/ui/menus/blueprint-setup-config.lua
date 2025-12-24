--[[
Blueprint setup config UI.

Shows checkboxes for create_blueprint options.
Opened as a child of blueprint-setup when right bracket is used.
]]

local FormBuilder = require("scripts.ui.form-builder")
local UiKeyGraph = require("scripts.ui.key-graph")
local UiRouter = require("scripts.ui.router")
local TabList = require("scripts.ui.tab-list")

local mod = {}

---@class fa.ui.BlueprintSetupConfig.Parameters
---@field area BoundingBox The selected area
---@field permanent boolean? Whether to make the blueprint permanent

---@class fa.ui.BlueprintSetupConfig.SharedState
---@field always_include_tiles boolean
---@field include_entities boolean
---@field include_modules boolean
---@field include_station_names boolean
---@field include_trains boolean
---@field include_fuel boolean

---@class fa.ui.BlueprintSetupConfig.Context: fa.ui.graph.Ctx
---@field global_parameters fa.ui.BlueprintSetupConfig.Parameters
---@field tablist_shared_state fa.ui.BlueprintSetupConfig.SharedState

---Setup shared state with default values
---@param _pindex number
---@param _params fa.ui.BlueprintSetupConfig.Parameters
---@return fa.ui.BlueprintSetupConfig.SharedState
local function state_setup(_pindex, _params)
   return {
      always_include_tiles = false,
      include_entities = true,
      include_modules = true,
      include_station_names = false,
      include_trains = false,
      include_fuel = true,
   }
end

---Render the blueprint setup config form
---@param ctx fa.ui.BlueprintSetupConfig.Context
---@return fa.ui.graph.Render?
local function render_config_form(ctx)
   local params = ctx.global_parameters
   local state = ctx.tablist_shared_state

   local p = game.get_player(ctx.pindex)
   if not p then return nil end

   local blueprint = p.cursor_stack
   if not blueprint or not blueprint.valid_for_read or not blueprint.is_blueprint then return nil end

   local builder = FormBuilder.FormBuilder.new()

   -- Proceed button at the top
   builder:add_action("proceed", { "fa.blueprint-setup-proceed" }, function(controller)
      -- Create blueprint from selected area with configured options
      blueprint.create_blueprint({
         surface = p.surface,
         force = p.force,
         area = params.area,
         always_include_tiles = state.always_include_tiles,
         include_entities = state.include_entities,
         include_modules = state.include_modules,
         include_station_names = state.include_station_names,
         include_trains = state.include_trains,
         include_fuel = state.include_fuel,
      })

      -- If permanent param is set, mark the blueprint as permanent
      if params.permanent then p.cursor_stack_temporary = false end

      -- Provide feedback about what was captured
      local entity_count = blueprint.get_blueprint_entity_count()
      local tiles = blueprint.get_blueprint_tiles()
      local tile_count = tiles and #tiles or 0
      if entity_count > 0 then
         controller.message:fragment({ "fa.planner-blueprint-created", entity_count })
      elseif tile_count > 0 then
         controller.message:fragment({ "fa.planner-blueprint-created-tiles", tile_count })
      else
         controller.message:fragment({ "fa.planner-blueprint-created-empty" })
      end

      -- Close the entire UI stack back to the parent
      controller:close_with_result("created")
   end)

   -- Checkbox for each option
   builder:add_checkbox("include_modules", { "fa.blueprint-setup-include-modules" }, function()
      return state.include_modules
   end, function(value)
      state.include_modules = value
   end)

   builder:add_checkbox("include_trains", { "fa.blueprint-setup-include-trains" }, function()
      return state.include_trains
   end, function(value)
      state.include_trains = value
   end)

   builder:add_checkbox("include_fuel", { "fa.blueprint-setup-include-fuel" }, function()
      return state.include_fuel
   end, function(value)
      state.include_fuel = value
   end)

   builder:add_checkbox("include_station_names", { "fa.blueprint-setup-include-station-names" }, function()
      return state.include_station_names
   end, function(value)
      state.include_station_names = value
   end)

   builder:add_checkbox("always_include_tiles", { "fa.blueprint-setup-always-include-tiles" }, function()
      return state.always_include_tiles
   end, function(value)
      state.always_include_tiles = value
   end)

   builder:add_checkbox("include_entities", { "fa.blueprint-setup-include-entities" }, function()
      return state.include_entities
   end, function(value)
      state.include_entities = value
   end)

   return builder:build()
end

mod.blueprint_setup_config_ui = TabList.declare_tablist({
   ui_name = UiRouter.UI_NAMES.BLUEPRINT_SETUP_CONFIG,
   resets_to_first_tab_on_open = true,
   shared_state_setup = state_setup,
   get_binds = function(pindex, parameters)
      return { { kind = UiRouter.BIND_KIND.HAND_CONTENTS } }
   end,
   tabs_callback = function()
      return {
         {
            name = "config",
            tabs = {
               UiKeyGraph.declare_graph({
                  name = "config",
                  title = { "fa.blueprint-setup-title" },
                  render_callback = render_config_form,
               }),
            },
         },
      }
   end,
})

UiRouter.register_ui(mod.blueprint_setup_config_ui)

return mod
