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
local Controls = require("scripts.ui.controls")
local Router = require("scripts.ui.router")
local UiSounds = require("scripts.ui.sounds")
local CircuitNetwork = require("scripts.circuit-network")
local FaInfo = require("scripts.fa-info")
local Consts = require("scripts.consts")
local Localising = require("scripts.localising")

local mod = {}

---@type RequestFromLocation[]
local REQUEST_FROM_CHOICES = { "planet", "platforms", "all" }

---The planets a platform hub request can be limited to, in the game's order
---@return LuaSpaceLocationPrototype[]
local function importable_planets()
   local planets = {}
   for _, location in pairs(prototypes.space_location) do
      if location.type == "planet" and not location.hidden then table.insert(planets, location) end
   end
   table.sort(planets, function(a, b)
      return a.order < b.order
   end)
   return planets
end

---The name of the planet a request imports from, or nil for any location
---@param filter LogisticFilter
---@return string?
local function import_from_name(filter)
   local location = filter.import_from
   if location == nil or type(location) == "string" then return location end
   return location.name
end

---@param filter LogisticFilter
---@return LocalisedString
local function localise_import_from(filter)
   local name = import_from_name(filter)
   if not name then return { "gui-orbital-request.any-location" } end
   return Localising.get_localised_name_with_fallback(prototypes.space_location[name])
end

