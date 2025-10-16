--[[
Roboport menu UI using the new TabList/Menu system.
Provides a vertical menu interface for managing roboport networks.
]]

local Functools = require("scripts.functools")
local WorkerRobots = require("scripts.worker-robots")
local Localising = require("scripts.localising")
local FormBuilder = require("scripts.ui.form-builder")
local Speech = require("scripts.speech")
local TabList = require("scripts.ui.tab-list")
local UiKeyGraph = require("scripts.ui.key-graph")
local UiRouter = require("scripts.ui.router")

local mod = {}

---@class fa.ui.RoboportMenu.SharedState
---@field port LuaEntity? The roboport being examined

---@class fa.ui.RoboportMenu.Parameters
-- Empty for now but available for extensions

---@class fa.ui.RoboportMenu.Context: fa.ui.graph.Ctx
---@field parameters fa.ui.RoboportMenu.Parameters
---@field tablist_shared_state fa.ui.RoboportMenu.SharedState

-- Shared state setup function
---@param pindex number
---@param params fa.ui.RoboportMenu.Parameters
---@return fa.ui.RoboportMenu.SharedState
local function state_setup(pindex, params)
   local player = game.get_player(pindex)
   local port = player.opened or player.selected

   if port and port.valid and port.type == "roboport" then return {
      port = port,
   } end

   return {
      port = nil,
   }
end

-- Main render function
---@param ctx fa.ui.RoboportMenu.Context
---@return fa.ui.graph.Render?
local function render_roboport_menu(ctx)
   local port = ctx.tablist_shared_state.port
   if not port or not port.valid then
      ctx.controller.message:fragment({ "fa.robots-roboport-menu-requires" })
      ctx.controller:close()
      return nil
   end

   local form = FormBuilder.FormBuilder.new()
   local nw = port.logistic_network

   -- Menu item 0: Title/Instructions
   form:add_label("title", function(label_ctx)
      label_ctx.message:fragment({ "fa.roboport-menu-title", WorkerRobots.get_network_name(port) })
      label_ctx.message:fragment({ "fa.roboport-menu-instructions" })
   end)

   -- Menu item 1: Rename roboport
   form:add_textfield("rename_roboport", { "fa.robots-rename-this-roboport" }, function()
      return port.backer_name
   end, function(new_name)
      if new_name and new_name ~= "" then port.backer_name = new_name end
   end)

   -- Menu item 2: Rename network
   form:add_textfield("rename_network", { "fa.robots-rename-this-network" }, function()
      return WorkerRobots.get_network_name(port)
   end, function(new_name)
      WorkerRobots.set_network_name(port, new_name)
   end)

   -- Menu item 3: Read roboport neighbours
   form:add_action("neighbours", { "fa.robots-read-roboport-neighbours" }, function(controller)
      local cell = port.logistic_cell
      local neighbour_count = #cell.neighbours

      if neighbour_count > 0 then
         controller.message:fragment({ "fa.roboport-neighbours-count", neighbour_count })
      else
         controller.message:fragment({ "fa.roboport-no-neighbours" })
      end
   end)

   -- Menu item 4: Read roboport contents
   form:add_action("contents", { "fa.robots-read-roboport-contents" }, function(controller)
      local cell = port.logistic_cell
      controller.message:fragment({
         "fa.roboport-contents",
         cell.charging_robot_count,
         cell.to_charge_robot_count,
         cell.stationed_logistic_robot_count,
         cell.stationed_construction_robot_count,
         port.get_inventory(defines.inventory.roboport_material).get_item_count(),
      })
   end)

   -- Menu item 5: Network robots info
   form:add_action("robots", { "fa.robots-read-robots-info" }, function(controller)
      if nw then
         controller.message:fragment({
            "fa.network-robots-info",
            #nw.cells,
            nw.all_logistic_robots,
            nw.available_logistic_robots,
            nw.all_construction_robots,
            nw.available_construction_robots,
         })
      else
         controller.message:fragment({ "fa.robots-error-no-network" })
      end
   end)

   -- Menu item 6: Network chests info
   form:add_action("chests", { "fa.robots-read-chests-info" }, function(controller)
      if nw then
         local storage_count = 0
         for _, point in ipairs(nw.storage_points) do
            if point.owner.type == "logistic-container" then storage_count = storage_count + 1 end
         end

         local passive_provider_count = 0
         for _, point in ipairs(nw.passive_provider_points) do
            if point.owner.type == "logistic-container" then passive_provider_count = passive_provider_count + 1 end
         end

         local active_provider_count = 0
         for _, point in ipairs(nw.active_provider_points) do
            if point.owner.type == "logistic-container" then active_provider_count = active_provider_count + 1 end
         end

         local requester_count = 0
         for _, point in ipairs(nw.requester_points) do
            if point.owner.type == "logistic-container" then requester_count = requester_count + 1 end
         end

         local total_count = storage_count + passive_provider_count + active_provider_count + requester_count

         controller.message:fragment({
            "fa.network-chests-info",
            total_count,
            storage_count,
            passive_provider_count,
            active_provider_count,
            requester_count,
         })
      else
         controller.message:fragment({ "fa.robots-error-no-network" })
      end
   end)

   -- Menu item 7: Network items info (simplified - shows all items at once)
   form:add_action("items", { "fa.robots-read-items-info" }, function(controller)
      if nw then
         local itemset = nw.get_contents()
         local itemtable = {}

         for name, count in pairs(itemset) do
            table.insert(itemtable, { name = name, count = count })
         end

         table.sort(itemtable, function(k1, k2)
            return k1.count > k2.count
         end)

         if #itemtable == 0 then
            controller.message:fragment({ "fa.roboport-network-no-items" })
         else
            controller.message:fragment({ "fa.roboport-network-contains" })
            for _, item in ipairs(itemtable) do
               local item_desc = Localising.localise_item({
                  name = item.name,
                  count = item.count,
               })
               controller.message:list_item(item_desc)
            end
         end
      else
         controller.message:fragment({ "fa.robots-error-no-network" })
      end
   end)

   return form:build()
end

-- TabList declaration
mod.roboport_menu = TabList.declare_tablist({
   ui_name = UiRouter.UI_NAMES.ROBOPORT,
   resets_to_first_tab_on_open = true,
   shared_state_setup = state_setup,
   tabs_callback = Functools.functionize({
      {
         name = "main",
         tabs = {
            UiKeyGraph.declare_graph({
               name = "roboport",
               title = { "fa.roboport-menu-main" },
               render_callback = render_roboport_menu,
            }),
         },
      },
   }),
})

-- Register with the UI event routing system for event interception
UiRouter.register_ui(mod.roboport_menu)

return mod
