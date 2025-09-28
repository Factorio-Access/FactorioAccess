--[[
A box selector.

The player selects two points and we return them Note that this *DOES* mean that the second point = the first point if
the player didn't move the cursor, and that in effect from the player's perspective this box includes the second point.
]]
local StorageManager = require("scripts.storage-manager")
local Viewpoint = require("scripts.viewpoint")
local Speech = require("scripts.speech")
local serpent = require("serpent")

local mod = {}

---@class fa.ui.BoxSelectorDeclaration
---@field ui_name fa.ui.UiName
---@field callback? fun(pindex: number, params: table, result: table) Optional callback when selection completes

---@class fa.ui.BoxSelectorState
---@field first_click? {x: number, y: number, modifiers: table, is_right_click: boolean}
---@field callback_params table

---@type table<number, table<string, fa.ui.BoxSelectorState>>
local box_selector_storage = StorageManager.declare_storage_module("box_selector", {}, {
   ephemeral_state_version = 1,
})

---@class fa.ui.BoxSelector : fa.ui.UiPanelBase
---@field callback? fun(pindex: number, params: table, result: table)
---@field declaration fa.ui.BoxSelectorDeclaration
local BoxSelector = {}
local BoxSelector_meta = { __index = BoxSelector }

function BoxSelector:open(pindex, parameters, controller)
   -- Always reinitialize state on open
   box_selector_storage[pindex][self.ui_name] = {
      first_click = parameters and parameters.first_point or nil,
      callback_params = parameters or {},
   }

   -- Build message combining intro and second message if both provided
   local message = Speech.new()

   -- Use intro message
   local intro_msg = (parameters and parameters.intro_message) or { "fa.box-selector-intro" }
   message:fragment(intro_msg)

   -- If second message provided, add it
   if parameters and parameters.second_message then message:fragment(parameters.second_message) end

   Speech.speak(pindex, message:build())
end

function BoxSelector:close(pindex)
   if box_selector_storage[pindex][self.ui_name] then
      box_selector_storage[pindex][self.ui_name].first_click = nil
      box_selector_storage[pindex][self.ui_name].callback_params = nil
   end
end

function BoxSelector:on_click(pindex, modifiers, controller)
   self:_handle_click(pindex, modifiers, false, controller)
end

function BoxSelector:on_right_click(pindex, modifiers, controller)
   self:_handle_click(pindex, modifiers, true, controller)
end

---Handle child result - not used for BoxSelector but needed for interface
function BoxSelector:on_child_result(pindex, result_context, result, controller)
   -- BoxSelector doesn't have children, so this is empty
end

function BoxSelector:_handle_click(pindex, modifiers, is_right_click, controller)
   local viewpoint = Viewpoint.get_viewpoint(pindex)
   local cursor_pos = viewpoint:get_cursor_pos()
   local state = box_selector_storage[pindex][self.ui_name]

   if not state.first_click then
      -- First click
      state.first_click = {
         x = cursor_pos.x,
         y = cursor_pos.y,
         modifiers = modifiers or {},
         is_right_click = is_right_click,
      }
      -- Speak second point message, including custom second_message if provided
      local second_message = (state.callback_params and state.callback_params.second_message)
         or { "fa.box-selector-second-point" }
      Speech.speak(pindex, second_message)
   else
      -- Second click - complete selection
      local result = {
         first_click = state.first_click,
         second_click = {
            x = cursor_pos.x,
            y = cursor_pos.y,
            modifiers = modifiers or {},
            is_right_click = is_right_click,
         },
         box = {
            left_top = {
               x = math.min(state.first_click.x, cursor_pos.x),
               y = math.min(state.first_click.y, cursor_pos.y),
            },
            right_bottom = {
               x = math.max(state.first_click.x, cursor_pos.x),
               y = math.max(state.first_click.y, cursor_pos.y),
            },
         },
         controller = controller,
      }

      -- Execute callback if provided
      if self.callback then self.callback(pindex, state.callback_params, result) end

      -- Close with result
      controller:close_with_result(result)
   end
end

---@param declaration fa.ui.BoxSelectorDeclaration
---@return fa.ui.BoxSelector
function mod.declare_box_selector(declaration)
   assert(declaration.ui_name, "BoxSelector declaration must have ui_name")

   ---@type fa.ui.BoxSelector
   local ret = setmetatable({
      ui_name = declaration.ui_name,
      callback = declaration.callback, -- Optional
      declaration = declaration,
   }, BoxSelector_meta)

   return ret
end

return mod
