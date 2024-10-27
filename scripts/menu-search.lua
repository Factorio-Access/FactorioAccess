--Here: Menu search and directly related functions
local fa_crafting = require("scripts.crafting")
local localising = require("scripts.localising")
local fa_sectors = require("scripts.building-vehicle-sectors")
local fa_circuits = require("scripts.circuit-networks")
local fa_travel = require("scripts.travel-tools")
local fa_graphics = require("scripts.graphics")
local fa_blueprints = require("scripts.blueprints")
local Research = require("scripts.research")

local mod = {}

--Returns the index for the next inventory item to match the search term, for any lua inventory
local function inventory_find_index_of_next_name_match(inv, index, str, pindex)
   local repeat_i = -1
   if index < 1 then index = 1 end
   --Iterate until the end of the inventory for a match
   for i = index, #inv, 1 do
      local stack = inv[i]
      if stack ~= nil and stack.valid_for_read then
         local name = string.lower(localising.get(stack.prototype, pindex))
         local result = string.find(name, str, 1, true)
         if result ~= nil then
            if name ~= players[pindex].menu_search_last_name then
               players[pindex].menu_search_last_name = name
               game.get_player(pindex).play_sound({ path = "Inventory-Move" }) --sound for finding the next
               return i
            else
               repeat_i = i
            end
         end
         --game.print(i .. " : " .. name .. " vs. " .. str,{volume_modifier=0})
      end
   end
   --End of inventory reached, circle back
   game.get_player(pindex).play_sound({ path = "inventory-wrap-around" }) --sound for having cicled around
   for i = 1, index, 1 do
      local stack = inv[i]
      if stack ~= nil and stack.valid_for_read then
         local name = string.lower(localising.get(stack.prototype, pindex))
         local result = string.find(name, str, 1, true)
         if result ~= nil then
            if name ~= players[pindex].menu_search_last_name then
               players[pindex].menu_search_last_name = name
               game.get_player(pindex).play_sound({ path = "Inventory-Move" }) --sound for finding the next
               return i
            else
               repeat_i = i
            end
         end
         --game.print(i .. " : " .. name .. " vs. " .. str,{volume_modifier=0})
      end
   end
   --Check if any repeats found
   if repeat_i > 0 then return repeat_i end
   --No matches found at all
   return -1
end

--Returns the index for the last inventory item to match the search term, for any lua inventory
local function inventory_find_index_of_last_name_match(inv, index, str, pindex)
   local repeat_i = -1
   if index < 1 then index = 1 end
   --Iterate until the start of the inventory for a match
   for i = index, 1, -1 do
      local stack = inv[i]
      if stack ~= nil and stack.valid_for_read then
         local name = string.lower(localising.get(stack.prototype, pindex))
         local result = string.find(name, str, 1, true)
         if result ~= nil then
            if name ~= players[pindex].menu_search_last_name then
               players[pindex].menu_search_last_name = name
               game.get_player(pindex).play_sound({ path = "Inventory-Move" }) --sound for finding the next
               return i
            else
               repeat_i = i
            end
         end
         --game.print(i .. " : " .. name .. " vs. " .. str,{volume_modifier=0})
      end
   end
   --Start of inventory reached, circle back
   game.get_player(pindex).play_sound({ path = "inventory-wrap-around" }) --sound for having cicled around
   for i = #inv, index, -1 do
      local stack = inv[i]
      if stack ~= nil and stack.valid_for_read then
         local name = string.lower(localising.get(stack.prototype, pindex))
         local result = string.find(name, str, 1, true)
         if result ~= nil then
            if name ~= players[pindex].menu_search_last_name then
               players[pindex].menu_search_last_name = name
               game.get_player(pindex).play_sound({ path = "Inventory-Move" }) --sound for finding the next
               return i
            else
               repeat_i = i
            end
         end
         --game.print(i .. " : " .. name .. " vs. " .. str,{volume_modifier=0})
      end
   end
   --Check if any repeats found
   if repeat_i > 0 then return repeat_i end
   --No matches found at all
   return -1
end

