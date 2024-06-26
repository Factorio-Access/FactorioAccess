--Here: Crafting menu, crafting queue menu, and related functions

local util = require("util")
local fa_utils = require("scripts.fa-utils")
local localising = require("scripts.localising")

local mod = {}

--Returns a navigable list of all unlocked recipes, for the recipe categories supported by the selected entity. Optionally can return all unlocked recipes for all categories.
function mod.get_recipes(pindex, ent, load_all_categories)
   if not ent then return {} end
   local category_filters = {}
   --Load the supported recipe categories for this entity
   for category_name, _ in pairs(ent.prototype.crafting_categories) do
      table.insert(category_filters, { filter = "category", category = category_name })
   end
   local all_machine_recipes = game.get_filtered_recipe_prototypes(category_filters)
   local unlocked_machine_recipes = {}
   local force_recipes = game.get_player(pindex).force.recipes

   --Load all crafting categories if instructed
   if load_all_categories == true then
      ---@diagnostic disable-next-line: cast-local-type
      all_machine_recipes = force_recipes
   end

   --Load only the unlocked recipes
   for recipe_name, recipe in pairs(all_machine_recipes) do
      if force_recipes[recipe_name] ~= nil and force_recipes[recipe_name].enabled then
         if unlocked_machine_recipes[recipe.group.name] == nil then unlocked_machine_recipes[recipe.group.name] = {} end
         table.insert(unlocked_machine_recipes[recipe.group.name], force_recipes[recipe.name])
      end
   end
   local result = {}
   for group, recipes in pairs(unlocked_machine_recipes) do
      table.insert(result, recipes)
   end
   return result
end

--Reads out the selected slot of the player crafting queue.
function mod.read_crafting_queue(pindex, start_phrase)
   start_phrase = start_phrase or ""
   if players[pindex].crafting_queue.max ~= 0 then
      local item = players[pindex].crafting_queue.lua_queue[players[pindex].crafting_queue.index]
      local recipe_name_only = item.recipe
      printout(
         start_phrase .. localising.get(game.recipe_prototypes[recipe_name_only], pindex) .. " x " .. item.count,
         pindex
      )
   else
      printout(start_phrase .. "Blank", pindex)
   end
end

--Returns a count of how many batches of this recipe are listed in the (entire) crafting queue.
function mod.count_in_crafting_queue(recipe_name, pindex)
   local count = 0
   if game.get_player(pindex).crafting_queue == nil or #game.get_player(pindex).crafting_queue == 0 then
      return count
   end
   for i, item in ipairs(game.get_player(pindex).crafting_queue) do
      if item.recipe == recipe_name then count = count + item.count end
      --game.print(item.recipe .. " vs " .. recipe_name)
   end
   return count
end

--Loads the crafting queue menu for a player.
function mod.load_crafting_queue(pindex)
   if players[pindex].crafting_queue.lua_queue ~= nil then
      players[pindex].crafting_queue.lua_queue = game.get_player(pindex).crafting_queue
      if players[pindex].crafting_queue.lua_queue ~= nil then
         delta = players[pindex].crafting_queue.max - #players[pindex].crafting_queue.lua_queue
         players[pindex].crafting_queue.index = math.max(1, players[pindex].crafting_queue.index - delta)
         players[pindex].crafting_queue.max = #players[pindex].crafting_queue.lua_queue
      else
         players[pindex].crafting_queue.index = 1
         players[pindex].crafting_queue.max = 0
      end
   else
      players[pindex].crafting_queue.lua_queue = game.get_player(pindex).crafting_queue
      players[pindex].crafting_queue.index = 1
      if players[pindex].crafting_queue.lua_queue ~= nil then
         players[pindex].crafting_queue.max = #players[pindex].crafting_queue.lua_queue
      else
         players[pindex].crafting_queue.max = 0
      end
   end
end

--Returns a count of total recipe batches left in the player crafting queue.
function mod.get_crafting_que_total(pindex)
   local p = game.get_player(pindex)
   local total_items = 0
   if p.crafting_queue == nil or p.crafting_queue == {} then return 0 end
   for i, q_item in ipairs(p.crafting_queue) do
      total_items = total_items + q_item.count
   end
   return total_items
end

