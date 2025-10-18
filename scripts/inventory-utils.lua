--[[
Inventory utility functions for transferring items between inventories
]]

local Consts = require("scripts.consts")
local Localising = require("scripts.localising")
local sounds = require("scripts.ui.sounds")

local mod = {}

---@alias fa.InventoryDefineName
---| "agricultural_tower_input"
---| "agricultural_tower_output"
---| "artillery_turret_ammo"
---| "artillery_wagon_ammo"
---| "assembling_machine_dump"
---| "assembling_machine_input"
---| "assembling_machine_modules"
---| "assembling_machine_output"
---| "assembling_machine_trash"
---| "asteroid_collector_arm"
---| "asteroid_collector_output"
---| "beacon_modules"
---| "burnt_result"
---| "car_ammo"
---| "car_trash"
---| "car_trunk"
---| "cargo_landing_pad_main"
---| "cargo_landing_pad_trash"
---| "cargo_unit"
---| "cargo_wagon"
---| "character_ammo"
---| "character_armor"
---| "character_corpse"
---| "character_guns"
---| "character_main"
---| "character_trash"
---| "character_vehicle"
---| "chest"
---| "crafter_input"
---| "crafter_modules"
---| "crafter_output"
---| "crafter_trash"
---| "editor_ammo"
---| "editor_armor"
---| "editor_guns"
---| "editor_main"
---| "fuel"
---| "furnace_modules"
---| "furnace_result"
---| "furnace_source"
---| "furnace_trash"
---| "god_main"
---| "hub_main"
---| "hub_trash"
---| "item_main"
---| "lab_input"
---| "lab_modules"
---| "lab_trash"
---| "linked_container_main"
---| "logistic_container_trash"
---| "mining_drill_modules"
---| "proxy_main"
---| "roboport_material"
---| "roboport_robot"
---| "robot_cargo"
---| "robot_repair"
---| "rocket_silo_input"
---| "rocket_silo_modules"
---| "rocket_silo_output"
---| "rocket_silo_rocket"
---| "rocket_silo_trash"
---| "spider_ammo"
---| "spider_trash"
---| "spider_trunk"
---| "turret_ammo"

---Safely get an inventory from an entity by checking that the name matches
---
---defines.inventory values are not unique, so getting an inventory for a specific entity
---when we don't know what that entity is can return the wrong inventory. This function
---allows doing so safely by taking a stringified defines name and validating that we got
---what we expect.
---@param entity LuaEntity
---@param define_name fa.InventoryDefineName The string name of the inventory define
---@return LuaInventory? inventory The inventory if it exists and matches, nil otherwise
function mod.get_inventory_safe(entity, define_name)
   local def = defines.inventory[define_name]
   assert(def)

   local inv = entity.get_inventory(def)
   if not inv then return nil end

   -- Verify the inventory name matches what we requested
   if inv.name ~= define_name then return nil end

   return inv
end

---Get the first inventory that exists from a priority list
---@param entity LuaEntity
---@param ... fa.InventoryDefineName Inventory define names in priority order
---@return LuaInventory? inventory The first inventory that exists, or nil if none exist
function mod.get_inventory_by_priority(entity, ...)
   local define_names = { ... }
   for _, define_name in ipairs(define_names) do
      local inv = mod.get_inventory_safe(entity, define_name)
      if inv then return inv end
   end
   return nil
end

---Get the main inventory for an entity
---
---Main inventories are the primary storage inventories like chest, car_trunk, character_main, etc.
---This checks all known main inventory types and returns the first one that exists.
---@param entity LuaEntity
---@return LuaInventory? inventory The main inventory if it exists, nil otherwise
function mod.get_main_inventory(entity)
   for _, define_name in ipairs(Consts.MAIN_INVENTORIES) do
      local inv = mod.get_inventory_safe(entity, define_name)
      if inv then return inv end
   end
   return nil
end

