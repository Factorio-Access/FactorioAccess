--[[
Get data about (but do not announce directly) the fluid states of an entity.

As a brief overview: entities have fluidboxes.  Each fluidbox is a "tank" of one
kind of fluid.  Boilers for example have one for water and one for steam.  Some
fluidboxes are connected to the external world, usually via a direct pipe
connection but sometimes via underground connections instead.

One special case is pipes.  These have fluidboxes but we treat them specially,
because announcing 4 fluidboxes is entirely unhelpful.  For that we compute
corner shapes and such and provide helpful descriptions.

Old versions of the mod hardcoded much of this.  The trick to not hardcoding it
is to know that one needs get_pipe_connections, and then relative directions to
the *box* of the entity they belong to provide what is needed there.
`get_simplified_connections` in this file handles the magic of converting an
entity's fluidboxes into tile coordinates and other info that is useful for
announcement and analysis on our side.

What's actually going on: `get_connections` returns the connected fluidboxes if
any.  That is, it returns an empty table for e.g. a lonely pipe.
`get_pipe_connections` instead figures out where connections are going, and
returns all of them even if they are not connected right now (that is, it seems
to have nothing to do with pipes).  This is however done per fluidbox, and each
fluidbox is one fluid only, so to get the overview for the whole entity one must
iterate.

Now for limitations on fluid contents: for that, the API calls it filters and it
works like splitter or belt filters--but for a whole fluidbox, including all
connections (for example the two boiler water inputs are one fluidbox and one
filter for that fluidbox).  Storage tanks are an example of an entity with many
connections and one un-filtered fluidbox.

The fluidbox indexing operator itself allows indexing the fluids in a fluidbox.
Most of the time it's up to 1.  It's unclear if or under what circumstances it
can be more than 1, but it is probably possible for that to happen.  As of
2024-11-04, it is unclear to us just when that can happen in the new fluid
system.

Note that the shape computation logic is reused by heat.  Heat isn't a fluid and
has a number of "interesting" special cases, but the corner shapes are the same.
]]
local FaUtils = require("scripts.fa-utils")
local TH = require("scripts.table-helpers")

local mod = {}

--[[
Definition of a connection point on an entity with computed directions and
rounded to tiles.  Provides the computed information needed to build cursor
announcements when the cursor is over an entity, and also returns the raw
connections for code needing more.
]]
---@class fa.Fluids.ConnectionPoint
---@field position fa.Point rounded to the tile
---@field output_direction defines.direction?
---@field input_direction defines.direction?
---@field bidirectional boolean
---@field fluid string? Set if the fluid must be a specific one.
---@field type data.PipeConnectionType
---@field raw PipeConnection

---@param ent LuaEntity
---@return fa.Fluids.ConnectionPoint[]
function mod.get_connection_points(ent)
   ---@type fa.Fluids.ConnectionPoint[]
   local res = {}
   local fb = ent.fluidbox

   for i = 1, #fb do
      local conns = fb.get_pipe_connections(i)
      local filt = fb.get_filter(i)
      local filt_name
      if filt then filt_name = filt.name end

      for j = 1, #conns do
         local c = conns[j]
         local sx = math.floor(c.position.x) + 0.5
         local sy = math.floor(c.position.y) + 0.5
         local tx = math.floor(c.target_position.x) + 0.5
         local ty = math.floor(c.target_position.y) + 0.5
         local out_dir
         local in_dir
         if c.flow_direction == "input" then
            in_dir = FaUtils.rotate_180(FaUtils.direction_of_vector({ x = tx - sx, y = ty - sy }))
         elseif c.flow_direction == "output" then
            out_dir = FaUtils.direction_of_vector({ x = tx - sx, y = ty - sy })
         elseif c.flow_direction == "input-output" then
            out_dir = FaUtils.direction_of_vector({ x = tx - sx, y = ty - sy })
            in_dir = FaUtils.rotate_180(out_dir)
         end

         ---@type fa.Fluids.ConnectionPoint
         local part = {
            bidirectional = in_dir ~= nil and out_dir ~= nil,
            position = { x = sx, y = sy },
            raw = c,
            type = c.connection_type,
            fluid = filt_name,
            input_direction = in_dir,
            output_direction = out_dir,
         }
         table.insert(res, part)
      end
   end

   return res
end

---@enum fa.Fluids.PipeShape
mod.PIPE_SHAPE = {
   STRAIT = "straight",

   -- 4-way, a cross
   CROSS = "cross",
   CORNER = "corner",

   END = "end",

   -- It's not connecting to anything.
   ALONE = "alone",

   T = "t",
}

