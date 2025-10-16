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
})

return mod
