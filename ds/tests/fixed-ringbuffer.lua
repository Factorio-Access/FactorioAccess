local lu = require("luaunit")
local RingBuffer = require("ds.fixed-ringbuffer")

local mod = {}

function mod.TestNew()
   local rb = RingBuffer.new(5)
   lu.assertNotNil(rb)
   lu.assertEquals(rb.capacity, 5)
end

function mod.TestPushAndGet()
   local rb = RingBuffer.new(3)

   rb:push("a")
   lu.assertEquals(rb:get(0), "a")

   rb:push("b")
   lu.assertEquals(rb:get(0), "b")
   lu.assertEquals(rb:get(1), "a")

   rb:push("c")
   lu.assertEquals(rb:get(0), "c")
   lu.assertEquals(rb:get(1), "b")
   lu.assertEquals(rb:get(2), "a")
end

function mod.TestOverwrite()
   local rb = RingBuffer.new(3)

   rb:push(1)
   rb:push(2)
   rb:push(3)
   rb:push(4)

   lu.assertEquals(rb:get(0), 4)
   lu.assertEquals(rb:get(1), 3)
   lu.assertEquals(rb:get(2), 2)

   rb:push(5)
   lu.assertEquals(rb:get(0), 5)
   lu.assertEquals(rb:get(1), 4)
   lu.assertEquals(rb:get(2), 3)
end

function mod.TestOutOfBounds()
   local rb = RingBuffer.new(5)

   lu.assertNil(rb:get(0))
   lu.assertNil(rb:get(-1))

   rb:push("a")
   rb:push("b")

   lu.assertEquals(rb:get(0), "b")
   lu.assertEquals(rb:get(1), "a")
   lu.assertNil(rb:get(2))
   lu.assertNil(rb:get(3))
end

function mod.TestLargeBuffer()
   local rb = RingBuffer.new(100)

   for i = 1, 150 do
      rb:push(i)
   end

   for i = 0, 99 do
      lu.assertEquals(rb:get(i), 150 - i)
   end
end

function mod.TestNilValues()
   local rb = RingBuffer.new(3)

   rb:push(nil)
   rb:push("a")
   rb:push(nil)

   lu.assertNil(rb:get(0))
   lu.assertEquals(rb:get(1), "a")
   lu.assertNil(rb:get(2))
end

function mod.TestSingleCapacity()
   local rb = RingBuffer.new(1)

   rb:push("first")
   lu.assertEquals(rb:get(0), "first")

   rb:push("second")
   lu.assertEquals(rb:get(0), "second")
end

function mod.TestSequentialWrapping()
   local rb = RingBuffer.new(4)

   for i = 1, 10 do
      rb:push(i)

      for j = 0, math.min(i - 1, 3) do
         lu.assertEquals(rb:get(j), i - j)
      end
   end
end

return mod
