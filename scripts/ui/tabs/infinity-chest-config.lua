--[[
Infinity chest configuration tab.

Provides controls for:
- Trash unrequested items
- Individual filter slots (item, mode, count)
]]

local Menu = require("scripts.ui.menu")
local UiKeyGraph = require("scripts.ui.key-graph")
local Controls = require("scripts.ui.controls")
local UiRouter = require("scripts.ui.router")
local UiUtils = require("scripts.ui.ui-utils")
local UiSounds = require("scripts.ui.sounds")
local Localising = require("scripts.localising")

local mod = {}

---Get mode label for infinity chest filter
---@param mode string
---@return LocalisedString
local function get_mode_label(mode)
   if mode == "at-least" then
      return { "fa.infinity-chest-mode-at-least" }
   elseif mode == "at-most" then
      return { "fa.infinity-chest-mode-at-most" }
   elseif mode == "exactly" then
      return { "fa.infinity-chest-mode-exactly" }
   else
      return { "fa.unknown" }
   end
end

---Render the infinity chest configuration menu
---@param ctx fa.ui.graph.Ctx
---@return fa.ui.graph.Render?
local function render_infinity_chest_config(ctx)
   local entity = ctx.tablist_shared_state.entity
   if not entity or not entity.valid then return nil end

   local menu = Menu.MenuBuilder.new()

   -- Row 1: Trash unrequested checkbox
   menu:add_item(
      "trash_unrequested",
      Controls.checkbox({
         label = { "fa.infinity-chest-trash-unrequested" },
         get = function()
            return entity.remove_unfiltered_items
         end,
         set = function(v)
            entity.remove_unfiltered_items = v
         end,
      })
   )

   -- Get all existing filters
   local filters = entity.infinity_container_filters or {}

   -- Add rows for each existing filter
   for i, filter in ipairs(filters) do
      local row_key = "filter_" .. i
      menu:start_row(row_key)

      -- Item 1: Overview + item selector
      menu:add_item(row_key .. "_overview", {
         label = function(ctx)
            local filter = entity.infinity_container_filters[i]
            if not filter then
               ctx.message:fragment({ "fa.empty" })
               return
            end

            -- Get item prototype for localized name
            local item_proto = prototypes.item[filter.name]
            if item_proto then
               ctx.message:fragment(item_proto.localised_name)
            else
               ctx.message:fragment(filter.name)
            end

            -- Add mode
            ctx.message:fragment(get_mode_label(filter.mode or "exactly"))

            -- Add count
            ctx.message:fragment(tostring(filter.count or 0))
         end,
         on_click = function(ctx)
            ctx.controller:open_child_ui(
               UiRouter.UI_NAMES.SIGNAL_CHOOSER,
               {},
               { node = row_key .. "_overview", filter_index = i }
            )
         end,
         on_child_result = function(ctx, result)
            if result and result.name then
               local filters = entity.infinity_container_filters
               local current = filters[i] or {}

               -- Update item but preserve mode and count
               entity.set_infinity_container_filter(i, {
                  name = result.name,
                  mode = current.mode or "exactly",
                  count = current.count or 0,
               })

               local item_proto = prototypes.item[result.name]
               if item_proto then
                  ctx.controller.message:fragment(item_proto.localised_name)
               else
                  ctx.controller.message:fragment(result.name)
               end
            end
         end,
         on_clear = function(ctx)
            -- Remove this filter by rebuilding the filters array without it
            local filters = entity.infinity_container_filters
            local new_filters = {}
            for j, f in ipairs(filters) do
               if j ~= i then table.insert(new_filters, f) end
            end
            entity.infinity_container_filters = new_filters

            UiSounds.play_menu_move(ctx.pindex)
            ctx.controller.message:fragment({ "fa.deleted" })
         end,
      })

      -- Item 2: Mode selector
      menu:add_item(row_key .. "_mode", {
         label = function(ctx)
            local filter = entity.infinity_container_filters[i]
            if not filter then
               ctx.message:fragment({ "fa.empty" })
               return
            end
            ctx.message:fragment({ "fa.infinity-chest-mode" })
            ctx.message:fragment(get_mode_label(filter.mode or "exactly"))
         end,
         on_click = function(ctx)
            local filters = entity.infinity_container_filters
            local current = filters[i]
            if not current then return end

            -- Cycle through modes: at-least -> at-most -> exactly -> at-least
            local new_mode
            if current.mode == "at-least" then
               new_mode = "at-most"
            elseif current.mode == "at-most" then
               new_mode = "exactly"
            else
               new_mode = "at-least"
            end

            entity.set_infinity_container_filter(i, {
               name = current.name,
               mode = new_mode,
               count = current.count or 0,
            })

            ctx.controller.message:fragment(get_mode_label(new_mode))
         end,
         on_clear = function(ctx)
            -- Remove this filter by rebuilding the filters array without it
            local filters = entity.infinity_container_filters
            local new_filters = {}
            for j, f in ipairs(filters) do
               if j ~= i then table.insert(new_filters, f) end
            end
            entity.infinity_container_filters = new_filters

            UiSounds.play_menu_move(ctx.pindex)
            ctx.controller.message:fragment({ "fa.deleted" })
         end,
      })

      -- Item 3: Count field
      menu:add_item(row_key .. "_count", {
         label = function(ctx)
            local filter = entity.infinity_container_filters[i]
            if not filter then
               ctx.message:fragment({ "fa.empty" })
               return
            end
            ctx.message:fragment({ "fa.infinity-chest-count" })
            ctx.message:fragment(tostring(filter.count or 0))
         end,
         on_click = function(ctx)
            local filters = entity.infinity_container_filters
            local current = filters[i]
            if not current then return end

            ctx.controller:open_textbox(
               "",
               { node = row_key .. "_count", filter_index = i },
               { "fa.infinity-chest-enter-count" }
            )
         end,
         on_child_result = function(ctx, result)
            local num = tonumber(result)
            if num and num >= 0 then
               local filters = entity.infinity_container_filters
               local current = filters[i]
               if not current then return end

               entity.set_infinity_container_filter(i, {
                  name = current.name,
                  mode = current.mode or "exactly",
                  count = math.floor(num),
               })

               ctx.controller.message:fragment(tostring(math.floor(num)))
            else
               UiSounds.play_ui_edge(ctx.pindex)
               ctx.controller.message:fragment({ "fa.invalid-number" })
            end
         end,
         on_clear = function(ctx)
            -- Remove this filter by rebuilding the filters array without it
            local filters = entity.infinity_container_filters
            local new_filters = {}
            for j, f in ipairs(filters) do
               if j ~= i then table.insert(new_filters, f) end
            end
            entity.infinity_container_filters = new_filters

            UiSounds.play_menu_move(ctx.pindex)
            ctx.controller.message:fragment({ "fa.deleted" })
         end,
      })

      -- Item 4: Delete button
      menu:add_item(row_key .. "_delete", {
         label = function(ctx)
            ctx.message:fragment({ "fa.delete" })
         end,
         on_click = function(ctx)
            -- Remove this filter by rebuilding the filters array without it
            local filters = entity.infinity_container_filters
            local new_filters = {}
            for j, f in ipairs(filters) do
               if j ~= i then table.insert(new_filters, f) end
            end
            entity.infinity_container_filters = new_filters

            UiSounds.play_menu_move(ctx.pindex)
            ctx.controller.message:fragment({ "fa.deleted" })
         end,
         on_clear = function(ctx)
            -- Remove this filter by rebuilding the filters array without it
            local filters = entity.infinity_container_filters
            local new_filters = {}
            for j, f in ipairs(filters) do
               if j ~= i then table.insert(new_filters, f) end
            end
            entity.infinity_container_filters = new_filters

            UiSounds.play_menu_move(ctx.pindex)
            ctx.controller.message:fragment({ "fa.deleted" })
         end,
      })

      menu:end_row()
   end

   -- Add "Add filter" button
   menu:add_item("add_filter", {
      label = function(ctx)
         ctx.message:fragment({ "fa.infinity-chest-add-filter" })
      end,
      on_click = function(ctx)
         ctx.controller:open_child_ui(UiRouter.UI_NAMES.SIGNAL_CHOOSER, {}, { node = "add_filter" })
      end,
      on_child_result = function(ctx, result)
         if result and result.name then
            local filters = entity.infinity_container_filters
            local new_index = #filters + 1

            -- Get default stack size for the item
            local item_proto = prototypes.item[result.name]
            local default_count = item_proto and item_proto.stack_size or 1

            entity.set_infinity_container_filter(new_index, {
               name = result.name,
               mode = "exactly",
               count = default_count,
            })

            ctx.controller.message:fragment({
               "fa.infinity-chest-filter-added",
               item_proto and item_proto.localised_name or result.name,
            })
         end
      end,
   })

   return menu:build()
end

-- Create the tab descriptor
mod.infinity_chest_config_tab = UiKeyGraph.declare_graph({
   name = "infinity-chest-config",
   title = { "fa.infinity-chest-config-title" },
   render_callback = render_infinity_chest_config,
})

---Check if this tab is available for the given entity
---@param entity LuaEntity
---@return boolean
function mod.is_available(entity)
   return entity.type == "infinity-container"
end

return mod
