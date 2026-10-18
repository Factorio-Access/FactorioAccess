--[[
Fast travel category chooser: uncategorized, every category in the player's order, then new category, which asks for a
name. Returns the name, "" for uncategorized.
]]
local KeyGraph = require("scripts.ui.key-graph")
local Menu = require("scripts.ui.menu")
local Router = require("scripts.ui.router")
local TabList = require("scripts.ui.tab-list")
local TravelTools = require("scripts.travel-tools")

local mod = {}

---@param ctx fa.ui.graph.Ctx
---@return fa.ui.graph.Render
local function render(ctx)
   local menu = Menu.MenuBuilder.new()
   menu:add_clickable("uncategorized", { "fa.travel-uncategorized" }, {
      on_click = function(click_ctx)
         click_ctx.controller:close_with_result("")
      end,
   })
   for i, name in ipairs(TravelTools.all_category_names(ctx.pindex)) do
      menu:add_clickable("category-" .. i, name, {
         on_click = function(click_ctx)
            click_ctx.controller:close_with_result(name)
         end,
      })
   end
   menu:add_clickable("new", { "fa.travel-new-category" }, {
      on_click = function(click_ctx)
         click_ctx.controller:open_textbox("", "new", { intro_message = { "fa.travel-enter-category" } })
      end,
      on_child_result = function(click_ctx, result)
         if result and result ~= "" then click_ctx.controller:close_with_result(result) end
      end,
   })
   return menu:build()
end

local graph = KeyGraph.declare_graph({
   name = "travel_category_selector",
   title = { "fa.travel-select-category" },
   render_callback = render,
})

mod.category_selector_ui = TabList.declare_tablist({
   ui_name = Router.UI_NAMES.TRAVEL_CATEGORY_SELECTOR,
   resets_to_first_tab_on_open = true,
   tabs_callback = function()
      return { { name = "selector", tabs = { graph } } }
   end,
})

Router.register_ui(mod.category_selector_ui)

return mod
