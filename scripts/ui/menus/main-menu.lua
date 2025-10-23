--[[
Main unified menu that combines inventory, guns, crafting, and research tabs.
This is the primary player interface accessed with the E key.
]]

local Functools = require("scripts.functools")
local TabList = require("scripts.ui.tab-list")
local UiRouter = require("scripts.ui.router")

-- Import all the individual tabs
local inventory = require("scripts.ui.menus.inventory")
local gun_menu = require("scripts.ui.menus.gun-menu")
local equipment_overview = require("scripts.ui.tabs.equipment-overview")
local equipment_grid = require("scripts.ui.tabs.equipment-grid")
local crafting = require("scripts.ui.menus.crafting")
local crafting_queue = require("scripts.ui.menus.crafting-queue")
local research = require("scripts.ui.menus.research")
local research_queue = require("scripts.ui.menus.research-queue")
local InventoryGrid = require("scripts.ui.inventory-grid")

local mod = {}

-- Create the trash inventory tab
local TRASH_GRID = InventoryGrid.create_inventory_grid({
   name = "player_trash",
   title = { "fa.ui-inventory-trash-title" },
})

---Shared state setup function that combines state from all tabs
---@param pindex number
---@param params any
---@return table
local function setup_shared_state(pindex, params)
   return {}
end

---Build tabs for the inventories section
---@param pindex number
---@param params table
---@return fa.ui.TabDescriptor[]
local function build_inventory_tabs(pindex, params)
   local tabs = {
      inventory.inventory_tab,
   }

   -- Add trash tab if it's in the parameters
   if params.player_trash then table.insert(tabs, TRASH_GRID) end

   return tabs
end

-- Create the unified TabList with sections
mod.main_menu = TabList.declare_tablist({
   ui_name = UiRouter.UI_NAMES.MAIN,
   resets_to_first_tab_on_open = true,
   shared_state_setup = setup_shared_state,
   tabs_callback = function(pindex, params)
      local sections = {
         {
            name = "inventories",
            title = { "fa.section-inventories" },
            tabs = build_inventory_tabs(pindex, params),
         },
      }

      -- Add crafting section
      table.insert(sections, {
         name = "crafting",
         title = { "fa.section-crafting" },
         tabs = {
            crafting.crafting_tab,
            crafting_queue.crafting_queue_tab,
         },
      })

      -- Add research section
      table.insert(sections, {
         name = "research",
         title = { "fa.section-research" },
         tabs = {
            research.research_tab,
            research_queue.research_tab,
         },
      })

      -- Equipment section - always visible, last
      local player = game.get_player(pindex)
      local equipment_tabs = {
         equipment_overview.equipment_overview_tab,
      }
      -- Add grid tab if available
      if player and player.character and equipment_grid.is_available(player.character) then
         table.insert(equipment_tabs, equipment_grid.equipment_grid_tab)
      end
      -- Add guns tab if available
      if gun_menu.needs_gun_menu_tab(pindex) then table.insert(equipment_tabs, gun_menu.gun_tab) end

      table.insert(sections, {
         name = "equipment",
         title = { "fa.section-equipment" },
         tabs = equipment_tabs,
      })

      return sections
   end,
})

---Open the main menu for a player
---@param pindex number Player index
---@return boolean success
function mod.open_main_menu(pindex)
   local player = game.get_player(pindex)
   if not player or not player.character then return false end

   local params = {
      player_inventory = {
         entity = player.character,
         inventory_index = defines.inventory.character_main,
      },
   }

   -- Add trash inventory if personal logistics is enabled
   if player.force.character_logistic_requests then
      params.player_trash = {
         entity = player.character,
         inventory_index = defines.inventory.character_trash,
      }
   end

   local router = UiRouter.get_router(pindex)
   router:open_ui(UiRouter.UI_NAMES.MAIN, params)
   return true
end

-- Register with the UI event routing system
UiRouter.register_ui(mod.main_menu)

return mod
