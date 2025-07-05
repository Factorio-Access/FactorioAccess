--[[
Item Descriptions Module
Provides functionality to read descriptions for various items, entities, and menu selections.
Handles descriptions for selected entities, items in hand, inventory items, and menu items.
]]

local UiRouter = require("scripts.ui.router")
local Driving = require("scripts.driving")
local Equipment = require("scripts.equipment")
local Research = require("scripts.research")

local mod = {}

---Gets description for an item stack, handling place results
---@param stack LuaItemStack
---@return LocalisedString
local function get_stack_description(stack)
   if not stack or not stack.valid_for_read then return "No description" end

   ---@type LocalisedString
   local str = ""
   if stack.prototype.place_result ~= nil then
      str = stack.prototype.place_result.localised_description
   else
      str = stack.prototype.localised_description
   end

   if str == nil or str == "" then str = "No description" end
   return str
end

---Gets description for a recipe product
---@param recipe LuaRecipe
---@return LocalisedString
local function get_recipe_product_description(recipe)
   if recipe == nil or #recipe.products == 0 then return "No description found, menu error" end

   local product_name = recipe.products[1].name
   ---@type LuaItemPrototype | LuaFluidPrototype
   local product = prototypes.item[product_name]
   local product_is_item = true

   if product == nil then
      product = prototypes.fluid[product_name]
      product_is_item = false
   elseif product_name == "empty-barrel" and recipe.products[2] ~= nil then
      product_name = recipe.products[2].name
      product = prototypes.fluid[product_name]
      product_is_item = false
   end

   ---@type LocalisedString
   local str = ""
   if product_is_item and product.place_result ~= nil then
      str = product.place_result.localised_description
   else
      str = product.localised_description
   end

   if str == nil or str == "" then str = "No description found for this" end
   return str
end

---Reads description for selected entity or item in hand
---@param pindex number
function mod.read_selected_or_hand_description(pindex)
   local p = game.get_player(pindex)
   local hand = p.cursor_stack

   local ent = p.selected
   if ent and ent.valid then
      local str = ent.localised_description
      if str == nil or str == "" then str = "No description for this entity" end
      printout(str, pindex)
   elseif hand and hand.valid_for_read then
      local str = get_stack_description(hand)
      local result = { "", "In hand: ", str }
      printout(result, pindex)
   else
      printout("Nothing selected, use this key to describe an entity or item that you select.", pindex)
   end
end

---Reads description for inventory slot
---@param pindex number
function mod.read_inventory_slot_description(pindex)
   local p = game.get_player(pindex)
   local router = UiRouter.get_router(pindex)
   local storage_players = storage.players[pindex]

   local stack = storage_players.inventory.lua_inventory[storage_players.inventory.index]
   if router:is_ui_open(UiRouter.UI_NAMES.PLAYER_TRASH) then
      stack = p.get_inventory(defines.inventory.character_trash)[storage_players.inventory.index]
   end

   local str = get_stack_description(stack)
   printout(str, pindex)
end

---Reads description for guns menu selection
---@param pindex number
function mod.read_guns_menu_description(pindex)
   local stack = Equipment.guns_menu_get_selected_slot(pindex)
   if stack and stack.valid_for_read then
      local str = stack.prototype.localised_description
      if str == nil or str == "" then str = "No description" end
      printout(str, pindex)
   else
      printout("No description", pindex)
   end
end

---Reads description for crafting menu selection
---@param pindex number
function mod.read_crafting_menu_description(pindex)
   local storage_players = storage.players[pindex]
   local recipe =
      storage_players.crafting.lua_recipes[storage_players.crafting.category][storage_players.crafting.index]
   local str = get_recipe_product_description(recipe)
   printout(str, pindex)
end

