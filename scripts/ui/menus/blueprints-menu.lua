local Menu = require("scripts.ui.menu")
local MenuItems = require("scripts.ui.menu-items")
local TabList = require("scripts.ui.tab-list")
local Functools = require("scripts.functools")
local Graphics = require("scripts.graphics")

local mod = {}

local function state(ctx)
   -- We don't use this; it relies on the blueprint in hand.
   return {}
end

---@type fun(fa.MenuCtx): fa.MenuRender?
local function render(ctx)
   local p = game.get_player(pindex)
   if not p then return nil end

   ---@type LuaItemStack
   local bp = p.cursor_stack
   if not bp.is_blueprint then return nil end

   local menu_items = {}

   if not bp.is_blueprint_setup() then
      table.insert(menu_items, MenuItems.make_label("blueprint-not-imported", { "fa.ui-blueprints-menu-limited" }))
   end

   table.insert(
      menu_items,
      MenuItems.clickable_label("import", { "fa.ui-blueprints-menu-import" }, function(ctx)
         -- For now, this shells out to legacy UI: close ourselves, and let it
         -- do the work.
         state.players[pindex].blueprint_menu.edit_import = true
         local frame = Graphics.create_text_field_frame(pindex, "blueprint-edit-import")
      end)
   )

   return {
      items = menu_items,
   }
end

mod.blueprint_menu_tabs = TabList.declare_tablist({
   menu_name = "blueprint_menu",
   tabs = {
      Menu.declare_menu({
         tab_name = "blueprints",
         title = { "fa.ui-blueprints-menu-title" },
         render_callback = render,
         state_callback = Functools.functionize({}),
      }),
   },
})

return mod
