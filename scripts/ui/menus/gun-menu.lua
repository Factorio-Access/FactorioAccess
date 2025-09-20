--[[
Gun menu UI using the new TabList/Grid system.
Provides a 3x2 grid interface for managing weapon and ammo slots.
]]

local Equipment = require("scripts.equipment")
local Grid = require("scripts.ui.grid")
local Localising = require("scripts.localising")
local Speech = require("scripts.speech")
local TabList = require("scripts.ui.tab-list")
local UiKeyGraph = require("scripts.ui.key-graph")
local UiRouter = require("scripts.ui.router")
local UiSounds = require("scripts.ui.sounds")

local mod = {}

---@class fa.ui.GunMenu.SharedState
-- For now there are none, just empty table.

---@class fa.ui.GunMenu.Parameters
---Empty for now, but available for future extensions

---@class fa.ui.GunMenu.Context: fa.ui.graph.Ctx
---@field parameters fa.ui.GunMenu.Parameters
---@field tablist_shared_state fa.ui.GunMenu.SharedState

---Shared state setup function
---@param pindex number
---@param params fa.ui.GunMenu.Parameters
---@return fa.ui.GunMenu.SharedState
local function state_setup(pindex, params)
   return {}
end

---Handle clicking on a gun or ammo slot
---@param ctx fa.ui.GunMenu.Context
---@param slot_index number
---@param is_ammo boolean
local function handle_slot_click(ctx, slot_index, is_ammo)
   local player = game.get_player(ctx.pindex)
   local cursor_stack = player.cursor_stack
   local gun_inv = player.get_inventory(defines.inventory.character_guns)
   local ammo_inv = player.get_inventory(defines.inventory.character_ammo)
   local target_stack = is_ammo and ammo_inv[slot_index] or gun_inv[slot_index]

   -- Play inventory click sound
   UiSounds.play_inventory_click(ctx.pindex)

   if cursor_stack and cursor_stack.valid_for_read then
      -- Hand has item - validate and swap
      local item_type = cursor_stack.type
      if is_ammo and item_type ~= "ammo" then
         Speech.speak(ctx.pindex, { "fa.equipment-error-ammo-only" })
         return
      elseif not is_ammo and item_type ~= "gun" then
         Speech.speak(ctx.pindex, { "fa.equipment-error-gun-only" })
         return
      end

      -- Try to swap
      if target_stack then
         cursor_stack.swap_stack(target_stack)
         -- If swap failed, it means incompatible item
         if cursor_stack.valid_for_read and cursor_stack.name == target_stack.name then
            Speech.speak(ctx.pindex, { "fa.equipment-error-incompatible" })
         end
      end
   else
      -- Empty hand - pick up item
      if target_stack and target_stack.valid_for_read then
         cursor_stack.swap_stack(target_stack)
      else
         Speech.speak(ctx.pindex, { "fa.equipment-no-action" })
      end
   end
end

---Handle right-clicking on a gun or ammo slot (split stack)
---@param ctx fa.ui.GunMenu.Context
---@param slot_index number
---@param is_ammo boolean
local function handle_slot_right_click(ctx, slot_index, is_ammo)
   local player = game.get_player(ctx.pindex)
   local cursor_stack = player.cursor_stack
   local gun_inv = player.get_inventory(defines.inventory.character_guns)
   local ammo_inv = player.get_inventory(defines.inventory.character_ammo)
   local target_stack = is_ammo and ammo_inv[slot_index] or gun_inv[slot_index]

   -- Play inventory click sound
   UiSounds.play_inventory_click(ctx.pindex)

   if cursor_stack and target_stack then
      if cursor_stack.valid_for_read and not target_stack.valid_for_read then
         -- Cursor has items, slot is empty - transfer half
         local item_type = cursor_stack.type
         if (is_ammo and item_type ~= "ammo") or (not is_ammo and item_type ~= "gun") then
            Speech.speak(
               ctx.pindex,
               is_ammo and { "fa.equipment-error-ammo-only" } or { "fa.equipment-error-gun-only" }
            )
            return
         end

         local half = math.floor(cursor_stack.count / 2)
         if half > 0 then
            target_stack.set_stack({ name = cursor_stack.name, count = half, quality = cursor_stack.quality })
            cursor_stack.count = cursor_stack.count - half
            Speech.speak(ctx.pindex, { "fa.placed-stuff", { "fa.half-stack" } })
         end
      elseif not cursor_stack.valid_for_read and target_stack.valid_for_read then
         -- Cursor is empty, slot has items - take half
         local half = math.floor(target_stack.count / 2)
         if half > 0 then
            cursor_stack.set_stack({ name = target_stack.name, count = half, quality = target_stack.quality })
            target_stack.count = target_stack.count - half
            local item_description = Localising.localise_item({
               name = cursor_stack.name,
               count = cursor_stack.count,
               quality = cursor_stack.quality and cursor_stack.quality.name or nil,
            })
            Speech.speak(ctx.pindex, { "fa.grabbed-stuff", item_description })
         end
      else
         -- Both have items or both empty - just swap
         handle_slot_click(ctx, slot_index, is_ammo)
      end
   end
