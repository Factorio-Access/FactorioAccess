---Stop Preview
---
---Provides train stop previews, showing where cars would be positioned
---if a train stopped at a nearby station. This helps blind users
---understand train positioning without a train present.
---
---Works only on straight rails that are part of a segment ending at a train stop.

local FaUtils = require("scripts.fa-utils")
local Geometry = require("scripts.geometry")
local RailInfo = require("railutils.rail-info")
local RailQueries = require("railutils.queries")

local mod = {}

---Maximum distance in tiles to show preview (7 cars * 7 units each)
local MAX_PREVIEW_DISTANCE = 49

---Size of one train car in tiles
local CAR_SIZE = 7

---Get effective rail type from entity (handles ghosts)
---@param ent LuaEntity
---@return string The rail type name
local function get_effective_name(ent)
   if ent.type == "entity-ghost" then return ent.ghost_name end
   return ent.name
end

---Check if a rail is a straight rail
---@param rail LuaEntity
---@return boolean
local function is_straight_rail(rail)
   local name = get_effective_name(rail)
   local rail_type = RailQueries.prototype_type_to_rail_type(name)
   return rail_type == RailInfo.RailType.STRAIGHT
end

---Check if rail is vertical or horizontal (the only orientations that can have stops)
---@param rail LuaEntity
---@return "vertical"|"horizontal"|nil
local function get_rail_orientation(rail)
   local name = get_effective_name(rail)
   local rail_type = RailQueries.prototype_type_to_rail_type(name)
   if rail_type ~= RailInfo.RailType.STRAIGHT then return nil end

   local ends = RailQueries.get_end_directions(rail_type, rail.direction)
   local dir_mod_8 = ends[1] % 8

   if dir_mod_8 == 0 then
      return "vertical"
   elseif dir_mod_8 == 4 then
      return "horizontal"
   end

   return nil
end

---Find the train stop at the end of a rail segment
---@param rail LuaEntity
---@param rail_direction defines.rail_direction
---@return LuaEntity? stop The train stop entity, or nil if none
---@return defines.rail_direction? direction The direction used to find the stop
local function find_segment_stop(rail, rail_direction)
   local stop = rail.get_rail_segment_stop(rail_direction)
   if stop then return stop, rail_direction end
   return nil, nil
end

---Calculate signed distance from cursor to stop rail
---Positive means cursor is "behind" the stop (on arrival side)
---@param cursor_pos MapPosition Cursor position (tile center)
---@param stop_rail_pos MapPosition Stop rail position
---@param orientation "vertical"|"horizontal"
---@param stop_direction defines.direction Compass direction the stop faces (from rail_end.location.direction)
---@return number Signed distance (positive = behind stop, negative = past stop)
local function calculate_signed_distance(cursor_pos, stop_rail_pos, orientation, stop_direction)
   -- Calculate raw difference
   local diff
   if orientation == "vertical" then
      diff = cursor_pos.y - stop_rail_pos.y
   else
      diff = cursor_pos.x - stop_rail_pos.x
   end

   -- The stop faces in stop_direction. Trains arrive from the opposite direction.
   -- We want positive distance when cursor is on the arrival side.
   -- stop_direction: 0=N, 4=E, 8=S, 12=W
   -- If stop faces north (0), trains come from south, so positive Y diff = behind
   -- If stop faces south (8), trains come from north, so negative Y diff = behind (flip)
   -- If stop faces east (4), trains come from west, so positive X diff = behind (flip)
   -- If stop faces west (12), trains come from east, so negative X diff = behind

   if orientation == "vertical" then
      -- Stop faces north (0) or south (8)
      if stop_direction == defines.direction.south then diff = -diff end
   else
      -- Stop faces east (4) or west (12)
      if stop_direction == defines.direction.east then diff = -diff end
   end

   return diff
end

