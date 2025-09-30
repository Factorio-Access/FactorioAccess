--Here: Utility functions called by other files. Examples include distance and position calculations, string processing.
local util = require("util")
local Viewpoint = require("scripts.viewpoint")
local dirs = defines.direction

local Consts = require("scripts.consts")
local EntitySelection = require("scripts.entity-selection")

local mod = {}

-- Helper function to draw a circle at the given position
local function draw_circle_at_position(surface, pos, color, radius, width, time_to_live)
   rendering.draw_circle({
      color = color or { 1, 0.0, 0.5 },
      radius = radius or 0.1,
      width = width or 2,
      target = pos,
      surface = surface,
      time_to_live = time_to_live or 30,
   })
end

-- Helper function to check if a preferred entity is at a given position
local function check_entity_at_position(surface, pos, preferred_unit_number, excluded_names)
   local entities = surface.find_entities_filtered({ position = pos, name = excluded_names, invert = true })
   for i = 1, math.min(3, #entities) do
      if entities[i].unit_number == preferred_unit_number then return true end
   end
   return false
end

-- Lookup table for direction offsets
local DIRECTION_OFFSETS = {
   [dirs.north] = { x = 0, y = -1 },
   [dirs.northeast] = { x = 1, y = -1 },
   [dirs.east] = { x = 1, y = 0 },
   [dirs.southeast] = { x = 1, y = 1 },
   [dirs.south] = { x = 0, y = 1 },
   [dirs.southwest] = { x = -1, y = 1 },
   [dirs.west] = { x = -1, y = 0 },
   [dirs.northwest] = { x = -1, y = -1 },
}

-- Lookup table for half-diagonal to full-diagonal mapping
local HALF_DIAGONAL_MAP = {
   [dirs.northnortheast] = dirs.northeast,
   [dirs.eastnortheast] = dirs.northeast,
   [dirs.eastsoutheast] = dirs.southeast,
   [dirs.southsoutheast] = dirs.southeast,
   [dirs.southsouthwest] = dirs.southwest,
   [dirs.westsouthwest] = dirs.southwest,
   [dirs.westnorthwest] = dirs.northwest,
   [dirs.northnorthwest] = dirs.northwest,
}

function mod.center_of_tile(pos)
   return { x = math.floor(pos.x) + 0.5, y = math.floor(pos.y) + 0.5 }
end

function mod.add_position(p1, p2)
   return { x = p1.x + p2.x, y = p1.y + p2.y }
end

function mod.sub_position(p1, p2)
   return { x = p1.x - p2.x, y = p1.y - p2.y }
end

function mod.mult_position(p, m)
   return { x = p.x * m, y = p.y * m }
end

-- This function is legacy. Do not use.  It cannot account for 16 directions and
-- does not move by 1 on the diagonals. That is, it is *not* working in unit
-- vectors.  Now that Factorio 2.0 is making us work with 16 directions, and
-- given that space age does actually use 16 directions as well as new rails,
-- that's not good enough.
function mod.offset_position_legacy(oldpos, direction, distance)
   local offset = DIRECTION_OFFSETS[direction]
   if offset then return { x = oldpos.x + offset.x * distance, y = oldpos.y + offset.y * distance } end
   return oldpos
end

--Offsets a position in a cardinal direction by a given distance
function mod.offset_position_cardinal(oldpos, direction, distance)
   local offset = DIRECTION_OFFSETS[direction]
   if
      offset
      and (direction == dirs.north or direction == dirs.south or direction == dirs.east or direction == dirs.west)
   then
      return { x = oldpos.x + offset.x * distance, y = oldpos.y + offset.y * distance }
   else
      error("Unsupported direction for offset request: " .. tostring(direction))
   end
end

--Gives the neighboring tile for each direction. Half diagonals are rounded to full diagonals.
function mod.to_neighboring_tile(pos, facing_direction)
   local dir = facing_direction
   -- Map half diagonals to full diagonals
   dir = HALF_DIAGONAL_MAP[dir] or dir

   local offset = DIRECTION_OFFSETS[dir]
   if offset then
      return { x = pos.x + offset.x, y = pos.y + offset.y }
   else
      return pos
   end
end

--Reports the direction and distance of one point from another. Biased towards the diagonals.
function mod.dir_dist(pos1, pos2)
   local x1 = pos1.x
   local x2 = pos2.x
   local dx = x2 - x1
   local y1 = pos1.y
   local y2 = pos2.y
   local dy = y2 - y1
   if dx == 0 and dy == 0 then return { 8, 0 } end
   --Consistent way to calculate dir:
   local dir = mod.get_direction_biased(pos2, pos1) --pos2 = that, pos1 = this
   --Alternate way to calculate dir:
   --local dir = math.atan2(dy, dx) --scaled -pi to pi 0 being east
   --dir = dir + math.sin(4 * dir) / 4 --bias towards the diagonals
   --dir = dir / math.pi -- now scaled as -0.5 north, 0 east, 0.5 south
   --dir = math.floor(dir * defines.direction.south + defines.direction.east + 0.5) --now scaled correctly
   --dir = dir % (2 * defines.direction.south) --now wrapped correctly
   local dist = math.sqrt(dx * dx + dy * dy)
   return { dir, dist }
end

function mod.dir(pos1, pos2)
   return mod.dir_dist(pos1, pos2)[1]
end

function mod.direction(pos1, pos2)
   return mod.direction_lookup(mod.dir(pos1, pos2))
end

function mod.distance(pos1, pos2)
   return mod.dir_dist(pos1, pos2)[2]
end

function mod.distance_speech_friendly(pos1, pos2)
   local dist = mod.distance(pos1, pos2)
   local mul = 1
   if dist < 1 then mul = 10 end

   local rounded = math.ceil(dist * mul) / mul
   return rounded
end

function mod.squared_distance(pos1, pos2)
   local offset = { x = pos1.x - pos2.x, y = pos1.y - pos2.y }
   local result = offset.x * offset.x + offset.y * offset.y
   return result
end

--[[
* Returns the direction of that entity from this entity, with a bias against the 4 cardinal directions so that you can align with them more easily.
* Returns 1 of 8 main directions, based on the ratios of the x and y distances.
* The deciding ratio is 1 to 4, meaning that for an object that is 100 tiles north, it can be offset by up to 25 tiles east or west before it stops being counted as "directly" in the north.
* The arctangent of 1/4 is about 14 degrees, meaning that the field of view that directly counts as a cardinal direction is about 30 degrees, while for a diagonal direction it is about 60 degrees.]]
function mod.get_direction_biased(pos_target, pos_origin)
   local diff_x = pos_target.x - pos_origin.x
   local diff_y = pos_target.y - pos_origin.y
   ---@type defines.direction | -1
   local dir = dirs.north

   if math.abs(diff_x) > 4 * math.abs(diff_y) then --along east-west
      if diff_x > 0 then
         dir = defines.direction.east
      else
         dir = defines.direction.west
      end
   elseif math.abs(diff_y) > 4 * math.abs(diff_x) then --along north-south
      if diff_y > 0 then
         dir = defines.direction.south
      else
         dir = defines.direction.north
      end
   else --along diagonals
      if diff_x > 0 and diff_y > 0 then
         dir = defines.direction.southeast
      elseif diff_x > 0 and diff_y < 0 then
         dir = defines.direction.northeast
      elseif diff_x < 0 and diff_y > 0 then
         dir = defines.direction.southwest
      elseif diff_x < 0 and diff_y < 0 then
         dir = defines.direction.northwest
      elseif diff_x == 0 and diff_y == 0 then
         dir = defines.direction.north
      end
   end

   return dir
end

---@param vector fa.Point
---@return defines.direction?
function mod.direction_of_vector(vector)
   --[[
   The math, since not everyone knows it:

   Factorio directions are 16 way.  Slice the circle like a pizza and you get
   north, northeast etc. like the compass rose.  Vectors need to associate to
   one of them, but will not always be perfectly aligned.  The angle between two
   subsequent directions is 22.5.

   Rotate the imaginary circle by 11.5 degrees, and now north lies directly in
   the middle of a cone, whose extent is 11.5 degrees left, 11.5 degrees right,
   22.5 degrees total.

   Slice this circle again with the 16 directions and you get segments.  Number
   these segments from 0 to 31.  Segments 0 and 31 are the special case and are
   north.  Segments 1 and 2 form north-northeast. Segments 3 and 4 form
   northeast.  So on.

   If we did not have special cases we could map things by just dividing by 2
   and taking the floor, but we need segment 31 to map to segment 0.  By adding
   1, we get 1 through 32. Segment 1 maps to north, and segment 32 mod 32 maps
   to north.  Segment 2 and 3 divided map to north-northeast, so on.

   To fix at the end, then just take mod 16: 16 maps to 0 and all is well.
   ]]
   -- Arg 1 is opposite; arg 2 is adjacent; swapping them exchanges
   -- counterclockwise of east to counterclockwise of north; negating then flips
   -- to clockwise.
   local angle = math.atan2(vector.x, -vector.y)
   -- 2pi/32 = pi/16, lua will not fold the constants.
   local segment = math.floor(angle / (math.pi / 16))
   local segment_off = segment + 1
   local mapped = segment % 32
   local dir = math.floor(mapped / 2)
   assert(dir < 16)
   return dir --[[ @as defines.direction ]]
end

function mod.get_direction_precise(pos_target, pos_origin)
   local diff_x = pos_target.x - pos_origin.x
   local diff_y = pos_target.y - pos_origin.y
   -- For legacy reasons, this must default north: callers have never checked,
   -- and this used to be a very complex if tree.
   return mod.direction_of_vector({ x = diff_x, y = diff_y }) or dirs.north
end

--Checks whether a cardinal or diagonal direction is precisely aligned. All check positions are floored to their northwest corners.
function mod.is_direction_aligned(pos_origin, pos_target)
   local diff_x = math.abs(math.floor(pos_origin.x) - math.floor(pos_target.x))
   local diff_y = math.abs(math.floor(pos_origin.y) - math.floor(pos_target.y))

   -- If both are zero, they're on top of each other.
   if diff_x == 0 and diff_y == 0 then return false end

   -- The cardinal directions are aligned if exactly one of the diff_x or diff_y is 0.
   if diff_x == 0 or diff_y == 0 then return true end

   -- The diagonals are aligned if the x and y distances are equal.
   if diff_x == diff_y then return true end

   --None of the above means they are not aligned.
   return false
end

--Converts an input direction into a localised string.
--Note: Directions are integeres but we need to use only defines because they will change in update 2.0. Todo: localise error cases.
function mod.direction_lookup(dir)
   local reading = "unknown"
   if dir < 0 then return "unknown direction ID " .. dir end
   if dir >= dirs.north and dir <= dirs.northnorthwest then
      return helpers.direction_to_string(dir)
   else
      if dir == 16 then --Returned by the game when there is no direction in particular
         reading = ""
      elseif dir == 99 then --Defined by mod
         reading = "Here"
      else
         reading = "unknown direction ID " .. dir
      end
      return reading
   end
end

function mod.rotate_90(dir)
   return (dir + dirs.east) % (2 * dirs.south)
end

function mod.rotate_180(dir)
   return (dir + dirs.south) % (2 * dirs.south)
end

function mod.rotate_270(dir)
   return (dir + dirs.east * 3) % (2 * dirs.south)
end

function mod.reset_rotation(pindex)
   storage.players[pindex].building_direction = dirs.north
end

--Converts the entity orientation into a heading direction, with all directions having equal bias.
--Returns the direction value, or nil if entity is nil.
function mod.get_heading_value(ent)
   if ent == nil then return nil end
   local ori = ent.orientation
   if ori < 0.0625 then
      return dirs.north
   elseif ori < 0.1875 then
      return dirs.northeast
   elseif ori < 0.3125 then
      return dirs.east
   elseif ori < 0.4375 then
      return dirs.southeast
   elseif ori < 0.5625 then
      return dirs.south
   elseif ori < 0.6875 then
      return dirs.southwest
   elseif ori < 0.8125 then
      return dirs.west
   elseif ori < 0.9375 then
      return dirs.northwest
   else
      return dirs.north --default
   end
end

--Converts the entity orientation value to a heading direction string, with all directions having equal bias.
--Returns nil if entity is nil.
function mod.get_heading_info(ent)
   local heading_value = mod.get_heading_value(ent)
   if heading_value == nil then return nil end
   return mod.direction_lookup(heading_value)
end

--Returns the length and width of the entity version of an item.
function mod.get_tile_dimensions(item, dir)
   if item.place_result ~= nil then
      local dimensions = item.place_result.selection_box
      local x = math.ceil(dimensions.right_bottom.x - dimensions.left_top.x)
      local y = math.ceil(dimensions.right_bottom.y - dimensions.left_top.y)
      if dir == dirs.north or dir == dirs.south then
         return { x = x, y = y }
      else
         return { x = y, y = x }
      end
   end
   return { x = 0, y = 0 }
end

--[[
Calculates the complete building footprint for an entity, handling all placement modes and offsets.
This centralizes the logic that was previously scattered across building-tools.lua and graphics.lua.

Parameters:
- params.entity_prototype: The entity prototype (or provide width/height directly)
- params.width: Entity width in tiles (if not using prototype)
- params.height: Entity height in tiles (if not using prototype)
- params.position: The base position (cursor or player position)
- params.building_direction: The entity's rotation (dirs.north, dirs.east, etc.)
- params.player_direction: The player's facing direction (for non-cursor mode)
- params.is_rail_vehicle: Special handling for locomotives/wagons

Returns:
{
  left_top = {x, y},
  right_bottom = {x, y},
  center = {x, y},
  width = number,
  height = number
}
]]
function mod.calculate_building_footprint(params)
   local width, height

   -- Get dimensions from prototype or direct parameters
   if params.entity_prototype then
      width = params.entity_prototype.tile_width
      height = params.entity_prototype.tile_height
   else
      width = params.width or 1
      height = params.height or 1
   end

   -- Handle direction rotation (east/west swap width and height)
   if params.building_direction == dirs.east or params.building_direction == dirs.west then
      width, height = height, width
   end

   -- Calculate initial footprint from position
   local left_top = {
      x = math.floor(params.position.x),
      y = math.floor(params.position.y),
   }
   local right_bottom = {
      x = left_top.x + width,
      y = left_top.y + height,
   }

   -- Calculate center position
   local center = {
      x = left_top.x + math.floor(width / 2),
      y = left_top.y + math.floor(height / 2),
   }

   return {
      left_top = left_top,
      right_bottom = right_bottom,
      center = center,
      width = width,
      height = height,
   }
end

--Small utility function for getting an entity's footprint area using just its name.
function mod.get_ent_area_from_name(ent_name, pindex)
   -- local ents = game.get_player(pindex).surface.find_entities_filtered{name = ent_name, limit = 1}
   -- if #ents == 0 then
   -- return -1
   -- else
   -- return ents[1].tile_height * ents[1].tile_width
   -- end
   return prototypes.entity[ent_name].tile_width * prototypes.entity[ent_name].tile_height
end

--Returns the map position of the northwest corner of an entity.
--NOTE: If the calculation result gives a tile that does not touch the ent, then the ent's own position is returned instead.
--TODO fix the calculation (several attempts have failed so far because fixing it for one group of ents breaks it for others).
function mod.get_ent_northwest_corner_position(ent)
   if ent.valid == false or ent.tile_width == nil then return ent.position end
   local width = ent.tile_width
   local height = ent.tile_height
   local pos = mod.center_of_tile({
      x = math.floor(ent.position.x - width / 2),
      y = math.floor(ent.position.y - height / 2),
   })
   --Error correction:
   --When the northwest corner selection has missed the ent for some reason, the ent position is used instead.
   local surf = ent.surface
   local pos_contains_ent = false
   local pos_ents = surf.find_entities_filtered({ position = pos })
   if pos_ents == nil or #pos_ents == 0 then
      pos_contains_ent = false
   else
      for i, e in ipairs(pos_ents) do
         if e.unit_number == ent.unit_number then pos_contains_ent = true end
      end
   end
   if pos_contains_ent == false then pos = mod.center_of_tile(ent.position) end

   --Return the pos
   return pos
end

--Reports which part of the selected entity has the cursor. E.g. southwest corner, center...
function mod.get_entity_part_at_cursor(pindex)
   local p = game.get_player(pindex)
   local vp = Viewpoint.get_viewpoint(pindex)
   local cursor_pos = vp:get_cursor_pos()
   local x = cursor_pos.x
   local y = cursor_pos.y
   local ents = EntitySelection.get_tile_cache(pindex).ents
   local north_same = false
   local south_same = false
   local east_same = false
   local west_same = false
   local location = nil

   --First check if there is an entity at the cursor
   if #ents > 0 then
      --Prefer the selected ent
      local preferred_ent = p.selected
      --Otherwise check for other ents at the cursor
      if not preferred_ent or not preferred_ent.valid then
         preferred_ent = EntitySelection.get_first_ent_at_tile(pindex)
      end
      if not preferred_ent or not preferred_ent.valid then return "unknown location" end

      --Report which part of the entity the cursor covers.
      draw_circle_at_position(p.surface, { x = x, y = y - 1 })
      draw_circle_at_position(p.surface, { x = x, y = y + 1 })
      draw_circle_at_position(p.surface, { x = x - 1, y = y })
      draw_circle_at_position(p.surface, { x = x + 1, y = y })

      north_same =
         check_entity_at_position(p.surface, { x = x, y = y - 1 }, preferred_ent.unit_number, Consts.EXCLUDED_ENT_NAMES)
      south_same =
         check_entity_at_position(p.surface, { x = x, y = y + 1 }, preferred_ent.unit_number, Consts.EXCLUDED_ENT_NAMES)
      east_same =
         check_entity_at_position(p.surface, { x = x + 1, y = y }, preferred_ent.unit_number, Consts.EXCLUDED_ENT_NAMES)
      west_same =
         check_entity_at_position(p.surface, { x = x - 1, y = y }, preferred_ent.unit_number, Consts.EXCLUDED_ENT_NAMES)

      if north_same and south_same then
         if east_same and west_same then
            location = "center"
         elseif east_same and not west_same then
            location = "west edge"
         elseif not east_same and west_same then
            location = "east edge"
         elseif not east_same and not west_same then
            location = "middle"
         end
      elseif north_same and not south_same then
         if east_same and west_same then
            location = "south edge"
         elseif east_same and not west_same then
            location = "southwest corner"
         elseif not east_same and west_same then
            location = "southeast corner"
         elseif not east_same and not west_same then
            location = "south tip"
         end
      elseif not north_same and south_same then
         if east_same and west_same then
            location = "north edge"
         elseif east_same and not west_same then
            location = "northwest corner"
         elseif not east_same and west_same then
            location = "northeast corner"
         elseif not east_same and not west_same then
            location = "north tip"
         end
      elseif not north_same and not south_same then
         if east_same and west_same then
            location = "middle"
         elseif east_same and not west_same then
            location = "west tip"
         elseif not east_same and west_same then
            location = "east tip"
         elseif not east_same and not west_same then
            location = "all"
         end
      end
   end
   return location
end

--Returns the top left and bottom right corners for a rectangle that takes pos_1 and pos_2 as any of its four corners.
function mod.get_top_left_and_bottom_right(pos_1, pos_2)
   local top_left = { x = math.min(pos_1.x, pos_2.x), y = math.min(pos_1.y, pos_2.y) }
   local bottom_right = { x = math.max(pos_1.x, pos_2.x), y = math.max(pos_1.y, pos_2.y) }
   return top_left, bottom_right
end

--Finds the nearest roboport
function mod.find_nearest_roboport(surf, pos, radius_in)
   local nearest = nil
   local min_dist = radius_in
   local ports = surf.find_entities_filtered({ name = "roboport", position = pos, radius = radius_in })
   for i, port in ipairs(ports) do
      local dist = math.ceil(util.distance(pos, port.position))
      if dist < min_dist then
         min_dist = dist
         nearest = port
      end
   end
   if nearest ~= nil then
      rendering.draw_circle({
         color = { 1, 1, 0 },
         radius = 4,
         width = 4,
         target = nearest.position,
         surface = surf,
         time_to_live = 90,
      })
   end
   return nearest, min_dist
end

function mod.table_concat(T1, T2)
   if T2 == nil then return end
   if T1 == nil then T1 = {} end
   for i, v in pairs(T2) do
      table.insert(T1, v)
   end
end

--Converts a dictionary into an iterable array.
function mod.get_iterable_array(dict)
   local result = {}
   for i, v in pairs(dict) do
      table.insert(result, v)
   end
   return result
end

--Converts an array into a lookup table based on the keys it has.
function mod.into_lookup(array)
   local lookup = {}
   for key, value in pairs(array) do
      lookup[value] = key
   end
   return lookup
end

--Reads the localised result for the distance and direction from one point to the other. Also mentions if they are precisely aligned. Distances are rounded.
function mod.dir_dist_locale(pos1, pos2)
   local dir_dist = mod.dir_dist(pos1, pos2)
   local aligned_note = ""
   if mod.is_direction_aligned(pos1, pos2) then aligned_note = "aligned " end
   return { "fa.dir-dist", aligned_note .. mod.direction_lookup(dir_dist[1]), math.floor(dir_dist[2] + 0.5) }
end

function mod.ent_name_locale(ent)
   if ent.name == "water" then
      print("todo: water isn't an entity")
      return { "gui-map-generator.water" }
   end
   if ent.name == "forest" then
      print("todo: forest isn't an entity")
      return { "fa.forest" }
   end
   local entity_prototype = prototypes.entity[ent.name]
   local resource_prototype = prototypes.resource_category[ent.name]
   local name = nil
   if ent.localised_name == nil and entity_prototype == nil and resource_prototype == nil then
      print("todo: " .. ent.name .. " is not an entity")
      name = ent.name .. " (localising error)"
   elseif ent.localised_name then
      name = ent.localised_name
   elseif entity_prototype then
      name = entity_prototype.localised_name
   elseif resource_prototype then
      name = resource_prototype.localised_name
   end
   return name
end

--Rounds down a number to the nearest thousand after 10 thousand, and nearest 100 thousand after 1 million.
function mod.simplify_large_number(num_in)
   local num = num_in
   num = math.ceil(num)
   if num > 10000 then num = 1000 * math.floor(num / 1000) end
   if num > 1000000 then num = 100000 * math.floor(num / 100000) end
   return num
end

--Returns a string to say the quantity of an item in terms of stacks, if there is at least one stack
function mod.express_in_stacks(count, stack_size, precise)
   local result = ""
   local new_count = "unknown amount of"
   local units = " units "
   if count == nil then
      count = 0
   elseif count == 0 then
      units = " units "
      new_count = "0"
   elseif count == 1 then
      units = " unit "
      new_count = "1"
   elseif count < stack_size then
      units = " units "
      new_count = tostring(count)
   elseif count == stack_size then
      units = " stack "
      new_count = "1"
   elseif count > stack_size then
      units = " stacks "
      new_count = tostring(math.floor(count / stack_size))
   end
   result = new_count .. units
   if precise and count > stack_size and count % stack_size > 0 then
      result = result .. " and " .. count % stack_size .. " units "
   end
   if count > 10000 then result = "infinite" end
   return result
end

function mod.sort_ents_by_distance_from_pos(pos, ents)
   table.sort(ents, function(k1, k2)
      if not k1 or not k1.valid then return true end
      if not k2 or not k2.valid then return false end
      return util.distance(pos, k1.position) < util.distance(pos, k2.position)
   end)
   return ents
end

--Checks a position to see if it has a water tile
function mod.tile_is_water(surface, pos)
   local water_tiles = surface.find_tiles_filtered({
      position = pos,
      radius = 0.1,
      name = Consts.WATER_TILE_NAMES,
   })
   return (water_tiles ~= nil and #water_tiles > 0)
end

--If the cursor is over a water tile, this function is called to check if it is open water or a shore.
function mod.identify_water_shores(pindex)
   local p = game.get_player(pindex)
   local water_tile_names = Consts.WATER_TILE_NAMES
   local vp = Viewpoint.get_viewpoint(pindex)
   local pos = vp:get_cursor_pos()
   draw_circle_at_position(p.surface, { x = pos.x, y = pos.y - 1 })
   draw_circle_at_position(p.surface, { x = pos.x, y = pos.y + 1 })
   draw_circle_at_position(p.surface, { x = pos.x - 1, y = pos.y })
   draw_circle_at_position(p.surface, { x = pos.x + 1, y = pos.y })

   local tile_north = #p.surface.find_tiles_filtered({
      position = { x = pos.x + 0, y = pos.y - 1 },
      radius = 0.1,
      name = water_tile_names,
   })
   local tile_south = #p.surface.find_tiles_filtered({
      position = { x = pos.x + 0, y = pos.y + 1 },
      radius = 0.1,
      name = water_tile_names,
   })
   local tile_east = #p.surface.find_tiles_filtered({
      position = { x = pos.x + 1, y = pos.y + 0 },
      radius = 0.1,
      name = water_tile_names,
   })
   local tile_west = #p.surface.find_tiles_filtered({
      position = { x = pos.x - 1, y = pos.y + 0 },
      radius = 0.1,
      name = water_tile_names,
   })

   if tile_north > 0 then tile_north = 1 end
   if tile_south > 0 then tile_south = 1 end
   if tile_east > 0 then tile_east = 1 end
   if tile_west > 0 then tile_west = 1 end

   local sum = tile_north + tile_south + tile_east + tile_west
   local result = " "
   if sum == 0 then
      result = " crevice pit "
   elseif sum == 1 then
      result = " crevice end "
   elseif sum == 2 and ((tile_north + tile_south == 2) or (tile_east + tile_west == 2)) then
      result = " crevice "
   elseif sum == 2 then
      result = " shore corner"
   elseif sum == 3 then
      result = " shore "
   elseif sum == 4 then
      result = " open "
   end
   return result
