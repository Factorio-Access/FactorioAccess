--[[
Unified logistics overview tab.

Shows entity-level logistics capabilities collapsed from all logistic points.
Designed for blind accessibility - presents logistics from the player's perspective,
not the internal point-based API structure.
]]

local Menu = require("scripts.ui.menu")
local KeyGraph = require("scripts.ui.key-graph")
local Router = require("scripts.ui.router")
local LogisticDescriptors = require("scripts.logistic-descriptors")
local WorkerRobots = require("scripts.worker-robots")
local Localising = require("scripts.localising")
local CircuitNetwork = require("scripts.circuit-network")

local mod = {}

---Check if a logistic mode supports sections (requester or buffer)
---@param mode defines.logistic_mode
---@return boolean
local function supports_sections(mode)
   return mode == defines.logistic_mode.requester or mode == defines.logistic_mode.buffer
end

---Check if entity is a requester chest (prototype type, not buffer)
---@param entity LuaEntity
---@return boolean
local function is_requester_chest(entity)
   if entity.type ~= "logistic-container" then return false end
   return entity.prototype.logistic_mode == "requester"
end

---Check if entity is a storage chest (prototype type)
---@param entity LuaEntity
---@return boolean
local function is_storage_chest(entity)
   if entity.type ~= "logistic-container" then return false end
   return entity.prototype.logistic_mode == "storage"
end

