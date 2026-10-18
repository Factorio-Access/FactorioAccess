--[[
Fast travel menu: a section per surface (ctrl+tab), a tab per category within it (tab), a row per point.

Sections and tabs come from TravelTools in a stable order; the menu opens on the player's own surface. Tab names are
stable identities (surface index and category ID), so the menu stays on a tab while the player works in it, also when m
and period move its category.
]]
local FaUtils = require("scripts.fa-utils")
local Graphics = require("scripts.graphics")
local Menu = require("scripts.ui.menu")
local SettingDecls = require("scripts.settings-decls")
local TabList = require("scripts.ui.tab-list")
local TravelTools = require("scripts.travel-tools")
local UiKeyGraph = require("scripts.ui.key-graph")
local UiRouter = require("scripts.ui.router")
local UiSounds = require("scripts.ui.sounds")
local Viewpoint = require("scripts.viewpoint")

local mod = {}

---@param surface_index integer
---@param filter fa.travel.Filter
---@return string
local function tab_name(surface_index, filter)
   return string.format("s%d-%s", surface_index, filter)
end

---@param pindex integer
---@param point fa.travel.TravelPoint
---@param ctx fa.ui.graph.Ctx
local function move_cursor_to(pindex, point, ctx)
   Viewpoint.get_viewpoint(pindex):set_cursor_pos(FaUtils.center_of_tile(point.position))
   Graphics.draw_cursor_highlight(pindex, nil, "train-visualization")
   ctx.controller:close()
   ctx.message:fragment({ "fa.travel-cursor-moved-to", point.label })
end

---@param pindex integer
---@return boolean
local function sorted_by_name(pindex)
   return settings.get_player_settings(pindex)[SettingDecls.SETTING_NAMES.FAST_TRAVEL_SORT_BY_NAME].value --[[@as boolean]]
end

---Keys that act on the tab from any of its rows: m and period move its category a tab earlier or later.
---@param pindex integer
---@param surface_index integer
---@param filter fa.travel.Filter
---@return table
local function tab_handlers(pindex, surface_index, filter)
   local function move(direction)
      return function(ctx)
         if type(filter) ~= "number" then
            UiSounds.play_ui_edge(pindex)
         elseif sorted_by_name(pindex) then
            UiSounds.play_ui_edge(pindex)
            ctx.message:fragment({ "fa.travel-move-category-sorted-by-name" })
         else
            local at, count = TravelTools.move_category(pindex, surface_index, filter, direction)
            if not at then
               UiSounds.play_ui_edge(pindex)
            else
               -- The first tab is not a category
               ctx.message:fragment({
                  "fa.travel-category-moved",
                  TravelTools.category_name(pindex, filter),
                  at + 1,
                  count + 1,
               })
            end
         end
      end
   end
   return { on_action1 = move(-1), on_action3 = move(1) }
end