end

---Main render function for the gun grid
---@param ctx fa.ui.GunMenu.Context
---@return fa.ui.graph.Render?
local function render_gun_grid(ctx)
   local player = game.get_player(ctx.pindex)
   if not player then return nil end

   local gun_inv = player.get_inventory(defines.inventory.character_guns)
   local ammo_inv = player.get_inventory(defines.inventory.character_ammo)
   if not gun_inv or not ammo_inv then return nil end

   local builder = Grid.grid_builder()

   builder:set_dimension_labeler(function(ctx, x, y)
      if y == 1 then
         ctx.message:fragment({ "fa.gun-slot", tostring(x) })
      else
         ctx.message:fragment({ "fa.ammo-slot", tostring(x) })
      end
   end)

   -- Build 3x2 grid
   for slot = 1, 3 do
      local gun_stack = gun_inv[slot]
      local ammo_stack = ammo_inv[slot]

      -- Row 1: Gun slots
      builder:add_control(slot, 1, function(label_ctx)
         -- Build gun slot label inline
         local gun_label = gun_stack and gun_stack.valid_for_read and Localising.localise_item(gun_stack)
            or { "fa.equipment-empty-gun-slot" }

         -- Add ammo info
         if ammo_stack and ammo_stack.valid_for_read then
            local ammo_label = Localising.localise_item(ammo_stack)
            label_ctx.message:fragment({ "fa.gun-menu-gun-using-ammo", gun_label, ammo_label })
         else
            label_ctx.message:fragment({ "fa.gun-menu-gun-no-ammo", gun_label })
         end
      end, {
         on_click = function(click_ctx)
            handle_slot_click(click_ctx, slot, false)
         end,
         on_right_click = function(click_ctx)
            handle_slot_right_click(click_ctx, slot, false)
         end,
         on_read_coords = function(coord_ctx)
            coord_ctx.message:fragment({ "fa.gun-slot", tostring(slot) })
         end,
      })

      -- Row 2: Ammo slots
      builder:add_control(slot, 2, function(label_ctx)
         -- Build ammo slot label inline
         local ammo_label = ammo_stack and ammo_stack.valid_for_read and Localising.localise_item(ammo_stack)
            or { "fa.equipment-empty-ammo-slot" }

         local gun_label = gun_stack and gun_stack.valid_for_read and Localising.localise_item(gun_stack)
            or { "fa.equipment-empty-gun-slot" }

         label_ctx.message:fragment({ "fa.gun-menu-ammo-for-gun", ammo_label, gun_label })
      end, {
         on_click = function(click_ctx)
            handle_slot_click(click_ctx, slot, true)
         end,
         on_right_click = function(click_ctx)
            handle_slot_right_click(click_ctx, slot, true)
         end,
         on_read_coords = function(coord_ctx)
            coord_ctx.message:fragment({ "fa.ammo-slot", tostring(slot) })
         end,
      })
   end

   return builder:build()
end

-- Export the gun tab for use in the main menu
mod.gun_tab = UiKeyGraph.declare_graph({
   name = "guns",
   title = { "fa.guns-and-ammo" },
   render_callback = render_gun_grid,
})

-- Add a state setup callback to ensure we have the inventories
mod.gun_tab.callbacks = mod.gun_tab.callbacks or {}
mod.gun_tab.callbacks.state_setup = function(ctx)
   return state_setup(ctx.pindex, {})
end

-- Legacy TabList for backward compatibility (can be removed later)
mod.gun_menu = TabList.declare_tablist({
   ui_name = UiRouter.UI_NAMES.GUNS,
   resets_to_first_tab_on_open = true,
   shared_state_setup = state_setup,
   tabs = {
      mod.gun_tab,
   },
})

-- Register with the UI event routing system for event interception
local UiEventRouting = require("scripts.ui.event-routing")
UiEventRouting.register_ui(mod.gun_menu)

return mod
