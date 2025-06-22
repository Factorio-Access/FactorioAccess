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
---@param initial_rail number? Optional initial rail
---@param initial_direction number? Optional initial direction
---@return syntrax.vm.Rail[] The generated rails
function mod.assert_compilation_succeeds(source, initial_rail, initial_direction)
   local rails, err = Syntrax.execute(source, initial_rail, initial_direction)
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

---Assert that rails match expected sequence of kinds
---@param rails syntrax.vm.Rail[]
---@param expected_kinds string[]
function mod.assert_rail_sequence(rails, expected_kinds)
   lu.assertEquals(#rails, #expected_kinds, string.format("Expected %d rails but got %d", #expected_kinds, #rails))
   for i, expected_kind in ipairs(expected_kinds) do
      lu.assertEquals(
         rails[i].kind,
         expected_kind,
         string.format("Rail %d: expected %s but got %s", i, expected_kind, rails[i].kind)
      )
   end
end

---Assert a specific rail connects to a parent
---@param rails syntrax.vm.Rail[]
---@param rail_index number The rail to check (1-based)
---@param expected_parent number? The expected parent index (nil for no parent)
---@param comment string? Optional comment explaining why
function mod.assert_rail_connects_to(rails, rail_index, expected_parent, comment)
   local rail = rails[rail_index]
   lu.assertNotNil(rail, string.format("Rail %d does not exist", rail_index))

   local message = string.format("Rail %d parent", rail_index)
   if comment then message = message .. " (" .. comment .. ")" end

   lu.assertEquals(rail.parent, expected_parent, message)
end

---Assert multiple rails all connect to the same parent
---@param rails syntrax.vm.Rail[]
---@param rail_indices number[] The rails to check
---@param expected_parent number? The expected parent index
---@param comment string? Optional comment
function mod.assert_rails_connect_to(rails, rail_indices, expected_parent, comment)
   for _, idx in ipairs(rail_indices) do
      mod.assert_rail_connects_to(rails, idx, expected_parent, comment)
   end
end

---Assert rail has expected direction
---@param rails syntrax.vm.Rail[]
---@param rail_index number
---@param expected_direction number Expected direction (0-15)
---@param direction_type "incoming"|"outgoing"
function mod.assert_rail_direction(rails, rail_index, expected_direction, direction_type)
   local rail = rails[rail_index]
   lu.assertNotNil(rail, string.format("Rail %d does not exist", rail_index))

   local actual = direction_type == "incoming" and rail.incoming_direction or rail.outgoing_direction
   lu.assertEquals(actual, expected_direction, string.format("Rail %d %s direction", rail_index, direction_type))
end

---Helper to create a table-driven test case
---@class TestCase
---@field source string The Syntrax source
---@field initial_rail number? Optional initial rail
---@field initial_direction number? Optional initial direction
---@field expected_count number Expected number of rails
---@field expected_kinds string[]? Expected sequence of rail kinds
---@field expected_error string? Expected error code (for failure cases)
---@field error_pattern string? Expected error message pattern

---Run a table-driven test case
---@param test_case TestCase
---@return syntrax.vm.Rail[]? rails
function mod.run_test_case(test_case)
   if test_case.expected_error then
      mod.assert_compilation_fails(test_case.source, test_case.expected_error, test_case.error_pattern)
      return nil
   else
      local rails =
         mod.assert_compilation_succeeds(test_case.source, test_case.initial_rail, test_case.initial_direction)

      lu.assertEquals(#rails, test_case.expected_count)

      if test_case.expected_kinds then mod.assert_rail_sequence(rails, test_case.expected_kinds) end

      return rails
   end
end

return mod
