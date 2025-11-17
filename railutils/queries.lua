---Rail Traversal Utilities
---
---Functions for finding rail connection points and navigating rail networks

require("polyfill")

local RailData = require("railutils.rail-data")
local RailInfo = require("railutils.rail-info")

local mod = {}

---Map from defines.direction to direction name
---@type table<defines.direction, string>
mod.DIRECTION_NAMES = {
   [defines.direction.north] = "north",
   [defines.direction.northnortheast] = "northnortheast",
   [defines.direction.northeast] = "northeast",
   [defines.direction.eastnortheast] = "eastnortheast",
   [defines.direction.east] = "east",
   [defines.direction.eastsoutheast] = "eastsoutheast",
   [defines.direction.southeast] = "southeast",
   [defines.direction.southsoutheast] = "southsoutheast",
   [defines.direction.south] = "south",
   [defines.direction.southsouthwest] = "southsouthwest",
   [defines.direction.southwest] = "southwest",
   [defines.direction.westsouthwest] = "westsouthwest",
   [defines.direction.west] = "west",
   [defines.direction.westnorthwest] = "westnorthwest",
   [defines.direction.northwest] = "northwest",
   [defines.direction.northnorthwest] = "northnorthwest",
}

---Map from defines.direction to cardinal name (only for cardinals)
---@type table<defines.direction, string>
mod.CARDINAL_NAMES = {
   [defines.direction.north] = "north",
   [defines.direction.east] = "east",
   [defines.direction.south] = "south",
   [defines.direction.west] = "west",
}

---Map from defines.direction to diagonal name (only for diagonals)
---@type table<defines.direction, string>
mod.DIAGONAL_NAMES = {
   [defines.direction.northeast] = "northeast",
   [defines.direction.southeast] = "southeast",
   [defines.direction.southwest] = "southwest",
   [defines.direction.northwest] = "northwest",
}

---Get direction name
---@param direction defines.direction
---@return string
function mod.get_direction_name(direction)
   return mod.DIRECTION_NAMES[direction] or "unknown"
end

---Get cardinal name (only for cardinal directions)
---@param direction defines.direction
---@return string|nil
function mod.get_cardinal_name(direction)
   return mod.CARDINAL_NAMES[direction]
end

---Get diagonal name (only for diagonal directions)
---@param direction defines.direction
---@return string|nil
function mod.get_diagonal_name(direction)
   return mod.DIAGONAL_NAMES[direction]
end

---Map RailType to prototype type string for table lookup
---@param rail_type railutils.RailType
---@return string
function mod.rail_type_to_prototype_type(rail_type)
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

---Map prototype type string to RailType
---@param prototype string Prototype type string like "curved-rail-a"
---@return railutils.RailType
function mod.prototype_type_to_rail_type(prototype)
   if prototype == "straight-rail" then
      return RailInfo.RailType.STRAIGHT
   elseif prototype == "curved-rail-a" then
      return RailInfo.RailType.CURVE_A
   elseif prototype == "curved-rail-b" then
      return RailInfo.RailType.CURVE_B
   elseif prototype == "half-diagonal-rail" then
      return RailInfo.RailType.HALF_DIAGONAL
   end
   error("Unknown prototype: " .. tostring(prototype))
end

---Get the grid-adjusted position where a rail will actually be placed
---
---Rails have parity requirements and the game snaps them to the grid by applying
---a grid_offset. This function returns the actual position where the rail will end up.
---
---@param rail_type railutils.RailType Type of rail to place
---@param position fa.Point Requested position
---@param direction defines.direction Direction to place the rail
---@return fa.Point The actual position after grid adjustment
function mod.get_adjusted_position(rail_type, position, direction)
   local prototype_type = mod.rail_type_to_prototype_type(rail_type)
   local rail_entry = RailData[prototype_type]
   if not rail_entry then error("Unknown rail prototype: " .. prototype_type) end

   local direction_entry = rail_entry[direction]
   if not direction_entry then error("Invalid direction for rail type: " .. direction) end

   local grid_offset = direction_entry.grid_offset
   if not grid_offset then error("No grid_offset found for rail") end

   return {
      x = position.x + grid_offset.x,
      y = position.y + grid_offset.y,
   }