end

-- Concatenate a bunch of stuff together, efficiently, and return this as a
-- localised string.
--
-- Assumes that tables are localised strings, otherwise calls tostring(x)
--
-- Works with more than 20 items by folding the localised strings into each
-- other, forming a tree structure.
---@return LocalisedString
mod.spacecat = function(...)
   local tab = table.pack(...)
   return mod.localise_cat_table(tab)
end

-- Like spacecat but for a table, and with custom separator.
---@param tab any[]
---@param sep string? The separator, default space.
---@return LocalisedString
function mod.localise_cat_table(tab, sep)
   sep = sep or " "
   local will_cat = { "" }

   for i = 1, #tab do
      local ent = tab[i]
      local adding = type(ent) == "table" and ent or tostring(ent)
      if adding == nil then adding = "NIL!" end
      table.insert(will_cat, adding)
      -- Careful: shouldn't add after the last element.
      if tab[i + 1] then table.insert(will_cat, sep) end
   end

   -- 21 because 20 params, then the first is the "" part.
   while #will_cat > 21 do
      local new_cat = { "" }

      for i = 1, #will_cat, 20 do
         local seg = { "" }
         for j = 1, 20 do
            table.insert(seg, will_cat[i + j])
         end
         table.insert(new_cat, seg)
      end

      will_cat = new_cat
   end

   return will_cat
