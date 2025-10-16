--Here: Helper functions for building signal choosers with TreeChooser
--Each signal type can be added to a TreeChooser builder, with hierarchy where possible

local TreeChooser = require("scripts.ui.tree-chooser")
local Localising = require("scripts.localising")

local mod = {}

---Helper to add signals with group/subgroup hierarchy
---@param builder fa.ui.tree.TreeChooserBuilder
---@param prototype_dict table Dictionary of prototypes (e.g., prototypes.item)
---@param signal_type string Signal type for SignalID (e.g., "item", "fluid")
---@param key_prefix string Prefix for node keys (e.g., "item", "fluid")
---@param root string Parent key for top-level groups
---@param filter_func? fun(prototype): boolean Optional filter function
---@param result_converter? fun(name: string): any Optional function to convert signal name to result (defaults to SignalID)
local function add_signals_with_hierarchy(
   builder,
   prototype_dict,
   signal_type,
   key_prefix,
   root,
   filter_func,
   result_converter
)
   local signals_by_group_and_subgroup = {}
   local ungrouped_signals = {}

   -- Collect all signals organized by group/subgroup
   for name, proto in pairs(prototype_dict) do
      if not filter_func or filter_func(proto) then
         local group = proto.group
         local subgroup = proto.subgroup

         if group and subgroup then
            signals_by_group_and_subgroup[group.name] = signals_by_group_and_subgroup[group.name] or {}
            signals_by_group_and_subgroup[group.name][subgroup.name] = signals_by_group_and_subgroup[group.name][subgroup.name]
               or {}
            table.insert(signals_by_group_and_subgroup[group.name][subgroup.name], name)
         else
            -- Collect signals without group/subgroup
            table.insert(ungrouped_signals, name)
         end
      end
   end

   -- Sort groups by order
   local sorted_groups = {}
   for group_name, _ in pairs(signals_by_group_and_subgroup) do
      table.insert(sorted_groups, group_name)
   end
   table.sort(sorted_groups, function(a, b)
      return (prototypes.item_group[a].order or "") < (prototypes.item_group[b].order or "")
   end)

   -- Add groups
   for _, group_name in ipairs(sorted_groups) do
      local group = prototypes.item_group[group_name]
      local group_key = key_prefix .. "-cat-" .. group_name

      builder:add_node(group_key, root, {
         label = function(ctx)
            ctx.message:fragment(Localising.get_localised_name_with_fallback(group))
         end,
         exclude_from_search = true,
      })

      -- Sort subgroups by order
      local sorted_subgroups = {}
      for subgroup_name, _ in pairs(signals_by_group_and_subgroup[group_name]) do
         table.insert(sorted_subgroups, subgroup_name)
      end
      table.sort(sorted_subgroups, function(a, b)
         return (prototypes.item_subgroup[a].order or "") < (prototypes.item_subgroup[b].order or "")
      end)

      -- Add subgroups
      for _, subgroup_name in ipairs(sorted_subgroups) do
         local subgroup = prototypes.item_subgroup[subgroup_name]
         local subgroup_key = key_prefix .. "-subcat-" .. subgroup_name

         builder:add_node(subgroup_key, group_key, {
            label = function(ctx)
               ctx.message:fragment(Localising.get_localised_name_with_fallback(subgroup))
            end,
            exclude_from_search = true,
         })

         -- Sort signals by order, then by name
         local signals = signals_by_group_and_subgroup[group_name][subgroup_name]
         table.sort(signals, function(a, b)
            local proto_a = prototype_dict[a]
            local proto_b = prototype_dict[b]
            if proto_a.order ~= proto_b.order then return proto_a.order < proto_b.order end
            return a < b
         end)

         -- Add individual signals
         for _, signal_name in ipairs(signals) do
            local proto = prototype_dict[signal_name]
            local signal_key = key_prefix .. "-signal-" .. signal_name

            builder:add_node(signal_key, subgroup_key, {
               label = function(ctx)
                  ctx.message:fragment(Localising.get_localised_name_with_fallback(proto))
               end,
               on_click = function(click_ctx)
                  local result
                  if result_converter then
                     result = result_converter(signal_name)
                  else
                     -- Default: return SignalID
                     result = {
                        type = signal_type,
                        name = signal_name,
                     }
                  end
                  click_ctx.controller:close_with_result(result)
               end,
            })
         end
      end
   end

   -- Add ungrouped signals if any
   if #ungrouped_signals > 0 then
      local ungrouped_key = key_prefix .. "-ungrouped"

      builder:add_node(ungrouped_key, root, {
         label = function(ctx)
            ctx.message:fragment({ "fa.ungrouped-signals" })
         end,
         exclude_from_search = true,
      })

      -- Sort ungrouped signals by order, then by name
      table.sort(ungrouped_signals, function(a, b)
         local proto_a = prototype_dict[a]
         local proto_b = prototype_dict[b]
         if proto_a.order ~= proto_b.order then return proto_a.order < proto_b.order end
         return a < b
      end)

      -- Add individual ungrouped signals
      for _, signal_name in ipairs(ungrouped_signals) do
         local proto = prototype_dict[signal_name]
         local signal_key = key_prefix .. "-signal-" .. signal_name

         builder:add_node(signal_key, ungrouped_key, {
            label = function(ctx)
               ctx.message:fragment(Localising.get_localised_name_with_fallback(proto))
            end,
            on_click = function(click_ctx)
               local result
               if result_converter then
                  result = result_converter(signal_name)
               else
                  -- Default: return SignalID
                  result = {
                     type = signal_type,
                     name = signal_name,
                  }
               end
               click_ctx.controller:close_with_result(result)
            end,
         })
      end
   end
