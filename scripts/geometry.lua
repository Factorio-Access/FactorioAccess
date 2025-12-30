--[[
Geometry math.
]]
local Consts = require("scripts.consts")

local mod = {}

--[[
Offset the given direction by a given number of directions.  That is an offset
of 4 is 90 degrees clockwise, and an offset of -4 90 degrees counterclockwise.
]]
---@param dir defines.direction
---@param offset number
---@return defines.direction
local function offset_dir(dir, offset)
   return (dir + offset) % 16 --[[ @as defines.direction ]]
end

mod.offset_dir = offset_dir

---@param dir defines.direction
---@return defines.direction dir rotated 90 degrees counterclockwise.
function mod.dir_counterclockwise_90(dir)
   return offset_dir(dir, -4)
end

---@param dir defines.direction
---@return defines.direction dir rotated 90 degrees clockwise
function mod.dir_clockwise_90(dir)
   return offset_dir(dir, 4)
end

---@param dir defines.direction
---@return defines.direction
function mod.dir_rot180(dir)
   return (dir + 8) % 16
end

-- The dot product, but set up to not require intermediate tables.
---@type fun(x1: number, y1: number, x2: number, y2: number): number
function mod.dot_unrolled_2d(x1, y1, x2, y2)
   return x1 * x2 + y1 * y2
end

-- Get the unit vector for a given direction.
---@param dir defines.direction
---@return number, number
function mod.uv_for_direction(dir)
   local v = Consts.DIRECTION_VECTORS[dir]
   assert(v)
   return v.x, v.y
end

-- Calculate the magnitude (length) of a 2D vector, unrolled to avoid tables
---@param x number
---@param y number
---@return number
function mod.magnitude_2d(x, y)
   return math.sqrt(x * x + y * y)
end

-- Normalize a 2D vector (make it unit length), returns individual components
---@param x number
---@param y number
---@return number nx normalized x component
---@return number ny normalized y component
function mod.normalize_2d(x, y)
   local mag = math.sqrt(x * x + y * y)
   if mag < 0.001 then return 0, 0 end
   return x / mag, y / mag
end

-- Calculate angle between two 2D vectors in radians (0 to pi)
-- Uses unrolled parameters to avoid intermediate tables
---@param x1 number first vector x component
---@param y1 number first vector y component
---@param x2 number second vector x component
---@param y2 number second vector y component
---@return number angle in radians (0 to pi)
function mod.angle_between_2d(x1, y1, x2, y2)
   local dot = x1 * x2 + y1 * y2
   local len1 = math.sqrt(x1 * x1 + y1 * y1)
   local len2 = math.sqrt(x2 * x2 + y2 * y2)

   if len1 < 0.001 or len2 < 0.001 then return 0 end

   local cos_angle = dot / (len1 * len2)
   cos_angle = math.max(-1, math.min(1, cos_angle))
   return math.acos(cos_angle)
end

-- Convert angle in radians to degrees
---@param radians number
---@return number
function mod.radians_to_degrees(radians)
   return radians * 180 / math.pi
end

-- Rotate a vector by an entity's direction
-- Transforms entity-local coordinates to world coordinates
---@param local_x number Entity-relative x coordinate
---@param local_y number Entity-relative y coordinate
---@param direction defines.direction Entity's facing direction
---@return number world_x World x coordinate
---@return number world_y World y coordinate
function mod.rotate_vec(local_x, local_y, direction)
   local ux, uy = mod.uv_for_direction(direction)
   -- The direction vector (ux, uy) points where the entity's forward faces
   -- Entity-local "forward" is (0, -1) and "right" is (1, 0)
   -- Rotation matrix maps entity-local to world coordinates:
   --   forward (0, -1) -> (ux, uy)
   --   right (1, 0) -> (-uy, ux)
   -- Matrix: [-uy  -ux]
   --         [ ux  -uy]
   return -uy * local_x - ux * local_y, ux * local_x - uy * local_y
end

-- Convert a vector (dx, dy) to the nearest cardinal direction
-- Only handles the 4 cardinal directions (N/E/S/W) for axis-aligned vectors
---@param dx number
---@param dy number
---@return defines.direction
function mod.vector_to_direction_cardinal(dx, dy)
   if math.abs(dx) > math.abs(dy) then
      return dx > 0 and defines.direction.east or defines.direction.west
   else
      return dy > 0 and defines.direction.south or defines.direction.north
   end
end

-- Check if two directions are collinear (on the same axis, either same or opposite)
---@param dir1 defines.direction
---@param dir2 defines.direction
---@return boolean collinear Whether the directions are on the same axis
---@return boolean opposite If collinear, whether they face opposite directions
function mod.are_directions_collinear(dir1, dir2)
   local diff = (dir2 - dir1) % 16
   if diff == 0 then
      return true, false -- same direction
   elseif diff == 8 then
      return true, true -- opposite direction
   else
      return false, false
   end
end

return mod