---Find the trash inventory for an entity
---
---Checks all possible trash inventory types and returns the first one that exists.
---@param entity LuaEntity
---@return LuaInventory? inventory The trash inventory if it exists, nil otherwise
function mod.find_trash_inventory(entity)
   return mod.get_inventory_by_priority(
      entity,
      "character_trash",
      "car_trash",
      "spider_trash",
      "assembling_machine_trash",
      "cargo_landing_pad_trash",
      "crafter_trash",
      "furnace_trash",
      "hub_trash",
      "lab_trash",
      "logistic_container_trash",
      "rocket_silo_trash"
   )
end

---Quick transfer a stack from source to destination inventory
---@param pindex integer Player index performing the transfer (for sound playback)
---@param msg_builder fa.MessageBuilder Message builder to append transfer results to
---@param src_ent LuaEntity? Source entity (can be player for player inventory)
---@param src_inv_def defines.inventory? Source inventory type
---@param src_slot integer Slot index in source inventory (1-indexed)
---@param dest_ent LuaEntity Destination entity (can be player for player inventory)
---@param dest_inv_def defines.inventory? Destination inventory type
---@param count integer? Optional count to transfer (nil = transfer entire stack)
---@return boolean success Whether the transfer succeeded
function mod.quick_transfer(pindex, msg_builder, src_ent, src_inv_def, src_slot, dest_ent, dest_inv_def, count)
   -- Get source inventory
   local src_inv
   if src_ent and src_ent.valid then
      if src_inv_def then
         src_inv = src_ent.get_inventory(src_inv_def)
      else
         msg_builder:fragment({ "fa.transfer-not-supported" })
         return false
      end
   else
      msg_builder:fragment({ "fa.transfer-no-source" })
      return false
   end

   if not src_inv then
      msg_builder:fragment({ "fa.transfer-no-source-inventory" })
      return false
   end

   -- Get destination inventory
   local dest_inv
   if dest_ent and dest_ent.valid then
      if dest_inv_def then
         dest_inv = dest_ent.get_inventory(dest_inv_def)
      else
         msg_builder:fragment({ "fa.transfer-not-supported" })
         return false
      end
   else
      msg_builder:fragment({ "fa.transfer-no-destination" })
      return false
   end

   if not dest_inv then
      msg_builder:fragment({ "fa.transfer-no-destination-inventory" })
      return false
   end

   -- Get the source stack
   local stack = src_inv[src_slot]
   if not stack or not stack.valid or not stack.valid_for_read then
      msg_builder:fragment({ "fa.transfer-empty-slot" })
      return false
   end

   -- Determine how much to transfer
   local transfer_count = count or stack.count
   if transfer_count > stack.count then transfer_count = stack.count end

   -- Create a transfer stack with the specified count
   local transfer_stack = { name = stack.name, count = transfer_count, quality = stack.quality }

   -- Check if destination can accept the stack
   if not dest_inv.can_insert(transfer_stack) then
      local item_label = Localising.localise_item({
         name = stack.name,
         quality = stack.quality and stack.quality.name or nil,
      })
      msg_builder:fragment({ "fa.transfer-cannot-insert", item_label })
      if dest_ent.type == "character" and dest_inv.count_empty_stacks() == 0 then
         msg_builder:fragment({ "fa.transfer-full-inventory" })
      end
      return false
   end

   -- Perform the transfer
   local item_name = stack.name
   local item_quality = stack.quality and stack.quality.name or nil
   local inserted = dest_inv.insert(transfer_stack)

   if inserted > 0 then
      -- Remove from source
      src_inv.remove({ name = item_name, count = inserted, quality = item_quality })

      -- Play sound for the player performing the transfer
      sounds.play_inventory_move(pindex)

      -- Build success message
      local item_label = Localising.localise_item({
         name = item_name,
         count = inserted,
         quality = item_quality,
      })
      msg_builder:fragment({ "fa.transfer-moved", item_label })

      return true
   else
      msg_builder:fragment({ "fa.transfer-failed" })
      return false
   end
end

return mod
