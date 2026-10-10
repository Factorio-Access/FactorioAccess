--Here: Helper functions for building signal choosers with TreeChooser
--Each signal type can be added to a TreeChooser builder, with hierarchy where possible

local EventManager = require("scripts.event-manager")
local TreeChooser = require("scripts.ui.tree-chooser")
local Localising = require("scripts.localising")

local mod = {}

---@class fa.ui.signal_helpers.SubgroupEntry
---@field name string
---@field signals string[] Sorted prototype names

---@class fa.ui.signal_helpers.GroupEntry
---@field name string
---@field subgroups fa.ui.signal_helpers.SubgroupEntry[]

---@class fa.ui.signal_helpers.Hierarchy
---@field groups fa.ui.signal_helpers.GroupEntry[]
---@field ungrouped string[] Sorted prototype names with no group/subgroup

--[[
Grouping and sorting an entire prototype dictionary is expensive and these choosers re-render on
every keypress.  Prototypes cannot change without a restart and module locals do not survive one,
so the orderings are computed once per dictionary and reused; filters are applied while walking
the cached ordering instead of while building it.
]]
---@type table<string, fa.ui.signal_helpers.Hierarchy?>
local hierarchy_cache = {}

---@param cache_key string Unique name for the dictionary, e.g. the chooser's key prefix.
---@param prototype_dict table
---@return fa.ui.signal_helpers.Hierarchy
local function get_hierarchy(cache_key, prototype_dict)
   local cached = hierarchy_cache[cache_key]
   if cached then return cached end

   local signals_by_group_and_subgroup = {}
   local ungrouped = {}

   for name, proto in pairs(prototype_dict) do
      local group = proto.group
      local subgroup = proto.subgroup

      if group and subgroup then
         local g = signals_by_group_and_subgroup[group.name]
         if not g then
            g = {}
            signals_by_group_and_subgroup[group.name] = g
         end
         local sg = g[subgroup.name]
         if not sg then
            sg = {}
            g[subgroup.name] = sg
         end
         table.insert(sg, name)
      else
         table.insert(ungrouped, name)
      end
   end

   local function order_then_name(a, b)
      local proto_a = prototype_dict[a]
      local proto_b = prototype_dict[b]
      if proto_a.order ~= proto_b.order then return proto_a.order < proto_b.order end
      return a < b
   end

   ---@type fa.ui.signal_helpers.GroupEntry[]
   local groups = {}
   for group_name in pairs(signals_by_group_and_subgroup) do
      table.insert(groups, { name = group_name, subgroups = {} })
   end
   table.sort(groups, function(a, b)
      return (prototypes.item_group[a.name].order or "") < (prototypes.item_group[b.name].order or "")
   end)

   for _, group in ipairs(groups) do
      local subgroup_names = {}
      for subgroup_name in pairs(signals_by_group_and_subgroup[group.name]) do
         table.insert(subgroup_names, subgroup_name)
      end
      table.sort(subgroup_names, function(a, b)
         return (prototypes.item_subgroup[a].order or "") < (prototypes.item_subgroup[b].order or "")
      end)

      for _, subgroup_name in ipairs(subgroup_names) do
         local signals = signals_by_group_and_subgroup[group.name][subgroup_name]
         table.sort(signals, order_then_name)
         table.insert(group.subgroups, { name = subgroup_name, signals = signals })
      end
   end

   table.sort(ungrouped, order_then_name)

   local hierarchy = { groups = groups, ungrouped = ungrouped }
   hierarchy_cache[cache_key] = hierarchy
   return hierarchy
end

---Build default vtable that closes with a SignalID result
---@param name string Prototype name
---@param proto any Prototype object
---@param signal_type string Signal type for SignalID
---@param result_converter? fun(name: string): any Optional result converter
---@return fa.ui.graph.NodeVtable
local function default_vtable_builder(name, proto, signal_type, result_converter)
   return {
      label = function(ctx)
         ctx.message:fragment(Localising.get_localised_name_with_fallback(proto))
      end,
      on_click = function(click_ctx)
         local result
         if result_converter then
            result = result_converter(name)
         else
            result = {
               type = signal_type,
               name = name,
            }
         end
         click_ctx.controller:close_with_result(result)
      end,
   }
end

