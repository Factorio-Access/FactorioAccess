local ustate = require("scripts.ui.global-state")

local mod = {}

-- These are the names of the panels one can open.
mod.fast_travel_panel_name = require("ui/flows/fast-travel").panel_name

mod.is_open = ustate.is_open

-- These reexports are for integrating into the event handlers.  See
-- global-state.lua for docs.
mod.evt_left = ustate.evt_left
mod.evt_right = ustate.evt_right
mod.evt_up = ustate.evt_up
mod.evt_down = ustate.evt_down
mod.evt_left_click = ustate.evt_left_click
mod.evt_right_click = ustate.evt_right_click
mod.evt_tab_forward = ustate.evt_tab_forward
mod.evt_tab_backward = ustate.evt_tab_backwarde

return mod
