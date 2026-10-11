---Wrapper around ds/localised-string-cache.lua integrated with Factorio's translation system.
---Provides per-player caching of localised string translations with LRU eviction.
local StorageManager = require("scripts.storage-manager")
local LocalisedStringCache = require("ds.localised-string-cache")

local mod = {}

-- Big enough for the largest searchable UI (the signal chooser has 3000 to 4000 labels): a smaller cache evicts its
-- own entries while a search refresh fills it, and they are requested again forever.
local CACHE_SIZE = 6000

-- Ticks after which a translation still not back is requested again.
local PENDING_TIMEOUT = 600

---@class fa.LocalisedStringCacheState
---@field cache any The underlying LRU cache instance
---@field pending_requests table<integer, LocalisedString> Map of translation request ID to localised string
---@field pending_keys table<string, integer> Tick each pending string was requested, by LocalisedStringCache.key_of

---@type table<number, fa.LocalisedStringCacheState>
-- The version rebuilds caches made with an older CACHE_SIZE (translations are simply requested again).
local cache_storage = StorageManager.declare_storage_module("localised_string_cache", function(_pindex)
   return {
      cache = LocalisedStringCache.new(CACHE_SIZE),
      pending_requests = {},
      pending_keys = {},
   }
end, { ephemeral_state_version = 1 })

---Hint that we may want a string soon - enqueues it for translation and discards the result.
---This is useful for pre-loading strings that will be searched.
---@param pindex integer
---@param localised_string LocalisedString
function mod.hint_submit(pindex, localised_string)
   local player = game.get_player(pindex)
   if not player then return end

   local state = cache_storage[pindex]

   if state.cache:has(localised_string) then return end

   -- Already asked for and not back yet
   local pending_keys = state.pending_keys
   local key = LocalisedStringCache.key_of(localised_string --[[@as table]])
   local asked = pending_keys[key]
   if asked and game.tick - asked < PENDING_TIMEOUT then return end

   local request_id = player.request_translation(localised_string)
   state.pending_requests[request_id] = localised_string
   pending_keys[key] = game.tick
end

---Get a cached translation for a localised string.
---@param pindex integer
---@param localised_string LocalisedString
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
   local key = LocalisedStringCache.key_of(localised_string --[[@as table]])
   state.pending_keys[key] = nil

   return true
end

return mod
