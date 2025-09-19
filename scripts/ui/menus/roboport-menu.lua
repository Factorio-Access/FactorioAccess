--[[
Roboport menu UI using the new TabList/Menu system.
Provides a vertical menu interface for managing roboport networks.
]]

local WorkerRobots = require("scripts.worker-robots")
local Localising = require("scripts.localising")
local Menu = require("scripts.ui.menu")
local Speech = require("scripts.speech")
local TabList = require("scripts.ui.tab-list")
local UiKeyGraph = require("scripts.ui.key-graph")
local UiRouter = require("scripts.ui.router")
local UiEventRouting = require("scripts.ui.event-routing")

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

   if port and port.valid and port.name == "roboport" then return {
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
      Speech.speak(ctx.pindex, { "fa.robots-roboport-menu-requires" })
      ctx.controller:close()
      return nil
   end

   local builder = Menu.MenuBuilder.new()
   local nw = port.logistic_network

   -- Menu item 0: Title/Instructions
   builder:add_label("title", function(label_ctx)
      label_ctx.message:fragment({ "fa.roboport-menu-title", WorkerRobots.get_network_name(port) })
      label_ctx.message:fragment({ "fa.roboport-menu-instructions" })
   end)

   -- Menu item 1: Rename network (PLACEHOLDER - textboxes broken)
   builder:add_clickable("rename", { "fa.robots-rename-this-network" }, {
      on_click = function(click_ctx)
         -- PLACEHOLDER: Just speak "not implemented" for now
         -- Keep the actual renaming code commented for when textboxes are fixed

         -- Original code to restore later:
         -- click_ctx.tablist_shared_state.renaming = true
         -- Graphics.create_text_field_frame(click_ctx.pindex, "network-rename")
         -- click_ctx.message:fragment({ "fa.robots-enter-new-network-name" })

         click_ctx.message:fragment({ "fa.not-implemented" })
      end,
   })

   -- Menu item 2: Read roboport neighbours
   builder:add_clickable("neighbours", { "fa.robots-read-roboport-neighbours" }, {
      on_click = function(click_ctx)
         local cell = port.logistic_cell
         local neighbour_count = #cell.neighbours

         if neighbour_count > 0 then
            click_ctx.message:fragment({ "fa.roboport-neighbours-count", neighbour_count })
         else
            click_ctx.message:fragment({ "fa.roboport-no-neighbours" })
         end
      end,
   })

   -- Menu item 3: Read roboport contents
   builder:add_clickable("contents", { "fa.robots-read-roboport-contents" }, {
      on_click = function(click_ctx)
         local cell = port.logistic_cell
         click_ctx.message:fragment({
            "fa.roboport-contents",
            cell.charging_robot_count,
            cell.to_charge_robot_count,
            cell.stationed_logistic_robot_count,
            cell.stationed_construction_robot_count,
            port.get_inventory(defines.inventory.roboport_material).get_item_count(),
         })
      end,
   })

   -- Menu item 4: Network robots info
   builder:add_clickable("robots", { "fa.robots-read-robots-info" }, {
      on_click = function(click_ctx)
         if nw then
            click_ctx.message:fragment({
               "fa.network-robots-info",
               #nw.cells,
               nw.all_logistic_robots,
               nw.available_logistic_robots,
               nw.all_construction_robots,
               nw.available_construction_robots,
            })
         else
            click_ctx.message:fragment({ "fa.robots-error-no-network" })
         end
      end,
   })

   -- Menu item 5: Network chests info
   builder:add_clickable("chests", { "fa.robots-read-chests-info" }, {
      on_click = function(click_ctx)
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

            click_ctx.message:fragment({
               "fa.network-chests-info",
               total_count,
               storage_count,
               passive_provider_count,
               active_provider_count,
               requester_count,
            })
         else
            click_ctx.message:fragment({ "fa.robots-error-no-network" })
         end
      end,
   })

   -- Menu item 6: Network items info (simplified - shows all items at once)
   builder:add_clickable("items", { "fa.robots-read-items-info" }, {
      on_click = function(click_ctx)
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
               click_ctx.message:fragment({ "fa.roboport-network-no-items" })
            else
               click_ctx.message:fragment({ "fa.roboport-network-contains" })
               for _, item in ipairs(itemtable) do
                  -- Use Localising.localise_item for proper item formatting
                  local item_desc = Localising.localise_item({
                     name = item.name,
                     count = item.count,
                  })
                  click_ctx.message:list_item(item_desc)
               end
            end
         else
            click_ctx.message:fragment({ "fa.robots-error-no-network" })
         end
      end,
   })

   return builder:build()
end

-- TabList declaration
mod.roboport_menu = TabList.declare_tablist({
   ui_name = UiRouter.UI_NAMES.ROBOPORT,
   resets_to_first_tab_on_open = true,
   shared_state_setup = state_setup,
   tabs = {
      UiKeyGraph.declare_graph({
         name = "roboport",
         title = { "fa.roboport-menu-main" },
         render_callback = render_roboport_menu,
      }),
   },
})

-- Register with the UI event routing system for event interception
UiEventRouting.register_ui(mod.roboport_menu)

return mod
