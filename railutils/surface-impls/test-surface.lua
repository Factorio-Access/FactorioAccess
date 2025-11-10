---Test Surface Implementation
---
---Simple in-memory surface for testing rail operations without a real Factorio surface

require("polyfill")

local RailData = require("railutils.rail-data")
local RailInfo = require("railutils.rail-info")
local Queries = require("railutils.queries")

local mod = {}

---Test surface storing rail placements in memory
---@class railutils.TestSurface : railutils.RailsSurface
---@field _rails railutils.RailInfo[] List of rails placed on this surface
---@field _next_unit_number number Counter for generating unit numbers
local TestSurface = {}
local TestSurface_meta = { __index = TestSurface }

---Create a new test surface
---@return railutils.TestSurface
function mod.new()
   return setmetatable({
      _rails = {},
      _next_unit_number = 1,
   }, TestSurface_meta)
end

---Check if a rail occupies a specific tile
---@param rail railutils.RailInfo The rail to check
---@param tile_x number Integer tile x coordinate
---@param tile_y number Integer tile y coordinate
---@return boolean
local function rail_occupies_tile(rail, tile_x, tile_y)
   local prototype_type = Queries.rail_type_to_prototype_type(rail.rail_type)
   local rail_entry = RailData[prototype_type]
   if not rail_entry then return false end

   local direction_entry = rail_entry[rail.direction]
   if not direction_entry then return false end

   local occupied_tiles = direction_entry.occupied_tiles
   if not occupied_tiles then return false end

   -- Occupied tiles are relative to rail position
   -- Shift them by rail position and check against target tile
   for _, offset in ipairs(occupied_tiles) do
      local occupied_x = rail.prototype_position.x + offset.x
      local occupied_y = rail.prototype_position.y + offset.y

      if math.floor(occupied_x) == tile_x and math.floor(occupied_y) == tile_y then return true end
   end

   return false
end

---Add a rail to the test surface
---
---Like the real game, this applies grid alignment by looking up the grid_offset
---from the rail data and adjusting the position to match parity requirements.
---Also corrects direction for straight rails (mod 8).
---
---@param rail_type railutils.RailType Type of rail to add
---@param position fa.Point Position to place the rail (will be adjusted for grid alignment)
---@param direction defines.direction Direction to place the rail
---@return railutils.RailInfo The added rail (with adjusted position and direction)
function TestSurface:add_rail(rail_type, position, direction)
   -- Correct direction for straight and half-diagonal rails (game applies mod 8)
   local corrected_direction = direction
   if rail_type == RailInfo.RailType.STRAIGHT or rail_type == RailInfo.RailType.HALF_DIAGONAL then
      corrected_direction = direction % 8
   end

   -- Determine grid offset based on rail type, corrected direction, and position parity
   -- These patterns match the game's actual behavior (see devdocs/rail-geometry.md)
   local grid_offset
   if rail_type == RailInfo.RailType.STRAIGHT then
      -- Straight rails snap to 2x2 grid to ensure centers at parity (1,1)
      -- Both N/S and E/W orientations use inverted parity formula
      local x_parity = math.abs(position.x) % 2
      local y_parity = math.abs(position.y) % 2
      if corrected_direction == 0 or corrected_direction == 4 then
         -- Directions 0, 4: inverted parity (most common orientations)
         grid_offset = { x = 1 - x_parity, y = 1 - y_parity }
      else -- corrected_direction == 2 or 6
         -- Directions 2, 6: direct parity (alternate orientations)
         grid_offset = { x = x_parity, y = y_parity }
      end
   elseif rail_type == RailInfo.RailType.CURVE_A then
      -- Curved-a rails depend on both X and Y parity
      local x_parity = math.abs(position.x) % 2
      local y_parity = math.abs(position.y) % 2
      if
         corrected_direction == 0
         or corrected_direction == 2
         or corrected_direction == 8
         or corrected_direction == 10
      then
         grid_offset = { x = 1 - x_parity, y = y_parity }
      else -- 4, 6, 12, 14
         grid_offset = { x = x_parity, y = 1 - y_parity }
      end
   elseif rail_type == RailInfo.RailType.CURVE_B then
      -- Curved-b rails depend on both X and Y parity
      local x_parity = math.abs(position.x) % 2
      local y_parity = math.abs(position.y) % 2
      grid_offset = { x = 1 - x_parity, y = 1 - y_parity }
   elseif rail_type == RailInfo.RailType.HALF_DIAGONAL then
      -- Half-diagonal rails depend on both X and Y parity (after mod 8)
      local x_parity = math.abs(position.x) % 2
      local y_parity = math.abs(position.y) % 2
      grid_offset = { x = 1 - x_parity, y = 1 - y_parity }
   else
      error("Unknown rail type: " .. tostring(rail_type))
   end

   -- Apply grid offset (what the game does for parity alignment)
   local adjusted_position = {
      x = position.x + grid_offset.x,
      y = position.y + grid_offset.y,
   }

   local rail = {
      prototype_position = adjusted_position,
      rail_type = rail_type,
      direction = corrected_direction,
      unit_number = self._next_unit_number,
   }

   self._next_unit_number = self._next_unit_number + 1
   table.insert(self._rails, rail)

   return rail
end

---Get rails at a specific tile position
---@param point fa.Point Tile coordinates (1x1 grid)
---@return railutils.RailInfo[]
function TestSurface:get_rails_at_point(point)
   local floor_x = math.floor(point.x)
   local floor_y = math.floor(point.y)

   local rails_at_tile = {}

   -- Iterate all rails and check if they occupy this tile
   for _, rail in ipairs(self._rails) do
      if rail_occupies_tile(rail, floor_x, floor_y) then table.insert(rails_at_tile, rail) end
   end

   return rails_at_tile
end

---Clear all rails from the surface
function TestSurface:clear()
   self._rails = {}
   self._next_unit_number = 1
end

return mod
