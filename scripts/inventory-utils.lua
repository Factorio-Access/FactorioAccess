--[[
Inventory utility functions for transferring items between inventories
]]

local Consts = require("scripts.consts")
local F = require("scripts.field-ref")
local FaUtils = require("scripts.fa-utils")
local ItemInfo = require("scripts.item-info")
local Localising = require("scripts.localising")
local Sounds = require("scripts.ui.sounds")
local Speech = require("scripts.speech")
local TH = require("scripts.table-helpers")

local mod = {}

--------------------------------------------------------------------------------
-- Deductor: Promise-based inventory deduction
--------------------------------------------------------------------------------

---@class fa.InventoryUtils.DeductSource
---@field inventory LuaInventory? The inventory to deduct from (nil = cursor)
---@field name string Item name
---@field count integer Amount to deduct

---@class fa.InventoryUtils.Deductor
---@field private _player LuaPlayer
---@field private _deductions fa.InventoryUtils.DeductSource[]
local Deductor = {}
mod.Deductor = Deductor
local Deductor_meta = { __index = Deductor }

---Create a new deductor for a player
---@param pindex integer
---@return fa.InventoryUtils.Deductor
function Deductor.new(pindex)
   return setmetatable({
      _player = game.get_player(pindex),
      _deductions = {},
   }, Deductor_meta)
end

---Compute where to deduct items from
---@param name string Item prototype name
---@param count integer Amount needed
---@return fa.InventoryUtils.DeductSource[]|nil sources Sources to deduct from, or nil if insufficient
---@private
function Deductor:_compute_deduct(name, count)
   local remaining = count
   local sources = {}

   -- First: try main inventory (from character, not player)
   if self._player.character then
      local main_inv = self._player.character.get_inventory(defines.inventory.character_main)
      if main_inv then
         local available = main_inv.get_item_count(name)
         if available > 0 then
            local take = math.min(available, remaining)
            table.insert(sources, { inventory = main_inv, name = name, count = take })
            remaining = remaining - take
         end
      end
   end

   -- Second: try hand (cursor stack)
   if remaining > 0 then
      local cursor = self._player.cursor_stack
      if cursor and cursor.valid_for_read and cursor.name == name then
         local available = cursor.count
         if available > 0 then
            local take = math.min(available, remaining)
            -- For cursor, we store nil inventory and handle specially in commit
            table.insert(sources, { inventory = nil, name = name, count = take })
            remaining = remaining - take
         end
      end
   end

   if remaining > 0 then return nil end
   return sources
end

---Add a deduction to be performed on commit
---@param name string Item prototype name
---@param count integer Amount to deduct
---@return boolean success True if the deduction can be satisfied
function Deductor:add_deduct(name, count)
   local sources = self:_compute_deduct(name, count)
   if not sources then return false end

   for _, source in ipairs(sources) do
      table.insert(self._deductions, source)
   end
   return true
end

---Commit all recorded deductions
---Crashes if deductions cannot be satisfied (API misuse)
function Deductor:commit()
   for _, deduction in ipairs(self._deductions) do
      if deduction.inventory then
         -- Deduct from inventory
         local removed = deduction.inventory.remove({ name = deduction.name, count = deduction.count })
         assert(removed == deduction.count, "Deductor: failed to remove expected count from inventory")
      else
         -- Deduct from cursor
         local cursor = self._player.cursor_stack
         assert(cursor and cursor.valid_for_read, "Deductor: cursor invalid at commit")
         assert(cursor.name == deduction.name, "Deductor: cursor item changed")
         assert(cursor.count >= deduction.count, "Deductor: cursor count insufficient")
         cursor.count = cursor.count - deduction.count
      end
   end

   self._deductions = {}
end

---Check if this deductor has any pending deductions
---@return boolean
function Deductor:is_empty()
   return #self._deductions == 0
end