---Helper to add signals with group/subgroup hierarchy
---@param builder fa.ui.tree.TreeChooserBuilder
---@param prototype_dict table Dictionary of prototypes (e.g., prototypes.item)
---@param signal_type string Signal type for SignalID (e.g., "item", "fluid")
---@param key_prefix string Prefix for node keys (e.g., "item", "fluid")
---@param root string Parent key for top-level groups
---@param filter_func? fun(prototype): boolean Optional filter function
---@param result_converter? fun(name: string): any Optional function to convert signal name to result (defaults to SignalID)
---@param vtable_builder? fun(name: string, proto: any, signal_type: string): fa.ui.graph.NodeVtable Optional custom vtable builder
local function add_signals_with_hierarchy(
   builder,
   prototype_dict,
   signal_type,
   key_prefix,
   root,
   filter_func,
   result_converter,
   vtable_builder
)
   local hierarchy = get_hierarchy(key_prefix, prototype_dict)

   -- Apply the filter to an already-sorted list of names.
   ---@param names string[]
   ---@return string[]
   local function filtered(names)
      if not filter_func then return names end
      local result = {}
      for _, name in ipairs(names) do
         if filter_func(prototype_dict[name]) then table.insert(result, name) end
      end
      return result
   end

   local function add_signal_node(signal_name, parent_key)
      local proto = prototype_dict[signal_name]
      local signal_key = key_prefix .. "-signal-" .. signal_name

      local vtable
      if vtable_builder then
         vtable = vtable_builder(signal_name, proto, signal_type)
      else
         vtable = default_vtable_builder(signal_name, proto, signal_type, result_converter)
      end
      builder:add_node(signal_key, parent_key, vtable)
   end

   for _, group in ipairs(hierarchy.groups) do
      -- Filter each subgroup first; groups where nothing survives get no node at all.
      ---@type fa.ui.signal_helpers.SubgroupEntry[]
      local surviving = {}
      for _, subgroup in ipairs(group.subgroups) do
         local names = filtered(subgroup.signals)
         if #names > 0 then table.insert(surviving, { name = subgroup.name, signals = names }) end
      end

      if #surviving > 0 then
         local group_proto = prototypes.item_group[group.name]
         local group_key = key_prefix .. "-cat-" .. group.name

         builder:add_node(group_key, root, {
            label = function(ctx)
               ctx.message:fragment(Localising.get_localised_name_with_fallback(group_proto))
            end,
            exclude_from_search = true,
         })

         for _, subgroup in ipairs(surviving) do
            local subgroup_proto = prototypes.item_subgroup[subgroup.name]
            local subgroup_key = key_prefix .. "-subcat-" .. subgroup.name

            builder:add_node(subgroup_key, group_key, {
               label = function(ctx)
                  ctx.message:fragment(Localising.get_localised_name_with_fallback(subgroup_proto))
               end,
               exclude_from_search = true,
            })

            for _, signal_name in ipairs(subgroup.signals) do
               add_signal_node(signal_name, subgroup_key)
            end
         end
      end
   end

   local ungrouped_signals = filtered(hierarchy.ungrouped)
   if #ungrouped_signals > 0 then
      local ungrouped_key = key_prefix .. "-ungrouped"

      builder:add_node(ungrouped_key, root, {
         label = function(ctx)
            ctx.message:fragment({ "fa.ungrouped-signals" })
         end,
         exclude_from_search = true,
      })

      for _, signal_name in ipairs(ungrouped_signals) do
         add_signal_node(signal_name, ungrouped_key)
      end
   end
end

--[[
Cache of which item names count as unlocked, per force index.  Computing this walks every
technology, recipe, and entity prototype, which is far too much for a per-keypress render.
Unlocks are driven by research, so the cache is dropped on research events.  A recipe enabled
directly by script without research will not show up until the next research event; that is rare
enough to accept.
]]
---@type table<integer, table<string, boolean>?>
local unlocked_items_cache = {}

-- The world slots for these events belong to the research announcements; EventManager permits one
-- handler per slot per event, so this rides in the ui slot and returns nil to let them run.
EventManager.on_event({ defines.events.on_research_finished, defines.events.on_research_reversed }, function()
   unlocked_items_cache = {}
   return nil
end, EventManager.EVENT_KIND.UI)

---@param force LuaForce
---@return table<string, boolean>
local function get_unlocked_items(force)
   local cached = unlocked_items_cache[force.index]
   if cached then return cached end

   local unlocked_items = {}

   -- Always-show items
   for name, item_proto in pairs(prototypes.item) do
      if item_proto.has_flag("always-show") then unlocked_items[name] = true end
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
            -- Loot is always items
            for _, loot_item in ipairs(loot) do
               unlocked_items[loot_item.name] = true
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

   unlocked_items_cache[force.index] = unlocked_items
   return unlocked_items
end

