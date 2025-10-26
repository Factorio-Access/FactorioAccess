--[[
Assembling machine recipe selection tab using CategoryRows.

Provides recipe selection interface for assembling machines where:
- Categories are recipe groups
- Items are individual recipes
- Current recipe is marked and focused
- Click sets the recipe on the machine
]]

local CategoryRows = require("scripts.ui.category-rows")
local Crafting = require("scripts.crafting")
local ItemInfo = require("scripts.item-info")
local Localising = require("scripts.localising")
local RecipeHelpers = require("scripts.recipe-helpers")
local Speech = require("scripts.speech")

local mod = {}

---Handle clicking on a recipe (set it on the machine)
---@param ctx fa.ui.CategoryRows.ItemContext
---@param recipe LuaRecipe
---@param entity LuaEntity
local function handle_recipe_click(ctx, recipe, entity)
   local player = game.get_player(ctx.pindex)

   -- Set the recipe (let it crash if there's an issue - the UI guarantees validity)
   local removed_items = entity.set_recipe(recipe.name)

   -- Announce the change
   ctx.message:fragment({
      "fa.assembling-machine-recipe-set",
      Localising.get_localised_name_with_fallback(recipe),
   })

   -- If items were removed, announce them
   if removed_items and next(removed_items) then
      ctx.message:fragment({ "fa.assembling-machine-items-removed" })
      for _, item in ipairs(removed_items) do
         if item.count > 0 then
            local item_str = ItemInfo.item_info({
               name = item.name,
               count = item.count,
            })
            ctx.message:list_item(item_str)
         end
      end
   end
end

---Render the assembling machine recipe selection
---@param ctx fa.ui.TabContext
---@return fa.ui.CategoryRows.Render?
local function render_assembling_machine_recipes(ctx)
   local entity = ctx.parameters.entity
   if not entity.valid then return nil end

   -- Check if this is an assembling machine (players can set recipes on these)
   -- Furnaces also support recipes via API but players can't change them
   if not RecipeHelpers.can_player_set_recipe(entity) then
      ctx.controller.message:fragment({ "fa.assembling-machine-cannot-set-recipe" })

      return nil
   end

   -- Get current recipe
   local current_recipe = entity.get_recipe()
   local current_recipe_name = current_recipe and current_recipe.name or nil

   -- Get recipes for this machine's categories
   local recipe_groups = Crafting.get_recipes(ctx.pindex, entity, false)
   if not recipe_groups or #recipe_groups == 0 then return {
      categories = {},
   } end

   local builder = CategoryRows.CategoryRowsBuilder_new()

   -- Track where the current recipe is for focus
   local focus_category_key = nil
   local focus_item_key = nil

   -- Add each recipe group as a category
   for group_index, recipes in ipairs(recipe_groups) do
      if recipes and #recipes > 0 then
         -- Get group name from first recipe
         local group_name = recipes[1].group.name
         local group_label = Localising.get_localised_name_with_fallback(recipes[1].group)

         builder:add_category(group_name, group_label)

         -- Add recipes as items
         for _, recipe in ipairs(recipes) do
            if recipe.valid then
               local is_current = (recipe.name == current_recipe_name)

               -- Track focus position
               if is_current then
                  focus_category_key = group_name
                  focus_item_key = recipe.name
               end

               -- Create vtable for this recipe (captures needed for closure)
               local recipe_ref = recipe
               local is_current_ref = is_current
               local entity_ref = entity

               builder:add_item(group_name, recipe.name, {
                  label = function(item_ctx)
                     RecipeHelpers.create_recipe_label(item_ctx.message, recipe_ref, ctx.pindex, is_current_ref)
                  end,
                  on_click = function(item_ctx, mods)
                     handle_recipe_click(item_ctx, recipe_ref, entity_ref)
                  end,
                  on_read_coords = function(item_ctx)
                     RecipeHelpers.read_recipe_details_with_time(item_ctx.message, recipe_ref)
                  end,
               })
            end
         end
      end
   end

   -- Set focus to current recipe if found
   if focus_category_key and focus_item_key then builder:set_focus(focus_category_key, focus_item_key) end

   return builder:build()
end

-- Create the tab descriptor for assembling machine recipes
mod.assembling_machine_tab = CategoryRows.declare_category_rows({
   name = "assembling-machine-recipes",
   title = { "fa.assembling-machine-recipes-title" },
   render_callback = render_assembling_machine_recipes,
})

return mod
