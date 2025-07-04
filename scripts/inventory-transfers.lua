--[[
Inventory Transfer System
Handles multi-stack transfers between player and building inventories.
Supports ratio-based transfers and item filtering.
]]

local Localising = require("scripts.localising")
local FaUtils = require("scripts.fa-utils")

local mod = {}

---Transfer inventory items between entities
---@param args table Arguments: from (inventory), to (inventory/entity), name (item name or empty), ratio (0-1)
---@return table moved Items moved {[item_name] = count}
---@return boolean full Whether destination inventory became full
local function transfer_inventory(args)
   local moved = {}
   local full = false

   --Get destination inventory
   local to_inventory = nil
   if args.to.object_name == "LuaInventory" then
      to_inventory = args.to
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

   --Simplified extraction with ratio
   local contents = args.from.get_contents()
   for name, count in pairs(contents) do
      local extracted = 0
      if args.name == nil or args.name == "" or args.name == name then
         local target_extract = math.ceil(count * args.ratio)
         if target_extract > 0 then
            extracted = args.from.remove({ name = name, count = target_extract })
            if extracted > 0 then
               local inserted = to_inventory.insert({ name = name, count = extracted })
               if inserted > 0 then moved[name] = (moved[name] or 0) + inserted end
               if inserted < extracted then
                  args.from.insert({ name = name, count = extracted - inserted })
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
   local result = { "" }
   local sector = storage.players[pindex].building.sectors[storage.players[pindex].building.sector]
   if
      sector
      and sector.name ~= "Fluid"
      and storage.players[pindex].building.sector_name ~= "player inventory from building"
   then
      --This is the section where we move from the building to the player.
      local item_name = ""
      local stack = sector.inventory[storage.players[pindex].building.index]
      if stack and stack.valid and stack.valid_for_read then item_name = stack.name end

      local moved, full =
         transfer_inventory({ from = sector.inventory, to = game.players[pindex], name = item_name, ratio = ratio })
      if full then
         table.insert(result, { "inventory-full-message.main" })
         table.insert(result, ", ")
      end
      if table_size(moved) == 0 then
         table.insert(result, { "fa.grabbed-nothing" })
      else
         game.get_player(pindex).play_sound({ path = "utility/inventory_move" })
         local item_list = { "" }
         local other_items = 0
         local listed_count = 0
         for name, amount in pairs(moved) do
            if listed_count <= 5 then
               table.insert(item_list, Localising.localise_item({ name = name, count = amount }))
               table.insert(item_list, ", ")
            else
               other_items = other_items + amount
            end
            listed_count = listed_count + 1
         end
         if other_items > 0 then
            table.insert(item_list, Localising.localise_item({ name = Localising.ITEM_OTHER, count = other_items }))
            table.insert(item_list, ", ")
         end
         -- trim trailing comma off
         item_list[#item_list] = nil
         table.insert(result, { "fa.grabbed-stuff", item_list })
      end
   elseif sector and sector.name == "fluid" then
      --Do nothing
   else
      local offset = 1
      if storage.players[pindex].building.recipe_list ~= nil then offset = offset + 1 end
      if storage.players[pindex].building.sector_name == "player inventory from building" then
         --This is the section where we move from the player to the building.
         local item_name = ""
         local stack = storage.players[pindex].inventory.lua_inventory[storage.players[pindex].inventory.index]
         if stack and stack.valid and stack.valid_for_read then item_name = stack.name end

         local moved, full = transfer_inventory({
            from = game.get_player(pindex).get_main_inventory(),
            to = storage.players[pindex].building.ent,
            name = item_name,
            ratio = ratio,
         })

         if table_size(moved) == 0 then
            if full then table.insert(result, "Inventory full or not applicable, ") end
            table.insert(result, { "fa.placed-nothing" })
         else
            if full then table.insert(result, "Partial success, ") end
            game.get_player(pindex).play_sound({ path = "utility/inventory_move" })
            local item_list = { "" }
            local other_items = 0
            local listed_count = 0
            for name, amount in pairs(moved) do
               if listed_count <= 5 then
                  table.insert(item_list, Localising.localise_item({ name = name, count = amount }))
                  table.insert(item_list, ", ")
               else
                  other_items = other_items + amount
               end
               listed_count = listed_count + 1
            end
            if other_items > 0 then
               table.insert(item_list, Localising.localise_item({ name = Localising.ITEM_OTHER, count = other_items }))
               table.insert(item_list, ", ")
            end
            -- trim trailing comma off
            item_list[#item_list] = nil
            table.insert(result, { "fa.placed-stuff", FaUtils.breakup_string(item_list) })
         end
      end
   end
   printout(result, pindex)
end

return mod
