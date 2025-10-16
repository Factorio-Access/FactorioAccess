local TreeChooser = require("scripts.ui.tree-chooser")
local KeyGraph = require("scripts.ui.key-graph")
local TabList = require("scripts.ui.tab-list")
local UiRouter = require("scripts.ui.router")
local SignalHelpers = require("scripts.ui.signal-helpers")
local Localising = require("scripts.localising")
local BotLogistics = require("scripts.worker-robots")

local mod = {}

---@param ctx fa.ui.graph.Ctx
local function build_signal_tree(ctx)
   local builder = TreeChooser.TreeChooserBuilder.new()
   local mode = ctx.global_parameters and ctx.global_parameters.mode

   -- If mode is "item" or "fluid", add signals directly to root without category wrapper
   if mode == "item" then
      SignalHelpers.add_item_signals(builder, TreeChooser.ROOT, false, nil)
      return builder:build()
   elseif mode == "fluid" then
      SignalHelpers.add_fluid_signals(builder, TreeChooser.ROOT)
      return builder:build()
   elseif mode == "roboport-items" then
      -- Build flat list of roboport-compatible items
      local item_names = BotLogistics.get_roboport_compatible_items()

      for _, item_name in ipairs(item_names) do
         local proto = prototypes.item[item_name]
         builder:add_node(item_name, TreeChooser.ROOT, {
            label = function(ctx)
               ctx.message:fragment(Localising.get_localised_name_with_fallback(proto))
            end,
            on_click = function(click_ctx)
               click_ctx.controller:close_with_result({ type = "item", name = item_name })
            end,
         })
      end
      return builder:build()
   end

   -- Default mode: show all signal types with categories
   -- Top-level signal type categories
   local signal_types = {
      {
         key = "type-item",
         label = { "fa.signal-type-item" },
         add_func = function()
            SignalHelpers.add_item_signals(builder, "type-item", false, nil)
         end,
      },
      {
         key = "type-fluid",
         label = { "fa.signal-type-fluid" },
         add_func = function()
            SignalHelpers.add_fluid_signals(builder, "type-fluid")
         end,
      },
      {
         key = "type-virtual",
         label = { "fa.signal-type-virtual" },
         add_func = function()
            SignalHelpers.add_virtual_signals(builder, "type-virtual")
         end,
      },
      {
         key = "type-entity",
         label = { "fa.signal-type-entity" },
         add_func = function()
            SignalHelpers.add_entity_signals(builder, "type-entity")
         end,
      },
      {
         key = "type-recipe",
         label = { "fa.signal-type-recipe" },
         add_func = function()
            SignalHelpers.add_recipe_signals(builder, "type-recipe")
         end,
      },
      {
         key = "type-space-location",
         label = { "fa.signal-type-space-location" },
         feature_flag = "space_travel",
         add_func = function()
            SignalHelpers.add_space_location_signals(builder, "type-space-location")
         end,
      },
      {
         key = "type-asteroid-chunk",
         label = { "fa.signal-type-asteroid-chunk" },
         feature_flag = "space_travel",
         add_func = function()
            SignalHelpers.add_asteroid_chunk_signals(builder, "type-asteroid-chunk")
         end,
      },
      {
         key = "type-quality",
         label = { "fa.signal-type-quality" },
         feature_flag = "quality",
         add_func = function()
            SignalHelpers.add_quality_signals(builder, "type-quality")
         end,
      },
   }

   -- Add top-level signal type categories
   for _, signal_type in ipairs(signal_types) do
      -- Skip if feature flag is not enabled
      if signal_type.feature_flag and not script.feature_flags[signal_type.feature_flag] then goto continue end

      builder:add_node(signal_type.key, TreeChooser.ROOT, {
         label = function(ctx)
            ctx.message:fragment(signal_type.label)
         end,
         exclude_from_search = true,
      })

      -- Add signals of this type
      signal_type.add_func()

      ::continue::
   end

   return builder:build()
end

local signal_chooser_tab = KeyGraph.declare_graph({
   name = "signal_chooser",
   render_callback = build_signal_tree,
   title = { "fa.signal-chooser-title" },
})

mod.signal_chooser_menu = TabList.declare_tablist({
   ui_name = UiRouter.UI_NAMES.SIGNAL_CHOOSER,
   resets_to_first_tab_on_open = true,
   tabs_callback = function()
      return {
         {
            name = "signal_chooser",
            tabs = { signal_chooser_tab },
         },
      }
   end,
})

UiRouter.register_ui(mod.signal_chooser_menu)

return mod
