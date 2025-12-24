--[[
A multipoint selector for selecting one or more points on the map.

Supports advanced cursor navigation while selecting points, and can be used for fast travel, waypoints, etc.
]]
local StorageManager = require("scripts.storage-manager")
local Viewpoint = require("scripts.viewpoint")
local EntitySelection = require("scripts.entity-selection")
local Speech = require("scripts.speech")
local MessageBuilder = Speech.MessageBuilder

local mod = {}

---@enum fa.ui.selectors.MultipointSelectionKind
mod.SELECTION_KIND = {
   LEFT = 1,
   RIGHT = 2,
}

---@enum fa.ui.selectors.MultipointResultKind
mod.RESULT_KIND = {
   KEEP_GOING = 1,
   STOP = 2,
   STOP_ALREADY_CLOSED = 3, -- Callback already called close_with_result, don't close again
}

---@class fa.ui.selectors.MultipointSelectorDeclaration
---@field ui_name fa.ui.UiName
---@field intro_message LocalisedString Message to say when selector opens
---@field point_selected_callback fun(callback_args: fa.ui.selectors.MultipointCallbackArgs): fa.ui.selectors.MultipointCallbackResult
---@field get_binds? fun(pindex: number, parameters: table): fa.ui.Bind[]? Optional bind callback

---@class fa.ui.selectors.MultipointCallbackArgs
---@field kind fa.ui.selectors.MultipointSelectionKind LEFT or RIGHT click
---@field position MapPosition The position that was selected
---@field entity LuaEntity? The entity at the cursor position (nil if none)
---@field modifiers {control: boolean?, shift: boolean?, alt: boolean?} Modifier keys pressed
---@field router_ctx fa.ui.RouterController Router controller for messaging
---@field state table Arbitrary state maintained for the callback
---@field parameters table Parameters passed when opening the selector

---@class fa.ui.selectors.MultipointCallbackResult
---@field result_kind fa.ui.selectors.MultipointResultKind KEEP_GOING or STOP

---@class fa.ui.selectors.MultipointSelectorState
---@field callback_params table
---@field state any Arbitrary state maintained by the callback

---@type table<number, table<string, fa.ui.selectors.MultipointSelectorState>>
local multipoint_selector_storage = StorageManager.declare_storage_module("multipoint_selector", {}, {
   ephemeral_state_version = 1,
})

---@class fa.ui.selectors.MultipointSelector : fa.ui.UiPanelBase
---@field declaration fa.ui.selectors.MultipointSelectorDeclaration
local MultipointSelector = {}
local MultipointSelector_meta = { __index = MultipointSelector }

function MultipointSelector:open(pindex, parameters, controller)
   -- Initialize state on open
   multipoint_selector_storage[pindex][self.ui_name] = {
      callback_params = parameters or {},
      state = {},
   }

   -- Speak intro message (allow parameters to override)
   local intro = (parameters and parameters.intro_message) or self.declaration.intro_message
   controller.message:fragment(intro)

   -- If initial_point provided, call the callback immediately with it
   if parameters and parameters.first_point then
      -- Get entity at initial point if any
      local entity = EntitySelection.get_first_ent_at_tile(pindex)

      local callback_args = {
         kind = mod.SELECTION_KIND.LEFT,
         position = parameters.first_point,
         entity = entity,
         modifiers = {},
         router_ctx = controller,
         state = multipoint_selector_storage[pindex][self.ui_name].state,
         parameters = parameters,
      }

      local result = self.declaration.point_selected_callback(callback_args)

      -- If callback says to stop immediately, close
      if result.result_kind == mod.RESULT_KIND.STOP then controller:close() end
   end
end

function MultipointSelector:close(pindex)
   multipoint_selector_storage[pindex][self.ui_name] = nil
end

function MultipointSelector:is_overlay()
   return true
end

function MultipointSelector:get_binds(pindex, parameters)
   if self.declaration.get_binds then return self.declaration.get_binds(pindex, parameters) end
   return {} -- No binds, but valid state
end

function MultipointSelector:on_click(pindex, modifiers, controller)
   self:_handle_click(pindex, modifiers, mod.SELECTION_KIND.LEFT, controller)
end

function MultipointSelector:on_right_click(pindex, modifiers, controller)
   self:_handle_click(pindex, modifiers, mod.SELECTION_KIND.RIGHT, controller)
end

---Announce the intro message
function MultipointSelector:on_announce_title(pindex, modifiers, controller)
   controller.message:fragment(self.declaration.intro_message)
end

---@param controller fa.ui.RouterController
function MultipointSelector:_handle_click(pindex, modifiers, kind, controller)
   local viewpoint = Viewpoint.get_viewpoint(pindex)
   local cursor_pos = viewpoint:get_cursor_pos()
   local entity = EntitySelection.get_first_ent_at_tile(pindex)
   local state = multipoint_selector_storage[pindex][self.ui_name]

   -- Prepare callback arguments
   local callback_args = {
      kind = kind,
      position = cursor_pos,
      entity = entity,
      modifiers = modifiers or {},
      router_ctx = controller,
      state = state.state,
      parameters = state.callback_params,
   }

   -- Call the callback
   local result = self.declaration.point_selected_callback(callback_args)

   -- Handle result
   if result.result_kind == mod.RESULT_KIND.STOP then controller:close() end
   -- If KEEP_GOING, do nothing - stay in selection mode
end

---@param declaration fa.ui.selectors.MultipointSelectorDeclaration
---@return fa.ui.selectors.MultipointSelector
function mod.declare_multipoint_selector(declaration)
   assert(declaration.ui_name, "MultipointSelector declaration must have ui_name")
   assert(declaration.intro_message, "MultipointSelector declaration must have intro_message")
   assert(declaration.point_selected_callback, "MultipointSelector declaration must have point_selected_callback")

   ---@type fa.ui.selectors.MultipointSelector
   local ret = setmetatable({
      ui_name = declaration.ui_name,
      declaration = declaration,
   }, MultipointSelector_meta)

   return ret
end

return mod
