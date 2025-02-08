local Menu = require("scripts.ui.menu")
local MenuItems = require("scripts.ui.menu-items")
local TabList = require("scripts.ui.tab-list")
local Functools = require("scripts.functools")

local mod = {}

local function state()
   -- We don't use this; it relies on the blueprint in hand.
   return {}
end

---@type fun(fa.MenuCtx): fa.MenuRender
local function render(ctx)
   return {
      items = {
         MenuItems.simple_label("label1", "hello"),
         MenuItems.simple_label("key2", "label 2"),
         MenuItems.simple_label("key3", "more labels"),
      },
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
