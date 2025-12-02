---Rail Primary Finder
---
---When multiple rails occupy the same tile (like at forks), we want to report only
---the "primary" rails - the ones that aren't connected to other rails we're already reporting.
---This avoids verbose announcements like "rail forks left and right of north curved rail bottom of west to south turn".

local Consts = require("scripts.consts")
local RailInfo = require("railutils.rail-info")
local RailQueries = require("railutils.queries")
local Traverser = require("railutils.traverser")

local mod = {}

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

---Push all connected rail unit numbers into a set
---@param connected_set table<integer, true> Set to add connected unit numbers to
---@param rail_ent LuaEntity Rail entity to find neighbors for
---@param rail_type railutils.RailType Type of the rail
---@param placement_direction defines.direction Direction the rail is placed
---@param position fa.Point Position of the rail
---@param query_fn fun(area: BoundingBox.0): LuaEntity[] Function to query rails at an area
local function push_connected_unit_numbers(connected_set, rail_ent, rail_type, placement_direction, position, query_fn)
   -- Get both end directions for this rail (always 2)
   local end_directions = RailQueries.get_end_directions(rail_type, placement_direction)

   -- For each end, check all 3 neighbors (forward, left, right) = 6 total extensions
   for _, end_direction in ipairs(end_directions) do
      local base_trav = Traverser.new(rail_type, position, end_direction)

      -- Forward, left, right (all 3 always exist)
      local moves = {
         function(t)
            t:move_forward()
         end,
         function(t)
            t:move_left()
         end,
         function(t)
            t:move_right()
         end,
      }

      for _, move_fn in ipairs(moves) do
         local trav = base_trav:clone()
         move_fn(trav)

         -- Get expected rail from traverser
         local expected_pos = trav:get_position()
         local expected_direction = trav:get_placement_direction()
         local expected_type = RailQueries.rail_type_to_prototype_type(trav:get_rail_kind())

         -- Floor the expected position (rails are grid-aligned)
         local expected_floor_x = math.floor(expected_pos.x)
         local expected_floor_y = math.floor(expected_pos.y)

         local search_area = {
            { x = expected_floor_x + 0.001, y = expected_floor_y + 0.001 },
            { x = expected_floor_x + 0.999, y = expected_floor_y + 0.999 },
         }

         -- Find rails at next position using provided query function
         local rails_at_pos = query_fn(search_area)

         -- Add rails that match the expected type, direction, and position
         for _, connected_rail in ipairs(rails_at_pos) do
            if connected_rail.valid and connected_rail.unit_number then
               -- Check that this rail matches what the traverser expects
               local rail_floor_x = math.floor(connected_rail.position.x)
               local rail_floor_y = math.floor(connected_rail.position.y)
               local pos_match = rail_floor_x == expected_floor_x and rail_floor_y == expected_floor_y
               local type_match = get_effective_name(connected_rail) == expected_type
               local direction_match = connected_rail.direction == expected_direction

               if pos_match and type_match and direction_match then connected_set[connected_rail.unit_number] = true end
            end
         end
      end
   end
end

---Sort order for rail types (lower number = higher priority)
---@param rail_type string Rail type name
---@return number Priority (lower = higher priority)
local function get_rail_priority(rail_type)
   if rail_type == "straight-rail" then
      return 1
   elseif rail_type == "half-diagonal-rail" then
      return 2
   elseif rail_type == "curved-rail-a" then
      return 3
   elseif rail_type == "curved-rail-b" then
      return 4
   else
      return 999 -- Unknown types go last
   end
end

---Deduplicate secondary rails that are connected to primary rails
---
---When multiple rails occupy the same tile, this filters to keep only "primary" rails.
---A rail is considered secondary if it connects to a rail we've already decided to keep.
---
---@param rail_list LuaEntity[] Array of rail entities at the same position
---@param query_fn fun(area: BoundingBox.0): LuaEntity[] Function to query rails at an area
---@return LuaEntity[] Filtered array with only primary rails
function mod.deduplicate_secondary_rails(rail_list, query_fn)
   if #rail_list <= 1 then return rail_list end

   -- Sort by priority: straight > half-diagonal > curve-a > curve-b
   -- Tie-break by unit number for stability
   table.sort(rail_list, function(a, b)
      local priority_a = get_rail_priority(get_effective_type(a))
      local priority_b = get_rail_priority(get_effective_type(b))
      if priority_a ~= priority_b then return priority_a < priority_b end
      return (a.unit_number or 0) < (b.unit_number or 0)
   end)

   local result = {}
   local connected_to_primary = {} -- Set of unit numbers connected to rails we're keeping

   for _, rail_ent in ipairs(rail_list) do
      if rail_ent.valid and rail_ent.unit_number then
         -- Check if this rail is connected to something we already added
         local is_secondary = connected_to_primary[rail_ent.unit_number]

         if not is_secondary then
            -- This is a primary rail - add it to result
            table.insert(result, rail_ent)

            -- Mark all rails connected to this one
            local rail_type = RailQueries.prototype_type_to_rail_type(get_effective_name(rail_ent))
            push_connected_unit_numbers(
               connected_to_primary,
               rail_ent,
               rail_type,
               rail_ent.direction,
               { x = rail_ent.position.x, y = rail_ent.position.y },
               query_fn
            )
         end
      end
   end

   return result
end

return mod