---Reads description for building/vehicle menu selection
---@param pindex number
function mod.read_building_menu_description(pindex)
   local storage_players = storage.players[pindex]
   local router = UiRouter.get_router(pindex)

   local offset = 0
   if
      router:is_ui_one_of({ UiRouter.UI_NAMES.BUILDING, UiRouter.UI_NAMES.VEHICLE })
      and storage_players.building.recipe_list ~= nil
   then
      offset = 1
   end

   if storage_players.building.recipe_selection then
      local recipe =
         storage_players.building.recipe_list[storage_players.building.category][storage_players.building.index]
      if recipe ~= nil and #recipe.products > 0 then
         local product_name = recipe.products[1].name
         local product = prototypes.item[product_name] or prototypes.fluid[product_name]
         local str = product.localised_description
         if str == nil or str == "" then str = "No description found for this" end
         printout(str, pindex)
      else
         printout("No description found, menu error", pindex)
      end
   elseif storage_players.building.sector <= #storage_players.building.sectors then
      local inventory = storage_players.building.sectors[storage_players.building.sector].inventory
      if inventory == nil or not inventory.valid then
         printout("No description found, menu error", pindex)
         return
      end

      local sector_name = storage_players.building.sectors[storage_players.building.sector].name
      if sector_name ~= "Fluid" and sector_name ~= "Filters" and inventory.is_empty() then
         printout("No description found, menu error", pindex)
         return
      end

      local stack = inventory[storage_players.building.index]
      local str = get_stack_description(stack)
      if str == "No description" then str = "No description found for this item" end
      printout(str, pindex)
   end
end

---Main function to read item descriptions based on context
---@param event EventData.CustomInputEvent
function mod.read_item_info(event)
   local pindex = event.player_index
   mod.read_item_description(pindex)
end

---Internal function to read item descriptions based on context
---@param pindex number
function mod.read_item_description(pindex)
   local router = UiRouter.get_router(pindex)
   local p = game.get_player(pindex)
   local storage_players = storage.players[pindex]

   -- Special case: driving
   if p.driving and not router:is_ui_open(UiRouter.UI_NAMES.TRAIN) then
      printout(Driving.vehicle_info(pindex), pindex)
      return
   end

   -- Not in menu - check selected or hand
   if not router:is_ui_open() then
      mod.read_selected_or_hand_description(pindex)
      return
   end

   -- In menu - handle based on menu type
   local offset = 0
   if
      router:is_ui_one_of({ UiRouter.UI_NAMES.BUILDING, UiRouter.UI_NAMES.VEHICLE })
      and storage_players.building.recipe_list ~= nil
   then
      offset = 1
   end

   if
      router:is_ui_one_of({ UiRouter.UI_NAMES.INVENTORY, UiRouter.UI_NAMES.PLAYER_TRASH })
      or (
         router:is_ui_one_of({ UiRouter.UI_NAMES.BUILDING, UiRouter.UI_NAMES.VEHICLE })
         and storage_players.building.sector > offset + #storage_players.building.sectors
      )
   then
      mod.read_inventory_slot_description(pindex)
   elseif router:is_ui_open(UiRouter.UI_NAMES.GUNS) then
      mod.read_guns_menu_description(pindex)
   elseif router:is_ui_open(UiRouter.UI_NAMES.TECHNOLOGY) then
      Research.menu_describe(pindex)
   elseif router:is_ui_open(UiRouter.UI_NAMES.CRAFTING) then
      mod.read_crafting_menu_description(pindex)
   elseif router:is_ui_one_of({ UiRouter.UI_NAMES.BUILDING, UiRouter.UI_NAMES.VEHICLE }) then
      mod.read_building_menu_description(pindex)
   else
      printout("Descriptions are not supported for this menu.", pindex)
   end
end

---Reads description for last indexed scanner entity
---@param event EventData.CustomInputEvent
function mod.read_last_indexed_item_info(event)
   local pindex = event.player_index
   mod.read_last_indexed_description(pindex)
end

---Internal function to read description for last indexed scanner entity
---@param pindex number
function mod.read_last_indexed_description(pindex)
   local router = UiRouter.get_router(pindex)

   if router:is_ui_open() then
      printout("Error: Cannot check scanned item descriptions while in a menu", pindex)
      return
   end

   local ent = storage.players[pindex].last_indexed_ent
   if ent == nil or not ent.valid then
      printout("No description, note that most resources need to be examined from up close", pindex)
      return
   end

   local str = ent.localised_description
   if str == nil or str == "" then str = "No description found for this entity" end
   printout(str, pindex)
end

return mod
