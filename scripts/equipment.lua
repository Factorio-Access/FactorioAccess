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
   local moved_key_count = 0
   for key, val in pairs(res) do
      moved_key_count = moved_key_count + 1
   end
   --Check fullness
   if ammo_inv.is_full() then
      result = "Fully reloaded all three weapons"
   elseif moved_key_count == 0 then
      result = "Error: No relevant ammo found for reloading"
   else
      result = "Reloaded weapons with any available ammunition, "
   end
   return result
end

--Move all weapons and ammo back to inventory
function mod.remove_weapons_and_ammo(pindex)
   local p = game.get_player(pindex)
   local guns_inv = p.get_inventory(defines.inventory.character_guns)
   local ammo_inv = p.get_inventory(defines.inventory.character_ammo)
   local main_inv = p.get_inventory(defines.inventory.character_main)
   local guns_count = #guns_inv - guns_inv.count_empty_stacks()
   local ammos_count = #ammo_inv - ammo_inv.count_empty_stacks()
   local expected_remove_count = guns_count + ammos_count
   local resulted_remove_count = 0
   local message = ""

   --Abort if not enough empty slots in inventory
   if main_inv.count_empty_stacks() < 6 then return "Error: Not enough empty inventory slots, at least 6 needed" end

   --Remove all ammo
   for i = 1, ammos_count, 1 do
      if main_inv.can_insert(ammo_inv[i]) then
         local inserted = main_inv.insert(ammo_inv[i])
         local removed = ammo_inv.remove(ammo_inv[i])
         if inserted ~= removed then p.print("ammo removal count error", { volume_modifier = 0 }) end
         resulted_remove_count = resulted_remove_count + math.ceil(removed / 1000) --counts how many stacks are removed
      end
   end

   --Remove all guns
   for i = 1, guns_count, 1 do
      if main_inv.can_insert(guns_inv[i]) then
         local inserted = main_inv.insert(guns_inv[i])
         local removed = guns_inv.remove(guns_inv[i])
         if inserted ~= removed then p.print("gun removal count error", { volume_modifier = 0 }) end
         resulted_remove_count = resulted_remove_count + math.ceil(removed / 1000) --counts how many stacks are removed
      end
   end

   message = "Collected " .. resulted_remove_count .. " of " .. expected_remove_count .. " item stacks,"
   if main_inv.count_empty_stacks() == 0 then message = message .. " Inventory full. " end

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

function mod.read_shield_and_health_level(pindex, ent_in)
   local p = game.get_player(pindex)
   local char = p.character
   local ent
   local grid
   local result = { "" }
   if ent_in then
      --Report for the ent
      ent = ent_in
      grid = ent.grid
      table.insert(result, ent.localised_name)
   else
      --Report for this player
      if char == nil or char.valid == false then
         table.insert(result, "No character")
         return result
      end
      ent = char
      local armor_inv = p.get_inventory(defines.inventory.character_armor)
      if armor_inv[1] and armor_inv[1].valid_for_read and armor_inv[1].grid and armor_inv[1].grid.valid then
         grid = armor_inv[1].grid
      end
   end

   --Check shield health remaining (if supported)
   local empty_shield = false
   if grid then
      if grid.shield > 0 and grid.shield == grid.max_shield then
         table.insert(result, " Shield full, ")
      elseif grid.shield > 0 then
         local shield_left = math.floor(grid.shield / grid.max_shield * 100 + 0.5)
         table.insert(result, " Shield " .. shield_left .. " percent, ")
      else
         empty_shield = true
      end
   end
   --Check health
   if ent.is_entity_with_health then
      if ent.get_health_ratio() == 1 then
         table.insert(result, { "fa.full-health" })
      else
         table.insert(result, { "fa.percent-health", math.floor(ent.get_health_ratio() * 100) })
      end
   end
   -- State shield empty at the end (if supported)
   if grid and empty_shield then table.insert(result, ", shield empty ") end
   return result
end

