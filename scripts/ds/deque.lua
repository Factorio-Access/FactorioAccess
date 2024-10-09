--[[
A double-ended queue based on: https://www.lua.org/pil/11.4.html

That's a long resource.  The idea is much simpler than the chapter: maintain two
indices for the bottom and top, then use the fact that Lua allows "moving" the
array upward forever at the cost of becoming a hashtable.

This is global-safe.

The one complexity is that Lua is one-based.  We therefore copy the above's
convension of `front = back = somenumber` being a queue with one item, not 0.
]]

local mod = {}

---@class fa.ds.Deque
---@field front number
---@field back number
---@field items table<number, any>
local Deque = {}
local deque_meta = { __index = Deque }

-- We want to be able to poke at this outside Factorio for debugging.
if script then script.register_metatable("fa.ds.Deque", deque_meta) end
mod.Deque = Deque

---@returns fa.ds.Deque
function Deque.new()
   local state = {
      front = 1,
      back = 0,
      items = {},
   }

   setmetatable(state, deque_meta)
   return state
end

function Deque:push_front(item)
   -- Front is either pointing at nothing (empty queue) or at a valid item.
   local f = self.front - 1
   self.items[f] = item
   self.front = f
end

function Deque:push_back(item)
   -- Back is either pointing at a valid item or the queue is empty.
   local b = self.back + 1
   self.items[b] = item
   self.back = b
end

---@returns bool
function Deque:is_empty()
   return self.back < self.front
end

---@returns any?
function Deque:pop_front()
   local f = self.front
   local b = self.back
   if b < f then return nil end
   local r = self.items[f]
   self.items[f] = nil
   self.front = f + 1
   return r
end

---@returns any?
function Deque:pop_back()
   local f = self.front
   local b = self.back
   if b < f then return nil end
   local r = self.items[b]
   self.items[b] = nil
   self.back = b - 1
   return r
end

function Deque:clear()
   self.front = 1
   self.back = 0
   self.items = {}
   self.items = {}
end

-- Some quick self-tests.
local test_d = Deque.new()
assert(test_d:is_empty())
test_d:push_back(1)
assert(test_d:pop_front() == 1)
test_d:push_back(1)
test_d:push_back(2)
test_d:push_back(3)
assert(test_d:pop_back() == 3)
assert(test_d:pop_front() == 1)
assert(not test_d:is_empty())
test_d:clear()
assert(test_d:is_empty())

return mod
