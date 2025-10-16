local lu = require("luaunit")
local Syntrax = require("syntrax")
local helpers = require("syntrax.tests.helpers")

local mod = {}

function mod.TestExecuteSimple()
   local rails = helpers.assert_compilation_succeeds("l r s")
   helpers.assert_rail_sequence(rails, { "left", "right", "straight" })
end

function mod.TestExecuteWithRepetition()
   local rails = helpers.assert_compilation_succeeds("[l] rep 4")
   helpers.assert_rail_sequence(rails, { "left", "left", "left", "left" })
end

function mod.TestExecuteEmpty()
   local rails = helpers.assert_compilation_succeeds("")
   lu.assertEquals(#rails, 0)
end

function mod.TestExecuteError()
   helpers.assert_compilation_fails("l rep 3", "unexpected_token", "Unexpected token 'rep'")
end

function mod.TestExecuteInvalidToken()
   helpers.assert_compilation_fails("x y z", "unexpected_token")
end

function mod.TestVersion()
   lu.assertNotNil(Syntrax.VERSION)
   lu.assertStrContains(Syntrax.VERSION, "dev")
end

function mod.TestRailStructure()
   local rails = helpers.assert_compilation_succeeds("l r")
   lu.assertEquals(#rails, 2)

   -- First rail has no parent
   helpers.assert_rail_connects_to(rails, 1, nil)
   lu.assertNotNil(rails[1].incoming_direction)
   lu.assertNotNil(rails[1].outgoing_direction)

   -- Second rail's parent is the first
   helpers.assert_rail_connects_to(rails, 2, 1)
   lu.assertEquals(rails[2].incoming_direction, rails[1].outgoing_direction)
end

return mod
