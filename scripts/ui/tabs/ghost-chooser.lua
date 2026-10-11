--[[
Ghost chooser: what replaces the inventory in remote view, where the player has no items. Lists the buildable items
the force has unlocked; choosing one puts its ghost in hand (player.cursor_ghost). On a space platform each item
says how many the hub holds, since the hub builds the ghosts from its own inventory.
]]
local KeyGraph = require("scripts.ui.key-graph")
local Localising = require("scripts.localising")
local SignalHelpers = require("scripts.ui.signal-helpers")
local TreeChooser = require("scripts.ui.tree-chooser")

local mod = {}

---@param proto LuaItemPrototype
---@return boolean
local function is_buildable(proto)
   return proto.place_result ~= nil or proto.place_as_tile_result ~= nil
end

---@param ctx fa.ui.graph.Ctx
---@return fa.ui.graph.Render?
local function render_ghost_chooser(ctx)
   local builder = TreeChooser.TreeChooserBuilder.new()
   local player = game.get_player(ctx.pindex)
   local hub = player.hub
   local hub_inv = hub and hub.get_inventory(defines.inventory.hub_main)

   SignalHelpers.add_item_signals(
      builder,
      TreeChooser.ROOT,
      true,
      player.force --[[@as LuaForce]],
      nil,
      is_buildable,
      function(name, proto)
         return {
            label = function(label_ctx)
               label_ctx.message:fragment(Localising.get_localised_name_with_fallback(proto))
               if hub_inv then
                  label_ctx.message:list_item({ "fa.ghost-chooser-in-hub", hub_inv.get_item_count(name) })
               end
            end,
            on_click = function(click_ctx)
               -- Changing the cursor announces the ghost in hand
               game.get_player(click_ctx.pindex).cursor_ghost = name
               click_ctx.controller:close()
            end,
         }
      end
   )

   return builder:build()
end

mod.ghost_chooser_tab = KeyGraph.declare_graph({
   name = "ghost_chooser",
   render_callback = render_ghost_chooser,
   title = { "fa.ghost-chooser-title" },
})

return mod