--Read armor stats such as type and bonuses. Default option is the player's own armor.
function mod.read_armor_stats(pindex, ent_in)
   local ent = ent_in
   local armor_inv = game.get_player(pindex).get_inventory(defines.inventory.character_armor)
   local result = mod.read_shield_and_health_level(pindex, ent_in) --First report health and shield
   table.insert(result, ", ")
   local grid
   if ent_in == nil then
      --Player armor
      if armor_inv.is_empty() then
         table.insert(result, "No armor equipped.")
         return result
      elseif armor_inv[1].grid == nil or not armor_inv[1].grid.valid then
         table.insert(result, armor_inv[1].name .. " equipped, with no equipment grid.")
         return result
      end
      --Player armor with non-empty equipment grid
      grid = armor_inv[1].grid
      table.insert(result, armor_inv[1].name .. " equipped, ")
   else
      --Entity grid
      grid = ent.grid
      if grid == nil or grid.valid == false then
         --No more info to report
         return result
      end
      --Entity with non-empty equipment grid
      --(continue)
   end
   --Stop if no equipment
   if grid.count() == 0 then
      table.insert(result, " no armor equipment installed. ")
      return result
   end
   --Read battery level
   if grid.battery_capacity > 0 then
      if grid.available_in_batteries == grid.battery_capacity then
         table.insert(result, " batteries full, ")
      elseif grid.available_in_batteries == 0 then
         table.insert(result, " batteries empty ")
      else
         local battery_level = math.ceil(100 * grid.available_in_batteries / grid.battery_capacity)
         table.insert(result, " batteries at " .. battery_level .. " percent, ")
      end
   else
      table.insert(result, " no batteries, ")
   end
   --Energy Producers
   if grid.generator_energy > 0 or grid.max_solar_energy > 0 then
      table.insert(result, " generating ")
      if grid.generator_energy > 0 then
         table.insert(result, fa_electrical.get_power_string(grid.generator_energy * 60) .. " nonstop, ")
      end
      if grid.max_solar_energy > 0 then
         table.insert(result, fa_electrical.get_power_string(grid.max_solar_energy * 60) .. " at daytime, ")
      end
   end
   --Movement bonus
   if grid.count("exoskeleton-equipment") > 0 then
      table.insert(
         result,
         " movement bonus "
            .. grid.count("exoskeleton-equipment") * 30
            .. " percent for "
            .. fa_electrical.get_power_string(grid.count("exoskeleton-equipment") * 200000)
      )
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
   local char_main_inv = game.get_player(pindex).get_inventory(defines.inventory.character_main)
   local result = ""
   if armor_inv.is_empty() then return "No armor." end

   local grid
   if players[pindex].menu == "vehicle" and game.get_player(pindex).opened.type == "spider-vehicle" then
      grid = game.get_player(pindex).opened.grid
   else
      grid = armor_inv[1].grid
   end
   if grid ~= nil and grid.valid then
      local initial_equipment_count = grid.count()
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
      result = "Collected " .. initial_equipment_count - grid.count() .. " of " .. initial_equipment_count .. " items, "
   end

   --Remove armor
   if players[pindex].menu == "vehicle" and game.get_player(pindex).opened.type == "spider-vehicle" then
      --do nothing
   elseif char_main_inv.count_empty_stacks() == 0 then
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

function mod.guns_menu_open(pindex)
   local p = game.get_player(pindex)
   players[pindex].menu = "guns"
   players[pindex].guns_menu.ammo_selected = false
   players[pindex].guns_menu.index = 1
   mod.guns_menu_read_slot(pindex, "Guns and ammo, ")
end

function mod.guns_menu_left(pindex)
   local index = players[pindex].guns_menu.index
   index = index - 1
   if index == 0 then
      index = 3
      game.get_player(pindex).play_sound({ path = "inventory-wrap-around" })
   else
      game.get_player(pindex).play_sound({ path = "Inventory-Move" })
   end
   players[pindex].guns_menu.index = index
   game.get_player(pindex).play_sound({ path = "Inventory-Move" })
   mod.guns_menu_read_slot(pindex)
end

function mod.guns_menu_right(pindex)
   local index = players[pindex].guns_menu.index
   index = index + 1
   if index == 4 then
      index = 1
      game.get_player(pindex).play_sound({ path = "inventory-wrap-around" })
   else
      game.get_player(pindex).play_sound({ path = "Inventory-Move" })
   end
   players[pindex].guns_menu.index = index
   mod.guns_menu_read_slot(pindex)
