local lu = require("luaunit")
require("polyfill")

local TestSurface = require("railutils.surface-impls.test-surface")
local RailDescriber = require("railutils.rail-describer")
local RailInfo = require("railutils.rail-info")
local Queries = require("railutils.queries")
local Traverser = require("railutils.traverser")

local mod = {}

---Generate all 16 permutations of 4 boolean values
---@return table<number, boolean[]> Array of 16 permutations, each is array of 4 booleans
local function generate_permutations()
   local permutations = {}
   for i = 0, 15 do
      local perm = {
         (i % 2) == 1, -- bit 0
         (math.floor(i / 2) % 2) == 1, -- bit 1
         (math.floor(i / 4) % 2) == 1, -- bit 2
         (math.floor(i / 8) % 2) == 1, -- bit 3
      }
      table.insert(permutations, perm)
   end
   return permutations
end

---Build a turn using traverser and get all 4 pieces
---@param start_pos fa.Point Starting position for the traverser (chosen to avoid grid adjustment)
---@param start_dir defines.direction Starting direction
---@param navigate_func function Function to navigate to the starting cardinal (called once)
---@param turn_func function Function to turn (called 4 times)
---@return table[] Array of 4 pieces with rail_type, placement_direction, position
local function get_turn_pieces(start_pos, start_dir, navigate_func, turn_func)
   local trav = Traverser.new(RailInfo.RailType.STRAIGHT, start_pos, start_dir)
   local pieces = {}

   -- Navigate to starting position
   navigate_func(trav)

   -- Collect the 4 turn pieces
   for i = 1, 4 do
      turn_func(trav)
      table.insert(pieces, {
         rail_type = trav:get_rail_kind(),
         placement_direction = trav:get_placement_direction(),
         position = trav:get_position(), -- Use traverser position directly
      })
   end

   return pieces
end

---Test that a piece only detects the turn when all 4 pieces are present
---@param pieces table[] The 4 pieces of the turn
---@param piece_index number Which piece to test (1-4)
---@param turn_name string Name of the turn for error messages
local function test_piece_detection(pieces, piece_index, turn_name)
   local permutations = generate_permutations()
   local test_piece = pieces[piece_index]

   for perm_index, perm in ipairs(permutations) do
      local surface = TestSurface.new()

      -- Add pieces according to permutation
      for i, present in ipairs(perm) do
         if present then
            surface:add_rail(pieces[i].rail_type, pieces[i].position, pieces[i].placement_direction)
         end
      end

      -- Can only query if the test piece is present
      if not perm[piece_index] then
         -- Skip querying a piece that doesn't exist
         goto continue
      end

      -- Try to classify the test piece
      local desc = RailDescriber.describe_rail(
         surface,
         test_piece.rail_type,
         test_piece.placement_direction,
         test_piece.position
      )

      -- Should only detect turn when all 4 pieces are present
      local all_present = perm[1] and perm[2] and perm[3] and perm[4]
      local detected_turn = desc.kind:find("-turn", 1, true) ~= nil

      if all_present then
         lu.assertTrue(
            detected_turn,
            string.format(
               "%s piece %d (perm %d): should detect turn when all present, got: %s",
               turn_name,
               piece_index,
               perm_index,
               desc.kind
            )
         )
         -- Verify it's detecting the correct turn
         lu.assertTrue(
            desc.kind:find(turn_name, 1, true) ~= nil,
            string.format(
               "%s piece %d (perm %d): detected wrong turn, got: %s",
               turn_name,
               piece_index,
               perm_index,
               desc.kind
            )
         )
      else
         lu.assertFalse(
            detected_turn,
            string.format(
               "%s piece %d (perm %d [%s,%s,%s,%s]): should NOT detect turn when pieces missing, got: %s",
               turn_name,
               piece_index,
               perm_index,
               perm[1] and "1" or "-",
               perm[2] and "2" or "-",
               perm[3] and "3" or "-",
               perm[4] and "4" or "-",
               desc.kind
            )
         )
      end

      ::continue::
   end
end

function mod.TestTurnDetection_EastToNorth()
   -- Start at {1, 1} facing east, then turn left 4 times
   local pieces = get_turn_pieces(
      { x = 1, y = 1 },
      defines.direction.east,
      function(t) end, -- No navigation needed
      function(t)
         t:move_left()
      end -- Turn left
   )

   for piece_index = 1, 4 do
      test_piece_detection(pieces, piece_index, "east-to-north")
   end
end

function mod.TestTurnDetection_EastToSouth()
   -- Start at {1, 1} facing east, then turn right 4 times
   local pieces = get_turn_pieces(
      { x = 1, y = 1 },
      defines.direction.east,
      function(t) end, -- No navigation needed
      function(t)
         t:move_right()
      end -- Turn right
   )

   for piece_index = 1, 4 do
      test_piece_detection(pieces, piece_index, "east-to-south")
   end
end

function mod.TestTurnDetection_WestToNorth()
   -- Start at {1, 1} facing west, then turn right 4 times
   local pieces = get_turn_pieces(
      { x = 1, y = 1 },
      defines.direction.west,
      function(t) end, -- No navigation needed
      function(t)
         t:move_right()
      end -- Turn right
   )

   for piece_index = 1, 4 do
      test_piece_detection(pieces, piece_index, "west-to-north")
   end
end

function mod.TestTurnDetection_WestToSouth()
   -- Start at {1, 1} facing west, then turn left 4 times
   local pieces = get_turn_pieces(
      { x = 1, y = 1 },
      defines.direction.west,
      function(t) end, -- No navigation needed
      function(t)
         t:move_left()
      end -- Turn left
   )

   for piece_index = 1, 4 do
      test_piece_detection(pieces, piece_index, "west-to-south")
   end
end

return mod
