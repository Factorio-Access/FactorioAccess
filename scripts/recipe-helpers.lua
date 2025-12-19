--[[
Shared helpers for displaying recipe information.
Used by crafting menu, assembling machine tab, and other recipe-related features.
Takes MessageBuilder directly to avoid UI dependencies.
]]

local ItemInfo = require("scripts.item-info")
local Localising = require("scripts.localising")

local mod = {}

---Read recipe ingredients and products
---@param message fa.MessageBuilder The message builder to append to
---@param recipe LuaRecipe The recipe to read
function mod.read_recipe_details(message, recipe)
   -- Read ingredients
   message:fragment({ "fa.crafting-ingredients" })
   for _, ingredient in ipairs(recipe.ingredients) do
      -- Use item_or_fluid_info for proper formatting with count
      local protos = prototypes.item[ingredient.name] and prototypes.item or prototypes.fluid
      local item_str = ItemInfo.item_or_fluid_info({
         name = ingredient.name,
         count = ingredient.amount,
      }, protos)
      message:list_item(item_str)
   end

   -- Read products
   message:fragment({ "fa.crafting-products" })
   for _, product in ipairs(recipe.products) do
      local protos = prototypes.item[product.name] and prototypes.item or prototypes.fluid

      if product.amount then
         -- Simple case with fixed amount
         local item_str = ItemInfo.item_or_fluid_info({
            name = product.name,
            count = product.amount,
         }, protos)
         message:list_item(item_str)
      elseif product.amount_min and product.amount_max then
         -- Variable amount - show range separately
         local item_str = ItemInfo.item_or_fluid_info({
            name = product.name,
         }, protos)
         message:list_item(item_str)
         message:fragment({ "fa.recipe-range", product.amount_min, product.amount_max })
      else
         -- No amount specified
         local item_str = ItemInfo.item_or_fluid_info({
            name = product.name,
         }, protos)
         message:list_item(item_str)
      end

      -- Include probability if less than 100%
      if product.probability and product.probability < 1 then
         message:fragment(("%.2f%%"):format(product.probability * 100))
      end
   end
end

---Get all categories a recipe belongs to
---@param recipe LuaRecipe
---@return string[]
local function get_recipe_categories(recipe)
   local categories = { recipe.category }
   if recipe.additional_categories then
      for _, cat in ipairs(recipe.additional_categories) do
         table.insert(categories, cat)
      end
   end
   return categories
end

---Get crafters that can make a recipe, separated into hand-craftable and machines
---@param recipe LuaRecipe
---@return boolean can_hand_craft
---@return LuaEntityPrototype[] machines
function mod.get_recipe_crafters(recipe)
   local categories = get_recipe_categories(recipe)
   local can_hand_craft = false
   local machines_seen = {}
   local machines = {}

   -- Check if any character prototype can craft this recipe
   local characters = prototypes.get_entity_filtered({ { filter = "type", type = "character" } })
   for _, char_proto in pairs(characters) do
      if char_proto.crafting_categories then
         for _, category in ipairs(categories) do
            if char_proto.crafting_categories[category] then
               can_hand_craft = true
               break
            end
         end
      end
      if can_hand_craft then break end
   end

   -- Get machines that can craft this recipe
   for _, category in ipairs(categories) do
      local entities =
         prototypes.get_entity_filtered({ { filter = "crafting-category", crafting_category = category } })
      for name, proto in pairs(entities) do
         if proto.type ~= "character" and not machines_seen[name] then
            machines_seen[name] = true
            table.insert(machines, proto)
         end
      end
   end

   -- Sort machines alphabetically by name for consistency
   table.sort(machines, function(a, b)
      return a.name < b.name
   end)

   return can_hand_craft, machines
end

---Read recipe details including crafting time and what can craft it
---@param message fa.MessageBuilder The message builder to append to
---@param recipe LuaRecipe The recipe to read
function mod.read_recipe_details_with_time(message, recipe)
   mod.read_recipe_details(message, recipe)

   -- Add crafting time
   message:fragment({ "fa.assembling-machine-crafting-time", recipe.energy })

   -- Add what can craft this recipe
   local can_hand_craft, machines = mod.get_recipe_crafters(recipe)
   message:fragment({ "fa.recipe-crafted-by" })
   if can_hand_craft then message:list_item({ "fa.recipe-crafted-by-hand" }) end
   for _, machine in ipairs(machines) do
      message:list_item(Localising.get_localised_name_with_fallback(machine))
   end
end

---Create a label for a recipe, optionally marking it as current
---@param message fa.MessageBuilder The message builder to append to
---@param recipe LuaRecipe The recipe
---@param pindex number Player index
---@param is_current boolean? Whether this is the currently selected recipe
function mod.create_recipe_label(message, recipe, pindex, is_current)
   message:fragment(Localising.get_localised_name_with_fallback(recipe))

   if is_current then message:fragment({ "fa.assembling-machine-current-recipe" }) end
end

---Check if an entity can have its recipe changed by the player
---@param entity LuaEntity
---@return boolean
function mod.can_player_set_recipe(entity)
   -- Only assembling machines can have recipes set by players
   -- Furnaces have recipes but they're fixed
   return entity.prototype.type == "assembling-machine"
end

return mod
