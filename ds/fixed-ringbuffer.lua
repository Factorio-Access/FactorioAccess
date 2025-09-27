--[[
A fixed sized ringbuffer. 0 is now and positive indices are "into the past".

This is safe to store in storage: the metatable is registered with Factorio.
]]
---@class fa.ds.FixedRingBuffer
---@field head integer
---@field capacity integer
---@field buffer table
local RingBuffer = {}
local RingBuffer_meta = { __index = RingBuffer }
if script then script.register_metatable("ds.FixedRingBuffer", RingBuffer_meta) end

---@param capacity integer
---@return fa.ds.FixedRingBuffer
function RingBuffer.new(capacity)
   assert(capacity > 0, "Capacity must be positive")
   local self = setmetatable({}, RingBuffer_meta)
   self.capacity = capacity
   self.head = 0

   self.buffer = {}
   return self
end

---@param relative_index integer
---@return integer
function RingBuffer:_map_index(relative_index)
   local rind_zero = (self.head - relative_index - 1 + self.capacity) % self.capacity
   return rind_zero + 1
end

---@param relative_index integer
---@return any
function RingBuffer:get(relative_index)
   local actual_index = self:_map_index(relative_index)
   return self.buffer[actual_index]
end

---@param value any
function RingBuffer:push(value)
   self.head = (self.head % self.capacity) + 1
   self.buffer[self.head] = value
end

return RingBuffer
