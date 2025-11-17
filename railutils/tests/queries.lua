local lu = require("luaunit")
require("polyfill")

local TestSurface = require("railutils.surface-impls.test-surface")
local Queries = require("railutils.queries")
local RailInfo = require("railutils.rail-info")

local mod = {}

function mod.TestGetExtensionsFromEnd_StraightRailNorthEnd()
   -- Test getting extensions from the north end of a straight rail facing north
   local position = { x = 1, y = 1 } -- Grid-adjusted position for straight north
   local extensions = Queries.get_extensions_from_end(
      position,
      RailInfo.RailType.STRAIGHT,
      defines.direction.north,
      defines.direction.north
   )

   -- From the north end (facing north), we should be able to extend to:
   -- - north (straight ahead, offset 0)
   -- - northnortheast (turn right, offset +1)
   -- - northnorthwest (turn left, offset -1)
   lu.assertEquals(#extensions, 3, "North end should have 3 extensions")

   -- Verify goal directions
   local goal_directions = {}
   for _, ext in ipairs(extensions) do
      goal_directions[ext.goal_direction] = true
      lu.assertEquals(ext.end_direction, defines.direction.north, "All extensions should be from north end")
   end

   lu.assertTrue(goal_directions[defines.direction.north], "Should extend straight north")
   lu.assertTrue(goal_directions[defines.direction.northnortheast], "Should extend to NNE")
   lu.assertTrue(goal_directions[defines.direction.northnorthwest], "Should extend to NNW")
end

function mod.TestGetExtensionsFromEnd_StraightRailSouthEnd()
   -- Test getting extensions from the south end of a straight rail facing north
   local position = { x = 1, y = 1 }
   local extensions = Queries.get_extensions_from_end(
      position,
      RailInfo.RailType.STRAIGHT,
      defines.direction.north,
      defines.direction.south
   )

   -- From the south end (facing south), we should be able to extend to:
   -- - south (straight ahead)
   -- - southsoutheast (turn right)
   -- - southsouthwest (turn left)
   lu.assertEquals(#extensions, 3, "South end should have 3 extensions")

   -- Verify goal directions
   local goal_directions = {}
   for _, ext in ipairs(extensions) do
      goal_directions[ext.goal_direction] = true
      lu.assertEquals(ext.end_direction, defines.direction.south, "All extensions should be from south end")
   end

   lu.assertTrue(goal_directions[defines.direction.south], "Should extend straight south")
   lu.assertTrue(goal_directions[defines.direction.southsoutheast], "Should extend to SSE")
   lu.assertTrue(goal_directions[defines.direction.southsouthwest], "Should extend to SSW")
end

function mod.TestGetExtensionsFromEnd_AbsolutePositions()
   -- Test that positions are absolute, not relative
   local requested_pos = { x = 10, y = 20 }
   local adjusted_pos =
      Queries.get_adjusted_position(RailInfo.RailType.STRAIGHT, requested_pos, defines.direction.north)

   local extensions = Queries.get_extensions_from_end(
      adjusted_pos,
      RailInfo.RailType.STRAIGHT,
      defines.direction.north,
      defines.direction.north
   )

   -- Verify that positions are absolute (offset from rail position)
   for _, ext in ipairs(extensions) do
      lu.assertNotEquals(ext.end_position.x, 0, "End position should be absolute, not relative")
      lu.assertNotEquals(ext.next_rail_position.x, 0, "Next rail position should be absolute, not relative")
      -- They should be based on the adjusted position, not zero
      lu.assertTrue(ext.end_position.x > 5, "End position x should be offset from rail at x=11")
      lu.assertTrue(ext.next_rail_position.x > 5, "Next rail position x should be offset from rail")
   end
end

function mod.TestGetExtensionsFromEnd_CurvedRail()
   -- Test extensions from a curved rail
   -- curved-rail-a at north (cardinal) has ends at south (8) and northnorthwest (15)
   local position = { x = 1, y = 0 } -- Grid-adjusted position for curved-a north
   local extensions = Queries.get_extensions_from_end(
      position,
      RailInfo.RailType.CURVE_A,
      defines.direction.north,
      defines.direction.northnorthwest
   )

   -- Curved rails also have 3 extensions per end
   lu.assertEquals(#extensions, 3, "Curved rail end should have 3 extensions")

   -- All extensions should be from the correct end
   for _, ext in ipairs(extensions) do
      lu.assertEquals(ext.end_direction, defines.direction.northnorthwest, "All extensions should be from NNW end")
   end
end

function mod.TestGetAdjustedPosition_GridAlignment()
   -- Test that grid adjustment works correctly for different rail types and directions

   -- Straight rail north: grid_offset (1, 1)
   local pos = Queries.get_adjusted_position(RailInfo.RailType.STRAIGHT, { x = 0, y = 0 }, defines.direction.north)
   lu.assertEquals(pos.x, 1, "Straight north should adjust x by 1")
   lu.assertEquals(pos.y, 1, "Straight north should adjust y by 1")

   -- Straight rail northeast: grid_offset (0, 0)
   pos = Queries.get_adjusted_position(RailInfo.RailType.STRAIGHT, { x = 0, y = 0 }, defines.direction.northeast)
   lu.assertEquals(pos.x, 0, "Straight northeast should not adjust x")
   lu.assertEquals(pos.y, 0, "Straight northeast should not adjust y")

   -- Curved-rail-a north: grid_offset (1, 0)
   pos = Queries.get_adjusted_position(RailInfo.RailType.CURVE_A, { x = 0, y = 0 }, defines.direction.north)
   lu.assertEquals(pos.x, 1, "Curved-a north should adjust x by 1")
   lu.assertEquals(pos.y, 0, "Curved-a north should not adjust y")

   -- Curved-rail-a west: grid_offset (0, 1)
   pos = Queries.get_adjusted_position(RailInfo.RailType.CURVE_A, { x = 0, y = 0 }, defines.direction.west)
   lu.assertEquals(pos.x, 0, "Curved-a west should not adjust x")
   lu.assertEquals(pos.y, 1, "Curved-a west should adjust y by 1")

   -- Curved-rail-b always: grid_offset (1, 1)
   pos = Queries.get_adjusted_position(RailInfo.RailType.CURVE_B, { x = 0, y = 0 }, defines.direction.north)
   lu.assertEquals(pos.x, 1, "Curved-b should adjust x by 1")
   lu.assertEquals(pos.y, 1, "Curved-b should adjust y by 1")

   -- Half-diagonal always: grid_offset (1, 1)
   pos = Queries.get_adjusted_position(RailInfo.RailType.HALF_DIAGONAL, { x = 0, y = 0 }, defines.direction.northeast)
   lu.assertEquals(pos.x, 1, "Half-diagonal should adjust x by 1")
   lu.assertEquals(pos.y, 1, "Half-diagonal should adjust y by 1")
end

return mod
