--Here: functions relating to guns and equipment management
--Does not include event handlers, combat, repair packs

local localising = require("scripts.localising")
local fa_electrical = require("scripts.electrical")

local mod = {}

--Tries to equip a stack. For now called only for a stack in hand when the only the inventory is open.
function mod.equip_it(stack, pindex)
   local message = ""
   if players[pindex].menu == "vehicle" and game.get_player(pindex).opened.type == "spider-vehicle" then
      message = localising.get_alt(game.entity_prototypes["spidertron"])
      if message == nil then
         message = "Spidertron " --laterdo possible bug here
      end
   end

   if stack == nil or not stack.valid_for_read or not stack.valid then return "Nothing found to equip." end

   if stack.is_armor then
      local armor = game.get_player(pindex).get_inventory(defines.inventory.character_armor)
      if armor.is_empty() then
         message = message .. " Equipped " .. stack.name
      else
         message = message .. " Equipped " .. stack.name .. " and took in hand " .. armor[1].name
      end
      stack.swap_stack(armor[1])
      players[pindex].skip_read_hand = true
   elseif stack.type == "gun" then
      --Equip gun ("arms")
      local gun_inv = game.get_player(pindex).get_inventory(defines.inventory.character_guns)
      if gun_inv.can_insert(stack) then
         local inserted = gun_inv.insert(stack)
         message = message .. " Equipped " .. stack.name
         stack.count = stack.count - inserted
         players[pindex].skip_read_hand = true
      else
         if gun_inv.count_empty_stacks() == 0 then
            message = message .. " All gun slots full."
         else
            message = message .. " Cannot insert " .. stack.name
         end
      end
   elseif stack.type == "ammo" then
      --Equip ammo
      local ammo_inv = game.get_player(pindex).get_inventory(defines.inventory.character_ammo)
      if ammo_inv.can_insert(stack) then
         local inserted = ammo_inv.insert(stack)
         message = message .. " Reloaded with " .. stack.name
         stack.count = stack.count - inserted
         players[pindex].skip_read_hand = true
      else
         if ammo_inv.count_empty_stacks() == 0 then
            message = message .. " All ammo slots full."
         else
            message = message .. " Cannot insert " .. stack.name
         end
      end
   elseif stack.prototype.place_as_equipment_result ~= nil then
      --Equip equipment ("gear")
      local armor_inv
      local grid
      if players[pindex].menu == "vehicle" and game.get_player(pindex).opened.type == "spider-vehicle" then
         grid = game.get_player(pindex).opened.grid
      else
         armor_inv = game.get_player(pindex).get_inventory(defines.inventory.character_armor)
         if armor_inv.is_empty() then return "Equipment requires armor with an equipment grid." end
         if armor_inv[1].grid == nil or not armor_inv[1].grid.valid then
            return "Equipment requires armor with an equipment grid."
         end
         grid = armor_inv[1].grid
      end
      --Iterate across the whole grid, trying to place the item.
      local placed = nil
      for i = 0, grid.width - 1, 1 do
         for j = 0, grid.height - 1, 1 do
            placed = grid.put({ name = stack.name, position = { i, j }, by_player = pindex })
            if placed ~= nil then break end
         end
         if placed ~= nil then break end
      end
      local slots_left = mod.count_empty_equipment_slots(grid)
      if placed ~= nil then
         message = message .. " equipped " .. stack.name .. ", " .. slots_left .. " empty slots remaining."
         stack.count = stack.count - 1
         players[pindex].skip_read_hand = true
      else
         --Check if the grid is full
         if slots_left == 0 then
            message = message .. " All armor equipment slots are full."
         else
            message = message .. " This equipment does not fit in the remaining " .. slots_left .. " slots."
         end
      end
   elseif
      players[pindex].in_menu == false
      and (stack.prototype.place_result ~= nil or stack.prototype.place_as_tile_result ~= nil)
   then
      message = ""
   else
      message = message .. " Cannot equip " .. stack.name
   end

   return message