---Add item signals to the tree (with optional unlocked filter)
---@param builder fa.ui.tree.TreeChooserBuilder
---@param root string Parent key for top-level groups (use TreeChooser.ROOT for top-level)
---@param unlocked_only? boolean If true, only show unlocked items (default: false)
---@param force? LuaForce Force to use for unlocked filter (required if unlocked_only is true)
---@param result_converter? fun(name: string): any Optional function to convert item name to result (defaults to SignalID)
---@param extra_filter? fun(proto: LuaItemPrototype): boolean Optional additional filter function
---@param vtable_builder? fun(name: string, proto: any, signal_type: string): fa.ui.graph.NodeVtable Optional custom vtable builder
function mod.add_item_signals(builder, root, unlocked_only, force, result_converter, extra_filter, vtable_builder)
   local unlocked_items = nil

   if unlocked_only then
      assert(force, "Force is required when unlocked_only is true")
      unlocked_items = get_unlocked_items(force)
   end

   local filter
   if unlocked_only and extra_filter then
      filter = function(proto)
         return unlocked_items[proto.name] and extra_filter(proto)
      end
   elseif unlocked_only then
      filter = function(proto)
         return unlocked_items[proto.name]
      end
   elseif extra_filter then
      filter = extra_filter
   end

   add_signals_with_hierarchy(builder, prototypes.item, "item", "item", root, filter, result_converter, vtable_builder)
end

---Add fluid signals to the tree
---@param builder fa.ui.tree.TreeChooserBuilder
---@param root string Parent key for top-level groups
---@param vtable_builder? fun(name: string, proto: any, signal_type: string): fa.ui.graph.NodeVtable Optional custom vtable builder
function mod.add_fluid_signals(builder, root, vtable_builder)
   add_signals_with_hierarchy(builder, prototypes.fluid, "fluid", "fluid", root, nil, nil, vtable_builder)
end

---Add virtual signals to the tree
---@param builder fa.ui.tree.TreeChooserBuilder
---@param root string Parent key for top-level groups
---@param vtable_builder? fun(name: string, proto: any, signal_type: string): fa.ui.graph.NodeVtable Optional custom vtable builder
function mod.add_virtual_signals(builder, root, vtable_builder)
   add_signals_with_hierarchy(builder, prototypes.virtual_signal, "virtual", "virtual", root, nil, nil, vtable_builder)
end

---Add entity signals to the tree
---@param builder fa.ui.tree.TreeChooserBuilder
---@param root string Parent key for top-level groups
---@param vtable_builder? fun(name: string, proto: any, signal_type: string): fa.ui.graph.NodeVtable Optional custom vtable builder
function mod.add_entity_signals(builder, root, vtable_builder)
   add_signals_with_hierarchy(builder, prototypes.entity, "entity", "entity", root, nil, nil, vtable_builder)
end

---Add recipe signals to the tree
---@param builder fa.ui.tree.TreeChooserBuilder
---@param root string Parent key for top-level groups
---@param vtable_builder? fun(name: string, proto: any, signal_type: string): fa.ui.graph.NodeVtable Optional custom vtable builder
function mod.add_recipe_signals(builder, root, vtable_builder)
   add_signals_with_hierarchy(builder, prototypes.recipe, "recipe", "recipe", root, nil, nil, vtable_builder)
end

---Add space location signals to the tree
---@param builder fa.ui.tree.TreeChooserBuilder
---@param root string Parent key for top-level groups
---@param vtable_builder? fun(name: string, proto: any, signal_type: string): fa.ui.graph.NodeVtable Optional custom vtable builder
function mod.add_space_location_signals(builder, root, vtable_builder)
   if not script.feature_flags.space_travel then return end
   add_signals_with_hierarchy(
      builder,
      prototypes.space_location,
      "space-location",
      "space-location",
      root,
      nil,
      nil,
      vtable_builder
   )
end

---Add asteroid chunk signals to the tree
---@param builder fa.ui.tree.TreeChooserBuilder
---@param root string Parent key for top-level groups
---@param vtable_builder? fun(name: string, proto: any, signal_type: string): fa.ui.graph.NodeVtable Optional custom vtable builder
function mod.add_asteroid_chunk_signals(builder, root, vtable_builder)
   if not script.feature_flags.space_travel then return end
   add_signals_with_hierarchy(
      builder,
      prototypes.asteroid_chunk,
      "asteroid-chunk",
      "asteroid-chunk",
      root,
      nil,
      nil,
      vtable_builder
   )
end

---Add quality signals to the tree
---@param builder fa.ui.tree.TreeChooserBuilder
---@param root string Parent key for top-level groups
---@param vtable_builder? fun(name: string, proto: any, signal_type: string): fa.ui.graph.NodeVtable Optional custom vtable builder
function mod.add_quality_signals(builder, root, vtable_builder)
   if not script.feature_flags.quality then return end
   add_signals_with_hierarchy(builder, prototypes.quality, "quality", "quality", root, nil, nil, vtable_builder)
end

return mod
