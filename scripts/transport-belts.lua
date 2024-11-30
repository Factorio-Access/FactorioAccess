--[[
See devdocs/belts.md.  Seriously, read that first: the belt APIs don't work how
they look like they should, in a few different ways.

IMPORTANT IMPORTANT IMPORTANT: if you update how belts work and don't update
that file then no one will be able to maintain this. As of 2024-11-09, the only
docs anywhere on how the belt API works (as far as we know anyway) are in that
file.  Not just for this mod, for all mods.  This already had to be rewritten
once in part due to lost knowledge.
]]

local util = require("util")

local Consts = require("scripts.consts")
local F = require("scripts.field-ref")
local FaUtils = require("scripts.fa-utils")
local Geometry = require("scripts.geometry")
local localising = require("scripts.localising")
local TH = require("scripts.table-helpers")

local mod = {}

-- Count the number of non-nil arguments, up to 3.  Useful because we can use it
-- to classify if a belt has one parent: count3(back, left, right) == 1.
local function count3(a, b, c)
   return (a and 1 or 0) + (b and 1 or 0) + (c and 1 or 0)
end

--[[
Return, as up to 3 values, the parents of a belt connectable.  The 3 values so
returned are behind, left, right.  The relevant return values will be nil.  For
example nil, belt, belt is valid at a merging.  The rules are as follows:

WARNING: these may be ghosts.

- For underground belt exits behind is the entrance and left/right are
  sideloads.
- For underground belt entrances behind is the incoming belt and left/right are
  sideloads.
- For splitters behind is always nil and left/right are set.
- Loaders: todo.

As with scanner, the odd interface here is about tables: returning the values
directly avoids creating and immediately destroying intermediates.
]]
---@param connectable LuaEntity
---@return LuaEntity?, LuaEntity?, LuaEntity?
local function get_parents(connectable)
   local outgoing_dir = connectable.direction

   if connectable.type == "splitter" then
      -- Splitters have to be geometry.  This is because it turns out that the
      -- line-based API doesn't handle mixed belts right at splitters, and the
      -- non-line-based one doesn't handle empty inputs.  To do it, instead get
      -- the up to 2 inputs, then use some geometry: the dot product of a vector
      -- perpendicular to the splitter's facing direction can be used to know if
      -- something is above or below the axis defined by the splitter's facing
      -- direction.
      local inputs = connectable.belt_neighbours.inputs
      if not next(inputs) then return nil, nil, nil end

      -- l is always non-nil, but it may not really be the left; we swap these
      -- if needed below.
      local l, r = inputs[1], inputs[2]
      local ccw_90_dir = Geometry.dir_counterclockwise_90(outgoing_dir)
      local uv_x, uv_y = uv_for_direction(ccw_90_dir)
      local splitter_pos = connectable.position
      local maybe_left_pos = l.position
      local rel_x, rel_y = splitter_pos.x - maybe_left_pos.x, splitter_pos.y - maybe_left_pos.y
      local dot = Geometry.dot_unrolled_2d(uv_x, uv_y, rel_x, rel_y)
      -- Suppose splitter faces east.  Suppose that the left exists, that is l
      -- is correct.  Then the above gave a vector pointing north (90
      -- counterclockwise of east) and a vector pointing southeast (from the
      -- possibly-left belt to the splitter). This would be a negative dot
      -- product.  Recall that dot products are invariant under rotation: the
      -- directionhs of the specific things involved doesn't matter.
      if dot > 0 then
         l, r = r, l
      end
      return nil, l, r
   end

   local behind, sl, sr

   -- For transport belts or either underground, we have a behind and optionally
   -- two sideloads; we correct behind for underground belt exits below.
   if connectable.type == "transport-belt" or connectable.type == "underground-belt" then
      local neighbours = connectable.belt_neighbours
      local inputs = neighbours.inputs

      -- In the common case, we do not need to worry about figuring out
      -- sideloads, as that is an expensive operation.
      if #inputs == 1 and inputs[1].direction == outgoing_dir then return inputs[1], nil, nil end

      local incoming_dir = connectable.direction

      if connectable.type == "transport-belt" then
         if connectable.belt_shape == "left" then
            incoming_dir = Geometry.dir_clockwise_90(incoming_dir)
         elseif connectable.belt_shape == "right" then
            incoming_dir = Geometry.dir_counterclockwise_90(incoming_dir)
         end
      end

      -- Has (up to) 3 parents.  We figure out which parent is which by
      -- examining the directions of the input.  This is counterclockwise 90
      -- then  rotate 180 for the direction the left sideload should be, which
      -- is equal to clockwise 90, and likewise for the right sideload: these
      -- aren't backward.
      local incoming_left = Geometry.dir_clockwise_90(incoming_dir)
      local incoming_right = Geometry.dir_counterclockwise_90(incoming_dir)

      local len = #inputs
      assert(len <= 3)
      for i = 1, len do
         local belt = inputs[i]
         if belt.direction == incoming_dir then
            behind = belt
         elseif belt.direction == incoming_left then
            sl = belt
         elseif belt.direction == incoming_right then
            sr = belt
         else
            error(
               string.format("Could not figure out what to do with %s: faces %i", serpent.line(belt), belt.direction)
            )
         end
      end
   end

   if connectable.type == "underground-belt" and connectable.belt_to_ground_type == "output" then
      behind = connectable.neighbours
   end

   return behind, sl, sr
