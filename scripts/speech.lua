--[[
Speech System - Intelligently build and speak messages.

This module combines message building with speech output. Messages are built
using a fluent API and then sent to an external launcher process for
text-to-speech rendering.

We have a pattern in the mod especially around entity info, but also in lots of
other places.  Build a message with a prefix and then a list.  Then, possibly
append more prefix-list.  Right now we either do that with string concatenation
or we do it with manual use of spacecat and related FaUtils functionality.  This
is an alternative:

```
-- 'the thing with a, b, c"
return Speech.new()
    :fragment("the thing with")
    :list_item("a")
    :list_item("b")
    :list_item("c")
    :build()
```

The basic usage pattern is use `fragment()` to append text, `list_item()` to
signal that a list item has ended.  `list_item()` takes an optional fragment and
appends it, so you can just chain list_item to build long lists of one thing
each. Any two fragments appended one after the other are separated by space;
lists are separated by commas.

Unlike normal localised strings, you are not limited to 20 items. You are
limited to 20^20 items, which is also known as infinite for all practical
purposes.

Ok so: what's the point?  For those who don't already get why you'd want this,
it lets you have a series of functions that collaboratively build up a message.
Rather than trying to coordinate getting everything everywhere to agree on when
things are lists and whatnot, everything "at the bottom" gets to just use
fragment() and the piece one level up gets to coordinate the larger pattern of
separation.  Also in large functions the alternative is `table.insert` and a
join by hand.

This is very much not storage safe, and it is very much not intended to be;
attempts to do so throw when the game saves.
]]
local FaUtils = require("scripts.fa-utils")
local SpeechLogger = require("scripts.speech-logger")

local mod = {}

-- Test capture mechanism
local capture_state = {
   enabled = false,
   messages = {},
}

local function __cannot_be_in_storage() end

---@enum fa.Speech.MessageBuilderState
local MESSAGE_BUILDER_STATE = {
   -- Nothing has happened yet.
   -- Next valid state: fragment only.
   INITIAL = "initial",

   -- A list separator was just pushed.
   -- Next valid state: fragment, or a return to LIST_ITEM
   LIST_ITEM = "list_item",

   -- A fragment was just pushed.
   -- Next valid state: FRAGMENT again, or list_item.
   FRAGMENT = "fragment",

   -- A fragment was pushed, and we are in a list already.  Tracks whether or
   -- not comma is needed.
   FRAGMENT_IN_LIST = "fragment_in_list",

   BUILT = "built",
}

---@class fa.MessageBuilder
---@field _no_storage fun()
---@field state fa.Speech.MessageBuilderState
---@field parts LocalisedString[]
---@field is_first_list_item boolean Used to avoid an extra comma at the start of lists.
local MessageBuilder = {}
mod.MessageBuilder = MessageBuilder
local MessageBuilder_meta = { __index = MessageBuilder }

---@return fa.MessageBuilder
function MessageBuilder.new()
   return setmetatable({
      _no_storage = __cannot_be_in_storage,
      state = MESSAGE_BUILDER_STATE.INITIAL,
      is_first_list_item = true,
      parts = {},
   }, MessageBuilder_meta)
end

function MessageBuilder:_check_not_built()
   assert(self.state ~= MESSAGE_BUILDER_STATE.BUILT, "Ateempt to use a message builder twice")
end

---@param fragment LocalisedString
---@return fa.MessageBuilder
function MessageBuilder:fragment(fragment)
   self:_check_not_built()

   -- Warn about common mistake: fragment(" ") is unnecessary as spaces are added automatically
   if type(fragment) == "string" and fragment == " " then
      error('Speech:fragment(" ") is unnecessary - spaces are automatically added between fragments')
   end

   -- If we just started a list item, this needs a comma.
   if self.state == MESSAGE_BUILDER_STATE.LIST_ITEM then
      if not self.is_first_list_item then table.insert(self.parts, ",") end
      self.is_first_list_item = false
   end

   if self.state == MESSAGE_BUILDER_STATE.LIST_ITEM or self.state == MESSAGE_BUILDER_STATE.FRAGMENT_IN_LIST then
      self.state = MESSAGE_BUILDER_STATE.FRAGMENT_IN_LIST
   else
      self.state = MESSAGE_BUILDER_STATE.FRAGMENT
   end

   -- In all cases but initial, a space is needed.
   if self.state ~= MESSAGE_BUILDER_STATE.INITIAL then table.insert(self.parts, " ") end

   table.insert(self.parts, fragment)
   return self
