--Here: Menu search and directly related functions
local Blueprints = require("scripts.blueprints")
local Sectors = require("scripts.building-vehicle-sectors")
local Circuits = require("scripts.circuit-networks")
local Crafting = require("scripts.crafting")
local Graphics = require("scripts.graphics")
local localising = require("scripts.localising")
local Research = require("scripts.research")
local Travel = require("scripts.travel-tools")
local UiRouter = require("scripts.ui.router")

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
            if name ~= storage.players[pindex].menu_search_last_name then
               storage.players[pindex].menu_search_last_name = name
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
      local stack = inv[i]
      if stack ~= nil and stack.valid_for_read then
         local name = string.lower(localising.get(stack.prototype, pindex))
         local result = string.find(name, str, 1, true)
         if result ~= nil then
            if name ~= storage.players[pindex].menu_search_last_name then
               storage.players[pindex].menu_search_last_name = name
               game.get_player(pindex).play_sound({ path = "Inventory-Move" }) --sound for finding the next
               return i
            else
               repeat_i = i
            end
         end
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
            if name ~= storage.players[pindex].menu_search_last_name then
               storage.players[pindex].menu_search_last_name = name
               game.get_player(pindex).play_sound({ path = "Inventory-Move" }) --sound for finding the next
               return i
            else
               repeat_i = i
            end
         end
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
            if name ~= storage.players[pindex].menu_search_last_name then
               storage.players[pindex].menu_search_last_name = name
               game.get_player(pindex).play_sound({ path = "Inventory-Move" }) --sound for finding the next
               return i
            else
               repeat_i = i
            end
         end
      end
   end
   --Check if any repeats found
   if repeat_i > 0 then return repeat_i end
   --No matches found at all
   return -1
end

--Returns the index for the next recipe to match the search term, designed for the way recipes are saved in storage.players[pindex]
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
            if result ~= nil then
               if name ~= storage.players[pindex].menu_search_last_name then
                  storage.players[pindex].menu_search_last_name = name
                  game.get_player(pindex).play_sound({ path = "Inventory-Move" }) --sound for finding the next
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
            if result ~= nil then
               if name ~= storage.players[pindex].menu_search_last_name then
                  storage.players[pindex].menu_search_last_name = name
                  game.get_player(pindex).play_sound({ path = "Inventory-Move" }) --sound for finding the next
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
            if name ~= storage.players[pindex].menu_search_last_name then
               storage.players[pindex].menu_search_last_name = name
               game.get_player(pindex).play_sound({ path = "Inventory-Move" }) --sound for finding the next
               return i
            else
               repeat_i = i
            end
         end
      end
   end
   --End of array reached, assume failed and will move on to next.
   return -1
end

local function blueprint_book_find_index_of_next_match(index, str, pindex)
   local router = UiRouter.get_router(pindex)

   if router:is_ui_open(UiRouter.UI_NAMES.BLUEPRINT_BOOK) and storage.players[pindex].blueprint_book_menu.list_mode then
      local book_data = storage.players[pindex].blueprint_book_menu.book_data
      local items = book_data.blueprint_book.blueprints
      if items == nil then return nil end
      for i = index, #items, 1 do
         if items[i] and items[i].blueprint and items[i].blueprint.label then
            local name = string.lower(items[i].blueprint.label)
            local result = string.find(name, str, 1, true)
            if result ~= nil then
               if name ~= storage.players[pindex].menu_search_last_name then
                  storage.players[pindex].menu_search_last_name = name
                  game.get_player(pindex).play_sound({ path = "Inventory-Move" }) --sound for finding the next
                  return i
               else
                  local repeat_i = i
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
               if name ~= storage.players[pindex].menu_search_last_name then
                  storage.players[pindex].menu_search_last_name = name
                  game.get_player(pindex).play_sound({ path = "Inventory-Move" }) --sound for finding the next
                  return i
               else
                  local repeat_i = i
               end
            end
         end
      end
   end
   return -1
end

