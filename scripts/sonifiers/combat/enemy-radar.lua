--[[
Enemy Radar Sonifier - Audio feedback for nearby enemies using leader-based clustering.

Groups enemies within a threshold distance into clusters, playing a sound at each
cluster's centroid. Sound IDs are stable based on the minimum unit number in each
group, providing consistent audio even as enemies move.
]]

local GridConsts = require("scripts.sonifiers.grid-consts")
local LauncherAudio = require("scripts.launcher-audio")
local SoundModel = require("scripts.sound-model")
local StorageManager = require("scripts.storage-manager")
local Viewpoint = require("scripts.viewpoint")
local Zoom = require("scripts.zoom")

local mod = {}

-- Clustering threshold in tiles
local CLUSTER_THRESHOLD = 2
local CLUSTER_THRESHOLD_SQ = CLUSTER_THRESHOLD * CLUSTER_THRESHOLD

-- Sound configuration (reusing crafting machine sound for prototype)
local SOUND_FILE = "sonifiers/grid/crafting_machine/complete.ogg"
local SOUND_VOLUME = 0.8

-- Tick interval (every tick for responsive combat feedback)
local TICK_INTERVAL = 1

---@class fa.EnemyRadar.Cluster
---@field center_x number
---@field center_y number
---@field count integer
---@field min_unit_number integer

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
         }
      end
   end

   return clusters
end

---Get the visible area based on cursor position and zoom
---@param pindex integer
---@return number left, number top, number right, number bottom
local function get_visible_area(pindex)
   local viewpoint = Viewpoint.get_viewpoint(pindex)
   local cursor_pos = viewpoint:get_cursor_pos()
   local tiles = Zoom.get_current_zoom_tiles(pindex)

   local half_tiles = tiles / 2

   return cursor_pos.x - half_tiles, cursor_pos.y - half_tiles, cursor_pos.x + half_tiles, cursor_pos.y + half_tiles
end

---Build sound for a cluster
---@param id string
---@param params fa.SoundModel.DirectionalParams
---@return fa.LauncherAudio.PatchBuilder
local function build_cluster_sound(id, params)
   local volume = SOUND_VOLUME * (params.gain or 1)
   local builder = LauncherAudio.patch(id):file(SOUND_FILE):volume(volume):pan(params.pan)
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

   -- Get visible area
   local left, top, right, bottom = get_visible_area(pindex)
   local center_x = (left + right) / 2
   local center_y = (top + bottom) / 2

   -- Reference distance for attenuation
   local half_width = (right - left) / 2
   local ref_distance = half_width / 4

   -- Find enemy units in visible area
   local surface = player.surface
   local enemies = surface.find_enemy_units(
      { x = center_x, y = center_y },
      half_width * 1.5, -- Search slightly beyond visible area
      player.force
   )

   -- Filter to only enemies within visible bounds
   local visible_enemies = {}
   for _, enemy in ipairs(enemies) do
      if enemy.valid then
         local pos = enemy.position
         if pos.x >= left and pos.x <= right and pos.y >= top and pos.y <= bottom then
            visible_enemies[#visible_enemies + 1] = enemy
         end
      end
   end

   -- Cluster the enemies
   local clusters = cluster_enemies(visible_enemies)

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

   -- Play sounds for current clusters
   for sound_id, cluster in pairs(current_sounds) do
      local dx = cluster.center_x - center_x
      local dy = cluster.center_y - center_y
      local params = SoundModel.map_relative_position(dx, dy, ref_distance)

      local builder = build_cluster_sound(sound_id, params)
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