end

--Returns the name for the item related to the entity name being checked
function mod.get_item_name_for_ent(name)
   if name == "straight-rail" or name == "curved-rail" then return "rail" end
   return name
end

--Returns true only if this action was called within the last 10 seconds. Resets.
---@param pindex int player index
---@param id_string string used to check whether the same thing as last time is being checked
---@param custom_message string info about what action is being checked
---@return boolean to allow the action
function mod.confirm_action(pindex, id_string, custom_message)
   local message = custom_message or "Press again to confirm this action."
   --Check the id string
   if storage.players[pindex].confirm_action_id_string ~= id_string then
      storage.players[pindex].confirm_action_id_string = id_string
      storage.players[pindex].confirm_action_tick = game.tick
      require("scripts.speech").speak(pindex, message)
      return false
   end
   --Check the time stamp
   if
      storage.players[pindex].confirm_action_tick == nil
      or game.tick - storage.players[pindex].confirm_action_tick > 600
   then
      storage.players[pindex].confirm_action_tick = game.tick
      require("scripts.speech").speak(pindex, message)
      return false
   else
      storage.players[pindex].confirm_action_tick = 0
      return true
   end
end

-- Format a  number to e.g. "1.3m"
---@param amount number
---@return string
function mod.format_number(amount)
   local suffix = ""

   local suffix_list = {
      ["T"] = 1000000000000,
      ["B"] = 1000000000,
      ["M"] = 1000000,
      ["k"] = 1000,
   }
   for letter, limit in pairs(suffix_list) do
      if math.abs(amount) >= limit then
         amount = math.floor(amount / (limit / 10)) / 10
         suffix = letter
         break
      end
   end

   return tostring(amount) .. suffix
