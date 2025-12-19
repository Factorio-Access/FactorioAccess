local TabList = require("scripts.ui.tab-list")
local UiRouter = require("scripts.ui.router")
local KeyGraph = require("scripts.ui.key-graph")
local FormBuilder = require("scripts.ui.form-builder")
local setting_decls = require("scripts.settings-decls")

local mod = {}

---@param ctx fa.ui.graph.Ctx
local function build_settings_menu(ctx)
   local builder = FormBuilder.FormBuilder.new()

   for _, decl in ipairs(setting_decls.declarations) do
      local name = decl.name

      if decl.type == "bool-setting" then
         builder:add_checkbox(name, { "mod-setting-name." .. name }, function()
            return settings.global[name].value --[[@as boolean]]
         end, function(value)
            settings.global[name] = { value = value }
         end)
      end
      -- Future: add int/string/double handling
   end

   return builder:build()
end

local settings_menu_tab = KeyGraph.declare_graph({
   name = "settings_menu",
   render_callback = build_settings_menu,
   title = { "fa.settings-menu-title" },
})

mod.settings_menu = TabList.declare_tablist({
   ui_name = UiRouter.UI_NAMES.SETTINGS,
   resets_to_first_tab_on_open = true,
   tabs_callback = function()
      return {
         {
            name = "settings",
            tabs = { settings_menu_tab },
         },
      }
   end,
})

UiRouter.register_ui(mod.settings_menu)

return mod
