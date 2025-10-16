---Wrapper around ds/localised-string-cache.lua integrated with Factorio's translation system.
---Provides per-player caching of localised string translations with LRU eviction.
local StorageManager = require("scripts.storage-manager")
local LocalisedStringCache = require("ds.localised-string-cache")

local mod = {}

local CACHE_SIZE = 1000

---@class fa.LocalisedStringCacheState
---@field cache any The underlying LRU cache instance
---@field pending_requests table<number, table> Map of translation request ID to localised string

---@type table<number, fa.LocalisedStringCacheState>
local cache_storage = StorageManager.declare_storage_module("localised_string_cache", function(_pindex)
   return {
      cache = LocalisedStringCache.new(CACHE_SIZE),
      pending_requests = {},
   }
end)

---Hint that we may want a string soon - enqueues it for translation and discards the result.
---This is useful for pre-loading strings that will be searched.
---@param pindex integer
---@param localised_string table
function mod.hint_submit(pindex, localised_string)
   local player = game.get_player(pindex)
   if not player then return end

   local state = cache_storage[pindex]

   -- Check if already cached
   if state.cache:has(localised_string) then return end

   -- Request translation
   local request_id = player.request_translation(localised_string)
   if request_id then state.pending_requests[request_id] = localised_string end
end

---Get a cached translation for a localised string.
---@param pindex integer
---@param localised_string table
---@return string? translation The cached translation, or nil if not cached
function mod.get(pindex, localised_string)
   local state = cache_storage[pindex]
   return state.cache:get(localised_string)
end

---Store a translation for a localised string.
---@param pindex integer
---@param localised_string table
---@param translation string
function mod.set(pindex, localised_string, translation)
   local state = cache_storage[pindex]
   state.cache:put(localised_string, translation)
end

---Handle a translation result from the on_string_translated event.
---This is called by the event handler in control.lua.
---@param pindex integer
---@param request_id integer
---@param translation string
---@return boolean handled True if this request was for our cache
function mod.handle_translation(pindex, request_id, translation)
   local state = cache_storage[pindex]
   local localised_string = state.pending_requests[request_id]

   if not localised_string then return false end

   -- Store in cache
   state.cache:put(localised_string, translation)

   -- Remove from pending
   state.pending_requests[request_id] = nil

   return true
end

return mod
