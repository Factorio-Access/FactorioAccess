--[[
Generic entity UI system
Provides a dynamic UI that adapts to entity capabilities
]]

local Consts = require("scripts.consts")
local Functools = require("scripts.functools")
local InventoryGrid = require("scripts.ui.inventory-grid")
local InventoryUtils = require("scripts.inventory-utils")
local Speech = require("scripts.speech")
local TabList = require("scripts.ui.tab-list")
local UiKeyGraph = require("scripts.ui.key-graph")
local UiRouter = require("scripts.ui.router")
local inventory = require("scripts.ui.menus.inventory")
local gun_menu = require("scripts.ui.menus.gun-menu")
local assembling_machine_tab = require("scripts.ui.tabs.assembling-machine")
local circuit_network_tab = require("scripts.ui.tabs.circuit-network")
local inserter_config_tab = require("scripts.ui.tabs.inserter-config")

local mod = {}

---@class fa.ui.EntityUI.SharedState
---@field entity LuaEntity The entity being viewed
---@field sorted_inventories table[] Sorted list of inventory data
---@field guns_ammo_inventories table[] Gun/ammo inventories to combine

---Get localized title for an inventory
---@param inv_name string The inventory name (key from defines.inventory)
---@return LocalisedString
local function get_inventory_title(inv_name)
   return { "fa.inventory-title-" .. inv_name }
end

