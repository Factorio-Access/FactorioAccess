--[[
Determine the directional "shape" of tile-grid networks such as fluid pipes or heat pipes.

This module is responsible for computing a normalized shape for an entity based on its
connections to neighboring tiles. This shape is described using a small set of canonical
forms such as corner, straight, T-junction, or cross.

Originally this logic lived in `fluids.lua`, where it was used to describe the layout of
pipe networks. However, since heat pipes and similar systems (e.g. reactors, heat exchangers)
use the same basic directional logic, the shape table and shape resolution were abstracted
here.

The shape logic does *not* inspect the contents of a network (e.g. what fluid or temperature
exists), only the connectivity of a given entity. It is suitable for any tile-based system
that connects to cardinal neighbors on a 2D grid.

This module exposes a function that accepts a table describing which of the four cardinal
directions (north, east, south, west) an entity is connected in, and returns a canonical
shape and orientation. This shape can then be used for screen reader announcements, visualization,
or analysis.

This module is agnostic to how connections are determined. Users of this module must supply
a table of boolean flags indicating directional connections, and shape data will be computed
from that.

Example:
  local dirs = {
     [defines.direction.north] = true,
     [defines.direction.east] = true,
     [defines.direction.west] = true,
  }

  local shape = mod.get_shape_from_directions(dirs)
  -- shape.shape == "t"
  -- shape.direction == defines.direction.south  (the open side of the T)
]]
local mod = {}
---@enum fa.NetworkShape.Shape
mod.SHAPE = {
   STRAIGHT = "straight",
   CROSS = "cross",
   CORNER = "corner",
   END = "end",
   ALONE = "alone",
   T = "t",
}

---@alias fa.NetworkShape.ShapeDef { shape: fa.NetworkShape.Shape, direction: defines.direction }

-- SHAPE_TABLE[north][east][south][west] = ShapeDef
---@type table<boolean, table<boolean, table<boolean, table<boolean, fa.NetworkShape.ShapeDef>>>>
local SHAPE_TABLE = {}

local function add_shape(n, e, s, w, shape, direction)
   SHAPE_TABLE[n] = SHAPE_TABLE[n] or {}
   SHAPE_TABLE[n][e] = SHAPE_TABLE[n][e] or {}
   SHAPE_TABLE[n][e][s] = SHAPE_TABLE[n][e][s] or {}
   SHAPE_TABLE[n][e][s][w] = { shape = shape, direction = direction }
end

-- Populate shape definitions
add_shape(true, true, true, true, mod.SHAPE.CROSS, defines.direction.north)
add_shape(true, false, true, false, mod.SHAPE.STRAIGHT, defines.direction.north)
add_shape(false, true, false, true, mod.SHAPE.STRAIGHT, defines.direction.east)
add_shape(true, true, false, false, mod.SHAPE.CORNER, defines.direction.southwest)
add_shape(false, true, true, false, mod.SHAPE.CORNER, defines.direction.northwest)
add_shape(false, false, true, true, mod.SHAPE.CORNER, defines.direction.northeast)
add_shape(true, false, false, true, mod.SHAPE.CORNER, defines.direction.southeast)
add_shape(true, false, false, false, mod.SHAPE.END, defines.direction.north)
add_shape(false, true, false, false, mod.SHAPE.END, defines.direction.east)
add_shape(false, false, true, false, mod.SHAPE.END, defines.direction.south)
add_shape(false, false, false, true, mod.SHAPE.END, defines.direction.west)
add_shape(true, true, true, false, mod.SHAPE.T, defines.direction.west)
add_shape(true, true, false, true, mod.SHAPE.T, defines.direction.south)
add_shape(true, false, true, true, mod.SHAPE.T, defines.direction.east)
add_shape(false, true, true, true, mod.SHAPE.T, defines.direction.north)
add_shape(false, false, false, false, mod.SHAPE.ALONE, defines.direction.north)

--[[
Given a direction map (e.g. { [north] = true, [east] = true }), compute the shape.

Returns a table with shape and direction.

- `shape` is one of "straight", "corner", "cross", "T", "end", or "alone".
- `direction` indicates the "rotation" of the shape, useful for display or narration.
]]
---@param dirs table<defines.direction, boolean>
---@return fa.NetworkShape.ShapeDef
function mod.get_shape_from_directions(dirs)
   local shape =
      SHAPE_TABLE[dirs[defines.direction.north] or false][dirs[defines.direction.east] or false][dirs[defines.direction.south] or false][dirs[defines.direction.west] or false]

   if not shape then error("No shape match for direction map: " .. serpent.line(dirs)) end

   return shape
end

return mod
