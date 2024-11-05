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
---@class fa.fluids.ConnectionPoint
---@field position fa.Point rounded to the tile
---@field output_direction defines.direction?
---@field input_direction defines.direction?
---@field bidirectional boolean
---@field fluid string? Set if the fluid must be a specific one.
---@field type data.PipeConnectionType
---@field raw PipeConnection

---@param ent LuaEntity
---@return fa.fluids.ConnectionPoint[]
function mod.get_connection_points(ent)
   ---@type fa.fluids.ConnectionPoint[]
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

         ---@type fa.fluids.ConnectionPoint
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

return mod