local function travel_find_index_of_next_name_match(index, str, pindex)
   local repeat_i = -1
   local list_size = #storage.players[pindex].travel
   if index == nil or index < 1 then index = 1 end
   --Iterate until the end of the list for a match
   for i = index, list_size, 1 do
      local locus = storage.players[pindex].travel[i]
      if locus and locus.name then
         local name = string.lower(locus.name)
         local result = string.find(name, str, 1, true)
         if result ~= nil then
            if name ~= storage.players[pindex].menu_search_last_name then
               storage.players[pindex].menu_search_last_name = name
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
      local locus = storage.players[pindex].travel[i]
      if locus and locus.name then
         local name = string.lower(locus.name)
         local result = string.find(name, str, 1, true)
         if result ~= nil then
            if name ~= storage.players[pindex].menu_search_last_name then
               storage.players[pindex].menu_search_last_name = name
               game.get_player(pindex).play_sound({ path = "Inventory-Move" }) --sound for finding the next
               return i
            else
               repeat_i = i
            end
         end
      end
   end
   --Check if any repeats found
   if repeat_i > 0 then return repeat_i end
   --No matches found at all
   return -1
end

function mod.open_search_box(pindex)
   --Open the searchbox frame
   storage.players[pindex].entering_search_term = true
   storage.players[pindex].menu_search_index = 0
   storage.players[pindex].menu_search_index_2 = 0
   if storage.players[pindex].menu_search_frame ~= nil then
      storage.players[pindex].menu_search_frame.destroy()
      storage.players[pindex].menu_search_frame = nil
   end
   local frame = Graphics.create_text_field_frame(pindex, "enter-search-term")
   storage.players[pindex].menu_search_frame = frame

   --Inform the player
   printout({ "fa.menu-search-type-term" }, pindex)
end

