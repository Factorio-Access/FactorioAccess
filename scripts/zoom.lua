--[[
Zoom control.

Provides functions to set and read zoom levels calibrated to show a specific number of tiles.
]]
local SoundModel = require("scripts.sound-model")
local Speech = require("scripts.speech")

local mod = {}

-- Zoom levels in tiles (diameter - full distance across screen). This list is calibrated to the default zoom limits for
-- the character view.
mod.ZOOM_LEVELS = { 20, 50, 100, 200 }

-- The base pixels per tile at zoom=1.
local base_pixels_per_tile = 32

---Get the zoom value needed to see t tiles across the screen.
---@param pindex integer
---@param t number Number of tiles (diameter)
---@return number zoom The zoom value that shows t tiles
function mod.zoom_for_tiles(pindex, t)
   local player = game.get_player(pindex)
   local screen = player.display_resolution
   local screen_dimension = math.max(screen.width, screen.height)
   return screen_dimension / (t * base_pixels_per_tile * player.display_density_scale)
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

---Get the current zoom level in tiles.
---Inverse of zoom_for_tiles.
---@param pindex integer
---@return integer tiles The tile count for the current zoom
function mod.get_current_zoom_tiles(pindex)
   local player = game.get_player(pindex)
   local screen = player.display_resolution
   local screen_dimension = math.max(screen.width, screen.height)
   return math.floor(screen_dimension / (player.zoom * base_pixels_per_tile * player.display_density_scale) + 0.5)
end

---Append zoom info to a MessageBuilder
---@param pindex integer
---@param mb fa.MessageBuilder
function mod.append_zoom_info(pindex, mb)
   local tiles = mod.get_current_zoom_tiles(pindex)
   mb:fragment({ "fa.zoom-current", tiles })
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

---@class fa.Zoom.SearchArea
---@field left number
---@field top number
---@field right number
---@field bottom number
---@field half_width number

---Get the search area centered on the sound model reference point (cursor or character)
---@param pindex integer
---@return fa.Zoom.SearchArea
function mod.get_search_area(pindex)
   local ref_pos = SoundModel.get_reference_position(pindex)
   local tiles = mod.get_current_zoom_tiles(pindex)
   local half_tiles = tiles / 2

   return {
      left = ref_pos.x - half_tiles,
      top = ref_pos.y - half_tiles,
      right = ref_pos.x + half_tiles,
      bottom = ref_pos.y + half_tiles,
      half_width = half_tiles,
   }
end

return mod