---Sort inventories by priority and extract gun/ammo inventories
---@param entity LuaEntity
---@return table[] sorted_inventories, table[] guns_ammo_inventories
local function sort_inventories(entity)
   local all_inventories = {}
   local guns_ammo = {}

   -- Get the maximum inventory index for this entity
   local max_index = entity.get_max_inventory_index()

   if not max_index or max_index == 0 then return {}, {} end

   -- Iterate through all possible inventory indices
   for inv_index = 1, max_index do
      -- Defines are integers, LuaLS doesn't get that.
      ---@diagnostic disable-next-line
      local inv = entity.get_inventory(inv_index)

      -- Inventory can be nil. Docs don't specify that. The inventory list is actually a sparse array.
      -- Also filter out inventories with 0 slots (e.g., module inventory on machines that don't support modules)
      if inv and #inv > 0 then
         local inv_name = inv.name
         if inv_name then
            local priority = Consts.INVENTORY_PRIORITIES[inv_name] or 100

            local inv_data = {
               name = inv_name,
               index = inv_index,
               inventory = inv,
               priority = priority,
            }

            -- Separate gun/ammo inventories by name pattern
            if string.find(inv_name, "_guns") or string.find(inv_name, "_ammo") then
               table.insert(guns_ammo, inv_data)
            else
               table.insert(all_inventories, inv_data)
            end
         end
      end
   end

   -- Sort non-gun inventories by priority, then alphabetically
   table.sort(all_inventories, function(a, b)
      if a.priority == b.priority then return a.name < b.name end
      return a.priority < b.priority
   end)

   return all_inventories, guns_ammo
end

---Build inventory tabs for an entity
---@param entity LuaEntity
---@param sorted_invs table[] Sorted non-gun inventories
---@param guns_ammo_invs table[] Gun/ammo inventories
---@return fa.ui.TabDescriptor[]
local function build_inventory_tabs(entity, sorted_invs, guns_ammo_invs)
   local tabs = {}

   -- Add a tab for each non-gun inventory
   for _, inv_data in ipairs(sorted_invs) do
      local tab = InventoryGrid.create_inventory_grid({
         name = "inv_" .. inv_data.name,
         title = get_inventory_title(inv_data.name),
         entity = entity,
         inventory_index = inv_data.index,
      })

      table.insert(tabs, tab)
   end

   return tabs
end

---Build configuration section based on entity prototype
---@param entity LuaEntity
---@return fa.ui.TabDescriptor[]?
local function build_configuration_tabs(entity)
   local prototype = entity.prototype
   if not prototype then return nil end

   local tabs = {}

   -- Add assembling machine recipe selector
   if prototype.type == "assembling-machine" then table.insert(tabs, assembling_machine_tab.assembling_machine_tab) end

   -- Add inserter configuration
   if prototype.type == "inserter" and inserter_config_tab.is_available(entity) then
      table.insert(tabs, inserter_config_tab.inserter_config_tab)
   end

   -- Future: Add other device-specific tabs here
   -- if prototype.type == "mining-drill" then ...
   -- if prototype.type == "lab" then ...
   -- etc.

   return #tabs > 0 and tabs or nil
end

---Build circuit network section based on control behavior
---@param entity LuaEntity
---@return fa.ui.TabDescriptor[]?
local function build_circuit_network_tabs(entity)
   if not circuit_network_tab.is_available(entity) then return nil end

   return { circuit_network_tab.get_tab() }
end

---Get player inventory section
---@param pindex number
---@return fa.ui.TabstopDescriptor
local function get_player_inventory_section(pindex)
   return {
      name = "player_inventories",
      title = { "fa.section-player-inventories" },
      tabs = {
         inventory.inventory_tab,
         gun_menu.gun_tab,
      },
   }
end

---Build all sections for the entity UI
---@param pindex number
---@param entity LuaEntity
---@return fa.ui.TabstopDescriptor[]?
local function build_entity_sections(pindex, entity)
   if not entity.valid then return nil end

   local sections = {}

   -- Get sorted inventories
   local sorted_invs, guns_ammo = sort_inventories(entity)

   -- Build inventory section
   local inventory_tabs = build_inventory_tabs(entity, sorted_invs, guns_ammo)
   if #inventory_tabs > 0 then
      table.insert(sections, {
         name = "inventories",
         title = { "fa.section-inventories" },
         tabs = inventory_tabs,
      })
   end

   -- Build configuration section
   local config_tabs = build_configuration_tabs(entity)
   if config_tabs then
      table.insert(sections, {
         name = "configuration",
         title = { "fa.section-device-configuration" },
         tabs = config_tabs,
      })
   end

   -- Build circuit network section
   local circuit_tabs = build_circuit_network_tabs(entity)
   if circuit_tabs then
      table.insert(sections, {
         name = "circuit-network",
         title = { "fa.section-circuit-network" },
         tabs = circuit_tabs,
      })
   end

   -- Only add player inventory section if there are entity-specific sections
   if #sections == 0 then return nil end

   -- Add player inventory section for convenience
   table.insert(sections, get_player_inventory_section(pindex))

   return sections
end

---Shared state setup for entity UI
---@param pindex number
---@param params table
---@return table
local function setup_shared_state(pindex, params)
   local entity = params.entity
   if not entity or not entity.valid then
      return {
         entity = nil,
         sorted_inventories = {},
         guns_ammo_inventories = {},
      }
   end

   local sorted_invs, guns_ammo = sort_inventories(entity)

   -- Create shared state with inventory data pre-populated
   local state = {
      entity = entity,
      sorted_inventories = sorted_invs,
      guns_ammo_inventories = guns_ammo,
   }

   -- Also add inventory states for the inventory grids
   for _, inv_data in ipairs(sorted_invs) do
      state["inv_" .. inv_data.name] = {
         entity = entity,
         inventory_index = inv_data.index,
      }
   end

   return state
end

-- Create the entity UI TabList
mod.entity_ui = TabList.declare_tablist({
   ui_name = UiRouter.UI_NAMES.ENTITY,
   resets_to_first_tab_on_open = true,
   shared_state_setup = setup_shared_state,
   tabs_callback = function(pindex, parameters)
      local entity = parameters and parameters.entity
      return build_entity_sections(pindex, entity)
   end,
})

---Open the entity UI for a given entity
---@param pindex number Player index
---@param entity LuaEntity The entity to open UI for
---@return boolean success
function mod.open_entity_ui(pindex, entity)
   local player = game.get_player(pindex)
   if not player then return false end

   -- Validate entity
   if not entity.valid then
      Speech.speak(pindex, { "fa.entity-invalid" })
      return false
   end

   -- Check if player can access the entity
   local can_access = false

   -- Ghosts are always accessible
   if entity.type == "entity-ghost" then
      can_access = true
   -- Check if player can reach the entity
   elseif player.can_reach_entity(entity) then
      can_access = true
   end

   if not can_access then
      Speech.speak(pindex, { "fa.entity-out-of-reach" })
      return false
   end

   ---@type table<any, any>
   local params = {
      entity = entity,
   }

   -- Find appropriate entity inventory for player → entity transfers
   -- Priority: chest > crafter_input > car_trunk > spider_trunk
   local entity_dest_inv_index = nil
   local dest_inv =
      InventoryUtils.get_inventory_by_priority(entity, "chest", "crafter_input", "car_trunk", "spider_trunk")
   if dest_inv then entity_dest_inv_index = dest_inv.index end

   -- Set up player inventory with entity as sibling
   if player.character then
      params.player_inventory = {
         entity = player.character,
         inventory_index = defines.inventory.character_main,
         sibling_entity = entity_dest_inv_index and entity or nil,
         sibling_inventory_id = entity_dest_inv_index,
      }
   end

   -- Set up entity inventories with player as sibling
   for i = 1, entity.get_max_inventory_index() do
      ---@diagnostic disable-next-line
      local inv = entity.get_inventory(i)
      if inv and inv.name then
         params["inv_" .. inv.name] = {
            entity = entity,
            inventory_index = i,
            sibling_entity = player.character,
            sibling_inventory_id = defines.inventory.character_main,
         }
      end
   end

   -- Open the appropriate UI based on entity type
   local router = UiRouter.get_router(pindex)

   -- Special case: constant combinators use their own UI
   if entity.type == "constant-combinator" then
      router:open_ui(UiRouter.UI_NAMES.CONSTANT_COMBINATOR, params)
      return true
   end

   -- Special case: belt-related entities use the belt analyzer
   if
      entity.type == "transport-belt"
      or entity.type == "underground-belt"
      or entity.type == "splitter"
      or entity.type == "loader"
      or entity.type == "loader-1x1"
   then
      router:open_ui(UiRouter.UI_NAMES.BELT, params)
      return true
   end

   -- Default: generic entity UI
   -- Note: Logistic containers open as normal chests to allow inventory access
   -- Logistics config is accessed via explicit keybinding (fa-cas-l)

   -- Check if the entity has any UI sections available
   local sections = build_entity_sections(pindex, entity)
   if not sections or #sections == 0 then
      Speech.speak(pindex, { "fa.entity-no-ui-available" })
      return false
   end

   router:open_ui(UiRouter.UI_NAMES.ENTITY, params)
   return true
end

-- Register with the UI router
UiRouter.register_ui(mod.entity_ui)

return mod
