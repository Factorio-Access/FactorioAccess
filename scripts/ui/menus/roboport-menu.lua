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
   form:add_textfield("rename_roboport", {
      label = { "fa.robots-rename-this-roboport" },
      get_value = function()
         return port.backer_name
      end,
      set_value = function(new_name)
         if new_name and new_name ~= "" then port.backer_name = new_name end
      end,
   })

   -- Menu item 2: Rename network
   form:add_textfield("rename_network", {
      label = { "fa.robots-rename-this-network" },
      get_value = function()
         return WorkerRobots.get_network_name(port)
      end,
      set_value = function(new_name)
         WorkerRobots.set_network_name(port, new_name)
      end,
   })

   -- Menu item 3: Roboport neighbours
   form:add_label("neighbours", function(label_ctx)
      local cell = port.logistic_cell
      local neighbour_count = #cell.neighbours

      if neighbour_count > 0 then
         label_ctx.message:fragment({ "fa.roboport-neighbours-count", neighbour_count })
      else
         label_ctx.message:fragment({ "fa.roboport-no-neighbours" })
      end
   end)

   -- Menu item 4: Network robots info
   form:add_label("robots", function(label_ctx)
      if nw then
         local items = {}

         table.insert(items, { name = "roboport", count = #nw.cells })

         if nw.all_logistic_robots > 0 then
            table.insert(items, { name = "logistic-robot", count = nw.all_logistic_robots })
         end

         if nw.all_construction_robots > 0 then
            table.insert(items, { name = "construction-robot", count = nw.all_construction_robots })
         end

         local mb = label_ctx.message
         mb:fragment({ "fa.network-robots-intro" })
         for _, item in ipairs(items) do
            mb:list_item(Localising.localise_item(item))
         end
      else
         label_ctx.message:fragment({ "fa.robots-error-no-network" })
      end
   end)

   -- Menu item 5: Roboport charging status
   form:add_label("charging", function(label_ctx)
      local cell = port.logistic_cell
      local mb = label_ctx.message

      if cell.charging_robot_count > 0 then
         mb:fragment({ "fa.roboport-charging", cell.charging_robot_count })
      else
         mb:fragment({ "fa.roboport-not-charging" })
      end
   end)

   -- Menu item 6: Roboport queue status
   form:add_label("queue", function(label_ctx)
      local cell = port.logistic_cell
      local mb = label_ctx.message

      if cell.to_charge_robot_count > 0 then
         mb:fragment({ "fa.roboport-queue", cell.to_charge_robot_count })
      else
         mb:fragment({ "fa.roboport-no-queue" })
      end
   end)

   -- Menu item 7: Roboport contents
   form:add_label("contents", function(label_ctx)
      local cell = port.logistic_cell
      local items = {}

      if cell.stationed_logistic_robot_count > 0 then
         table.insert(items, { name = "logistic-robot", count = cell.stationed_logistic_robot_count })
      end

      if cell.stationed_construction_robot_count > 0 then
         table.insert(items, { name = "construction-robot", count = cell.stationed_construction_robot_count })
      end

      local repair_count = port.get_inventory(defines.inventory.roboport_material).get_item_count()
      if repair_count > 0 then table.insert(items, { name = "repair-pack", count = repair_count }) end

      local mb = label_ctx.message
      if #items == 0 then
         mb:fragment({ "fa.roboport-empty" })
      else
         mb:fragment({ "fa.roboport-contents-intro" })
         for _, item in ipairs(items) do
            mb:list_item(Localising.localise_item(item))
         end
      end
   end)

   -- Menu item 8: Network chests info
   form:add_label("chests", function(label_ctx)
      if nw then
         local chest_counts = {}

         for _, point in ipairs(nw.storage_points) do
            if point.owner.type == "logistic-container" then
               local name = point.owner.name
               chest_counts[name] = (chest_counts[name] or 0) + 1
            end
         end

         for _, point in ipairs(nw.passive_provider_points) do
            if point.owner.type == "logistic-container" then
               local name = point.owner.name
               chest_counts[name] = (chest_counts[name] or 0) + 1
            end
         end

         for _, point in ipairs(nw.active_provider_points) do
            if point.owner.type == "logistic-container" then
               local name = point.owner.name
               chest_counts[name] = (chest_counts[name] or 0) + 1
            end
         end

         for _, point in ipairs(nw.requester_points) do
            if point.owner.type == "logistic-container" then
               local name = point.owner.name
               chest_counts[name] = (chest_counts[name] or 0) + 1
            end
         end

         local chest_list = {}
         for name, count in pairs(chest_counts) do
            table.insert(chest_list, { name = name, count = count })
         end

         table.sort(chest_list, function(a, b)
            return a.count > b.count
         end)

         local mb = label_ctx.message
         if #chest_list == 0 then
            mb:fragment({ "fa.network-no-chests" })
         else
            mb:fragment({ "fa.network-chests-intro" })
            for _, chest in ipairs(chest_list) do
               mb:list_item(Localising.localise_item({ name = chest.name, count = chest.count }))
            end
         end
      else
         label_ctx.message:fragment({ "fa.robots-error-no-network" })
      end
   end)

   -- Menu item 9: Network items info
   form:add_label("items", function(label_ctx)
      if nw then
         local items = nw.get_contents()

         if #items == 0 then
            label_ctx.message:fragment({ "fa.roboport-network-no-items" })
         else
            table.sort(items, function(a, b)
               return a.count > b.count
            end)

            label_ctx.message:fragment({ "fa.roboport-network-contains" })
            for _, item in ipairs(items) do
               local item_desc = Localising.localise_item({
                  name = item.name,
                  count = item.count,
                  quality = item.quality,
               })
               label_ctx.message:list_item(item_desc)
            end
         end
      else
         label_ctx.message:fragment({ "fa.robots-error-no-network" })
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
