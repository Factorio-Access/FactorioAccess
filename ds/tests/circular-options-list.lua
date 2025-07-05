local lu = require("luaunit")
local col = require("ds.circular-options-list")

local mod = {}

function mod.TestBasicOperations()
   local list = col.kv_list({
      { 1, "first" },
      { 2, "second" },
      { 3, "third" },
   })
   
   -- Test current
   local current = col.current(list, 2)
   lu.assertEquals(current.key, 2)
   lu.assertEquals(current.value, "second")
   lu.assertFalse(current.wrapped)
   
   -- Test next
   local next_item = col.next(list, 2)
   lu.assertEquals(next_item.key, 3)
   lu.assertEquals(next_item.value, "third")
   lu.assertFalse(next_item.wrapped)
   
   -- Test prev
   local prev_item = col.prev(list, 2)
   lu.assertEquals(prev_item.key, 1)
   lu.assertEquals(prev_item.value, "first")
   lu.assertFalse(prev_item.wrapped)
end

function mod.TestWraparound()
   local list = col.kv_list({
      { "a", 1 },
      { "b", 2 },
      { "c", 3 },
   })
   
   -- Test wrap from end to beginning
   local next_item = col.next(list, "c")
   lu.assertEquals(next_item.key, "a")
   lu.assertEquals(next_item.value, 1)
   lu.assertTrue(next_item.wrapped)
   
   -- Test wrap from beginning to end
   local prev_item = col.prev(list, "a")
   lu.assertEquals(prev_item.key, "c")
   lu.assertEquals(prev_item.value, 3)
   lu.assertTrue(prev_item.wrapped)
end

function mod.TestSingleElement()
   local list = col.kv_list({
      { "only", "one" },
   })
   
   -- Current should work
   local current = col.current(list, "only")
   lu.assertEquals(current.key, "only")
   lu.assertEquals(current.value, "one")
   
   -- Next and prev should wrap to itself
   local next_item = col.next(list, "only")
   lu.assertEquals(next_item.key, "only")
   lu.assertEquals(next_item.value, "one")
   lu.assertTrue(next_item.wrapped)
   
   local prev_item = col.prev(list, "only")
   lu.assertEquals(prev_item.key, "only")
   lu.assertEquals(prev_item.value, "one")
   lu.assertTrue(prev_item.wrapped)
end

function mod.TestComplexValues()
   local list = col.kv_list({
      { "state1", { name = "idle", speed = 0 } },
      { "state2", { name = "walking", speed = 5 } },
      { "state3", { name = "running", speed = 10 } },
   })
   
   local current = col.current(list, "state2")
   lu.assertEquals(current.value.name, "walking")
   lu.assertEquals(current.value.speed, 5)
   
   local next_item = col.next(list, "state2")
   lu.assertEquals(next_item.value.name, "running")
   lu.assertEquals(next_item.value.speed, 10)
end

function mod.TestCustomComparer()
   -- Test with tuple comparer
   local list = col.kv_list({
      { {1, 2}, "first" },
      { {3, 4}, "second" },
      { {5, 6}, "third" },
   }, col.tuples)
   
   local current = col.current(list, {3, 4})
   lu.assertEquals(current.value, "second")
   
   local next_item = col.next(list, {3, 4})
   lu.assertEquals(next_item.key[1], 5)
   lu.assertEquals(next_item.key[2], 6)
   lu.assertEquals(next_item.value, "third")
end

function mod.TestAnyWildcard()
   -- Test with ANY wildcard in tuples
   local list = col.kv_list({
      { {1, col.ANY}, "first" },
      { {2, 5}, "second" },
      { {3, col.ANY}, "third" },
   }, col.tuples)
   
   -- Should match with ANY
   local current = col.current(list, {1, 999})
   lu.assertEquals(current.value, "first")
   
   -- Should also match with exact value
   current = col.current(list, {1, col.ANY})
   lu.assertEquals(current.value, "first")
   
   -- Next from a wildcard match
   local next_item = col.next(list, {1, 42})
   lu.assertEquals(next_item.key[1], 2)
   lu.assertEquals(next_item.key[2], 5)
   lu.assertEquals(next_item.value, "second")
end

function mod.TestErrorOnMissingKey()
   local list = col.kv_list({
      { 1, "first" },
      { 2, "second" },
   })
   
   -- Should throw error for non-existent key
   lu.assertError(function()
      col.current(list, 999)
   end)
   
   lu.assertError(function()
      col.next(list, "nonexistent")
   end)
   
   lu.assertError(function()
      col.prev(list, nil)
   end)
end

return mod