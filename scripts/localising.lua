--Here: localisation functions, including event handlers
local Speech = require("scripts.speech")
local LocalisedStringCache = require("scripts.localised-string-cache")
local MessageLists = require("scripts.message-lists")

local mod = {}

function mod.request_localisation(thing, pindex)
   local id = game.players[pindex].request_translation(thing.localised_name)
   local lookup = storage.players[pindex].translation_id_lookup
   lookup[id] = { thing.object_name, thing.name }
end

function mod.handler(event)
   local pindex = event.player_index
   local player = storage.players[pindex]
   local successful = event.translated

   -- Check if this is a localised string cache request
   if successful and LocalisedStringCache.handle_translation(pindex, event.id, event.result) then return end

   -- Check if this is a message list request
   if successful then MessageLists.on_string_translated(event) end
end

local function wrapped_pcall(f)
   local good, val = pcall(f)
   if good then
      return val
   else
      return nil
   end
end

-- Build a localised string which will announce the localised_x field or, if not present, the name.
---@param what { name: string, localised_name: LocalisedString? } | LuaItemStack | LuaEntity | LuaPrototypeBase
---@return LocalisedString
function mod.get_localised_name_with_fallback(what)
   assert(what ~= nil, "get_localised_name_with_fallback called with nil")
   -- We could do a bunch of complex object type checking, or we can just chain out pcall.  The issue is that Factorio
   -- objects hard error on properties that don't exist rather than giving back nil.  This is a *VERY BAD* antipattern
   -- in the general case, but this function needs to work with effectively anything you might pass it.

   local fallback_name = wrapped_pcall(function()
      return what.prototype.name
   end) or wrapped_pcall(function()
      return what.name
   end)

   local res = wrapped_pcall(function()
      return what.localised_name
   end) or wrapped_pcall(function()
      return what.prototype.localised_name
   end) or wrapped_pcall(function()
      return what.prototype.name
   end) or what.name

   if fallback_name then
      return { "?", res, fallback_name }
   else
      return res
   end
end

-- Marker to say "other item" in localise_item.
mod.ITEM_OTHER = {}

---@class fa.Localising.LocaliseItemOpts
---@field name LuaItemPrototype | LuaFluidPrototype | string | `mod.ITEM_OTHER`
---@field quality (LuaQualityPrototype|string)?
---@field count number?

--[[
Localise an item, or fluid, possibly with count and quality.

This function can take two things.  An LuaItemStack, or a table with 3 keys:
name, quality, and count.  In that table, name and quality may either be a
string or a LuaXXXPrototype.  It:

- For the case of stacks, "transport belt X 50" or (for non-normal quality)
  "legendary transport belt X 50".
- For the case of the table, announce item with (if present and non-normal)
  quality and (if present) count.  That is, leaving stuff out is how you prevent
  it being announced.

for the case of "and 5 other items" you may use mod.ITEM_OTHER in place of the
name.
]]
---@param what LuaItemStack | fa.Localising.LocaliseItemOpts
---@param protos table<string, LuaItemPrototype|LuaFluidPrototype>
---@return LocalisedString
function mod.localise_item_or_fluid(what, protos)
   ---@type fa.Localising.LocaliseItemOpts
   local final_opts

   if type(what) == "userdata" then
      ---@type LuaItemStack
      local stack = what --[[@as LuaItemStack ]]
      assert(stack.object_name == "LuaItemStack")

      final_opts = {
         name = stack.prototype,
         quality = stack.quality,
         count = stack.count,
         is_blueprint = stack.is_blueprint,
         blueprint_label = stack.is_blueprint and stack.label or nil,
         is_blueprint_book = stack.is_blueprint_book,
         blueprint_book_label = stack.is_blueprint_book and stack.label or nil,
      }
   else
      if what.name == mod.ITEM_OTHER then
         assert(what.count, "it does not make sense to ask to localise ITEM_OTHER without also giving a count")
         return { "fa.item-other", what.count }
      end

      final_opts = what --[[ @as fa.Localising.LocaliseItemOpts ]]
   end

   local quality = final_opts.quality
   local name = final_opts.name
   local count = final_opts.count

   local item_proto, quality_proto

   if type(name) == "string" then
      item_proto = protos[name]
   elseif name then
      item_proto = name
   end
   if not item_proto then error(item_proto, "unable to find item " .. name) end

   if quality and type(quality) == "string" then
      quality_proto = prototypes.quality[quality]
   elseif quality then
      quality_proto = quality --[[@as LuaQualityPrototype ]]
   else
      quality_proto = prototypes.quality["normal"]
   end
   assert((not quality) or quality_proto)

   local item_str = mod.get_localised_name_with_fallback(item_proto)
   local quality_str = mod.get_localised_name_with_fallback(quality_proto)
   local has_quality = (quality and quality_proto.name ~= "normal") and 1 or 0
   local has_count = (count and count > 1) and 1 or 0

   -- Special case for blueprints with labels
   if final_opts.is_blueprint and final_opts.blueprint_label then
      return { "fa.item-blueprint", final_opts.blueprint_label, has_quality, quality_str, has_count, count }
   end

   -- Special case for blueprint books with labels
   if final_opts.is_blueprint_book and final_opts.blueprint_book_label then
      return { "fa.item-blueprint-book", final_opts.blueprint_book_label, has_quality, quality_str, has_count, count }
   end

   return { "fa.item-quantity-quality", item_str, has_quality, quality_str, has_count, count }
end

---@param what LuaItemStack | fa.Localising.LocaliseItemOpts
---@return LocalisedString
function mod.localise_item(what)
   return mod.localise_item_or_fluid(what, prototypes.item)
end

return mod
