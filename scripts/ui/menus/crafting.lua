--[[
Crafting menu UI using the CategoryRows system.

Provides a category-based interface for crafting recipes where:
- Categories are recipe groups (logistics, production, combat, etc.)
- Items are individual recipes
- Left click crafts 1, Shift+click crafts 5, Ctrl+click crafts all
- K reads recipe ingredients
]]

local CategoryRows = require("scripts.ui.category-rows")
local Crafting = require("scripts.crafting")
local Localising = require("scripts.localising")
local Speech = require("scripts.speech")

local mod = {}

---Get the craftable count for a recipe
---@param player LuaPlayer
---@param recipe LuaRecipe
---@return number
local function get_craftable_count(player, recipe)
   return player.get_craftable_count(recipe.name)
end

---Start crafting a recipe
---@param player LuaPlayer
---@param recipe LuaRecipe
---@param count number
---@return number actual_count
local function start_crafting(player, recipe, count)
   local T = {
      count = count,
      recipe = recipe,
      silent = false,
   }
   return player.begin_crafting(T)
end

---Create the label for a recipe item
---@param ctx fa.ui.CategoryRows.ItemContext
---@param recipe LuaRecipe
local function create_recipe_label(ctx, recipe)
   local player = ctx.player
   local craftable = get_craftable_count(player, recipe)

   ctx.message:fragment(Localising.get_recipe_from_name(recipe.name, ctx.pindex))
   ctx.message:fragment({ "fa.crafting-can-craft", craftable })
end

---Handle clicking on a recipe (craft it)
---@param ctx fa.ui.CategoryRows.ItemContext
---@param recipe LuaRecipe
---@param modifiers {control?: boolean, shift?: boolean, alt?: boolean}
local function handle_recipe_click(ctx, recipe, modifiers)
   local player = ctx.player
   local count = 1

   if modifiers.shift then
      count = 5
   elseif modifiers.control then
      count = get_craftable_count(player, recipe)
   end

   if count == 0 then
      ctx.message:fragment({ "fa.crafting-cannot-craft" })
      local missing_info = Crafting.recipe_missing_ingredients_info(ctx.pindex, recipe)
      ctx.message:fragment(missing_info)
      return
   end

   local crafted = start_crafting(player, recipe, count)
   if crafted > 0 then
      local total_count = Crafting.count_in_crafting_queue(recipe.name, ctx.pindex)
      ctx.message:fragment({
         "fa.crafting-started",
         crafted,
         Localising.get_recipe_from_name(recipe.name, ctx.pindex),
         total_count,
      })
   else
      ctx.message:fragment({ "fa.crafting-cannot-craft" })
      local missing_info = Crafting.recipe_missing_ingredients_info(ctx.pindex, recipe)
      ctx.message:fragment(missing_info)
   end
end

---Read recipe ingredients and products
---@param ctx fa.ui.CategoryRows.ItemContext
---@param recipe LuaRecipe
local function read_recipe_info(ctx, recipe)
   -- Read ingredients
   ctx.message:fragment({ "fa.crafting-ingredients" })
   for _, ingredient in ipairs(recipe.ingredients) do
      local proto = prototypes.item[ingredient.name] or prototypes.fluid[ingredient.name]
      if proto then
         ctx.message:list_item(Localising.get_localised_name_with_fallback(proto))
         ctx.message:fragment({ "fa.crafting-amount", ingredient.amount })
      end
   end

   -- Read products
   ctx.message:fragment({ "fa.crafting-products" })
   for _, product in ipairs(recipe.products) do
      local proto = prototypes.item[product.name] or prototypes.fluid[product.name]
      if proto then
         ctx.message:list_item(Localising.get_localised_name_with_fallback(proto))
         if product.amount then
            ctx.message:fragment({ "fa.crafting-amount", product.amount })
         elseif product.amount_min and product.amount_max then
            ctx.message:fragment({ "fa.crafting-amount-range", product.amount_min, product.amount_max })
         end
         if product.probability and product.probability < 1 then
            ctx.message:fragment({ "fa.crafting-probability", product.probability * 100 })
         end
      end
   end
end

---Render the crafting menu
---@param ctx fa.ui.TabContext
---@return fa.ui.CategoryRows.Render?
local function render_crafting_menu(ctx)
   local player = ctx.player
   if not player.character then
      Speech.speak(ctx.pindex, { "fa.crafting-no-character" })
      ctx.force_close = true
      return nil
   end

   -- Get recipes grouped by category
   local recipe_groups = Crafting.get_recipes(ctx.pindex, player.character, true)
   if not recipe_groups or #recipe_groups == 0 then return {
      categories = {},
   } end

   local builder = CategoryRows.CategoryRowsBuilder_new()

   -- Add each recipe group as a category
   for group_index, recipes in ipairs(recipe_groups) do
      if recipes and #recipes > 0 then
         -- Get group name from first recipe
         local group_name = recipes[1].group.name
         local group_label = Localising.get_alt(recipes[1].group, ctx.pindex)

         builder:add_category(group_name, group_label)

         -- Add recipes as items
         for _, recipe in ipairs(recipes) do
            if recipe.valid then
               -- Create vtable for this recipe (avoiding inline closures)
               local vtable = {}

               function vtable.label(item_ctx)
                  create_recipe_label(item_ctx, recipe)
               end

               function vtable.on_click(item_ctx, mods)
                  handle_recipe_click(item_ctx, recipe, mods)
               end

               function vtable.on_read_coords(item_ctx)
                  read_recipe_info(item_ctx, recipe)
               end

               builder:add_item(group_name, recipe.name, vtable)
            end
         end
      end
   end

   return builder:build()
end

-- Create the tab descriptor for the crafting menu
mod.crafting_tab = CategoryRows.declare_category_rows({
   name = "crafting",
   title = { "fa.crafting-title" },
   render_callback = render_crafting_menu,
})

return mod
