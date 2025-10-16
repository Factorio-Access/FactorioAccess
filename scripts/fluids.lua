--[[
Get data about (but do not announce directly) the fluid states of an entity.

As a brief overview: entities have fluidboxes.  Each fluidbox is a "tank" of one kind of fluid.  Boilers for example
have one for water and one for steam.  Some fluidboxes are connected to the external world, usually via a direct pipe
connection but sometimes via underground connections instead.

One special case is pipes.  These have fluidboxes but we treat them specially, because announcing 4 fluidboxes is
entirely unhelpful.  For that we compute corner shapes and such and provide helpful descriptions.

Old versions of the mod hardcoded much of this.  The trick to not hardcoding it is to know that one needs
get_pipe_connections, and then relative directions to the *box* of the entity they belong to provide what is needed
there. `get_simplified_connections` in this file handles the magic of converting an entity's fluidboxes into tile
coordinates and other info that is useful for announcement and analysis on our side.

What's actually going on: `get_connections` returns the connected fluidboxes if any.  That is, it returns an empty table
for e.g. a lonely pipe. `get_pipe_connections` instead figures out where connections are going, and returns all of them
even if they are not connected right now (that is, it seems to have nothing to do with pipes).  This is however done per
fluidbox, and each fluidbox is one fluid only, so to get the overview for the whole entity one must iterate.

Now for limitations on fluid contents: for that, the API calls it filters and it works like splitter or belt
filters--but for a whole fluidbox, including all connections (for example the two boiler water inputs are one fluidbox
and one filter for that fluidbox).  Storage tanks are an example of an entity with many connections and one un-filtered
fluidbox.

The fluidbox indexing operator itself allows indexing the fluids in a fluidbox. Most of the time it's up to 1.  It's
unclear if or under what circumstances it can be more than 1, but it is probably possible for that to happen.  As of
2024-11-04, it is unclear to us just when that can happen in the new fluid system.

There is a concept of locked fluids.  The API doesn't do a good job of explaining this.  If a fluid is locked, this
means that it is on something that produces or consumes that fluid.  This doesn't happen on pipes or storage tanks, but
it does happen on crafting machines when recipes are set.

Note: the logic for determining pipe shapes (corner, T, cross, etc.) was formerly part of this file, but is now shared
via `network-shape.lua`, and reused by both fluids and heat systems.
]]
local Consts = require("scripts.consts")
local FaUtils = require("scripts.fa-utils")
local NetworkShape = require("scripts.network-shape")
local TH = require("scripts.table-helpers")

local mod = {}

--[[
Definition of a connection point on an entity with computed directions and rounded to tiles.  Provides the computed
information needed to build cursor announcements when the cursor is over an entity, and also returns the raw connections
for code needing more.
]]
---@class fa.Fluids.ConnectionPoint
---@field position fa.Point rounded to the tile
---@field output_direction defines.direction?
---@field input_direction defines.direction?
---@field bidirectional boolean
---@field fluid string? Set if the fluid must be a specific one.
---@field type data.PipeConnectionType
---@field open boolean Closed if it's a crafting machine and the recipe doesn't use it.
---@field distance_in_tiles number Not the same as just checking positions unless it's "normal"
---@field raw PipeConnection

--[[
Given a fluidbox, determine if it must be a specific fluid, using the following rules:

- If a crafting machine recipe is set and it is an input, it must be that input.
- If it has a filter e.g. a pump, that filter.
- If the fluidbox is in a segment and that segment contains one fluid only, it must be that fluid.

Otherwise return nil.  Either there's no requirement or the user has managed to mix fluids.
]]
---@param fluidbox LuaFluidBox
---@param index number
---@return string?
local function get_local_fluidbox_constraint(fluidbox, index)
   local locked = fluidbox.get_locked_fluid(index)
   if locked then return locked end
   local filt = fluidbox.get_filter(index)

   if filt then return filt.name end
   local from_contents
   local contents = fluidbox.get_fluid_segment_contents(index)
   if contents and table_size(contents) == 1 then from_contents = next(contents) end
   return from_contents
