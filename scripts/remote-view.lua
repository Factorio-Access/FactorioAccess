--[[
Remote view: looking at a surface without the character. Alt+I enters it at the cursor and leaves it again; Escape
and the game's map key leave it too, so the announcements come from the events rather than the key.

Leaving goes back to the character. Aboard a space platform the character sits in the hub and the player is always
in remote view: leaving a view of another surface goes back to the platform, the way the game's own keys do, and
exit_remote_view refuses.

Code that moves the view and says so itself (fast travel) does it through `quietly`. The game raises these events
after the Lua call that changed the controller returns, in the same tick, so `quietly` silences that tick.
]]

local FaUtils = require("scripts.fa-utils")
local PlatformTravel = require("scripts.platform-travel")
local Speech = require("scripts.speech")
local Viewpoint = require("scripts.viewpoint")

local mod = {}

-- The tick a player's view changes are not announced in. Lost on load: at worst one extra announcement.
---@type table<integer, integer>
local quiet_tick = {}

---Run f with this module's announcements off for the player, for the rest of the tick.
---@param pindex integer
---@param f fun()
function mod.quietly(pindex, f)
   quiet_tick[pindex] = game.tick
   f()
end

---@param pindex integer
function mod.toggle(pindex)
   local player = assert(game.get_player(pindex))
   if player.controller_type == defines.controllers.remote then
      player.exit_remote_view()
      if player.controller_type ~= defines.controllers.remote then return end
      if player.surface ~= player.physical_surface then
         player.set_controller({
            type = defines.controllers.remote,
            surface = player.physical_surface,
            position = player.physical_position,
         })
      else
         Speech.speak(pindex, { "fa.remote-view-nothing-to-return-to" })
      end
   elseif FaUtils.controlled_character(player) then
      player.set_controller({
         type = defines.controllers.remote,
         surface = player.surface,
         position = Viewpoint.get_viewpoint(pindex):get_cursor_pos(),
      })
   else
      Speech.speak(pindex, FaUtils.no_controlled_character_reason(player))
   end
end

---@param event EventData.on_player_controller_changed
---@param pindex integer
function mod.on_player_controller_changed(event, pindex)
   if quiet_tick[pindex] == game.tick then return end
   local player = assert(game.get_player(pindex))
   -- Boarding a platform and riding a rocket are announced by PlatformTravel
   if player.hub or player.cargo_pod then return end
   if player.controller_type == defines.controllers.remote and event.old_type == defines.controllers.character then
      Speech.speak(pindex, { "fa.remote-view-entered" })
   elseif player.controller_type == defines.controllers.character and event.old_type == defines.controllers.remote then
      Viewpoint.get_viewpoint(pindex):set_cursor_pos(player.position --[[@as fa.Point]])
      Speech.speak(pindex, { "fa.remote-view-left" })
   end
end

---Back from viewing another surface to the platform the player is aboard: the controller stays remote.
---@param event EventData.on_player_changed_surface
---@param pindex integer
function mod.on_player_changed_surface(event, pindex)
   if quiet_tick[pindex] == game.tick then return end
   local player = assert(game.get_player(pindex))
   local hub = player.hub
   if player.controller_type ~= defines.controllers.remote or not hub or player.surface ~= hub.surface then return end
   Viewpoint.get_viewpoint(pindex):set_cursor_pos(player.position --[[@as fa.Point]])
   -- Boarding raises this too, in the same tick as the announcement PlatformTravel makes for it
   PlatformTravel.announce_boarding(pindex, assert(hub.surface.platform), 1)
end

return mod
