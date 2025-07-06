--[[
Inventory Transfer System
Handles multi-stack transfers between player and building inventories.
Supports ratio-based transfers and item filtering.
]]

local Localising = require("scripts.localising")
local FaUtils = require("scripts.fa-utils")
local Speech = require("scripts.speech")
local TH = require("scripts.table-helpers")

local mod = {}

---Build a message listing transferred items
---@param moved table<string, integer> Table of moved items {[item_name] = count}
---@return LocalisedString
local function build_item_list_message(moved)
   local message = Speech.new()

   -- Convert to array and sort by count (descending)
   local items = {}
   for name, count in pairs(moved) do
      table.insert(items, { name = name, count = count })
   end
   table.sort(items, function(a, b)
      return a.count > b.count
   end)

   for i, item in ipairs(items) do
      if i > 1 then message:fragment(", ") end
      message:fragment(Localising.localise_item({ name = item.name, count = item.count }))
   end

   return message:build()
end

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

---Perform multi-stack transfer between player and building inventories
---@param ratio number Transfer ratio (0-1)
---@param pindex number Player index
function mod.do_multi_stack_transfer(ratio, pindex)
   local message = Speech.new()
   local building_data = storage.players[pindex].building
   if not building_data or not building_data.sectors then
      message:fragment({ "fa.grabbed-nothing" })
      Speech.speak(pindex, message:build())
      return
   end

   local sector = building_data.sectors[building_data.sector]
   if sector and sector.name ~= "Fluid" and building_data.sector_name ~= "player inventory from building" then
      --This is the section where we move from the building to the player.
      local item_name = nil
      local current_index = storage.players[pindex].building.index
      local inventory = sector.inventory

      -- When the hand is empty and we're on a slot with an item, transfer just that stack
      local stack = game.get_player(pindex).cursor_stack
      if (not stack or not stack.valid_for_read) and current_index and inventory then
         -- Empty hand - transfer the specific stack at current index
         local slot_stack = inventory[current_index]
         if slot_stack and slot_stack.valid and slot_stack.valid_for_read then item_name = slot_stack.name end
      end

      local moved, full =
         transfer_inventory({ from = inventory, to = game.players[pindex], name = item_name, ratio = ratio })
      if full then
         message:fragment({ "inventory-full-message.main" })
         message:fragment(", ")
      end
      if table_size(moved) == 0 then
         message:fragment({ "fa.grabbed-nothing" })
      else
         game.get_player(pindex).play_sound({ path = "utility/inventory_move" })
         local item_list = build_item_list_message(moved)
         message:fragment({ "fa.grabbed-stuff", item_list })
      end
   elseif sector and sector.name == "fluid" then
      --Do nothing
      message:fragment({ "fa.grabbed-nothing" })
   else
      if storage.players[pindex].building.sector_name == "player inventory from building" then
         --This is the section where we move from the player to the building.
         local item_name = "" -- Empty string means transfer all items
         local stack = storage.players[pindex].inventory.lua_inventory[storage.players[pindex].inventory.index]
         if stack and stack.valid and stack.valid_for_read then item_name = stack.name end

         local moved, full = transfer_inventory({
            from = assert(game.get_player(pindex).get_main_inventory()),
            to = storage.players[pindex].building.ent,
            name = item_name,
            ratio = ratio,
         })

         if table_size(moved) == 0 then
            if full then
               message:fragment({ "fa.inventory-full-or-not-applicable" })
               message:fragment(" ")
            end
            message:fragment({ "fa.placed-nothing" })
         else
            if full then
               message:fragment({ "fa.partial-success" })
               message:fragment(" ")
            end
            game.get_player(pindex).play_sound({ path = "utility/inventory_move" })
            local item_list = build_item_list_message(moved)
            message:fragment({ "fa.placed-stuff", item_list })
         end
      else
         -- No valid transfer scenario
         message:fragment({ "fa.grabbed-nothing" })
      end
   end
   Speech.speak(pindex, message:build())
end

return mod
