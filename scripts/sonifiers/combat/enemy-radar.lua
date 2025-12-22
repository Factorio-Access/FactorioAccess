--[[
Enemy Radar Sonifier - Audio feedback for nearby enemies using leader-based clustering.

Groups enemies within a threshold distance into clusters, playing a sound at each
cluster's centroid. Sound IDs are stable based on the minimum unit number in each
group, providing consistent audio even as enemies move.
]]

local LauncherAudio = require("scripts.launcher-audio")
local SoundModel = require("scripts.sound-model")
local StorageManager = require("scripts.storage-manager")
local Zoom = require("scripts.zoom")

local mod = {}

-- Clustering threshold in tiles
local CLUSTER_THRESHOLD = 2
local CLUSTER_THRESHOLD_SQ = CLUSTER_THRESHOLD * CLUSTER_THRESHOLD

local SOUND_FILE = "sonifiers/combat/enemy.ogg"
local SOUND_VOLUME = 0.8

-- Tick interval: 4 times per second (60 ticks / 4 = 15 ticks)
local TICK_INTERVAL = 15

-- Fraction of enemies to ping each interval (random subset)
local ENEMY_SAMPLE_FRACTION = 0.5

-- Health-based pitch scaling (higher health = higher pitch, like a gauge)
local BASE_HEALTH = 15 -- Small biter health (reference point)
local PITCH_SCALE = 0.18 -- How much log(health ratio) affects pitch
local MIN_PITCH = 0.7 -- Lowest pitch (small enemies)
local MAX_PITCH = 1.5 -- Highest pitch (behemoths)

---Calculate pitch based on max health
---@param max_health number
---@return number
local function health_to_pitch(max_health)
   if max_health <= 0 then return 1.0 end
   local log_ratio = math.log(max_health / BASE_HEALTH)
   local pitch = 1.0 + PITCH_SCALE * log_ratio
   return math.max(MIN_PITCH, math.min(MAX_PITCH, pitch))
end

---@class fa.EnemyRadar.Cluster
---@field center_x number
---@field center_y number
---@field count integer
---@field min_unit_number integer
---@field max_health number Highest max_health of any enemy in cluster

---@class fa.EnemyRadar.State
---@field active_sounds table<string, true> Sound IDs currently playing

---@return fa.EnemyRadar.State
local function make_default_state()
   return {
      active_sounds = {},
   }
end

---@type table<integer, fa.EnemyRadar.State>
local radar_storage = StorageManager.declare_storage_module("enemy_radar", make_default_state, {
   ephemeral_state_version = 1,
})

---Randomly sample a fraction of enemies
---@param enemies LuaEntity[]
---@param fraction number Fraction to keep (0-1)
---@return LuaEntity[]
local function sample_enemies(enemies, fraction)
   if #enemies == 0 or fraction >= 1 then return enemies end

   local sampled = {}
   for _, enemy in ipairs(enemies) do
      if math.random() < fraction then sampled[#sampled + 1] = enemy end
   end
   return sampled
end

---Leader-based clustering of enemy positions
---@param enemies LuaEntity[]
---@return fa.EnemyRadar.Cluster[]
local function cluster_enemies(enemies)
   if #enemies == 0 then return {} end

   -- Sort by unit number for stable clustering
   table.sort(enemies, function(a, b)
      return a.unit_number < b.unit_number
   end)

   ---@type fa.EnemyRadar.Cluster[]
   local clusters = {}

   for _, enemy in ipairs(enemies) do
      local pos = enemy.position
      local enemy_max_health = enemy.max_health
      local found_cluster = false

      -- Try to join an existing cluster
      for _, cluster in ipairs(clusters) do
         local dx = pos.x - cluster.center_x
         local dy = pos.y - cluster.center_y
         if dx * dx + dy * dy <= CLUSTER_THRESHOLD_SQ then
            -- Update centroid incrementally
            local old_count = cluster.count
            cluster.count = cluster.count + 1
            cluster.center_x = (cluster.center_x * old_count + pos.x) / cluster.count
            cluster.center_y = (cluster.center_y * old_count + pos.y) / cluster.count
            -- min_unit_number stays the same since we sorted ascending
            -- Track the strongest enemy in the cluster
            if enemy_max_health > cluster.max_health then cluster.max_health = enemy_max_health end
            found_cluster = true
            break
         end
      end

      -- Create new cluster if no match found
      if not found_cluster then
         clusters[#clusters + 1] = {
            center_x = pos.x,
            center_y = pos.y,
            count = 1,
            min_unit_number = enemy.unit_number,
            max_health = enemy_max_health,
         }
      end
   end

   return clusters
end

---Build sound for a cluster
---@param id string
---@param params fa.SoundModel.DirectionalParams
---@param pitch number
---@return fa.LauncherAudio.PatchBuilder
local function build_cluster_sound(id, params, pitch)
   local volume = SOUND_VOLUME * (params.gain or 1)
   local builder = LauncherAudio.patch(id):file(SOUND_FILE):volume(volume):pan(params.pan):playback_rate(pitch)
   SoundModel.apply_lpf(builder, params)
   return builder
end

---Main tick handler
---@param pindex integer
function mod.tick(pindex)
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

   -- Find enemy units in search area
   local surface = player.surface
   local enemies = surface.find_enemy_units(
      ref_pos,
      half_width * 1.5, -- Search slightly beyond visible area
      player.force
   )

   -- Also find enemy turrets (worms)
   local turrets = surface.find_entities_filtered({
      area = { { left, top }, { right, bottom } },
      type = "turret",
      force = "enemy",
   })

   -- Filter units to only those within visible bounds
   local visible_enemies = {}
   for _, enemy in ipairs(enemies) do
      if enemy.valid then
         local pos = enemy.position
         if pos.x >= left and pos.x <= right and pos.y >= top and pos.y <= bottom then
            visible_enemies[#visible_enemies + 1] = enemy
         end
      end
   end

   -- Add turrets (already filtered by area)
   for _, turret in ipairs(turrets) do
      if turret.valid then visible_enemies[#visible_enemies + 1] = turret end
   end

   -- Sample a random subset of enemies for this tick
   local sampled_enemies = sample_enemies(visible_enemies, ENEMY_SAMPLE_FRACTION)

   -- Cluster the sampled enemies
   local clusters = cluster_enemies(sampled_enemies)

   -- Build sound IDs for current clusters
   local current_sounds = {}
   for _, cluster in ipairs(clusters) do
      local sound_id = "group-" .. cluster.min_unit_number
      current_sounds[sound_id] = cluster
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

   -- Play sounds for current clusters relative to reference position
   for sound_id, cluster in pairs(current_sounds) do
      local dx = cluster.center_x - ref_pos.x
      local dy = cluster.center_y - ref_pos.y
      local params = SoundModel.map_relative_position(dx, dy, half_width, ref_distance)
      local pitch = health_to_pitch(cluster.max_health)

      local builder = build_cluster_sound(sound_id, params, pitch)
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
