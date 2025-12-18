--[[
Blueprint area selector.

This is the raw box selector for blueprint area selection.
It returns the selected box via close_with_result.
The parent UI (blueprint-setup.lua) handles the result.
]]

local BoxSelector = require("scripts.ui.box-selector")
local UiRouter = require("scripts.ui.router")

local mod = {}

-- Register box selector for blueprint area selection (no callback - parent handles result)
mod.blueprint_area_selector = BoxSelector.declare_box_selector({
   ui_name = UiRouter.UI_NAMES.BLUEPRINT_AREA_SELECTOR,
})

UiRouter.register_ui(mod.blueprint_area_selector)

return mod
