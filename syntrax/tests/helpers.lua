local lu = require("luaunit")
local Syntrax = require("syntrax")

local mod = {}

--- Deep copy the table, breaking any loops/recursive references. Useful to get luaunit to print in a way that lets one
--  paste values from the terminal.
function mod.deepcopy_unrecursive(tab)
   local res = {}

   for k, v in pairs(tab) do
      if type(v) == "table" then v = mod.deepcopy_unrecursive(v) end
      res[k] = v
   end

   return res
end

---Execute Syntrax code and assert it compiles successfully
---@param source string The Syntrax source code
---@param initial_position fa.Point? Optional initial position
---@param initial_direction number? Optional initial direction
---@return syntrax.vm.RailPlacement[] The generated rails
function mod.assert_compilation_succeeds(source, initial_position, initial_direction)
   local rails, err = Syntrax.execute(source, initial_position, initial_direction)
   if err then
      -- Provide helpful error message that includes the source
      lu.fail(string.format("Expected compilation to succeed for:\n%s\nBut got error: %s", source, err.message))
   end
   lu.assertNotNil(rails)
   assert(rails)
   return rails
end

---Execute Syntrax code and assert it fails with expected error
---@param source string The Syntrax source code
---@param expected_error_code string Expected error code
---@param expected_message_pattern string? Optional pattern to match in error message
---@return syntrax.Error The error object
function mod.assert_compilation_fails(source, expected_error_code, expected_message_pattern)
   local rails, err = Syntrax.execute(source)
   lu.assertNil(rails)
   lu.assertNotNil(err)
   assert(err)
   lu.assertEquals(err.code, expected_error_code)
   if expected_message_pattern then lu.assertStrContains(err.message, expected_message_pattern) end
   return err
end

-- Movement kind to rail type mapping (for test compatibility)
-- Note: actual rail types depend on geometry, but basic movements produce these:
local MOVEMENT_TO_RAIL_TYPE = {
   left = nil, -- curves vary, so we don't check specific type
   right = nil, -- curves vary
   straight = "straight-rail",
}

---Assert that rails match expected count (simplified from old kind-based checking)
---The new output format uses rail_type instead of movement kind, so we just verify count.
---@param rails syntrax.vm.RailPlacement[]
---@param expected_kinds string[] Movement kinds (for count, types are ignored)
function mod.assert_rail_sequence(rails, expected_kinds)
   lu.assertEquals(#rails, #expected_kinds, string.format("Expected %d rails but got %d", #expected_kinds, #rails))
   -- With new format, we verify positions exist rather than movement types
   for i, _ in ipairs(expected_kinds) do
      lu.assertNotNil(rails[i].position, string.format("Rail %d missing position", i))
      lu.assertNotNil(rails[i].rail_type, string.format("Rail %d missing rail_type", i))
   end
end

---Assert a rail exists at the given index
---@param rails syntrax.vm.RailPlacement[]
---@param rail_index number The rail to check (1-based)
---@param comment string? Optional comment explaining why
function mod.assert_rail_exists(rails, rail_index, comment)
   local rail = rails[rail_index]
   local message = string.format("Rail %d should exist", rail_index)
   if comment then message = message .. " (" .. comment .. ")" end
   lu.assertNotNil(rail, message)
end

---Assert rail has expected placement direction
---@param rails syntrax.vm.RailPlacement[]
---@param rail_index number
---@param expected_direction number Expected placement direction (0-15)
function mod.assert_rail_placement_direction(rails, rail_index, expected_direction)
   local rail = rails[rail_index]
   lu.assertNotNil(rail, string.format("Rail %d does not exist", rail_index))
   lu.assertEquals(
      rail.placement_direction,
      expected_direction,
      string.format("Rail %d placement direction", rail_index)
   )
end

---Assert rail has expected position
---@param rails syntrax.vm.RailPlacement[]
---@param rail_index number
---@param expected_x number
---@param expected_y number
function mod.assert_rail_position(rails, rail_index, expected_x, expected_y)
   local rail = rails[rail_index]
   lu.assertNotNil(rail, string.format("Rail %d does not exist", rail_index))
   lu.assertEquals(rail.position.x, expected_x, string.format("Rail %d x position", rail_index))
   lu.assertEquals(rail.position.y, expected_y, string.format("Rail %d y position", rail_index))
end

---Helper to create a table-driven test case
---@class TestCase
---@field source string The Syntrax source
---@field initial_position fa.Point? Optional initial position
---@field initial_direction number? Optional initial direction
---@field expected_count number Expected number of rails
---@field expected_kinds string[]? Expected sequence of rail kinds (for count verification)
---@field expected_error string? Expected error code (for failure cases)
---@field error_pattern string? Expected error message pattern

---Run a table-driven test case
---@param test_case TestCase
---@return syntrax.vm.RailPlacement[]? rails
function mod.run_test_case(test_case)
   if test_case.expected_error then
      mod.assert_compilation_fails(test_case.source, test_case.expected_error, test_case.error_pattern)
      return nil
   else
      local rails =
         mod.assert_compilation_succeeds(test_case.source, test_case.initial_position, test_case.initial_direction)

      lu.assertEquals(#rails, test_case.expected_count)

      if test_case.expected_kinds then mod.assert_rail_sequence(rails, test_case.expected_kinds) end

      return rails
   end
end

return mod
