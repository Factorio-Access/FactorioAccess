---Simple test: bind traverser to (1,1) straight-rail facing east, move forward, check position
require("polyfill")

local Traverser = require("railutils.traverser")
local RailInfo = require("railutils.rail-info")

print("=== Testing Traverser Grid Alignment ===")
print()

-- Start at (1, 1) with a straight-rail, bind to the east end (direction 4)
print("Creating traverser at position (1, 1), binding to east end (direction 4)")
local trav = Traverser.new(RailInfo.RailType.STRAIGHT, { x = 1, y = 1 }, 4)

print("  Current position:", trav:get_position().x, trav:get_position().y)
print("  End direction:", trav:get_direction())
print("  Placement direction:", trav:get_placement_direction())
print()

-- Move forward once
print("Moving forward once...")
trav:move_forward()

local new_pos = trav:get_position()
print("  New position:", new_pos.x, new_pos.y)
print("  Expected: (3, 1)")
print()

-- Check result
if new_pos.x == 3 and new_pos.y == 1 then
   print("✓ PASS: Position is grid-aligned at (3, 1)")
   os.exit(0)
else
   print("✗ FAIL: Position is NOT at (3, 1)")
   print("  Got: (" .. new_pos.x .. ", " .. new_pos.y .. ")")
   os.exit(1)
end
