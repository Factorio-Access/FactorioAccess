-- Prototype lister UI
-- Lists all prototypes (items, fluids, virtual signals, entities, recipes, etc.)
-- Left click: Speak prototype name without modification
-- Right click: Spell out name with spaces between characters
-- Shift+left click: Copy prototype name to clipboard
-- Shift+right click: Copy rich text shorthand to clipboard (items, fluids, virtual signals only)

local TreeChooser = require("scripts.ui.tree-chooser")
local KeyGraph = require("scripts.ui.key-graph")
local TabList = require("scripts.ui.tab-list")
local UiRouter = require("scripts.ui.router")
local SignalHelpers = require("scripts.ui.signal-helpers")
local Localising = require("scripts.localising")
local LauncherCommands = require("scripts.launcher-commands")
local Speech = require("scripts.speech")
local UiSounds = require("scripts.ui.sounds")

local mod = {}

-- Wildcard signal names that have shorthands
local WILDCARD_SHORTHANDS = {
   ["signal-item-parameter"] = ":*i",
   ["signal-fluid-parameter"] = ":*f",
   ["signal-fuel-parameter"] = ":*fu",
   ["signal-signal-parameter"] = ":*s",
}

-- Signal types that support rich text shorthands
local SHORTHAND_TYPES = {
   item = true,
   fluid = true,
   virtual = true,
}

---Convert a prototype name to spaced-out format for speaking
---@param name string
---@return string
local function name_to_spaced(name)
   local chars = {}
   for char in name:gmatch(".") do
      table.insert(chars, char)
   end
   return table.concat(chars, " ")
end

---Get rich text shorthand for a prototype, or nil if not supported
---@param signal_type string
---@param name string
---@return string? shorthand
local function get_rich_text_shorthand(signal_type, name)
   if signal_type == "item" then
      return ":i." .. name
   elseif signal_type == "fluid" then
      return ":f." .. name
   elseif signal_type == "virtual" then
      if WILDCARD_SHORTHANDS[name] then return WILDCARD_SHORTHANDS[name] end
      return ":s." .. name
   end
   return nil
end

---Build vtable for prototype lister nodes
---@param name string Prototype name
---@param proto any Prototype object
---@param signal_type string Signal type
---@return fa.ui.graph.NodeVtable
local function prototype_lister_vtable_builder(name, proto, signal_type)
   local has_shorthand = SHORTHAND_TYPES[signal_type]

   return {
      label = function(ctx)
         ctx.message:fragment(Localising.get_localised_name_with_fallback(proto))
      end,
      on_click = function(click_ctx)
         local pindex = click_ctx.pindex
         local modifiers = click_ctx.modifiers

         if modifiers.shift then
            LauncherCommands.copy_to_clipboard(pindex, name)
            Speech.speak(pindex, { "fa.prototype-lister-copied", name })
         else
            Speech.speak(pindex, name)
         end
      end,
      on_right_click = function(click_ctx)
         local pindex = click_ctx.pindex
         local modifiers = click_ctx.modifiers

         if modifiers.shift then
            if has_shorthand then
               local shorthand = get_rich_text_shorthand(signal_type, name)
               LauncherCommands.copy_to_clipboard(pindex, shorthand)
               Speech.speak(pindex, { "fa.prototype-lister-copied-shorthand", shorthand })
            else
               UiSounds.play_ui_error(pindex)
               Speech.speak(pindex, { "fa.prototype-lister-no-shorthand" })
            end
         else
            local spaced = name_to_spaced(name)
            Speech.speak(pindex, spaced)
         end
      end,
   }
end

---@param ctx fa.ui.graph.Ctx
local function build_prototype_tree(ctx)
   local builder = TreeChooser.TreeChooserBuilder.new()

   -- Prototype type categories with their signal-helpers add functions
   local proto_types = {
      {
         key = "type-item",
         label = { "fa.signal-type-item" },
         add_func = function()
            SignalHelpers.add_item_signals(builder, "type-item", false, nil, nil, nil, prototype_lister_vtable_builder)
         end,
      },
      {
         key = "type-fluid",
         label = { "fa.signal-type-fluid" },
         add_func = function()
            SignalHelpers.add_fluid_signals(builder, "type-fluid", prototype_lister_vtable_builder)
         end,
      },
      {
         key = "type-virtual",
         label = { "fa.signal-type-virtual" },
         add_func = function()
            SignalHelpers.add_virtual_signals(builder, "type-virtual", prototype_lister_vtable_builder)
         end,
      },
      {
         key = "type-entity",
         label = { "fa.signal-type-entity" },
         add_func = function()
            SignalHelpers.add_entity_signals(builder, "type-entity", prototype_lister_vtable_builder)
         end,
      },
      {
         key = "type-recipe",
         label = { "fa.signal-type-recipe" },
         add_func = function()
            SignalHelpers.add_recipe_signals(builder, "type-recipe", prototype_lister_vtable_builder)
         end,
      },
      {
         key = "type-space-location",
         label = { "fa.signal-type-space-location" },
         feature_flag = "space_travel",
         add_func = function()
            SignalHelpers.add_space_location_signals(builder, "type-space-location", prototype_lister_vtable_builder)
         end,
      },
      {
         key = "type-asteroid-chunk",
         label = { "fa.signal-type-asteroid-chunk" },
         feature_flag = "space_travel",
         add_func = function()
            SignalHelpers.add_asteroid_chunk_signals(builder, "type-asteroid-chunk", prototype_lister_vtable_builder)
         end,
      },
      {
         key = "type-quality",
         label = { "fa.signal-type-quality" },
         feature_flag = "quality",
         add_func = function()
            SignalHelpers.add_quality_signals(builder, "type-quality", prototype_lister_vtable_builder)
         end,
      },
   }

   -- Add top-level prototype type categories
   for _, proto_type in ipairs(proto_types) do
      if proto_type.feature_flag and not script.feature_flags[proto_type.feature_flag] then goto continue end

      builder:add_node(proto_type.key, TreeChooser.ROOT, {
         label = function(label_ctx)
            label_ctx.message:fragment(proto_type.label)
         end,
         exclude_from_search = true,
      })

      proto_type.add_func()

      ::continue::
   end

   return builder:build()
end

local prototype_lister_tab = KeyGraph.declare_graph({
   name = "prototype_lister",
   render_callback = build_prototype_tree,
   title = { "fa.prototype-lister-title" },
})

mod.prototype_lister_menu = TabList.declare_tablist({
   ui_name = UiRouter.UI_NAMES.PROTOTYPE_LISTER,
   resets_to_first_tab_on_open = true,
   tabs_callback = function()
      return {
         {
            name = "prototype_lister",
            tabs = { prototype_lister_tab },
         },
      }
   end,
})

UiRouter.register_ui(mod.prototype_lister_menu)

return mod
