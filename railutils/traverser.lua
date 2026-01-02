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

---Get the end data for the current state (internal helper)
---@return table End data from RailData with extensions and signal_locations
function Traverser:_get_end_data()
   local prototype = Queries.rail_type_to_prototype_type(self._rail_type)
   local rail_entry = RailData[prototype]
   if not rail_entry then error("Invalid rail type in traverser state") end

   local direction_entry = rail_entry[self._placement_direction]
   if not direction_entry then error("Invalid placement direction in traverser state") end

   local end_data = direction_entry[self._end_direction]
   if not end_data then error("Invalid end direction in traverser state") end

   return end_data
end

---Apply an extension result to update traverser state (internal helper)
---@param ext railutils.ExtensionPoint
function Traverser:_apply_extension(ext)
   self._rail_type = Queries.prototype_type_to_rail_type(ext.next_rail_prototype)
   self._placement_direction = ext.next_rail_direction
   self._position = ext.next_rail_position
   self._end_direction = ext.next_rail_goal_direction
end

---Get signal data for a specific side (internal helper)
---@param end_data table End data from _get_end_data
---@param side railutils.SignalSide LEFT or RIGHT
---@param use_alt boolean If true, use alt_in_signal/alt_out_signal instead
---@return table|nil Signal data with position and direction
function Traverser:_get_signal_data(end_data, side, use_alt)
   if not end_data.signal_locations then
      if use_alt then return nil end
      error("No signal locations for current end")
   end

   local signal_data
   if side == mod.SignalSide.LEFT then
      signal_data = use_alt and end_data.signal_locations.alt_in_signal or end_data.signal_locations.in_signal
   elseif side == mod.SignalSide.RIGHT then
      signal_data = use_alt and end_data.signal_locations.alt_out_signal or end_data.signal_locations.out_signal
   else
      error("Invalid signal side: " .. tostring(side))
   end

   if not signal_data and not use_alt then error("No signal found for side: " .. tostring(side)) end

   return signal_data
end

---Create a new traverser with explicit placement direction
---@param rail_type railutils.RailType Initial rail type
---@param position fa.Point Initial position (should already be grid-adjusted if binding to a real rail)
---@param placement_direction defines.direction Direction the rail was placed
---@param end_direction defines.direction Which end to bind to
---@return railutils.Traverser
function mod.new(rail_type, position, placement_direction, end_direction)
   -- Validate that the arguments match exact values in the rail data table
   local prototype = Queries.rail_type_to_prototype_type(rail_type)
   local rail_entry = RailData[prototype]
   if not rail_entry then
      error(string.format("Invalid rail_type: %s (prototype: %s)", tostring(rail_type), tostring(prototype)))
   end

   local direction_entry = rail_entry[placement_direction]
   if not direction_entry then
      error(
         string.format(
            "Invalid placement_direction %d for rail_type %s (prototype: %s)",
            placement_direction,
            tostring(rail_type),
            prototype
         )
      )
   end

   if not direction_entry[end_direction] then
      error(
         string.format(
            "Invalid end_direction %d for placement_direction %d of rail_type %s (prototype: %s)",
            end_direction,
            placement_direction,
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
   local goal_direction = (self._end_direction + direction_offset) % 16
   local end_data = self:_get_end_data()

   if not end_data.extensions then error("No extensions for current end") end

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
   self:_apply_extension(self:_get_extension(0))
end

---Turn left (direction - 1)
function Traverser:move_left()
   self:_apply_extension(self:_get_extension(-1))
end

---Turn right (direction + 1)
function Traverser:move_right()
   self:_apply_extension(self:_get_extension(1))
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

---Clone this traverser to create an independent copy
---@return railutils.Traverser
function Traverser:clone()
   return setmetatable({
      _rail_type = self._rail_type,
      _placement_direction = self._placement_direction,
      _position = { x = self._position.x, y = self._position.y },
      _end_direction = self._end_direction,
   }, Traverser_meta)
end

---Get signal position on a specific side
---@param side railutils.SignalSide LEFT or RIGHT
---@return fa.Point Absolute signal position
function Traverser:get_signal_pos(side)
   local end_data = self:_get_end_data()
   local signal_data = self:_get_signal_data(end_data, side, false)

   return {
      x = self._position.x + signal_data.position.x,
      y = self._position.y + signal_data.position.y,
   }
end

---Get alternative signal position on a specific side
---@param side railutils.SignalSide LEFT or RIGHT
---@return fa.Point|nil Absolute signal position, or nil if no alt signal
function Traverser:get_alt_signal_pos(side)
   local end_data = self:_get_end_data()
   local signal_data = self:_get_signal_data(end_data, side, true)
   if not signal_data then return nil end

   return {
      x = self._position.x + signal_data.position.x,
      y = self._position.y + signal_data.position.y,
   }
end

---Get signal direction on a specific side
---@param side railutils.SignalSide LEFT or RIGHT
---@return defines.direction Signal direction
function Traverser:get_signal_direction(side)
   local end_data = self:_get_end_data()
   local signal_data = self:_get_signal_data(end_data, side, false)
   return signal_data.direction
end

return mod
