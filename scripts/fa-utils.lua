--Here: Utility functions called by other files. Examples include distance and position calculations, string processing.
local util = require("util")
local dirs = defines.direction

local mod = {}

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

function mod.offset_position(oldpos, direction, distance)
   if direction == defines.direction.north then
      return { x = oldpos.x, y = oldpos.y - distance }
   elseif direction == defines.direction.south then
      return { x = oldpos.x, y = oldpos.y + distance }
   elseif direction == defines.direction.east then
      return { x = oldpos.x + distance, y = oldpos.y }
   elseif direction == defines.direction.west then
      return { x = oldpos.x - distance, y = oldpos.y }
   elseif direction == defines.direction.northwest then
      return { x = oldpos.x - distance, y = oldpos.y - distance }
   elseif direction == defines.direction.northeast then
      return { x = oldpos.x + distance, y = oldpos.y - distance }
   elseif direction == defines.direction.southwest then
      return { x = oldpos.x - distance, y = oldpos.y + distance }
   elseif direction == defines.direction.southeast then
      return { x = oldpos.x + distance, y = oldpos.y + distance }
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

--[[
* Returns the direction of that entity from this entity, with each of 8 directions getting equal representation.
* Returns 1 of 8 main directions, based on the ratios of the x and y distances. 
* The deciding ratio is 1 to 2.5, meaning that for an object that is 25 tiles north, it can be offset by up to 10 tiles east or west before it stops being counted as "directly" in the north. 
* The arctangent of 1/2.5 is about 22 degrees, meaning that the field of view that directly counts as a cardinal direction is about 44 degrees, while for a diagonal direction it is about 46 degrees.]]
function mod.get_direction_precise(pos_target, pos_origin)
   local diff_x = pos_target.x - pos_origin.x
   local diff_y = pos_target.y - pos_origin.y
   ---@type defines.direction
   local dir = defines.direction.north

   if math.abs(diff_x) > 2.5 * math.abs(diff_y) then --along east-west
      if diff_x > 0 then
         dir = defines.direction.east
      else
         dir = defines.direction.west
      end
   elseif math.abs(diff_y) > 2.5 * math.abs(diff_x) then --along north-south
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
   if dir >= dirs.north and dir <= dirs.northwest then
      return game.direction_to_string(dir)
   else
      if dir == 8 then --Returned by the game when there is no direction in particular
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
   players[pindex].building_direction = dirs.north
end

--Converts the entity orientation value to a heading direction string, with all directions having equal bias.
function mod.get_heading_info(ent)
   ---@diagnostic disable: cast-local-type
   local heading = "unknown"
   if ent == nil then return "nil error" end
   local ori = ent.orientation
   if ori < 0.0625 then
      heading = mod.direction_lookup(dirs.north)
   elseif ori < 0.1875 then
      heading = mod.direction_lookup(dirs.northeast)
   elseif ori < 0.3125 then
      heading = mod.direction_lookup(dirs.east)
   elseif ori < 0.4375 then
      heading = mod.direction_lookup(dirs.southeast)
   elseif ori < 0.5625 then
      heading = mod.direction_lookup(dirs.south)
   elseif ori < 0.6875 then
      heading = mod.direction_lookup(dirs.southwest)
   elseif ori < 0.8125 then
      heading = mod.direction_lookup(dirs.west)
   elseif ori < 0.9375 then
      heading = mod.direction_lookup(dirs.northwest)
   else
      heading = mod.direction_lookup(dirs.north) --default
   end
   return heading
end

--Converts the entity orientation into a heading direction, with all directions having equal bias.
function mod.get_heading_value(ent)
   local heading = nil
   if ent == nil then return nil end
   local ori = ent.orientation
   if ori < 0.0625 then
      heading = dirs.north
   elseif ori < 0.1875 then
      heading = dirs.northeast
   elseif ori < 0.3125 then
      heading = dirs.east
   elseif ori < 0.4375 then
      heading = dirs.southeast
   elseif ori < 0.5625 then
      heading = dirs.south
   elseif ori < 0.6875 then
      heading = dirs.southwest
   elseif ori < 0.8125 then
      heading = dirs.west
   elseif ori < 0.9375 then
      heading = dirs.northwest
   else
      heading = dirs.north --default
   end
   return heading
