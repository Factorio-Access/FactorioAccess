--[[
Item Descriptions Module
Provides functionality to read descriptions for various items, entities, and menu selections.
Handles descriptions for selected entities, items in hand, inventory items, and menu items.
]]

local UiRouter = require("scripts.ui.router")
local Driving = require("scripts.driving")
local Equipment = require("scripts.equipment")
local Research = require("scripts.research")
local Speech = require("scripts.speech")

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
      Speech.speak(pindex, str)
   elseif hand and hand.valid_for_read then
      local str = get_stack_description(hand)
      local result = { "", "In hand: ", str }
      Speech.speak(pindex, result)
   else
      Speech.speak(pindex, "Nothing selected, use this key to describe an entity or item that you select.")
   end
end

---Reads description for inventory slot
---@param pindex number
function mod.read_inventory_slot_description(pindex)
   local p = game.get_player(pindex)
   local router = UiRouter.get_router(pindex)
   local storage_players = storage.players[pindex]

   local stack = storage_players.inventory.lua_inventory[storage_players.inventory.index]

   local str = get_stack_description(stack)
   Speech.speak(pindex, str)
end

---Reads description for guns menu selection
---@param pindex number
function mod.read_guns_menu_description(pindex)
   local stack = Equipment.guns_menu_get_selected_slot(pindex)
   if stack and stack.valid_for_read then
      local str = stack.prototype.localised_description
      if str == nil or str == "" then str = "No description" end
      Speech.speak(pindex, str)
   else
      Speech.speak(pindex, "No description")
   end
end

---Reads description for crafting menu selection
---@param pindex number
function mod.read_crafting_menu_description(pindex)
   local storage_players = storage.players[pindex]
   local recipe =
      storage_players.crafting.lua_recipes[storage_players.crafting.category][storage_players.crafting.index]
   local str = get_recipe_product_description(recipe)
   Speech.speak(pindex, str)
end

---Reads description for building/vehicle menu selection
---@param pindex number
function mod.read_building_menu_description(pindex)
   local storage_players = storage.players[pindex]
   -- [UI CHECKS REMOVED] Offset calculation removed - caller should handle context

   local offset = 0
   if storage_players.building.recipe_list ~= nil then offset = 1 end

   if storage_players.building.recipe_selection then
      local recipe =
         storage_players.building.recipe_list[storage_players.building.category][storage_players.building.index]
      if recipe ~= nil and #recipe.products > 0 then
         local product_name = recipe.products[1].name
         local product = prototypes.item[product_name] or prototypes.fluid[product_name]
         local str = product.localised_description
         if str == nil or str == "" then str = "No description found for this" end
         Speech.speak(pindex, str)
      else
         Speech.speak(pindex, "No description found, menu error")
      end
   elseif storage_players.building.sector <= #storage_players.building.sectors then
      local inventory = storage_players.building.sectors[storage_players.building.sector].inventory
      if inventory == nil or not inventory.valid then
         Speech.speak(pindex, "No description found, menu error")
         return
      end

      local sector_name = storage_players.building.sectors[storage_players.building.sector].name
      if sector_name ~= "Fluid" and sector_name ~= "Filters" and inventory.is_empty() then
         Speech.speak(pindex, "No description found, menu error")
         return
      end

      local stack = inventory[storage_players.building.index]
      local str = get_stack_description(stack)
      if str == "No description" then str = "No description found for this item" end
      Speech.speak(pindex, str)
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
   -- [UI CHECKS REMOVED] Menu routing removed - new UI system will handle context
   -- Default to world behavior (selected or hand)
   local p = game.get_player(pindex)

   -- Special case: driving
   if p.driving then
      Speech.speak(pindex, Driving.vehicle_info(pindex))
      return
   end

   -- Default: check selected or hand
   mod.read_selected_or_hand_description(pindex)
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
   -- [UI CHECKS REMOVED] Scanner descriptions now available anytime

   local ent = storage.players[pindex].last_indexed_ent
   if ent == nil or not ent.valid then
      Speech.speak(pindex, "No description, note that most resources need to be examined from up close")
      return
   end

   local str = ent.localised_description
   if str == nil or str == "" then str = "No description found for this entity" end
   Speech.speak(pindex, str)
end

return mod
