---LRU Cache tests

local LRUCache = require("ds.lru-cache")
local utils = require("ds.tests.test-utils")

local assert_equals = utils.assert_equals
local assert_true = utils.assert_true
local assert_false = utils.assert_false
local assert_nil = utils.assert_nil

local tests = {}

function tests.basic_operations()
   local cache = LRUCache.new(2)

   cache:put("a", 1)
   assert_equals(1, cache:get("a"), "Should get value 1 for key 'a'")
   assert_equals(1, cache:get_size(), "Size should be 1")

   cache:put("b", 2)
   assert_equals(2, cache:get("b"), "Should get value 2 for key 'b'")
   assert_equals(2, cache:get_size(), "Size should be 2")
end

function tests.lru_eviction()
   local cache = LRUCache.new(2)

   cache:put("a", 1)
   cache:put("b", 2)
   cache:put("c", 3)

   assert_nil(cache:get("a"), "Key 'a' should be evicted")
   assert_equals(2, cache:get("b"), "Key 'b' should still exist")
   assert_equals(3, cache:get("c"), "Key 'c' should exist")
   assert_equals(2, cache:get_size(), "Size should be 2")
end

function tests.update_marks_used()
   local cache = LRUCache.new(2)

   cache:put("a", 1)
   cache:put("b", 2)
   cache:get("a")
   cache:put("c", 3)

   assert_equals(1, cache:get("a"), "Key 'a' should still exist")
   assert_nil(cache:get("b"), "Key 'b' should be evicted")
   assert_equals(3, cache:get("c"), "Key 'c' should exist")
end

function tests.put_marks_used()
   local cache = LRUCache.new(2)

   cache:put("a", 1)
   cache:put("b", 2)
   cache:put("a", 10)
   cache:put("c", 3)

   assert_equals(10, cache:get("a"), "Key 'a' should be updated and exist")
   assert_nil(cache:get("b"), "Key 'b' should be evicted")
   assert_equals(3, cache:get("c"), "Key 'c' should exist")
end

function tests.remove()
   local cache = LRUCache.new(3)

   cache:put("a", 1)
   cache:put("b", 2)
   cache:put("c", 3)

   local removed = cache:remove("b")
   assert_equals(2, removed, "Should return removed value")
   assert_nil(cache:get("b"), "Key 'b' should be removed")
   assert_equals(2, cache:get_size(), "Size should be 2")
end

function tests.clear()
   local cache = LRUCache.new(3)

   cache:put("a", 1)
   cache:put("b", 2)
   cache:clear()

   assert_equals(0, cache:get_size(), "Size should be 0")
   assert_nil(cache:get("a"), "Key 'a' should be gone")
end

function tests.has_method()
   local cache = LRUCache.new(3)

   cache:put("a", 1)
   assert_true(cache:has("a"), "Should have key 'a'")
   assert_false(cache:has("b"), "Should not have key 'b'")
end

function tests.explicit_evict_lru()
   local cache = LRUCache.new(3)

   cache:put("a", 1)
   cache:put("b", 2)
   cache:put("c", 3)

   local evicted = cache:evict_lru()
   assert_equals("a", evicted, "Should evict 'a'")
   assert_equals(2, cache:get_size(), "Size should be 2 after eviction")
   assert_nil(cache:get("a"), "Key 'a' should be evicted")
end

function tests.table_keys()
   local cache = LRUCache.new(2)

   local key1 = { "foo" }
   local key2 = { "bar" }

   cache:put(key1, "value1")
   cache:put(key2, "value2")

   assert_equals("value1", cache:get(key1), "Should handle table keys")
   assert_equals("value2", cache:get(key2), "Should handle table keys")
end

return tests
