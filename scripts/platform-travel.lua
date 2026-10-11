--[[
Announcements for travelling between planets and space platforms: boarding a platform, dropping to a planet,
and the trips of the platform the player is on.

A player boards a platform either directly (the controller becomes remote with player.hub set) or by riding a
rocket, whose cargo pod lands in the hub. Both can report the same boarding, so the announcement is suppressed
when it repeats shortly after for the same platform.
]]

local Localising = require("scripts.localising")
local Speech = require("scripts.speech")

local mod = {}

-- Speech only: losing this on load at worst repeats one announcement.
---@type table<integer, { tick: integer, platform_index: integer }>
local last_boarding = {}

local BOARDING_REPEAT_TICKS = 300

---The space location the platform is heading to, from its schedule.
---@param platform LuaSpacePlatform
---@return LuaSpaceLocationPrototype?
local function destination(platform)
   local schedule = platform.schedule
   if not schedule then return nil end
   local record = schedule.records[schedule.current]
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
      Speech.speak(
         pindex,
         { "fa.platform-aboard-orbiting", platform.name, Localising.get_localised_name_with_fallback(location) }
      )
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
   local platform = event.cargo_pod.surface.platform
   if platform then announce_boarding(pindex, platform) end
end

return mod