--Returns the index for the next recipe to match the search term, designed for the way recipes are saved in players[pindex]
local function crafting_find_index_of_next_name_match(str, pindex, last_i, last_j, recipe_set)
   local recipes = recipe_set
   local cata_total = #recipes
   local repeat_i = -1
   local repeat_j = -1
   if last_i < 1 then last_i = 1 end
   if last_j < 1 then last_j = 1 end
   --Iterate until the end of the inventory for a match
   for i = last_i, cata_total, 1 do
      for j = last_j, #recipes[i], 1 do
         local recipe = recipes[i][j]
         if recipe and recipe.valid then
            local name = string.lower(localising.get(recipe, pindex))
            local result = string.find(name, str, 1, true)
            --game.print(i .. "," .. j .. " : " .. name .. " vs. " .. str,{volume_modifier=0})
            if result ~= nil then
               --game.print(" * " .. i .. "," .. j .. " : " .. name .. " vs. " .. str .. " * ",{volume_modifier=0})
               if name ~= players[pindex].menu_search_last_name then
                  players[pindex].menu_search_last_name = name
                  game.get_player(pindex).play_sound({ path = "Inventory-Move" }) --sound for finding the next
                  --game.print(" ** " .. recipes[i][j].name .. " ** ")
                  return i, j
               else
                  repeat_i = i
                  repeat_j = j
               end
            end
         end
      end
      last_j = 1
   end
   --End of inventory reached, circle back
   game.get_player(pindex).play_sound({ path = "inventory-wrap-around" }) --sound for having cicled around
   for i = 1, cata_total, 1 do
      for j = 1, #recipes[i], 1 do
         local recipe = recipes[i][j]
         if recipe and recipe.valid then
            local name = string.lower(localising.get(recipe, pindex))
            local result = string.find(name, str, 1, true)
            --game.print(i .. "," .. j .. " : " .. name .. " vs. " .. str,{volume_modifier=0})
            if result ~= nil then
               --game.print(" * " .. i .. "," .. j .. " : " .. name .. " vs. " .. str .. " * ",{volume_modifier=0})
               if name ~= players[pindex].menu_search_last_name then
                  players[pindex].menu_search_last_name = name
                  game.get_player(pindex).play_sound({ path = "Inventory-Move" }) --sound for finding the next
                  --game.print(" ** " .. recipes[i][j].name .. " ** ")
                  return i, j
               else
                  repeat_i = i
                  repeat_j = j
               end
            end
         end
      end
   end
   --Check if any repeats found
   if repeat_i > 0 then return repeat_i, repeat_j end
   --No matches found at all
   return -1, -1
end

--Returns the index for the next prototypes array item to match the search term.
local function prototypes_find_index_of_next_name_match(array, index, str, pindex)
   local repeat_i = -1
   if index < 1 then index = 1 end
   --Iterate until the end of the inventory for a match
   for i = index, #array, 1 do
      local prototype = array[i]
      if prototype ~= nil and prototype.valid then
         local name = string.lower(localising.get(prototype, pindex))
         local result = string.find(name, str, 1, true)
         if result ~= nil then
            if name ~= players[pindex].menu_search_last_name then
               players[pindex].menu_search_last_name = name
               game.get_player(pindex).play_sound({ path = "Inventory-Move" }) --sound for finding the next
               --game.print("found: " .. i .. " : " .. name .. " vs. " .. str .. ", last: " .. players[pindex].menu_search_last_name,{volume_modifier=0})--
               return i
            else
               repeat_i = i
            end
         end
         --game.print(i .. " : " .. name .. " vs. " .. str .. ", last: " .. players[pindex].menu_search_last_name,{volume_modifier=0})--
      end
   end
   --End of array reached, assume failed and will move on to next.
   return -1
end

