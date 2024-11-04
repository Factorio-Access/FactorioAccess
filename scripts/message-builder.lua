--[[
Intelligently build messages.

We have a pattern in the mod especially around entity info, but also in lots of
other places.  Build a message with a prefix and then a list.  Then, possibly
append more prefix-list.  Right now we either do that with string concatenation
or we do it with manual use of spacecat and related FaUtils functionality.  This
is an alternative:

```
-- 'the thing with a, b, c"
return MessageBuilder.new()
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
lists are separated by commas.  This handles:

- Nil fragments and empty string fragments get ignored.
- Duplicate calls to separate list items get ignored.
- Larger segments can be separated with `.`.
- You are not limited to 20 items. You are limited to 20^20 items, which is also
  known as infinite for all practical purposes.

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

local mod = {}

local function __cannot_be_in_storage() end

---@enum fa.MessageBuilder.MessageBuilderState
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
---@field state fa.MessageBuilder.MessageBuilderState
---@field parts LocalisedString[]
local MessageBuilder = {}
mod.MessageBuilder = MessageBuilder
local MessageBuilder_meta = { __index = MessageBuilder }

---@return fa.MessageBuilder
function MessageBuilder.new()
   return setmetatable({
      _no_storage = __cannot_be_in_storage,
      state = MESSAGE_BUILDER_STATE.INITIAL,
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
   -- The first fragments are state fragment.  The fragments after the first
   -- list item are marked by being in state FRAGMENT_IN_LIST.
   if self.state == MESSAGE_BUILDER_STATE.FRAGMENT_IN_LIST then table.insert(self.parts, ",") end
   self.state = MESSAGE_BUILDER_STATE.LIST_ITEM
   if fragment then self:fragment(fragment) end
   return self
end

-- It is an error to keep using this builder after building.
---@return LocalisedString Empty string if nothing was ever done.
function MessageBuilder:build()
   self:_check_not_built()
   self.state = MESSAGE_BUILDER_STATE.BUILT

   return FaUtils.localise_cat_table(self.parts, "")
end

return mod
