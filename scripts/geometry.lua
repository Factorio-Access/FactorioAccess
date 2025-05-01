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
---@type fun(number, number, number, nuamber): number
function mod.dot_unrolled_2d(x1, y1, x2, y2)
   return x1 * x2 + y1 * y2
end

-- Get the unit vector for a given direction.
---@param dir defines.direction
---@return number, number
function mod.uv_for_direction(dir)
   local v = Consts.DIRECTION_VECTORS[dir + 1]
   assert(v)
   return v.x, v.y
end
return mod
