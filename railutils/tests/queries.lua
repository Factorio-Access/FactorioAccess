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

   -- Place a straight rail at origin facing north
   -- According to rail-geometry.md, straight-rail at north has ends at north and south
   surface:add_rail(RailInfo.RailType.STRAIGHT, { x = 0, y = 0 }, defines.direction.north)

   local extensions = Queries.get_extension_points_at_position(surface, { x = 0, y = 0 })

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

   local extensions = Queries.get_extension_points_at_position(surface, { x = 0, y = 0 })

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

   local extensions = Queries.get_extension_points_at_position(surface, { x = 0, y = 0 })

   -- All extensions should reference the rail's unit number
   for _, exts in pairs(extensions) do
      for _, ext in ipairs(exts) do
         lu.assertEquals(ext.rail_unit_number, rail.unit_number, "Extension should reference correct rail unit number")
      end
   end
end

function mod.TestGetExtensionPoints_MultipleRails()
   local surface = TestSurface.new()

   -- Place two different rails that might overlap at some tile
   -- For simplicity, we'll place them at the same position but different orientations
   surface:add_rail(RailInfo.RailType.STRAIGHT, { x = 0, y = 0 }, defines.direction.north)
   surface:add_rail(RailInfo.RailType.STRAIGHT, { x = 0, y = 0 }, defines.direction.east)

   local extensions = Queries.get_extension_points_at_position(surface, { x = 0, y = 0 })

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
   surface:add_rail(RailInfo.RailType.STRAIGHT, { x = 10, y = 20 }, defines.direction.north)

   local extensions = Queries.get_extension_points_at_position(surface, { x = 10, y = 20 })

   -- Verify that positions are absolute (not relative to rail)
   for _, exts in pairs(extensions) do
      for _, ext in ipairs(exts) do
         -- End positions and next rail positions should be offset from the rail position
         lu.assertNotEquals(ext.end_position.x, 0, "End position should be absolute, not relative")
         lu.assertNotEquals(ext.next_rail_position.x, 0, "Next rail position should be absolute, not relative")
      end
   end
end

return mod
