---Test utilities for data structure tests

local mod = {}

---Simple assertion functions
function mod.assert_equals(expected, actual, message)
   if expected ~= actual then
      error(
         string.format(
            "Assertion failed: %s\nExpected: %s\nActual: %s",
            message or "",
            tostring(expected),
            tostring(actual)
         )
      )
   end
end

function mod.assert_true(value, message)
   if not value then error(string.format("Assertion failed: %s", message or "Expected true")) end
end

function mod.assert_false(value, message)
   if value then error(string.format("Assertion failed: %s", message or "Expected false")) end
end

function mod.assert_nil(value, message)
   if value ~= nil then
      error(string.format("Assertion failed: %s\nExpected nil, got: %s", message or "", tostring(value)))
   end
end

---Test runner
function mod.run_test(name, test_fn)
   io.write(string.format("  %-50s ", name))
   io.flush()
   local success, err = pcall(test_fn)
   if success then
      print("PASS")
      return true
   else
      print("FAIL")
      print("    Error: " .. tostring(err))
      return false
   end
end

return mod
