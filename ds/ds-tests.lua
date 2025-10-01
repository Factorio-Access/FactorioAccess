---Comprehensive test suite for data structures (pure Lua tests)

local LRUCache = require("ds.lru-cache")
local LocalisedStringCache = require("ds.localised-string-cache")

---Simple assertion functions
local function assert_equals(expected, actual, message)
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

local function assert_true(value, message)
   if not value then error(string.format("Assertion failed: %s", message or "Expected true")) end
end

local function assert_false(value, message)
   if value then error(string.format("Assertion failed: %s", message or "Expected false")) end
end

local function assert_nil(value, message)
   if value ~= nil then
      error(string.format("Assertion failed: %s\nExpected nil, got: %s", message or "", tostring(value)))
   end
end

---Test runner
local function run_test(name, test_fn)
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

---LRU Cache Tests
local function test_lru_basic()
   local cache = LRUCache.new(2)

   cache:put("a", 1)
   assert_equals(1, cache:get("a"), "Should get value 1 for key 'a'")
   assert_equals(1, cache:get_size(), "Size should be 1")

   cache:put("b", 2)
   assert_equals(2, cache:get("b"), "Should get value 2 for key 'b'")
   assert_equals(2, cache:get_size(), "Size should be 2")
end

local function test_lru_eviction()
   local cache = LRUCache.new(2)

   cache:put("a", 1)
   cache:put("b", 2)
   cache:put("c", 3)

   assert_nil(cache:get("a"), "Key 'a' should be evicted")
   assert_equals(2, cache:get("b"), "Key 'b' should still exist")
   assert_equals(3, cache:get("c"), "Key 'c' should exist")
   assert_equals(2, cache:get_size(), "Size should be 2")
end

local function test_lru_update_marks_used()
   local cache = LRUCache.new(2)

   cache:put("a", 1)
   cache:put("b", 2)
   cache:get("a")
   cache:put("c", 3)

   assert_equals(1, cache:get("a"), "Key 'a' should still exist")
   assert_nil(cache:get("b"), "Key 'b' should be evicted")
   assert_equals(3, cache:get("c"), "Key 'c' should exist")
end

local function test_lru_put_marks_used()
   local cache = LRUCache.new(2)

   cache:put("a", 1)
   cache:put("b", 2)
   cache:put("a", 10)
   cache:put("c", 3)

   assert_equals(10, cache:get("a"), "Key 'a' should be updated and exist")
   assert_nil(cache:get("b"), "Key 'b' should be evicted")
   assert_equals(3, cache:get("c"), "Key 'c' should exist")
end

local function test_lru_remove()
   local cache = LRUCache.new(3)

   cache:put("a", 1)
   cache:put("b", 2)
   cache:put("c", 3)

   local removed = cache:remove("b")
   assert_equals(2, removed, "Should return removed value")
   assert_nil(cache:get("b"), "Key 'b' should be removed")
   assert_equals(2, cache:get_size(), "Size should be 2")
end

local function test_lru_clear()
   local cache = LRUCache.new(3)

   cache:put("a", 1)
   cache:put("b", 2)
   cache:clear()

   assert_equals(0, cache:get_size(), "Size should be 0")
   assert_nil(cache:get("a"), "Key 'a' should be gone")
end

local function test_lru_has()
   local cache = LRUCache.new(3)

   cache:put("a", 1)
   assert_true(cache:has("a"), "Should have key 'a'")
   assert_false(cache:has("b"), "Should not have key 'b'")
end

local function test_lru_evict_lru_explicit()
   local cache = LRUCache.new(3)

   cache:put("a", 1)
   cache:put("b", 2)
   cache:put("c", 3)

   local evicted = cache:evict_lru()
   assert_equals("a", evicted, "Should evict 'a'")
   assert_equals(2, cache:get_size(), "Size should be 2 after eviction")
   assert_nil(cache:get("a"), "Key 'a' should be evicted")
end

local function test_lru_table_keys()
   local cache = LRUCache.new(2)

   local key1 = { "foo" }
   local key2 = { "bar" }

   cache:put(key1, "value1")
   cache:put(key2, "value2")

   assert_equals("value1", cache:get(key1), "Should handle table keys")
   assert_equals("value2", cache:get(key2), "Should handle table keys")
