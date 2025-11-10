---Extract simplified turn table
---Each curved rail placement is part of exactly ONE 90-degree turn
---We just verify by turning left N times from one end, right M times from other end

require("polyfill")

local TestSurface = require("railutils.surface-impls.test-surface")
local Traverser = require("railutils.traverser")
local RailInfo = require("railutils.rail-info")
local Queries = require("railutils.queries")

---Build a 90-degree turn and extract verification info for each piece
---@param start_cardinal defines.direction Starting cardinal
---@param turn_dir number 1 for right turn, -1 for left turn
---@return table[] Array of verification info
local function extract_turn_verification(start_cardinal, turn_dir)
   local surface = TestSurface.new()

   -- Place starting straight rail
   local start_rail = surface:add_rail(RailInfo.RailType.STRAIGHT, { x = 0, y = 0 }, start_cardinal)

   -- Create traverser
   local ends = Queries.get_end_directions(start_rail.rail_type, start_rail.direction)
   local trav = Traverser.new(start_rail.rail_type, start_rail.prototype_position, start_rail.direction)

   -- Navigate to correct end
   if trav:get_direction() ~= start_cardinal then trav:flip_ends() end

   -- Build the 4 pieces
   local pieces = {}
   for i = 1, 4 do
      if turn_dir > 0 then
         trav:move_right()
      else
         trav:move_left()
      end

      local rail_type = trav:get_rail_kind()
      local placement_dir = trav:get_placement_direction()
      local position = trav:get_position()
      local current_end = trav:get_direction()

      -- For this piece, figure out verification params
      -- We're at position i out of 4 total
      -- From current end: turn in same direction (i-1) more times → finds remaining pieces
      -- From other end: turn opposite direction (4-i) times → finds previous pieces

      local piece_ends = Queries.get_end_directions(rail_type, placement_dir)
      local other_end = (piece_ends[1] == current_end) and piece_ends[2] or piece_ends[1]

      table.insert(pieces, {
         rail_type = rail_type,
         placement_dir = placement_dir,
         position = i == 1 and "top" or i == 2 and "upper-half" or i == 3 and "lower-half" or "bottom",
         -- From current end, continue in same direction to find remaining pieces
         verify_forward = { end_dir = current_end, turn_dir = turn_dir, count = 4 - i },
         -- From other end, go opposite direction to find previous pieces
         verify_back = { end_dir = other_end, turn_dir = -turn_dir, count = i - 1 },
      })
   end

   return pieces
end

---Direction names
local function cardinal_name(dir)
   return ({ [0] = "north", [4] = "east", [8] = "south", [12] = "west" })[dir] or "unknown"
end

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

-- Build only the 4 canonical turns (horizontal direction first)
local turns = {
   { from = defines.direction.east, to = defines.direction.north, turn = -1, name = "east-to-north" },
   { from = defines.direction.east, to = defines.direction.south, turn = 1, name = "east-to-south" },
   { from = defines.direction.west, to = defines.direction.north, turn = 1, name = "west-to-north" },
   { from = defines.direction.west, to = defines.direction.south, turn = -1, name = "west-to-south" },
}

print("-- Simplified Turn Table")
print("-- Each entry: position, from/to cardinals, and two verification paths")
print("")

-- Organize by rail type
local by_type = {
   [RailInfo.RailType.CURVE_A] = {},
   [RailInfo.RailType.CURVE_B] = {},
}

for _, turn_spec in ipairs(turns) do
   local pieces = extract_turn_verification(turn_spec.from, turn_spec.turn)

   print(string.format("Turn %s:", turn_spec.name))
   for i, piece in ipairs(pieces) do
      print(
         string.format(
            "  Piece %d: %s at dir=%d (%s)",
            i,
            piece.rail_type,
            piece.placement_dir,
            dir_to_name(piece.placement_dir)
         )
      )

      if not by_type[piece.rail_type][piece.placement_dir] then by_type[piece.rail_type][piece.placement_dir] = {} end
      table.insert(by_type[piece.rail_type][piece.placement_dir], {
         position = piece.position,
         from_cardinal = turn_spec.from,
         to_cardinal = turn_spec.to,
         verify_forward = piece.verify_forward,
         verify_back = piece.verify_back,
         turn_name = turn_spec.name,
      })
   end
end

-- Output
print('["curved-rail-a"] = {')
for dir = 0, 15 do
   if by_type[RailInfo.RailType.CURVE_A][dir] then
      print(string.format("   [defines.direction.%s] = {", dir_to_name(dir)))
      for _, entry in ipairs(by_type[RailInfo.RailType.CURVE_A][dir]) do
         print(string.format('      position = "%s", -- %s', entry.position, entry.turn_name))
         print(string.format("      from_cardinal = defines.direction.%s,", cardinal_name(entry.from_cardinal)))
         print(string.format("      to_cardinal = defines.direction.%s,", cardinal_name(entry.to_cardinal)))
         print(
            string.format(
               "      verify_forward = {end_dir = defines.direction.%s, turn_dir = %d, count = %d},",
               dir_to_name(entry.verify_forward.end_dir),
               entry.verify_forward.turn_dir,
               entry.verify_forward.count
            )
         )
         print(
            string.format(
               "      verify_back = {end_dir = defines.direction.%s, turn_dir = %d, count = %d},",
               dir_to_name(entry.verify_back.end_dir),
               entry.verify_back.turn_dir,
               entry.verify_back.count
            )
         )
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
         print(string.format('      position = "%s", -- %s', entry.position, entry.turn_name))
         print(string.format("      from_cardinal = defines.direction.%s,", cardinal_name(entry.from_cardinal)))
         print(string.format("      to_cardinal = defines.direction.%s,", cardinal_name(entry.to_cardinal)))
         print(
            string.format(
               "      verify_forward = {end_dir = defines.direction.%s, turn_dir = %d, count = %d},",
               dir_to_name(entry.verify_forward.end_dir),
               entry.verify_forward.turn_dir,
               entry.verify_forward.count
            )
         )
         print(
            string.format(
               "      verify_back = {end_dir = defines.direction.%s, turn_dir = %d, count = %d},",
               dir_to_name(entry.verify_back.end_dir),
               entry.verify_back.turn_dir,
               entry.verify_back.count
            )
         )
      end
      print("   },")
   end
end
print("},")
