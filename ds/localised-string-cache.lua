---Cache for localised strings with canonicalization via trie structure.
---Maps structurally-equal localised strings to a canonical reference,
---then uses LRU cache to store translated text.
---@class LocalisedStringCache
---@field trie_root table Trie structure for canonicalizing localised strings
---@field lru_cache LRUCache LRU cache for storing translations
local LocalisedStringCache = {}
local LocalisedStringCache_meta = { __index = LocalisedStringCache }
if script then script.register_metatable("ds.LocalisedStringCache", LocalisedStringCache_meta) end

local LRUCache = require("ds.lru-cache")

---Unique markers for table boundaries in the trie path
---Must be strings to survive save/load cycles (table references don't persist)
local START_MARKER = "=start"
local END_MARKER = "=end"

---Create a new localised string cache
---@param capacity integer Maximum number of translations to cache
---@return LocalisedStringCache
function LocalisedStringCache.new(capacity)
   assert(capacity and capacity > 0, "Capacity must be positive")

   local cache = {
      trie_root = {},
      lru_cache = LRUCache.new(capacity),
   }

   setmetatable(cache, LocalisedStringCache_meta)
   return cache
end

---Flatten a localised string into a linear path through the trie.
---Nested tables are marked with START_MARKER and END_MARKER.
---@param localised table Localised string (nested array structure)
---@param result table Output array to append path elements to
local function flatten_localised_string(localised, result)
   for i = 1, #localised do
      local element = localised[i]
      if type(element) == "table" then
         table.insert(result, START_MARKER)
         flatten_localised_string(element, result)
         table.insert(result, END_MARKER)
      else
         table.insert(result, tostring(element))
      end
   end
end

---Canonicalize a localised string to a canonical reference.
---Structurally-equal localised strings map to the same canonical reference.
---@param localised_string table Localised string to canonicalize
---@return table canonical The canonical reference (first instance seen)
local function canonicalize(trie_root, localised_string)
   assert(type(localised_string) == "table", "Localised string must be a table")

   local path = {}
   flatten_localised_string(localised_string, path)

   local current = trie_root
   for i = 1, #path do
      local key = path[i]
      if not current[key] then current[key] = {} end
      current = current[key]
   end

   if not current._canonical then current._canonical = localised_string end

   return current._canonical
end

---Canonicalize a localised string (public method for advanced use).
---Most users should use get/put/has/remove which handle canonicalization automatically.
---@param localised_string table Localised string to canonicalize
---@return table canonical The canonical reference
function LocalisedStringCache:canonicalize(localised_string)
   return canonicalize(self.trie_root, localised_string)
end

---Get the translated text for a localised string
---@param localised_string table Localised string to look up
---@return string|nil text Translated text if cached, nil otherwise
function LocalisedStringCache:get(localised_string)
   local canonical = canonicalize(self.trie_root, localised_string)
   return self.lru_cache:get(canonical)
end

---Store translated text for a localised string
---@param localised_string table Localised string to cache
---@param translated_text string The translated text
function LocalisedStringCache:put(localised_string, translated_text)
   local canonical = canonicalize(self.trie_root, localised_string)
   self.lru_cache:put(canonical, translated_text)
end

---Check if a localised string has a translation (does not mark as used)
---@param localised_string table Localised string to check
---@return boolean
function LocalisedStringCache:has(localised_string)
   local canonical = canonicalize(self.trie_root, localised_string)
   return self.lru_cache:has(canonical)
end

---Get the current number of cached translations
---@return integer
function LocalisedStringCache:get_size()
   return self.lru_cache:get_size()
end

---Remove a localised string from the cache.
---Also removes it from the trie to prevent memory leaks.
---@param localised_string table Localised string to remove
---@return string|nil value Removed translation if found, nil otherwise
function LocalisedStringCache:remove(localised_string)
   local canonical = canonicalize(self.trie_root, localised_string)
   local value = self.lru_cache:remove(canonical)

   if value then self:_remove_from_trie(canonical) end

   return value
end

---Remove a canonical reference from the trie structure.
---Walks back up the trie removing empty nodes to prevent memory leaks.
---@param canonical table The canonical localised string to remove
function LocalisedStringCache:_remove_from_trie(canonical)
   local path = {}
   flatten_localised_string(canonical, path)

   local nodes = { self.trie_root }
   local current = self.trie_root

   for i = 1, #path do
      local key = path[i]
      current = current[key]
      if not current then return end
      table.insert(nodes, current)
   end

   current._canonical = nil

   for i = #path, 1, -1 do
      local node = nodes[i + 1]
      local parent = nodes[i]
      local key = path[i]

      local is_empty = true
      for _ in pairs(node) do
         is_empty = false
         break
      end

      if is_empty then
         parent[key] = nil
      else
         break
      end
   end
end

---Clear all cached translations and trie structure
function LocalisedStringCache:clear()
   self.trie_root = {}
   self.lru_cache:clear()
end

return LocalisedStringCache