end

--[[
Given a fluidbox and index, determine what the fluid must be using the rules of
get_local_fluidbox_constraint, but call it on all immediately adjacent
fluidboxes until one is found.  We don't look further than that. for now.
]]
---@param fluidbox LuaFluidBox
---@param index number
---@return string?
local function get_fluidbox_constraint(fluidbox, index)
   local first_attempt = get_local_fluidbox_constraint(fluidbox, index)
   if first_attempt then return first_attempt end

   -- Otherwise try adjacents.
   for _, c in pairs(fluidbox.get_pipe_connections(index)) do
      if c.target then
         local try = get_local_fluidbox_constraint(c.target, c.target_fluidbox_index)
         if try then return try end
      end
   end
end

---@param ent LuaEntity
---@return fa.Fluids.ConnectionPoint[]
function mod.get_connection_points(ent)
   ---@type fa.Fluids.ConnectionPoint[]
   local res = {}
   local fb = ent.fluidbox

   local is_crafting_machine = Consts.CRAFTING_MACHINES[ent.type]

   local closed_because_no_recipe = is_crafting_machine and ent.get_recipe() == nil

   for i = 1, #fb do
      local conns = fb.get_pipe_connections(i)
      local fluid = get_fluidbox_constraint(fb, i)

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

         local distance_in_tiles = 1

         -- For underground and linked connections, the game does not report the
         -- position of the other side directly and instead yields the position
         -- of the fluidbox in this entity, e.g. c.position==c.target.  We have
         -- to look at the other side indirectly. Careful: if there is no other
         -- side yet, we can't know.
         if c.connection_type ~= "normal" and c.target then
            local other_pos =
               c.target.get_pipe_connections(c.target_fluidbox_index)[c.target_pipe_connection_index].position
            distance_in_tiles = math.ceil(FaUtils.distance(c.position, other_pos))
         end
         local open = true
         if is_crafting_machine then open = not closed_because_no_recipe or fb.get_locked_fluid(i) ~= nil end
         ---@type fa.Fluids.ConnectionPoint
         local part = {
            bidirectional = in_dir ~= nil and out_dir ~= nil,
            position = { x = sx, y = sy },
            raw = c,
            type = c.connection_type,
            fluid = fluid,
            input_direction = in_dir,
            output_direction = out_dir,
            open = open,
            distance_in_tiles = distance_in_tiles,
         }
         table.insert(res, part)
      end
   end

   return res
end

