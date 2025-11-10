---Extract turn table by building turns with Traverser
require("polyfill")

local TestSurface = require("railutils.surface-impls.test-surface")
local Traverser = require("railutils.traverser")
local RailInfo = require("railutils.rail-info")
local Queries = require("railutils.queries")

---Build a 90-degree turn and extract all piece placements
---@param start_cardinal defines.direction Starting cardinal (0=north, 4=east, 8=south, 12=west)
---@param turn_dir number 1 for right turn, -1 for left turn
---@return table[] Array of {rail_type, placement_direction, position}
local function build_and_extract_turn(start_cardinal, turn_dir)
   local surface = TestSurface.new()

   -- Place starting straight rail
   local start_rail = surface:add_rail(RailInfo.RailType.STRAIGHT, { x = 0, y = 0 }, start_cardinal)

   -- Create traverser at the end pointing in start_cardinal direction
   local ends = Queries.get_end_directions(start_rail.rail_type, start_rail.direction)
   local end_dir = ends[1] == start_cardinal and ends[1] or ends[2]

   local trav = Traverser.new(start_rail.rail_type, start_rail.prototype_position, start_rail.direction)

   -- Navigate to the correct end
   if trav:get_direction() ~= end_dir then trav:flip_ends() end

   -- Build the turn by turning 4 times (each 22.5 degrees = 90 total)
   local pieces = {}

   for i = 1, 4 do
      -- Turn in the specified direction
      if turn_dir > 0 then
         trav:move_right()
      else
         trav:move_left()
      end

      -- Get the current state after moving
      local rail_type = trav:get_rail_kind()
      local placement_dir = trav:get_placement_direction()
      local position = trav:get_position()
      local current_end = trav:get_direction() -- Which end we're at after the move

      -- Place the rail on surface
      surface:add_rail(rail_type, position, placement_dir)

      -- Record the piece including which end we're at
      table.insert(pieces, {
         rail_type = rail_type,
         placement_direction = placement_dir,
         position = position,
         current_end = current_end,
      })
   end

   return pieces
end

---Determine position label (top, upper-half, lower-half, bottom)
---@param index number 1-4, where 1 is first piece after starting rail
---@return string
local function get_position_label(index)
   if index == 1 then
      return "top"
   elseif index == 2 then
      return "upper-half"
   elseif index == 3 then
      return "lower-half"
   elseif index == 4 then
      return "bottom"
   end
   return "unknown"
end

---Convert direction number to name
---@param dir defines.direction
---@return string
local function dir_to_name(dir)
   local names = {
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
   return names[dir] or "unknown"
end

---Get cardinal name
---@param dir defines.direction
---@return string
local function cardinal_name(dir)
   return ({ [0] = "north", [4] = "east", [8] = "south", [12] = "west" })[dir] or "unknown"
end

-- Build all 8 turns
local turns = {
   { from = defines.direction.north, to = defines.direction.east, turn = 1, name = "north-to-east" },
   { from = defines.direction.north, to = defines.direction.west, turn = -1, name = "north-to-west" },
   { from = defines.direction.east, to = defines.direction.south, turn = 1, name = "east-to-south" },
   { from = defines.direction.east, to = defines.direction.north, turn = -1, name = "east-to-north" },
   { from = defines.direction.south, to = defines.direction.west, turn = 1, name = "south-to-west" },
   { from = defines.direction.south, to = defines.direction.east, turn = -1, name = "south-to-east" },
   { from = defines.direction.west, to = defines.direction.north, turn = 1, name = "west-to-north" },
   { from = defines.direction.west, to = defines.direction.south, turn = -1, name = "west-to-south" },
}

print("-- Generated Turn Table")
print("-- Organized by rail type, then placement direction")
print("")

-- Organize by rail type
local by_type = {
   [RailInfo.RailType.CURVE_A] = {},
   [RailInfo.RailType.CURVE_B] = {},
}

for _, turn_spec in ipairs(turns) do
   local pieces = build_and_extract_turn(turn_spec.from, turn_spec.turn)

   for i, piece in ipairs(pieces) do
      local pos_label = get_position_label(i)

      -- For verification: start from the end we're at, continue in turn direction
      -- This will traverse through the remaining pieces of the turn
      local verify_end = piece.current_end
      local verify_dir = turn_spec.turn -- 1 for right, -1 for left

      local entry = {
         position = pos_label,
         from_cardinal = turn_spec.from,
         to_cardinal = turn_spec.to,
         placement_direction = piece.placement_direction,
         verify_end = verify_end,
         verify_dir = verify_dir,
         turn_name = turn_spec.name,
      }

      if not by_type[piece.rail_type][piece.placement_direction] then
         by_type[piece.rail_type][piece.placement_direction] = {}
      end
      table.insert(by_type[piece.rail_type][piece.placement_direction], entry)
   end
end

-- Output organized table
print('["curved-rail-a"] = {')
for dir = 0, 15 do
   if by_type[RailInfo.RailType.CURVE_A][dir] then
      print(string.format("   [defines.direction.%s] = {", dir_to_name(dir)))
      for _, entry in ipairs(by_type[RailInfo.RailType.CURVE_A][dir]) do
         print(string.format("      { -- %s", entry.turn_name))
         print(string.format('         position = "%s",', entry.position))
         print(string.format("         from_cardinal = defines.direction.%s,", cardinal_name(entry.from_cardinal)))
         print(string.format("         to_cardinal = defines.direction.%s,", cardinal_name(entry.to_cardinal)))
         print(string.format("         verify_end = defines.direction.%s,", dir_to_name(entry.verify_end)))
         print(string.format("         verify_dir = %d,", entry.verify_dir))
         print("      },")
      end
      print("   },")
   end
end
print("},")
print("")
print('["curved-rail-b"] = {')
for dir = 0, 15 do
   if by_type[RailInfo.RailType.CURVE_B][dir] then
      print(string.format("   [defines.direction.%s] = {", dir_to_name(dir)))
      for _, entry in ipairs(by_type[RailInfo.RailType.CURVE_B][dir]) do
         print(string.format("      { -- %s", entry.turn_name))
         print(string.format('         position = "%s",', entry.position))
         print(string.format("         from_cardinal = defines.direction.%s,", cardinal_name(entry.from_cardinal)))
         print(string.format("         to_cardinal = defines.direction.%s,", cardinal_name(entry.to_cardinal)))
         print(string.format("         verify_end = defines.direction.%s,", dir_to_name(entry.verify_end)))
         print(string.format("         verify_dir = %d,", entry.verify_dir))
         print("      },")
      end
      print("   },")
   end
end
print("},")
