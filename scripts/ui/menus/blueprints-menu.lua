local Blueprints = require("scripts.blueprints")
local FaUtils = require("scripts.fa-utils")
local Functools = require("scripts.functools")
local Graphics = require("scripts.graphics")
local Localising = require("scripts.localising")
local TH = require("scripts.table-helpers")
local UiKeyGraph = require("scripts.ui.key-graph")
local Menu = require("scripts.ui.menu")
local UiRouter = require("scripts.ui.router")
local TabList = require("scripts.ui.tab-list")

local mod = {}

---@type fun(fa.ui.graph.Ctx): fa.ui.graph.Render?
local function render(ctx)
   local p = game.get_player(ctx.pindex)
   if not p then return nil end

   ---@type LuaItemStack
   local bp = p.cursor_stack
   if not bp.is_blueprint then return nil end

   local builder = Menu.MenuBuilder.new()

   -- In the below note that it is long-standing mod behavior to close menus
   -- after text boxes close.  That's unfortunate, but we'll keep doing that for
   -- now as we flesh out our gui story.

   if not bp.is_blueprint_setup() then
      builder:add_label("blueprint-info", { "fa.ui-blueprints-menu-limited" })
   else
      builder:add_label("blueprint-info", { "fa.ui-blueprints-menu-basic", Blueprints.get_blueprint_label(bp) })
   end

   -- Blueprints which are empty can't have descriptions; don't show it.
   if bp.is_blueprint_setup then
      builder:add_label("description", function(ctx)
         ctx.message:fragment({ "fa.ui-blueprints-menu-description", Blueprints.get_blueprint_description(bp) })
      end)

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
         local width, height = Blueprints.get_blueprint_width_and_height(ctx.pindex)
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

      builder:add_clickable("rename", { "fa.ui-blueprints-menu-rename" }, {
         on_click = function(ctx)
            storage.players[ctx.pindex].blueprint_menu.edit_label = true
            Graphics.create_text_field_frame(ctx.pindex, "blueprint-edit-label")
            ctx.message:fragment({ "fa.ui-blueprints-rename-txtbox" })
            ctx.controller:close()
         end,
      })

      builder:add_clickable("edit-desc", { "fa.ui-blueprints-menu-edit-desc" }, {
         on_click = function(ctx)
            storage.players[ctx.pindex].blueprint_menu.edit_description = true
            Graphics.create_text_field_frame(ctx.pindex, "blueprint-edit-description")
            ctx.message:fragment({ "fa.ui-blueprints-description-txtbox" })
            ctx.controller:close()
         end,
      })

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

      builder:add_clickable("export", { "fa.ui-blueprints-menu-export" }, {
         on_click = function(ctx)
            storage.players[ctx.pindex].blueprint_menu.edit_export = true
            Graphics.create_text_field_frame(ctx.pindex, "blueprint-edit-export", bp.export_stack())
            ctx.message:fragment({ "fa.ui-blueprints-export-txtbox" })
            ctx.controller:close()
         end,
      })
   end

   builder:add_clickable("import", { "fa.ui-blueprints-menu-import" }, {
      on_click = function(ctx)
         -- For now, this shells out to legacy UI: close ourselves, and let it
         -- do the work.
         storage.players[ctx.pindex].blueprint_menu.edit_import = true
         Graphics.create_text_field_frame(ctx.pindex, "blueprint-edit-import")
         ctx.message:fragment({ "fa.ui-blueprints-import-txtbox" })
         ctx.controller:close()
      end,
   })

   builder:add_clickable("reselect", { "fa.ui-blueprints-menu-reselect" }, {
      on_click = function(ctx)
         storage.players[ctx.pindex].blueprint_reselecting = true
         ctx.message:fragment({ "fa.ui-blueprints-select-first-point" })
         ctx.controller:close()
      end,
   })
   return builder:build()
end

mod.blueprint_menu_tabs = TabList.declare_tablist({
   ui_name = UiRouter.UI_NAMES.BLUEPRINT,
   tabs_callback = Functools.functionize({
      UiKeyGraph.declare_graph({
         name = "blueprints-menu",
         render_callback = render,
         title = { "fa.ui-blueprints-menu-title" },
      }),
   }),
})

-- Register with the UI event routing system for event interception
UiRouter.register_ui(mod.blueprint_menu_tabs)

return mod
