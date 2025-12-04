local lu = require("luaunit")
local Syntrax = require("syntrax")
local helpers = require("syntrax.tests.helpers")

local mod = {}

function mod.TestExecuteSimple()
   local rails = helpers.assert_compilation_succeeds("l r s")
   helpers.assert_rail_sequence(rails, { "left", "right", "straight" })
end

function mod.TestExecuteWithRepetition()
   local rails = helpers.assert_compilation_succeeds("[l] x 4")
   helpers.assert_rail_sequence(rails, { "left", "left", "left", "left" })
end

function mod.TestExecuteEmpty()
   local rails = helpers.assert_compilation_succeeds("")
   lu.assertEquals(#rails, 0)
end

function mod.TestExecuteError()
   -- x without a preceding primitive or bracket is still an error
   helpers.assert_compilation_fails("x 3", "unexpected_token", "Unexpected token 'x'")
end

function mod.TestExecuteInvalidToken()
   helpers.assert_compilation_fails("foo bar baz", "unexpected_token")
end

function mod.TestVersion()
   lu.assertNotNil(Syntrax.VERSION)
   lu.assertStrContains(Syntrax.VERSION, "dev")
end

function mod.TestRailStructure()
   local rails = helpers.assert_compilation_succeeds("l r")
   lu.assertEquals(#rails, 2)

   -- New format: check that rails have position and rail_type
   helpers.assert_rail_exists(rails, 1)
   lu.assertNotNil(rails[1].position)
   lu.assertNotNil(rails[1].rail_type)
   lu.assertNotNil(rails[1].placement_direction)

   helpers.assert_rail_exists(rails, 2)
   lu.assertNotNil(rails[2].position)
   lu.assertNotNil(rails[2].rail_type)
end

return mod