--Reads out the next inventory/menu item to match the search term. Used in all searchable menus.
function mod.fetch_next(pindex, str, start_phrase_in)
   local router = UiRouter.get_router(pindex)

   --Only allow "inventory" and "building" menus for now
   if not router:is_ui_open() then
      printout({ "fa.menu-search-map-unsupported" }, pindex)
      return
   end
   if
      not router:is_ui_one_of({
         UiRouter.UI_NAMES.INVENTORY,
         UiRouter.UI_NAMES.BUILDING,
         UiRouter.UI_NAMES.VEHICLE,
         UiRouter.UI_NAMES.CRAFTING,
         UiRouter.UI_NAMES.TECHNOLOGY,
         UiRouter.UI_NAMES.SIGNAL_SELECTOR,
         UiRouter.UI_NAMES.PLAYER_TRASH,
         UiRouter.UI_NAMES.TRAVEL,
      })
      or (router:is_ui_open(UiRouter.UI_NAMES.BLUEPRINT_BOOK) and storage.players[pindex].blueprint_book_menu.list_mode)
   then
      printout({ "fa.menu-search-menu-unsupported" }, pindex)
      return
   end
   if str == nil or str == "" then
      printout({ "fa.menu-search-missing-term" }, pindex)
      return
   end
   --Start phrase
   local start_phrase = ""
   if start_phrase_in ~= nil then start_phrase = start_phrase_in end
   --Get the current search index
   local search_index = storage.players[pindex].menu_search_index
   local search_index_2 = storage.players[pindex].menu_search_index_2
   if search_index == nil then
      storage.players[pindex].menu_search_index = 0
      storage.players[pindex].menu_search_index_2 = 0
      search_index = 0
      search_index_2 = 0
   end
   --Search for the new index in the appropriate menu
   local inv = nil
   local new_index = nil
   local new_index_2 = nil
   local pb = storage.players[pindex].building
   if router:is_ui_open(UiRouter.UI_NAMES.INVENTORY) then
      inv = game.get_player(pindex).get_main_inventory()
      new_index = inventory_find_index_of_next_name_match(inv, search_index, str, pindex)
   elseif router:is_ui_open(UiRouter.UI_NAMES.PLAYER_TRASH) then
      inv = game.get_player(pindex).get_inventory(defines.inventory.character_trash)
      new_index = inventory_find_index_of_next_name_match(inv, search_index, str, pindex)
   elseif router:is_ui_one_of({ UiRouter.UI_NAMES.BUILDING, UiRouter.UI_NAMES.VEHICLE }) and pb.sector_name ~= nil then
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
            storage.players[pindex].building.recipe_list
         )
      else
         printout({ "fa.menu-search-sector-not-supported", pb.sector_name }, pindex)
         return
      end
   elseif router:is_ui_open(UiRouter.UI_NAMES.CRAFTING) then
      new_index, new_index_2 = crafting_find_index_of_next_name_match(
         str,
         pindex,
         search_index,
         search_index_2,
         storage.players[pindex].crafting.lua_recipes
      )
   elseif router:is_ui_open(UiRouter.UI_NAMES.TECHNOLOGY) then
      Research.menu_search(pindex, str, 1)
      return
   elseif router:is_ui_open(UiRouter.UI_NAMES.SIGNAL_SELECTOR) then
      --Search the currently selected group
      local group_index = storage.players[pindex].signal_selector.group_index
      local group_name = storage.players[pindex].signal_selector.group_names[group_index]
      local group = storage.players[pindex].signal_selector.signals[group_name]
      local starting_group_index = group_index
      local tries = 0
      new_index = prototypes_find_index_of_next_name_match(group, search_index, str, pindex)
      while new_index <= 0 and tries < #storage.players[pindex].signal_selector.group_names + 1 do
         storage.players[pindex].menu_search_last_name = "(none)"
         Circuits.signal_selector_group_down(pindex)
         group_index = storage.players[pindex].signal_selector.group_index
         group_name = storage.players[pindex].signal_selector.group_names[group_index]
         group = storage.players[pindex].signal_selector.signals[group_name]
         new_index = prototypes_find_index_of_next_name_match(group, 0, str, pindex)
         if tries > 0 and group_index == starting_group_index then
            game.get_player(pindex).play_sound({ path = "inventory-wrap-around" }) --sound for having cicled around
         end
         tries = tries + 1
      end
      if new_index <= 0 then
         storage.players[pindex].signal_selector.group_index = starting_group_index
         storage.players[pindex].signal_selector.signal_index = 0
      end
   elseif router:is_ui_open(UiRouter.UI_NAMES.TRAVEL) then
      new_index = travel_find_index_of_next_name_match(search_index, str, pindex)
   elseif
      router:is_ui_open(UiRouter.UI_NAMES.BLUEPRINT_BOOK_MENU) and storage.players[pindex].blueprint_book_menu.list_mode
   then
      new_index = blueprint_book_find_index_of_next_match(search_index, str, pindex)
   else
      printout({ "fa.menu-search-sector-unsupported" }, pindex)
      return
   end
   --Return a menu output according to the index found
   if new_index <= 0 then
      printout({ "fa.menu-search-not-found", str }, pindex)
      game.get_player(pindex).print("Menu search: Could not find " .. str, { volume_modifier = 0 })
      storage.players[pindex].menu_search_last_name = "(none)"
      return
   elseif router:is_ui_open(UiRouter.UI_NAMES.INVENTORY) then
      storage.players[pindex].menu_search_index = new_index
      storage.players[pindex].inventory.index = new_index
      read_inventory_slot(pindex, start_phrase)
   elseif router:is_ui_open(UiRouter.UI_NAMES.PLAYER_TRASH) then
      storage.players[pindex].menu_search_index = new_index
      storage.players[pindex].inventory.index = new_index
      read_inventory_slot(pindex, start_phrase, inv)
   elseif router:is_ui_one_of({ UiRouter.UI_NAMES.BUILDING, UiRouter.UI_NAMES.VEHICLE }) and pb.sector_name ~= nil then
      if pb.sector_name == "Output" then
         storage.players[pindex].menu_search_index = new_index
         storage.players[pindex].building.index = new_index
         Sectors.read_sector_slot(pindex, false)
      elseif pb.sector_name == "player inventory from building" then
         storage.players[pindex].menu_search_index = new_index
         storage.players[pindex].inventory.index = new_index
         read_inventory_slot(pindex, "")
      elseif storage.players[pindex].building.recipe_selection == true then
         storage.players[pindex].menu_search_index = new_index
         storage.players[pindex].menu_search_index_2 = new_index_2
         storage.players[pindex].building.category = new_index
         storage.players[pindex].building.index = new_index_2
         Sectors.read_building_recipe(pindex, start_phrase)
      else
         printout({ "fa.menu-search-section-error" }, pindex)
         return
      end
   elseif router:is_ui_open(UiRouter.UI_NAMES.CRAFTING) then
      storage.players[pindex].menu_search_index = new_index
      storage.players[pindex].menu_search_index_2 = new_index_2
      storage.players[pindex].crafting.category = new_index
      storage.players[pindex].crafting.index = new_index_2
      Crafting.read_crafting_slot(pindex, start_phrase)
   elseif router:is_ui_open(UiRouter.UI_NAMES.SIGNAL_SELECTOR) then
      storage.players[pindex].menu_search_index = new_index
      storage.players[pindex].signal_selector.signal_index = new_index
      Circuits.read_selected_signal_slot(pindex, start_phrase)
   elseif router:is_ui_open(UiRouter.UI_NAMES.TRAVEL) then
      storage.players[pindex].menu_search_index = new_index
      storage.players[pindex].travel.index.y = new_index
      Travel.read_fast_travel_slot(pindex)
   elseif
      router:is_ui_open(UiRouter.UI_NAMES.BLUEPRINT_BOOK) and storage.players[pindex].blueprint_book_menu.list_mode
   then
      storage.players[pindex].menu_search_index = new_index
      storage.players[pindex].blueprint_book_menu.index = new_index
      Blueprints.run_blueprint_book_menu(pindex, new_index, true, false, false)
   else
      printout({ "fa.menu-search-error" }, pindex)
      return
   end
