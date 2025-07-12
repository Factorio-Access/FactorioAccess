--[[
Gun menu functionality for managing weapon and ammo slots.
This module provides a UI for players to manage their gun and ammo inventories.
]]

local StorageManager = require("scripts.storage-manager")
local Speech = require("scripts.speech")
local UiRouter = require("scripts.ui.router")
local localising = require("scripts.localising")
local Math2 = require("math-helpers")
local Sounds = require("scripts.ui.sounds")

local mod = {}

---@class fa.GunMenuState
---@field index number The current slot index (1-3)
---@field ammo_selected boolean Whether the ammo slot is selected (vs gun slot)

---@type table<number, fa.GunMenuState>
local gun_menu_storage = StorageManager.declare_storage_module("guns_menu", {
   index = 1,
   ammo_selected = false,
})

function mod.open(pindex)
   local router = UiRouter.get_router(pindex)

   router:open_ui(UiRouter.UI_NAMES.GUNS)
   mod.read_slot(pindex, "Guns and ammo, ")
end

---Navigate left or right through gun/ammo slots
---@param pindex number
---@param direction number -1 for left, 1 for right
local function navigate_horizontal(pindex, direction)
   local state = gun_menu_storage[pindex]
   local new_index = Math2.mod1(state.index + direction, 3)

   gun_menu_storage[pindex].index = new_index

   -- Check if we wrapped around
   local wrapped = (direction == 1 and new_index == 1) or (direction == -1 and new_index == 3)

   if wrapped then
      Sounds.play_menu_wrap(pindex)
   else
      Sounds.play_menu_move(pindex)
   end

   mod.read_slot(pindex)
end

function mod.left(pindex)
   navigate_horizontal(pindex, -1)
end

function mod.right(pindex)
   navigate_horizontal(pindex, 1)
end

function mod.up_or_down(pindex)
   local state = gun_menu_storage[pindex]
   gun_menu_storage[pindex].ammo_selected = not state.ammo_selected
   Sounds.play_menu_move(pindex)
   mod.read_slot(pindex)
end

function mod.get_selected_slot(pindex)
   local state = gun_menu_storage[pindex]
   local p = game.get_player(pindex)
   local gun_stack = p.get_inventory(defines.inventory.character_guns)[state.index]
   local ammo_stack = p.get_inventory(defines.inventory.character_ammo)[state.index]

   if state.ammo_selected then
      return ammo_stack
   else
      return gun_stack
   end
end

function mod.read_slot(pindex, start_phrase_in)
   local start_phrase = start_phrase_in or ""
   local state = gun_menu_storage[pindex]
   local p = game.get_player(pindex)
   local message = Speech.new()

   if start_phrase ~= "" then message:fragment(start_phrase) end

   local gun_stack = p.get_inventory(defines.inventory.character_guns)[state.index]
   local ammo_stack = p.get_inventory(defines.inventory.character_ammo)[state.index]

   if state.ammo_selected then
      -- Read ammo slot first when selected
      if ammo_stack and ammo_stack.valid_for_read then
         message:fragment(localising.get_localised_name_with_fallback(ammo_stack))
         message:fragment(" x " .. tostring(ammo_stack.count))
      else
         message:fragment({ "fa.equipment-empty-ammo-slot" })
      end
      message:fragment({ "fa.equipment-for" })
      if gun_stack and gun_stack.valid_for_read then
         message:fragment(localising.get_localised_name_with_fallback(gun_stack))
      else
         message:fragment({ "fa.equipment-empty-gun-slot" })
      end
   else
      -- Read gun slot first when selected
      if gun_stack and gun_stack.valid_for_read then
         message:fragment(localising.get_localised_name_with_fallback(gun_stack))
         if gun_stack.count > 1 then message:fragment({ "fa.equipment-times", "", tostring(gun_stack.count) }) end
      else
         message:fragment({ "fa.equipment-empty-gun-slot" })
      end
      message:fragment({ "fa.equipment-using" })
      if ammo_stack and ammo_stack.valid_for_read then
         message:fragment(localising.get_localised_name_with_fallback(ammo_stack))
         message:fragment(" x " .. tostring(ammo_stack.count))
      else
         message:fragment({ "fa.equipment-no-ammo" })
      end
   end

   Speech.speak(pindex, message:build())
end

function mod.click_slot(pindex)
   local p = game.get_player(pindex)
   local hand = p.cursor_stack
   local state = gun_menu_storage[pindex]
   local gun_stack = p.get_inventory(defines.inventory.character_guns)[state.index]
   local ammo_stack = p.get_inventory(defines.inventory.character_ammo)[state.index]
   local selected_stack = nil

   if state.ammo_selected then
      selected_stack = ammo_stack
   else
      selected_stack = gun_stack
   end

   if hand and hand.valid_for_read then
      --Full hand operations
      if not selected_stack or not selected_stack.valid_for_read then
         --Empty slot
         if state.ammo_selected and hand.type ~= "ammo" then
            Speech.speak(pindex, { "fa.equipment-error-ammo-only" })
         elseif not state.ammo_selected and hand.type ~= "gun" then
            Speech.speak(pindex, { "fa.equipment-error-gun-only" })
         else
            if selected_stack ~= nil then hand.swap_stack(selected_stack) end
            --If the swap is successful then the following print statement is overwritten.
            Speech.speak(pindex, { "fa.equipment-error-incompatible" })
         end
      else
         --Full slot
         if state.ammo_selected and hand.type ~= "ammo" then
            Speech.speak(pindex, { "fa.equipment-error-ammo-only" })
         elseif not state.ammo_selected and hand.type ~= "gun" then
            Speech.speak(pindex, { "fa.equipment-error-gun-only" })
         else
            hand.swap_stack(selected_stack)
            --If the swap is successful then the following print statement is overwritten.
            Speech.speak(pindex, { "fa.equipment-error-incompatible" })
         end
      end
   else
      --Empty hand
      if selected_stack and selected_stack.valid_for_read then
         --Pick up the thing
         hand.swap_stack(selected_stack)
      else
         Speech.speak(pindex, { "fa.equipment-no-action" })
      end
   end
end

---Get the current gun menu state for coordinate readout
---@param pindex number
---@return fa.GunMenuState
function mod.get_state(pindex)
   return gun_menu_storage[pindex]
end

return mod
