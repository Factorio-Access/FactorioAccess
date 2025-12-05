---Signal and Station Classifier
---
---Analyzes rails to find signals and train stations associated with them.
---Used for rail announcements and primary rail detection.

local RailInfo = require("railutils.rail-info")
local RailQueries = require("railutils.queries")

local mod = {}

---@alias fa.rails.SignalType "signal"|"chain"

---@class fa.rails.SignalStationInfo
---@field direction defines.direction Direction of the rail end with signals
---@field left fa.rails.SignalType? Type of signal on left side (in_signal), nil if none
---@field right fa.rails.SignalType? Type of signal on right side (out_signal), nil if none
---@field station boolean True if a train station is adjacent to this rail

---Get effective rail type from entity (handles ghosts)
---@param ent LuaEntity
---@return string The rail type (e.g., "straight-rail")
local function get_effective_type(ent)
   if ent.type == "entity-ghost" then return ent.ghost_type end
   return ent.type
end

---Get effective rail name from entity (handles ghosts)
---@param ent LuaEntity
---@return string The rail prototype name
local function get_effective_name(ent)
   if ent.type == "entity-ghost" then return ent.ghost_name end
   return ent.name
end

---Check what type of signal exists at a position
---@param surface LuaSurface
---@param position MapPosition
---@return fa.rails.SignalType? nil if no signal, "signal" or "chain" otherwise
local function get_signal_type_at(surface, position)
   local signal = surface.find_entity("rail-signal", position)
   if signal then return "signal" end

   local chain = surface.find_entity("rail-chain-signal", position)
   if chain then return "chain" end

   return nil
end

---Check for signals at a rail end using the Factorio API
---@param rail LuaEntity Rail entity
---@param rail_direction defines.rail_direction Which end to check
---@return defines.direction? end_direction Direction of the rail end
---@return fa.rails.SignalType? left Signal type on left (in_signal)
---@return fa.rails.SignalType? right Signal type on right (out_signal)
local function get_signals_at_end(rail, rail_direction)
   local rail_end = rail.get_rail_end(rail_direction)
   local surface = rail.surface

   local end_direction = rail_end.location.direction

   -- in_signal_location = left relative to movement
   -- out_signal_location = right relative to movement
   local left = get_signal_type_at(surface, rail_end.in_signal_location.position)
   local right = get_signal_type_at(surface, rail_end.out_signal_location.position)

   -- Also check alternative signal locations
   if not left and rail_end.alternative_in_signal_location then
      left = get_signal_type_at(surface, rail_end.alternative_in_signal_location.position)
   end
   if not right and rail_end.alternative_out_signal_location then
      right = get_signal_type_at(surface, rail_end.alternative_out_signal_location.position)
   end

   return end_direction, left, right
end

---Check if this is a vertical or horizontal rail
---@param rail_type railutils.RailType
---@param placement_direction defines.direction
---@return "vertical"|"horizontal"|nil
local function get_rail_orientation(rail_type, placement_direction)
   if rail_type ~= RailInfo.RailType.STRAIGHT then return nil end

   local ends = RailQueries.get_end_directions(rail_type, placement_direction)
   local dir_mod_8 = ends[1] % 8

   if dir_mod_8 == 0 then
      return "vertical" -- north/south
   elseif dir_mod_8 == 4 then
      return "horizontal" -- east/west
   end

   return nil
end

---Check if a train station is adjacent to this rail
---
---Stations can only be placed adjacent to vertical or horizontal straight rails.
---For vertical rails: 2 units left or right (x +/- 2)
---For horizontal rails: 2 units up or down (y +/- 2)
---
---@param rail LuaEntity Rail entity
---@param rail_type railutils.RailType
---@param placement_direction defines.direction
---@return boolean True if a station is adjacent
local function has_adjacent_station(rail, rail_type, placement_direction)
   local orientation = get_rail_orientation(rail_type, placement_direction)
   if not orientation then return false end

   local surface = rail.surface
   local pos = rail.position

   local offsets
   if orientation == "vertical" then
      -- Check 2 units left and right
      offsets = { { x = -2, y = 0 }, { x = 2, y = 0 } }
   else
      -- horizontal: check 2 units up and down
      offsets = { { x = 0, y = -2 }, { x = 0, y = 2 } }
   end

   for _, offset in ipairs(offsets) do
      local check_pos = { x = pos.x + offset.x, y = pos.y + offset.y }
      local station = surface.find_entity("train-stop", check_pos)
      if station then return true end
   end

   return false
end

---Get signal and station information for a rail entity
---
---Checks both ends of the rail for signals. If one end has signals, returns
---info for that end. Signals on both ends is rare and we only report one.
---
---@param rail LuaEntity Rail entity to analyze
---@return fa.rails.SignalStationInfo? nil if no signals or stations found
function mod.get_signal_station_info(rail)
   local effective_name = get_effective_name(rail)
   local rail_type = RailQueries.prototype_type_to_rail_type(effective_name)
   local placement_direction = rail.direction

   -- Check for station first (only vertical/horizontal straight rails)
   local has_station = has_adjacent_station(rail, rail_type, placement_direction)

   -- Check front end for signals
   local front_dir, front_left, front_right = get_signals_at_end(rail, defines.rail_direction.front)
   if front_left or front_right then
      return {
         direction = front_dir,
         left = front_left,
         right = front_right,
         station = has_station,
      }
   end

   -- Check back end for signals
   local back_dir, back_left, back_right = get_signals_at_end(rail, defines.rail_direction.back)
   if back_left or back_right then
      return {
         direction = back_dir,
         left = back_left,
         right = back_right,
         station = has_station,
      }
   end

   -- No signals found, but might have station
   if has_station then
      -- Return info with just station, use front end direction as default
      return {
         direction = front_dir,
         left = nil,
         right = nil,
         station = true,
      }
   end

   return nil
end

---Check if a rail has any signals or stations
---
---Convenience function for primary rail detection.
---
---@param rail LuaEntity Rail entity to check
---@return boolean True if rail has signals or station
function mod.has_signals_or_station(rail)
   return mod.get_signal_station_info(rail) ~= nil
end

return mod