end

---Get both end directions for a rail
---
---Every rail has two ends. This returns the directions of both ends.
---
---@param rail_type railutils.RailType Type of rail
---@param placement_direction defines.direction Direction the rail is placed
---@return defines.direction[] Array of two end directions
function mod.get_end_directions(rail_type, placement_direction)
   local prototype_type = mod.rail_type_to_prototype_type(rail_type)
   local rail_entry = RailData[prototype_type]
   if not rail_entry then error("Unknown rail prototype: " .. prototype_type) end

   local direction_entry = rail_entry[placement_direction]
   if not direction_entry then error("Invalid placement direction for rail type: " .. placement_direction) end

   local end_directions = {}
   for key, value in pairs(direction_entry) do
      -- End directions are numeric keys with extension data
      if type(key) == "number" and value.extensions then table.insert(end_directions, key) end
   end

   if #end_directions ~= 2 then error("Expected 2 ends, found " .. #end_directions) end

   return end_directions
end

---Extension point information
---@class railutils.ExtensionPoint
---@field rail_unit_number number Unit number of the rail this extension is from
---@field end_position fa.Point Absolute position of the rail end
---@field end_direction defines.direction Direction the rail end faces
---@field goal_direction defines.direction Direction of the extension
---@field next_rail_prototype string Prototype type to place for this extension
---@field next_rail_position fa.Point Absolute position to place next rail
---@field next_rail_direction defines.direction Direction to place next rail
---@field next_rail_goal_position fa.Point Absolute position of far end of next rail
---@field next_rail_goal_direction defines.direction Direction of far end of next rail

---Get extension points from a specific end of a specific rail configuration
---
---@param position fa.Point Rail's grid-adjusted position
---@param rail_type railutils.RailType Type of rail
---@param placement_direction defines.direction Direction the rail is placed
---@param end_direction defines.direction Which end to get extensions from
---@return railutils.ExtensionPoint[] Array of extensions from this end
function mod.get_extensions_from_end(position, rail_type, placement_direction, end_direction)
   local prototype_type = mod.rail_type_to_prototype_type(rail_type)
   local rail_entry = RailData[prototype_type]
   if not rail_entry then error("Unknown rail prototype: " .. prototype_type) end

   local direction_entry = rail_entry[placement_direction]
   if not direction_entry then error("Invalid placement direction for rail type: " .. placement_direction) end

   local end_data = direction_entry[end_direction]
   if not end_data or not end_data.extensions then
      error("Invalid end_direction or no extensions for this end: " .. end_direction)
   end

   local extensions = {}

   -- Calculate absolute position of the end
   local end_abs_position = {
      x = position.x + end_data.position.x,
      y = position.y + end_data.position.y,
   }

   -- Iterate over all extensions from this end
   for goal_dir, extension in pairs(end_data.extensions) do
      -- Calculate absolute positions for the extension
      local next_rail_abs_position = {
         x = position.x + extension.position.x,
         y = position.y + extension.position.y,
      }

      local next_rail_goal_abs_position = {
         x = position.x + extension.goal_position.x,
         y = position.y + extension.goal_position.y,
      }

      local ext_point = {
         rail_unit_number = nil, -- Not relevant when querying by configuration
         end_position = end_abs_position,
         end_direction = end_direction,
         goal_direction = goal_dir,
         next_rail_prototype = extension.prototype,
         next_rail_position = next_rail_abs_position,
         next_rail_direction = extension.direction,
         next_rail_goal_position = next_rail_goal_abs_position,
         next_rail_goal_direction = extension.goal_direction,
      }

      table.insert(extensions, ext_point)
   end

   return extensions
end

return mod
