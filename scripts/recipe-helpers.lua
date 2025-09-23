--[[
Shared helpers for displaying recipe information.
Used by crafting menu, assembling machine tab, and other recipe-related features.
Takes MessageBuilder directly to avoid UI dependencies.
]]

local Localising = require("scripts.localising")

local mod = {}

---Read recipe ingredients and products
---@param message fa.Speech The message builder to append to
---@param recipe LuaRecipe The recipe to read
function mod.read_recipe_details(message, recipe)
   -- Read ingredients
   message:fragment({ "fa.crafting-ingredients" })
   for _, ingredient in ipairs(recipe.ingredients) do
      -- Use localise_item_or_fluid for proper formatting with count
      local protos = prototypes.item[ingredient.name] and prototypes.item or prototypes.fluid
      local item_str = Localising.localise_item_or_fluid({
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
         local item_str = Localising.localise_item_or_fluid({
            name = product.name,
            count = product.amount,
         }, protos)
         message:list_item(item_str)
      elseif product.amount_min and product.amount_max then
         -- Variable amount - show range separately
         local item_str = Localising.localise_item_or_fluid({
            name = product.name,
         }, protos)
         message:list_item(item_str)
         message:fragment(" x " .. product.amount_min .. "-" .. product.amount_max)
      else
         -- No amount specified
         local item_str = Localising.localise_item_or_fluid({
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

---Read recipe details including crafting time (for machines)
---@param message fa.Speech The message builder to append to
---@param recipe LuaRecipe The recipe to read
function mod.read_recipe_details_with_time(message, recipe)
   mod.read_recipe_details(message, recipe)

   -- Add crafting time
   message:fragment({ "fa.assembling-machine-crafting-time", recipe.energy })
end

---Create a label for a recipe, optionally marking it as current
---@param message fa.Speech The message builder to append to
---@param recipe LuaRecipe The recipe
---@param pindex number Player index
---@param is_current boolean? Whether this is the currently selected recipe
function mod.create_recipe_label(message, recipe, pindex, is_current)
   message:fragment(Localising.get_recipe_from_name(recipe.name, pindex))

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
