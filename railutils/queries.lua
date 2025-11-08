---Rail Traversal Utilities
---
---Functions for finding rail connection points and navigating rail networks

require("polyfill")

local RailData = require("railutils.rail-data")
local RailInfo = require("railutils.rail-info")

local mod = {}

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
      local prototype_type = rail_type_to_prototype_type(rail.rail_type)
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
