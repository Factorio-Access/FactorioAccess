local lu = require("luaunit")
local SparseBitsetModule = require("ds.sparse-bitset")
local SparseBitset = SparseBitsetModule.SparseBitset

local mod = {}

function mod.TestBasicOperations()
   local set = SparseBitset.new()
   
   -- Test empty set
   lu.assertFalse(set:test(0))
   lu.assertFalse(set:test(100))
   lu.assertFalse(set:test(1000000))
   
   -- Test set and test
   set:set(5)
   set:set(100)
   set:set(1000000)
   
   lu.assertTrue(set:test(5))
   lu.assertTrue(set:test(100))
   lu.assertTrue(set:test(1000000))
   lu.assertFalse(set:test(6))
   lu.assertFalse(set:test(99))
   
   -- Test remove
   set:remove(100)
   lu.assertFalse(set:test(100))
   lu.assertTrue(set:test(5))
   lu.assertTrue(set:test(1000000))
end

function mod.TestLargeSparseSet()
   local set = SparseBitset.new()
   
   -- Set some very sparse bits
   set:set(0)
   set:set(1000)
   set:set(1000000)
   set:set(1000000000)
   
   -- Verify they're set
   lu.assertTrue(set:test(0))
   lu.assertTrue(set:test(1000))
   lu.assertTrue(set:test(1000000))
   lu.assertTrue(set:test(1000000000))
   
   -- Verify others are not set
   for i = 1, 999 do
      lu.assertFalse(set:test(i))
   end
end

function mod.TestBitPatterns()
   local set = SparseBitset.new()
   
   -- Set every other bit in a chunk
   for i = 0, 63 do
      if i % 2 == 0 then
         set:set(i)
      end
   end
   
   -- Verify pattern
   for i = 0, 63 do
      if i % 2 == 0 then
         lu.assertTrue(set:test(i))
      else
         lu.assertFalse(set:test(i))
      end
   end
end

function mod.TestChunkBoundaries()
   local set = SparseBitset.new()
   
   -- Test around chunk boundaries (chunks are 32 bits)
   set:set(31)
   set:set(32)
   set:set(33)
   
   lu.assertTrue(set:test(31))
   lu.assertTrue(set:test(32))
   lu.assertTrue(set:test(33))
   
   -- Test multiple chunk boundaries
   set:set(63)
   set:set(64)
   set:set(95)
   set:set(96)
   
   lu.assertTrue(set:test(63))
   lu.assertTrue(set:test(64))
   lu.assertTrue(set:test(95))
   lu.assertTrue(set:test(96))
end

function mod.TestToggling()
   local set = SparseBitset.new()
   
   -- Toggle bits on
   for i = 1, 10 do
      set:set(i)
   end
   
   for i = 1, 10 do
      lu.assertTrue(set:test(i))
   end
   
   -- Toggle them off
   for i = 1, 10 do
      set:remove(i)
   end
   
   for i = 1, 10 do
      lu.assertFalse(set:test(i))
   end
   
   -- Toggle back on
   for i = 1, 10 do
      set:set(i)
   end
   
   for i = 1, 10 do
      lu.assertTrue(set:test(i))
   end
end

function mod.TestRemoveReturnValue()
   local set = SparseBitset.new()
   
   -- Test remove on unset bit returns false
   lu.assertFalse(set:remove(42))
   
   -- Set bit and test remove returns true
   set:set(42)
   lu.assertTrue(set:remove(42))
   
   -- Remove again should return false
   lu.assertFalse(set:remove(42))
end

function mod.TestVeryLargeIndex()
   local set = SparseBitset.new()
   
   -- Test with a very large index
   local huge_index = 2^30  -- 1 billion+
   set:set(huge_index)
   lu.assertTrue(set:test(huge_index))
   lu.assertFalse(set:test(huge_index - 1))
   lu.assertFalse(set:test(huge_index + 1))
end

function mod.TestEdgeCases()
   local set = SparseBitset.new()
   
   -- Test bit 0
   set:set(0)
   lu.assertTrue(set:test(0))
   
   -- Test clearing entire chunks
   for i = 0, 31 do
      set:set(i)
   end
   
   for i = 0, 31 do
      lu.assertTrue(set:test(i))
   end
   
   -- Remove all bits in the chunk
   for i = 0, 31 do
      set:remove(i)
   end
   
   -- Verify chunk is cleared
   for i = 0, 31 do
      lu.assertFalse(set:test(i))
   end
end

return mod