--[[
What the name says: a sparse bitset.

Handles all values -2^53 to 2^53.  Representation is a table of the bits divided
out by 32 and values of 32 bits for each.

Saves 8x min on memory over the approach of just using a table of bools.
]]

local mod = {}

local band = bit32.band
local bor = bit32.bor
local btest = bit32.btest
local bnot = bit32.bnot
local lshift = bit32.lshift
local floor = math.floor

---@class fa.ds.SparseBitset
---@field bits table<number, number>
local SparseBitset = {}
mod.SparseBitset = SparseBitset
local SparseBitset_meta = { __index = SparseBitset }
if script then script.register_metatable("fa.ds.SparseBitset", SparseBitset_meta) end

---@return fa.ds.SparseBitset
function SparseBitset.new()
   return setmetatable({ bits = {} }, SparseBitset_meta)
end

---@param bit number
---@return boolean
function SparseBitset:test(bit)
   local chunk = floor(bit / 32)
   local data = self.bits[chunk]
   if not data then return false end
   local offset = bit - chunk * 32
   local mask = lshift(1, offset)
   return btest(mask, data)
end

---@param bit number
function SparseBitset:set(bit)
   local chunk = floor(bit / 32)
   local offset = bit - chunk * 32
   local data = self.bits[chunk] or 0
   self.bits[chunk] = bor(lshift(1, offset), data)
end

---@param bit number
---@return boolean whether or not the bit used to be set
function SparseBitset:remove(bit)
   local chunk = floor(bit / 32)
   local data = self.bits[chunk]
   if not data then return false end
   local offset = bit - chunk * 32
   local newdata = band(data, bnot(lshift(1, offset)))
   if newdata == 0 then
      self.bits[chunk] = nil
   else
      self.bits[chunk] = newdata
   end

   -- It's set if what we did cleared a bit.
   return data ~= newdata
end

return mod