local function blueprint_book_find_index_of_next_match(index, str, pindex)
   if players[pindex].menu == "blueprint_book_menu" and players[pindex].blueprint_book_menu.list_mode then
      local book_data = players[pindex].blueprint_book_menu.book_data
      local items = book_data.blueprint_book.blueprints
      if items == nil then return nil end
      for i = index, #items, 1 do
         if items[i] and items[i].blueprint and items[i].blueprint.label then
            local name = string.lower(items[i].blueprint.label)
            local result = string.find(name, str, 1, true)
            if result ~= nil then
               if name ~= players[pindex].menu_search_last_name then
                  players[pindex].menu_search_last_name = name
                  game.get_player(pindex).play_sound({ path = "Inventory-Move" }) --sound for finding the next
                  return i
               else
                  repeat_i = i
               end
            end
         end
      end
      --End of inventory reached, circle back
      game.get_player(pindex).play_sound({ path = "inventory-wrap-around" }) --sound for having cicled around
      for i = 1, index, 1 do
         if items[i] and items[i].blueprint and items[i].blueprint.label then
            local name = string.lower(items[i].blueprint.label)
            local result = string.find(name, str, 1, true)
            if result ~= nil then
               if name ~= players[pindex].menu_search_last_name then
                  players[pindex].menu_search_last_name = name
                  game.get_player(pindex).play_sound({ path = "Inventory-Move" }) --sound for finding the next
                  return i
               else
                  repeat_i = i
               end
            end
         end
      end
   end
   return -1
end

local function travel_find_index_of_next_name_match(index, str, pindex)
   local repeat_i = -1
   local list_size = #players[pindex].travel
   if index == nil or index < 1 then index = 1 end
   --Iterate until the end of the list for a match
   for i = index, list_size, 1 do
      local locus = players[pindex].travel[i]
      if locus and locus.name then
         local name = string.lower(locus.name)
         local result = string.find(name, str, 1, true)
         if result ~= nil then
            if name ~= players[pindex].menu_search_last_name then
               players[pindex].menu_search_last_name = name
               game.get_player(pindex).play_sound({ path = "Inventory-Move" }) --sound for finding the next
               return i
            else
               repeat_i = i
            end
         end
         --game.print(i .. " : " .. name .. " vs. " .. str, { volume_modifier = 0 })
      end
   end
   --End of inventory reached, circle back
   game.get_player(pindex).play_sound({ path = "inventory-wrap-around" }) --sound for having cicled around
   for i = 1, index, 1 do
      local locus = players[pindex].travel[i]
      if locus and locus.name then
         local name = string.lower(locus.name)
         local result = string.find(name, str, 1, true)
         if result ~= nil then
            if name ~= players[pindex].menu_search_last_name then
               players[pindex].menu_search_last_name = name
               game.get_player(pindex).play_sound({ path = "Inventory-Move" }) --sound for finding the next
               return i
            else
               repeat_i = i
            end
         end
         --game.print(i .. " : " .. name .. " vs. " .. str, { volume_modifier = 0 })
      end
   end
   --Check if any repeats found
   if repeat_i > 0 then return repeat_i end
   --No matches found at all
   return -1
end

function mod.open_search_box(pindex)
   --Open the searchbox frame
   players[pindex].entering_search_term = true
   players[pindex].menu_search_index = 0
   players[pindex].menu_search_index_2 = 0
   if players[pindex].menu_search_frame ~= nil then
      players[pindex].menu_search_frame.destroy()
      players[pindex].menu_search_frame = nil
   end
   local frame = fa_graphics.create_text_field_frame(pindex, "enter-search-term")
   players[pindex].menu_search_frame = frame

   --Inform the player
   printout("Type in a search term and press 'ENTER' ", pindex)
end

