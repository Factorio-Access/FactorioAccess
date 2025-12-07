--[[
Zoom control.

Provides functions to set and read zoom levels calibrated to show a specific number of tiles.
The cache must be cleared when display resolution changes as zoom values depend on window dimensions.
]]
local StorageManager = require("scripts.storage-manager")
local Speech = require("scripts.speech")

local mod = {}

-- Zoom levels in tiles (diameter - full distance across screen). This list is calibrated to the default zoom limits for
-- the character view.
mod.ZOOM_LEVELS = { 20, 50, 100, 200 }

---@class fa.ZoomCache
---@field tile_to_zoom_cache table<number, number> Mapping from tile count to zoom value

---@type table<number, fa.ZoomCache>
local zoom_cache = StorageManager.declare_storage_module("zoom_cache", {
   tile_to_zoom_cache = {},
})

---Clear the zoom cache for a player.
---Call this when display resolution or scale changes.
---@param pindex integer
function mod.clear_cache(pindex)
   zoom_cache[pindex].tile_to_zoom_cache = {}
end

---Get the zoom value needed to see t tiles across the screen.
---This temporarily manipulates zoom limits to measure the actual zoom, then restores them.
---Results are cached per-player until clear_cache is called.
---@param pindex integer
---@param t number Number of tiles (diameter)
---@return number zoom The zoom value that shows t tiles
function mod.zoom_for_tiles(pindex, t)
   local cache = zoom_cache[pindex]
   if cache.tile_to_zoom_cache[t] then return cache.tile_to_zoom_cache[t] end

   local player = game.get_player(pindex)

   -- Save current zoom limits
   local original_limits = player.zoom_limits

   -- Set all limits to the target tile count
   player.zoom_limits = {
      closest = { distance = t, max_distance = t },
      furthest = { distance = t, max_distance = t },
      furthest_game_view = { distance = t, max_distance = t },
   }

   -- Read the actual zoom value that Factorio computed
   local zoom = player.zoom

   -- Restore original limits
   player.zoom_limits = original_limits

   -- Cache and return
   cache.tile_to_zoom_cache[t] = zoom
   return zoom
end

---Find the closest index in ZOOM_LEVELS to the current player zoom.
---@param pindex integer
---@return integer index The 1-based index into ZOOM_LEVELS
function mod.get_closest_zoom_index(pindex)
   local player = game.get_player(pindex)
   local current_zoom = player.zoom

   local best_index = 1
   local best_diff = math.huge

   for i, tiles in ipairs(mod.ZOOM_LEVELS) do
      local target_zoom = mod.zoom_for_tiles(pindex, tiles)
      local diff = math.abs(current_zoom - target_zoom)
      if diff < best_diff then
         best_diff = diff
         best_index = i
      end
   end

   return best_index
end

---Set zoom to a specific tile count and announce result.
---Warns if the actual zoom differs from expected (due to player's zoom limits).
---@param pindex integer
---@param tiles number The target tile count (diameter)
local function set_zoom_and_announce(pindex, tiles)
   local player = game.get_player(pindex)
   local target_zoom = mod.zoom_for_tiles(pindex, tiles)

   -- Set the zoom
   player.zoom = target_zoom

   -- Read back and compare
   local actual_zoom = player.zoom
   local epsilon = 1e-3

   if math.abs(actual_zoom - target_zoom) > epsilon then
      -- Zoom was clamped by player's limits
      Speech.speak(pindex, { "fa.zoom-limited", tiles })
   else
      Speech.speak(pindex, { "fa.zoom-set", tiles })
   end
end

---Binary search to find the current zoom level in tiles.
---Searches from 1 to 1000 tiles to find what tile count matches the player's current zoom.
---@param pindex integer
---@return integer tiles The approximate tile count for the current zoom
function mod.get_current_zoom_tiles(pindex)
   local player = game.get_player(pindex)
   local current_zoom = player.zoom

   local low = 1
   local high = 1000

   -- Binary search: zoom_for_tiles returns smaller values for larger tile counts
   -- So if current_zoom < zoom_for_tiles(mid), we need more tiles (go higher)
   while high - low > 1 do
      local mid = math.floor((low + high) / 2)
      local mid_zoom = mod.zoom_for_tiles(pindex, mid)

      if current_zoom < mid_zoom then
         -- Current zoom is more zoomed out, need more tiles
         low = mid
      else
         -- Current zoom is more zoomed in, need fewer tiles
         high = mid
      end
   end

   -- Check which endpoint is closer
   local low_zoom = mod.zoom_for_tiles(pindex, low)
   local high_zoom = mod.zoom_for_tiles(pindex, high)

   if math.abs(current_zoom - low_zoom) < math.abs(current_zoom - high_zoom) then
      return low
   else
      return high
   end
end

---Announce the current zoom level in tiles
---@param pindex integer
function mod.announce_zoom(pindex)
   local tiles = mod.get_current_zoom_tiles(pindex)
   Speech.speak(pindex, { "fa.zoom-current", tiles })
end

---Handle zoom out (minus key)
---@param pindex integer
function mod.zoom_out(pindex)
   local current_index = mod.get_closest_zoom_index(pindex)
   local new_index = math.min(current_index + 1, #mod.ZOOM_LEVELS)

   if new_index == current_index then
      Speech.speak(pindex, { "fa.zoom-at-max", mod.ZOOM_LEVELS[current_index] })
   else
      set_zoom_and_announce(pindex, mod.ZOOM_LEVELS[new_index])
   end
end

---Handle zoom in (equals key)
---@param pindex integer
function mod.zoom_in(pindex)
   local current_index = mod.get_closest_zoom_index(pindex)
   local new_index = math.max(current_index - 1, 1)

   if new_index == current_index then
      Speech.speak(pindex, { "fa.zoom-at-min", mod.ZOOM_LEVELS[current_index] })
   else
      set_zoom_and_announce(pindex, mod.ZOOM_LEVELS[new_index])
   end
end

return mod
