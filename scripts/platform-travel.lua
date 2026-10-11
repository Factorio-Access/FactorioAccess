--[[
Announcements for travelling between planets and space platforms: boarding a platform, dropping to a planet,
the trips of the platform the player is on, and platforms being destroyed. Also the compact description of a
platform's status that the hub and the platform list read.

A player boards a platform either directly (the controller becomes remote with player.hub set) or by riding a
rocket, whose cargo pod lands in the hub. Both can report the same boarding, so the announcement is suppressed
when it repeats shortly after for the same platform.
]]

local FaUtils = require("scripts.fa-utils")
local Localising = require("scripts.localising")
local Speech = require("scripts.speech")

local mod = {}

-- Speech only: losing this on load at worst repeats one announcement.
---@type table<integer, { tick: integer, platform_index: integer }>
local last_boarding = {}

local BOARDING_REPEAT_TICKS = 300

-- A platform can change state twice in one tick (paused, waiting at station, on the path), and each event already
-- sees the final state. The first event of a tick announces it; the others repeat it and are dropped.
---@type table<integer, { tick: integer, state: defines.space_platform_state }>
local last_platform_state = {}

---The space location the platform is heading to, from its schedule.
---@param platform LuaSpacePlatform
---@return LuaSpaceLocationPrototype?
local function destination(platform)
   local schedule = platform.schedule
   if not schedule then return nil end
   local record = schedule.records[schedule.current]
   if not record then return nil end
   return prototypes.space_location[assert(record.station)]
end

---@param pindex integer
---@param platform LuaSpacePlatform
local function announce_boarding(pindex, platform)
   local last = last_boarding[pindex]
   if last and last.platform_index == platform.index and game.tick - last.tick < BOARDING_REPEAT_TICKS then return end
   last_boarding[pindex] = { tick = game.tick, platform_index = platform.index }

   local location = platform.space_location --[[@as LuaSpaceLocationPrototype?]]
   local heading_to = platform.state == defines.space_platform_state.on_the_path and destination(platform)
   if location then
      local key = location.type == "planet" and "fa.platform-aboard-orbiting-planet" or "fa.platform-aboard-orbiting"
      Speech.speak(pindex, { key, platform.name, Localising.get_localised_name_with_fallback(location) })
   elseif heading_to then
      Speech.speak(
         pindex,
         { "fa.platform-aboard-travelling", platform.name, Localising.get_localised_name_with_fallback(heading_to) }
      )
   else
      Speech.speak(pindex, { "fa.platform-aboard", platform.name })
   end
end

---@param event EventData.on_player_controller_changed
---@param pindex integer
function mod.on_player_controller_changed(event, pindex)
   local player = game.get_player(pindex)
   local hub = player.hub
   if player.controller_type == defines.controllers.remote and hub then
      announce_boarding(pindex, assert(hub.surface.platform))
   end
end

---@param event EventData.on_cargo_pod_finished_descending
function mod.on_cargo_pod_finished_descending(event)
   local pindex = event.player_index
   if not pindex then return end
   local surface = event.cargo_pod.surface
   local platform = surface.platform
   local planet = surface.planet
   if platform then
      announce_boarding(pindex, platform)
   elseif planet then
      Speech.speak(pindex, { "fa.platform-landed", Localising.get_localised_name_with_fallback(planet.prototype) })
   end
end

---The planet the platform is in orbit over, if any. Platforms also stop at space locations that aren't planets.
---@param platform LuaSpacePlatform
---@return LuaSpaceLocationPrototype?
function mod.orbited_planet(platform)
   local location = platform.space_location --[[@as LuaSpaceLocationPrototype?]]
   if location and location.type == "planet" then return location end
   return nil
end

