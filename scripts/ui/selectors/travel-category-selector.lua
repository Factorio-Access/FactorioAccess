--[[
Fast travel category chooser: uncategorized, then every category by name. Returns the name, "" for uncategorized.
Typing a new category's name is the travel menu's own textbox (m), not this.
]]
local OptionsSelector = require("scripts.ui.selectors.options-selector")
local Router = require("scripts.ui.router")
local TravelTools = require("scripts.travel-tools")

local mod = {}

---@param pindex integer
---@return fa.ui.selectors.OptionsResult
local function get_options(pindex)
   local options = { { label = { "fa.travel-uncategorized" }, value = "" } }
   for _, name in ipairs(TravelTools.all_category_names(pindex)) do
      table.insert(options, { label = name, value = name })
   end
   return { options = options }
end

mod.category_selector_ui = OptionsSelector.declare_options_selector({
   ui_name = Router.UI_NAMES.TRAVEL_CATEGORY_SELECTOR,
   title = { "fa.travel-select-category" },
   get_options = get_options,
})

Router.register_ui(mod.category_selector_ui)

return mod
