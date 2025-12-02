--[[
Roboport configuration tab.

Provides a configuration form for roboports with:
- Roboport name
- Network name
- Network statistics (robots, chests, items)
- Roboport status (charging, queue, contents)
]]

local FormBuilder = require("scripts.ui.form-builder")
local ItemInfo = require("scripts.item-info")
local UiKeyGraph = require("scripts.ui.key-graph")
local UiSounds = require("scripts.ui.sounds")
local WorkerRobots = require("scripts.worker-robots")

local mod = {}

---@class fa.ui.RoboportTabContext: fa.ui.TabContext
---@field tablist_shared_state fa.ui.EntityUI.SharedState

---Render the roboport configuration form
---@param ctx fa.ui.RoboportTabContext
---@return fa.ui.graph.Render?
local function render_roboport_config(ctx)
   local port = ctx.tablist_shared_state.entity
   if not port or not port.valid then return nil end
   assert(port.type == "roboport", "render: entity is not a roboport")

   local form = FormBuilder.FormBuilder.new()
   local nw = port.logistic_network

   -- Menu item 0: Title/Instructions
   form:add_label("title", function(label_ctx)
      label_ctx.message:fragment({ "fa.roboport-menu-title", WorkerRobots.get_network_name(port) })
      label_ctx.message:fragment({ "fa.roboport-menu-instructions" })
   end)

   -- Menu item 1: Rename roboport
   form:add_item("rename_roboport", {
      label = function(item_ctx)
         local name = port.backer_name or ""
         local value_text = name ~= "" and name or { "fa.empty" }
         item_ctx.message:fragment(value_text)
         item_ctx.message:fragment({ "fa.robots-rename-this-roboport" })
      end,
      on_click = function(item_ctx)
         item_ctx.controller:open_textbox("", "rename_roboport")
      end,
      on_child_result = function(item_ctx, result)
         if not result or result == "" then
            UiSounds.play_ui_edge(item_ctx.pindex)
            item_ctx.controller.message:fragment({ "fa.roboport-name-cannot-be-empty" })
         else
            port.backer_name = result
            item_ctx.controller.message:fragment(result)
         end
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
         label_ctx.message:fragment({
            "fa.network-members-info",
            #nw.cells,
            nw.all_logistic_robots,
            nw.available_logistic_robots,
            nw.all_construction_robots,
            nw.available_construction_robots,
         })
      else
         label_ctx.message:fragment({ "fa.robots-error-no-network" })
      end
   end)

   -- Menu item 5: Roboport charging status with queue
   form:add_label("charging", function(label_ctx)
      local cell = port.logistic_cell

      if cell.charging_robot_count > 0 then
         label_ctx.message:fragment({
            "fa.roboport-charging-with-queue",
            cell.charging_robot_count,
            cell.to_charge_robot_count,
         })
      else
         label_ctx.message:fragment({ "fa.roboport-not-charging" })
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
            mb:list_item(ItemInfo.item_info(item))
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
               mb:list_item(ItemInfo.item_info({ name = chest.name, count = chest.count }))
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
               local item_desc = ItemInfo.item_info({
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

-- Create the tab descriptor
mod.roboport_config_tab = UiKeyGraph.declare_graph({
   name = "roboport-config",
   title = { "fa.roboport-config-title" },
   render_callback = render_roboport_config,
})

return mod