end

--Reads out the last inventory/menu item to match the search term. Implemented only in some menus, more can be added later.
function mod.fetch_last(pindex, str)
   local router = UiRouter.get_router(pindex)

   --Only allow "inventory" and "building" menus for now
   if not router:is_ui_open() then
      printout({ "fa.menu-search-map-no-backwards" }, pindex)
      return
   end
   if
      not router:is_ui_one_of({
         UiRouter.UI_NAMES.INVENTORY,
         UiRouter.UI_NAMES.BUILDING,

         UiRouter.UI_NAMES.TECHNOLOGY,
      })
   then
      printout({ "fa.menu-search-no-backwards", storage.players[pindex].menu }, pindex)
      return
   end
   if str == nil or str == "" then
      printout({ "fa.menu-search-missing-term" }, pindex)
      return
   end
   --Get the current search index
   local search_index = storage.players[pindex].menu_search_index
   if search_index == nil then
      storage.players[pindex].menu_search_index = 0
      search_index = 0
   end
   --Search for the new index in the appropriate menu
   local inv = nil
   local new_index = nil
   local pb = storage.players[pindex].building
   if router:is_ui_open(UiRouter.UI_NAMES.INVENTORY) then
      inv = game.get_player(pindex).get_main_inventory()
      new_index = inventory_find_index_of_last_name_match(inv, search_index, str, pindex)
   elseif
      router:is_ui_one_of({ UiRouter.UI_NAMES.BUILDING, UiRouter.UI_NAMES.VEHICLE })
      and pb.sectors
      and pb.sectors[pb.sector]
      and pb.sector_name == "Output"
   then
      inv = game.get_player(pindex).opened.get_output_inventory()
      new_index = inventory_find_index_of_last_name_match(inv, search_index, str, pindex)
   elseif router:is_ui_open(UiRouter.UI_NAMES.TECHNOLOGY) then
      Research.menu_search(pindex, str, -1)
      return
   else
      printout("This menu or building sector does not support backwards searching.", pindex)
      return
   end
   --Return a menu output according to the index found
   if new_index <= 0 then
      printout({ "fa.menu-search-not-found", str }, pindex)
      return
   elseif router:is_ui_open(UiRouter.UI_NAMES.INVENTORY) then
      storage.players[pindex].menu_search_index = new_index
      storage.players[pindex].inventory.index = new_index
      read_inventory_slot(pindex)
   elseif
      router:is_ui_one_of({ UiRouter.UI_NAMES.BUILDING, UiRouter.UI_NAMES.VEHICLE })
      and pb.sectors
      and pb.sectors[pb.sector]
      and pb.sector_name == "Output"
   then
      storage.players[pindex].menu_search_index = new_index
      storage.players[pindex].building.index = new_index
      Sectors.read_sector_slot(pindex, false)
   else
      printout({ "fa.menu-search-error" }, pindex)
      return
   end
end

return mod
