local TravelTools = require("scripts.travel-tools")
local FaUtils = require("scripts.fa-utils")
local Functools = require("scripts.functools")
local Graphics = require("scripts.graphics")
local UiKeyGraph = require("scripts.ui.key-graph")
local Menu = require("scripts.ui.menu")
local UiRouter = require("scripts.ui.router")
local TabList = require("scripts.ui.tab-list")
local Viewpoint = require("scripts.viewpoint")

local mod = {}

---@type fun(fa.ui.graph.Ctx): fa.ui.graph.Render?
local function render(ctx)
   local p = game.get_player(ctx.pindex)
   if not p then return nil end

   local controller = TravelTools.get_controller(ctx.pindex)
   local builder = Menu.MenuBuilder.new()
   local vp = Viewpoint.get_viewpoint(ctx.pindex)

   local num_points = controller:get_num_travel_points()

   -- Add travel points as rows
   for i = 1, num_points do
      local point = controller:get_point_by_index(i)
      if point then
         local point_id = point.id -- Capture ID for closures

         -- Start a row for this travel point
         builder:start_row("travelpoint")

         -- Point name and location
         builder:add_clickable("point-" .. point_id, function(ctx)
            local position_str = FaUtils.format_position(point.position.x, point.position.y)
            if point.description and point.description ~= "" then
               ctx.message:fragment({
                  "fa.travel-point-label-with-description",
                  point.label,
                  position_str,
                  point.description,
               })
            else
               ctx.message:fragment({ "fa.travel-point-label-no-description", point.label, position_str })
            end
         end, {
            on_click = function(ctx)
               -- Move cursor to show location
               vp:set_cursor_pos(FaUtils.center_of_tile(point.position))
               Graphics.draw_cursor_highlight(ctx.pindex, nil, "train-visualization")
               ctx.controller:close()
               ctx.message:fragment({ "fa.travel-cursor-moved-to", point.label })
            end,
            on_dangerous_delete = function(ctx)
               -- Delete travel point with Ctrl+Backspace
               local deleted_name = point.label
               if controller:delete_point(point_id) then
                  ctx.message:fragment({ "fa.travel-deleted-point", deleted_name })
                  -- Menu will re-render automatically
               else
                  ctx.message:fragment({ "fa.travel-failed-delete" })
               end
            end,
         })

         -- Teleport action
         builder:add_clickable("teleport-" .. point_id, function(ctx)
            ctx.message:fragment({ "fa.travel-menu-travel" })
            ctx.message:fragment(point.label)
         end, {
            on_click = function(ctx)
               if controller:travel_to_point(point_id) then
                  ctx.controller:close()
                  ctx.message:fragment({ "fa.travel-teleported-to", point.label })
               end
            end,
         })

         -- Relocate action
         builder:add_clickable("relocate-" .. point_id, function(ctx)
            ctx.message:fragment({ "fa.travel-menu-relocate" })
            ctx.message:fragment(point.label)
         end, {
            on_click = function(ctx)
               local p = game.get_player(ctx.pindex)
               if not p or not p.character then
                  ctx.message:fragment({ "fa.travel-cannot-relocate-no-character" })
                  return
               end

               local position = storage.players[ctx.pindex].position
               if controller:relocate_point(point_id, position) then
                  ctx.message:fragment({
                     "fa.travel-relocated-point",
                     point.label,
                     tostring(math.floor(position.x)),
                     tostring(math.floor(position.y)),
                  })
                  vp:set_cursor_pos({ x = position.x, y = position.y })
                  Graphics.draw_cursor_highlight(ctx.pindex)
               else
                  ctx.message:fragment({ "fa.travel-failed-relocate" })
               end
            end,
         })

         -- Rename action
         builder:add_clickable("rename-" .. point_id, function(ctx)
            ctx.message:fragment({ "fa.travel-menu-rename" })
            ctx.message:fragment(point.label)
         end, {
            on_click = function(ctx)
               ctx.controller:open_textbox("", "rename-" .. point_id)
               ctx.message:fragment({ "fa.travel-enter-name" })
            end,
            on_child_result = function(ctx, result)
               if result and result ~= "" then
                  if controller:update_point_label(point_id, result) then
                     ctx.message:fragment({ "fa.travel-point-renamed", result })
                     -- Menu will re-render automatically
                  end
               end
            end,
         })

         -- Edit description action
         builder:add_clickable("edit-desc-" .. point_id, function(ctx)
            ctx.message:fragment({ "fa.travel-rewrite-description-of", point.label })
         end, {
            on_click = function(ctx)
               ctx.controller:open_textbox("", "edit-desc-" .. point_id)
               ctx.message:fragment({ "fa.travel-enter-description" })
            end,
            on_child_result = function(ctx, result)
               if result then
                  if controller:update_point_description(point_id, result) then
                     ctx.message:fragment({ "fa.travel-description-updated" })
                     -- Menu will re-render automatically
                  end
               end
            end,
         })

         -- Delete action
         builder:add_clickable("delete-" .. point_id, function(ctx)
            ctx.message:fragment({ "fa.travel-menu-delete" })
            ctx.message:fragment(point.label)
         end, {
            on_click = function(ctx)
               local deleted_name = point.label
               if controller:delete_point(point_id) then
                  ctx.message:fragment({ "fa.travel-deleted-point", deleted_name })
                  -- Menu will re-render automatically
               else
                  ctx.message:fragment({ "fa.travel-failed-delete" })
               end
            end,
         })

         builder:end_row()
      end
   end

   -- Add bottom actions row
   builder:start_row("actions")

   -- Create new travel point
   builder:add_clickable("create-new", { "fa.travel-menu-create-new" }, {
      on_click = function(ctx)
         ctx.controller:open_textbox("", "create-new")
         ctx.message:fragment({ "fa.travel-enter-name" })
      end,
      on_child_result = function(ctx, result)
         if result and result ~= "" then
            local p = game.get_player(ctx.pindex)
            if p and p.character then
               local position = storage.players[ctx.pindex].position
               controller:create_point(result, position)
               ctx.message:fragment({ "fa.travel-point-created", result })
               -- Menu will re-render automatically
            end
         end
      end,
   })

   builder:end_row()

   return builder:build()
end

mod.fast_travel_menu_tabs = TabList.declare_tablist({
   ui_name = UiRouter.UI_NAMES.TRAVEL,
   tabs_callback = Functools.functionize({
      {
         name = "main",
         tabs = {
            UiKeyGraph.declare_graph({
               name = "fast-travel-menu",
               render_callback = render,
               title = { "fa.travel-menu-title" },
            }),
         },
      },
   }),
})

-- Register with the UI event routing system
UiRouter.register_ui(mod.fast_travel_menu_tabs)

return mod
