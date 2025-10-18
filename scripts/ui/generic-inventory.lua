--[[
A "boring" inventory.

Vehicles and containers have:

- A single main inventory
- Possibly a single trash inventory
- A convenience player-mounted inventory that the player can grab from

Crafting machines etc. are more complicated, but this covers the simpler cases.
]]
local Functools = require("scripts.functools")
local InventoryGrid = require("scripts.ui.inventory-grid")
local TabList = require("scripts.ui.tab-list")
local UiRouter = require("scripts.ui.router")

local mod = {}

---@class fa.ui.GenericInventory.Parameters
---@field entity LuaEntity The target entity
---@field inventory defines.inventory

---@class fa.ui.Inventory.SharedState
---@field entity LuaEntity
---@field inventory LuaInventory

---Setup shared state when opening the UI
---@param pindex number
---@param params fa.ui.GenericInventory.Parameters
---@return fa.ui.Inventory.SharedState?
local function setup_shared_state(pindex, params)
   local entity = params.entity
   if not entity or not entity.valid then return end

   local inventory = entity.get_inventory(params.inventory)
   if not inventory then error("Entity does not have inventory " .. tostring(params.inventory)) end

   local ret = {
      generic_inventory = {
         entity = entity,
         inventory_index = params.inventory,
      },
   }

   local p = game.players[pindex]
   if not p.character or not p.character.valid then return ret end

   ret["player_inventory"] = {
      entity = p.character,
      inventory_index = defines.inventory.character_main,
   }

   -- Add trash inventory for vehicles if vehicle logistics is enabled
   local trash_inv_index = nil
   local show_trash = false

   if entity.type == "car" or entity.type == "spider-vehicle" then
      trash_inv_index = defines.inventory.car_trash
      -- For vehicles: only show if vehicle logistics is enabled
      show_trash = entity.force.vehicle_logistics
   end

   if show_trash and trash_inv_index and entity.get_inventory(trash_inv_index) then
      ret["trash_inventory"] = {
         entity = entity,
         inventory_index = trash_inv_index,
      }
   end

   return ret
end

local GENERIC_GRID = InventoryGrid.create_inventory_grid({
   name = "generic_inventory",
   title = { "fa.ui-inventory-main-title" },
   subkey = "generic_inventory",
})

local PERSONAL_GRID = InventoryGrid.create_inventory_grid({
   name = "player_inventory",
   title = { "fa.ui-inventory-player-title" },
   subkey = "player_inventory",
})
PERSONAL_GRID.callbacks.enabled = function(pindex)
   return game.players[pindex] ~= nil and game.players[pindex].character ~= nil and game.players[pindex].character.valid
end

local TRASH_GRID = InventoryGrid.create_inventory_grid({
   name = "trash_inventory",
   title = { "fa.ui-inventory-trash-title" },
   subkey = "trash_inventory",
})

-- Create the TabList declaration for generic inventories.
mod.generic_inventory = TabList.declare_tablist({
   ui_name = UiRouter.UI_NAMES.GENERIC_INVENTORY,
   resets_to_first_tab_on_open = true,
   shared_state_setup = setup_shared_state,
   tabs_callback = Functools.functionize({
      {
         name = "main",
         tabs = {
            GENERIC_GRID,
            PERSONAL_GRID,
            TRASH_GRID,
         },
      },
   }),
})

-- Register with the UI event routing system
UiRouter.register_ui(mod.generic_inventory)

return mod