---@alias fa.fluids.ShapeDef { shape: fa.Fluids.PipeShape, direction: defines.direction }

-- north->east->south->west->shape, true if the direction is present, false if
-- it is not. Used below.
---@type table<boolean, table<boolean, table<boolean, table<boolean, fa.fluids.ShapeDef>>>>
local SHAPE_TABLE = {}

local function add_shape(n, e, s, w, shape, direction)
   SHAPE_TABLE[n] = SHAPE_TABLE[n] or {}
   SHAPE_TABLE[n][e] = SHAPE_TABLE[n][e] or {}
   SHAPE_TABLE[n][e][s] = SHAPE_TABLE[n][e][s] or {}
   SHAPE_TABLE[n][e][s][w] = { shape = shape, direction = direction }
end

add_shape(true, true, true, true, mod.PIPE_SHAPE.CROSS, defines.direction.north)
add_shape(true, false, true, false, mod.PIPE_SHAPE.STRAIT, defines.direction.north)
add_shape(false, true, false, true, mod.PIPE_SHAPE.STRAIT, defines.direction.east)
add_shape(true, true, false, false, mod.PIPE_SHAPE.CORNER, defines.direction.southwest)
add_shape(false, true, true, false, mod.PIPE_SHAPE.CORNER, defines.direction.northwest)
add_shape(false, false, true, true, mod.PIPE_SHAPE.CORNER, defines.direction.northeast)
add_shape(true, false, false, true, mod.PIPE_SHAPE.CORNER, defines.direction.southeast)
add_shape(true, false, false, false, mod.PIPE_SHAPE.END, defines.direction.north)
add_shape(false, true, false, false, mod.PIPE_SHAPE.END, defines.direction.east)
add_shape(false, false, true, false, mod.PIPE_SHAPE.END, defines.direction.south)
add_shape(false, false, false, true, mod.PIPE_SHAPE.END, defines.direction.west)
add_shape(true, true, true, false, mod.PIPE_SHAPE.T, defines.direction.west)
add_shape(true, true, false, true, mod.PIPE_SHAPE.T, defines.direction.south)
add_shape(true, false, true, true, mod.PIPE_SHAPE.T, defines.direction.east)
add_shape(false, true, true, true, mod.PIPE_SHAPE.T, defines.direction.north)
add_shape(false, false, false, false, mod.PIPE_SHAPE.ALONE, defines.direction.north)

--[[
Given a pipe entity, determine to which pipes it is connected and pass back
information on the shape.  This comes back as two values, a kind and a
direction. Shape interpretations are as follows:

- straight: a line of 3 segments and this pipe is the middle. Direction is
  either north or east, specifying if it is vertical or horizontal.
- end: has one connection. Direction is the way the end "points" e.g. 180 from
  the connection.
- corner: an L formed of 3 pipe segments.  The direction is the corner of the
  imaginary box which would be formed of 4 corners.  FOr example, northwest
  means connecting south and east, because if you completed the box it'd be the
  northwest corner.
- Cross: direction is returned as north.  Looks like a cross, which is invariant
  under rotation.
- alone: nothing connects, will just pass back north.
- T: the direction is the top of the T, e.g. the missing one.

This mismatches fa-info.  The trouble is that the above directions make sense
for analysis and exposing them directly woiuld be the least verbose option, but
that relies on blind people knowing what a T is, and figuring out what
"northwest corner" means--we'd have to teach it.  We probably do at some point,
but that's not now, so fa-info simplifies.

This function considers only pipe entities, and ignores undergrounds.
Undergrounds need to be announced separately.
]]
---@param ent LuaEntity
---@return { shape: fa.Fluids.PipeShape, direction: defines.direction }
function mod.get_pipe_shape(ent)
   local dirs = {}

   assert(ent.type == "pipe")
   local fb = ent.fluidbox
   assert(#fb == 1)

   local conns = fb.get_pipe_connections(1)
   for _, conn in pairs(conns) do
      if conn.target and conn.target.owner.type == "pipe" then
         local v = { x = conn.target_position.x - conn.position.x, y = conn.target_position.y - conn.position.y }
         local dir = FaUtils.direction_of_vector(v)
         assert(dir)
         dirs[dir] = true
      end
   end

   local shape =
      SHAPE_TABLE[dirs[defines.direction.north] ~= nil][dirs[defines.direction.east] ~= nil][dirs[defines.direction.south] ~= nil][dirs[defines.direction.west] ~= nil]
   if not shape then error(string.format("No shape for %s", serpent.line(dirs))) end

   -- Don't let callers modify what is otherwise a constant.
   return table.deepcopy(shape)
end

return mod
