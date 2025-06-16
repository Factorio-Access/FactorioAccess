--- Building footprint calculation tests

local TestRegistry = require("scripts.test-registry")
local describe = TestRegistry.describe
local it = TestRegistry.it
local FaUtils = require("scripts.fa-utils")

-- Log that the file is being loaded
print("[BuildingFootprintTests] Loading building footprint tests file")

describe("Building Footprint Calculations", function()
   -- Test basic footprint calculation for a 3x3 entity
   it("should calculate basic 3x3 footprint correctly", function(ctx)
      ctx:init(function()
         local dirs = defines.direction
         local footprint = FaUtils.calculate_building_footprint({
            width = 3,
            height = 3,
            position = { x = 10.5, y = 20.5 },
            building_direction = dirs.north,
            player_direction = dirs.south,
            cursor_enabled = true,
            build_lock = false,
            is_rail_vehicle = false,
         })

         ctx:assert_equals(footprint.left_top.x, 10, "Left top X should be 10")
         ctx:assert_equals(footprint.left_top.y, 20, "Left top Y should be 20")
         ctx:assert_equals(footprint.right_bottom.x, 13, "Right bottom X should be 13")
         ctx:assert_equals(footprint.right_bottom.y, 23, "Right bottom Y should be 23")
         ctx:assert_equals(footprint.center.x, 11, "Center X should be 11")
         ctx:assert_equals(footprint.center.y, 21, "Center Y should be 21")
         ctx:assert_equals(footprint.width, 3, "Width should be 3")
         ctx:assert_equals(footprint.height, 3, "Height should be 3")
      end)
   end)

   -- Test rotation (east/west swaps dimensions)
   it("should swap dimensions when rotated east/west", function(ctx)
      ctx:init(function()
         local footprint = FaUtils.calculate_building_footprint({
            width = 2,
            height = 4,
            position = { x = 10.5, y = 20.5 },
            building_direction = defines.direction.east,
            player_direction = defines.direction.south,
            cursor_enabled = true,
            build_lock = false,
            is_rail_vehicle = false,
         })

         -- When rotated east, width and height are swapped
         ctx:assert_equals(footprint.width, 4, "Width should be 4 (swapped)")
         ctx:assert_equals(footprint.height, 2, "Height should be 2 (swapped)")
         ctx:assert_equals(footprint.left_top.x, 10, "Left top X should be 10")
         ctx:assert_equals(footprint.left_top.y, 20, "Left top Y should be 20")
         ctx:assert_equals(footprint.right_bottom.x, 14, "Right bottom X should be 14")
         ctx:assert_equals(footprint.right_bottom.y, 22, "Right bottom Y should be 22")
      end)
   end)

   -- Test non-cursor mode with player facing west
   it("should offset left when player faces west in non-cursor mode", function(ctx)
      ctx:init(function()
         local footprint = FaUtils.calculate_building_footprint({
            width = 3,
            height = 3,
            position = { x = 10.5, y = 20.5 },
            building_direction = defines.direction.north,
            player_direction = defines.direction.west,
            cursor_enabled = false,
            build_lock = false,
            is_rail_vehicle = false,
         })

         -- When player faces west in non-cursor mode, footprint shifts left
         ctx:assert_equals(footprint.left_top.x, 8, "Left top X should be 8 (shifted left)")
         ctx:assert_equals(footprint.left_top.y, 20, "Left top Y should be 20")
         ctx:assert_equals(footprint.right_bottom.x, 11, "Right bottom X should be 11 (shifted left)")
         ctx:assert_equals(footprint.right_bottom.y, 23, "Right bottom Y should be 23")
         ctx:assert_equals(footprint.center.x, 9, "Center X should be 9")
      end)
   end)

   -- Test non-cursor mode with player facing north
   it("should offset up when player faces north in non-cursor mode", function(ctx)
      ctx:init(function()
         local footprint = FaUtils.calculate_building_footprint({
            width = 3,
            height = 3,
            position = { x = 10.5, y = 20.5 },
            building_direction = defines.direction.north,
            player_direction = defines.direction.north,
            cursor_enabled = false,
            build_lock = false,
            is_rail_vehicle = false,
         })

         -- When player faces north in non-cursor mode, footprint shifts up
         ctx:assert_equals(footprint.left_top.x, 10, "Left top X should be 10")
         ctx:assert_equals(footprint.left_top.y, 18, "Left top Y should be 18 (shifted up)")
         ctx:assert_equals(footprint.right_bottom.x, 13, "Right bottom X should be 13")
         ctx:assert_equals(footprint.right_bottom.y, 21, "Right bottom Y should be 21 (shifted up)")
         ctx:assert_equals(footprint.center.y, 19, "Center Y should be 19")
      end)
   end)

   -- Test build lock mode (building from behind)
   it("should build behind player with build lock facing south", function(ctx)
      ctx:init(function()
         local footprint = FaUtils.calculate_building_footprint({
            width = 3,
            height = 3,
            position = { x = 10.5, y = 20.5 },
            building_direction = defines.direction.north,
            player_direction = defines.direction.south,
            cursor_enabled = false,
            build_lock = true,
            is_rail_vehicle = false,
         })

         -- Build lock with player facing south: builds behind (north of) player
         -- Base offset is -2, size offset is -3 + 1 = -2, total = -4
         ctx:assert_equals(footprint.left_top.x, 10, "Left top X should be 10")
         ctx:assert_equals(footprint.left_top.y, 16, "Left top Y should be 16 (offset -4)")
         ctx:assert_equals(footprint.right_bottom.x, 13, "Right bottom X should be 13")
         ctx:assert_equals(footprint.right_bottom.y, 19, "Right bottom Y should be 19 (offset -4)")
      end)
   end)

   -- Test build lock mode with rotation
   it("should handle build lock with rotated entity", function(ctx)
      ctx:init(function()
         local footprint = FaUtils.calculate_building_footprint({
            width = 2,
            height = 4,
            position = { x = 10.5, y = 20.5 },
            building_direction = defines.direction.east, -- Rotated
            player_direction = defines.direction.east,
            cursor_enabled = false,
            build_lock = true,
            is_rail_vehicle = false,
         })

         -- Rotated entity (4x2 after rotation) with build lock facing east
         -- Base offset is -2, size offset is -4 + 1 = -3, total = -5
         ctx:assert_equals(footprint.width, 4, "Width should be 4 (swapped)")
         ctx:assert_equals(footprint.height, 2, "Height should be 2 (swapped)")
         ctx:assert_equals(footprint.left_top.x, 5, "Left top X should be 5 (offset -5)")
         ctx:assert_equals(footprint.left_top.y, 20, "Left top Y should be 20")
      end)
   end)

   -- Test 1x1 entity
   it("should handle 1x1 entities correctly", function(ctx)
      ctx:init(function()
         local footprint = FaUtils.calculate_building_footprint({
            width = 1,
            height = 1,
            position = { x = 10.5, y = 20.5 },
            building_direction = defines.direction.north,
            player_direction = defines.direction.south,
            cursor_enabled = true,
            build_lock = false,
            is_rail_vehicle = false,
         })

         ctx:assert_equals(footprint.left_top.x, 10, "Left top X should be 10")
         ctx:assert_equals(footprint.left_top.y, 20, "Left top Y should be 20")
         ctx:assert_equals(footprint.right_bottom.x, 11, "Right bottom X should be 11")
         ctx:assert_equals(footprint.right_bottom.y, 21, "Right bottom Y should be 21")
         ctx:assert_equals(footprint.center.x, 10, "Center X should be 10")
         ctx:assert_equals(footprint.center.y, 20, "Center Y should be 20")
      end)
   end)

   -- Test rail vehicle special case (should ignore build lock)
   it("should ignore build lock for rail vehicles", function(ctx)
      ctx:init(function()
         local footprint = FaUtils.calculate_building_footprint({
            width = 3,
            height = 3,
            position = { x = 10.5, y = 20.5 },
            building_direction = defines.direction.north,
            player_direction = defines.direction.south,
            cursor_enabled = false,
            build_lock = true,
            is_rail_vehicle = true, -- Should ignore build lock
         })

         -- Rail vehicles ignore build lock offsets
         ctx:assert_equals(footprint.left_top.x, 10, "Left top X should be 10")
         ctx:assert_equals(footprint.left_top.y, 20, "Left top Y should be 20")
         ctx:assert_equals(footprint.right_bottom.x, 13, "Right bottom X should be 13")
         ctx:assert_equals(footprint.right_bottom.y, 23, "Right bottom Y should be 23")
      end)
   end)
end)
