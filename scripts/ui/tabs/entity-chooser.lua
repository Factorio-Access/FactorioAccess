--[[
Entity chooser for selecting entity prototypes.
Primarily used for turret priority targets.
Supports filtering via predefined filter types.
]]

local TreeChooser = require("scripts.ui.tree-chooser")
local KeyGraph = require("scripts.ui.key-graph")
local TabList = require("scripts.ui.tab-list")
local UiRouter = require("scripts.ui.router")
local Localising = require("scripts.localising")

local mod = {}

-- Predefined filter types
mod.FILTER_TYPES = {
   TURRET_PRIORITY = "turret_priority",
}

-- Entity types that can be turret priority targets
local TURRET_PRIORITY_TYPES = {
   ["unit"] = true,
   ["unit-spawner"] = true,
   ["turret"] = true,
   ["car"] = true,
   ["spider-vehicle"] = true,
   ["spider-unit"] = true,
   ["asteroid"] = true,
   ["segment"] = true,
   ["segmented-unit"] = true,
}

-- Filter functions by type
local FILTERS = {
   [mod.FILTER_TYPES.TURRET_PRIORITY] = function(proto)
      return TURRET_PRIORITY_TYPES[proto.type] or false
   end,
}

---Build the entity tree with optional filtering
---@param ctx fa.ui.graph.Ctx
local function build_entity_tree(ctx)
   local builder = TreeChooser.TreeChooserBuilder.new()

   -- Get filter type from global parameters (passed to open_child_ui)
   local params = ctx.global_parameters or {}
   local filter_type = params.filter_type
   local filter_func = filter_type and FILTERS[filter_type]

   -- Collect entities by group/subgroup
   local entities_by_group = {}
   local ungrouped = {}

   for name, proto in pairs(prototypes.entity) do
      if not filter_func or filter_func(proto) then
         local group = proto.group
         local subgroup = proto.subgroup

         if group and subgroup then
            entities_by_group[group.name] = entities_by_group[group.name] or {}
            entities_by_group[group.name][subgroup.name] = entities_by_group[group.name][subgroup.name] or {}
            table.insert(entities_by_group[group.name][subgroup.name], proto)
         else
            table.insert(ungrouped, proto)
         end
      end
   end

   -- Sort and add groups
   local sorted_groups = {}
   for group_name, _ in pairs(entities_by_group) do
      table.insert(sorted_groups, group_name)
   end
   table.sort(sorted_groups, function(a, b)
      local ga = prototypes.item_group[a]
      local gb = prototypes.item_group[b]
      return (ga and ga.order or "") < (gb and gb.order or "")
   end)

   for _, group_name in ipairs(sorted_groups) do
      local group = prototypes.item_group[group_name]
      local group_key = "entity-cat-" .. group_name

      builder:add_node(group_key, TreeChooser.ROOT, {
         label = function(lctx)
            lctx.message:fragment(Localising.get_localised_name_with_fallback(group))
         end,
         exclude_from_search = true,
      })

      -- Sort subgroups
      local sorted_subgroups = {}
      for subgroup_name, _ in pairs(entities_by_group[group_name]) do
         table.insert(sorted_subgroups, subgroup_name)
      end
      table.sort(sorted_subgroups, function(a, b)
         local sa = prototypes.item_subgroup[a]
         local sb = prototypes.item_subgroup[b]
         return (sa and sa.order or "") < (sb and sb.order or "")
      end)

      for _, subgroup_name in ipairs(sorted_subgroups) do
         local subgroup = prototypes.item_subgroup[subgroup_name]
         local subgroup_key = "entity-subcat-" .. subgroup_name

         builder:add_node(subgroup_key, group_key, {
            label = function(lctx)
               lctx.message:fragment(Localising.get_localised_name_with_fallback(subgroup))
            end,
            exclude_from_search = true,
         })

         -- Sort entities
         local entities = entities_by_group[group_name][subgroup_name]
         table.sort(entities, function(a, b)
            if a.order ~= b.order then return a.order < b.order end
            return a.name < b.name
         end)

         -- Add entities
         for _, proto in ipairs(entities) do
            local entity_key = "entity-" .. proto.name

            builder:add_node(entity_key, subgroup_key, {
               label = function(lctx)
                  lctx.message:fragment(Localising.get_localised_name_with_fallback(proto))
               end,
               on_click = function(click_ctx)
                  click_ctx.controller:close_with_result(proto.name)
               end,
            })
         end
      end
   end

   -- Add ungrouped entities
   if #ungrouped > 0 then
      builder:add_node("entity-ungrouped", TreeChooser.ROOT, {
         label = function(lctx)
            lctx.message:fragment({ "fa.ungrouped-entities" })
         end,
         exclude_from_search = true,
      })

      table.sort(ungrouped, function(a, b)
         if a.order ~= b.order then return a.order < b.order end
         return a.name < b.name
      end)

      for _, proto in ipairs(ungrouped) do
         local entity_key = "entity-" .. proto.name

         builder:add_node(entity_key, "entity-ungrouped", {
            label = function(lctx)
               lctx.message:fragment(Localising.get_localised_name_with_fallback(proto))
            end,
            on_click = function(click_ctx)
               click_ctx.controller:close_with_result(proto.name)
            end,
         })
      end
   end

   return builder:build()
end

local entity_chooser_tab = KeyGraph.declare_graph({
   name = "entity_chooser",
   render_callback = build_entity_tree,
   title = { "fa.entity-chooser-title" },
})

mod.entity_chooser_menu = TabList.declare_tablist({
   ui_name = UiRouter.UI_NAMES.ENTITY_CHOOSER,
   resets_to_first_tab_on_open = true,
   tabs_callback = function()
      return {
         {
            name = "entity_chooser",
            tabs = { entity_chooser_tab },
         },
      }
   end,
})

UiRouter.register_ui(mod.entity_chooser_menu)

return mod
