--[[
Module for managing the game GUI elements - frames and textboxes.
This provides a centralized way to show UI indicators and collect text input.
]]

local StorageManager = require("scripts.storage-manager")

local mod = {}

---@class fa.ui.GameGuiState
---@field ui_frame LuaGuiElement?
---@field ui_label LuaGuiElement?
---@field textbox_element LuaGuiElement?
---@field active_ui_name string?
---@field textbox_result_context table? { ui_name: string, context: any }

---@type table<number, fa.ui.GameGuiState>
local gui_storage = StorageManager.declare_storage_module("game_gui", {
   ui_frame = nil,
   ui_label = nil,
   textbox_element = nil,
   active_ui_name = nil,
   textbox_result_context = nil,
})

---Cleanup any invalid GUI elements
---@param pindex number
local function cleanup_invalid_elements(pindex)
   local state = gui_storage[pindex]
   if state.ui_frame and not state.ui_frame.valid then
      state.ui_frame = nil
      state.ui_label = nil
   end
   if state.textbox_element and not state.textbox_element.valid then
      state.textbox_element = nil
      state.textbox_result_context = nil
   end
end

---Ensure the UI frame exists and is valid
---@param pindex number
---@return LuaGuiElement
local function ensure_frame_exists(pindex)
   local state = gui_storage[pindex]
   local player = game.get_player(pindex)
   if not player then error("Invalid player index") end

   cleanup_invalid_elements(pindex)

   if not state.ui_frame or not state.ui_frame.valid then
      -- Create the frame
      state.ui_frame = player.gui.screen.add({
         type = "frame",
         name = "fa-gui-indicator",
         direction = "vertical",
      })
      state.ui_frame.force_auto_center()
      state.ui_frame.bring_to_front()

      -- Create the label
      state.ui_label = state.ui_frame.add({
         type = "label",
         caption = "",
      })
   end

   return state.ui_frame
end

---Set the active UI, creating or updating the GUI frame
---@param pindex number
---@param ui_name string?
function mod.set_active_ui(pindex, ui_name)
   local state = gui_storage[pindex]

   if not ui_name then
      mod.clear_active_ui(pindex)
      return
   end

   ensure_frame_exists(pindex)
   state.active_ui_name = ui_name

   -- Update the label with the UI name
   if state.ui_label and state.ui_label.valid then
      -- For now, just show the UI name. Could be localized later.
      state.ui_label.caption = ui_name
   end

   if state.ui_frame and state.ui_frame.valid then
      state.ui_frame.visible = true
      state.ui_frame.bring_to_front()
   end
end

---Clear the active UI, destroying the GUI frame
---@param pindex number
function mod.clear_active_ui(pindex)
   local state = gui_storage[pindex]

   if state.ui_frame and state.ui_frame.valid then state.ui_frame.destroy() end

   state.ui_frame = nil
   state.ui_label = nil
   state.textbox_element = nil
   state.active_ui_name = nil
   state.textbox_result_context = nil
end

---Open a textbox for user input
---@param pindex number
---@param initial_text string
---@param result_context table { ui_name: string, context: any }
function mod.open_textbox(pindex, initial_text, result_context)
   local state = gui_storage[pindex]

   if not state.active_ui_name then error("Cannot open textbox without an active UI") end

   -- Ensure frame exists
   local frame = ensure_frame_exists(pindex)

   -- Clean up any existing textbox
   if state.textbox_element and state.textbox_element.valid then state.textbox_element.destroy() end

   -- Create the textbox
   state.textbox_element = frame.add({
      type = "textfield",
      name = "fa-text-input",
      text = initial_text or "",
   })
   state.textbox_element.focus()
   state.textbox_element.select_all()

   -- Store the result context
   state.textbox_result_context = result_context
end

---Close the textbox
---@param pindex number
function mod.close_textbox(pindex)
   local state = gui_storage[pindex]

   if state.textbox_element and state.textbox_element.valid then state.textbox_element.destroy() end

   state.textbox_element = nil
   state.textbox_result_context = nil
end

---Get the stored result context for the textbox
---@param pindex number
---@return table? { ui_name: string, context: any }
function mod.get_textbox_result_context(pindex)
   return gui_storage[pindex].textbox_result_context
end

---Check if a textbox is open
---@param pindex number
---@return boolean
function mod.is_textbox_open(pindex)
   local state = gui_storage[pindex]
   return state.textbox_element and state.textbox_element.valid
end

return mod
