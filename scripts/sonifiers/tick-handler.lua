--[[
Centralized tick handler for all sonifiers.

This module runs the player loop once and calls each sonifier's
on_tick_per_player function, avoiding redundant iteration.
]]

local VanillaMode = require("scripts.vanilla-mode")
local SettingsDecls = require("scripts.settings-decls")
local SETTING_NAMES = SettingsDecls.SETTING_NAMES
local VehicleSounds = require("scripts.sonifiers.vehicle")
local InserterSonifier = require("scripts.sonifiers.inserter")
local PlayerCraftingSonifier = require("scripts.sonifiers.player-crafting")
local GridSonifier = require("scripts.sonifiers.grid-sonifier")
local EnemyRadar = require("scripts.sonifiers.combat.enemy-radar")
local SpawnerRadar = require("scripts.sonifiers.combat.spawner-radar")
local HealthBar = require("scripts.sonifiers.health-bar")

local mod = {}

---Called every tick from control.lua
function mod.on_tick()
   for _, player in pairs(game.players) do
      if not player.connected then goto continue end

      local pindex = player.index
      if VanillaMode.is_enabled(pindex) then goto continue end

      -- Vehicle sounds (driving feedback)
      VehicleSounds.on_tick_per_player(pindex)

      -- Inserter sonification (when hovering inserter)
      InserterSonifier.on_tick_per_player(pindex)

      -- Player crafting sounds
      PlayerCraftingSonifier.on_tick_per_player(pindex)

      -- Grid-based sonification (crafting machines etc)
      if settings.global[SETTING_NAMES.SONIFICATION_CRAFTING].value then GridSonifier.on_tick_per_player(pindex) end

      -- Combat sonification
      if settings.global[SETTING_NAMES.SONIFICATION_COMBAT_ENEMIES].value then EnemyRadar.on_tick_per_player(pindex) end
      if settings.global[SETTING_NAMES.SONIFICATION_COMBAT_SPAWNERS].value then
         SpawnerRadar.on_tick_per_player(pindex)
      end

      -- Health bar sonification
      HealthBar.on_tick_per_player(pindex)

      ::continue::
   end
end

return mod
