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
local crafting = require("scripts.ui.menus.crafting")
local crafting_queue = require("scripts.ui.menus.crafting-queue")
local research = require("scripts.ui.menus.research")
local research_queue = require("scripts.ui.menus.research-queue")

local mod = {}

---Shared state setup function that combines state from all tabs
---@param pindex number
---@param params any
---@return table
local function setup_shared_state(pindex, params)
   return {}
end

-- Create the unified TabList with sections
mod.main_menu = TabList.declare_tablist({
   ui_name = UiRouter.UI_NAMES.MAIN,
   resets_to_first_tab_on_open = true,
   shared_state_setup = setup_shared_state,
   tabs_callback = Functools.functionize({
      {
         name = "inventories",
         title = { "fa.section-inventories" },
         tabs = {
            inventory.inventory_tab,
            gun_menu.gun_tab,
         },
      },
      {
         name = "crafting",
         title = { "fa.section-crafting" },
         tabs = {
            crafting.crafting_tab,
            crafting_queue.crafting_queue_tab,
         },
      },
      {
         name = "research",
         title = { "fa.section-research" },
         tabs = {
            research.research_tab,
            research_queue.research_queue_tab,
         },
      },
   }),
})

-- Register with the UI event routing system
UiRouter.register_ui(mod.main_menu)

return mod