end

--Returns info on weapons and ammo
function mod.read_weapons_and_ammo(pindex)
   local guns_inv = game.get_player(pindex).get_inventory(defines.inventory.character_guns)
   local ammo_inv = game.get_player(pindex).get_inventory(defines.inventory.character_ammo)
   local guns_count = #guns_inv - guns_inv.count_empty_stacks()
   local ammos_count = #ammo_inv - ammo_inv.count_empty_stacks()
   local result = "Weapons, "

   for i = 1, 3, 1 do
      if i > 1 then result = result .. " and " end
      if guns_inv[i] and guns_inv[i].valid and guns_inv[i].valid_for_read then
         result = result .. guns_inv[i].name
      else
         result = result .. "empty weapon slot"
      end
      if ammo_inv[i] ~= nil and ammo_inv[i].valid and ammo_inv[i].valid_for_read then
         result = result .. " with " .. ammo_inv[i].count .. " " .. ammo_inv[i].name .. "s, "
      else
         result = result .. " with no ammunition, "
      end
   end
   if guns_count == 0 then result = " No weapons equipped." end

   return result
end

--Reload all ammo possible from the inventory. Existing stacks have priority over fuller stacks.
function mod.reload_weapons(pindex)
   local ammo_inv = game.get_player(pindex).get_inventory(defines.inventory.character_ammo)
   local main_inv = game.get_player(pindex).get_inventory(defines.inventory.character_main)
   local result = ""
   if ammo_inv.is_full() then
      result = "All ammo slots are already full."
      return result
   end
   --Apply an inventory transfer to the ammo inventory.
   local res, full = transfer_inventory({ from = main_inv, to = ammo_inv })
   --**laterdo fail conditions messages, and maybe add reload sound?
   --Check fullness
   if ammo_inv.is_full() then
      result = "Fully reloaded all three weapons"
   else
      result = "Reloaded weapons with any available ammunition, "
   end
   return result
end

--Move all weapons and ammo back to inventory
function mod.remove_weapons_and_ammo(pindex)
   local guns_inv = game.get_player(pindex).get_inventory(defines.inventory.character_guns)
   local ammo_inv = game.get_player(pindex).get_inventory(defines.inventory.character_ammo)
   local main_inv = game.get_player(pindex).get_inventory(defines.inventory.character_main)
   local guns_count = #guns_inv - guns_inv.count_empty_stacks()
   local ammos_count = #ammo_inv - ammo_inv.count_empty_stacks()
   local expected_remove_count = guns_count + ammos_count
   local resulted_remove_count = 0
   local message = ""

   --Remove all ammo
   for i = 1, ammos_count, 1 do
      if main_inv.can_insert(ammo_inv[i]) then
         local inserted = main_inv.insert(ammo_inv[i])
         local removed = ammo_inv.remove(ammo_inv[i])
         if inserted ~= removed then
            game.get_player(pindex).print("ammo removal count error", { volume_modifier = 0 }) --todo fix
         end
         resulted_remove_count = resulted_remove_count + math.ceil(removed / 1000) --counts how many stacks are removed
      end
   end

   --Remove all guns
   for i = 1, guns_count, 1 do
      if main_inv.can_insert(guns_inv[i]) then
         local inserted = main_inv.insert(guns_inv[i])
         local removed = guns_inv.remove(guns_inv[i])
         if inserted ~= removed then
            game.get_player(pindex).print("gun removal count error", { volume_modifier = 0 }) --todo fix
         end
         resulted_remove_count = resulted_remove_count + math.ceil(removed / 1000) --counts how many stacks are removed
      end
   end

   message = "Collected " .. resulted_remove_count .. " of " .. expected_remove_count .. " item stacks,"
   if game.get_player(pindex).get_main_inventory().count_empty_stacks() == 0 then
      message = message .. " Inventory full. "
   end

   return message