end

---Add item signals to the tree (with optional unlocked filter)
---@param builder fa.ui.tree.TreeChooserBuilder
---@param root string Parent key for top-level groups (use TreeChooser.ROOT for top-level)
---@param unlocked_only? boolean If true, only show unlocked items (default: false)
---@param force? LuaForce Force to use for unlocked filter (required if unlocked_only is true)
---@param result_converter? fun(name: string): any Optional function to convert item name to result (defaults to SignalID)
function mod.add_item_signals(builder, root, unlocked_only, force, result_converter)
   local unlocked_items = nil

   if unlocked_only then
      assert(force, "Force is required when unlocked_only is true")
      unlocked_items = {}

      -- Always-show items
      for name, item_proto in pairs(prototypes.item) do
         if item_proto.flags and item_proto.flags["always-show"] then unlocked_items[name] = true end
      end

      -- Items from researched technologies
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

      -- Items from enabled recipes
      for name, recipe in pairs(prototypes.recipe) do
         if recipe.enabled and recipe.unlock_results ~= false then
            for _, product in ipairs(recipe.products or {}) do
               if product.type == "item" then unlocked_items[product.name] = true end
            end
         end
      end

      -- Items from resources
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
   end

   local filter = unlocked_only and function(proto)
      return unlocked_items[proto.name]
   end or nil

   add_signals_with_hierarchy(builder, prototypes.item, "item", "item", root, filter, result_converter)
end

---Add fluid signals to the tree
---@param builder fa.ui.tree.TreeChooserBuilder
---@param root string Parent key for top-level groups
function mod.add_fluid_signals(builder, root)
   add_signals_with_hierarchy(builder, prototypes.fluid, "fluid", "fluid", root)
end

---Add virtual signals to the tree
---@param builder fa.ui.tree.TreeChooserBuilder
---@param root string Parent key for top-level groups
function mod.add_virtual_signals(builder, root)
   add_signals_with_hierarchy(builder, prototypes.virtual_signal, "virtual", "virtual", root)
end

---Add entity signals to the tree
---@param builder fa.ui.tree.TreeChooserBuilder
---@param root string Parent key for top-level groups
function mod.add_entity_signals(builder, root)
   add_signals_with_hierarchy(builder, prototypes.entity, "entity", "entity", root)
end

---Add recipe signals to the tree
---@param builder fa.ui.tree.TreeChooserBuilder
---@param root string Parent key for top-level groups
function mod.add_recipe_signals(builder, root)
   add_signals_with_hierarchy(builder, prototypes.recipe, "recipe", "recipe", root)
end

---Add space location signals to the tree
---@param builder fa.ui.tree.TreeChooserBuilder
---@param root string Parent key for top-level groups
function mod.add_space_location_signals(builder, root)
   if not script.feature_flags.space_travel then return end
   add_signals_with_hierarchy(builder, prototypes.space_location, "space-location", "space-location", root)
end

---Add asteroid chunk signals to the tree
---@param builder fa.ui.tree.TreeChooserBuilder
---@param root string Parent key for top-level groups
function mod.add_asteroid_chunk_signals(builder, root)
   if not script.feature_flags.space_travel then return end
   add_signals_with_hierarchy(builder, prototypes.asteroid_chunk, "asteroid-chunk", "asteroid-chunk", root)
end

---Add quality signals to the tree
---@param builder fa.ui.tree.TreeChooserBuilder
---@param root string Parent key for top-level groups
function mod.add_quality_signals(builder, root)
   if not script.feature_flags.quality then return end
   add_signals_with_hierarchy(builder, prototypes.quality, "quality", "quality", root)
end

return mod