end

---@param point fa.Point
---@param box fa.AABB
---@return fa.Point?
function mod.closest_point_in_box(point, box)
   return {
      x = math.max(math.min(point.x, box.right_bottom.x), box.left_top.x),
      y = math.max(math.min(point.y, box.right_bottom.y), box.left_top.y),
   }
end

local ALL_PROTO_KINDS = {
   "item",
   "font",
   "map_gen_preset",
   "style",
   "entity",
   "fluid",
   "tile",
   "equipment",
   "damage",
   "virtual_signal",
   "equipment_grid",
   "recipe",
   "technology",
   "decorative",
   "particle",
   "autoplace_control",
   "mod_setting",
   "custom_input",
   "ammo_category",
   "named_noise_expression",
   "named_noise_function",
   "item_subgroup",
   "item_group",
   "fuel_category",
   "resource_category",
   "achievement",
   "module_category",
   "equipment_category",
   "trivial_smoke",
   "shortcut",
   "recipe_category",
   "quality",
   "surface_property",
   "space_location",
   "space_connection",
   "custom_event",
   "active_trigger",
   "asteroid_chunk",
   "collision_layer",
   "airborne_pollutant",
   "burner_usage",
   "surface",
   "procession",
   "procession_layer_inheritance_group",
}

-- In 2.0 all the prototypes got split up into separate attributes of
-- LuaPrototypes, but that's a userdata.  This function checks them all for a
-- prototype, because in some cases we don't know what it actually is.
---@param name string
---@return LuaPrototypeBase?
function mod.find_prototype(name)
   for _, f in pairs(ALL_PROTO_KINDS) do
      local p = prototypes[f]
      if p and p[name] then return p[name] end
   end

   return nil