end

---Localised String Cache Tests
local function test_localised_canonicalize_simple()
   local cache = LocalisedStringCache.new(10)

   local str1 = { "entity-name.iron-ore" }
   local str2 = { "entity-name.iron-ore" }

   local canonical1 = cache:canonicalize(str1)
   local canonical2 = cache:canonicalize(str2)

   assert_equals(canonical1, canonical2, "Should return same canonical reference")
   assert_equals(str1, canonical1, "First canonical should be str1")
end

local function test_localised_canonicalize_nested()
   local cache = LocalisedStringCache.new(10)

   local str1 = { "my-string", { "nested", "values" }, 42 }
   local str2 = { "my-string", { "nested", "values" }, 42 }

   local canonical1 = cache:canonicalize(str1)
   local canonical2 = cache:canonicalize(str2)

   assert_equals(canonical1, canonical2, "Should return same canonical for nested")
end

local function test_localised_different_strings()
   local cache = LocalisedStringCache.new(10)

   local str1 = { "entity-name.iron-ore" }
   local str2 = { "entity-name.copper-ore" }

   local canonical1 = cache:canonicalize(str1)
   local canonical2 = cache:canonicalize(str2)

   assert_true(canonical1 ~= canonical2, "Different strings should have different canonicals")
end

local function test_localised_get_put()
   local cache = LocalisedStringCache.new(10)

   local str = { "entity-name.iron-ore" }

   cache:put(str, "Iron ore")
   assert_equals("Iron ore", cache:get(str), "Should get translated text")
end

local function test_localised_lru_eviction()
   local cache = LocalisedStringCache.new(2)

   local str1 = { "entity-name.iron-ore" }
   local str2 = { "entity-name.copper-ore" }
   local str3 = { "entity-name.coal" }

   cache:put(str1, "Iron ore")
   cache:put(str2, "Copper ore")
   cache:put(str3, "Coal")

   assert_nil(cache:get(str1), "str1 should be evicted")
   assert_equals("Copper ore", cache:get(str2), "str2 should exist")
   assert_equals("Coal", cache:get(str3), "str3 should exist")
end

local function test_localised_remove()
   local cache = LocalisedStringCache.new(10)

   local str1 = { "entity-name.iron-ore" }
   local str2 = { "entity-name.iron-ore" }

   cache:put(str1, "Iron ore")
   local c1 = cache:canonicalize(str1)
   cache:remove(str1)

   local c2 = cache:canonicalize(str2)
   assert_true(c1 ~= c2, "After removal, should get new canonical")
   assert_nil(cache:get(str1), "Removed string should not have translation")
end

local function test_localised_trie_cleanup()
   local cache = LocalisedStringCache.new(10)

   local str1 = { "a", { "b", "c" }, "d" }
   local str2 = { "a", { "b", "e" }, "d" }

   cache:put(str1, "Translation 1")
   cache:put(str2, "Translation 2")

   local c1 = cache:canonicalize(str1)
   cache:remove(str1)

   assert_equals("Translation 2", cache:get(str2), "str2 should still be accessible")

   local str1_copy = { "a", { "b", "c" }, "d" }
   local c1_new = cache:canonicalize(str1_copy)
   assert_true(c1 ~= c1_new, "Should create new canonical after removal")
end

local function test_localised_has()
   local cache = LocalisedStringCache.new(10)

   local str = { "entity-name.iron-ore" }

   assert_false(cache:has(str), "Should not have translation initially")

   cache:put(str, "Iron ore")
   assert_true(cache:has(str), "Should have translation after put")
end

local function test_localised_with_numbers()
   local cache = LocalisedStringCache.new(10)

   local str1 = { "quantity", 5 }
   local str2 = { "quantity", 5 }
   local str3 = { "quantity", 10 }

   local c1 = cache:canonicalize(str1)
   local c2 = cache:canonicalize(str2)
   local c3 = cache:canonicalize(str3)

   assert_equals(c1, c2, "Same number should give same canonical")
   assert_true(c1 ~= c3, "Different number should give different canonical")
end

