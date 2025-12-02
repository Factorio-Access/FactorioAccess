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
local FaInfo = require("scripts.fa-info")
local BotLogistics = require("scripts.worker-robots")

local mod = {}

---Build the unified section editor menu
---Works for all entities via entity.get_logistic_sections()
---@param ctx fa.ui.graph.Ctx
---@param section_index number
---@return fa.ui.graph.Render?
local function render_section(ctx, section_index)
   assert(ctx.global_parameters, "render_section: global_parameters is nil")
   local entity = ctx.global_parameters.entity

   -- Validate entity at render callback entry
   if not entity or not entity.valid then return nil end

   assert(section_index, "render_section: section_index is nil")

   -- Get sections directly from entity
   local sections = entity.get_logistic_sections()
   assert(sections, "render_section: entity has no logistic sections")

   local section = sections.get_section(section_index)
   assert(section, "render_section: section not found")

   local menu = Menu.MenuBuilder.new()

   -- Determine signal mode based on entity type
   local is_combinator = entity.type == "constant-combinator"
   local is_roboport = entity.type == "roboport"
   local signal_mode
   if is_combinator then
      signal_mode = "all"
   elseif is_roboport then
      signal_mode = "roboport-items"
   else
      signal_mode = "item"
   end

   -- Add rows for each existing filter/request
   for i = 1, section.filters_count do
      local slot = section.get_slot(i)
      if slot and slot.value then
         local item_key = "filter_" .. i
         -- All filter rows share the same key for column navigation
         menu:start_row("filter")

         -- Item 1: Overview + signal selector
         menu:add_item(item_key .. "_overview", {
            label = function(ctx)
               local min_val = slot.min or 0
               local max_val = slot.max

               -- Localize the signal (works for both items and other signal types)
               local sid = slot.value
               ---@cast sid SignalID
               ctx.message:fragment({
                  "fa.logistics-signal-range",
                  CircuitNetwork.localise_signal(sid),
                  tostring(min_val),
                  max_val and tostring(max_val) or { "fa.infinity" },
               })
            end,
            on_click = function(ctx)
               ctx.controller:open_child_ui(
                  Router.UI_NAMES.SIGNAL_CHOOSER,
                  { mode = signal_mode },
                  { node = item_key .. "_overview", slot_index = i }
               )
            end,
            on_child_result = function(ctx, result)
               if result then
                  local sections = entity.get_logistic_sections()
                  if not sections then return end
                  local section = sections.get_section(section_index)
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
         menu:add_item(item_key .. "_min", {
            label = function(ctx)
               local sid = slot.value
               ---@cast sid SignalID
               ctx.message:fragment({
                  "fa.logistics-min-for",
                  tostring(slot.min or 0),
                  CircuitNetwork.localise_signal(sid),
               })
            end,
            on_click = function(ctx)
               ctx.controller:open_textbox(
                  "",
                  { node = item_key .. "_min", slot_index = i },
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
                  local sections = entity.get_logistic_sections()
                  if not sections then return end
                  local section = sections.get_section(section_index)
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
               local sections = entity.get_logistic_sections()
               if not sections then return end
               local section = sections.get_section(section_index)
               if not section then return end

               local slot = section.get_slot(i)
               slot.min = 0
               section.set_slot(i, slot)

               ctx.controller.message:fragment("0")
            end,
         })

         -- Item 3: Max value
         menu:add_item(item_key .. "_max", {
            label = function(ctx)
               local sid = slot.value
               ---@cast sid SignalID
               ctx.message:fragment({
                  "fa.logistics-max-for",
                  slot.max and tostring(slot.max) or { "fa.infinity" },
                  CircuitNetwork.localise_signal(sid),
               })
            end,
            on_click = function(ctx)
               ctx.controller:open_textbox(
                  "",
                  { node = item_key .. "_max", slot_index = i },
                  { "fa.logistics-enter-max" }
               )
            end,
            on_child_result = function(ctx, result)
               if result == "" then
                  -- Error on empty - tell user to use backspace
                  UiSounds.play_ui_edge(ctx.pindex)
                  ctx.controller.message:fragment({ "fa.logistics-use-backspace-to-clear" })
               else
                  local num = tonumber(result)
                  if not num then
                     UiSounds.play_ui_edge(ctx.pindex)
                     ctx.controller.message:fragment({ "fa.logistics-invalid-number" })
                  elseif num < 0 then
                     UiSounds.play_ui_edge(ctx.pindex)
                     ctx.controller.message:fragment({ "fa.logistics-value-cannot-be-negative" })
                  else
                     local sections = entity.get_logistic_sections()
                     if not sections then return end
                     local section = sections.get_section(section_index)
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
               local sections = entity.get_logistic_sections()
               if not sections then return end
               local section = sections.get_section(section_index)
               if not section then return end

               local slot = section.get_slot(i)
               slot.max = nil
               section.set_slot(i, slot)

               ctx.controller.message:fragment({ "fa.infinity" })
            end,
         })

         -- Item 4: Delete button
         menu:add_item(item_key .. "_delete", {
            label = function(ctx)
               local sid = slot.value
               ---@cast sid SignalID
               ctx.message:fragment({ "fa.logistics-delete-for", CircuitNetwork.localise_signal(sid) })
            end,
            on_click = function(ctx)
               local sections = entity.get_logistic_sections()
               if not sections then return end
               local section = sections.get_section(section_index)
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
            local sections = entity.get_logistic_sections()
            if not sections then return end
            local section = sections.get_section(section_index)
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
         local sections = entity.get_logistic_sections()
         if not sections then
            ctx.message:fragment({ "fa.logistics-no-group" })
            return
         end
         local section = sections.get_section(section_index)
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
         ctx.controller:open_child_ui(
            Router.UI_NAMES.LOGISTIC_GROUP_SELECTOR,
            { entity = entity },
            { node = "group_selector" }
         )
      end,
      on_child_result = function(ctx, result)
         if result ~= nil then
            local sections = entity.get_logistic_sections()
            if not sections then return end
            local section = sections.get_section(section_index)
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
         local sections = entity.get_logistic_sections()
         if not sections then return end
         local section = sections.get_section(section_index)
         if not section then return end

         section.group = ""
         ctx.controller.message:fragment({ "fa.logistics-group-cleared" })
      end,
      on_action1 = function(ctx)
         ctx.controller:open_textbox("", { node = "group_selector" }, { "fa.logistics-enter-group-name" })
      end,
   })

   -- Delete this section
   menu:add_item("delete_section", {
      label = function(ctx)
         ctx.message:fragment({ "fa.logistics-delete-section" })
      end,
      on_click = function(ctx)
         local sections = entity.get_logistic_sections()
         if sections and sections.remove_section(section_index) then
            UiSounds.play_menu_move(ctx.pindex)
            ctx.controller.message:fragment({ "fa.logistics-section-deleted" })
         else
            UiSounds.play_ui_edge(ctx.pindex)
            ctx.controller.message:fragment({ "fa.logistics-section-delete-failed" })
         end
      end,
   })

   -- Add new section to end
   menu:add_item("add_section_end", {
      label = function(ctx)
         ctx.message:fragment({ "fa.logistics-add-section-end" })
      end,
      on_click = function(ctx)
         local sections = entity.get_logistic_sections()
         local new_section = sections and sections.add_section()
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
---@param section_index number
---@param title? LocalisedString Optional title override
---@return fa.ui.TabDescriptor
function mod.create_section_tab(section_index, title)
   return KeyGraph.declare_graph({
      name = "section_" .. section_index,
      title = title or { "fa.logistics-section-title", tostring(section_index) },
      render_callback = function(ctx)
         return render_section(ctx, section_index)
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
