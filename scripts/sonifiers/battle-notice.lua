--[[
Battle Notice Sonifier - Audio alert when structures are damaged or destroyed.

Per-force sonifier that plays an alert sound when entities belonging to that force are damaged or destroyed. Checks
periodically and plays a single alert if any battle activity occurred since the last check.

Battle activity is detected via:
- Direct notify() calls from on_entity_damaged/on_entity_died events
- Polling for combat-related alerts (entity_under_attack, entity_destroyed, turret_fire)

Uses Factorio's native force.play_sound() API.
]]

local mod = {}

-- Check interval in ticks
local CHECK_INTERVAL = 5 * 60

-- Combat-related alert types to check for
local COMBAT_ALERT_TYPES = {
   defines.alert_type.entity_under_attack,
   defines.alert_type.entity_destroyed,
   defines.alert_type.turret_fire,
}

-- Storage for per-force state
-- Keyed by force index, stores { notified = boolean }
local force_state = {}

---Get or create state for a force
---@param force_index uint32
---@return { notified: boolean }
local function get_force_state(force_index)
   if not force_state[force_index] then force_state[force_index] = {
      notified = false,
   } end
   return force_state[force_index]
end

---Check if a player has any combat-related alerts
---@param player LuaPlayer
---@return boolean
local function has_combat_alerts(player)
   for _, alert_type in ipairs(COMBAT_ALERT_TYPES) do
      local alerts = player.get_alerts({ type = alert_type })
      -- alerts is Dictionary[surface_index, Dictionary[alert_type, Alert[]]]
      for _, alerts_by_type in pairs(alerts) do
         if alerts_by_type[alert_type] and #alerts_by_type[alert_type] > 0 then return true end
      end
   end
   return false
end

---Notify that a force's entity was damaged or destroyed
---@param force LuaForce
function mod.notify(force)
   local state = get_force_state(force.index)
   state.notified = true
end

---On tick handler - checks periodically for battle notifications
function mod.on_tick()
   local tick = game.tick
   if tick % CHECK_INTERVAL ~= 0 then return end

   for _, force in pairs(game.forces) do
      -- Skip forces with no players
      if #force.players == 0 then goto continue end

      local state = get_force_state(force.index)

      -- Check for combat alerts if not already notified
      if not state.notified then
         -- Check any connected player from this force for combat alerts
         for _, player in ipairs(force.players) do
            if player.connected and has_combat_alerts(player) then
               state.notified = true
               break
            end
         end
      end

      if not state.notified then goto continue end

      -- Clear the notification flag and play sound
      state.notified = false
      force.play_sound({ path = "fa-battle-notice" })

      ::continue::
   end
end

return mod
