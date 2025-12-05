---Stop Preview
---
---Provides train stop previews, showing where cars would be positioned
---if a train stopped at a nearby station. This helps blind users
---understand train positioning without a train present.
---
---Works only on straight rails leading to a train stop.

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

---Check if a stop is valid for preview (connected to axis-aligned rail, on correct side)
---@param stop LuaEntity
---@return LuaEntity? stop_rail The rail the stop is connected to, or nil if invalid
---@return defines.direction? stop_facing The direction the stop faces
---@return "vertical"|"horizontal"? orientation The rail orientation
local function validate_stop(stop)
   local stop_rail = stop.connected_rail
   if not stop_rail then return nil end

   local orientation = get_rail_orientation(stop_rail)
   if not orientation then return nil end

   -- Get the compass direction the stop faces
   local rail_end = stop_rail.get_rail_end(stop.connected_rail_direction)
   local stop_facing = rail_end.location.direction

   -- Verify the stop is on the correct side of its connected rail
   -- The rail should be 2 units in direction 90° counterclockwise from stop_facing
   local expected_rail_dir = Geometry.dir_counterclockwise_90(stop_facing)
   local rail_ux, rail_uy = Geometry.uv_for_direction(expected_rail_dir)
   local expected_rail_x = stop.position.x + rail_ux * 2
   local expected_rail_y = stop.position.y + rail_uy * 2

   local rail_dx = stop_rail.position.x - expected_rail_x
   local rail_dy = stop_rail.position.y - expected_rail_y
   if math.abs(rail_dx) > 0.5 or math.abs(rail_dy) > 0.5 then
      return nil -- Stop is on wrong side of rail for our direction
   end

   return stop_rail, stop_facing, orientation
end

---Find nearby train stops that could form a preview
---@param surface LuaSurface
---@param position MapPosition Center position to search from
---@return table<uint, {stop: LuaEntity, rail: LuaEntity, facing: defines.direction, orientation: "vertical"|"horizontal"}>
local function find_candidate_stops(surface, position)
   local candidates = {}

   local stops = surface.find_entities_filtered({
      type = "train-stop",
      position = position,
      radius = MAX_PREVIEW_DISTANCE + 10, -- A bit extra for the stop offset from rail
   })

   for _, stop in ipairs(stops) do
      local stop_rail, stop_facing, orientation = validate_stop(stop)
      if stop_rail then
         candidates[stop_rail.unit_number] = {
            stop = stop,
            rail = stop_rail,
            facing = stop_facing,
            orientation = orientation,
         }
      end
   end

   return candidates
end

---Extend from a rail in one direction, looking for a candidate stop rail
---@param rail LuaEntity Starting rail
---@param rail_direction defines.rail_direction Direction to extend
---@param candidates table<uint, table> Map of unit_number to candidate info
---@param cursor_pos MapPosition Cursor position for distance calculation
---@return table? candidate The matched candidate, or nil
local function extend_and_find(rail, rail_direction, candidates, cursor_pos)
   local rail_end = rail.get_rail_end(rail_direction)
   local tiles_traveled = 0

   while true do
      local current_rail = rail_end.rail

      -- Check if current rail is a candidate
      local candidate = candidates[current_rail.unit_number]
      if candidate then return candidate end

      -- Check if we've gone too far
      tiles_traveled = tiles_traveled + 2 -- Each straight rail is 2 tiles
      if tiles_traveled > MAX_PREVIEW_DISTANCE then return nil end

      -- Try to move forward (straight only)
      if not rail_end.move_forward(defines.rail_connection_direction.straight) then
         return nil -- Hit end of line or would need to turn
      end

      -- Check if next rail is straight
      if not is_straight_rail(rail_end.rail) then
         return nil -- Hit a curve
      end
   end
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

   -- Find all candidate stops nearby
   local candidates = find_candidate_stops(rail.surface, cursor_pos)
   if not next(candidates) then return nil end

   -- Check if current rail is itself a candidate
   local candidate = candidates[rail.unit_number]

   -- If not, extend in both directions to find one
   if not candidate then
      -- Try front direction
      candidate = extend_and_find(rail, defines.rail_direction.front, candidates, cursor_pos)

      -- Try back direction if front didn't find anything
      if not candidate then candidate = extend_and_find(rail, defines.rail_direction.back, candidates, cursor_pos) end
   end

   if not candidate then return nil end

   local stop = candidate.stop
   local stop_rail = candidate.rail
   local stop_facing = candidate.facing

   -- Check if this stop is "for" our rail (we're on the arrival side)
   local arrival_direction = Geometry.dir_rot180(stop_facing)

   -- Vector from stop_rail to our rail should match arrival direction
   local dx = rail.position.x - stop_rail.position.x
   local dy = rail.position.y - stop_rail.position.y

   -- For rails away from the stop_rail, check we're in the arrival direction
   if math.abs(dx) > 0.5 or math.abs(dy) > 0.5 then
      local direction_from_stop = Geometry.vector_to_direction_cardinal(dx, dy)
      if direction_from_stop ~= arrival_direction then return nil end
   end

   -- Use center of tile for consistent distance from both sides of stop
   local tile_center = FaUtils.center_of_tile(cursor_pos)

   -- Calculate signed distance (positive = behind stop, negative = past stop)
   local signed_dist = calculate_signed_distance(tile_center, stop_rail.position, orientation, stop_facing)

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
