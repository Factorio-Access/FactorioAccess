--[[
Inventory Transfer System
Handles multi-stack transfers between player and building inventories.
Supports ratio-based transfers and item filtering.
]]

local FaUtils = require("scripts.fa-utils")
local ItemInfo = require("scripts.item-info")
local Localising = require("scripts.localising")
local Speech = require("scripts.speech")
local MessageBuilder = Speech.MessageBuilder
local TH = require("scripts.table-helpers")

local mod = {}

---Transfer inventory items between entities
---@param args {from: LuaInventory, to: LuaInventory|LuaEntity|LuaPlayer, name?: string, ratio: number}
---@return table<string, integer> moved Items moved {[item_name] = count}
---@return boolean full Whether destination inventory became full
local function transfer_inventory(args)
   local moved = {}
   local full = false

   --Get destination inventory
   local to_inventory = nil
   if args.to.object_name == "LuaInventory" then
      to_inventory = args.to
   elseif args.to.object_name == "LuaPlayer" then
      -- Players use main inventory
      to_inventory = args.to.get_main_inventory()
   elseif args.to.get_output_inventory ~= nil then
      to_inventory = args.to.get_output_inventory()
   elseif args.to.get_inventory ~= nil then
      to_inventory = args.to.get_inventory(defines.inventory.chest)
         or args.to.get_inventory(defines.inventory.assembling_machine_input)
         or args.to.get_inventory(defines.inventory.lab_input)
         or args.to.get_inventory(defines.inventory.rocket_silo_rocket)
   elseif args.to.get_main_inventory ~= nil then
      to_inventory = args.to.get_main_inventory()
   end
   if to_inventory == nil then return moved, full end

   if args.name and args.name ~= "" then
      -- Transfer specific item
      local count = args.from.get_item_count(args.name)
      if count > 0 then
         local target_extract = math.ceil(count * args.ratio)
         local extracted = args.from.remove({ name = args.name, count = target_extract })
         if extracted > 0 then
            local inserted = to_inventory.insert({ name = args.name, count = extracted })
            if inserted > 0 then moved[args.name] = inserted end
            if inserted < extracted then
               args.from.insert({ name = args.name, count = extracted - inserted })
               full = true
            end
         end
      end
   else
      -- Transfer all items
      -- In Factorio 2.0, get_contents() returns an array of items
      local contents = args.from.get_contents()
      for _, item in ipairs(contents) do
         local target_extract = math.ceil(item.count * args.ratio)
         if target_extract > 0 then
            local extracted = args.from.remove({ name = item.name, count = target_extract })
            if extracted > 0 then
               local inserted = to_inventory.insert({ name = item.name, count = extracted })
               if inserted > 0 then moved[item.name] = (moved[item.name] or 0) + inserted end
               if inserted < extracted then
                  args.from.insert({ name = item.name, count = extracted - inserted })
                  full = true
               end
            end
         end
      end
   end

   return moved, full
end

-- Removed: do_multi_stack_transfer function
-- This was used for building/vehicle inventory transfers which are being
-- replaced with capability-based UI system

mod.transfer_inventory = transfer_inventory

return mod