end

function mod.guns_menu_up_or_down(pindex)
   players[pindex].guns_menu.ammo_selected = not players[pindex].guns_menu.ammo_selected
   game.get_player(pindex).play_sound({ path = "Inventory-Move" })
   mod.guns_menu_read_slot(pindex)
end

function mod.guns_menu_get_selected_slot(pindex)
   local menu = players[pindex].guns_menu
   local p = game.get_player(pindex)
   local gun_stack = p.get_inventory(defines.inventory.character_guns)[menu.index]
   local ammo_stack = p.get_inventory(defines.inventory.character_ammo)[menu.index]
   if menu.ammo_selected then
      return ammo_stack
   else
      return gun_stack
   end
end

function mod.guns_menu_read_slot(pindex, start_phrase_in)
   local start_phrase = start_phrase_in or ""
   local menu = players[pindex].guns_menu
   local p = game.get_player(pindex)
   local result = { "" }
   table.insert(result, start_phrase)
   local gun_stack = p.get_inventory(defines.inventory.character_guns)[menu.index]
   local ammo_stack = p.get_inventory(defines.inventory.character_ammo)[menu.index]
   if menu.ammo_selected then
      --Read the ammo slot
      if ammo_stack and ammo_stack.valid_for_read then
         table.insert(result, ammo_stack.name .. " " .. "times" .. " " .. ammo_stack.count)
      else
         table.insert(result, "empty ammo slot")
      end
      table.insert(result, " for ")
      if gun_stack and gun_stack.valid_for_read then
         table.insert(result, gun_stack.name)
      else
         table.insert(result, "empty gun slot")
      end
   else
      --Read the gun slot
      if gun_stack and gun_stack.valid_for_read then
         table.insert(result, gun_stack.name)
         if gun_stack.count > 1 then table.insert(result, "times" .. " " .. gun_stack.count) end
      else
         table.insert(result, "empty gun slot")
      end
      table.insert(result, " using ")
      if ammo_stack and ammo_stack.valid_for_read then
         --Read the ammo
         table.insert(result, ammo_stack.name .. " " .. "times" .. " " .. ammo_stack.count)
      else
         table.insert(result, "no ammo")
      end
   end
   printout(result, pindex)
end

function mod.guns_menu_click_slot(pindex)
   local p = game.get_player(pindex)
   local hand = p.cursor_stack
   local menu = players[pindex].guns_menu
   local gun_stack = p.get_inventory(defines.inventory.character_guns)[menu.index]
   local ammo_stack = p.get_inventory(defines.inventory.character_ammo)[menu.index]
   local selected_stack = nil
   if menu.ammo_selected then
      selected_stack = ammo_stack
   else
      selected_stack = gun_stack
   end
   if hand and hand.valid_for_read then
      --FUll hand operations
      if selected_stack == nil or selected_stack.valid_for_read == false then
         --Empty slot
         if menu.ammo_selected and hand.type ~= "ammo" then
            printout("Error: Slot reserved for ammo types only", pindex)
         elseif not menu.ammo_selected and hand.type ~= "gun" then
            printout("Error: Slot reserved for gun types only", pindex)
         else
            if selected_stack ~= nil then hand.swap_stack(selected_stack) end
            --If the swap is successful then the following print statement is overwritten.
            printout("Error: Incompatible gun and ammo types", pindex)
         end
      else
         --Full slot
         if menu.ammo_selected and hand.type ~= "ammo" then
            printout("Error: Slot reserved for ammo types only", pindex)
         elseif not menu.ammo_selected and hand.type ~= "gun" then
            printout("Error: Slot reserved for gun types only", pindex)
         else
            hand.swap_stack(selected_stack)
            --If the swap is successful then the following print statement is overwritten.
            printout("Error: Incompatible gun and ammo types", pindex)
         end
      end
   else
      --Empty hand
      if selected_stack and selected_stack.valid_for_read then
         --Pick up the thing
         hand.swap_stack(selected_stack)
      else
         printout("No action", pindex)
      end
   end
end

return mod
