---Data structure tests launcher

local utils = require("ds.tests.test-utils")

-- Import test modules
local lru_cache_tests = require("ds.tests.lru-cache")
local localised_string_cache_tests = require("ds.tests.localised-string-cache")

---Run all tests
local function run_all_tests()
   print("=== LRU Cache Tests ===")
   local lru_test_list = {
      { "Basic operations", lru_cache_tests.basic_operations },
      { "LRU eviction", lru_cache_tests.lru_eviction },
      { "Update marks as used", lru_cache_tests.update_marks_used },
      { "Put marks as used", lru_cache_tests.put_marks_used },
      { "Remove", lru_cache_tests.remove },
      { "Clear", lru_cache_tests.clear },
      { "Has method", lru_cache_tests.has_method },
      { "Explicit evict_lru", lru_cache_tests.explicit_evict_lru },
      { "Table keys", lru_cache_tests.table_keys },
   }

   local lru_passed = 0
   for _, test in ipairs(lru_test_list) do
      if utils.run_test(test[1], test[2]) then lru_passed = lru_passed + 1 end
   end

   print("\n=== Localised String Cache Tests ===")
   local localised_test_list = {
      { "Canonicalize simple", localised_string_cache_tests.canonicalize_simple },
      { "Canonicalize nested", localised_string_cache_tests.canonicalize_nested },
      { "Different strings", localised_string_cache_tests.different_strings },
      { "Get/Put", localised_string_cache_tests.get_put },
      { "LRU eviction", localised_string_cache_tests.lru_eviction },
      { "Remove", localised_string_cache_tests.remove },
      { "Trie cleanup", localised_string_cache_tests.trie_cleanup },
      { "Has method", localised_string_cache_tests.has_method },
      { "With numbers", localised_string_cache_tests.with_numbers },
      { "Empty string", localised_string_cache_tests.empty_string },
      { "Deeply nested", localised_string_cache_tests.deeply_nested },
      { "Multiple tables", localised_string_cache_tests.multiple_tables },
      { "Different nesting", localised_string_cache_tests.different_nesting },
      { "Clear", localised_string_cache_tests.clear },
   }

   local localised_passed = 0
   for _, test in ipairs(localised_test_list) do
      if utils.run_test(test[1], test[2]) then localised_passed = localised_passed + 1 end
   end

   print("\n=== Test Summary ===")
   print(string.format("LRU Cache:               %d/%d passed", lru_passed, #lru_test_list))
   print(string.format("Localised String Cache:  %d/%d passed", localised_passed, #localised_test_list))
   print(
      string.format(
         "Total:                   %d/%d passed",
         lru_passed + localised_passed,
         #lru_test_list + #localised_test_list
      )
   )

   if lru_passed == #lru_test_list and localised_passed == #localised_test_list then
      print("\nAll tests passed!")
      return 0
   else
      print("\nSome tests failed!")
      return 1
   end
end

os.exit(run_all_tests())
