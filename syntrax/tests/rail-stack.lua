-- Tests for rail stack operations (rpush, rpop, reset)

local lu = require("luaunit")
local Errors = require("syntrax.errors")
local Directions = require("syntrax.directions")
local helpers = require("syntrax.tests.helpers")

local mod = {}

function mod.test_rpush_rpop_basic()
   -- Basic push and pop
   local rails = helpers.assert_compilation_succeeds("s rpush l l rpop s")
   helpers.assert_rail_sequence(rails, { "straight", "left", "left", "straight" })

   -- Check connections
   helpers.assert_rail_connects_to(rails, 1, nil, "first rail has no parent")
   helpers.assert_rail_connects_to(rails, 2, 1)
   helpers.assert_rail_connects_to(rails, 3, 2)
   helpers.assert_rail_connects_to(rails, 4, 1, "rpop restores to after first straight")
end

function mod.test_reset_basic()
   -- Reset returns to initial position
   local rails = helpers.assert_compilation_succeeds("l r s reset s s")
   helpers.assert_rail_sequence(rails, { "left", "right", "straight", "straight", "straight" })

   -- After reset, parent should be nil (initial position)
   helpers.assert_rail_connects_to(rails, 4, nil, "reset returns to initial")
   helpers.assert_rail_connects_to(rails, 5, 4, "continues from reset position")
end

function mod.test_reset_with_initial()
   -- Reset with explicit initial rail
   local rails = helpers.assert_compilation_succeeds("l r reset s", 5, Directions.EAST)
   lu.assertEquals(#rails, 3)

   -- Check parent connections
   helpers.assert_rail_connects_to(rails, 1, 5, "starts from initial rail")
   helpers.assert_rail_connects_to(rails, 2, 1)
   helpers.assert_rail_connects_to(rails, 3, 5, "reset returns to initial rail")

   -- Check direction is preserved
   helpers.assert_rail_direction(rails, 3, Directions.EAST, "incoming")
end

function mod.test_rpop_empty_stack()
   -- Error when popping empty stack
   helpers.assert_compilation_fails("rpop", Errors.ERROR_CODE.RUNTIME_ERROR, "empty")
end

function mod.test_nested_rpush_rpop()
   -- Nested push/pop operations
   local rails = helpers.assert_compilation_succeeds("rpush s rpush l rpop s rpop")
   helpers.assert_rail_sequence(rails, { "straight", "left", "straight" })

   -- Check connections show proper nesting
   helpers.assert_rail_connects_to(rails, 1, nil)
   helpers.assert_rail_connects_to(rails, 2, 1)
   helpers.assert_rail_connects_to(rails, 3, 1, "inner rpop restores to after first straight")
end

function mod.test_loop_with_rpush_rpop()
   -- Loops can have mismatched rpush/rpop
   local rails = helpers.assert_compilation_succeeds("rpush [s rpop rpush] rep 3")
   lu.assertEquals(#rails, 3)

   -- All straights should have same parent (initial position)
   helpers.assert_rails_connect_to(rails, { 1, 2, 3 }, nil, "all rails start from initial position")
end

function mod.test_direction_preservation()
   -- rpush/rpop should preserve direction
   local rails = helpers.assert_compilation_succeeds("l l rpush r r rpop s", 1, Directions.NORTH)

   -- After two lefts, direction should be NNW (14)
   helpers.assert_rail_direction(rails, 2, 14, "outgoing")

   -- After rpop, direction should be restored to NNW
   helpers.assert_rail_direction(rails, 5, 14, "incoming")
   helpers.assert_rail_direction(rails, 5, 14, "outgoing")
end

function mod.test_three_way_fork()
   -- Example from spec - 3-way fork with all branches starting from same point
   local code = [[
rpush
l r s reset
s s s reset
r s l
]]
   local rails = helpers.assert_compilation_succeeds(code, 1, Directions.EAST)
   lu.assertEquals(#rails, 9)

   -- All three branches should start from rail 1
   helpers.assert_rails_connect_to(rails, { 1, 4, 7 }, 1, "all three branches start from same rail")
end

function mod.test_initial_rail_rpush()
   -- Can rpush the initial rail
   local rails = helpers.assert_compilation_succeeds("rpush s s rpop", 10, Directions.SOUTH)
   lu.assertEquals(#rails, 2)

   -- Both rails placed from initial position
   helpers.assert_rail_connects_to(rails, 1, 10, "starts from initial rail")
   helpers.assert_rail_connects_to(rails, 2, 1)
   -- After rpop, we're back at initial rail 10 (no rail placed by rpop itself)
end

return mod
