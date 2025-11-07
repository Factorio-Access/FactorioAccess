---Rail Table Extractor
---
---This module extracts comprehensive geometric and connectivity data for all rail piece -types in Factorio 2.0. The
--extracted data is used by the rail navigation system to -understand rail geometry without hardcoding piece-specific
--logic.
---
---# What the Extracted Table Contains
---
---The table structure is: -``` -[prototype_type][placement_direction] = {
---  grid_offset = { x, y },                              -- API placement offset from requested origin
---  bounding_box = { left_top, right_bottom, orientation? },  -- Collision box (may be oriented)
---  occupied_tiles = { {x, y}, ... },              -- Integer tile coordinates relative to entity
---  [end_direction] = {                            -- One entry per rail end
---    signal_locations = { ... },                  -- Signal placement locations
---    extensions = {                               -- Possible next rail pieces
---      [goal_direction] = { ... }
---    }
---  } -} -```
---
---# Rail Types
---
---Factorio 2.0 has four rail piece types:
---  - straight-rail: Simple straight segment
---  - half-diagonal-rail: 45-degree diagonal segment
---  - curved-rail-a: Longer curve (connects cardinal <-> diagonal)
---  - curved-rail-b: Tighter curve (connects diagonals)
---
---# Directions
---
---Rails use 16-way directions (defines.direction), with pieces placeable in 8 directions -(even values 0, 2, 4, 6, 8,
--10, 12, 14). Direction strings like "north", "northeast", -"east" are used for readability.
---
---# Coordinate System
---
---ALL coordinates in the extracted table are relative to the rail piece's actual position -after placement, NOT the
--requested origin. This handles API offsets where the game -places rails at adjusted positions due to grid alignment
--constraints.
---
---The `grid_offset` field records the offset: actual_position - requested_position
---
---Occupied tiles use integer coordinates representing tile indices, not world positions.
---
---# Data Fields
---
---## grid_offset -The offset applied by the API when placing the rail. For example, half-diagonal rails -can only be placed
--on odd coordinates, so the API may grid_offset the position by (1, 1).
---
---## bounding_box -The collision bounding box from LuaEntity.bounding_box, relative to entity position. -Contains
--left_top and right_bottom corners. May include an orientation field if the -box is rotated (making it an oriented
--bounding box, not axis-aligned).
---
---## occupied_tiles -Array of {x, y} integer tile coordinates showing which tiles the rail occupies, -relative to the
--entity's center. Used for collision detection and spatial queries.
---
---## end_direction -Each rail piece has two ends (front/back). The table has one entry per end, keyed by -the end's
--direction. Each end contains:
---
---### signal_locations -Locations where signals can be placed for this rail end:
---  - in_signal: Main entrance signal position/direction
---  - out_signal: Exit signal position/direction
---  - alt_in_signal: Alternative entrance signal (if exists)
---  - alt_out_signal: Alternative exit signal (if exists)
---
---### extensions -Possible rail pieces that can connect to this end, keyed by goal_direction. -Each extension contains:
---  - prototype: The rail type (straight-rail, curved-rail-a, etc.)
---  - position: Where to place the connecting piece
---  - direction: Which direction to place it facing
---  - goal_position: Where the connection point ends up
---  - goal_direction: Direction of the far end of the connecting piece
---
---# How Data is Extracted
---
---For each rail type and direction: -1. Place the rail at origin (0, 0) -2. Record actual position (may differ due to
--API offsets) -3. Scan tiles in 32x32 area to find occupied tiles -4. Query both rail ends using LuaRailEnd API -5. For
--each end, extract signal locations and possible extensions -6. Make all positions relative to actual entity position
---7. Destroy the rail and move to next
---
---# Usage
---
---Called by /railtable command to regenerate the rail geometry table when needed -(e.g., after game updates or to
--verify patterns).

local mod = {}

---Direction number to string name mapping
local DIRECTION_NAMES = {
   [0] = "north",
   [1] = "northnortheast",
   [2] = "northeast",
   [3] = "eastnortheast",
   [4] = "east",
   [5] = "eastsoutheast",
   [6] = "southeast",
   [7] = "southsoutheast",
   [8] = "south",
   [9] = "southsouthwest",
   [10] = "southwest",
   [11] = "westsouthwest",
   [12] = "west",
   [13] = "westnorthwest",
   [14] = "northwest",
   [15] = "northnorthwest",
}

---Rail prototype names (entity names in the game)
local RAIL_PROTOTYPE_NAMES = {
   "straight-rail",
   "half-diagonal-rail",
   "curved-rail-a",
   "curved-rail-b",
}

---8-way placement directions (even values only)
local PLACEMENT_DIRECTIONS = { 0, 2, 4, 6, 8, 10, 12, 14 }