end

-- Exported so that /fac can see it. Useful for testing.
mod.get_parents = get_parents

---@param connectable LuaEntity
---@return LuaEntity[]
local function get_children(connectable)
   local neighbours = connectable.belt_neighbours.outputs
   if
      connectable.type == "underground-belt"
      and connectable.belt_to_ground_type == "input"
      and connectable.neighbours
   then
      table.insert(neighbours, connectable.neighbours)
   end
   return neighbours
end

---@class fa.TransportBelts.Node
---@field entity LuaEntity
local Node = {}
local Node_meta = { __index = Node }
mod.Node = Node
if script then script.register_metatable("fa.TransportBelts.Node", Node_meta) end

---@param entity LuaEntity
function Node.create(entity)
   return setmetatable({ entity = entity }, Node_meta)
end

---@return boolean
function Node:valid()
   return self.entity.valid
end

function Node:_assert_valid()
   assert(self:valid())
end

-- Is this a connectable with no children/outputs?
---@return boolean
function Node:is_belt_end()
   self:_assert_valid()

   return not next(self.entity.belt_neighbours.outputs)
end

-- Is this a connectable with no parents?
---@return boolean
function Node:is_belt_start()
   self:_assert_valid()

   return not next(self.entity.belt_neighbours.inputs)
end

---@enum fa.TransportBelts.CornerKind
mod.CORNER_KINDS = {
   LEFT = "left",
   RIGHT = "right",
}

--[[
Describe the shape of a belt.  The relevant fields are non-nil (so e.g. a
splitter never has sideloads or a corner kind).  See belts.md for the specific
rules.
]]
---@class fa.TransportBelts.ShapeInfo
---@field has_input boolean
---@field has_output boolean
---@field left_sideload LuaEntity?
---@field right_sideload LuaEntity?
---@field merge boolean
---@field corner fa.TransportBelts.CornerKind?
---@field is_pouring boolean