end

---@param fragment LocalisedString? If present, pushed after the separator.
---@return fa.MessageBuilder
function MessageBuilder:list_item(fragment)
   self:_check_not_built()

   self.state = MESSAGE_BUILDER_STATE.LIST_ITEM
   if fragment then self:fragment(fragment) end
   return self
end

-- Just like list_item, but will force a comma even if this is the first item in a list.  This is used e.g. in grids,
-- which should always be "label, dims".
---@param fragment LocalisedString? If present, pushed after the separator.
---@return fa.MessageBuilder
function MessageBuilder:list_item_forced_comma(fragment)
   self:_check_not_built()
   self:list_item()
   self.is_first_list_item = false
   if fragment then self:fragment(fragment) end
   return self
end

-- It is an error to keep using this builder after building.
---@return LocalisedString? Nil if nothing was done.
function MessageBuilder:build()
   self:_check_not_built()
   self.state = MESSAGE_BUILDER_STATE.BUILT

   if not next(self.parts) then return nil end

   return FaUtils.localise_cat_table(self.parts, "")
end

-- Convenience function at module level
mod.new = MessageBuilder.new

-- Late-registered rich text processor (set by rich-text.lua to avoid circular dependency)
local rich_text_processor = nil

---Register the rich text processor function (called by rich-text.lua)
---@param processor fun(text: string): LocalisedString
function mod.register_rich_text_processor_late(processor)
   rich_text_processor = processor
end

---Process rich text in a LocalisedString, converting rich text tags to readable text.
---For strings: runs rich text verbalization.
---For tables (locale keys): recursively processes indices >= 2 since index 1 is the key.
---@param str LocalisedString
---@return LocalisedString
local function process_rich_text(str)
   if type(str) == "string" then
      if rich_text_processor then return rich_text_processor(str) end
      return str
   elseif type(str) == "table" then
      -- Index 1 is the locale key/directive, process indices >= 2
      local result = { str[1] }
      for i = 2, #str do
         result[i] = process_rich_text(str[i])
      end
      return result
   else
      -- Numbers, booleans, nil - return as-is
      return str
   end
end

mod.process_rich_text = process_rich_text

---Send a localized string to the external launcher for text-to-speech rendering.
---This is the primary way the mod communicates with blind players.
---@param pindex number Player index
---@param str LocalisedString The message to speak
function mod.speak(pindex, str)
   -- Assert to catch parameter order mistakes
   assert(type(pindex) == "number", "Speech.speak expects pindex as first parameter (number), got " .. type(pindex))

   -- Process rich text before output
   local processed = process_rich_text(str)

   -- Capture for tests if enabled
   if capture_state.enabled then
      table.insert(capture_state.messages, {
         message = processed,
         pindex = pindex,
      })
   end

   if pindex ~= nil and pindex > 0 then
      storage.players[pindex].last = processed
   else
      return
   end
   if storage.players[pindex].vanilla_mode == nil then storage.players[pindex].vanilla_mode = false end
   if not storage.players[pindex].vanilla_mode then
      localised_print({ "", "out " .. pindex .. " ", processed })
      -- Also log to file for debugging
      SpeechLogger.log_speech(processed, pindex)
   end
end

-- Test helper functions
---Enable speech capture for testing
function mod.start_capture()
   capture_state.enabled = true
   capture_state.messages = {}
end

---Disable speech capture and return captured messages
---@return table Array of {message: LocalisedString, pindex: number}
function mod.stop_capture()
   capture_state.enabled = false
   local messages = capture_state.messages
   capture_state.messages = {}
   return messages
end

---Get captured messages without stopping capture
---@return table Array of {message: LocalisedString, pindex: number}
function mod.get_captured_messages()
   return capture_state.messages
end

---Clear captured messages without stopping capture
function mod.clear_captured_messages()
   capture_state.messages = {}
end

---Check if any messages were captured
---@return boolean
function mod.has_captured_messages()
   return #capture_state.messages > 0
end

return mod
