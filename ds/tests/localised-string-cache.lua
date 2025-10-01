---Localised String Cache tests

local LocalisedStringCache = require("ds.localised-string-cache")
local utils = require("ds.tests.test-utils")

local assert_equals = utils.assert_equals
local assert_true = utils.assert_true
local assert_false = utils.assert_false
local assert_nil = utils.assert_nil

local tests = {}

function tests.canonicalize_simple()
   local cache = LocalisedStringCache.new(10)

   local str1 = { "entity-name.iron-ore" }
   local str2 = { "entity-name.iron-ore" }

   local canonical1 = cache:canonicalize(str1)
   local canonical2 = cache:canonicalize(str2)

   assert_equals(canonical1, canonical2, "Should return same canonical reference")
   assert_equals(str1, canonical1, "First canonical should be str1")
end

function tests.canonicalize_nested()
   local cache = LocalisedStringCache.new(10)

   local str1 = { "my-string", { "nested", "values" }, 42 }
   local str2 = { "my-string", { "nested", "values" }, 42 }

   local canonical1 = cache:canonicalize(str1)
   local canonical2 = cache:canonicalize(str2)

   assert_equals(canonical1, canonical2, "Should return same canonical for nested")
end

function tests.different_strings()
   local cache = LocalisedStringCache.new(10)

   local str1 = { "entity-name.iron-ore" }
   local str2 = { "entity-name.copper-ore" }

   local canonical1 = cache:canonicalize(str1)
   local canonical2 = cache:canonicalize(str2)

   assert_true(canonical1 ~= canonical2, "Different strings should have different canonicals")
end

function tests.get_put()
   local cache = LocalisedStringCache.new(10)

   local str = { "entity-name.iron-ore" }

   cache:put(str, "Iron ore")
   assert_equals("Iron ore", cache:get(str), "Should get translated text")
end

function tests.lru_eviction()
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

function tests.remove()
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

function tests.trie_cleanup()
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

function tests.has_method()
   local cache = LocalisedStringCache.new(10)

   local str = { "entity-name.iron-ore" }

   assert_false(cache:has(str), "Should not have translation initially")

   cache:put(str, "Iron ore")
   assert_true(cache:has(str), "Should have translation after put")
end

function tests.with_numbers()
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

function tests.empty_string()
   local cache = LocalisedStringCache.new(10)

   local str = { "" }
   cache:put(str, "Empty")

   assert_equals("Empty", cache:get(str), "Should handle empty string")
end

function tests.deeply_nested()
   local cache = LocalisedStringCache.new(10)

   local str1 = { "a", { "b", { "c", { "d" } } } }
   local str2 = { "a", { "b", { "c", { "d" } } } }

   local c1 = cache:canonicalize(str1)
   local c2 = cache:canonicalize(str2)

   assert_equals(c1, c2, "Deeply nested should canonicalize correctly")
end

function tests.multiple_tables()
   local cache = LocalisedStringCache.new(10)

   local str1 = { "a", { "b" }, { "c" } }
   local str2 = { "a", { "b" }, { "c" } }

   local c1 = cache:canonicalize(str1)
   local c2 = cache:canonicalize(str2)

   assert_equals(c1, c2, "Multiple tables should canonicalize correctly")
end

function tests.different_nesting()
   local cache = LocalisedStringCache.new(10)

   local str1 = { "a", "b", "c" }
   local str2 = { "a", { "b" }, "c" }

   local c1 = cache:canonicalize(str1)
   local c2 = cache:canonicalize(str2)

   assert_true(c1 ~= c2, "Different nesting should produce different canonicals")
end

function tests.clear()
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

return tests