---Extract complete rail geometry data for all rail types and directions
---@param surface LuaSurface Surface to place temporary rails on
---@param force LuaForce Force to use for rail placement
---@return table Rail data table with structure [prototype_type][direction][end_direction]
function mod.extract_rail_table(surface, force)
   local origin = { x = 0, y = 0 }
   local rail_data = {}

   for _, rail_name in ipairs(RAIL_PROTOTYPE_NAMES) do
      local prototype_type = prototypes.entity[rail_name].type
      rail_data[prototype_type] = {}

      for _, dir in ipairs(PLACEMENT_DIRECTIONS) do
         -- Clear any existing rails at origin
         local existing = surface.find_entities_filtered({
            position = origin,
            radius = 10,
            type = prototype_type,
         })
         for _, e in ipairs(existing) do
            e.destroy()
         end

         -- Place rail
         local rail = surface.create_entity({
            name = rail_name,
            position = origin,
            direction = dir,
            force = force,
            raise_built = false,
         })

         if rail then
            local dir_str = DIRECTION_NAMES[dir]
            rail_data[prototype_type][dir_str] = {}

            -- Record actual position (API may offset the entity)
            local actual_position = rail.position
            local grid_offset = {
               x = actual_position.x - origin.x,
               y = actual_position.y - origin.y,
            }

            -- Extract bounding boxes relative to entity position
            local raw_bbox = rail.bounding_box
            local bounding_box = {
               left_top = {
                  x = raw_bbox.left_top.x - actual_position.x,
                  y = raw_bbox.left_top.y - actual_position.y,
               },
               right_bottom = {
                  x = raw_bbox.right_bottom.x - actual_position.x,
                  y = raw_bbox.right_bottom.y - actual_position.y,
               },
            }
            -- Preserve orientation if present
            if raw_bbox.orientation then bounding_box.orientation = raw_bbox.orientation end

            -- Scan tiles to find which tiles contain this entity
            local occupied_tiles = {}
            for tx = -16, 16 do
               for ty = -16, 16 do
                  local tile_x = math.floor(actual_position.x) + tx
                  local tile_y = math.floor(actual_position.y) + ty

                  -- Use entity-selection logic: small search area per tile
                  local search_area = {
                     { x = tile_x + 0.001, y = tile_y + 0.001 },
                     { x = tile_x + 0.999, y = tile_y + 0.999 },
                  }

                  local ents_in_tile = surface.find_entities_filtered({ area = search_area })
                  for _, ent in ipairs(ents_in_tile) do
                     if ent == rail then
                        -- Store relative to entity position (as integer tile coords)
                        table.insert(occupied_tiles, {
                           x = tile_x - actual_position.x,
                           y = tile_y - actual_position.y,
                        })
                        break
                     end
                  end
               end
            end

            rail_data[prototype_type][dir_str].grid_offset = grid_offset
            rail_data[prototype_type][dir_str].bounding_box = bounding_box
            rail_data[prototype_type][dir_str].occupied_tiles = occupied_tiles

            -- Get both rail ends
            local front_end = rail.get_rail_end(defines.rail_direction.front)
            local back_end = rail.get_rail_end(defines.rail_direction.back)

            -- Helper to make positions relative to entity
            local function make_relative_pos(pos)
               return {
                  x = pos.x - actual_position.x,
                  y = pos.y - actual_position.y,
               }
            end

            -- Process both ends
            for _, end_info in ipairs({
               { end_obj = front_end, name = "front" },
               { end_obj = back_end, name = "back" },
            }) do
               local rail_end = end_info.end_obj
               local end_direction = rail_end.location.direction
               local end_dir_str = DIRECTION_NAMES[end_direction]

               rail_data[prototype_type][dir_str][end_dir_str] = {
                  signal_locations = {},
                  extensions = {},
               }

               local end_data = rail_data[prototype_type][dir_str][end_dir_str]

               -- Extract signal locations
               end_data.signal_locations.in_signal = {
                  position = make_relative_pos(rail_end.in_signal_location.position),
                  direction = DIRECTION_NAMES[rail_end.in_signal_location.direction],
               }

               end_data.signal_locations.out_signal = {
                  position = make_relative_pos(rail_end.out_signal_location.position),
                  direction = DIRECTION_NAMES[rail_end.out_signal_location.direction],
               }

               if rail_end.alternative_in_signal_location then
                  end_data.signal_locations.alt_in_signal = {
                     position = make_relative_pos(rail_end.alternative_in_signal_location.position),
                     direction = DIRECTION_NAMES[rail_end.alternative_in_signal_location.direction],
                  }
               end

               if rail_end.alternative_out_signal_location then
                  end_data.signal_locations.alt_out_signal = {
                     position = make_relative_pos(rail_end.alternative_out_signal_location.position),
                     direction = DIRECTION_NAMES[rail_end.alternative_out_signal_location.direction],
                  }
               end

               -- Extract extensions
               local extensions = rail_end.get_rail_extensions("rail")
               for _, ext in ipairs(extensions) do
                  local ext_prototype_type = prototypes.entity[ext.name].type
                  local goal_dir_str = DIRECTION_NAMES[ext.goal.direction]

                  end_data.extensions[goal_dir_str] = {
                     prototype = ext_prototype_type,
                     position = make_relative_pos(ext.position),
                     direction = DIRECTION_NAMES[ext.direction],
                     goal_position = make_relative_pos(ext.goal.position),
                     goal_direction = goal_dir_str,
                  }
               end
            end

            -- Clean up temporary rail
            rail.destroy()
         end
      end
   end

   return rail_data
end

return mod