---Render unified logistics overview
---@param ctx fa.ui.graph.Ctx
---@return fa.ui.graph.Render?
local function render_unified_overview(ctx)
   assert(ctx.global_parameters, "render_unified_overview: global_parameters is nil")
   local entity = ctx.global_parameters.entity
   assert(entity, "render_unified_overview: entity is nil")
   assert(entity.valid, "render_unified_overview: entity is not valid")

   -- Get all logistic points
   local points = WorkerRobots.get_all_logistic_points(entity)
   if #points == 0 then
      ctx.controller.message:fragment({ "fa.entity-no-logistics" })
      ctx.controller:close()
      return nil
   end

   local menu = Menu.MenuBuilder.new()

   -- Analyze entity capabilities across all points
   local has_requester = false
   local has_provider = false
   local requester_points = {}
   local is_character = entity.type == "character"

   for _, point in ipairs(points) do
      local mode = point.mode
      if mode == defines.logistic_mode.requester or mode == defines.logistic_mode.buffer then
         has_requester = true
         table.insert(requester_points, point)
      elseif
         mode == defines.logistic_mode.active_provider
         or mode == defines.logistic_mode.passive_provider
         or mode == defines.logistic_mode.storage
      then
         has_provider = true
      end
   end

   -- Header: Entity and network
   menu:add_label("header", function(label_ctx)
      label_ctx.message:list_item()
      label_ctx.message:fragment({ "entity-name." .. entity.name })

      -- Network info (from first point with a network)
      for _, point in ipairs(points) do
         if point.logistic_network then
            local network_name = WorkerRobots.get_network_name_for_point(point)
            if network_name then
               label_ctx.message:fragment({ "fa.logistics-in-network", network_name })
               break
            end
         end
      end
   end)

   -- Show compiled requests from all requester points
   if has_requester then
      menu:add_label("requests", function(label_ctx)
         label_ctx.message:list_item({ "fa.logistics-requests" })

         local has_any_requests = false
         for _, point in ipairs(requester_points) do
            if point.filters and #point.filters > 0 then
               has_any_requests = true
               for _, filter in ipairs(point.filters) do
                  label_ctx.message:list_item()
                  WorkerRobots.push_compiled_filter_readout(label_ctx.message, filter)
               end
            end
         end

         if not has_any_requests then label_ctx.message:list_item({ "fa.logistics-no-requests" }) end
      end)
   end

   -- Entity-level toggles row
   if is_character or is_requester_chest(entity) or has_requester then
      menu:start_row("toggles")

      -- Active toggle (characters only)
      if is_character and #requester_points > 0 then
         local point = requester_points[1]
         menu:add_item("active_toggle", {
            label = function(ctx)
               if point.enabled then
                  ctx.message:fragment({ "fa.logistics-active" })
               else
                  ctx.message:fragment({ "fa.logistics-inactive" })
               end
            end,
            on_click = function(ctx)
               point.enabled = not point.enabled
               if point.enabled then
                  ctx.controller.message:fragment({ "fa.logistics-active" })
               else
                  ctx.controller.message:fragment({ "fa.logistics-inactive" })
               end
            end,
         })
      end

      -- Request from buffers (requester chests only)
      if is_requester_chest(entity) then
         menu:add_item("request_from_buffers", {
            label = function(ctx)
               if entity.request_from_buffers then
                  ctx.message:fragment({ "fa.logistics-request-from-buffers-on" })
               else
                  ctx.message:fragment({ "fa.logistics-request-from-buffers-off" })
               end
            end,
            on_click = function(ctx)
               entity.request_from_buffers = not entity.request_from_buffers
               if entity.request_from_buffers then
                  ctx.controller.message:fragment({ "fa.on" })
               else
                  ctx.controller.message:fragment({ "fa.off" })
               end
            end,
         })
      end

      -- Trash unrequested (any requester point)
      if has_requester and #requester_points > 0 then
         local point = requester_points[1]
         menu:add_item("trash_unrequested", {
            label = function(ctx)
               if point.trash_not_requested then
                  ctx.message:fragment({ "fa.logistics-trash-unrequested-on" })
               else
                  ctx.message:fragment({ "fa.logistics-trash-unrequested-off" })
               end
            end,
            on_click = function(ctx)
               point.trash_not_requested = not point.trash_not_requested
               if point.trash_not_requested then
                  ctx.controller.message:fragment({ "fa.on" })
               else
                  ctx.controller.message:fragment({ "fa.off" })
               end
            end,
         })
      end

      menu:end_row()
   end

   -- Section management (for entities that support sections)
   local sections_obj = entity.get_logistic_sections()
   local has_sections = false

   -- Try entity-level sections first
   if sections_obj then
      has_sections = true
   else
      -- Check if any requester points support sections
      for _, point in ipairs(requester_points) do
         if supports_sections(point.mode) then
            has_sections = true
            sections_obj = {
               add_section = function(...)
                  return point.add_section(...)
               end,
            }
            break
         end
      end
   end

   if has_sections and sections_obj then
      menu:start_row("section_management")

      -- Section info
      menu:add_item("section_info", {
         label = function(ctx)
            local sections_for_count = entity.get_logistic_sections()
            if not sections_for_count then
               -- Use point sections
               for _, point in ipairs(requester_points) do
                  if supports_sections(point.mode) then
                     sections_for_count = point
                     break
                  end
               end
            end

            local manual_count = 0
            if sections_for_count then
               for _, section in pairs(sections_for_count.sections) do
                  if section.is_manual then manual_count = manual_count + 1 end
               end
            end

            if manual_count == 0 then
               ctx.message:fragment({ "fa.logistics-no-sections" })
            elseif manual_count == 1 then
               ctx.message:fragment({ "fa.logistics-one-section" })
            else
               ctx.message:fragment({ "fa.logistics-n-sections", tostring(manual_count) })
            end
         end,
      })

      -- Add section at end
      menu:add_item("add_section_end", {
         label = function(ctx)
            ctx.message:fragment({ "fa.logistics-add-section-end" })
         end,
         on_click = function(ctx)
            local new_section = sections_obj.add_section()
            if new_section then
               ctx.controller.message:fragment({ "fa.logistics-section-added-end" })
            else
               ctx.controller.message:fragment({ "fa.logistics-section-add-failed" })
            end
         end,
      })

      menu:end_row()
   end

   -- Storage chest filter button
   if is_storage_chest(entity) then
      menu:add_item("storage_filter", {
         label = function(ctx)
            local filter = entity.storage_filter
            if filter then
               ctx.message:fragment({ "fa.logistics-storage-filter" })
               ctx.message:fragment(Localising.get_localised_name_with_fallback(filter))
            else
               ctx.message:fragment({ "fa.logistics-no-storage-filter" })
            end
         end,
         on_click = function(ctx)
            ctx.controller:open_child_ui(Router.UI_NAMES.SIGNAL_CHOOSER, { mode = "item" }, { node = "storage_filter" })
         end,
         on_child_result = function(ctx, result)
            if result and result.name then
               entity.storage_filter = prototypes.item[result.name]
               ctx.controller.message:fragment({
                  "fa.logistics-storage-filter-set",
                  Localising.get_localised_name_with_fallback(prototypes.item[result.name]),
               })
            end
         end,
         on_clear = function(ctx)
            entity.storage_filter = nil
            ctx.controller.message:fragment({ "fa.logistics-storage-filter-cleared" })
         end,
      })
   end

   return menu:build()
end

---Create unified logistics overview tab descriptor
---@return fa.ui.TabDescriptor
function mod.create_unified_tab()
   return KeyGraph.declare_graph({
      name = "logistics_overview",
      title = { "fa.logistics-overview" },
      render_callback = render_unified_overview,
   })
end

return mod