end

--Returns the length and width of the entity version of an item.
function mod.get_tile_dimensions(item, dir)
   if item.place_result ~= nil then
      local dimensions = item.place_result.selection_box
      x = math.ceil(dimensions.right_bottom.x - dimensions.left_top.x)
      y = math.ceil(dimensions.right_bottom.y - dimensions.left_top.y)
      if dir == dirs.north or dir == dirs.south then
         return { x = x, y = y }
      else
         return { x = y, y = x }
      end
   end
   return { x = 0, y = 0 }
end

--Small utility function for getting an entity's footprint area using just its name.
function mod.get_ent_area_from_name(ent_name, pindex)
   -- local ents = game.get_player(pindex).surface.find_entities_filtered{name = ent_name, limit = 1}
   -- if #ents == 0 then
   -- return -1
   -- else
   -- return ents[1].tile_height * ents[1].tile_width
   -- end
   return game.entity_prototypes[ent_name].tile_width * game.entity_prototypes[ent_name].tile_height
end

--Returns true/false on whether an entity is located within a defined area.
function mod.is_ent_inside_area(ent_name, area_left_top, area_right_bottom, pindex)
   local ents = game
      .get_player(pindex).surface
      .find_entities_filtered({ name = ent_name, area = { area_left_top, area_right_bottom }, limit = 1 })
   return #ents > 0
end

