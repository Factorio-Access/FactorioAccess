--Here: Crafting menu, crafting queue menu, and related functions

local util = require("util")
local FaUtils = require("scripts.fa-utils")
local localising = require("scripts.localising")
local Speech = require("scripts.speech")
local MessageBuilder = Speech.MessageBuilder

local mod = {}

--Returns a navigable list of all unlocked recipes, for the recipe categories supported by the selected entity. Optionally can return all unlocked recipes for all categories.
function mod.get_recipes(pindex, ent, load_all_categories)
   if not ent then return {} end
   local category_filters = {}
   --Load the supported recipe categories for this entity
   for category_name, _ in pairs(ent.prototype.crafting_categories) do
      table.insert(category_filters, { filter = "category", category = category_name })
   end
   local all_machine_recipes = prototypes.get_recipe_filtered(category_filters)
   local unlocked_machine_recipes = {}
   local force_recipes = game.get_player(pindex).force.recipes

   --Load all crafting categories if instructed
   if load_all_categories == true then
      ---@diagnostic disable-next-line: cast-local-type
      all_machine_recipes = force_recipes
   end

   --Load only the unlocked recipes
   for recipe_name, recipe in pairs(all_machine_recipes) do
      local force_recipe = force_recipes[recipe_name]
      local proto = prototypes.recipe[recipe_name]
      -- only include enabled, non-hidden recipes that actually produce items
      if force_recipe and force_recipe.enabled and not force_recipe.hidden and proto and next(proto.products) then
         local grp = recipe.group.name
         unlocked_machine_recipes[grp] = unlocked_machine_recipes[grp] or {}
         table.insert(unlocked_machine_recipes[grp], force_recipe)
      end
   end
   local result = {}
   for group, recipes in pairs(unlocked_machine_recipes) do
      table.insert(result, recipes)
   end
   return result
end

--Returns a count of how many batches of this recipe are listed in the (entire) crafting queue.
function mod.count_in_crafting_queue(recipe_name, pindex)
   local count = 0
   if game.get_player(pindex).crafting_queue == nil or #game.get_player(pindex).crafting_queue == 0 then
      return count
   end
   for i, item in ipairs(game.get_player(pindex).crafting_queue) do
      if item.recipe == recipe_name then count = count + item.count end
   end
   return count
end

--Check if a recipe requires fluid ingredients
---@param recipe LuaRecipe
---@return boolean
function mod.recipe_requires_fluids(recipe)
   for _, ing in ipairs(recipe.ingredients) do
      if ing.type == "fluid" then return true end
   end
   return false
end

--Returns an info string about why crafting failed for this recipe.
--Checks for fluid requirements first, then missing item ingredients.
---@param pindex integer
---@param recipe_in LuaRecipe?
---@return LocalisedString?
function mod.recipe_cannot_craft_reason(pindex, recipe_in)
   local recipe = recipe_in
      or storage.players[pindex].crafting.lua_recipes[storage.players[pindex].crafting.category][storage.players[pindex].crafting.index]

   -- Check if recipe requires fluids (cannot be hand-crafted normally)
   if mod.recipe_requires_fluids(recipe) then return { "fa.crafting-requires-fluids" } end

   -- Check for missing item ingredients
   local p = game.get_player(pindex)
   local inv = p.get_main_inventory()
   local message = MessageBuilder.new()
   local found_missing = false

   for _, ing in ipairs(recipe.ingredients) do
      if ing.type == "item" then
         local on_hand = inv.get_item_count(ing.name)
         local needed = ing.amount - on_hand
         if needed > 0 then
            if not found_missing then
               message:fragment({ "fa.crafting-missing" })
               found_missing = true
            end
            local proto = prototypes.item[ing.name]
            message:list_item({
               "fa.crafting-missing-ingredient",
               tostring(needed),
               localising.get_localised_name_with_fallback(proto),
            })
         end
      end
   end

   return message:build()
end

return mod
