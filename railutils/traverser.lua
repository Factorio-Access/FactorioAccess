---Rail Traverser
---
---A speculation tool for navigating rails as if driving a train.
---Maintains internal state of current rail and end, allowing simulation of rail movement
---without actually placing rails or querying the game surface.

require("polyfill")

local RailData = require("railutils.rail-data")
local RailInfo = require("railutils.rail-info")
local Queries = require("railutils.queries")

local mod = {}

---Signal side enum
---@enum railutils.SignalSide
mod.SignalSide = {
   LEFT = "left", -- Incoming signal (in_signal)
   RIGHT = "right", -- Outgoing signal (out_signal)
}

---Rail traverser for simulating train movement
---@class railutils.Traverser
---@field _rail_type railutils.RailType Current rail type
---@field _placement_direction defines.direction Direction the rail was placed
---@field _position fa.Point Current position (grid-adjusted)
---@field _end_direction defines.direction Which end we're currently at
local Traverser = {}
local Traverser_meta = { __index = Traverser }

---Create a new traverser
---@param rail_type railutils.RailType Initial rail type
---@param position fa.Point Initial position (should already be grid-adjusted if binding to a real rail)
---@param end_direction defines.direction Which end to bind to
---@return railutils.Traverser
function mod.new(rail_type, position, end_direction)
   -- Validate that the arguments match exact values in the rail data table
   local prototype = Queries.rail_type_to_prototype_type(rail_type)
   local rail_entry = RailData[prototype]
   if not rail_entry then
      error(string.format("Invalid rail_type: %s (prototype: %s)", tostring(rail_type), tostring(prototype)))
   end

   -- Find the placement direction that has this end_direction
   local placement_direction = nil
   for dir, dir_entry in pairs(rail_entry) do
      if dir_entry[end_direction] then
         placement_direction = dir
         break
      end
   end

   if not placement_direction then
      error(
         string.format(
            "No placement_direction found with end_direction %d for rail_type %s (prototype: %s)",
            end_direction,
            tostring(rail_type),
            prototype
         )
      )
   end

   return setmetatable({
      _rail_type = rail_type,
      _placement_direction = placement_direction,
      _position = position,
      _end_direction = end_direction,
   }, Traverser_meta)
end

---Get extension in a specific direction offset
---@param direction_offset number 0=forward, 1=right, -1=left
---@return railutils.ExtensionPoint
function Traverser:_get_extension(direction_offset)
   -- Calculate goal direction (wrapping around 16-way compass)
   local goal_direction = (self._end_direction + direction_offset) % 16

   -- Get all extensions at current position
   -- Note: In real usage, we're not querying a surface, we're using the static table
   -- But get_extension_points_at_position works off rail data, so we need to simulate
   -- Actually, let me just look up directly in the rail data
   local prototype = Queries.rail_type_to_prototype_type(self._rail_type)
   local rail_entry = RailData[prototype]
   if not rail_entry then error("Invalid rail type in traverser state") end

   local direction_entry = rail_entry[self._placement_direction]
   if not direction_entry then error("Invalid placement direction in traverser state") end

   local end_data = direction_entry[self._end_direction]
   if not end_data or not end_data.extensions then error("Invalid end direction in traverser state") end

   local extension = end_data.extensions[goal_direction]
   if not extension then
      error(
         string.format(
            "No extension found for offset %d (goal_direction=%d) from end_direction=%d",
            direction_offset,
            goal_direction,
            self._end_direction
         )
      )
   end

   -- Convert to absolute positions
   return {
      next_rail_prototype = extension.prototype,
      next_rail_position = {
         x = self._position.x + extension.position.x,
         y = self._position.y + extension.position.y,
      },
      next_rail_direction = extension.direction,
      next_rail_goal_direction = extension.goal_direction,
   }
end

---Move forward (continue in same direction)
function Traverser:move_forward()
   local ext = self:_get_extension(0)

   self._rail_type = Queries.prototype_type_to_rail_type(ext.next_rail_prototype)
   self._placement_direction = ext.next_rail_direction
   self._position = ext.next_rail_position
   self._end_direction = ext.next_rail_goal_direction
