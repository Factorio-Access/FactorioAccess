--Here: localisation functions, including event handlers
local mod = {}
--Returns the localised name of an object as a string. Used for ents and items and fluids
---@return string
function mod.get(object, pindex)
   -- Everything, everything uses this function without checking the return
   -- values. Use really annoying strings to make it very clear there's a
   -- bug.
   if pindex == nil then
      game.print("localising: pindex is nil error")
      return "NOT LOCALIZED!"
   end
   if object == nil then return "LOCALIZED OBJECT IS NIL!" end
   if object.valid and string.sub(object.object_name, -9) ~= "Prototype" then object = object.prototype end
   local result = players[pindex].localisations
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
      printout("localising: pindex is nil error")
      return "(nil)"
   end
   if object == nil then return "(nil)" end
   local result = players[pindex].localisations
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
   local proto = game.item_prototypes[name]
   if proto == nil then return "(nil)" end
   local result = mod.get(proto, pindex)
   return result or "(nil)"
end

function mod.get_fluid_from_name(name, pindex)
   local proto = game.fluid_prototypes[name]
   if proto == nil then return "nil" end
   local result = mod.get(proto, pindex)
   return result
end

function mod.get_recipe_from_name(name, pindex)
   local proto = game.recipe_prototypes[name]
   if proto == nil then return "nil" end
   local result = mod.get_alt(proto, pindex)
   return result
end

function mod.get_item_group_from_name(name, pindex)
   local proto = game.item_group_prototypes[name]
   if proto == nil then return "nil" end
   local result = mod.get_alt(proto, pindex)
   return result
end

function mod.request_localisation(thing, pindex)
   local id = game.players[pindex].request_translation(thing.localised_name)
   local lookup = players[pindex].translation_id_lookup
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
      for _, proto in pairs(game[cat .. "_prototypes"]) do
         mod.request_localisation(proto, pindex)
      end
   end
end

--Populates the appropriate localised string arrays for every translation
function mod.handler(event)
   local pindex = event.player_index
   local player = players[pindex]
   local successful = event.translated
   local translated_thing = player.translation_id_lookup[event.id]
   if not translated_thing then return end
   player.translation_id_lookup[event.id] = nil
   if not successful then
      if player.translation_issue_counter == nil then
         player.translation_issue_counter = 1
      else
         player.translation_issue_counter = player.translation_issue_counter + 1
      end
      --print("translation request ".. event.id .. " failed, request: [" .. serpent.line(event.localised_string) ..  "] for:" .. translated_thing[1] .. ":" .. translated_thing[2] .. ", total issues: " .. players[pindex].translation_issue_counter)
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
   local player = players[pindex]
   local id = game.players[pindex].request_translation({ "error.crash-to-desktop-message" })
   if not id then return end
   player.translation_id_lookup = player.translation_id_lookup or {}
   player.translation_id_lookup[id] = "test_translation"
end

return mod
