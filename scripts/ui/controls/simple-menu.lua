--[[
This menu provides a static unchanging list of items.  Labels may be functions.
If any item is clicked the associated action closure is called.  Think blueprint
action menus.

This does not support rebuilding.
]]

ustate = require("scripts.ui.global-state")
local math_helpers = require("math-helpers")

local mod = {}

-- Returns whether or not the menu should stay open (true for continue, false
--for close).
--- @alias SimpleMenuActionFn fun(pindex: number): boolean

---@class SimpleMenuItem
---@field label LazyString
---@field action SimpleMenuActionFn?
--- @field action_left SimpleMenuActionFn? If present overrides action.
--- @field action_right SimpleMenuActionFn? If present overrides action.

---@class SimpleMenuDescriptor
--- @field items SimpleMenuItem[]

--- @class SimpleMenuGlobalState
--- @field cursor_index number

---@class SimpleMenuOpts
---@field items SimpleMenuItem[]

local simple_menu_vtable = {}

---@param descriptor SimpleMenuDescriptor
---@param state SimpleMenuGlobalState
---@param offset number
local function move_cursor(pindex, state, descriptor, offset)
   if #descriptor.items == 0 then printout("No items", pindex) end

   local nindex = math_helpers.mod1(state.cursor_index, #descriptor.items)
   state.cursor_index = nindex
   printout(ustate.ui_index(pindex, descriptor.items, nindex), pindex)
end

function simple_menu_vtable.evt_up(pindex, state, descriptor)
   move_cursor(pindex, state, descriptor, -1)
end
-- Make a simple menu from options.  Return this from add_control's callback
-- when building controls.
---@param opts SimpleMenuOpts
function mod.new_simple_menu(opts)
   local desc = {
      items = opts.items,
   }

   local global_state = { cursor_index = 1 }

   return { descriptor = desc, global_state = global_state, vtable = simple_menu_vtable }
end

return mod