-- WARNING: this is very expensive. Fine to call a few times per tick but not in
-- tight loops.  Some belt shape properties require materializing both parents
-- and children and doing algos on them.
---@return fa.TransportBelts.ShapeInfo
function Node:get_shape_info()
   self:_assert_valid()
   local e = self.entity

   ---@type fa.TransportBelts.ShapeInfo
   local ret = {
      has_input = false,
      has_output = false,
      is_pouring = false,
      corner = nil,
      left_sideload = nil,
      right_sideload = nil,
      merge = false,
   }

   local behind, left, right = get_parents(e)
   ret.left_sideload = left
   ret.right_sideload = right

   ret.has_input = count3(behind, left, right) > 0
   local children = get_children(e)
   ret.has_output = #children > 0

   -- Work out pouring.
   if e.type == "transport-belt" and e.belt_shape == "straight" and ret.has_output then
      assert(#children == 1)

      -- If the next thing is a transport belt and it is a corner then it is
      -- outputting 90 degrees off based on which way it goes, and we must
      -- account for that.  What we want is the direction of the input.  These
      -- aren't backwards if you visualize it.  A left turn's input is 90
      -- degrees to the clockwise because going left offset it 90 degrees
      -- counterclockwise, and that's what we want to undo.
      local child = children[1]
      local child_dir = child.direction
      if child.type == "transport-belt" then
         if child.belt_shape == "left" then
            child_dir = Geometry.dir_clockwise_90(child_dir)
         elseif child.belt_shape == "right" then
            child_dir = Geometry.dir_counterclockwise_90(child_dir)
         end
      end

      ret.is_pouring = e.direction ~= child_dir
   end

   -- Translate corners to the enum.
   if e.type == "transport-belt" then
      if e.belt_shape == "left" then
         ret.corner = mod.CORNER_KINDS.LEFT
      elseif e.belt_shape == "right" then
         ret.corner = mod.CORNER_KINDS.RIGHT
      end
   end

   ret.merge = e.type == "transport-belt" and ret.left_sideload ~= nil and ret.right_sideload ~= nil and not behind

   return ret
end

--[[
OK fun time.  The game doesn't document this well but the linear length of a
line is the length in tiles.  No case of a transport line exists which doesn't
however put 0.25 between entities, and it's not possible to change this in mods,
only to change the speed.  But, in some cases, things will not be on that
boundary in particular at inserters and drills.  To deal with that we will round
down.

That means that in rare cases we can probably bucket such that there are two
item kinds in a slot, but observing one in practice is almost impossibly
difficult.

The items table is prototype->quality->count.
]]
---@class fa.TransportBelts.SlotBucket
---@field items table<string, table<string, number>>

-- Get the contents of a lane, accounting for stack sizes.
---@param line defines.transport_line
---@return  fa.TransportBelts.SlotBucket[]
function Node:get_line_contents(line)
   self:_assert_valid()
   local line = self.entity.get_transport_line(line --[[@as number]])

   local buckets = {}

   for _ = 1, line.line_length * 4 do
      table.insert(buckets, {
         items = {},
      })
   end

   for _, details in pairs(line.get_detailed_contents()) do
      local slot = math.floor(details.position * 4) + 1
      local b = buckets[slot]

      local ds = details.stack
      local n, q = ds.name, ds.quality.name

      b.items[n] = b.items[n] or {}
      b.items[n][q] = (b.items[n][q] or 0) + ds.count
   end

   return buckets
end

--[[
Return two sets of lane contents, one for the "left" and the "right".  On a
splitter, this is best effort.
]]
---@return fa.TransportBelts.SlotBucket[][]
function Node:get_all_contents()
   self:_assert_valid()

   local e = self.entity
   local t = e.type

   -- For transport belts, loaders, and outgoing underground belts, it's simply
   -- the first two lines.  Underground belts do not seem to use the other two
   -- lines on the output.
   if t == "transport-belt" or t == "loader" or (t == "underground-belt" and e.belt_to_ground_type == "output") then
      local left = self:get_line_contents(defines.transport_line.left_line)
      local right = self:get_line_contents(defines.transport_line.right_line)
      return { left, right }
   elseif t == "underground-belt" then
      -- Underground inputs are two lines smashed together: the first line is
      -- 0.5 long and covers the half of the first tile which is above ground,
      -- the other is however many tiles are underground.
      local left_above = self:get_line_contents(defines.transport_line.left_line)
      local right_above = self:get_line_contents(defines.transport_line.right_line)
      local left_underground = self:get_line_contents(defines.transport_line.left_underground_line)
      local right_underground = self:get_line_contents(defines.transport_line.right_underground_line)
      TH.concat_arrays(left_above, left_underground)
      TH.concat_arrays(right_above, right_underground)
      return { left_above, right_above }
   elseif t == "splitter" then
      -- Splitters are tricky.  It seems that what we have here is 1 3 5 7 are
      -- left, 2 4 6 8 are right.  That's not necessarily correct.  What we
      -- definitely don't have is a good perfect geometry interpretation:
      -- splitters seem to change what's what in terms of inputs and outputs.
      -- Because looking at a splitter's internals is not a very useful
      -- operation, we just do our best.
      local left = {}
      local right = {}
      for i = 1, 8, 2 do
         TH.concat_arrays(left, self:get_line_contents(i --[[@as defines.transport_line]]))
      end

      for i = 2, 8, 2 do
         TH.concat_arrays(right, self:get_line_contents(i --[[@as defines.transport_line]]))
      end

      return { left, right }
   end

   error(string.format("Should be unreachable as this should be a belt connectable, but it is a %s", t))

   return ret
end

-- If this node has exactly one parent, return that entity.
--
-- Single parents are special.  No matter what the current item is, a single
-- parent means that the current item must carry what the parent carries.
function Node:get_single_parent()
   self:_assert_valid()

   local b, l, r = get_parents(self.entity)
   local count = count3(b, l, r)
   if count == 1 then return b or l or r end
   return nil
end

-- Is the given transport line full?
---@param line defines.transport_line
function Node:is_line_full(line)
   self:_assert_valid()
   local line = self.entity.get_transport_line(line --[[@as number]])
   local expected = line.line_length * 4
   return #line == expected
end

---@return boolean
function Node:is_left_full()
   return self:is_line_full(defines.transport_line.left_line)
end

---@return boolean
function Node:is_right_full()
   return self:is_line_full(defines.transport_line.right_line)
end

-- Is every line in this connectable entity full?
---@return boolean
function Node:is_all_full()
   for i = 1, #self.entity.get_max_transport_line_index() do
      local line = self.entity.get_transport_line(i)
      local expected = line.line_length * 4
      if expected ~= #line then return false end
   end

   return true
end

---@class fa.TransportBelts.Heuristic
---@field distance number Negative for behind, 0 for "here", positive ahead.
---@field results table<string, table<string, number>> item->quality->count

-- Walk this node's parents until either a ghost or a connectable with more than
-- one parent is found.  Stop if the passed callback returns false or if a loop
-- is detected.
---@param callback fun(LuaEntity, number): boolean second arg is number of steps so far, starts at 1.
function Node:walk_single_parents(callback)
   self:_assert_valid()

   local e = self.entity
   local depth = 1
   local seen = {}

   if e.type == "entity-ghost" then return end
   seen[e.unit_number] = true

   while true do
      local b, l, r = get_parents(e)
      if count3(b, l, r) ~= 1 then return end

      -- Makes stylua happy (because it will otherwise clobber this function)
      -- and LuaLS happy (because it thinks that p is nil).
      do
         local p = b or l or r
         assert(p)
         e = p
      end
      if e.type == "entity-ghost" then return end
      if seen[e.unit_number] then return end
      seen[e.unit_number] = true

      if not callback(e, depth) then return end
      depth = depth + 1
   end
end

-- Exactly the same as walk_single_parent but for single children.
---@param callback fun(LuaEntity, number): boolean second arg is number of steps so far, starts at 1.
function Node:walk_single_child(callback)
   self:_assert_valid()

   local e = self.entity
   local depth = 1
   local seen = {}

   if e.type == "entity-ghost" then return end
   seen[e.unit_number] = true

   while true do
      local children = get_children(e)
      if #children ~= 1 then return end
      e = children[1]

      if e.type == "entity-ghost" then return end
      if seen[e.unit_number] then return end
      seen[e.unit_number] = true

      if not callback(e, depth) then return end
      depth = depth + 1
   end
end

-- Run the heuristic to determine what a belt might be carrying, and return a
--prototype->quality->count table.  See devdocs/belts.md
---@param line_index defines.transport_line
---@param depth_limit number
---@return fa.TransportBelts.Heuristic
function Node:carries_heuristic(line_index, depth_limit)
   -- To start, we will go upstream until we find a lane with some contents or hit max depth.
   local contents
   local distance = 0

   local function handler(cur_parent, cur_depth, negate)
      if cur_depth > depth_limit then return false end

      local line, empty

      -- skip splitters, which have very complex internal contents.
      if cur_parent.type == "splitter" then return true end

      line = cur_parent.get_transport_line(line_index --[[@as number]])
      empty = #line == 0
      if not empty then
         contents = line.get_detailed_contents()
         distance = negate and -cur_depth or cur_depth
         return false
      end

      return true
   end

   handler(self.entity, 0, false)

   if not contents then self:walk_single_parents(function(e, d)
      return handler(e, d, true)
   end) end

   if not contents then
      -- Now do the same thing, but downstream.  As with upstream, stop if we
      -- find more than one child.
      self:walk_single_child(function(e, d)
         return handler(e, d, false)
      end)
   end

   ---@type fa.TransportBelts.Heuristic
   local result = {
      distance = distance,
      results = {},
   }

   if contents then
      result.results = TH.rollup2(contents, F.stack.name().get, F.stack.quality.name().get, F.stack.count().get)
   end

   return result
end

--Transport belt analyzer: Read a results list slot
function mod.read_belt_slot(pindex, start_phrase)
   return "unimplemented for 2.0"
end

--Set the input priority or the output priority or filter for a splitter
function mod.set_splitter_priority(splitter, is_input, is_left, filter_item_stack, clear)
   local clear = clear or false
   local result = "no message"
   local filter = splitter.splitter_filter

   if clear then
      splitter.splitter_filter = nil
      filter = splitter.splitter_filter
      result = "Cleared splitter filter"
      splitter.splitter_output_priority = "none"
   elseif filter_item_stack ~= nil and filter_item_stack.valid_for_read then
      splitter.splitter_filter = filter_item_stack.prototype
      filter = splitter.splitter_filter
      result = "filter set to " .. filter_item_stack.name
      if splitter.splitter_output_priority == "none" then
         splitter.splitter_output_priority = "left"
         result = result .. ", from the left"
      end
   elseif is_input and is_left then
      if splitter.splitter_input_priority == "left" then
         splitter.splitter_input_priority = "none"
         result = "equal input priority"
      else
         splitter.splitter_input_priority = "left"
         result = "left input priority"
      end
   elseif is_input and not is_left then
      if splitter.splitter_input_priority == "right" then
         splitter.splitter_input_priority = "none"
         result = "equal input priority"
      else
         splitter.splitter_input_priority = "right"
         result = "right input priority"
      end
   elseif not is_input and is_left then
      if splitter.splitter_output_priority == "left" then
         if filter == nil then
            splitter.splitter_output_priority = "none"
            result = "equal output priority"
         else
            result = "left filter output"
         end
      else
         if filter == nil then
            splitter.splitter_output_priority = "left"
            result = "left output priority"
         else
            splitter.splitter_output_priority = "left"
            result = "left filter output"
         end
      end
   elseif not is_input and not is_left then
      if splitter.splitter_output_priority == "right" then
         if filter == nil then
            splitter.splitter_output_priority = "none"
            result = "equal output priority"
         else
            result = "right filter output"
         end
      else
         if filter == nil then
            splitter.splitter_output_priority = "right"
            result = "right output priority"
         else
            splitter.splitter_output_priority = "right"
            result = "right filter output"
         end
      end
   else
      result = "Splitter config error"
   end

   return result
end

--Returns an info string about a splitter's input and output settings.
function mod.splitter_priority_info(ent)
   local result = ","
   local input = ent.splitter_input_priority
   local output = ent.splitter_output_priority
   local filter = ent.splitter_filter
   if input == "none" then
      result = result .. " input balanced, "
   elseif input == "right" then
      result = result
         .. " input priority "
         .. "right"
         .. " which is "
         .. FaUtils.direction_lookup(FaUtils.rotate_90(ent.direction))
         .. ", "
   elseif input == "left" then
      result = result
         .. " input priority "
         .. "left"
         .. " which is "
         .. FaUtils.direction_lookup(FaUtils.rotate_270(ent.direction))
         .. ", "
   end
   if filter == nil then
      if output == "none" then
         result = result .. " output balanced, "
      elseif output == "right" then
         result = result
            .. " output priority "
            .. "right"
            .. " which is "
            .. FaUtils.direction_lookup(FaUtils.rotate_90(ent.direction))
            .. ", "
      elseif output == "left" then
         result = result
            .. " output priority "
            .. "left"
            .. " which is "
            .. FaUtils.direction_lookup(FaUtils.rotate_270(ent.direction))
            .. ", "
      end
   else
      local item_name = localising.get(filter, pindex)
      if item_name == nil or item_name == "" then item_name = "unknown item" end
      if output == "right" then
         result = result
            .. " output filtering "
            .. item_name
            .. " towards the "
            .. "right"
            .. " which is "
            .. FaUtils.direction_lookup(FaUtils.rotate_90(ent.direction))
            .. ", "
      elseif output == "left" then
         result = result
            .. " output filtering "
            .. item_name
            .. " towards the "
            .. "left"
            .. " which is "
            .. FaUtils.direction_lookup(FaUtils.rotate_270(ent.direction))
            .. ", "
      end
   end
   return result
end

return mod