end

-- Formats a power value in watts to a localized string
---@param power number Power value in watts
---@return LocalisedString
function mod.format_power(power)
   if power > 1000000000000 then
      return { "fa.unit-terawatts", string.format("%.1f", power / 1000000000000) }
   elseif power > 1000000000 then
      return { "fa.unit-gigawatts", string.format("%.1f", power / 1000000000) }
   elseif power > 1000000 then
      return { "fa.unit-megawatts", string.format("%.1f", power / 1000000) }
   elseif power > 1000 then
      return { "fa.unit-kilowatts", string.format("%.1f", power / 1000) }
   else
      return { "fa.unit-watts", string.format("%.1f", power) }
   end
end

-- Formats a distance with direction to a localized string
---@param distance number Distance in tiles
---@param direction string|number Direction name (e.g., "north", "south") or direction number
---@return LocalisedString
function mod.format_distance_with_direction(distance, direction)
   -- If direction is a string, we need to convert it to a number
   -- This is a temporary fix - ideally callers should pass the numeric direction
   if type(direction) == "string" then
      -- Try to convert string directions back to numbers
      local dir_map = {
         ["North"] = 0,
         ["NorthNorthEast"] = 1,
         ["NorthEast"] = 2,
         ["EastNorthEast"] = 3,
         ["East"] = 4,
         ["EastSouthEast"] = 5,
         ["SouthEast"] = 6,
         ["SouthSouthEast"] = 7,
         ["South"] = 8,
         ["SouthSouthWest"] = 9,
         ["SouthWest"] = 10,
         ["WestSouthWest"] = 11,
         ["West"] = 12,
         ["WestNorthWest"] = 13,
         ["NorthWest"] = 14,
         ["NorthNorthWest"] = 15,
      }
      direction = dir_map[direction] or 0
   end
   return { "fa.distance-tiles-direction", tostring(distance), { "fa.direction", direction } }