---Traverse from current rail to the stop, checking all rails are straight
---@param rail LuaEntity Starting rail
---@param rail_direction defines.rail_direction Direction toward the stop
---@return boolean success True if all rails in path are straight
local function verify_path_is_straight(rail, rail_direction)
   local rail_end = rail.get_rail_end(rail_direction)

   -- Walk to segment end, checking each rail
   -- No cycle guard needed: straight rails can't form cycles
   while true do
      if not is_straight_rail(rail_end.rail) then return false end

      if not rail_end.move_natural() then break end
   end

   return true
end

---Get stop preview information for a rail
---
---Returns a localised string describing the train car position at this rail
---if a train were stopped at the nearby station.
---
---@param rail LuaEntity Rail entity to check
---@param cursor_pos MapPosition Cursor position for accurate tile distance
---@return LocalisedString? nil if no preview available (not straight, no stop, too far, etc.)
function mod.get_stop_preview(rail, cursor_pos)
   -- Only works on straight rails
   if not is_straight_rail(rail) then return nil end

   local orientation = get_rail_orientation(rail)
   if not orientation then return nil end

   -- Check both ends for a train stop
   local stop, stop_direction = find_segment_stop(rail, defines.rail_direction.front)
   if not stop then
      stop, stop_direction = find_segment_stop(rail, defines.rail_direction.back)
   end

   if not stop then return nil end

   -- Get the rail the stop is connected to
   local stop_rail = stop.connected_rail
   if not stop_rail then return nil end

   -- Get the compass direction the stop faces using LuaRailEnd
   local rail_end = stop_rail.get_rail_end(stop.connected_rail_direction)
   local stop_facing_direction = rail_end.location.direction

   -- Verify the stop is on the correct side of its connected rail
   -- The rail should be 2 units in direction 90° counterclockwise from stop_facing_direction
   local expected_rail_dir = Geometry.dir_counterclockwise_90(stop_facing_direction)
   local rail_ux, rail_uy = Geometry.uv_for_direction(expected_rail_dir)
   local expected_rail_x = stop.position.x + rail_ux * 2
   local expected_rail_y = stop.position.y + rail_uy * 2

   local rail_dx = stop_rail.position.x - expected_rail_x
   local rail_dy = stop_rail.position.y - expected_rail_y
   if math.abs(rail_dx) > 0.5 or math.abs(rail_dy) > 0.5 then
      return nil -- Stop is on wrong side of rail for our direction
   end

   -- Check if this stop is "for" our rail
   -- Trains travel in stop_facing_direction to reach the stop, so they arrive from opposite
   local arrival_direction = Geometry.dir_rot180(stop_facing_direction)

   -- Vector from stop_rail to our rail should match arrival direction
   local dx = rail.position.x - stop_rail.position.x
   local dy = rail.position.y - stop_rail.position.y

   -- For rails away from the stop_rail, check we're in the arrival direction
   if math.abs(dx) > 0.5 or math.abs(dy) > 0.5 then
      local direction_from_stop = Geometry.vector_to_direction_cardinal(dx, dy)
      if direction_from_stop ~= arrival_direction then return nil end
   end

   -- Verify the path to the stop is all straight rails
   if not verify_path_is_straight(rail, stop_direction) then return nil end

   -- Use center of tile for consistent distance from both sides of stop
   local tile_center = FaUtils.center_of_tile(cursor_pos)

   -- Calculate signed distance (positive = behind stop, negative = past stop)
   local signed_dist = calculate_signed_distance(tile_center, stop_rail.position, orientation, stop_facing_direction)

   -- If we're past the stop (negative distance), don't show preview
   if signed_dist < 0 then return nil end

   local dist = math.floor(signed_dist)

   -- Check if within preview range
   if dist > MAX_PREVIEW_DISTANCE then return nil end

   -- Calculate car position (1-indexed: positions 1-6 in car, position 7 is gap)
   local car_number = math.floor(dist / CAR_SIZE) + 1
   local position_in_car = (dist % CAR_SIZE) + 1

   if position_in_car == 7 then
      -- Gap after this car
      return { "fa.stop-preview-gap-after-car", stop.backer_name, car_number }
   else
      -- Within a car (positions 1-6)
      return { "fa.stop-preview-car-position", stop.backer_name, car_number, position_in_car }
   end
end

return mod
