---LRU cache implementation using doubly-linked list and hash map.
---Provides O(1) get, put, and remove operations.
---@class LRUCache
---@field capacity integer Maximum number of items to store
---@field size integer Current number of items in cache
---@field map table<any, table> Map from keys to nodes
---@field head table? Most recently used node
---@field tail table? Least recently used node
local LRUCache = {}
local LRUCache_meta = { __index = LRUCache }
if script then script.register_metatable("ds.LruCache", LRUCache_meta) end

---Create a new node (plain table, no metatable for internal use)
---@param key any
---@param value any
---@return table
local function new_node(key, value)
   return {
      key = key,
      value = value,
      prev = nil,
      next = nil,
   }
end

---Create a new LRU cache
---@param capacity integer Maximum number of items to store
---@return LRUCache
function LRUCache.new(capacity)
   assert(capacity and capacity > 0, "Capacity must be positive")

   local cache = {
      capacity = capacity,
      size = 0,
      map = {}, -- key -> node
      head = nil, -- most recently used
      tail = nil, -- least recently used
   }

   setmetatable(cache, LRUCache_meta)
   return cache
end

---Remove a node from the linked list
---@param node table
function LRUCache:_unlink(node)
   if node.prev then
      node.prev.next = node.next
   else
      self.head = node.next
   end

   if node.next then
      node.next.prev = node.prev
   else
      self.tail = node.prev
   end

   node.prev = nil
   node.next = nil
end

---Add a node to the head of the linked list
---@param node table
function LRUCache:_add_to_head(node)
   node.next = self.head
   node.prev = nil

   if self.head then self.head.prev = node end

   self.head = node

   if not self.tail then self.tail = node end
end

---Move a node to the head (mark as most recently used)
---@param node table
function LRUCache:_move_to_head(node)
   self:_unlink(node)
   self:_add_to_head(node)
end

---Get a value from the cache
---@param key any
---@return any|nil value Value if found, nil otherwise
function LRUCache:get(key)
   local node = self.map[key]
   if node then
      self:_move_to_head(node)
      return node.value
   end
   return nil
end

---Put a key-value pair into the cache
---@param key any
---@param value any
function LRUCache:put(key, value)
   local node = self.map[key]

   if node then
      node.value = value
      self:_move_to_head(node)
   else
      node = new_node(key, value)
      self.map[key] = node
      self:_add_to_head(node)
      self.size = self.size + 1

      if self.size > self.capacity then self:evict_lru() end
   end
end

---Remove a specific key from the cache
---@param key any
---@return any|nil value Removed value if found, nil otherwise
function LRUCache:remove(key)
   local node = self.map[key]
   if node then
      self:_unlink(node)
      self.map[key] = nil
      self.size = self.size - 1
      return node.value
   end
   return nil
end

---Evict the least recently used item
---@return any|nil key Key of evicted item, nil if cache was empty
function LRUCache:evict_lru()
   if self.tail then
      local key = self.tail.key
      self:remove(key)
      return key
   end
   return nil
end

---Get the current size of the cache
---@return integer
function LRUCache:get_size()
   return self.size
end

---Check if a key exists in the cache (does not mark as used)
---@param key any
---@return boolean
function LRUCache:has(key)
   return self.map[key] ~= nil
end

---Clear all items from the cache
function LRUCache:clear()
   self.map = {}
   self.head = nil
   self.tail = nil
   self.size = 0
end

return LRUCache
