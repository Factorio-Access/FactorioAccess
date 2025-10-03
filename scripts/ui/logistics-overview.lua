--[[
Reusable logistics overview tab component.

Provides a readonly overview of all logistic points on an entity, showing:
- Point labels with network and group information
- Compiled filters
- Targeted items for pickup/delivery
- Active state, trash settings, and exact mode

This component is designed to be embedded in other UIs (logistics config, roboports, etc.)
]]

local Menu = require("scripts.ui.menu")
local KeyGraph = require("scripts.ui.key-graph")
local LogisticDescriptors = require("scripts.logistic-descriptors")
local WorkerRobots = require("scripts.worker-robots")
local Localising = require("scripts.localising")

local mod = {}

---Check if a logistic mode supports sections (requester or buffer)
---@param mode defines.logistic_mode
---@return boolean
local function supports_sections(mode)
   return mode == defines.logistic_mode.requester or mode == defines.logistic_mode.buffer
end

---Render the overview for a single logistic point
---@param menu_builder any The MenuBuilder instance
---@param point LuaLogisticPoint
---@param entity LuaEntity
---@param point_index number
local function render_point(menu_builder, point, entity, point_index)
   assert(point and point.valid, "render_point: point is nil or invalid")

   -- Get descriptor for this point type
   ---@diagnostic disable-next-line: param-type-mismatch
   local descriptor = LogisticDescriptors.get_descriptor(entity.type, point.logistic_member_index)
   local point_label = descriptor and descriptor.label or { "fa.logistics-point-unknown" }

   -- Get network name
   local network_name_str = WorkerRobots.get_network_name_for_point(point)
   local network_name = network_name_str or { "fa.logistics-no-network" }

   -- Get unique groups
   local groups = WorkerRobots.get_unique_groups_from_point(point)
   local groups_text
   if #groups == 0 then
      groups_text = { "fa.logistics-no-groups" }
   elseif #groups == 1 then
      groups_text = { "fa.logistics-in-group", groups[1] }
   else
      groups_text = { "fa.logistics-in-groups", tostring(#groups) }
   end

   -- Header with summary
   local key_prefix = "point_" .. point_index
   menu_builder:add_label(key_prefix .. "_header", function(ctx)
      ctx.message:list_item()
      ctx.message:fragment(point_label)
      ctx.message:fragment({ "fa.logistics-in-network", network_name })
      ctx.message:fragment(groups_text)
      ctx.message:fragment({ "fa.logistics-section-count", tostring(point.sections_count) })
   end)

   -- Compiled filters (requests)
   menu_builder:add_label(key_prefix .. "_requests", function(ctx)
      if point.filters and #point.filters > 0 then
         ctx.message:list_item({ "fa.logistics-requests" })
         for _, filter in ipairs(point.filters) do
            ctx.message:list_item()
            WorkerRobots.push_compiled_filter_readout(ctx.message, filter)
         end
      else
         ctx.message:list_item({ "fa.logistics-no-requests" })
      end
   end)

   -- Section management row (only for points that support sections)
   if not supports_sections(point.mode) then return end

   menu_builder:start_row(key_prefix .. "_section_management")

   -- Section info label
   menu_builder:add_item(key_prefix .. "_section_info", {
      label = function(ctx)
         local manual_count = 0
         local groups_set = {}
         for _, section in pairs(point.sections) do
            if section.is_manual then
               manual_count = manual_count + 1
               if section.group and section.group ~= "" then groups_set[section.group] = true end
            end
         end

         local groups = {}
         for group, _ in pairs(groups_set) do
            table.insert(groups, group)
         end
         table.sort(groups)

         if manual_count == 0 then
            ctx.message:fragment({ "fa.logistics-no-sections" })
         elseif manual_count == 1 then
            ctx.message:fragment({ "fa.logistics-one-section" })
         else
            ctx.message:fragment({ "fa.logistics-n-sections", tostring(manual_count) })
         end

         if #groups > 0 then
            ctx.message:fragment({ "fa.logistics-sections-in-groups" })
            for _, group in ipairs(groups) do
               ctx.message:fragment(group)
            end
         end
      end,
   })

   -- Add section at start
   menu_builder:add_item(key_prefix .. "_add_start", {
      label = function(ctx)
         ctx.message:fragment({ "fa.logistics-add-section-start" })
      end,
      on_click = function(ctx)
         local new_section = point.add_section("", 1)
         if new_section then
            ctx.controller.message:fragment({ "fa.logistics-section-added" })
         else
            ctx.controller.message:fragment({ "fa.logistics-section-add-failed" })
         end
      end,
   })

   -- Add section at end
   menu_builder:add_item(key_prefix .. "_add_end", {
      label = function(ctx)
         ctx.message:fragment({ "fa.logistics-add-section-end" })
      end,
      on_click = function(ctx)
         local new_section = point.add_section()
         if new_section then
            ctx.controller.message:fragment({ "fa.logistics-section-added-end" })
         else
            ctx.controller.message:fragment({ "fa.logistics-section-add-failed" })
         end
      end,
   })

   menu_builder:end_row()

   -- Targeted items for pickup
   if point.targeted_items_pickup and next(point.targeted_items_pickup) then
      menu_builder:add_label(key_prefix .. "_pickup", function(ctx)
         ctx.message:list_item({ "fa.logistics-targeted-pickup" })
         WorkerRobots.add_formatted_filters(point, ctx.message, "targeted_items_pickup")
      end)
   end

   -- Targeted items for delivery
   if point.targeted_items_deliver and next(point.targeted_items_deliver) then
      menu_builder:add_label(key_prefix .. "_deliver", function(ctx)
         ctx.message:list_item({ "fa.logistics-targeted-deliver" })
         WorkerRobots.add_formatted_filters(point, ctx.message, "targeted_items_deliver")
      end)
   end

   -- Toggles row
   menu_builder:start_row(key_prefix .. "_toggles")

   -- Active toggle
   local allows_active = descriptor and descriptor.allows_active_toggle
   if allows_active then
      menu_builder:add_item(key_prefix .. "_active", {
         label = function(ctx)
            if point.enabled then
               ctx.message:fragment({ "fa.logistics-active-checked" })
            else
               ctx.message:fragment({ "fa.logistics-active-unchecked" })
            end
         end,
         on_click = function(ctx)
            point.enabled = not point.enabled
         end,
      })
   else
      menu_builder:add_item(key_prefix .. "_active", {
         label = function(ctx)
            if point.enabled then
               ctx.message:fragment({ "fa.logistics-enabled-locked" })
            else
               ctx.message:fragment({ "fa.logistics-disabled-locked" })
            end
         end,
      })
   end

   -- Trash unrequested toggle
   menu_builder:add_item(key_prefix .. "_trash", {
      label = function(ctx)
         if point.trash_not_requested then
            ctx.message:fragment({ "fa.logistics-trash-unrequested-on" })
         else
            ctx.message:fragment({ "fa.logistics-trash-unrequested-off" })
         end
      end,
      on_click = function(ctx)
         point.trash_not_requested = not point.trash_not_requested
      end,
   })

   -- Exact mode (readonly label)
   menu_builder:add_item(key_prefix .. "_exact", {
      label = function(ctx)
         if point.exact then
            ctx.message:fragment({ "fa.logistics-is-exact" })
         else
            ctx.message:fragment({ "fa.logistics-is-not-exact" })
         end
      end,
   })

   menu_builder:end_row()
end

---Build the overview menu for a single logistic point
---@param ctx fa.ui.graph.Ctx
---@param point_index number
---@return fa.ui.graph.Render?
local function render_point_overview(ctx, point_index)
   assert(ctx.global_parameters, "render_point_overview: global_parameters is nil")
   local entity = ctx.global_parameters.entity
   assert(entity, "render_point_overview: entity is nil")
   assert(entity.valid, "render_point_overview: entity is not valid")

   -- Get the point from the entity
   local points = WorkerRobots.get_all_logistic_points(entity)
   local point = points[point_index]
   assert(point and point.valid, "render_point_overview: point is nil or invalid")

   local menu = Menu.MenuBuilder.new()
   render_point(menu, point, entity, point_index)
   return menu:build()
end

---Create a logistics point overview tab descriptor
---@param point_index number
---@param point LuaLogisticPoint
---@return fa.ui.TabDescriptor
function mod.create_point_tab(point_index, point)
   -- Get descriptor for tab title
   ---@diagnostic disable-next-line: param-type-mismatch
   local descriptor = LogisticDescriptors.get_descriptor(point.owner.type, point.logistic_member_index)
   local base_title = descriptor and descriptor.label or { "fa.logistics-point-unknown" }

   -- Add "point" suffix to the title
   local title = { "", base_title, " ", { "fa.logistics-point-suffix" } }

   return KeyGraph.declare_graph({
      name = "logistics_point_" .. point_index,
      title = title,
      render_callback = function(ctx)
         return render_point_overview(ctx, point_index)
      end,
   })
end

return mod
