--- Test Registry
-- Provides test registration functions (describe, it, etc.) separate from the test runner
-- This avoids circular dependencies when test files need to import these functions

local Logging = require("scripts.logging")
local logger = Logging.Logger("TestRegistry")

local mod = {}

-- Test suite storage
local test_suites = {}
local current_suite = nil

-- Assertion helpers that will be injected into test contexts
local assertions = {}

--- Assert that a value is truthy
function assertions.assert(value, message)
   if not value then error(message or "Assertion failed: expected truthy value", 2) end
end

--- Assert that two values are equal
function assertions.assert_equals(expected, actual, message)
   if expected ~= actual then
      local msg = message
         or string.format("Assertion failed: expected %s, got %s", serpent.line(expected), serpent.line(actual))
      error(msg, 2)
   end
end

--- Assert that two tables are equal (deep comparison)
function assertions.assert_table_equals(expected, actual, message)
   local function deep_equals(t1, t2)
      if type(t1) ~= "table" or type(t2) ~= "table" then return t1 == t2 end

      -- Check all keys in t1
      for k, v in pairs(t1) do
         if not deep_equals(v, t2[k]) then return false end
      end

      -- Check all keys in t2
      for k, v in pairs(t2) do
         if not deep_equals(v, t1[k]) then return false end
      end

      return true
   end

   if not deep_equals(expected, actual) then
      local msg = message
         or string.format(
            "Assertion failed: tables not equal\nExpected: %s\nActual: %s",
            serpent.block(expected),
            serpent.block(actual)
         )
      error(msg, 2)
   end
end

--- Assert that a value is nil
function assertions.assert_nil(value, message)
   if value ~= nil then
      local msg = message or string.format("Assertion failed: expected nil, got %s", serpent.line(value))
      error(msg, 2)
   end
end

--- Assert that a value is not nil
function assertions.assert_not_nil(value, message)
   if value == nil then error(message or "Assertion failed: expected non-nil value", 2) end
end

--- Assert that two values are not equal
function assertions.assert_not_equals(expected, actual, message)
   if expected == actual then
      local msg = message
         or string.format("Assertion failed: expected values to be different\nBoth values: %s", serpent.line(expected))
      error(msg, 2)
   end
end

--- Assert that a function throws an error
function assertions.assert_error(func, message)
   local success = pcall(func)
   if success then error(message or "Assertion failed: expected error but none was thrown", 2) end
end

--- Define a test suite
function mod.describe(suite_name, suite_func)
   local suite = {
      name = suite_name,
      tests = {},
      before_all = nil,
      after_all = nil,
      before_each = nil,
      after_each = nil,
   }

   current_suite = suite
   suite_func()
   current_suite = nil

   -- Add suite to test_suites
   table.insert(test_suites, suite)

   logger:info("Registered test suite: " .. suite_name .. " with " .. #suite.tests .. " tests")
end

--- Define a test within a suite
function mod.it(test_name, test_func)
   if not current_suite then error("it() must be called within a describe() block") end

   table.insert(current_suite.tests, {
      name = test_name,
      func = test_func,
   })
end

--- Setup function to run before all tests in a suite
function mod.before_all(func)
   if not current_suite then error("before_all() must be called within a describe() block") end
   current_suite.before_all = func
end

--- Setup function to run after all tests in a suite
function mod.after_all(func)
   if not current_suite then error("after_all() must be called within a describe() block") end
   current_suite.after_all = func
end

--- Setup function to run before each test
function mod.before_each(func)
   if not current_suite then error("before_each() must be called within a describe() block") end
   current_suite.before_each = func
end

--- Teardown function to run after each test
function mod.after_each(func)
   if not current_suite then error("after_each() must be called within a describe() block") end
   current_suite.after_each = func
end

--- Get all registered test suites
function mod.get_test_suites()
   return test_suites
end

--- Get assertion helpers
function mod.get_assertions()
   return assertions
end

--- Clear all test suites (useful for testing the test framework)
function mod.clear_suites()
   test_suites = {}
   current_suite = nil
end

return mod
