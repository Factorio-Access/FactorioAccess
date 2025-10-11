--[[
Fluid chooser - simplified chooser that only shows fluids
]]

local TreeChooser = require("scripts.ui.tree-chooser")
local KeyGraph = require("scripts.ui.key-graph")
local TabList = require("scripts.ui.tab-list")
local UiRouter = require("scripts.ui.router")
local SignalHelpers = require("scripts.ui.signal-helpers")

local mod = {}

---@param ctx fa.ui.graph.Ctx
local function build_fluid_tree(ctx)
   local builder = TreeChooser.TreeChooserBuilder.new()

   -- Just add fluids directly at the root level
   SignalHelpers.add_fluid_signals(builder, TreeChooser.ROOT)

   return builder:build()
end

local fluid_chooser_tab = KeyGraph.declare_graph({
   name = "fluid_chooser",
   render_callback = build_fluid_tree,
   title = { "fa.fluid-chooser-title" },
})

mod.fluid_chooser_menu = TabList.declare_tablist({
   ui_name = UiRouter.UI_NAMES.FLUID_CHOOSER,
   resets_to_first_tab_on_open = true,
   tabs_callback = function()
      return {
         {
            name = "fluid_chooser",
            tabs = { fluid_chooser_tab },
         },
      }
   end,
})

UiRouter.register_ui(mod.fluid_chooser_menu)

return mod
