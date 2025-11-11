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
---@param what { name: string, localised_name: LocalisedString? } | LuaItemStack | LuaEntity | LuaPrototypeBase | LuaTile
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

return mod
