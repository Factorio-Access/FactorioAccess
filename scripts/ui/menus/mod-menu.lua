--[[
The mod menu, on Alt+M: a list of the mod's less frequently used UIs, each opened as a child.
]]

local TabList = require("scripts.ui.tab-list")
local UiRouter = require("scripts.ui.router")
local Menu = require("scripts.ui.menu")
local KeyGraph = require("scripts.ui.key-graph")

local mod = {}

---@class fa.ui.ModMenuEntry
---@field ui_name fa.ui.UiName
---@field label LocalisedString
---@field available (fun(pindex: integer): boolean)? Shown only when this returns true

---@type fa.ui.ModMenuEntry[]
local ENTRIES = {
   { ui_name = UiRouter.UI_NAMES.SETTINGS, label = { "fa.settings-menu-title" } },
   { ui_name = UiRouter.UI_NAMES.SURFACE_INFO, label = { "fa.surface-info-title" } },
   {
      ui_name = UiRouter.UI_NAMES.SPACE_MAP,
      label = { "fa.space-map-title" },
      available = function()
         return script.feature_flags.space_travel
      end,
   },
   {
      ui_name = UiRouter.UI_NAMES.SPACE_PLATFORMS,
      label = { "gui-space-platforms.title" },
      available = function()
         return script.feature_flags.space_travel
      end,
   },
}

---@param ctx fa.ui.graph.Ctx
local function build_mod_menu(ctx)
   local builder = Menu.MenuBuilder.new()

   for _, entry in ipairs(ENTRIES) do
      if not entry.available or entry.available(ctx.pindex) then
         builder:add_clickable(entry.ui_name, entry.label, {
            on_click = function(click_ctx)
               click_ctx.controller:open_child_ui(entry.ui_name)
            end,
         })
      end
   end

   return builder:build()
end

local mod_menu_tab = KeyGraph.declare_graph({
   name = "mod_menu",
   render_callback = build_mod_menu,
   title = { "fa.mod-menu-title" },
})

mod.mod_menu = TabList.declare_tablist({
   ui_name = UiRouter.UI_NAMES.MOD_MENU,
   resets_to_first_tab_on_open = true,
   tabs_callback = function()
      return {
         {
            name = "mod_menu",
            tabs = { mod_menu_tab },
         },
      }
   end,
})

UiRouter.register_ui(mod.mod_menu)

return mod