local function test_localised_empty_string()
   local cache = LocalisedStringCache.new(10)

   local str = { "" }
   cache:put(str, "Empty")

   assert_equals("Empty", cache:get(str), "Should handle empty string")
end

local function test_localised_deeply_nested()
   local cache = LocalisedStringCache.new(10)

   local str1 = { "a", { "b", { "c", { "d" } } } }
   local str2 = { "a", { "b", { "c", { "d" } } } }

   local c1 = cache:canonicalize(str1)
   local c2 = cache:canonicalize(str2)

   assert_equals(c1, c2, "Deeply nested should canonicalize correctly")
end

local function test_localised_multiple_tables()
   local cache = LocalisedStringCache.new(10)

   local str1 = { "a", { "b" }, { "c" } }
   local str2 = { "a", { "b" }, { "c" } }

   local c1 = cache:canonicalize(str1)
   local c2 = cache:canonicalize(str2)

   assert_equals(c1, c2, "Multiple tables should canonicalize correctly")
end

local function test_localised_different_nesting()
   local cache = LocalisedStringCache.new(10)

   local str1 = { "a", "b", "c" }
   local str2 = { "a", { "b" }, "c" }

   local c1 = cache:canonicalize(str1)
   local c2 = cache:canonicalize(str2)

   assert_true(c1 ~= c2, "Different nesting should produce different canonicals")
end

local function test_localised_clear()
   local cache = LocalisedStringCache.new(10)

   local str = { "entity-name.iron-ore" }
   cache:put(str, "Iron ore")
   local canonical = cache:canonicalize(str)

   cache:clear()

   assert_equals(0, cache:get_size(), "Size should be 0")

   local str_copy = { "entity-name.iron-ore" }
   local new_canonical = cache:canonicalize(str_copy)
   assert_true(canonical ~= new_canonical, "Should get new canonical after clear")
   assert_nil(cache:get(str), "Should not have translation after clear")
end

---Run all tests
local function run_all_tests()
   print("=== LRU Cache Tests ===")
   local lru_tests = {
      { "Basic operations", test_lru_basic },
      { "LRU eviction", test_lru_eviction },
      { "Update marks as used", test_lru_update_marks_used },
      { "Put marks as used", test_lru_put_marks_used },
      { "Remove", test_lru_remove },
      { "Clear", test_lru_clear },
      { "Has method", test_lru_has },
      { "Explicit evict_lru", test_lru_evict_lru_explicit },
      { "Table keys", test_lru_table_keys },
   }

   local lru_passed = 0
   for _, test in ipairs(lru_tests) do
      if run_test(test[1], test[2]) then lru_passed = lru_passed + 1 end
   end

   print("\n=== Localised String Cache Tests ===")
   local localised_tests = {
      { "Canonicalize simple", test_localised_canonicalize_simple },
      { "Canonicalize nested", test_localised_canonicalize_nested },
      { "Different strings", test_localised_different_strings },
      { "Get/Put", test_localised_get_put },
      { "LRU eviction", test_localised_lru_eviction },
      { "Remove", test_localised_remove },
      { "Trie cleanup", test_localised_trie_cleanup },
      { "Has method", test_localised_has },
      { "With numbers", test_localised_with_numbers },
      { "Empty string", test_localised_empty_string },
      { "Deeply nested", test_localised_deeply_nested },
      { "Multiple tables", test_localised_multiple_tables },
      { "Different nesting", test_localised_different_nesting },
      { "Clear", test_localised_clear },
   }

   local localised_passed = 0
   for _, test in ipairs(localised_tests) do
      if run_test(test[1], test[2]) then localised_passed = localised_passed + 1 end
   end

   print("\n=== Test Summary ===")
   print(string.format("LRU Cache:               %d/%d passed", lru_passed, #lru_tests))
   print(string.format("Localised String Cache:  %d/%d passed", localised_passed, #localised_tests))
   print(
      string.format(
         "Total:                   %d/%d passed",
         lru_passed + localised_passed,
         #lru_tests + #localised_tests
      )
   )

   if lru_passed == #lru_tests and localised_passed == #localised_tests then
      print("\nAll tests passed!")
      return 0
   else
      print("\nSome tests failed!")
      return 1
   end
end

os.exit(run_all_tests())