end

-- Builds a list with proper separators
---@param items table Array of LocalisedString or string items
---@param separator? LocalisedString Optional separator (defaults to comma-space)
---@param last_separator? LocalisedString Optional last separator (defaults to "and")
---@return LocalisedString
function mod.build_list(items, separator, last_separator)
   if #items == 0 then
      return ""
   elseif #items == 1 then
      return items[1]
   end

   separator = separator or { "", ", " }
   last_separator = last_separator or { "", " ", { "fa.list-and" }, " " }

   local result = { "", items[1] }
   for i = 2, #items - 1 do
      table.insert(result, separator)
      table.insert(result, items[i])
   end
   table.insert(result, last_separator)
   table.insert(result, items[#items])

   return result
end

-- Formats item count (e.g., "iron-plate x 100")
---@param item_name LocalisedString Item localized name
---@param count number Item count
---@return LocalisedString
function mod.format_item_count(item_name, count)
   return { "fa.item-count", item_name, tostring(count) }
end

-- Formats a slot state (empty, contains item, filtered, etc.)
---@param item_name? LocalisedString Item name if slot contains item
---@param count? number Item count if applicable
---@param is_filtered? boolean Whether slot is filtered
---@param filter_name? LocalisedString Filter name if filtered
---@return LocalisedString
function mod.format_slot_state(item_name, count, is_filtered, filter_name)
   if item_name then
      if is_filtered then
         return { "", { "fa.slot-filtered" }, " ", mod.format_item_count(item_name, count or 1) }
      else
         return mod.format_item_count(item_name, count or 1)
      end
   elseif is_filtered and filter_name then
      return { "fa.slot-empty-filtered", filter_name }
   else
      return { "fa.slot-empty" }
   end
end

-- Formats a position to a localized string (e.g., "at 10, 20")
---@param x number X coordinate
---@param y number Y coordinate
---@return LocalisedString
function mod.format_position(x, y)
   return { "fa.position-at", tostring(math.floor(x)), tostring(math.floor(y)) }
end

-- Formats a percentage value
---@param value number Value between 0 and 100
---@param suffix? string Optional suffix key (e.g., "complete", "full")
---@return LocalisedString
function mod.format_percentage(value, suffix)
   if suffix then
      return { "fa.percentage-with-suffix", tostring(math.floor(value)), { "fa.percentage-suffix-" .. suffix } }
   else
      return { "fa.percentage", tostring(math.floor(value)) }
   end
end

-- Formats a state/status string
---@param state_key string The state key to look up
---@param prefix? string Optional prefix for the locale key (defaults to "state")
---@return LocalisedString
function mod.format_state(state_key, prefix)
   prefix = prefix or "state"
   return { "fa." .. prefix .. "-" .. state_key }
end

-- Wave 5 formatting helpers
-- Formats a count with item name (no pluralization needed)
---@param count number The count to format
---@param item_name LocalisedString The item name
---@return LocalisedString
function mod.format_count(count, item_name)
   return { "fa.count-of-items", tostring(count), item_name }
end

-- Formats a distance value
---@param distance number Distance in tiles
---@param include_unit? boolean Whether to include "tiles" unit (default true)
---@return LocalisedString
function mod.format_distance(distance, include_unit)
   include_unit = include_unit == nil and true or include_unit
   if include_unit then
      return { "fa.distance-tiles", string.format("%.1f", distance) }
   else
      return tostring(math.floor(distance))
   end
end

-- Formats time from ticks to human-readable format
---@param ticks number Game ticks
---@return LocalisedString
function mod.format_time(ticks)
   local seconds = ticks / 60
   local minutes = seconds / 60
   local hours = minutes / 60

   if hours >= 1 then
      return { "fa.time-hours", string.format("%.1f", hours) }
   elseif minutes >= 1 then
      return { "fa.time-minutes", string.format("%.1f", minutes) }
   else
      return { "fa.time-seconds", string.format("%.1f", seconds) }
   end
end

-- Formats coordinates in a standard way
---@param x number X coordinate
---@param y number Y coordinate
---@param include_label? boolean Whether to include "coordinates" label (default true)
---@return LocalisedString
function mod.format_coordinates(x, y, include_label)
   include_label = include_label == nil and true or include_label
   if include_label then
      return { "fa.coordinates-labeled", tostring(math.floor(x)), tostring(math.floor(y)) }
   else
      return { "fa.coordinates", tostring(math.floor(x)), tostring(math.floor(y)) }
   end
end

return mod
