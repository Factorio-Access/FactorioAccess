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

---@type table<number, fa.MessageLists.State>
local message_list_storage = StorageManager.declare_storage_module("message_lists", function(_pindex)
   return {
      metadata_cache = {},
      pending_translations = {},
   }
end, {
   ephemeral_state_version = MessageListIndex.MESSAGE_LISTS_HASH,
})

---Request translation for a message list's metadata.
---@param pindex integer
---@param list_name string
local function request_metadata_translation(pindex, list_name)
   local player = game.get_player(pindex)
   if not player then return end

   local state = message_list_storage[pindex]

   -- Request translation for the metadata key
   local meta_key = { "fa.messagelist--" .. list_name .. "--meta" }
   local request_id = player.request_translation(meta_key)

   if request_id then state.pending_translations[request_id] = list_name end
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

---Event handler for on_string_translated.
---Should be called from the main event handler in control.lua.
---@param event EventData.on_string_translated
function mod.on_string_translated(event)
   local pindex = event.player_index
   mod.handle_translation(pindex, event.id, event.result)
end

return mod