--[[
Given a pipe entity, determine to which pipes it is connected and pass back information on the shape.  This comes back
as two values, a kind and a direction. Shape interpretations are as follows:

- straight: a line of 3 segments and this pipe is the middle. Direction is either north or east, specifying if it is
  vertical or horizontal.
- end: has one connection. Direction is the way the end "points" e.g. 180 from the connection.
- corner: an L formed of 3 pipe segments.  The direction is the corner of the imaginary box which would be formed of 4
  corners.  For example, northwest means connecting south and east, because if you completed the box it'd be the
  northwest corner.
- Cross: direction is returned as north.  Looks like a cross, which is invariant under rotation.
- alone: nothing connects, will just pass back north.
- T: the direction is the top of the T, e.g. the missing one.

This mismatches fa-info.  The trouble is that the above directions make sense for analysis and exposing them directly
would be the least verbose option, but that relies on blind people knowing what a T is, and figuring out what "northwest
corner" means--we'd have to teach it.  We probably do at some point, but that's not now, so fa-info simplifies.

This function considers only pipe entities, and ignores undergrounds. Undergrounds need to be announced separately.
]]
---@param ent LuaEntity
---@return { shape: fa.NetworkShape.Shape, direction: defines.direction }
function mod.get_pipe_shape(ent)
   assert(ent.type == "pipe" or ent.type == "infinity-pipe")
   local fb = ent.fluidbox
   assert(#fb == 1)

   local dirs = {}
   local conns = fb.get_pipe_connections(1)

   for _, conn in pairs(conns) do
      if conn.target and (conn.target.owner.type == "pipe" or conn.target.owner.type == "infinity-pipe") then
         local dx = conn.target_position.x - conn.position.x
         local dy = conn.target_position.y - conn.position.y
         local dir = FaUtils.direction_of_vector({ x = dx, y = dy })
         assert(dir, "Unable to compute direction from vector.")
         dirs[dir] = true
      end
   end

   return NetworkShape.get_shape_from_directions(dirs)
end

---@class Fluids.FluidDescriptor
---@field fluid_name string The localized fluid name
---@field amount number The amount of fluid
---@field direction_type string? One of: "input", "output", "bidirectional", or nil for none
---@field locked boolean Whether the fluidbox is locked to this fluid
---@field empty boolean Whether this is an empty fluidbox
---@field sort_key string For deterministic ordering

---Build fluid descriptors for an entity's GUI
---@param entity LuaEntity
---@return Fluids.FluidDescriptor[]
function mod.build_fluid_descriptors(entity)
   ---@type Fluids.FluidDescriptor[]
   local descriptors = {}

   local fluids_count = entity.fluids_count
   if fluids_count == 0 then return descriptors end

   local fluidbox = entity.fluidbox

   -- For entities with fluidboxes, use fluidbox data exclusively
   if fluidbox and #fluidbox > 0 then
      for i = 1, #fluidbox do
         local prototype = fluidbox.get_prototype(i)
         local locked_fluid = fluidbox.get_locked_fluid(i)
         local fluid_data = fluidbox[i]

         -- Determine the production type
         local production_type = nil
         if prototype then
            -- Handle cases where prototype might be an array (merged prototypes)
            if type(prototype) == "table" and #prototype > 0 then
               -- Multiple prototypes merged, need to combine their production types
               local has_input = false
               local has_output = false
               for _, proto in ipairs(prototype) do
                  if proto.production_type == "input" or proto.production_type == "input-output" then
                     has_input = true
                  end
                  if proto.production_type == "output" or proto.production_type == "input-output" then
                     has_output = true
                  end
               end
               if has_input and has_output then
                  production_type = "bidirectional"
               elseif has_input then
                  production_type = "input"
               elseif has_output then
                  production_type = "output"
               end
            else
               -- Single prototype
               local ptype = prototype.production_type
               if ptype == "input-output" then
                  production_type = "bidirectional"
               elseif ptype == "input" then
                  production_type = "input"
               elseif ptype == "output" then
                  production_type = "output"
               end
            end
         end

         -- Handle empty but locked fluidboxes
         if locked_fluid and not fluid_data then
            ---@type Fluids.FluidDescriptor
            local descriptor = {
               fluid_name = locked_fluid,
               amount = 0,
               direction_type = production_type,
               locked = true,
               empty = true,
               sort_key = string.format("fluidbox-%03d", i),
            }
            table.insert(descriptors, descriptor)
         elseif fluid_data then
            -- Fluidbox has fluid - use amount from fluidbox (already local)
            ---@type Fluids.FluidDescriptor
            local descriptor = {
               fluid_name = fluid_data.name,
               amount = fluid_data.amount,
               direction_type = production_type,
               locked = locked_fluid ~= nil,
               empty = false,
               sort_key = string.format("fluidbox-%03d", i),
            }
            table.insert(descriptors, descriptor)
         end
      end
   else
      -- For entities without fluidboxes, use get_fluid_contents
      local fluid_contents = entity.get_fluid_contents()
      for fluid_name, amount in pairs(fluid_contents) do
         ---@type Fluids.FluidDescriptor
         local descriptor = {
            fluid_name = fluid_name,
            amount = amount,
            direction_type = nil,
            locked = false,
            empty = false,
            sort_key = string.format("fluid-%s", fluid_name),
         }
         table.insert(descriptors, descriptor)
      end
   end

   -- Sort by sort_key for deterministic ordering
   table.sort(descriptors, function(a, b)
      return a.sort_key < b.sort_key
   end)

   return descriptors
end

return mod
