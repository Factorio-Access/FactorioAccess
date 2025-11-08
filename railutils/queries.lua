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

---Get all extension points at a given position
---
---Queries the surface for rails at the position and returns information about
---all possible extensions from all rail ends found at that location.
---
---@param surface railutils.RailsSurface Surface to query (GameSurface or TestSurface)
---@param position fa.Point Position to query (1x1 grid coordinates)
---@return table<defines.direction, railutils.ExtensionPoint[]> Extensions keyed by goal direction
function mod.get_extension_points_at_position(surface, position)
   local rails = surface:get_rails_at_point(position)

   local extension_points = {}

   for _, rail in ipairs(rails) do
      local prototype_type = mod.rail_type_to_prototype_type(rail.rail_type)
      local rail_entry = RailData[prototype_type]

      if rail_entry then
         local direction_entry = rail_entry[rail.direction]

         if direction_entry then
            -- Iterate over all ends of this rail
            for end_direction, end_data in pairs(direction_entry) do
               -- Skip non-end entries (grid_offset, bounding_box, occupied_tiles)
               if type(end_direction) == "number" and end_data.extensions then
                  -- Calculate absolute position of the end
                  local end_abs_position = {
                     x = rail.prototype_position.x + end_data.position.x,
                     y = rail.prototype_position.y + end_data.position.y,
                  }

                  -- Iterate over all extensions from this end
                  for goal_dir, extension in pairs(end_data.extensions) do
                     -- Calculate absolute positions for the extension
                     local next_rail_abs_position = {
                        x = rail.prototype_position.x + extension.position.x,
                        y = rail.prototype_position.y + extension.position.y,
                     }

                     local next_rail_goal_abs_position = {
                        x = rail.prototype_position.x + extension.goal_position.x,
                        y = rail.prototype_position.y + extension.goal_position.y,
                     }

                     local ext_point = {
                        rail_unit_number = rail.unit_number,
                        end_position = end_abs_position,
                        end_direction = end_direction,
                        goal_direction = goal_dir,
                        next_rail_prototype = extension.prototype,
                        next_rail_position = next_rail_abs_position,
                        next_rail_direction = extension.direction,
                        next_rail_goal_position = next_rail_goal_abs_position,
                        next_rail_goal_direction = extension.goal_direction,
                     }

                     -- Group by goal direction
                     if not extension_points[goal_dir] then extension_points[goal_dir] = {} end

                     table.insert(extension_points[goal_dir], ext_point)
                  end
               end
            end
         end
      end
   end

   return extension_points
end

return mod
