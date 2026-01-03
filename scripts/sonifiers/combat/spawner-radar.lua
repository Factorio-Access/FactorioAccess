--[[
Spawner Radar Sonifier - Audio feedback for nearby enemy spawners.

Pings spawners twice per second, cycling through them using unit_number % cycle_length
to spread out the audio and avoid overwhelming the player with many simultaneous sounds.
]]

local LauncherAudio = require("scripts.launcher-audio")
local SoundModel = require("scripts.sound-model")
local StorageManager = require("scripts.storage-manager")
local Zoom = require("scripts.zoom")

local mod = {}

local SOUND_FILE = "sonifiers/combat/spawner.ogg"
local SOUND_VOLUME = 0.8

-- Tick interval: 2 times per second (60 ticks / 2 = 30 ticks)
local TICK_INTERVAL = 30

-- Target number of spawners to ping per tick
-- We ping spawners where (unit_number % visible_count) falls within our "slot"
local TARGET_PINGS_PER_TICK = 1

---@class fa.SpawnerRadar.State
---@field cycle_index integer Current index in the cycle
---@field active_sounds table<string, true> Sound IDs currently playing

---@return fa.SpawnerRadar.State
local function make_default_state()
   return {
      cycle_index = 0,
      active_sounds = {},
   }
end

---@type table<integer, fa.SpawnerRadar.State>
local radar_storage = StorageManager.declare_storage_module("spawner_radar", make_default_state, {
   ephemeral_state_version = 1,
})

---Build sound for a spawner
---@param id string
---@param params fa.SoundModel.DirectionalParams
---@return fa.LauncherAudio.PatchBuilder
local function build_spawner_sound(id, params)
   local volume = SOUND_VOLUME * (params.gain or 1)
   local builder = LauncherAudio.patch(id):file(SOUND_FILE):volume(volume):pan(params.pan)
   SoundModel.apply_lpf(builder, params)
   return builder
end

---Main tick handler
---@param pindex integer
function mod.on_tick_per_player(pindex)
   -- Only run every TICK_INTERVAL ticks
   if game.tick % TICK_INTERVAL ~= 0 then return end

   local player = game.get_player(pindex)
   if not player or not player.valid then return end

   local state = radar_storage[pindex]

   -- Get reference position from sound model (cursor or character depending on mode)
   local ref_pos = SoundModel.get_reference_position(pindex)

   -- Get search area centered on reference position
   local area = Zoom.get_search_area(pindex)
   local left, top, right, bottom = area.left, area.top, area.right, area.bottom
   local half_width = area.half_width
   local ref_distance = half_width / 4

   -- Find spawners in visible area
   local surface = player.surface
   local spawners = surface.find_entities_filtered({
      area = { { left, top }, { right, bottom } },
      type = "unit-spawner",
      force = "enemy",
   })

   local spawner_count = #spawners
   if spawner_count == 0 then
      -- No spawners, clear any active sounds
      if next(state.active_sounds) then
         local compound = LauncherAudio.compound()
         for old_id in pairs(state.active_sounds) do
            compound:add(LauncherAudio.stop(old_id))
         end
         compound:send(pindex)
         state.active_sounds = {}
      end
      return
   end

   -- Advance cycle index, wrapping based on spawner count
   -- This ensures we cycle through all spawners regardless of count
   state.cycle_index = (state.cycle_index + 1) % spawner_count

   -- Filter to spawners that match current cycle index
   -- Pick spawners where (unit_number % spawner_count) == cycle_index
   local current_sounds = {}
   for _, spawner in ipairs(spawners) do
      if spawner.unit_number % spawner_count == state.cycle_index then
         local sound_id = "spawner-" .. spawner.unit_number
         current_sounds[sound_id] = spawner
      end
   end

   -- Stop sounds that are no longer active
   local compound = LauncherAudio.compound()
   local has_commands = false

   for old_id in pairs(state.active_sounds) do
      if not current_sounds[old_id] then
         compound:add(LauncherAudio.stop(old_id))
         has_commands = true
      end
   end

   -- Play sounds for current spawners
   for sound_id, spawner in pairs(current_sounds) do
      local pos = spawner.position
      local dx = pos.x - ref_pos.x
      local dy = pos.y - ref_pos.y
      local params = SoundModel.map_relative_position(dx, dy, half_width, ref_distance)

      local builder = build_spawner_sound(sound_id, params)
      compound:add(builder)
      has_commands = true
   end

   if has_commands then compound:send(pindex) end

   -- Update active sounds
   state.active_sounds = {}
   for sound_id in pairs(current_sounds) do
      state.active_sounds[sound_id] = true
   end
end

---Stop all active sounds (e.g., when disabling the radar)
---@param pindex integer
function mod.stop_all(pindex)
   local state = radar_storage[pindex]

   if next(state.active_sounds) then
      local compound = LauncherAudio.compound()
      for sound_id in pairs(state.active_sounds) do
         compound:add(LauncherAudio.stop(sound_id))
      end
      compound:send(pindex)
   end

   state.active_sounds = {}
end

return mod