--Returns the map position of the northwest corner of an entity.
--NOTE: If the calculation result gives a tile that does not touch the ent, then the ent's own position is returned instead.
--TODO fix the calculation (several attempts have failed so far because fixing it for one group of ents breaks it for others).
function mod.get_ent_northwest_corner_position(ent)
   if ent.valid == false or ent.tile_width == nil then return ent.position end
   local width = ent.tile_width
   local height = ent.tile_height
   if ent.direction == dirs.east or ent.direction == dirs.west then
      width = ent.tile_height
      height = ent.tile_width
   end
   local pos = mod.center_of_tile({
      x = ent.position.x - math.floor(width / 2),
      y = ent.position.y - math.floor(height / 2),
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
   local x = players[pindex].cursor_pos.x
   local y = players[pindex].cursor_pos.y
   local ents = players[pindex].tile.ents
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
      if preferred_ent == nil or preferred_ent.valid == false then preferred_ent = get_first_ent_at_tile(pindex) end
      if preferred_ent == nil or preferred_ent.valid == false then return "unknown location" end

      --Report which part of the entity the cursor covers.
      rendering.draw_circle({
         color = { 1, 0.0, 0.5 },
         radius = 0.1,
         width = 2,
         target = { x = x + 0, y = y - 1 },
         surface = p.surface,
         time_to_live = 30,
      })
      rendering.draw_circle({
         color = { 1, 0.0, 0.5 },
         radius = 0.1,
         width = 2,
         target = { x = x + 0, y = y + 1 },
         surface = p.surface,
         time_to_live = 30,
      })
      rendering.draw_circle({
         color = { 1, 0.0, 0.5 },
         radius = 0.1,
         width = 2,
         target = { x = x - 1, y = y - 0 },
         surface = p.surface,
         time_to_live = 30,
      })
      rendering.draw_circle({
         color = { 1, 0.0, 0.5 },
         radius = 0.1,
         width = 2,
         target = { x = x + 1, y = y - 0 },
         surface = p.surface,
         time_to_live = 30,
      })

      local ent_north =
         p.surface.find_entities_filtered({ position = { x = x, y = y - 1 }, name = EXCLUDED_ENT_NAMES, invert = true })
      if #ent_north > 0 and ent_north[1].unit_number == preferred_ent.unit_number then
         north_same = true
      elseif #ent_north > 1 and ent_north[2].unit_number == preferred_ent.unit_number then
         north_same = true
      elseif #ent_north > 2 and ent_north[3].unit_number == preferred_ent.unit_number then
         north_same = true
      end
      local ent_south =
         p.surface.find_entities_filtered({ position = { x = x, y = y + 1 }, name = EXCLUDED_ENT_NAMES, invert = true })
      if #ent_south > 0 and ent_south[1].unit_number == preferred_ent.unit_number then
         south_same = true
      elseif #ent_south > 1 and ent_south[2].unit_number == preferred_ent.unit_number then
         south_same = true
      elseif #ent_south > 2 and ent_south[3].unit_number == preferred_ent.unit_number then
         south_same = true
      end
      local ent_east =
         p.surface.find_entities_filtered({ position = { x = x + 1, y = y }, name = EXCLUDED_ENT_NAMES, invert = true })
      if #ent_east > 0 and ent_east[1].unit_number == preferred_ent.unit_number then
         east_same = true
      elseif #ent_east > 1 and ent_east[2].unit_number == preferred_ent.unit_number then
         east_same = true
      elseif #ent_east > 2 and ent_east[3].unit_number == preferred_ent.unit_number then
         east_same = true
      end
      local ent_west =
         p.surface.find_entities_filtered({ position = { x = x - 1, y = y }, name = EXCLUDED_ENT_NAMES, invert = true })
      if #ent_west > 0 and ent_west[1].unit_number == preferred_ent.unit_number then
         west_same = true
      elseif #ent_west > 1 and ent_west[2].unit_number == preferred_ent.unit_number then
         west_same = true
      elseif #ent_west > 2 and ent_west[3].unit_number == preferred_ent.unit_number then
         west_same = true
      end

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

--For a list of edge points of an aggregate entity, returns the nearest one.
function mod.nearest_edge(edges, pos, name)
   local pos = table.deepcopy(pos)
   if name == "forest" then
      pos.x = pos.x / 8
      pos.y = pos.y / 8
   end
   local result = {}
   local min = math.huge
   for str, b in pairs(edges) do
      local edge_pos = mod.str2pos(str)
      local d = util.distance(pos, edge_pos)
      if d < min then
         result = edge_pos
         min = d
      end
   end
   if name == "forest" then
      result.x = result.x * 8 - 4
      result.y = result.y * 8 - 4
   end
   return result
end

--Checks whether a rectangle defined by the two points falls fully within the rectangular range value
function mod.is_rectangle_fully_within_player_range(pindex, left_top, right_bottom, range)
   local pos = game.get_player(pindex).position
   if math.abs(left_top.x - pos.x) > range then return false end
   if math.abs(left_top.y - pos.y) > range then return false end
   if math.abs(right_bottom.x - pos.x) > range then return false end
   if math.abs(right_bottom.y - pos.y) > range then return false end
   return true
end

function mod.scale_area(area, factor)
   result = table.deepcopy(area)
   result.left_top.x = area.left_top.x * factor
   result.left_top.y = area.left_top.y * factor
   result.right_bottom.x = area.right_bottom.x * factor
   result.right_bottom.y = area.right_bottom.y * factor
   return result
end

--Checks whether a given position is at the edge of an area, in the selected direction
function mod.area_edge(area, dir, pos, name)
   local adjusted_area = table.deepcopy(area)
   if name == "forest" then
      local chunk_size = 8
      adjusted_area.left_top.x = adjusted_area.left_top.x / chunk_size
      adjusted_area.left_top.y = adjusted_area.left_top.y / chunk_size
      adjusted_area.right_bottom.x = adjusted_area.right_bottom.x / chunk_size
      adjusted_area.right_bottom.y = adjusted_area.right_bottom.y / chunk_size
   end
   if dir == dirs.north then
      if adjusted_area.left_top.y == math.floor(pos.y) then
         return true
      else
         return false
      end
   elseif dir == dirs.east then
      if adjusted_area.right_bottom.x == math.ceil(0.001 + pos.x) then
         return true
      else
         return false
      end
   elseif dir == dirs.south then
      if adjusted_area.right_bottom.y == math.ceil(0.001 + pos.y) then
         return true
      else
         return false
      end
   elseif dir == dirs.west then
      if adjusted_area.left_top.x == math.floor(pos.x) then
         return true
      else
         return false
      end
   end
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

function mod.pos2str(pos)
   return pos.x .. " " .. pos.y
end

function mod.str2pos(str)
   local t = {}
   for s in string.gmatch(str, "([^%s]+)") do
      table.insert(t, s)
   end
   return { x = t[1], y = t[2] }
end

function mod.breakup_string(str)
   result = { "" }
   if table_size(str) > 20 then
      local i = 0
      while i < #str do
         if i % 20 == 0 then table.insert(result, { "" }) end
         ---@diagnostic disable-next-line: param-type-mismatch
         table.insert(result[math.ceil((i + 1) / 20) + 1], table.deepcopy(str[i + 1]))
         i = i + 1
      end
      return result
   else
      return str
   end
end

--Converts a dictionary into an iterable array.
function mod.get_iterable_array(dict)
   result = {}
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

--Returns the part of a substring before a space character. BUG: Breaks when parsing dashes.
function mod.get_substring_before_space(str)
   local first, final = string.find(str, " ")
   if first == nil or first == 1 then --No space, or space at the start only
      return str
   else
      return string.sub(str, 1, first - 1)
   end
end

--Returns the part of a substring after a space character. BUG: Breaks when parsing dashes.
function mod.get_substring_after_space(str)
   local first, final = string.find(str, " ")
   if final == nil then --No spaces
      return str
   end
   if first == 1 then --spaces at start only
      return string.sub(str, final + 1, string.len(str))
   end

   if final == string.len(str) then --space at the end only?
      return str
   end

   return string.sub(str, final + 1, string.len(str))
end

--Returns the part of a substring before a comma character. BUG: Breaks when parsing dashes.
function mod.get_substring_before_comma(str)
   local first, final = string.find(str, ",")
   if first == nil or first == 1 then
      return str
   else
      return string.sub(str, 1, first - 1)
   end
end

function mod.get_substring_before_dash(str)
   local first, final = string.find(str, "-")
   if first == nil or first == 1 then
      return str
   else
      return string.sub(str, 1, first - 1)
   end
end

--Reads the localised result for the distance and direction from one point to the other. Also mentions if they are precisely aligned. Distances are rounded.
function mod.dir_dist_locale(pos1, pos2)
   local dir_dist = mod.dir_dist(pos1, pos2)
   local aligned_note = ""
   if mod.is_direction_aligned(pos1, pos2) then aligned_note = "aligned " end
   return { "access.dir-dist", aligned_note .. mod.direction_lookup(dir_dist[1]), math.floor(dir_dist[2] + 0.5) }
end

function mod.ent_name_locale(ent)
   if ent.name == "water" then
      print("todo: water isn't an entity")
      return { "gui-map-generator.water" }
   end
   if ent.name == "forest" then
      print("todo: forest isn't an entity")
      return { "access.forest" }
   end
   local entity_prototype = game.entity_prototypes[ent.name]
   local resource_prototype = game.resource_category_prototypes[ent.name]
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

--small utility function for getting the index of a named object from an array of objects.
function mod.index_of_entity(array, value)
   if next(array) == nil then return nil end
   for i = 1, #array, 1 do
      if array[i].name == value then return i end
   end
   return nil
end

--Returns the first found item prototype in the currently selected crafting menu slot, if any. Else returns nil.
function mod.get_prototype_of_item_product(pindex)
   local recipe =
      players[pindex].crafting.lua_recipes[players[pindex].crafting.category][players[pindex].crafting.index]
   if recipe and recipe.valid and recipe.products and recipe.products[1] then
      for i, product in ipairs(recipe.products) do
         local prototype = nil
         if product.type == "item" then
            --Select product item #1
            prototype = game.item_prototypes[product.name]
            if prototype then return prototype end
         end
      end
   end
   return nil
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

function mod.factorio_default_sort(k1, k2)
   if k1.group.order ~= k2.group.order then
      return k1.group.order < k2.group.order
   elseif k1.subgroup.order ~= k2.subgroup.order then
      return k1.subgroup.order < k2.subgroup.order
   elseif k1.order ~= k2.order then
      return k1.order < k2.order
   else
      return k1.name < k2.name
   end
end

function mod.sort_ents_by_distance_from_pos(pos, ents)
   table.sort(ents, function(k1, k2)
      if k1 == nil or k1.valid == false then return true end
      if k2 == nil or k2.valid == false then return false end
      return util.distance(pos, k1.position) < util.distance(pos, k2.position)
   end)
   return ents
end

--Checks a position to see if it has a water tile
function mod.tile_is_water(surface, pos)
   local water_tiles = surface.find_tiles_filtered({
      position = pos,
      radius = 0.1,
      name = {
         "water",
         "deepwater",
         "water-green",
         "deepwater-green",
         "water-shallow",
         "water-mud",
         "water-wube",
      },
   })
   return (water_tiles ~= nil and #water_tiles > 0)
end

--If the cursor is over a water tile, this function is called to check if it is open water or a shore.
function mod.identify_water_shores(pindex)
   local p = game.get_player(pindex)
   local water_tile_names =
      { "water", "deepwater", "water-green", "deepwater-green", "water-shallow", "water-mud", "water-wube" }
   local pos = players[pindex].cursor_pos
   rendering.draw_circle({
      color = { 1, 0.0, 0.5 },
      radius = 0.1,
      width = 2,
      target = { x = pos.x + 0, y = pos.y - 1 },
      surface = p.surface,
      time_to_live = 30,
   })
   rendering.draw_circle({
      color = { 1, 0.0, 0.5 },
      radius = 0.1,
      width = 2,
      target = { x = pos.x + 0, y = pos.y + 1 },
      surface = p.surface,
      time_to_live = 30,
   })
   rendering.draw_circle({
      color = { 1, 0.0, 0.5 },
      radius = 0.1,
      width = 2,
      target = { x = pos.x - 1, y = pos.y - 0 },
      surface = p.surface,
      time_to_live = 30,
   })
   rendering.draw_circle({
      color = { 1, 0.0, 0.5 },
      radius = 0.1,
      width = 2,
      target = { x = pos.x + 1, y = pos.y - 0 },
      surface = p.surface,
      time_to_live = 30,
   })

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

--Checks whether the player has not walked for 1 second. Uses the bump alert checks.
function mod.player_was_still_for_1_second(pindex)
   local b = players[pindex].bump
   if b == nil or b.filled ~= true then
      --It is too soon to report anything
      return false
   end
   local diff_x1 = math.abs(b.last_pos_1.x - b.last_pos_2.x)
   local diff_x2 = math.abs(b.last_pos_2.x - b.last_pos_3.x)
   local diff_x3 = math.abs(b.last_pos_3.x - b.last_pos_4.x)
   local diff_y1 = math.abs(b.last_pos_1.y - b.last_pos_2.y)
   local diff_y2 = math.abs(b.last_pos_2.y - b.last_pos_3.y)
   local diff_y3 = math.abs(b.last_pos_3.y - b.last_pos_4.y)
   if (diff_x1 + diff_x2 + diff_x3 + diff_y1 + diff_y2 + diff_y3) == 0 then
      --Confirmed no movement in the past 60 ticks
      return true
   else
      --Confirmed some movement in the past 60 ticks
      return false
   end
end

-- Given a list of items which may be stringified, concatenate them all together
-- with a space between, efficiently.
mod.spacecat = function(...)
   local tab = table.pack(...)
   local will_cat = {}

   for i = 1, tab.n do
      local ent = tab[i]
      local stringified = tostring(ent)
      if stringified == nil then stringified = "NIL!" end
      table.insert(will_cat, stringified)
   end

   return table.concat(will_cat, " ")
end

--Returns the name for the item related to the entity name being checked
function mod.get_item_name_for_ent(name)
   if name == "straight-rail" or name == "curved-rail" then return "rail" end
   return name
end

--Returns true only if this action was called within the last 10 seconds. Resets.
function mod.confirm_action(pindex, custom_message)
   local message = custom_message or "Press again to confirm this action."
   if players[pindex].confirm_action_tick == nil or game.tick - players[pindex].confirm_action_tick > 600 then
      printout(message, pindex)
      players[pindex].confirm_action_tick = game.tick
      return false
   else
      players[pindex].confirm_action_tick = 1
      return true
   end
end

return mod
