local TreeChooser = require("scripts.ui.tree-chooser")
local KeyGraph = require("scripts.ui.key-graph")
local TabList = require("scripts.ui.tab-list")
local UiRouter = require("scripts.ui.router")
local SignalHelpers = require("scripts.ui.signal-helpers")

local mod = {}

---@param ctx fa.ui.graph.Ctx
local function build_item_tree(ctx)
   local builder = TreeChooser.TreeChooserBuilder.new()
   local player = game.get_player(ctx.pindex)
   local force = player.force --[[@as LuaForce]]

   -- Use signal helper to add items (with unlocked filter)
   -- Pass converter to return just the name string, not SignalID
   SignalHelpers.add_item_signals(builder, TreeChooser.ROOT, true, force, function(name)
      return name
   end)

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