--Reads the currently selected recipe in the player crafting menu.
function mod.read_crafting_slot(pindex, start_phrase, new_category)
   start_phrase = start_phrase or ""
   local recipe =
      players[pindex].crafting.lua_recipes[players[pindex].crafting.category][players[pindex].crafting.index]
   if recipe.valid == true then
      if new_category == true then start_phrase = start_phrase .. localising.get_alt(recipe.group, pindex) .. ", " end
      printout(
         start_phrase
            .. localising.get_recipe_from_name(recipe.name, pindex)
            .. ", can craft "
            .. game.get_player(pindex).get_craftable_count(recipe.name),
         pindex
      )
   else
      printout("Blank", pindex)
   end
end

--Returns an info string about how many units of which ingredients are missing in order to craft one batch of this recipe.
function mod.recipe_missing_ingredients_info(pindex, recipe_in)
   local recipe = recipe_in
      or players[pindex].crafting.lua_recipes[players[pindex].crafting.category][players[pindex].crafting.index]
   local p = game.get_player(pindex)
   local inv = p.get_main_inventory()
   local result = "Missing "
   local missing = 0
   for i, ing in ipairs(recipe.ingredients) do
      local on_hand = inv.get_item_count(ing.name)
      local needed = ing.amount - on_hand
      if needed > 0 then
         missing = missing + 1
         if missing > 1 then result = result .. " and " end
         result = result .. needed .. " " .. localising.get_item_from_name(ing.name, pindex)
      end
   end
   if missing == 0 then result = "" end
   return result
end

--Returns info text on the raw ingredients for a recipe.
function mod.recipe_raw_ingredients_info(recipe, pindex)
   local raw_ingredients = mod.get_raw_ingredients_table(recipe, pindex)
   --Merge duplicates
   local merged_table = {}
   for i, ing in ipairs(raw_ingredients) do
      local is_in_table = false
      for j, ingt in ipairs(merged_table) do
         if ingt.name == ing.name then
            is_in_table = true
            --Add the count to the existing table count.
            ingt.amount = ingt.amount + ing.amount
         end
      end
      if is_in_table == false then
         --Add a new table entry
         table.insert(merged_table, ing)
      end
   end

   --Construct result string
   local result = "Base ingredients: "
   for j, ingt in ipairs(merged_table) do
      local localised_name = ingt.name
      ---@type LuaItemPrototype | LuaFluidPrototype
      local ingredient_prototype = game.item_prototypes[ingt.name]

      if ingredient_prototype then
         localised_name = localising.get(ingredient_prototype, pindex)
      else
         ingredient_prototype = game.fluid_prototypes[ingt.name]
         if ingredient_prototype ~= nil then
            localised_name = localising.get(ingredient_prototype, pindex)
         else
            localised_name = ingt.name
         end
      end

      result = result .. localised_name .. ", " --" times " .. ingt.amount .. ", "
   end
   return result
end

--Explores a recipe and its sub-recipes and returns a table that contains all ingredients that do not have their own sub-recipes.
--The same ingredient may appear multiple times in the table, so its entries need to be merged.
--Bug: Due to ratios of ingredients to products across multiple recipes, the counts are not being calculated correctly, so they are ignored.
function mod.get_raw_ingredients_table(recipe, pindex, count_in)
   local count = count_in or 1
   local raw_ingredients_table = {}
   for i, ing in ipairs(recipe.ingredients) do
      --Check if a recipe of the ingredient's name exists
      local sub_recipe = game.recipe_prototypes[ing.name]
      if sub_recipe ~= nil and sub_recipe.valid then
         --If the sub-recipe cannot be crafted by hand, add this ingredient to the main table
         if
            sub_recipe.category ~= "basic-crafting"
            and sub_recipe.category ~= "crafting"
            and sub_recipe.category ~= ""
            and sub_recipe.category ~= nil
         then
            for i = 1, count, 1 do
               table.insert(raw_ingredients_table, ing)
            end
         else
            --Check the sub-recipe recursively
            local sub_table = mod.get_raw_ingredients_table(sub_recipe, pindex) --, ing.amount)
            if sub_table ~= nil then
               --Copy the sub_table to the main table
               for j, ing2 in ipairs(sub_table) do
                  for i = 1, count, 1 do
                     table.insert(raw_ingredients_table, ing2)
                  end
               end
            end
         end
      else
         --If a sub-recipe does not exist, add this ingredient to the main table
         for i = 1, count, 1 do
            table.insert(raw_ingredients_table, ing)
         end
      end
   end
   return raw_ingredients_table
end

return mod
