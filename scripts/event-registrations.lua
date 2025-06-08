--- Event Registrations
-- This module contains all event registrations moved from control.lua
-- to enable proper event mocking in tests

local mod = {}

local EventManager = require("scripts.event-manager")

-- Import all required modules
local fa_utils = require("scripts.fa-utils")
local fa_localising = require("scripts.localising")
local fa_trains = require("scripts.trains")
local fa_spidertrons = require("scripts.spidertron")
local fa_warnings = require("scripts.warnings")
local fa_quickbar = require("scripts.quickbar")
local Viewpoint = require("scripts.viewpoint")
local UiRouter = require("scripts.ui.router")
local WorkQueue = require("scripts.work-queue")
local TestFramework = require("scripts.test-framework")

-- Helper function to check for player
local function check_for_player(pindex)
   return game.get_player(pindex) ~= nil
end

-- Helper function for move_key (temporary - should be moved to appropriate module)
local function move_key(direction, event, is_arrow_key)
   -- TODO: This function needs to be imported from the appropriate module
   -- For now, just log
   if _G.Logger then Logger.debug("EventRegistrations", "move_key called with direction " .. tostring(direction)) end
end

--- Register all events
-- @param on_tick_handler The main on_tick function from control.lua
-- @param move_key_handler The move_key function from control.lua
function mod.register_all(on_tick_handler, move_key_handler)
   -- Store handlers
   local on_tick = on_tick_handler
   local move_key = move_key_handler or move_key

   -- Register WASD movement keys
   EventManager.on_custom_input("fa-w", function(event)
      local pindex = event.player_index
      local router = UiRouter.get_router(pindex)
      if not check_for_player(pindex) or router:is_ui_open(UiRouter.UI_NAMES.PROMPT) then return end

      move_key(defines.direction.north, event)
   end)

   EventManager.on_custom_input("fa-a", function(event)
      local pindex = event.player_index
      local router = UiRouter.get_router(pindex)
      if not check_for_player(pindex) or router:is_ui_open(UiRouter.UI_NAMES.PROMPT) then return end

      move_key(defines.direction.west, event)
   end)

   EventManager.on_custom_input("fa-s", function(event)
      local pindex = event.player_index
      local router = UiRouter.get_router(pindex)
      if not check_for_player(pindex) or router:is_ui_open(UiRouter.UI_NAMES.PROMPT) then return end

      move_key(defines.direction.south, event)
   end)

   EventManager.on_custom_input("fa-d", function(event)
      local pindex = event.player_index
      local router = UiRouter.get_router(pindex)
      if not check_for_player(pindex) or router:is_ui_open(UiRouter.UI_NAMES.PROMPT) then return end

      move_key(defines.direction.east, event)
   end)

   -- Register on_tick handler
   EventManager.on_event(defines.events.on_tick, function(event)
      on_tick(event)
      WorkQueue.on_tick()
      TestFramework.on_tick(event)
   end)

   -- Register player position changed
   EventManager.on_event(defines.events.on_player_changed_position, function(event)
      -- TODO: Import the actual handler
      if _G.Logger then Logger.debug("EventRegistrations", "on_player_changed_position triggered") end
   end)

   -- Register other critical events
   EventManager.on_event(defines.events.on_player_joined_game, function(event)
      -- TODO: Import the actual handler
      if _G.Logger then Logger.debug("EventRegistrations", "on_player_joined_game triggered") end
   end)

   -- Register quickbar events
   local quickbar_get_events = {}
   local quickbar_set_events = {}
   local quickbar_page_events = {}
   for i = 1, 10 do
      local key = tostring(i % 10)
      table.insert(quickbar_get_events, "fa-" .. key)
      table.insert(quickbar_set_events, "fa-c-" .. key)
      table.insert(quickbar_page_events, "fa-s-" .. key)
   end

   EventManager.on_event(quickbar_get_events, fa_quickbar.quickbar_get_handler)
   EventManager.on_event(quickbar_set_events, fa_quickbar.quickbar_set_handler)
   EventManager.on_event(quickbar_page_events, fa_quickbar.quickbar_page_handler)

   -- Register string translated event
   EventManager.on_event(defines.events.on_string_translated, fa_localising.handler)

   -- More events can be migrated here incrementally
end

return mod
