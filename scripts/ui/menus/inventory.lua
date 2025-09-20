--[[
Player inventory tab using the InventoryGrid system.
Provides access to the player's main inventory with standard grid navigation.
]]

local InventoryGrid = require("scripts.ui.inventory-grid")

local mod = {}

-- Create the player inventory tab
mod.inventory_tab = InventoryGrid.create_inventory_grid({
   name = "player_inventory",
   title = { "fa.ui-inventory-player-title" },
   subkey = "player_inventory",
})

-- Add a state setup callback to ensure we have the inventory
mod.inventory_tab.callbacks = mod.inventory_tab.callbacks or {}
mod.inventory_tab.callbacks.state_setup = function(ctx)
   local player = game.get_player(ctx.pindex)
   if not player or not player.character then
      return {
         player_inventory = {
            entity = nil,
            inventory = nil,
         },
      }
   end

   return {
      player_inventory = {
         entity = player.character,
         inventory = player.character.get_inventory(defines.inventory.character_main),
      },
   }
end

return mod
