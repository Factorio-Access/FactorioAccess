--Here: localisation functions, including event handlers
local Speech = require("scripts.speech")
local LocalisedStringCache = require("scripts.localised-string-cache")

local mod = {}
--Returns the localised name of an object as a string. Used for ents and items and fluids
---@return string
function mod.get(object, pindex)
   -- Everything, everything uses this function without checking the return
   -- values. Use really annoying strings to make it very clear there's a
   -- bug.
   if pindex == nil then error("localising.get: pindex is nil") end
   if object == nil then return "LOCALIZED OBJECT IS NIL!" end
   if object.valid and string.sub(object.object_name, -9) ~= "Prototype" then object = object.prototype end
   local result = storage.players[pindex].localisations
   result = result and result[object.object_name]
   result = result and result[object.name]
   --for debugging
   if not result then
      game
         .get_player(pindex)
         .print("translation fallback for " .. object.object_name .. " " .. object.name, { volume_modifier = 0 })
   end
   result = result or object.name
   return result
end

--Used for recipes
function mod.get_alt(object, pindex)
   if pindex == nil then
      Speech.speak(nil, "localising: pindex is nil error")
      return "(nil)"
   end
   if object == nil then return "(nil)" end
   local result = storage.players[pindex].localisations
   result = result and result[object.object_name]
   result = result and result[object.name]
   --for debugging
   if not result then
      game
         .get_player(pindex)
         .print("translation fallback for " .. object.object_name .. " " .. object.name, { volume_modifier = 0 })
   end
   result = result or object.name
   return result or "(nil)"
end

function mod.get_item_from_name(name, pindex)
   local proto = prototypes.item[name]
   if proto == nil then return "(nil)" end
   local result = mod.get(proto, pindex)
   return result or "(nil)"
end

function mod.get_fluid_from_name(name, pindex)
   local proto = prototypes.fluid[name]
   if proto == nil then return "nil" end
   local result = mod.get(proto, pindex)
   return result
end

function mod.get_recipe_from_name(name, pindex)
   local proto = prototypes.recipe[name]
   if proto == nil then return "nil" end
   local result = mod.get_alt(proto, pindex)
   return result
end

function mod.get_item_group_from_name(name, pindex)
   local proto = prototypes.item_group[name]
   if proto == nil then return "nil" end
   local result = mod.get_alt(proto, pindex)
   return result
end

function mod.request_localisation(thing, pindex)
   local id = game.players[pindex].request_translation(thing.localised_name)
   local lookup = storage.players[pindex].translation_id_lookup
   lookup[id] = { thing.object_name, thing.name }
end

function mod.request_all_the_translations(pindex)
   for _, cat in pairs({
      "entity",
      "item",
      "fluid",
      "tile",
      "equipment",
      "damage",
      "virtual_signal",
      "recipe",
      "technology",
      "decorative",
      "autoplace_control",
      "mod_setting",
      "custom_input",
      "ammo_category",
      "item_group",
      "fuel_category",
      "achievement",
      "equipment_category",
      "shortcut",
   }) do
      for _, proto in pairs(prototypes[cat]) do
         mod.request_localisation(proto, pindex)
      end
   end
end

--Populates the appropriate localised string arrays for every translation
function mod.handler(event)
   local pindex = event.player_index
   local player = storage.players[pindex]
   local successful = event.translated

   -- Check if this is a localised string cache request
   if successful and LocalisedStringCache.handle_translation(pindex, event.id, event.result) then return end

   local translated_thing = player.translation_id_lookup[event.id]
   if not translated_thing then return end
   player.translation_id_lookup[event.id] = nil
   if not successful then
      if player.translation_issue_counter == nil then
         player.translation_issue_counter = 1
      else
         player.translation_issue_counter = player.translation_issue_counter + 1
      end
      --print("translation request ".. event.id .. " failed, request: [" .. serpent.line(event.localised_string) ..  "] for:" .. translated_thing[1] .. ":" .. translated_thing[2] .. ", total issues: " .. storage.players[pindex].translation_issue_counter)
      return
   end
   if translated_thing == "test_translation" then
      local last_try = player.localisation_test
      if last_try == event.result then return end
      mod.request_all_the_translations(pindex)
      player.localisation_test = event.result
      return
   end
   player.localisations = player.localisations or {}
   local localised = player.localisations
   localised[translated_thing[1]] = localised[translated_thing[1]] or {}
   local translated_list = localised[translated_thing[1]]
   translated_list[translated_thing[2]] = event.result
end

function mod.check_player(pindex)
   local player = storage.players[pindex]
   local id = game.players[pindex].request_translation({ "error.crash-to-desktop-message" })
   if not id then return end
   player.translation_id_lookup = player.translation_id_lookup or {}
   player.translation_id_lookup[id] = "test_translation"
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
---@param what { name: string, localised_name: LocalisedString } | LuaItemStack | LuaEntity | LuaPrototypeBase
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
   assert(item_proto, "unable to find item")

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

   return { "fa.item-quantity-quality", item_str, has_quality, quality_str, has_count, count }
end

---@param what LuaItemStack | fa.Localising.LocaliseItemOpts
---@return LocalisedString
function mod.localise_item(what)
   return mod.localise_item_or_fluid(what, prototypes.item)
end

return mod
