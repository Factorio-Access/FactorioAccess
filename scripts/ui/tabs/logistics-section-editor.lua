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
local CircuitNetwork = require("scripts.circuit-network")
local LogisticSectionProvider = require("scripts.logistic-section-provider")
local FaInfo = require("scripts.fa-info")

local mod = {}

---Build the unified section editor menu
---Works for both logistic points and constant combinators via provider
---@param ctx fa.ui.graph.Ctx
---@param point_index number? Only required for logistic points
---@param section_index number
---@return fa.ui.graph.Render?
local function render_section(ctx, point_index, section_index)
   assert(ctx.global_parameters, "render_section: global_parameters is nil")
   local entity = ctx.global_parameters.entity
   assert(entity and entity.valid, "render_section: entity is nil or invalid")
   assert(section_index, "render_section: section_index is nil")

   -- Create provider based on entity type
   local provider = LogisticSectionProvider.create_provider(entity, point_index)
   assert(provider, "render_section: failed to create provider")

   local section = provider.get_section(section_index)
   assert(section, "render_section: section not found")

   local menu = Menu.MenuBuilder.new()

   -- Detect if this is a constant combinator to determine signal mode
   local is_combinator = entity.type == "constant-combinator"
   local signal_mode = is_combinator and "all" or "item"

   -- Add rows for each existing filter/request
   for i = 1, section.filters_count do
      local slot = section.get_slot(i)
      if slot and slot.value then
         local row_key = "filter_" .. i
         menu:start_row(row_key)

         -- Item 1: Overview + signal selector
         menu:add_item(row_key .. "_overview", {
            label = function(ctx)
               local min_val = slot.min or 0
               local max_val = slot.max

               -- Localize the signal (works for both items and other signal types)
               ---@cast slot.value SignalID
               ctx.message:fragment(CircuitNetwork.localise_signal(slot.value))
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
                  Router.UI_NAMES.SIGNAL_CHOOSER,
                  { mode = signal_mode },
                  { node = row_key .. "_overview", slot_index = i }
               )
            end,
            on_child_result = function(ctx, result)
               if result then
                  local section = provider.get_section(section_index)
                  if not section then return end

                  local slot = section.get_slot(i)
                  result.quality = result.quality or "normal"
                  slot.value = result
                  section.set_slot(i, slot)

                  ctx.controller.message:fragment(CircuitNetwork.localise_signal(result))
               end
            end,
            on_production_stats_announcement = function(ctx)
               if slot.value and slot.value.name then
                  local stats_message = FaInfo.selected_item_production_stats_info(ctx.pindex, slot.value.name)
                  ctx.message:fragment(stats_message)
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
               if not num then
                  UiSounds.play_ui_edge(ctx.pindex)
                  ctx.controller.message:fragment({ "fa.logistics-invalid-number" })
               elseif not is_combinator and num < 0 then
                  UiSounds.play_ui_edge(ctx.pindex)
                  ctx.controller.message:fragment({ "fa.logistics-value-cannot-be-negative" })
               else
                  local section = provider.get_section(section_index)
                  if not section then return end

                  local slot = section.get_slot(i)
                  if slot.max and num > slot.max then
                     UiSounds.play_ui_edge(ctx.pindex)
                     ctx.controller.message:fragment({ "fa.logistics-min-must-be-at-most-max", tostring(slot.max) })
                  else
                     slot.min = math.floor(num)
                     section.set_slot(i, slot)

                     ctx.controller.message:fragment(tostring(math.floor(num)))
                  end
               end
            end,
            on_clear = function(ctx)
               local section = provider.get_section(section_index)
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
                  local section = provider.get_section(section_index)
                  if not section then return end

                  local slot = section.get_slot(i)
                  slot.max = nil
                  section.set_slot(i, slot)

                  ctx.controller.message:fragment({ "fa.infinity" })
               else
                  local num = tonumber(result)
                  if not num then
                     UiSounds.play_ui_edge(ctx.pindex)
                     ctx.controller.message:fragment({ "fa.logistics-invalid-number" })
                  elseif num < 0 then
                     UiSounds.play_ui_edge(ctx.pindex)
                     ctx.controller.message:fragment({ "fa.logistics-value-cannot-be-negative" })
                  else
                     local section = provider.get_section(section_index)
                     if not section then return end

                     local slot = section.get_slot(i)
                     local min_val = slot.min or 0
                     if num < min_val then
                        UiSounds.play_ui_edge(ctx.pindex)
                        ctx.controller.message:fragment({ "fa.logistics-max-must-be-at-least-min", tostring(min_val) })
                     else
                        slot.max = math.floor(num)
                        section.set_slot(i, slot)

                        ctx.controller.message:fragment(tostring(math.floor(num)))
                     end
                  end
               end
            end,
            on_clear = function(ctx)
               local section = provider.get_section(section_index)
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
               local section = provider.get_section(section_index)
               if not section then return end

               section.clear_slot(i)

               UiSounds.play_menu_move(ctx.pindex)
               ctx.controller.message:fragment({ "fa.logistics-deleted" })
            end,
         })

         menu:end_row()
      end
   end

   -- Add "Add filter/request" button
   menu:add_item("add_filter", {
      label = function(ctx)
         ctx.message:fragment({ "fa.logistics-add-request" })
      end,
      on_click = function(ctx)
         ctx.controller:open_child_ui(Router.UI_NAMES.SIGNAL_CHOOSER, { mode = signal_mode }, { node = "add_filter" })
      end,
      on_child_result = function(ctx, result)
         if result then
            local section = provider.get_section(section_index)
            if not section then return end

            local new_index = section.filters_count + 1
            result.quality = result.quality or "normal"
            section.set_slot(new_index, {
               value = result,
               min = 0,
               max = nil,
            })

            ctx.controller.message:fragment({
               "fa.logistics-request-added",
               CircuitNetwork.localise_signal(result),
            })
         end
      end,
   })

   -- Bottom row: section management controls
   menu:start_row("section_controls")

   -- Group selector
   menu:add_item("group_selector", {
      label = function(ctx)
         local section = provider.get_section(section_index)
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
            local section = provider.get_section(section_index)
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
         local section = provider.get_section(section_index)
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
         if provider.remove_section(section_index) then
            UiSounds.play_menu_move(ctx.pindex)
            ctx.controller.message:fragment({ "fa.logistics-section-deleted" })
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
         local new_section = provider.add_section("", section_index + 1)
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
         local new_section = provider.add_section()
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

---Create a section editor tab
---@param point_index number? Only required for logistic points, nil for constant combinators
---@param section_index number
---@param title? LocalisedString Optional title override
---@return fa.ui.TabDescriptor
function mod.create_section_tab(point_index, section_index, title)
   local name_suffix = point_index and ("_" .. point_index .. "_" .. section_index) or ("_" .. section_index)
   return KeyGraph.declare_graph({
      name = "section" .. name_suffix,
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
      ---@param ctx fa.ui.graph.Ctx
      ---@return fa.ui.graph.Render
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