---Build the unified section editor menu
---Works for all entities via entity.get_logistic_sections()
---@param ctx fa.ui.graph.Ctx
---@param section_index integer
---@return fa.ui.graph.Render?
local function render_section(ctx, section_index)
   assert(ctx.global_parameters, "render_section: global_parameters is nil")
   local entity = ctx.global_parameters.entity

   -- Validate entity at render callback entry
   if not entity or not entity.valid then return nil end

   -- Get sections directly from entity
   local sections = entity.get_logistic_sections()
   assert(sections, "render_section: entity has no logistic sections")

   local section = sections.get_section(section_index)
   assert(section, "render_section: section not found")

   local menu = Menu.MenuBuilder.new()

   -- Determine signal mode based on entity type
   local is_combinator = entity.type == "constant-combinator"
   local is_roboport = entity.type == "roboport"
   -- Only the hub's requests are orbital requests, with the fields the game shows under them
   local is_orbital = script.feature_flags.space_travel and entity.type == "space-platform-hub"
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
               local max_text = max_val and tostring(max_val) or { "fa.infinity" }
               if import_from_name(slot) then
                  ctx.message:fragment({
                     "fa.logistics-signal-range-from",
                     CircuitNetwork.localise_signal(sid),
                     tostring(min_val),
                     max_text,
                     localise_import_from(slot),
                  })
               else
                  ctx.message:fragment({
                     "fa.logistics-signal-range",
                     CircuitNetwork.localise_signal(sid),
                     tostring(min_val),
                     max_text,
                  })
               end
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
               elseif num < Consts.INT32_MIN or num > Consts.INT32_MAX then
                  UiSounds.play_ui_edge(ctx.pindex)
                  ctx.controller.message:fragment({ "fa.logistics-value-out-of-range" })
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
                  elseif num > Consts.INT32_MAX then
                     UiSounds.play_ui_edge(ctx.pindex)
                     ctx.controller.message:fragment({ "fa.logistics-value-out-of-range" })
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

         if is_orbital then
            ---Replace the slot with a changed copy, keeping its other fields
            ---@param change fun(filter: LogisticFilter)
            ---@return LogisticFilter
            local function modify_slot(change)
               local section = entity.get_logistic_sections().get_section(section_index)
               local filter = section.get_slot(i)
               change(filter)
               section.set_slot(i, filter)
               return filter
            end

            -- Import from: any location, then each planet
            menu:add_item(item_key .. "_import_from", {
               label = function(ctx)
                  local sid = slot.value
                  ---@cast sid SignalID
                  ctx.message:fragment({
                     "fa.logistics-import-from-for",
                     localise_import_from(slot),
                     CircuitNetwork.localise_signal(sid),
                  })
               end,
               on_click = function(ctx)
                  local planets = importable_planets()
                  local direction = (ctx.modifiers and ctx.modifiers.shift) and -1 or 1
                  local filter = modify_slot(function(filter)
                     local current = import_from_name(filter)
                     -- 0 is any location
                     local index = 0
                     for n, planet in ipairs(planets) do
                        if planet.name == current then index = n end
                     end
                     index = (index + direction) % (#planets + 1)
                     filter.import_from = index > 0 and planets[index].name or nil
                  end)
                  UiSounds.play_menu_move(ctx.pindex)
                  ctx.controller.message:fragment(localise_import_from(filter))
               end,
               on_clear = function(ctx)
                  modify_slot(function(filter)
                     filter.import_from = nil
                  end)
                  ctx.controller.message:fragment({ "gui-orbital-request.any-location" })
               end,
            })

            -- Request from: planet, platforms or all
            menu:add_item(item_key .. "_request_from", {
               label = function(ctx)
                  local sid = slot.value
                  ---@cast sid SignalID
                  ctx.message:fragment({
                     "fa.logistics-request-from-for",
                     { "gui-orbital-request." .. (slot.request_from or "planet") },
                     CircuitNetwork.localise_signal(sid),
                  })
               end,
               on_click = function(ctx)
                  local direction = (ctx.modifiers and ctx.modifiers.shift) and -1 or 1
                  local filter = modify_slot(function(filter)
                     local index = 1
                     for n, choice in ipairs(REQUEST_FROM_CHOICES) do
                        if choice == (filter.request_from or "planet") then index = n end
                     end
                     index = (index - 1 + direction) % #REQUEST_FROM_CHOICES + 1
                     filter.request_from = REQUEST_FROM_CHOICES[index]
                  end)
                  UiSounds.play_menu_move(ctx.pindex)
                  ctx.controller.message:fragment({ "gui-orbital-request." .. filter.request_from })
               end,
            })

            -- Custom minimum payload: unset is the game's default
            menu:add_item(item_key .. "_min_payload", {
               label = function(ctx)
                  local sid = slot.value
                  ---@cast sid SignalID
                  if slot.minimum_delivery_count then
                     ctx.message:fragment({
                        "fa.logistics-min-payload-for",
                        tostring(slot.minimum_delivery_count),
                        CircuitNetwork.localise_signal(sid),
                     })
                  else
                     ctx.message:fragment({ "fa.logistics-no-min-payload-for", CircuitNetwork.localise_signal(sid) })
                  end
               end,
               on_click = function(ctx)
                  ctx.controller:open_textbox(
                     "",
                     { node = item_key .. "_min_payload", slot_index = i },
                     { "fa.logistics-enter-min-payload" }
                  )
               end,
               on_child_result = function(ctx, result)
                  local num = tonumber(result)
                  -- The largest payload, as the game's rocket capacity
                  local item = prototypes.item[slot.value.name]
                  local capacity = math.floor(prototypes.utility_constants.default_rocket_lift_weight / item.weight)
                  if not num then
                     UiSounds.play_ui_edge(ctx.pindex)
                     ctx.controller.message:fragment({ "fa.logistics-invalid-number" })
                  elseif num < 1 then
                     UiSounds.play_ui_edge(ctx.pindex)
                     ctx.controller.message:fragment({ "fa.logistics-min-payload-too-low" })
                  elseif num > capacity then
                     UiSounds.play_ui_edge(ctx.pindex)
                     ctx.controller.message:fragment({ "fa.logistics-min-payload-too-high", tostring(capacity) })
                  else
                     modify_slot(function(filter)
                        filter.minimum_delivery_count = math.floor(num)
                     end)
                     ctx.controller.message:fragment(tostring(math.floor(num)))
                  end
               end,
               on_clear = function(ctx)
                  modify_slot(function(filter)
                     filter.minimum_delivery_count = nil
                  end)
                  ctx.controller.message:fragment({ "fa.logistics-min-payload-cleared" })
               end,
            })
         end

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

   -- Section settings row: group, multiplier, active
   menu:start_row("section_settings")

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

   -- Multiplier
   menu:add_item("multiplier", {
      label = function(ctx)
         local sections = entity.get_logistic_sections()
         if not sections then return end
         local section = sections.get_section(section_index)
         if not section then return end

         ctx.message:fragment({ "fa.logistics-multiplier", tostring(section.multiplier) })
      end,
      on_click = function(ctx)
         ctx.controller:open_textbox("", { node = "multiplier" }, { "fa.logistics-enter-multiplier" })
      end,
      on_child_result = function(ctx, result)
         local num = tonumber(result)
         if not num then
            UiSounds.play_ui_edge(ctx.pindex)
            ctx.controller.message:fragment({ "fa.logistics-invalid-number" })
         elseif num < 0 then
            UiSounds.play_ui_edge(ctx.pindex)
            ctx.controller.message:fragment({ "fa.logistics-multiplier-cannot-be-negative" })
         elseif num > Consts.INT32_MAX then
            UiSounds.play_ui_edge(ctx.pindex)
            ctx.controller.message:fragment({ "fa.logistics-value-out-of-range" })
         else
            local sections = entity.get_logistic_sections()
            if not sections then return end
            local section = sections.get_section(section_index)
            if not section then return end

            section.multiplier = num
            ctx.controller.message:fragment({ "fa.logistics-multiplier", tostring(num) })
         end
      end,
      on_clear = function(ctx)
         local sections = entity.get_logistic_sections()
         if not sections then return end
         local section = sections.get_section(section_index)
         if not section then return end

         section.multiplier = 1
         ctx.controller.message:fragment({ "fa.logistics-multiplier", "1" })
      end,
   })

   -- Active checkbox
   menu:add_item(
      "active",
      Controls.checkbox({
         label = { "fa.logistics-active" },
         get = function()
            local sections = entity.get_logistic_sections()
            if not sections then return false end
            local section = sections.get_section(section_index)
            if not section then return false end
            return section.active
         end,
         set = function(v)
            local sections = entity.get_logistic_sections()
            if not sections then return end
            local section = sections.get_section(section_index)
            if not section then return end
            section.active = v
         end,
      })
   )

   menu:end_row()

   -- Section management row: delete, add
   menu:start_row("section_management")

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
---@param section_index integer
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