---Keys that act on a point from any cell of its row: drag it, step its category, delete it.
---@param pindex integer
---@param point fa.travel.TravelPoint
---@param visible fa.travel.TravelPoint[] The tab's points, which dragging moves among
---@param filter fa.travel.Filter The tab's filter
---@return table
local function row_handlers(pindex, point, visible, filter)
   local function drag(direction)
      return function(ctx)
         if sorted_by_name(pindex) then
            UiSounds.play_ui_edge(pindex)
            ctx.message:fragment({ "fa.travel-drag-sorted-by-name" })
         elseif not TravelTools.drag_point(pindex, point.id, direction, visible) then
            UiSounds.play_ui_edge(pindex)
         else
            local now = TravelTools.points(pindex, point.surface_index, filter)
            for i, p in ipairs(now) do
               if p.id == point.id then ctx.message:fragment({ "fa.travel-dragged", point.label, i, #now }) end
            end
         end
      end
   end
   local function step(direction)
      return function(ctx)
         local moved = TravelTools.step_category(pindex, point.id, direction)
         if moved == nil then
            UiSounds.play_ui_edge(pindex)
         elseif moved == false then
            ctx.message:fragment({ "fa.travel-moved-to-uncategorized", point.label })
         else
            ctx.message:fragment({ "fa.travel-moved-to-category", point.label, moved })
         end
      end
   end
   return {
      on_drag_up = drag(-1),
      on_drag_down = drag(1),
      on_drag_left = step(-1),
      on_drag_right = step(1),
      on_dangerous_delete = function(ctx)
         TravelTools.delete_point(pindex, point.id)
         ctx.message:fragment({ "fa.travel-deleted-point", point.label })
      end,
   }
end

---@param base table
---@param extra table
---@return table
local function with(base, extra)
   local out = {}
   for k, v in pairs(base) do
      out[k] = v
   end
   for k, v in pairs(extra) do
      out[k] = v
   end
   return out
end

---@param ctx fa.ui.graph.Ctx
---@param surface_index integer
---@param filter fa.travel.Filter
---@return fa.ui.graph.Render?
local function render(ctx, surface_index, filter)
   local pindex = ctx.pindex
   local p = game.get_player(pindex)
   if not p then return nil end
   local vp = Viewpoint.get_viewpoint(pindex)
   local here = p.surface.index == surface_index

   local builder = Menu.MenuBuilder.new()
   local points = TravelTools.points(pindex, surface_index, filter)
   local tab_keys = tab_handlers(pindex, surface_index, filter)

   for _, point in ipairs(points) do
      local id = point.id
      local keys = with(row_handlers(pindex, point, points, filter), tab_keys)
      builder:start_row("travelpoint")

      builder:add_clickable(
         "point-" .. id,
         function(label_ctx)
            label_ctx.message:fragment(point.label)
            if filter == "all" and point.category then
               label_ctx.message:list_item(TravelTools.category_name(pindex, point.category))
            end
            label_ctx.message:list_item(FaUtils.format_position(point.position.x, point.position.y))
            if point.description ~= "" then label_ctx.message:list_item(point.description) end
         end,
         with(keys, {
            on_click = function(click_ctx)
               if here then
                  move_cursor_to(pindex, point, click_ctx)
               else
                  click_ctx.message:fragment(TravelTools.travel_to_point(pindex, id))
                  click_ctx.controller:close()
               end
            end,
         })
      )

      builder:add_clickable(
         "teleport-" .. id,
         { "fa.travel-menu-travel-to", point.label },
         with(keys, {
            on_click = function(click_ctx)
               click_ctx.message:fragment(TravelTools.travel_to_point(pindex, id))
               click_ctx.controller:close()
            end,
         })
      )

      builder:add_clickable(
         "relocate-" .. id,
         { "fa.travel-menu-relocate-point", point.label },
         with(keys, {
            on_click = function(click_ctx)
               local position = vp:get_cursor_pos()
               TravelTools.relocate_point(pindex, id, p.surface.index, position)
               click_ctx.message:fragment({
                  "fa.travel-relocated-point",
                  point.label,
                  tostring(math.floor(position.x)),
                  tostring(math.floor(position.y)),
               })
               Graphics.draw_cursor_highlight(pindex)
            end,
         })
      )

      builder:add_clickable(
         "rename-" .. id,
         { "fa.travel-menu-rename-point", point.label },
         with(keys, {
            on_click = function(click_ctx)
               click_ctx.controller:open_textbox("", "rename-" .. id)
               click_ctx.message:fragment({ "fa.travel-enter-name" })
            end,
            on_child_result = function(click_ctx, result)
               if result and result ~= "" then
                  TravelTools.rename_point(pindex, id, result)
                  click_ctx.message:fragment({ "fa.travel-point-renamed", result })
               end
            end,
         })
      )

      builder:add_clickable(
         "category-" .. id,
         function(label_ctx)
            local name = TravelTools.category_name(pindex, point.category)
            label_ctx.message:fragment(name or { "fa.travel-uncategorized" })
            label_ctx.message:fragment({ "fa.travel-category" })
         end,
         with(keys, {
            on_click = function(click_ctx)
               click_ctx.controller:open_child_ui(
                  UiRouter.UI_NAMES.TRAVEL_CATEGORY_SELECTOR,
                  {},
                  { node = "category-" .. id }
               )
            end,
            on_clear = function(click_ctx)
               TravelTools.set_category(pindex, id, nil)
               click_ctx.message:fragment({ "fa.travel-moved-to-uncategorized", point.label })
            end,
            on_child_result = function(click_ctx, result)
               if result == nil then return end
               TravelTools.set_category(pindex, id, result)
               if result == "" then
                  click_ctx.message:fragment({ "fa.travel-moved-to-uncategorized", point.label })
               else
                  click_ctx.message:fragment({ "fa.travel-moved-to-category", point.label, result })
               end
            end,
         })
      )

      builder:add_clickable(
         "edit-desc-" .. id,
         { "fa.travel-rewrite-description-of", point.label },
         with(keys, {
            on_click = function(click_ctx)
               click_ctx.controller:open_textbox("", "edit-desc-" .. id)
               click_ctx.message:fragment({ "fa.travel-enter-description" })
            end,
            on_child_result = function(click_ctx, result)
               if result then
                  TravelTools.set_description(pindex, id, result)
                  click_ctx.message:fragment({ "fa.travel-description-updated" })
               end
            end,
         })
      )

      builder:add_clickable(
         "delete-" .. id,
         { "fa.travel-menu-delete-point", point.label },
         with(keys, {
            on_click = function(click_ctx)
               TravelTools.delete_point(pindex, id)
               click_ctx.message:fragment({ "fa.travel-deleted-point", point.label })
            end,
         })
      )

      builder:end_row()
   end

   -- New points are made at the cursor, which is on the player's surface: only offered there
   if here then
      builder:add_clickable(
         "create-new",
         { "fa.travel-menu-create-new" },
         with(tab_keys, {
            on_click = function(click_ctx)
               click_ctx.controller:open_textbox("", "create-new")
               click_ctx.message:fragment({ "fa.travel-enter-name" })
            end,
            on_child_result = function(click_ctx, result)
               if result and result ~= "" then
                  local category = type(filter) == "number" and TravelTools.category_name(pindex, filter) or nil
                  TravelTools.create_point(pindex, result, surface_index, vp:get_cursor_pos(), category)
                  click_ctx.message:fragment({ "fa.travel-point-created", result })
               end
            end,
         })
      )
   elseif #points == 0 then
      -- A tab whose last point just left: it is gone from the list at the next key
      builder:add_label("empty", { "fa.travel-no-points" })
   end

   return builder:build()
end

-- One graph per tab, shared by every player; a tab's points are read when it renders
---@type table<string, fa.ui.TabCallbacks>
local graphs = {}

---@param surface_index integer
---@param filter fa.travel.Filter
---@param title LocalisedString
---@return fa.ui.TabDescriptor
local function tab(surface_index, filter, title)
   local name = tab_name(surface_index, filter)
   if not graphs[name] then
      graphs[name] = UiKeyGraph.declare_graph({
         name = name,
         title = title,
         render_callback = function(ctx)
            return render(ctx, surface_index, filter)
         end,
      }).callbacks
   end
   return { name = name, title = title, callbacks = graphs[name] }
end

---@param pindex integer
---@return fa.ui.TabstopDescriptor[]
local function tabstops(pindex)
   local out = {}
   for _, surface in ipairs(TravelTools.surfaces(pindex)) do
      local index = surface.index
      local tabs = { tab(index, "all", { "fa.travel-tab-all" }) }
      for _, c in ipairs(TravelTools.categories_on(pindex, index)) do
         table.insert(tabs, tab(index, c.id, c.name))
      end
      table.insert(out, { name = "s" .. index, title = TravelTools.surface_name(surface), tabs = tabs })
   end
   return out
end

mod.fast_travel_menu_tabs = TabList.declare_tablist({
   ui_name = UiRouter.UI_NAMES.TRAVEL,
   tabs_callback = tabstops,
   initial_tab = function(pindex)
      return tab_name(assert(game.get_player(pindex)).surface.index, "all")
   end,
})

UiRouter.register_ui(mod.fast_travel_menu_tabs)

return mod
