--[[
Offshore pump placement menu UI using the new TabList/Menu system.
Provides a menu interface for selecting from valid offshore pump placement positions.
]]

local Functools = require("scripts.functools")
local FaUtils = require("scripts.fa-utils")
local Menu = require("scripts.ui.menu")
local Speech = require("scripts.speech")
local TabList = require("scripts.ui.tab-list")
local UiKeyGraph = require("scripts.ui.key-graph")
local UiRouter = require("scripts.ui.router")
local Viewpoint = require("scripts.viewpoint")

local mod = {}

---@class fa.ui.OffshorePumpPlacement.SharedState
---@field positions table<string, {position: MapPosition, direction: defines.direction}> Map of key -> position data

---@class fa.ui.OffshorePumpPlacement.Parameters
---@field positions {position: MapPosition, direction: defines.direction}[] Array of valid placement positions

---@class fa.ui.OffshorePumpPlacement.Context: fa.ui.graph.Ctx
---@field parameters fa.ui.OffshorePumpPlacement.Parameters
---@field tablist_shared_state fa.ui.OffshorePumpPlacement.SharedState

-- Shared state setup function
---@param pindex number
---@param params fa.ui.OffshorePumpPlacement.Parameters
---@return fa.ui.OffshorePumpPlacement.SharedState
local function state_setup(pindex, params)
   -- Convert positions array to keyed map
   local positions_map = {}
   for _, pos_data in ipairs(params.positions or {}) do
      local key = string.format("%d-%d-%d", pos_data.position.x, pos_data.position.y, pos_data.direction)
      positions_map[key] = pos_data
   end

   return {
      positions = positions_map,
   }
end

-- Main render function
---@param ctx fa.ui.OffshorePumpPlacement.Context
---@return fa.ui.graph.Render?
local function render_pump_menu(ctx)
   local positions_map = ctx.tablist_shared_state.positions
   local player = game.get_player(ctx.pindex)
   local player_position = player.position

   if not positions_map or not next(positions_map) then
      ctx.controller.message:fragment({ "fa.building-pump-no-positions" })
      ctx.controller:close()
      return nil
   end

   -- Convert map back to sorted array for display
   local positions_array = {}
   for _, pos_data in pairs(positions_map) do
      table.insert(positions_array, pos_data)
   end

   -- Sort by distance from player
   table.sort(positions_array, function(a, b)
      return FaUtils.distance(player_position, a.position) < FaUtils.distance(player_position, b.position)
   end)

   local builder = Menu.MenuBuilder.new()

   -- Menu item 0: Title/Instructions
   builder:add_label("title", function(label_ctx)
      label_ctx.message:fragment({ "fa.building-pump-positions-available", #positions_array })
      label_ctx.message:fragment({ "fa.offshore-pump-menu-instructions" })
   end)

   -- Add a clickable item for each position
   for i, pos_data in ipairs(positions_array) do
      local key = string.format("%d-%d-%d", pos_data.position.x, pos_data.position.y, pos_data.direction)
      local distance = math.floor(FaUtils.distance(player_position, pos_data.position))
      local direction_name = FaUtils.direction_lookup(pos_data.direction)

      builder:add_clickable(key, function(item_ctx)
         item_ctx.message:fragment({
            "fa.offshore-pump-position-option",
            i,
            pos_data.position.x,
            pos_data.position.y,
            direction_name,
            distance,
         })
      end, {
         on_click = function(click_ctx)
            -- Check if we can still build (in case something changed)
            if
               player.can_build_from_cursor({
                  position = pos_data.position,
                  direction = pos_data.direction,
               })
            then
               -- Place the pump
               player.build_from_cursor({
                  position = pos_data.position,
                  direction = pos_data.direction,
               })
               click_ctx.message:fragment({
                  "fa.offshore-pump-placed",
                  pos_data.position.x,
                  pos_data.position.y,
                  direction_name,
               })
               click_ctx.controller:close()
            else
               click_ctx.message:fragment({ "fa.offshore-pump-placement-failed" })
            end
         end,
      })
   end

   return builder:build()
end

-- TabList declaration
mod.offshore_pump_menu = TabList.declare_tablist({
   ui_name = UiRouter.UI_NAMES.PUMP,
   resets_to_first_tab_on_open = true,
   shared_state_setup = state_setup,
   tabs_callback = Functools.functionize({
      {
         name = "main",
         tabs = {
            UiKeyGraph.declare_graph({
               name = "pump_placement",
               title = { "fa.offshore-pump-menu-title" },
               render_callback = render_pump_menu,
            }),
         },
      },
   }),
})

-- Register with the UI event routing system for event interception
UiRouter.register_ui(mod.offshore_pump_menu)

return mod
