--[[
Ghost chooser: what replaces the inventory in remote view, where the player has no items. Lists the items the force
has unlocked that can be built on the player's surface; choosing one puts its ghost in hand (player.cursor_ghost). On
a space platform each item says how many the hub holds, since the hub builds the ghosts from its own inventory.
]]
local KeyGraph = require("scripts.ui.key-graph")
local Localising = require("scripts.localising")
local SignalHelpers = require("scripts.ui.signal-helpers")
local SurfaceConditions = require("scripts.surface-conditions")
local TreeChooser = require("scripts.ui.tree-chooser")

local mod = {}

---Whether the item places something on this surface. Tiles have no surface conditions.
---@param proto LuaItemPrototype
---@param surface LuaSurface
---@return boolean
local function is_buildable(proto, surface)
   local entity = proto.place_result
   if entity then return SurfaceConditions.failed_condition(entity, surface) == nil end
   return proto.place_as_tile_result ~= nil
end

---@param ctx fa.ui.graph.Ctx
---@return fa.ui.graph.Render?
local function render_ghost_chooser(ctx)
   local builder = TreeChooser.TreeChooserBuilder.new()
   local player = game.get_player(ctx.pindex)
   local hub = player.hub
   local hub_inv = hub and hub.get_inventory(defines.inventory.hub_main)

   local surface = player.surface
   local function filter(proto)
      return is_buildable(proto, surface)
   end

   SignalHelpers.add_item_signals(
      builder,
      TreeChooser.ROOT,
      true,
      player.force --[[@as LuaForce]],
      nil,
      filter,
      function(name, proto)
         return {
            label = function(label_ctx)
               local localised_name = Localising.get_localised_name_with_fallback(proto)
               if hub_inv then
                  label_ctx.message:fragment({ "fa.ghost-chooser-in-hub", localised_name, hub_inv.get_item_count(name) })
               else
                  label_ctx.message:fragment(localised_name)
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