---Describe a platform compactly: name, pending deletion, state, where it is or how far along its trip, speed and mass.
---@param platform LuaSpacePlatform
---@param message fa.MessageBuilder
function mod.describe(platform, message)
   message:list_item(platform.name)

   local deleting = platform.scheduled_for_deletion
   if deleting > 0 then message:list_item({ "fa.platform-status-deleting", FaUtils.format_time(deleting) }) end

   local states = defines.space_platform_state
   local state = platform.state
   if state == states.waiting_for_starter_pack then
      message:list_item({ "fa.platform-status-waiting-for-starter-pack" })
   elseif state == states.starter_pack_requested then
      message:list_item({ "fa.platform-status-starter-pack-requested" })
   elseif state == states.starter_pack_on_the_way then
      message:list_item({ "fa.platform-status-starter-pack-on-the-way" })
   elseif state == states.paused then
      message:list_item({ "fa.platform-status-paused" })
   elseif state == states.no_path then
      local to = destination(platform)
      if to then
         message:list_item({ "fa.platform-status-no-path", Localising.get_localised_name_with_fallback(to) })
      end
   end

   local location = platform.space_location --[[@as LuaSpaceLocationPrototype?]]
   local connection = platform.space_connection
   if location then
      local key = location.type == "planet" and "fa.platform-status-orbiting" or "fa.platform-status-at"
      message:list_item({ key, Localising.get_localised_name_with_fallback(location) })
   elseif connection then
      -- distance runs from the connection's from end (0) to its to end (1), whichever way the platform flies; the
      -- end it last passed is the one it is leaving.
      local from = platform.last_visited_space_location
      local reversed = from ~= nil and from.name == connection.to.name
      local to = (reversed and connection.from or connection.to) --[[@as LuaSpaceLocationPrototype]]
      local distance = assert(platform.distance)
      local progress = reversed and 1 - distance or distance
      message:list_item({
         "fa.platform-status-travelling",
         Localising.get_localised_name_with_fallback(to),
         tostring(math.floor(progress * 100)),
      })
      local final = state == states.on_the_path and destination(platform)
      if final and final.name ~= to.name then
         message:list_item({ "fa.platform-status-then", Localising.get_localised_name_with_fallback(final) })
      end
   end

   -- Speed is in kilometres per tick: distance along a 15000 km connection changes by speed / 15000 a tick.
   local km_per_second = math.floor(math.abs(platform.speed) * 60 + 0.5)
   if km_per_second > 0 then message:list_item({ "fa.platform-status-speed", tostring(km_per_second) }) end

   -- Platform weight is in kilograms (a foundation tile adds 200), not the grams of item weights.
   if platform.hub then
      message:list_item({ "fa.platform-status-mass", FaUtils.one_decimal(platform.weight / 1000) })
   end
end

---Drop the player from the hub they are in to the planet below, like the game's "Drop to a planet" button.
---@param player LuaPlayer
---@param message fa.MessageBuilder
---@return boolean dropped
function mod.drop_to_planet(player, message)
   local platform = assert(assert(player.hub).surface.platform)
   local planet = mod.orbited_planet(platform)
   if not planet then
      message:fragment({ "fa.platform-drop-not-in-orbit" })
      return false
   end
   local name = Localising.get_localised_name_with_fallback(planet)
   if not player.land_on_planet() then
      message:fragment({ "fa.platform-drop-failed", name })
      return false
   end
   message:fragment({ "fa.platform-dropping", name })
   return true
end

---Departures, arrivals and a stuck schedule, for the players physically on the platform. Pausing is the player's
---own doing and waiting at a station follows an arrival, so neither is announced.
---@param event EventData.on_space_platform_changed_state
function mod.on_space_platform_changed_state(event)
   local platform = event.platform
   local state = platform.state
   local last = last_platform_state[platform.index]
   if last and last.tick == event.tick and last.state == state then return end
   last_platform_state[platform.index] = { tick = event.tick, state = state }

   local states = defines.space_platform_state
   ---@type LocalisedString?
   local message
   if state == states.on_the_path then
      local to = Localising.get_localised_name_with_fallback(assert(destination(platform)))
      local from = platform.last_visited_space_location
      if from then
         message = { "fa.platform-leaving", Localising.get_localised_name_with_fallback(from), to }
      else
         message = { "fa.platform-on-the-way", to }
      end
   elseif state == states.waiting_at_station and event.old_state == states.on_the_path then
      local location = assert(platform.space_location) --[[@as LuaSpaceLocationPrototype]]
      message = { "fa.platform-arrived", Localising.get_localised_name_with_fallback(location) }
   elseif state == states.no_path then
      local to = destination(platform)
      if to then message = { "fa.platform-no-path", Localising.get_localised_name_with_fallback(to) } end
   end
   if not message then return end

   local surface = platform.surface
   for _, player in pairs(platform.force.connected_players) do
      if player.physical_surface == surface then Speech.speak(player.index, message) end
   end
end

---The hub dying takes its platform with it.
---@param hub LuaEntity
function mod.on_hub_died(hub)
   local platform = assert(hub.surface.platform)
   for _, player in pairs(platform.force.connected_players) do
      Speech.speak(player.index, { "fa.platform-destroyed", platform.name })
   end
end

return mod
