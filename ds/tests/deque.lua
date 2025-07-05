local lu = require("luaunit")
local DequeModule = require("ds.deque")
local Deque = DequeModule.Deque

local mod = {}

-- Helper function since deque doesn't have len()
local function deque_len(d)
   if d:is_empty() then return 0 end
   return d.back - d.front + 1
end

function mod.TestBasicOperations()
   local d = Deque.new()

   -- Test empty deque
   lu.assertTrue(d:is_empty())
   lu.assertNil(d:pop_front())
   lu.assertNil(d:pop_back())

   -- Test push_back and pop_front (FIFO behavior)
   d:push_back(1)
   d:push_back(2)
   d:push_back(3)
   lu.assertEquals(deque_len(d), 3)
   lu.assertFalse(d:is_empty())

   lu.assertEquals(d:pop_front(), 1)
   lu.assertEquals(d:pop_front(), 2)
   lu.assertEquals(d:pop_front(), 3)
   lu.assertTrue(d:is_empty())

   -- Test push_front and pop_back (reverse FIFO)
   d:push_front(1)
   d:push_front(2)
   d:push_front(3)
   lu.assertEquals(deque_len(d), 3)

   lu.assertEquals(d:pop_back(), 1)
   lu.assertEquals(d:pop_back(), 2)
   lu.assertEquals(d:pop_back(), 3)
   lu.assertTrue(d:is_empty())
end

function mod.TestMixedOperations()
   local d = Deque.new()

   -- Mix push_front and push_back
   d:push_front(1)
   d:push_back(2)
   d:push_front(3)
   d:push_back(4)
   -- Should be: [3, 1, 2, 4]

   lu.assertEquals(d:pop_front(), 3)
   lu.assertEquals(d:pop_back(), 4)
   lu.assertEquals(d:pop_front(), 1)
   lu.assertEquals(d:pop_back(), 2)
   lu.assertTrue(d:is_empty())
end

function mod.TestLargeQueue()
   local d = Deque.new()
   local n = 1000

   -- Push many elements
   for i = 1, n do
      d:push_back(i)
   end

   lu.assertEquals(deque_len(d), n)

   -- Pop all elements in order
   for i = 1, n do
      lu.assertEquals(d:pop_front(), i)
   end

   lu.assertTrue(d:is_empty())
end

function mod.TestAlternatingPushPop()
   local d = Deque.new()

   -- Alternate between push and pop to test ring buffer behavior
   for i = 1, 100 do
      d:push_back(i)
      if i > 50 then lu.assertEquals(d:pop_front(), i - 50) end
   end

   -- Should have elements 51-100 remaining
   lu.assertEquals(deque_len(d), 50)

   for i = 51, 100 do
      lu.assertEquals(d:pop_front(), i)
   end

   lu.assertTrue(d:is_empty())
end

function mod.TestClear()
   local d = Deque.new()

   -- Add some elements
   for i = 1, 10 do
      d:push_back(i)
   end

   lu.assertFalse(d:is_empty())

   -- Clear and verify
   d:clear()
   lu.assertTrue(d:is_empty())
   lu.assertNil(d:pop_front())
   lu.assertNil(d:pop_back())
end

return mod
