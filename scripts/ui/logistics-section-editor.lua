--[[
Reusable logistics section editor component.

Provides editing capabilities for a single logistic section:
- Configure requests (item, min, max)
- Delete requests
- Manage section group membership
- Add/remove sections

This component is designed to be embedded in the main logistics UI.
]]

local Menu = require("scripts.ui.menu")
local KeyGraph = require("scripts.ui.key-graph")
local Router = require("scripts.ui.router")
local Speech = require("scripts.speech")
local UiSounds = require("scripts.ui.sounds")
local Localising = require("scripts.localising")

local mod = {}

---Get a specific section by index
---@param entity LuaEntity
---@param point_index number
---@param section_index number
---@return LuaLogisticSection?
local function get_section(entity, point_index, section_index)
   assert(entity and entity.valid, "get_section: entity is nil or invalid")

   local points_result = entity.get_logistic_point()
   assert(points_result, "get_section: no logistic points found")

   local points
   if type(points_result) == "table" and points_result.object_name ~= "LuaLogisticPoint" then
      points = points_result
   else
      points = { points_result }
   end

   local point = points[point_index]
   if not point then return nil end

   return point.get_section(section_index)
end

---Build the section editor menu
---@param ctx fa.ui.graph.Ctx
---@param point_index number
---@param section_index number
---@return fa.ui.graph.Render?
local function render_section(ctx, point_index, section_index)
   assert(ctx.global_parameters, "render_section: global_parameters is nil")
   local entity = ctx.global_parameters.entity

   assert(entity and entity.valid, "render_section: entity is nil or invalid")
   assert(point_index, "render_section: point_index is nil")
   assert(section_index, "render_section: section_index is nil")

   local section = get_section(entity, point_index, section_index)
   assert(section, "render_section: section not found")

   local menu = Menu.MenuBuilder.new()

   -- Add rows for each existing request
   for i = 1, section.filters_count do
      local slot = section.get_slot(i)
      if slot and slot.value then
         local row_key = "request_" .. i
         menu:start_row(row_key)

         -- Item 1: Overview + item selector
         menu:add_item(row_key .. "_overview", {
            label = function(ctx)
               local item_name = slot.value.name
               local min_val = slot.min or 0
               local max_val = slot.max

               ctx.message:fragment(Localising.get_localised_name_with_fallback(prototypes.item[item_name]))
               ctx.message:fragment(tostring(min_val))
               ctx.message:fragment("to")
               if max_val then
                  ctx.message:fragment(tostring(max_val))
               else
                  ctx.message:fragment({ "fa.infinity" })
               end
            end,
            on_click = function(ctx)
               ctx.controller:open_child_ui(
                  Router.UI_NAMES.ITEM_CHOOSER,
                  {},
                  { node = row_key .. "_overview", slot_index = i }
               )
            end,
            on_child_result = function(ctx, result)
               if result then
                  local section = get_section(entity, point_index, section_index)
                  if not section then return end

                  local slot = section.get_slot(i)
                  slot.value = result
                  section.set_slot(i, slot)

                  ctx.controller.message:fragment(Localising.get_localised_name_with_fallback(prototypes.item[result]))
               end
            end,
         })

         -- Item 2: Min value
         menu:add_item(row_key .. "_min", {
            label = function(ctx)
               ctx.message:fragment({ "fa.logistics-min" })
               ctx.message:fragment(tostring(slot.min or 0))
            end,
            on_click = function(ctx)
               ctx.controller:open_textbox(
                  tostring(slot.min or 0),
                  { node = row_key .. "_min", slot_index = i },
                  { "fa.logistics-enter-min" }
               )
            end,
            on_child_result = function(ctx, result)
               local num = tonumber(result)
               if num and num >= 0 then
                  local section = get_section(entity, point_index, section_index)
                  if not section then return end

                  local slot = section.get_slot(i)
                  slot.min = math.floor(num)
                  section.set_slot(i, slot)

                  ctx.controller.message:fragment(tostring(math.floor(num)))
               else
                  UiSounds.play_ui_edge(ctx.pindex)
                  ctx.controller.message:fragment({ "fa.logistics-invalid-number" })
               end
            end,
            on_clear = function(ctx)
               local section = get_section(entity, point_index, section_index)
               if not section then return end

               local slot = section.get_slot(i)
               slot.min = 0
               section.set_slot(i, slot)

               ctx.controller.message:fragment("0")
            end,
         })

         -- Item 3: Max value
         menu:add_item(row_key .. "_max", {
            label = function(ctx)
               ctx.message:fragment({ "fa.logistics-max" })
               if slot.max then
                  ctx.message:fragment(tostring(slot.max))
               else
                  ctx.message:fragment({ "fa.infinity" })
               end
            end,
            on_click = function(ctx)
               local current_val = slot.max and tostring(slot.max) or ""
               ctx.controller:open_textbox(
                  current_val,
                  { node = row_key .. "_max", slot_index = i },
                  { "fa.logistics-enter-max" }
               )
            end,
            on_child_result = function(ctx, result)
               if result == "" then
                  -- Empty means infinity
                  local section = get_section(entity, point_index, section_index)
                  if not section then return end

                  local slot = section.get_slot(i)
                  slot.max = nil
                  section.set_slot(i, slot)

                  ctx.controller.message:fragment({ "fa.infinity" })
               else
                  local num = tonumber(result)
                  if num and num >= 0 then
                     local section = get_section(entity, point_index, section_index)
                     if not section then return end

                     local slot = section.get_slot(i)
                     slot.max = math.floor(num)
                     section.set_slot(i, slot)

                     ctx.controller.message:fragment(tostring(math.floor(num)))
                  else
                     UiSounds.play_ui_edge(ctx.pindex)
                     ctx.controller.message:fragment({ "fa.logistics-invalid-number" })
                  end
               end
            end,
            on_clear = function(ctx)
               local section = get_section(entity, point_index, section_index)
               if not section then return end

               local slot = section.get_slot(i)
               slot.max = nil
               section.set_slot(i, slot)

               ctx.controller.message:fragment({ "fa.infinity" })
            end,
         })

         -- Item 4: Delete button
         menu:add_item(row_key .. "_delete", {
            label = function(ctx)
               ctx.message:fragment({ "fa.logistics-delete" })
            end,
            on_click = function(ctx)
               local section = get_section(entity, point_index, section_index)
               if not section then return end

               section.clear_slot(i)

               UiSounds.play_menu_move(ctx.pindex)
               ctx.controller.message:fragment({ "fa.logistics-deleted" })
            end,
         })

         menu:end_row()
      end
   end

   -- Add "Add request" button
   menu:add_item("add_request", {
      label = function(ctx)
         ctx.message:fragment({ "fa.logistics-add-request" })
      end,
      on_click = function(ctx)
         ctx.controller:open_child_ui(Router.UI_NAMES.ITEM_CHOOSER, {}, { node = "add_request" })
      end,
      on_child_result = function(ctx, result)
         if result then
            local section = get_section(entity, point_index, section_index)
            if not section then return end

            local new_index = section.filters_count + 1
            section.set_slot(new_index, {
               value = result,
               min = 0,
               max = nil,
            })

            ctx.controller.message:fragment({
               "fa.logistics-request-added",
               Localising.get_localised_name_with_fallback(prototypes.item[result]),
            })
         end
      end,
   })

   -- Bottom row: section management controls
   menu:start_row("section_controls")

   -- Group selector
   menu:add_item("group_selector", {
      label = function(ctx)
         local section = get_section(entity, point_index, section_index)
         if not section then
            ctx.message:fragment({ "fa.logistics-no-group" })
            return
         end

         if section.group == "" then
            ctx.message:fragment({ "fa.logistics-no-group" })
         else
            ctx.message:fragment({ "fa.logistics-in-group", section.group })
         end
         ctx.message:fragment({ "fa.logistics-group-hint" })
      end,
      on_click = function(ctx)
         ctx.controller:open_child_ui(Router.UI_NAMES.LOGISTIC_GROUP_SELECTOR, {}, { node = "group_selector" })
      end,
      on_child_result = function(ctx, result)
         if result ~= nil then
            local section = get_section(entity, point_index, section_index)
            if not section then return end

            section.group = result
            if result == "" then
               ctx.controller.message:fragment({ "fa.logistics-group-cleared" })
            else
               ctx.controller.message:fragment({ "fa.logistics-group-set", result })
            end
         end
      end,
      on_clear = function(ctx)
         local section = get_section(entity, point_index, section_index)
         if not section then return end

         section.group = ""
         ctx.controller.message:fragment({ "fa.logistics-group-cleared" })
      end,
   })

   -- Delete this section
   menu:add_item("delete_section", {
      label = function(ctx)
         ctx.message:fragment({ "fa.logistics-delete-section" })
      end,
      on_click = function(ctx)
         -- Get the point to delete from
         local points_result = entity.get_logistic_point()
         if not points_result then return end

         local points
         if type(points_result) == "table" and points_result.object_name ~= "LuaLogisticPoint" then
            points = points_result
         else
            points = { points_result }
         end

         local point = points[point_index]
         if not point then return end

         if point.remove_section(section_index) then
            UiSounds.play_menu_move(ctx.pindex)
            ctx.controller.message:fragment({ "fa.logistics-section-deleted" })
            -- Force UI rebuild by closing and reopening would be ideal,
            -- but for now just announce it
         else
            UiSounds.play_ui_edge(ctx.pindex)
            ctx.controller.message:fragment({ "fa.logistics-section-delete-failed" })
         end
      end,
   })

   -- Add new section after this one
   menu:add_item("add_section_after", {
      label = function(ctx)
         ctx.message:fragment({ "fa.logistics-add-section-after" })
      end,
      on_click = function(ctx)
         local points_result = entity.get_logistic_point()
         if not points_result then return end

         local points
         if type(points_result) == "table" and points_result.object_name ~= "LuaLogisticPoint" then
            points = points_result
         else
            points = { points_result }
         end

         local point = points[point_index]
         if not point then return end

         local new_section = point.add_section()
         if new_section then
            UiSounds.play_menu_move(ctx.pindex)
            ctx.controller.message:fragment({ "fa.logistics-section-added" })
         else
            UiSounds.play_ui_edge(ctx.pindex)
            ctx.controller.message:fragment({ "fa.logistics-section-add-failed" })
         end
      end,
   })

   -- Add new section to end
   menu:add_item("add_section_end", {
      label = function(ctx)
         ctx.message:fragment({ "fa.logistics-add-section-end" })
      end,
      on_click = function(ctx)
         local points_result = entity.get_logistic_point()
         if not points_result then return end

         local points
         if type(points_result) == "table" and points_result.object_name ~= "LuaLogisticPoint" then
            points = points_result
         else
            points = { points_result }
         end

         local point = points[point_index]
         if not point then return end

         local new_section = point.add_section()
         if new_section then
            UiSounds.play_menu_move(ctx.pindex)
            ctx.controller.message:fragment({ "fa.logistics-section-added-end" })
         else
            UiSounds.play_ui_edge(ctx.pindex)
            ctx.controller.message:fragment({ "fa.logistics-section-add-failed" })
         end
      end,
   })

   menu:end_row()

   return menu:build()
end

---Create a section editor tab for a specific point and section
---@param point_index number
---@param section_index number
---@param title? LocalisedString Optional title override
---@return fa.ui.TabDescriptor
function mod.create_section_tab(point_index, section_index, title)
   return KeyGraph.declare_graph({
      name = "section_" .. point_index .. "_" .. section_index,
      title = title or { "fa.logistics-section-title", tostring(section_index) },
      render_callback = function(ctx)
         return render_section(ctx, point_index, section_index)
      end,
   })
end

---Create a placeholder "no sections" tab
---@return fa.ui.TabDescriptor
function mod.create_no_sections_tab()
   return KeyGraph.declare_graph({
      name = "no_sections",
      title = { "fa.logistics-no-sections" },
      render_callback = function(ctx)
         local menu = Menu.MenuBuilder.new()
         menu:add_label("no_sections_msg", function(ctx)
            ctx.message:fragment({ "fa.logistics-no-sections-message" })
         end)
         return menu:build()
      end,
   })
end

return mod
