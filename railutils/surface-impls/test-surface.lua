---Test Surface Implementation
---
---Simple in-memory surface for testing rail operations without a real Factorio surface

require("polyfill")

local RailData = require("railutils.rail-data")
local RailInfo = require("railutils.rail-info")

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

---Map RailType to prototype type string for table lookup
---@param rail_type railutils.RailType
---@return string
local function rail_type_to_prototype_type(rail_type)
   if rail_type == RailInfo.RailType.STRAIGHT then
      return "straight-rail"
   elseif rail_type == RailInfo.RailType.CURVE_A then
      return "curved-rail-a"
   elseif rail_type == RailInfo.RailType.CURVE_B then
      return "curved-rail-b"
   elseif rail_type == RailInfo.RailType.HALF_DIAGONAL then
      return "half-diagonal-rail"
   end
   error("Unknown rail type: " .. tostring(rail_type))
end

---Check if a rail occupies a specific tile
---@param rail railutils.RailInfo The rail to check
---@param tile_x number Integer tile x coordinate
---@param tile_y number Integer tile y coordinate
---@return boolean
local function rail_occupies_tile(rail, tile_x, tile_y)
   local prototype_type = rail_type_to_prototype_type(rail.rail_type)
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
---@param rail_type railutils.RailType Type of rail to add
---@param position fa.Point Position to place the rail
---@param direction defines.direction Direction to place the rail
---@return railutils.RailInfo The added rail
function TestSurface:add_rail(rail_type, position, direction)
   local rail = {
      prototype_position = { x = position.x, y = position.y },
      rail_type = rail_type,
      direction = direction,
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
