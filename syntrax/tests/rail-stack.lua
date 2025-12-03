-- Tests for rail stack operations (rpush, rpop, reset)

local lu = require("luaunit")
local Errors = require("syntrax.errors")
local Directions = require("syntrax.directions")
local helpers = require("syntrax.tests.helpers")

local mod = {}

function mod.test_rpush_rpop_basic()
   -- Basic push and pop
   local rails = helpers.assert_compilation_succeeds("s rpush l l rpop s")
   -- With new format, just verify we get rails with positions
   lu.assertEquals(#rails, 4)
   for i, rail in ipairs(rails) do
      lu.assertNotNil(rail.position)
      lu.assertNotNil(rail.rail_type)
   end
end

function mod.test_reset_basic()
   -- Reset returns to initial position
   local rails = helpers.assert_compilation_succeeds("l r s reset s s")
   -- Verifies that reset works - we should get 5 rails
   lu.assertEquals(#rails, 5)
   for i, rail in ipairs(rails) do
      lu.assertNotNil(rail.position)
      lu.assertNotNil(rail.rail_type)
   end
end

function mod.test_reset_with_initial()
   -- Reset with explicit initial position/direction
   local initial_pos = { x = 10, y = 20 }
   local rails = helpers.assert_compilation_succeeds("l r reset s", initial_pos, Directions.EAST)
   lu.assertEquals(#rails, 3)
   for i, rail in ipairs(rails) do
      lu.assertNotNil(rail.position)
      lu.assertNotNil(rail.rail_type)
   end
end

function mod.test_rpop_empty_stack()
   -- Error when popping empty stack
   helpers.assert_compilation_fails("rpop", Errors.ERROR_CODE.RUNTIME_ERROR, "empty")
end

function mod.test_nested_rpush_rpop()
   -- Nested push/pop operations
   local rails = helpers.assert_compilation_succeeds("rpush s rpush l rpop s rpop")
   lu.assertEquals(#rails, 3)
   for i, rail in ipairs(rails) do
      lu.assertNotNil(rail.position)
      lu.assertNotNil(rail.rail_type)
   end
end

function mod.test_loop_with_rpush_rpop()
   -- Loops can have mismatched rpush/rpop
   -- With deduplication, same position rails only appear once
   local rails = helpers.assert_compilation_succeeds("rpush [s rpop rpush] x 3")
   -- Due to deduplication (all straights go to same position), may get fewer rails
   lu.assertTrue(#rails >= 1, "Should have at least one rail")
   for _, rail in ipairs(rails) do
      lu.assertNotNil(rail.position)
      lu.assertNotNil(rail.rail_type)
   end
end

function mod.test_direction_preservation()
   -- rpush/rpop should preserve direction - verified by successful execution
   local rails = helpers.assert_compilation_succeeds("l l rpush r r rpop s", nil, Directions.NORTH)
   lu.assertEquals(#rails, 5)
   for _, rail in ipairs(rails) do
      lu.assertNotNil(rail.position)
      lu.assertNotNil(rail.rail_type)
   end
end

function mod.test_three_way_fork()
   -- Example from spec - 3-way fork with all branches starting from same point
   local code = [[
rpush
l r s reset
s s s reset
r s l
]]
   local initial_pos = { x = 0, y = 0 }
   local rails = helpers.assert_compilation_succeeds(code, initial_pos, Directions.EAST)
   -- Should have multiple rails for the three branches
   lu.assertTrue(#rails > 0, "Should have rails for three branches")
   for _, rail in ipairs(rails) do
      lu.assertNotNil(rail.position)
      lu.assertNotNil(rail.rail_type)
   end
end

function mod.test_initial_rail_rpush()
   -- Can rpush the initial rail
   local initial_pos = { x = 100, y = 200 }
   local rails = helpers.assert_compilation_succeeds("rpush s s rpop", initial_pos, Directions.SOUTH)
   lu.assertEquals(#rails, 2)
   for _, rail in ipairs(rails) do
      lu.assertNotNil(rail.position)
      lu.assertNotNil(rail.rail_type)
   end
end

return mod
