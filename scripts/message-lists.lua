---Message list system for help and documentation.
---
---Handles translation and caching of message lists defined in locale files.
local StorageManager = require("scripts.storage-manager")
local MessageListIndex = require("scripts.message-list-index")

local mod = {}

---@enum fa.MessageLists.Status
mod.STATUS = {
   READY = 1,
   PENDING = 2,
   NOT_FOUND = 3,
}

---@class fa.MessageLists.Metadata
---@field count number Number of messages in the list
---@field name string Name of the message list

---@class fa.MessageLists.State
---@field metadata_cache table<string, fa.MessageLists.Metadata> Cached metadata by list name
---@field pending_translations table<number, string> Map of translation request ID to list name
---@field pending_list_names table<string, boolean> Set of list names with pending translations
---@field all_translated boolean True once all lists have been translated

---@type table<number, fa.MessageLists.State>
local message_list_storage = StorageManager.declare_storage_module("message_lists", function(_pindex)
   return {
      metadata_cache = {},
      pending_translations = {},
      pending_list_names = {},
      all_translated = false,
   }
end, {
   -- The string concatenation is to let us chjange the implementation of this module. this is saying "reset if the
   -- message list contents or this module changes", where changing this module is bumping the second term.
   ephemeral_state_version = MessageListIndex.MESSAGE_LISTS_HASH .. "0",
})

---Request translation for a message list's metadata.
---@param pindex integer
---@param list_name string
---@return boolean requested True if a new request was made
local function request_metadata_translation(pindex, list_name)
   local player = game.get_player(pindex)
   if not player then return false end

   local state = message_list_storage[pindex]

   -- Skip if already pending
   if state.pending_list_names[list_name] then return false end

   -- Request translation for the metadata key
   local meta_key = { "fa.messagelist--" .. list_name .. "--meta" }
   local request_id = player.request_translation(meta_key)

   if request_id then
      state.pending_translations[request_id] = list_name
      state.pending_list_names[list_name] = true
      return true
   end
   return false
end

---Handle a translation result from on_string_translated event.
---@param pindex integer
---@param request_id number
---@param result string
---@return boolean handled True if this was a message list translation
function mod.handle_translation(pindex, request_id, result)
   local state = message_list_storage[pindex]
   local list_name = state.pending_translations[request_id]

   if not list_name then return false end

   -- Decode the base64+deflate metadata (will crash if invalid)
   local metadata_json = helpers.decode_string(result)

   -- Parse JSON (will crash if invalid)
   local metadata = helpers.json_to_table(metadata_json)

   -- Store the metadata (no need to translate individual messages)
   state.metadata_cache[list_name] = {
      count = metadata.count,
      name = list_name,
   }

   state.pending_translations[request_id] = nil
   state.pending_list_names[list_name] = nil
   return true
end

---Get metadata for a message list.
---Returns the metadata with programmatically-built message keys.
---@param pindex integer
---@param list_name string
---@return { status: fa.MessageLists.Status, metadata: fa.MessageLists.Metadata?, messages: LocalisedString[]? }
function mod.get_message_list_meta(pindex, list_name)
   -- Check if the list exists using O(1) set lookup
   if not MessageListIndex.MESSAGE_LISTS[list_name] then
      return { status = mod.STATUS.NOT_FOUND, metadata = nil, messages = nil }
   end

   local state = message_list_storage[pindex]

   -- Check if we have cached metadata
   local metadata = state.metadata_cache[list_name]

   if not metadata then
      -- Not cached yet - request translation for metadata only
      request_metadata_translation(pindex, list_name)
      return { status = mod.STATUS.PENDING, metadata = nil, messages = nil }
   end

   -- Build message keys programmatically (no translation needed)
   local messages = {}
   for i = 1, metadata.count do
      messages[i] = { "fa.messagelist--" .. list_name .. "--msg" .. i }
   end

   return { status = mod.STATUS.READY, metadata = metadata, messages = messages }
end

---Check if a message list exists.
---@param list_name string
---@return boolean
function mod.has_list(list_name)
   return MessageListIndex.MESSAGE_LISTS[list_name] ~= nil
end

---Event handler for on_string_translated.
---Should be called from the main event handler in control.lua.
---@param event EventData.on_string_translated
function mod.on_string_translated(event)
   local pindex = event.player_index
   mod.handle_translation(pindex, event.id, event.result)
end

---Try to translate all message lists for a player.
---@param pindex integer
local function try_translate_all(pindex)
   local state = message_list_storage[pindex]

   if state.all_translated then return end

   local any_requested = false
   local any_pending = false

   for list_name, _ in pairs(MessageListIndex.MESSAGE_LISTS) do
      if state.metadata_cache[list_name] then
         -- Already cached
      elseif state.pending_list_names[list_name] then
         any_pending = true
      else
         if request_metadata_translation(pindex, list_name) then any_requested = true end
      end
   end

   if not any_requested and not any_pending then state.all_translated = true end
end

---Try to translate all message lists for all players.
---Call this from on_tick. Rate-limited internally to tick 1 and every 60 ticks.
function mod.try_translate_all_players()
   local tick = game.tick
   if tick % 60 ~= 0 then return end

   for _, player in pairs(game.players) do
      if player.valid then try_translate_all(player.index) end
   end
end

return mod