--Reads out the next inventory/menu item to match the search term. Used in all searchable menus.
function mod.fetch_next(pindex, str, start_phrase_in)
   --Only allow "inventory" and "building" menus for now
   if not players[pindex].in_menu then
      printout("The open map does not support searching.", pindex)
      return
   end
   if
      players[pindex].menu ~= "inventory"
      and players[pindex].menu ~= "building"
      and players[pindex].menu ~= "vehicle"
      and players[pindex].menu ~= "crafting"
      and players[pindex].menu ~= "technology"
      and players[pindex].menu ~= "signal_selector"
      and players[pindex].menu ~= "player_trash"
      and players[pindex].menu ~= "travel"
      and not (players[pindex].menu == "blueprint_book_menu" and players[pindex].blueprint_book_menu.list_mode)
   then
      printout(players[pindex].menu .. " menu does not support searching.", pindex)
      return
   end
   if str == nil or str == "" then
      printout("Missing search term", pindex)
      return
   end
   --Start phrase
   local start_phrase = ""
   if start_phrase_in ~= nil then start_phrase = start_phrase_in end
   --Get the current search index
   local search_index = players[pindex].menu_search_index
   local search_index_2 = players[pindex].menu_search_index_2
   if search_index == nil then
      players[pindex].menu_search_index = 0
      players[pindex].menu_search_index_2 = 0
      search_index = 0
      search_index_2 = 0
   end
   --Search for the new index in the appropriate menu
   local inv = nil
   local new_index = nil
   local new_index_2 = nil
   local pb = players[pindex].building
   if players[pindex].menu == "inventory" then
      inv = game.get_player(pindex).get_main_inventory()
      new_index = inventory_find_index_of_next_name_match(inv, search_index, str, pindex)
   elseif players[pindex].menu == "player_trash" then
      inv = game.get_player(pindex).get_inventory(defines.inventory.character_trash)
      new_index = inventory_find_index_of_next_name_match(inv, search_index, str, pindex)
   elseif (players[pindex].menu == "building" or players[pindex].menu == "vehicle") and pb.sector_name ~= nil then
      if pb.sector_name == "Output" then
         inv = game.get_player(pindex).opened.get_output_inventory()
         new_index = inventory_find_index_of_next_name_match(inv, search_index, str, pindex)
      elseif pb.sector_name == "player inventory from building" then
         inv = game.get_player(pindex).get_main_inventory()
         new_index = inventory_find_index_of_next_name_match(inv, search_index, str, pindex)
      elseif pb.recipe_selection == true then
         new_index, new_index_2 = crafting_find_index_of_next_name_match(
            str,
            pindex,
            search_index,
            search_index_2,
            players[pindex].building.recipe_list
         )
      else
         printout(pb.sector_name .. " sector does not support searching.", pindex)
         return
      end
   elseif players[pindex].menu == "crafting" then
      new_index, new_index_2 = crafting_find_index_of_next_name_match(
         str,
         pindex,
         search_index,
         search_index_2,
         players[pindex].crafting.lua_recipes
      )
   elseif players[pindex].menu == "technology" then
      Research.menu_search(pindex, str, 1)
      return
   elseif players[pindex].menu == "signal_selector" then
      --Search the currently selected group
      local group_index = players[pindex].signal_selector.group_index
      local group_name = players[pindex].signal_selector.group_names[group_index]
      local group = players[pindex].signal_selector.signals[group_name]
      local starting_group_index = group_index
      local tries = 0
      new_index = prototypes_find_index_of_next_name_match(group, search_index, str, pindex)
      while new_index <= 0 and tries < #players[pindex].signal_selector.group_names + 1 do
         players[pindex].menu_search_last_name = "(none)"
         fa_circuits.signal_selector_group_down(pindex)
         group_index = players[pindex].signal_selector.group_index
         group_name = players[pindex].signal_selector.group_names[group_index]
         group = players[pindex].signal_selector.signals[group_name]
         new_index = prototypes_find_index_of_next_name_match(group, 0, str, pindex)
         if tries > 0 and group_index == starting_group_index then
            game.get_player(pindex).play_sound({ path = "inventory-wrap-around" }) --sound for having cicled around
         end
         tries = tries + 1
      end
      if new_index <= 0 then
         players[pindex].signal_selector.group_index = starting_group_index
         players[pindex].signal_selector.signal_index = 0
      end
      --game.print("tries: " .. tries,{volume_modifier=0})--
   elseif players[pindex].menu == "travel" then
      new_index = travel_find_index_of_next_name_match(search_index, str, pindex)
   elseif players[pindex].menu == "blueprint_book_menu" and players[pindex].blueprint_book_menu.list_mode then
      new_index = blueprint_book_find_index_of_next_match(search_index, str, pindex)
   else
      printout("This menu or building sector does not support searching.", pindex)
      return
   end
   --Return a menu output according to the index found
   if new_index <= 0 then
      printout("Could not find " .. str, pindex)
      game.get_player(pindex).print("Menu search: Could not find " .. str, { volume_modifier = 0 })
      players[pindex].menu_search_last_name = "(none)"
      return
   elseif players[pindex].menu == "inventory" then
      players[pindex].menu_search_index = new_index
      players[pindex].inventory.index = new_index
      read_inventory_slot(pindex, start_phrase)
   elseif players[pindex].menu == "player_trash" then
      players[pindex].menu_search_index = new_index
      players[pindex].inventory.index = new_index
      read_inventory_slot(pindex, start_phrase, inv)
   elseif (players[pindex].menu == "building" or players[pindex].menu == "vehicle") and pb.sector_name ~= nil then
      if pb.sector_name == "Output" then
         players[pindex].menu_search_index = new_index
         players[pindex].building.index = new_index
         fa_sectors.read_sector_slot(pindex, false)
      elseif pb.sector_name == "player inventory from building" then
         players[pindex].menu_search_index = new_index
         players[pindex].inventory.index = new_index
         read_inventory_slot(pindex, "")
      elseif players[pindex].building.recipe_selection == true then
         players[pindex].menu_search_index = new_index
         players[pindex].menu_search_index_2 = new_index_2
         players[pindex].building.category = new_index
         players[pindex].building.index = new_index_2
         fa_sectors.read_building_recipe(pindex, start_phrase)
      else
         printout("Search section error", pindex)
         return
      end
   elseif players[pindex].menu == "crafting" then
      players[pindex].menu_search_index = new_index
      players[pindex].menu_search_index_2 = new_index_2
      players[pindex].crafting.category = new_index
      players[pindex].crafting.index = new_index_2
      fa_crafting.read_crafting_slot(pindex, start_phrase)
   elseif players[pindex].menu == "signal_selector" then
      players[pindex].menu_search_index = new_index
      players[pindex].signal_selector.signal_index = new_index
      fa_circuits.read_selected_signal_slot(pindex, start_phrase)
   elseif players[pindex].menu == "travel" then
      players[pindex].menu_search_index = new_index
      players[pindex].travel.index.y = new_index
      fa_travel.read_fast_travel_slot(pindex)
   elseif players[pindex].menu == "blueprint_book_menu" and players[pindex].blueprint_book_menu.list_mode then
      players[pindex].menu_search_index = new_index
      players[pindex].blueprint_book_menu.index = new_index
      fa_blueprints.run_blueprint_book_menu(pindex, new_index, true, false, false)
   else
      printout("Search error", pindex)
      return
   end