end

---Turn left (direction - 1)
function Traverser:move_left()
   local ext = self:_get_extension(-1)

   self._rail_type = Queries.prototype_type_to_rail_type(ext.next_rail_prototype)
   self._placement_direction = ext.next_rail_direction
   self._position = ext.next_rail_position
   self._end_direction = ext.next_rail_goal_direction
end

---Turn right (direction + 1)
function Traverser:move_right()
   local ext = self:_get_extension(1)

   self._rail_type = Queries.prototype_type_to_rail_type(ext.next_rail_prototype)
   self._placement_direction = ext.next_rail_direction
   self._position = ext.next_rail_position
   self._end_direction = ext.next_rail_goal_direction
end

---Flip to the opposite end of the current rail
function Traverser:flip_ends()
   local end_dirs = Queries.get_end_directions(self._rail_type, self._placement_direction)

   -- Find the other end (the one that isn't current)
   local other_end = nil
   for _, dir in ipairs(end_dirs) do
      if dir ~= self._end_direction then
         other_end = dir
         break
      end
   end

   if not other_end then error("Could not find opposite end of rail") end

   self._end_direction = other_end
end

---Get current end direction
---@return defines.direction
function Traverser:get_direction()
   return self._end_direction
end

---Get current rail type
---@return railutils.RailType
function Traverser:get_rail_kind()
   return self._rail_type
end

---Get current placement direction
---@return defines.direction
function Traverser:get_placement_direction()
   return self._placement_direction
end

---Get current position
---@return fa.Point
function Traverser:get_position()
   return { x = self._position.x, y = self._position.y }
end

---Get signal position on a specific side
---@param side railutils.SignalSide LEFT or RIGHT
---@return fa.Point Absolute signal position
function Traverser:get_signal_pos(side)
   local prototype = Queries.rail_type_to_prototype_type(self._rail_type)
   local rail_entry = RailData[prototype]
   if not rail_entry then error("Invalid rail type in traverser state") end

   local direction_entry = rail_entry[self._placement_direction]
   if not direction_entry then error("Invalid placement direction in traverser state") end

   local end_data = direction_entry[self._end_direction]
   if not end_data or not end_data.signal_locations then error("No signal locations for current end") end

   local signal_data
   if side == mod.SignalSide.LEFT then
      signal_data = end_data.signal_locations.in_signal
   elseif side == mod.SignalSide.RIGHT then
      signal_data = end_data.signal_locations.out_signal
   else
      error("Invalid signal side: " .. tostring(side))
   end

   if not signal_data then error("No signal found for side: " .. tostring(side)) end

   -- Return absolute position
   return {
      x = self._position.x + signal_data.position.x,
      y = self._position.y + signal_data.position.y,
   }
end

---Get alternative signal position on a specific side
---@param side railutils.SignalSide LEFT or RIGHT
---@return fa.Point|nil Absolute signal position, or nil if no alt signal
function Traverser:get_alt_signal_pos(side)
   local prototype = Queries.rail_type_to_prototype_type(self._rail_type)
   local rail_entry = RailData[prototype]
   if not rail_entry then error("Invalid rail type in traverser state") end

   local direction_entry = rail_entry[self._placement_direction]
   if not direction_entry then error("Invalid placement direction in traverser state") end

   local end_data = direction_entry[self._end_direction]
   if not end_data or not end_data.signal_locations then return nil end

   local signal_data
   if side == mod.SignalSide.LEFT then
      signal_data = end_data.signal_locations.alt_in_signal
   elseif side == mod.SignalSide.RIGHT then
      signal_data = end_data.signal_locations.alt_out_signal
   else
      error("Invalid signal side: " .. tostring(side))
   end

   if not signal_data then return nil end

   -- Return absolute position
   return {
      x = self._position.x + signal_data.position.x,
      y = self._position.y + signal_data.position.y,
   }
end

return mod
