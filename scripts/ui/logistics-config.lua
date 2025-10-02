--[[
Logistics configuration UI for entities with logistic sections.
Allows configuring logistic requests with min/max values.
]]
local Menu = require("scripts.ui.menu")
local TabList = require("scripts.ui.tab-list")
local Router = require("scripts.ui.router")
local KeyGraph = require("scripts.ui.key-graph")
local Speech = require("scripts.speech")
local UiSounds = require("scripts.ui.sounds")
local Localising = require("scripts.localising")

local mod = {}

---Find or create the first manual section with group ""
---@param entity LuaEntity
---@return LuaLogisticSection?
local function get_or_create_manual_section(entity)
   if not entity or not entity.valid then return nil end

   local point = entity.get_logistic_point(defines.logistic_member_index.character_requester)
   if not point then return nil end

   -- Find existing manual section with no group
   for _, sec in pairs(point.sections) do
      if sec.is_manual and sec.group == "" then return sec end
   end

   -- Create new section
   return point.add_section()
end

---Build the logistics menu
---@param ctx fa.ui.graph.Ctx
---@return fa.ui.graph.Render?
local function render_logistics(ctx)
   local entity = ctx.global_parameters and ctx.global_parameters.entity
   if not entity or not entity.valid then return nil end

   local section = get_or_create_manual_section(entity)
   if not section then return nil end

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
               -- Open item chooser to change the item
               ctx.controller:open_child_ui(
                  Router.UI_NAMES.ITEM_CHOOSER,
                  {},
                  { node = row_key .. "_overview", slot_index = i }
               )
            end,
            on_child_result = function(ctx, result)
               if result then
                  local section = get_or_create_manual_section(entity)
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
               -- Open textbox for min value
               ctx.controller:open_textbox(
                  tostring(slot.min or 0),
                  { node = row_key .. "_min", slot_index = i },
                  { "fa.logistics-enter-min" }
               )
            end,
            on_child_result = function(ctx, result)
               local num = tonumber(result)
               if num and num >= 0 then
                  local section = get_or_create_manual_section(entity)
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
               local section = get_or_create_manual_section(entity)
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
               -- Open textbox for max value
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
                  local section = get_or_create_manual_section(entity)
                  if not section then return end

                  local slot = section.get_slot(i)
                  slot.max = nil
                  section.set_slot(i, slot)

                  ctx.controller.message:fragment({ "fa.infinity" })
               else
                  local num = tonumber(result)
                  if num and num >= 0 then
                     local section = get_or_create_manual_section(entity)
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
               local section = get_or_create_manual_section(entity)
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
               local section = get_or_create_manual_section(entity)
               if not section then return end

               -- Remove the slot
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
            local section = get_or_create_manual_section(entity)
            if not section then return end

            local new_index = section.filters_count + 1
            section.set_slot(new_index, {
               value = result,
               min = 0,
               max = nil, -- infinity
            })

            ctx.controller.message:fragment({
               "fa.logistics-request-added",
               Localising.get_localised_name_with_fallback(prototypes.item[result]),
            })
         end
      end,
   })

   return menu:build()
end

---Create the logistics configuration tab
---@return fa.ui.TabDescriptor
function mod.get_logistics_tab()
   return KeyGraph.declare_graph({
      name = "logistics",
      title = { "fa.logistics-title" },
      render_callback = render_logistics,
   })
end

---Create and register the logistics configuration UI
mod.logistics_ui = TabList.declare_tablist({
   ui_name = Router.UI_NAMES.LOGISTICS_CONFIG,
   resets_to_first_tab_on_open = true,
   tabs_callback = function()
      return {
         {
            name = "logistics",
            tabs = { mod.get_logistics_tab() },
         },
      }
   end,
})

Router.register_ui(mod.logistics_ui)

return mod