end

--Temporary safety measure for preventing accidental shooting of atomic bombs
function mod.delete_equipped_atomic_bombs(pindex)
   local ammo_inv = game.get_player(pindex).get_inventory(defines.inventory.character_ammo)
   local main_inv = game.get_player(pindex).get_inventory(defines.inventory.character_main)
   local ammos_count = #ammo_inv - ammo_inv.count_empty_stacks()
   local resulted_remove_count = 0

   --Remove all atomic bombs
   for i = 1, ammos_count, 1 do
      if ammo_inv[i] and ammo_inv[i].valid_for_read and ammo_inv[i].name == "atomic-bomb" then
         local removed = ammo_inv.remove(ammo_inv[i])
         resulted_remove_count = resulted_remove_count + removed
      end
   end

   --Save removed amount
   local restore_count = players[pindex].restore_count
   if restore_count == nil or restore_count < resulted_remove_count then
      players[pindex].restore_count = resulted_remove_count
   end
   return
end

--Temporary safety measure for preventing accidental shooting of atomic bombs
function mod.restore_equipped_atomic_bombs(pindex)
   local guns_inv = game.get_player(pindex).get_inventory(defines.inventory.character_guns)
   local ammo_inv = game.get_player(pindex).get_inventory(defines.inventory.character_ammo)
   local main_inv = game.get_player(pindex).get_inventory(defines.inventory.character_main)
   local guns_count = #guns_inv - guns_inv.count_empty_stacks()
   local ammos_count = #ammo_inv - ammo_inv.count_empty_stacks()

   --Create stack
   local restore_count = players[pindex].restore_count
   if restore_count == nil then restore_count = 1 end
   local stack = { name = "atomic-bomb", count = restore_count }

   --Equip all atomic bombs according to count
   if restore_count > 0 and ammo_inv.can_insert(stack) then local inserted = ammo_inv.insert(stack) end
end

function mod.count_empty_equipment_slots(grid)
   local slots_left = 0
   for i = 0, grid.width - 1, 1 do
      for j = 0, grid.height - 1, 1 do
         local check = grid.get({ i, j })
         if check == nil then slots_left = slots_left + 1 end
      end
   end
   return slots_left
end

--Read armor stats such as type and bonuses
function mod.read_armor_stats(pindex)
   local armor_inv = game.get_player(pindex).get_inventory(defines.inventory.character_armor)
   local result = ""
   if armor_inv.is_empty() then return "No armor equipped." end
   if armor_inv[1].grid == nil or not armor_inv[1].grid.valid then
      return armor_inv[1].name .. " equipped, with no equipment grid."
   end
   --Armor with Equipment
   local grid
   if players[pindex].menu == "vehicle" and game.get_player(pindex).opened.type == "spider-vehicle" then
      grid = game.get_player(pindex).opened.grid
      result = localising.get_alt(game.entity_prototypes["spidertron"])
      if result == nil then
         result = "Spidertron " --laterdo possible bug here
      end
   else
      grid = armor_inv[1].grid
      result = armor_inv[1].name .. " equipped, "
   end
   if grid.count() == 0 then return result .. " no armor equipment installed. " end
   --Read shield level
   if grid.max_shield > 0 then
      if grid.shield == grid.max_shield then
         result = result .. " shields full, "
      else
         result = result .. " shields at " .. math.ceil(100 * grid.shield / grid.max_shield) .. " percent, "
      end
   end
   --Read battery level
   if grid.battery_capacity > 0 then
      if grid.available_in_batteries == grid.battery_capacity then
         result = result .. " batteries full, "
      elseif grid.available_in_batteries == 0 then
         result = result .. " batteries empty "
      else
         result = result
            .. " batteries at "
            .. math.ceil(100 * grid.available_in_batteries / grid.battery_capacity)
            .. " percent, "
      end
   else
      result = result .. " no batteries, "
   end
   --Energy Producers
   if grid.generator_energy > 0 or grid.max_solar_energy > 0 then
      result = result .. " generating "
      if grid.generator_energy > 0 then
         result = result .. fa_electrical.get_power_string(grid.generator_energy * 60) .. " nonstop, "
      end
      if grid.max_solar_energy > 0 then
         result = result .. fa_electrical.get_power_string(grid.max_solar_energy * 60) .. " at daytime, "
      end
   end

   --Movement bonus
   if grid.count("exoskeleton-equipment") > 0 then
      result = result
         .. " movement bonus "
         .. grid.count("exoskeleton-equipment") * 30
         .. " percent for "
         .. fa_electrical.get_power_string(grid.count("exoskeleton-equipment") * 200000)
   end

   return result