---Check if a single item requirement can be satisfied
---@param player LuaPlayer
---@param name string Item prototype name
---@param count integer Amount needed
---@return boolean
local function can_deduct_item(player, name, count)
   local remaining = count

   -- Check main inventory
   if player.character then
      local main_inv = player.character.get_inventory(defines.inventory.character_main)
      if main_inv then
         remaining = remaining - main_inv.get_item_count(name)
         if remaining <= 0 then return true end
      end
   end

   -- Check cursor
   local cursor = player.cursor_stack
   if cursor and cursor.valid_for_read and cursor.name == name then remaining = remaining - cursor.count end

   return remaining <= 0
end

---Create a deductor for placing an entity prototype
---Tries all items_to_place_this options, not just the first
---@param pindex integer
---@param proto_name string Entity prototype name
---@param silent boolean? If true, don't announce errors
---@return fa.InventoryUtils.Deductor|nil deductor The deductor, or nil if items unavailable
function mod.deductor_to_place(pindex, proto_name, silent)
   local player = game.get_player(pindex)
   if not player then return nil end

   local proto = prototypes.entity[proto_name]
   if not proto then
      if not silent then
         Sounds.play_cannot_build(pindex)
         Speech.speak(pindex, { "fa.cannot-build" })
      end
      return nil
   end

   local items = proto.items_to_place_this
   if not items or #items == 0 then
      -- Free to place (no items required)
      return Deductor.new(pindex)
   end

   -- Try each possible item until one works
   for _, required in ipairs(items) do
      if can_deduct_item(player, required.name, required.count) then
         local deductor = Deductor.new(pindex)
         deductor:add_deduct(required.name, required.count)
         return deductor
      end
   end

   -- None of the options worked - report the first one as the missing item
   if not silent then
      Sounds.play_cannot_build(pindex)
      local needed_list = mod.present_list({ { name = items[1].name, count = items[1].count } }, nil, nil, true)
      Speech.speak(pindex, { "fa.missing-items", needed_list or "" })
   end
   return nil
end

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
      local item_label = ItemInfo.item_info({
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
      Sounds.play_inventory_move(pindex)

      -- Build success message
      local item_label = ItemInfo.item_info({
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

-- Present a list like iron plate x1, transport belt legendary x2, ...
---@param list ({ name: string|LuaItemPrototype, quality: string|LuaQualityPrototype|nil, count: number})[]
---@param truncate number?
---@param protos table<string, LuaItemPrototype | LuaFluidPrototype>?
---@param raw boolean? If true, return just the list without "Has" wrapper
---@return LocalisedString?
function mod.present_list(list, truncate, protos, raw)
   local contents = TH.rollup2(list, F.name().get, function(i)
      return i.quality or "normal"
   end, F.count().get)

   -- Now that everything is together we must unroll it again, then sort.
   ---@type ({ count: number, name: string, quality: LuaQualityPrototype })[]
   local final = {}

   for name, quals in pairs(contents) do
      for qual, count in pairs(quals) do
         table.insert(final, { count = count, name = name, quality = prototypes.quality[qual] })
      end
   end

   -- Careful: this is actually a reverse sort.
   table.sort(final, function(a, b)
      if a.count == b.count and a.name == b.name then
         return a.quality.level > b.quality.level
      elseif a.count == b.count then
         return a.name > b.name
      else
         return a.count > b.count
      end
   end)

   local endpoint = #final
   local extra = false
   if truncate then
      extra = truncate < endpoint
      endpoint = math.min(endpoint, truncate)
   end

   if not next(final) then return { "fa.ent-info-inventory-empty" } end

   local entries = {}
   for i = 1, endpoint do
      local e = final[i]

      table.insert(
         entries,
         ItemInfo.item_or_fluid_info({ name = e.name, quality = e.quality, count = e.count }, protos or prototypes.item)
      )
   end

   if extra then
      table.insert(entries, ItemInfo.item_info({ name = ItemInfo.ITEM_OTHER, count = #final - truncate }))
   end
   local joined = FaUtils.localise_cat_table(entries, ", ")

   if raw then return joined end
   return { "fa.ent-info-inventory-presentation", joined }
end

return mod
