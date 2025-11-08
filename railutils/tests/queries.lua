local lu = require("luaunit")
require("polyfill")

local TestSurface = require("railutils.surface-impls.test-surface")
local Queries = require("railutils.queries")
local RailInfo = require("railutils.rail-info")

local mod = {}

function mod.TestGetExtensionPoints_EmptySurface()
   local surface = TestSurface.new()

   local extensions = Queries.get_extension_points_at_position(surface, { x = 0, y = 0 })

   lu.assertEquals(table_size(extensions), 0, "Empty surface should have no extension points")
end

function mod.TestGetExtensionPoints_StraightRailNorth()
   local surface = TestSurface.new()

   -- Place a straight rail facing north (grid offset will adjust position)
   -- According to rail-geometry.md, straight-rail at north has ends at north and south
   surface:add_rail(RailInfo.RailType.STRAIGHT, { x = 0, y = 0 }, defines.direction.north)

   -- Query at the actual position where the rail was placed (after grid adjustment)
   local adjusted_pos = Queries.get_adjusted_position(RailInfo.RailType.STRAIGHT, { x = 0, y = 0 }, defines.direction.north)
   local extensions = Queries.get_extension_points_at_position(surface, adjusted_pos)

   -- A straight rail has 2 ends, each end has 3 extensions
   -- So we expect 6 unique goal directions
   lu.assertEquals(table_size(extensions), 6, "Straight rail should have 6 unique goal directions")

   -- Verify we have extensions from both ends by checking end_directions in the extension points
   local has_north_end = false
   local has_south_end = false

   for _, exts in pairs(extensions) do
      for _, ext in ipairs(exts) do
         if ext.end_direction == defines.direction.north then has_north_end = true end
         if ext.end_direction == defines.direction.south then has_south_end = true end
      end
   end

   lu.assertTrue(has_north_end, "Should have extensions from north-facing end")
   lu.assertTrue(has_south_end, "Should have extensions from south-facing end")
end

function mod.TestGetExtensionPoints_ExtensionDirections()
   local surface = TestSurface.new()

   -- Place a straight rail at origin facing north
   surface:add_rail(RailInfo.RailType.STRAIGHT, { x = 0, y = 0 }, defines.direction.north)

   local adjusted_pos = Queries.get_adjusted_position(RailInfo.RailType.STRAIGHT, { x = 0, y = 0 }, defines.direction.north)
   local extensions = Queries.get_extension_points_at_position(surface, adjusted_pos)

   -- From the north end (facing north), we should be able to extend to:
   -- - north (straight, offset 0)
   -- - northnortheast (turn right, offset +1)
   -- - northnorthwest (turn left, offset -1)
   -- Now we can just check if these directions exist as keys
   lu.assertNotNil(extensions[defines.direction.north], "Should be able to extend north")
   lu.assertNotNil(extensions[defines.direction.northnortheast], "Should be able to extend northnortheast")
   lu.assertNotNil(extensions[defines.direction.northnorthwest], "Should be able to extend northnorthwest")

   -- Each should have exactly one extension point
   lu.assertEquals(#extensions[defines.direction.north], 1, "North extension should have 1 option")
   lu.assertEquals(#extensions[defines.direction.northnortheast], 1, "NNE extension should have 1 option")
   lu.assertEquals(#extensions[defines.direction.northnorthwest], 1, "NNW extension should have 1 option")
end

function mod.TestGetExtensionPoints_UnitNumber()
   local surface = TestSurface.new()

   local rail = surface:add_rail(RailInfo.RailType.STRAIGHT, { x = 0, y = 0 }, defines.direction.north)

   local adjusted_pos = Queries.get_adjusted_position(RailInfo.RailType.STRAIGHT, { x = 0, y = 0 }, defines.direction.north)
   local extensions = Queries.get_extension_points_at_position(surface, adjusted_pos)

   -- All extensions should reference the rail's unit number
   for _, exts in pairs(extensions) do
      for _, ext in ipairs(exts) do
         lu.assertEquals(ext.rail_unit_number, rail.unit_number, "Extension should reference correct rail unit number")
      end
   end
end

function mod.TestGetExtensionPoints_MultipleRails()
   local surface = TestSurface.new()

   -- Place two different rails at the same requested position but different orientations
   -- They'll get grid-adjusted to the same actual position
   surface:add_rail(RailInfo.RailType.STRAIGHT, { x = 0, y = 0 }, defines.direction.north)
   surface:add_rail(RailInfo.RailType.STRAIGHT, { x = 0, y = 0 }, defines.direction.east)

   -- Both north and east straight rails have grid_offset (1, 1), so they end up at the same position
   local adjusted_pos = Queries.get_adjusted_position(RailInfo.RailType.STRAIGHT, { x = 0, y = 0 }, defines.direction.north)
   local extensions = Queries.get_extension_points_at_position(surface, adjusted_pos)

   -- Each rail has 6 unique goal directions, and they don't overlap
   -- So we should have 12 unique directions total
   lu.assertEquals(table_size(extensions), 12, "Two rails should have 12 unique goal directions")

   -- Count total extension points across all directions
   local total_count = 0
   for _, exts in pairs(extensions) do
      total_count = total_count + #exts
   end
   lu.assertEquals(total_count, 12, "Should have 12 total extension points")
end

function mod.TestGetExtensionPoints_AbsolutePositions()
   local surface = TestSurface.new()

   -- Place a rail at a non-origin position
   local requested_pos = { x = 10, y = 20 }
   surface:add_rail(RailInfo.RailType.STRAIGHT, requested_pos, defines.direction.north)

   local adjusted_pos = Queries.get_adjusted_position(RailInfo.RailType.STRAIGHT, requested_pos, defines.direction.north)
   local extensions = Queries.get_extension_points_at_position(surface, adjusted_pos)

   -- Verify that positions are absolute (not relative to rail)
   for _, exts in pairs(extensions) do
      for _, ext in ipairs(exts) do
         -- End positions and next rail positions should be offset from the rail position
         lu.assertNotEquals(ext.end_position.x, 0, "End position should be absolute, not relative")
         lu.assertNotEquals(ext.next_rail_position.x, 0, "Next rail position should be absolute, not relative")
      end
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