end

--List armor equipment
function mod.read_equipment_list(pindex)
   local armor_inv = game.get_player(pindex).get_inventory(defines.inventory.character_armor)
   local result = ""
   if armor_inv.is_empty() then return "No armor equipped." end
   if armor_inv[1].grid == nil or not armor_inv[1].grid.valid then return "No equipment grid." end
   --Armor with Equipment
   local grid
   if players[pindex].menu == "vehicle" and game.get_player(pindex).opened.type == "spider-vehicle" then
      grid = game.get_player(pindex).opened.grid
      result = localising.get_alt(game.entity_prototypes["spidertron"])
      if result == nil then
         result = "Spidertron " --laterdo possible bug here
      end
   else
      grid = armor_inv[1].grid
      result = "Armor "
   end
   if grid.equipment == nil or grid.equipment == {} then return " No armor equipment installed. " end
   --Read Equipment List
   result = result .. " equipped, "
   local contents = grid.get_contents()
   local itemtable = {}
   for name, count in pairs(contents) do
      table.insert(itemtable, { name = name, count = count })
   end
   if #itemtable == 0 then
      result = result .. " nothing, "
   else
      for i = 1, #itemtable, 1 do
         result = result .. itemtable[i].count .. " " .. itemtable[i].name .. ", "
      end
   end

   result = result .. mod.count_empty_equipment_slots(grid) .. " empty slots remaining "

   return result
end

--Remove all armor equipment and then the armor. laterdo "inv full" checks
function mod.remove_equipment_and_armor(pindex)
   local armor_inv = game.get_player(pindex).get_inventory(defines.inventory.character_armor)
   local result = ""
   if armor_inv.is_empty() then return "No armor." end

   local grid
   if players[pindex].menu == "vehicle" and game.get_player(pindex).opened.type == "spider-vehicle" then
      grid = game.get_player(pindex).opened.grid
   else
      grid = armor_inv[1].grid
   end
   if grid ~= nil and grid.valid then
      local e_count = grid.count()
      --Take all items
      for i = 0, grid.width - 1, 1 do
         for j = 0, grid.height - 1, 1 do
            local check = grid.get({ i, j })
            local inv = game.get_player(pindex).get_main_inventory()
            if check ~= nil and inv.can_insert({ name = check.name }) then
               inv.insert({ name = check.name })
               grid.take({ position = { i, j } })
            end
         end
      end
      result = "Collected " .. e_count - grid.count() .. " of " .. e_count .. " items, "
   end

   --Remove armor
   if players[pindex].menu == "vehicle" and game.get_player(pindex).opened.type == "spider-vehicle" then
      --do nothing
   elseif game.get_player(pindex).get_inventory(defines.inventory.character_main).count_empty_stacks() == 0 then
      result = result .. " inventory full "
   else
      result = result .. "removed " .. armor_inv[1].name
      game.get_player(pindex).clear_cursor()
      local stack2 = game.get_player(pindex).cursor_stack
      stack2.swap_stack(armor_inv[1])
      game.get_player(pindex).clear_cursor()
   end

   return result
end

return mod
