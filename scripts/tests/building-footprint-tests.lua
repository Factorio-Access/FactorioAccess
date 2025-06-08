local test_framework = require("scripts.test_framework")
local fa_utils = require("scripts.fa-utils")

-- Test basic footprint calculation for a 3x3 entity
test_framework.register_test("building_footprint_basic_3x3", function(context)
   local footprint = fa_utils.calculate_building_footprint({
      width = 3,
      height = 3,
      position = { x = 10.5, y = 20.5 },
      building_direction = defines.direction.north,
      player_direction = defines.direction.south,
      cursor_enabled = true,
      build_lock = false,
      is_rail_vehicle = false,
   })

   context:assert_equals(footprint.left_top.x, 10, "Left top X should be 10")
   context:assert_equals(footprint.left_top.y, 20, "Left top Y should be 20")
   context:assert_equals(footprint.right_bottom.x, 13, "Right bottom X should be 13")
   context:assert_equals(footprint.right_bottom.y, 23, "Right bottom Y should be 23")
   context:assert_equals(footprint.center.x, 11, "Center X should be 11")
   context:assert_equals(footprint.center.y, 21, "Center Y should be 21")
   context:assert_equals(footprint.width, 3, "Width should be 3")
   context:assert_equals(footprint.height, 3, "Height should be 3")
end)

-- Test rotation (east/west swaps dimensions)
test_framework.register_test("building_footprint_rotated", function(context)
   local footprint = fa_utils.calculate_building_footprint({
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
   context:assert_equals(footprint.width, 4, "Width should be 4 (swapped)")
   context:assert_equals(footprint.height, 2, "Height should be 2 (swapped)")
   context:assert_equals(footprint.left_top.x, 10, "Left top X should be 10")
   context:assert_equals(footprint.left_top.y, 20, "Left top Y should be 20")
   context:assert_equals(footprint.right_bottom.x, 14, "Right bottom X should be 14")
   context:assert_equals(footprint.right_bottom.y, 22, "Right bottom Y should be 22")
end)

-- Test non-cursor mode with player facing west
test_framework.register_test("building_footprint_non_cursor_west", function(context)
   local footprint = fa_utils.calculate_building_footprint({
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
   context:assert_equals(footprint.left_top.x, 8, "Left top X should be 8 (shifted left)")
   context:assert_equals(footprint.left_top.y, 20, "Left top Y should be 20")
   context:assert_equals(footprint.right_bottom.x, 11, "Right bottom X should be 11 (shifted left)")
   context:assert_equals(footprint.right_bottom.y, 23, "Right bottom Y should be 23")
   context:assert_equals(footprint.center.x, 9, "Center X should be 9")
end)

-- Test non-cursor mode with player facing north
test_framework.register_test("building_footprint_non_cursor_north", function(context)
   local footprint = fa_utils.calculate_building_footprint({
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
   context:assert_equals(footprint.left_top.x, 10, "Left top X should be 10")
   context:assert_equals(footprint.left_top.y, 18, "Left top Y should be 18 (shifted up)")
   context:assert_equals(footprint.right_bottom.x, 13, "Right bottom X should be 13")
   context:assert_equals(footprint.right_bottom.y, 21, "Right bottom Y should be 21 (shifted up)")
   context:assert_equals(footprint.center.y, 19, "Center Y should be 19")
end)

-- Test build lock mode (building from behind)
test_framework.register_test("building_footprint_build_lock_south", function(context)
   local footprint = fa_utils.calculate_building_footprint({
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
   context:assert_equals(footprint.left_top.x, 10, "Left top X should be 10")
   context:assert_equals(footprint.left_top.y, 16, "Left top Y should be 16 (offset -4)")
   context:assert_equals(footprint.right_bottom.x, 13, "Right bottom X should be 13")
   context:assert_equals(footprint.right_bottom.y, 19, "Right bottom Y should be 19 (offset -4)")
end)

-- Test build lock mode with rotation
test_framework.register_test("building_footprint_build_lock_rotated", function(context)
   local footprint = fa_utils.calculate_building_footprint({
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
   context:assert_equals(footprint.width, 4, "Width should be 4 (swapped)")
   context:assert_equals(footprint.height, 2, "Height should be 2 (swapped)")
   context:assert_equals(footprint.left_top.x, 5, "Left top X should be 5 (offset -5)")
   context:assert_equals(footprint.left_top.y, 20, "Left top Y should be 20")
end)

-- Test 1x1 entity
test_framework.register_test("building_footprint_1x1", function(context)
   local footprint = fa_utils.calculate_building_footprint({
      width = 1,
      height = 1,
      position = { x = 10.5, y = 20.5 },
      building_direction = defines.direction.north,
      player_direction = defines.direction.south,
      cursor_enabled = true,
      build_lock = false,
      is_rail_vehicle = false,
   })

   context:assert_equals(footprint.left_top.x, 10, "Left top X should be 10")
   context:assert_equals(footprint.left_top.y, 20, "Left top Y should be 20")
   context:assert_equals(footprint.right_bottom.x, 11, "Right bottom X should be 11")
   context:assert_equals(footprint.right_bottom.y, 21, "Right bottom Y should be 21")
   context:assert_equals(footprint.center.x, 10, "Center X should be 10")
   context:assert_equals(footprint.center.y, 20, "Center Y should be 20")
end)

-- Test rail vehicle special case (should ignore build lock)
test_framework.register_test("building_footprint_rail_vehicle", function(context)
   local footprint = fa_utils.calculate_building_footprint({
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
   context:assert_equals(footprint.left_top.x, 10, "Left top X should be 10")
   context:assert_equals(footprint.left_top.y, 20, "Left top Y should be 20")
   context:assert_equals(footprint.right_bottom.x, 13, "Right bottom X should be 13")
   context:assert_equals(footprint.right_bottom.y, 23, "Right bottom Y should be 23")
end)
