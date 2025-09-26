local TreeChooser = require("scripts.ui.tree-chooser")
local KeyGraph = require("scripts.ui.key-graph")
local TabList = require("scripts.ui.tab-list")
local UiRouter = require("scripts.ui.router")
local Localising = require("scripts.localising")

local mod = {}

---@param ctx fa.ui.graph.Ctx
local function build_item_tree(ctx)
   local builder = TreeChooser.TreeChooserBuilder.new()
   local player = game.get_player(ctx.pindex)
   local force = player.force

   local unlocked_items = {}

   for name, item_proto in pairs(prototypes.item) do
      if item_proto.flags and item_proto.flags["always-show"] then unlocked_items[name] = true end
   end

   for name, tech in pairs(force.technologies) do
      if tech.researched then
         local tech_proto = tech.prototype
         for _, effect in ipairs(tech_proto.effects or {}) do
            if effect.type == "unlock-recipe" then
               local recipe = prototypes.recipe[effect.recipe]
               if recipe and recipe.unlock_results ~= false then
                  for _, product in ipairs(recipe.products or {}) do
                     if product.type == "item" then unlocked_items[product.name] = true end
                  end
               end
            end
         end
      end
   end

   for name, recipe in pairs(prototypes.recipe) do
      if recipe.enabled and recipe.unlock_results ~= false then
         for _, product in ipairs(recipe.products or {}) do
            if product.type == "item" then unlocked_items[product.name] = true end
         end
      end
   end

   for name, entity_proto in pairs(prototypes.entity) do
      if entity_proto.resource_category then
         local loot = entity_proto.loot
         if loot then
            for _, loot_item in ipairs(loot) do
               if loot_item.item then unlocked_items[loot_item.item] = true end
            end
         end

         local mineable = entity_proto.mineable_properties
         if mineable and mineable.products then
            for _, product in ipairs(mineable.products) do
               if product.type == "item" then unlocked_items[product.name] = true end
            end
         end
      end
   end

   local items_by_group_and_subgroup = {}

   for item_name, _ in pairs(unlocked_items) do
      local item = prototypes.item[item_name]
      if item then
         local group = item.group
         local subgroup = item.subgroup

         if group and subgroup then
            items_by_group_and_subgroup[group.name] = items_by_group_and_subgroup[group.name] or {}
            items_by_group_and_subgroup[group.name][subgroup.name] = items_by_group_and_subgroup[group.name][subgroup.name]
               or {}
            table.insert(items_by_group_and_subgroup[group.name][subgroup.name], item_name)
         end
      end
   end

   local sorted_groups = {}
   for group_name, _ in pairs(items_by_group_and_subgroup) do
      table.insert(sorted_groups, group_name)
   end
   table.sort(sorted_groups, function(a, b)
      return (prototypes.item_group[a].order or "") < (prototypes.item_group[b].order or "")
   end)

   for _, group_name in ipairs(sorted_groups) do
      local group = prototypes.item_group[group_name]
      local group_key = "cat-" .. group_name

      builder:add_node(group_key, TreeChooser.ROOT, {
         label = function(ctx)
            ctx.message:fragment(Localising.get_localised_name_with_fallback(group))
         end,
      })

      local sorted_subgroups = {}
      for subgroup_name, _ in pairs(items_by_group_and_subgroup[group_name]) do
         table.insert(sorted_subgroups, subgroup_name)
      end
      table.sort(sorted_subgroups, function(a, b)
         return (prototypes.item_subgroup[a].order or "") < (prototypes.item_subgroup[b].order or "")
      end)

      for _, subgroup_name in ipairs(sorted_subgroups) do
         local subgroup = prototypes.item_subgroup[subgroup_name]
         local subgroup_key = "subcat-" .. subgroup_name

         builder:add_node(subgroup_key, group_key, {
            label = function(ctx)
               ctx.message:fragment(Localising.get_localised_name_with_fallback(subgroup))
            end,
         })

         local items = items_by_group_and_subgroup[group_name][subgroup_name]
         table.sort(items, function(a, b)
            local item_a = prototypes.item[a]
            local item_b = prototypes.item[b]
            return (item_a.order or "") < (item_b.order or "")
         end)

         for _, item_name in ipairs(items) do
            local item = prototypes.item[item_name]
            local item_key = "item-" .. item_name

            builder:add_node(item_key, subgroup_key, {
               label = function(ctx)
                  ctx.message:fragment(Localising.get_localised_name_with_fallback(item))
               end,
               on_click = function(click_ctx)
                  click_ctx.controller:close_with_result(item_name)
               end,
            })
         end
      end
   end

   return builder:build()
end

local item_chooser_tab = KeyGraph.declare_graph({
   name = "item_chooser",
   render_callback = build_item_tree,
   title = { "fa.item-chooser-title" },
})

mod.item_chooser_menu = TabList.declare_tablist({
   ui_name = UiRouter.UI_NAMES.ITEM_CHOOSER,
   resets_to_first_tab_on_open = true,
   tabs_callback = function()
      return {
         {
            name = "item_chooser",
            tabs = { item_chooser_tab },
         },
      }
   end,
})

UiRouter.register_ui(mod.item_chooser_menu)

return mod
