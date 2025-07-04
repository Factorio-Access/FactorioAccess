--[[
Audio Cues
Centralized management of various audio cues that need to be played periodically.
Handles train sounds, enemy alerts, driving alerts, mining sounds, and crafting sounds.
]]

local Rails = require("scripts.rails")
local Combat = require("scripts.combat")
local Driving = require("scripts.driving")
local PlayerMiningTools = require("scripts.player-mining-tools")
local Trains = require("scripts.trains")
local sounds = require("scripts.ui.sounds")

local mod = {}

---@class fa.AudioCues.CueType
---@field check_function function The function to call for checking
---@field tick_interval number How often to check (in ticks)
---@field tick_offset number Offset to distribute checks across ticks
---@field per_player boolean Whether to check for each player individually
---@field params any[] Additional parameters to pass to the check function

---@type table<string, fa.AudioCues.CueType>
local cue_types = {}

---Registers an audio cue to be played periodically
---@param name string Unique identifier for the cue
---@param check_function function Function to call (receives pindex and tick if per_player, otherwise just tick)
---@param tick_interval number How often to check in ticks
---@param tick_offset number? Offset to avoid all checks on same tick (default 0)
---@param per_player boolean? Whether to run for each player (default true)
---@param params any[]? Additional parameters to pass to the check function
function mod.register_cue(name, check_function, tick_interval, tick_offset, per_player, params)
   cue_types[name] = {
      check_function = check_function,
      tick_interval = tick_interval,
      tick_offset = tick_offset or 0,
      per_player = per_player ~= false, -- default true
      params = params or {},
   }
end

---Unregisters an audio cue
---@param name string
function mod.unregister_cue(name)
   cue_types[name] = nil
end

---Checks all registered audio cues for the current tick
---@param tick number
---@param players table<number, LuaPlayer>
function mod.check_cues(tick, players)
   for name, cue in pairs(cue_types) do
      if (tick + cue.tick_offset) % cue.tick_interval == 0 then
         if cue.per_player then
            for pindex, player in pairs(players) do
               cue.check_function(pindex, tick, table.unpack(cue.params))
            end
         else
            cue.check_function(tick, table.unpack(cue.params))
         end
      end
   end
end

---Initialize default audio cues
function mod.on_init()
   -- Train track alerts at different frequencies
   mod.register_cue("train_track_3", Rails.check_and_play_train_track_alert_sounds, 15, 1, false, { 3 })
   mod.register_cue("train_track_2", Rails.check_and_play_train_track_alert_sounds, 30, 1, false, { 2 })
   mod.register_cue("train_track_1", Rails.check_and_play_train_track_alert_sounds, 60, 1, false, { 1 })

   -- Enemy alerts at different frequencies
   mod.register_cue("enemy_3", Combat.check_and_play_enemy_alert_sound, 15, 1, false, { 3 })
   mod.register_cue("enemy_2", Combat.check_and_play_enemy_alert_sound, 30, 1, false, { 2 })
   mod.register_cue("enemy_1", Combat.check_and_play_enemy_alert_sound, 60, 1, false, { 1 })

   -- Driving alerts (cascading checks)
   mod.register_cue("driving", function(pindex, tick)
      local check_further = Driving.check_and_play_driving_alert_sound(pindex, tick, 1)
      if tick % 30 == 2 and check_further then
         check_further = Driving.check_and_play_driving_alert_sound(pindex, tick, 2)
         if tick % 60 == 2 and check_further then
            check_further = Driving.check_and_play_driving_alert_sound(pindex, tick, 3)
            if tick % 120 == 2 and check_further then
               check_further = Driving.check_and_play_driving_alert_sound(pindex, tick, 4)
            end
         end
      end
   end, 15, 2, true)

   -- Train horns
   mod.register_cue("train_horns", function(pindex, tick)
      Trains.check_and_honk_at_trains_in_same_block(tick, pindex)
      Trains.check_and_honk_at_closed_signal(tick, pindex)
      Trains.check_and_play_sound_for_turning_trains(pindex)
   end, 30, 6, true)

   -- Mining sounds
   mod.register_cue("mining", function(pindex, tick)
      local p = game.get_player(pindex)
      if p ~= nil and p.mining_state.mining == true then PlayerMiningTools.play_mining_sound(pindex) end
   end, 30, 8, true)

   -- Combat aiming and crafting sounds
   mod.register_cue("combat_crafting", function(pindex, tick)
      local p = game.get_player(pindex)

      -- Enemy aiming
      local enemy = p.surface.find_nearest_enemy({ position = p.position, max_distance = 50, force = p.force })
      if enemy ~= nil and enemy.valid then Combat.aim_gun_at_nearest_enemy(pindex, enemy) end

      -- Crafting sound
      if p.character and p.crafting_queue ~= nil and #p.crafting_queue > 0 and p.crafting_queue_size > 0 then
         sounds.play_crafting(pindex)
      end
   end, 60, 11, true)
end

return mod
