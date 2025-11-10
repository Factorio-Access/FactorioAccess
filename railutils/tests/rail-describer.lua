local lu = require("luaunit")
require("polyfill")

local TestSurface = require("railutils.surface-impls.test-surface")
local RailDescriber = require("railutils.rail-describer")
local RailInfo = require("railutils.rail-info")
local Queries = require("railutils.queries")
local Traverser = require("railutils.traverser")

local mod = {}

function mod.TestDescriber_VerticalRail()
   local surface = TestSurface.new()

   -- Place a vertical rail (straight north/south)
   surface:add_rail(RailInfo.RailType.STRAIGHT, { x = 0, y = 0 }, defines.direction.north)

   local pos = Queries.get_adjusted_position(RailInfo.RailType.STRAIGHT, { x = 0, y = 0 }, defines.direction.north)
   local desc = RailDescriber.describe_rail(surface, RailInfo.RailType.STRAIGHT, defines.direction.north, pos)

   lu.assertEquals(desc.kind, "vertical")
   lu.assertTrue(desc.lonely, "Single rail should be lonely")
   lu.assertEquals(#desc.forks, 0)
end

function mod.TestDescriber_HorizontalRail()
   local surface = TestSurface.new()

   -- Place a horizontal rail (straight east/west)
   surface:add_rail(RailInfo.RailType.STRAIGHT, { x = 0, y = 0 }, defines.direction.east)

   local pos = Queries.get_adjusted_position(RailInfo.RailType.STRAIGHT, { x = 0, y = 0 }, defines.direction.east)
   local desc = RailDescriber.describe_rail(surface, RailInfo.RailType.STRAIGHT, defines.direction.east, pos)

   lu.assertEquals(desc.kind, "horizontal")
   lu.assertTrue(desc.lonely, "Single rail should be lonely")
end

function mod.TestDescriber_HalfDiagonalRail()
   local surface = TestSurface.new()

   -- Place a northnortheast rail
   surface:add_rail(RailInfo.RailType.HALF_DIAGONAL, { x = 0, y = 0 }, defines.direction.northeast)

   local pos =
      Queries.get_adjusted_position(RailInfo.RailType.HALF_DIAGONAL, { x = 0, y = 0 }, defines.direction.northeast)
   local desc = RailDescriber.describe_rail(surface, RailInfo.RailType.HALF_DIAGONAL, defines.direction.northeast, pos)

   lu.assertEquals(desc.kind, "northnortheast")
   lu.assertTrue(desc.lonely)
end

function mod.TestDescriber_CurvedRailFallback()
   local surface = TestSurface.new()

   -- Place a curved rail (should get fallback description)
   surface:add_rail(RailInfo.RailType.CURVE_A, { x = 0, y = 0 }, defines.direction.north)

   local pos = Queries.get_adjusted_position(RailInfo.RailType.CURVE_A, { x = 0, y = 0 }, defines.direction.north)
   local desc = RailDescriber.describe_rail(surface, RailInfo.RailType.CURVE_A, defines.direction.north, pos)

   -- Should have a fallback description (left or right of a cardinal direction)
   lu.assertTrue(
      desc.kind == "left-of-north"
         or desc.kind == "right-of-north"
         or desc.kind == "left-of-east"
         or desc.kind == "right-of-east"
         or desc.kind == "left-of-south"
         or desc.kind == "right-of-south"
         or desc.kind == "left-of-west"
         or desc.kind == "right-of-west",
      "Curved rail should have left/right of cardinal description, got: " .. desc.kind
   )
   lu.assertTrue(desc.lonely)
end

function mod.TestDescriber_SingleRailIsLonely()
   local surface = TestSurface.new()

   -- Place a single rail
   local rail = surface:add_rail(RailInfo.RailType.STRAIGHT, { x = 0, y = 0 }, defines.direction.north)

   local desc = RailDescriber.describe_rail(surface, rail.rail_type, rail.direction, rail.prototype_position)

   -- Single rail should be lonely
   lu.assertTrue(desc.lonely, "Single rail should be lonely")

   -- Should have disconnected ends (both ends)
   lu.assertNotNil(desc.end_direction, "Should have at least one disconnected end")
end

function mod.TestDescriber_NoForks()
   local surface = TestSurface.new()

   -- Place a single straight rail
   local rail = surface:add_rail(RailInfo.RailType.STRAIGHT, { x = 0, y = 0 }, defines.direction.north)

   local desc = RailDescriber.describe_rail(surface, rail.rail_type, rail.direction, rail.prototype_position)

   lu.assertEquals(#desc.forks, 0, "Single rail should have no forks")
end

function mod.TestDescriber_TurnDetection_IsolatedCurve()
   local surface = TestSurface.new()

   -- Place a single curved-rail-a at north (would be bottom of east-to-south if the turn existed)
   local rail = surface:add_rail(RailInfo.RailType.CURVE_A, { x = 0, y = 0 }, defines.direction.north)

   local desc = RailDescriber.describe_rail(surface, rail.rail_type, rail.direction, rail.prototype_position)

   -- Without the full turn, should fall back to left/right of cardinal
   lu.assertTrue(
      desc.kind:find("north") ~= nil,
      "Isolated curved rail should use fallback description, got: " .. desc.kind
   )
   lu.assertTrue(desc.kind ~= "bottom-of-east-to-south-turn", "Isolated curve should not detect as turn")
end

function mod.TestDescriber_CompleteTurn()
   local surface = TestSurface.new()

   -- Build a complete east-to-south turn using traverser
   local start_rail = surface:add_rail(RailInfo.RailType.STRAIGHT, { x = 0, y = 0 }, defines.direction.east)

   local ends = Queries.get_end_directions(start_rail.rail_type, start_rail.direction)
   local trav = Traverser.new(start_rail.rail_type, start_rail.prototype_position, start_rail.direction)

   -- Navigate to east-facing end
   if trav:get_direction() ~= defines.direction.east then trav:flip_ends() end

   -- First, build all 4 pieces of the turn
   local turn_pieces = {}
   for i = 1, 4 do
      trav:move_right()
      local rail_type = trav:get_rail_kind()
      local placement_dir = trav:get_placement_direction()
      local position = trav:get_position()

      table.insert(turn_pieces, { rail_type = rail_type, placement_dir = placement_dir, position = position })
   end

   -- Place all pieces on the surface (all must exist for verification to work)
   for _, piece in ipairs(turn_pieces) do
      surface:add_rail(piece.rail_type, piece.position, piece.placement_dir)
   end

   -- Now verify each piece is detected as part of the turn
   local expected_positions = { "top", "upper-half", "lower-half", "bottom" }

   for i, piece in ipairs(turn_pieces) do
      local desc = RailDescriber.describe_rail(surface, piece.rail_type, piece.placement_dir, piece.position)

      -- Should detect as east-to-south turn (use plain text search to avoid hyphen pattern issues)
      lu.assertTrue(
         desc.kind:find("east-to-south-turn", 1, true) ~= nil,
         string.format("Piece %d should be detected as east-to-south turn, got: %s", i, desc.kind)
      )

      -- Should have correct position label (use plain text search)
      lu.assertTrue(
         desc.kind:find(expected_positions[i], 1, true) ~= nil,
         string.format("Piece %d should be %s, got: %s", i, expected_positions[i], desc.kind)
      )
   end
end

return mod
