local Blueprints = require("scripts.blueprints")
local BuildDimensions = require("scripts.build-dimensions")
local FaUtils = require("scripts.fa-utils")
local Functools = require("scripts.functools")
local Graphics = require("scripts.graphics")
local Localising = require("scripts.localising")
local Speech = require("scripts.speech")
local TH = require("scripts.table-helpers")
local UiKeyGraph = require("scripts.ui.key-graph")
local Menu = require("scripts.ui.menu")
local UiRouter = require("scripts.ui.router")
local TabList = require("scripts.ui.tab-list")
local BoxSelector = require("scripts.ui.box-selector")

local mod = {}

---@type fun(fa.ui.graph.Ctx): fa.ui.graph.Render?
local function render(ctx)
   local p = game.get_player(ctx.pindex)
   if not p then return nil end

   ---@type LuaItemStack
   local bp = p.cursor_stack
   if not bp.is_blueprint then return nil end

   local builder = Menu.MenuBuilder.new()
   local is_temporary = p.cursor_stack_temporary

   if not bp.is_blueprint_setup() then
      -- Use custom intro message if provided in params, otherwise default
      local intro_message = (ctx.params and ctx.params.intro_message) or { "fa.ui-blueprints-menu-limited" }
      builder:add_label("blueprint-info", intro_message)

      -- Add option to select area for empty blueprint
      builder:add_clickable("select-area", { "fa.ui-blueprints-menu-reselect" }, {
         on_click = function(ctx)
            ctx.controller:open_child_ui(UiRouter.UI_NAMES.BLUEPRINT_AREA_SELECTOR, {
               intro_message = { "fa.ui-blueprints-select-first-point" },
               permanent = true,
            }, { node = "select-area" })
         end,
         on_child_result = function(ctx, result)
            if result and result.box then
               ctx.message:fragment({ "fa.ui-blueprints-area-selected" })
            else
               ctx.message:fragment({ "fa.ui-blueprints-selection-cancelled" })
            end
         end,
      })
   elseif is_temporary then
      -- Temporary blueprint: show limited message but allow export
      builder:add_label("blueprint-info", { "fa.ui-blueprints-menu-temporary" })
   else
      builder:add_label("blueprint-info", { "fa.ui-blueprints-menu-basic", bp.label or { "fa.unnamed" } })
   end

   -- Blueprints which are empty can't have descriptions; don't show it.
   if bp.is_blueprint_setup() and not is_temporary then
      builder:add_clickable("name", function(ctx)
         ctx.message:fragment({
            "fa.ui-blueprints-menu-name-click-to-edit",
            bp.label or { "fa.unnamed" },
         })
      end, {
         on_click = function(ctx)
            ctx.controller:open_textbox("", "name")
            ctx.message:fragment({ "fa.ui-blueprints-enter-name" })
         end,
         on_child_result = function(ctx, result)
            bp.label = result
            ctx.message:fragment({ "fa.ui-blueprints-renamed", result })
         end,
      })

      builder:add_clickable("description", function(ctx)
         ctx.message:fragment({
            "fa.ui-blueprints-menu-description-click-to-edit",
            bp.blueprint_description or "",
         })
      end, {
         on_click = function(ctx)
            ctx.controller:open_textbox("", "description")
            ctx.message:fragment({ "fa.ui-blueprints-enter-description" })
         end,
         ---@param result string
         on_child_result = function(ctx, result)
            ---@diagnostic disable-next-line: inject-field
            bp.blueprint_description = result
            ctx.message:fragment({ "fa.ui-blueprints-description-updated" })
         end,
      })

      builder:add_label("icons", function(ctx)
         local icons = bp.preview_icons
         if not icons or not next(icons) then
            ctx.message:fragment({ "fa.ui-blueprints-menu-no-icons" })
            return
         end

         table.sort(icons, function(a, b)
            return a.index < b.index
         end)

         icons = TH.map(bp.preview_icons, function(icon)
            -- Localising this is tricky because it could be from anywhere.

            local proto = FaUtils.find_prototype(icon.signal.name)
            if proto then return Localising.get_localised_name_with_fallback(proto) end

            return icon.signal.name
         end)

         ctx.message:fragment({ "fa.ui-blueprints-menu-icons" })
         for _, i in ipairs(icons) do
            ctx.message:list_item(i)
         end
      end)

      builder:add_label("count-and-dims", function(ctx)
         local count = bp.get_blueprint_entity_count()
         local width, height = BuildDimensions.get_stack_build_dimensions(bp, defines.direction.north)
         ctx.message:fragment({ "fa.ui-blueprints-menu-count-and-dims", width, height, count })
      end)

      builder:add_label("components", function(ctx)
         local comps = bp.get_blueprint_entities()
         if not comps or not next(comps) then
            ctx.message:fragment({ "fa.ui-blueprints-menu-no-components" })
            return
         end

         ctx.message:fragment({ "fa.ui-blueprints-menu-components-intro" })
         local counts = {}
         for _, comp in ipairs(comps) do
            counts[comp.name] = (counts[comp.name] or 0) + 1
         end

         local by_name = TH.set_to_sorted_array(counts)
         print(serpent.line(by_name))
         table.sort(by_name, function(a, b)
            return a[2] > b[2]
         end)

         for _, ent in pairs(by_name) do
            local comp, count = ent[1], ent[2]
            ctx.message:fragment(Localising.get_localised_name_with_fallback(prototypes.entity[comp]))
         end
      end)

      builder:add_clickable("copy", { "fa.ui-blueprints-menu-copy" }, {
         on_click = function(ctx)
            local p = game.get_player(ctx.pindex)
            if not p then return end
            -- The deepcopy here shouldn't be necessary, indeed it shouldn't do
            -- anything at all.  But this is copied over from old code, and it's
            -- not worth determining if it's secretly needed for some weird
            -- reason.
            if p.insert(table.deepcopy(bp)) > 0 then
               ctx.message:fragment({ "fa.ui-blueprints-copy-success" })
            else
               ctx.message:fragment({ "fa.ui-blueprints-copy-failed" })
            end
         end,
      })

      builder:add_clickable("delete", { "fa.ui-blueprints-menu-delete" }, {
         on_click = function(ctx)
            local p = game.get_player(ctx.pindex)
            if not p then return end

            bp.set_stack({ name = "blueprint", count = 1 })
            bp.set_stack(nil) --calls event handler to delete empty planners.
            ctx.message:fragment({ "fa.blueprints-ui-deleted" })
            ctx.controller:close()
         end,
      })

      builder:add_clickable("reselect", { "fa.ui-blueprints-menu-reselect" }, {
         on_click = function(ctx)
            ctx.controller:open_child_ui(UiRouter.UI_NAMES.BLUEPRINT_AREA_SELECTOR, {
               intro_message = { "fa.ui-blueprints-select-first-point" },
               permanent = true,
            }, { node = "reselect" })
         end,
      })
   end

   -- Export is available for both temporary and non-temporary blueprints
   if bp.is_blueprint_setup() then
      builder:add_clickable("export", { "fa.ui-blueprints-menu-export" }, {
         on_click = function(ctx)
            local export_string = bp.export_stack()
            ctx.controller:open_textbox(export_string, "export")
            ctx.message:fragment({ "fa.ui-blueprints-export-string-shown" })
         end,
         on_child_result = function(ctx, result)
            -- User might paste a different blueprint string to import
            if result and result ~= "" then
               local import_result = bp.import_stack(result)
               if import_result == 0 then
                  -- Mark as permanent after successful import
                  p.cursor_stack_temporary = false
                  ctx.message:fragment({ "fa.ui-blueprints-import-success" })
               else
                  ctx.message:fragment({ "fa.ui-blueprints-import-failed" })
               end
            else
               ctx.message:fragment({ "fa.ui-blueprints-export-closed" })
            end
         end,
      })
   end

   -- Import is available for all blueprints
   builder:add_clickable("import", { "fa.ui-blueprints-menu-import" }, {
      on_click = function(ctx)
         ctx.controller:open_textbox("", "import")
         ctx.message:fragment({ "fa.ui-blueprints-import-prompt" })
      end,
      on_child_result = function(ctx, result)
         if result and result ~= "" then
            local import_result = bp.import_stack(result)
            if import_result == 0 then
               -- Mark as permanent after successful import
               p.cursor_stack_temporary = false
               ctx.message:fragment({ "fa.ui-blueprints-import-success" })
            else
               ctx.message:fragment({ "fa.ui-blueprints-import-failed" })
            end
         else
            ctx.message:fragment({ "fa.ui-blueprints-import-cancelled" })
         end
      end,
   })

   return builder:build()
end

mod.blueprint_menu_tabs = TabList.declare_tablist({
   ui_name = UiRouter.UI_NAMES.BLUEPRINT,
   tabs_callback = Functools.functionize({
      {
         name = "main",
         tabs = {
            UiKeyGraph.declare_graph({
               name = "blueprints-menu",
               render_callback = render,
               title = { "fa.ui-blueprints-menu-title" },
            }),
         },
      },
   }),
})

-- Register with the UI event routing system for event interception
UiRouter.register_ui(mod.blueprint_menu_tabs)

return mod