end

--Reads out the last inventory/menu item to match the search term. Implemented only in some menus, more can be added later.
function mod.fetch_last(pindex, str)
   --Only allow "inventory" and "building" menus for now
   if not players[pindex].in_menu then
      printout("The open map does not support backwards searching.", pindex)
      return
   end
   if
      players[pindex].menu ~= "inventory"
      and players[pindex].menu ~= "building"
      and players[pindex].menu ~= "technology"
   then
      printout(players[pindex].menu .. " menu does not support backwards searching.", pindex)
      return
   end
   if str == nil or str == "" then
      printout("Missing search term", pindex)
      return
   end
   --Get the current search index
   local search_index = players[pindex].menu_search_index
   if search_index == nil then
      players[pindex].menu_search_index = 0
      search_index = 0
   end
   --Search for the new index in the appropriate menu
   local inv = nil
   local new_index = nil
   local pb = players[pindex].building
   if players[pindex].menu == "inventory" then
      inv = game.get_player(pindex).get_main_inventory()
      new_index = inventory_find_index_of_last_name_match(inv, search_index, str, pindex)
   elseif
      (players[pindex].menu == "building" or players[pindex].menu == "vehicle")
      and pb.sectors
      and pb.sectors[pb.sector]
      and pb.sector_name == "Output"
   then
      inv = game.get_player(pindex).opened.get_output_inventory()
      new_index = inventory_find_index_of_last_name_match(inv, search_index, str, pindex)
   elseif players[pindex].menu == "technology" then
      Research.menu_search(pindex, str, -1)
      return
   else
      printout("This menu or building sector does not support backwards searching.", pindex)
      return
   end
   --Return a menu output according to the index found
   if new_index <= 0 then
      printout("Could not find " .. str, pindex)
      return
   elseif players[pindex].menu == "inventory" then
      players[pindex].menu_search_index = new_index
      players[pindex].inventory.index = new_index
      read_inventory_slot(pindex)
   elseif
      (players[pindex].menu == "building" or players[pindex].menu == "vehicle")
      and pb.sectors
      and pb.sectors[pb.sector]
      and pb.sector_name == "Output"
   then
      players[pindex].menu_search_index = new_index
      players[pindex].building.index = new_index
      fa_sectors.read_sector_slot(pindex, false)
   else
      printout("Search error", pindex)
      return
   end
end

return mod
