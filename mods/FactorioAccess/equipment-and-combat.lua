--Here: functions relating to combat, repair packs 
--Does not include event handlers, guns and equipment, repair work (but maybe it could?)

--Tries to equip a stack. For now called only for a stack in hand when the only the inventory is open.
function equip_it(stack,pindex)
   local message = ""
   if players[pindex].menu == "vehicle" and game.get_player(pindex).opened.type == "spider-vehicle" then
      message = localising.get_alt(game.entity_prototypes["spidertron"]) 
      if message == nil then
         message = "Spidertron "--laterdo possible bug here
      end
   end
   
   if stack == nil or not stack.valid_for_read or not stack.valid then
      return "Nothing found to equip."
   end
   
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
         if armor_inv.is_empty() then
            return "Equipment requires armor with an equipment grid."
         end
         if armor_inv[1].grid == nil or not armor_inv[1].grid.valid  then
            return "Equipment requires armor with an equipment grid."
         end
         grid = armor_inv[1].grid
     end
	  --Iterate across the whole grid, trying to place the item. 
	  local placed = nil
	  for i = 0, grid.width-1, 1 do
	     for j = 0, grid.height-1, 1 do
		    placed = grid.put{name = stack.name, position = {i,j}, by_player = pindex}
			if placed ~= nil then
			   break
			end
		 end
		 if placed ~= nil then
		   break
		 end
	  end    
     local slots_left = count_empty_equipment_slots(grid)
	  if placed ~= nil then
	    message = message .. " equipped " .. stack.name .. ", " .. slots_left .. " empty slots remaining."
		 stack.count = stack.count - 1
       players[pindex].skip_read_hand = true
	  else
	     --Check if the grid is full 
		 if slots_left == 0 then
		    message = message .. " All armor equipment slots are full."
		 else
		    message = message .. " This equipment does not fit in the remaining ".. slots_left .. " slots."
		 end
	  end
   else
      message = message .. " Cannot equip " .. stack.name
   end
   
   return message
end

--Returns info on weapons and ammo
function read_weapons_and_ammo(pindex)
   local guns_inv = game.get_player(pindex).get_inventory(defines.inventory.character_guns)
   local ammo_inv = game.get_player(pindex).get_inventory(defines.inventory.character_ammo)
   local guns_count  = #guns_inv - guns_inv.count_empty_stacks()
   local ammos_count = #ammo_inv - ammo_inv.count_empty_stacks()
   local result = "Weapons, "
   
   for i = 1, 3, 1 do
      if i > 1 then
	    result = result .. " and "
	  end
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
   if guns_count == 0 then
      result = " No weapons equipped."
   end
   
   return result
end

--Reload all ammo possible from the inventory. Existing stacks have priority over fuller stacks.
function reload_weapons(pindex)
   local ammo_inv = game.get_player(pindex).get_inventory(defines.inventory.character_ammo)
   local main_inv = game.get_player(pindex).get_inventory(defines.inventory.character_main)
   local result = ""
   if ammo_inv.is_full() then
      result = "All ammo slots are already full."
      return result
   end
   --Apply an inventory transfer to the ammo inventory.
   local res, full = transfer_inventory{from = main_inv, to = ammo_inv}
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
function remove_weapons_and_ammo(pindex)
   local guns_inv = game.get_player(pindex).get_inventory(defines.inventory.character_guns)
   local ammo_inv = game.get_player(pindex).get_inventory(defines.inventory.character_ammo)
   local main_inv = game.get_player(pindex).get_inventory(defines.inventory.character_main)
   local guns_count  = #guns_inv - guns_inv.count_empty_stacks()
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
            game.get_player(pindex).print("ammo removal count error",{volume_modifier=0})--todo fix
         end
         resulted_remove_count = resulted_remove_count + math.ceil(removed / 1000 )--counts how many stacks are removed
	  end
   end
   
   --Remove all guns
   for i = 1, guns_count, 1 do
      if main_inv.can_insert(guns_inv[i]) then
	     local inserted = main_inv.insert(guns_inv[i])
        local removed = guns_inv.remove(guns_inv[i])
        if inserted ~= removed then
            game.get_player(pindex).print("gun removal count error",{volume_modifier=0})--todo fix
        end
	     resulted_remove_count = resulted_remove_count + math.ceil(removed / 1000)--counts how many stacks are removed
	  end
   end
   
   message = "Collected " .. resulted_remove_count .. " of " .. expected_remove_count .. " item stacks,"
   if game.get_player(pindex).get_main_inventory().count_empty_stacks() == 0 then 
      message = message .. " Inventory full. "
   end
   
   return message
end

function count_empty_equipment_slots(grid)
    local slots_left = 0
	for i = 0, grid.width-1, 1 do
	   for j = 0, grid.height-1, 1 do
		  local check = grid.get({i,j})
		  if check == nil then
			 slots_left = slots_left + 1
	      end
	   end
    end
    return slots_left
end

--Read armor stats such as type and bonuses
function read_armor_stats(pindex)
   local armor_inv = game.get_player(pindex).get_inventory(defines.inventory.character_armor)
   local result = ""
   if armor_inv.is_empty() then
      return "No armor equipped."
   end
   if armor_inv[1].grid == nil or not armor_inv[1].grid.valid  then
      return armor_inv[1].name .. " equipped, with no equipment grid."
   end
   --Armor with Equipment
   local grid 
   if players[pindex].menu == "vehicle" and game.get_player(pindex).opened.type == "spider-vehicle" then
      grid = game.get_player(pindex).opened.grid
      result = localising.get_alt(game.entity_prototypes["spidertron"]) 
      if result == nil then
         result = "Spidertron "--laterdo possible bug here
      end
   else
      grid = armor_inv[1].grid
      result = armor_inv[1].name .. " equipped, "
   end
   if grid.count() == 0 then
      return result .. " no armor equipment installed. "
   end
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
	     result = result .. " batteries at " .. math.ceil(100 * grid.available_in_batteries / grid.battery_capacity) .. " percent, "
	  end
   else
      result = result .. " no batteries, "
   end   
   --Energy Producers
   if grid.generator_energy > 0 or grid.max_solar_energy > 0 then
      result = result .. " generating "
	  if grid.generator_energy > 0 then
	     result = result .. get_power_string(grid.generator_energy*60) .. " nonstop, "
	  end
	  if grid.max_solar_energy > 0 then
	     result = result .. get_power_string(grid.max_solar_energy*60) .. " at daytime, "
	  end
   end
   
   --Movement bonus
   if grid.count("exoskeleton-equipment") > 0 then
      result = result .. " movement bonus " .. grid.count("exoskeleton-equipment") * 30 .. " percent for " .. get_power_string(grid.count("exoskeleton-equipment")*200000)
   end
   
   return result
end

--List armor equipment
function read_equipment_list(pindex)
   local armor_inv = game.get_player(pindex).get_inventory(defines.inventory.character_armor)
   local result = ""
   if armor_inv.is_empty() then
      return "No armor equipped."
   end
   if armor_inv[1].grid == nil or not armor_inv[1].grid.valid  then
      return "No equipment grid."
   end
   --Armor with Equipment
   local grid 
   if players[pindex].menu == "vehicle" and game.get_player(pindex).opened.type == "spider-vehicle" then
      grid = game.get_player(pindex).opened.grid
      result = localising.get_alt(game.entity_prototypes["spidertron"]) 
      if result == nil then
         result = "Spidertron "--laterdo possible bug here
      end
   else
      grid = armor_inv[1].grid
      result = "Armor "
   end
   if grid.equipment == nil or grid.equipment == {} then
      return " No armor equipment installed. "
   end
   --Read Equipment List
   result = result .." equipped, "
   local contents = grid.get_contents() 
   local itemtable = {}
   for name, count in pairs(contents) do
      table.insert(itemtable, {name = name, count = count})
   end
   if #itemtable == 0 then
      result = result .. " nothing, "
   else
      for i = 1, #itemtable, 1 do
         result = result .. itemtable[i].count .. " " .. itemtable[i].name .. ", "
      end
   end
   
   result = result .. count_empty_equipment_slots(grid) .. " empty slots remaining "
   
   return result
end

--Remove equipment and then armor. laterdo "inv full" checks
function remove_equipment_and_armor(pindex)
   local armor_inv = game.get_player(pindex).get_inventory(defines.inventory.character_armor)
   local result = ""
   if armor_inv.is_empty() then
      return "No armor."
   end
   
   local grid 
   if players[pindex].menu == "vehicle" and game.get_player(pindex).opened.type == "spider-vehicle" then
      grid = game.get_player(pindex).opened.grid
   else
      grid = armor_inv[1].grid
   end
   if grid ~= nil and grid.valid then 
       local e_count = grid.count()
	   --Take all items
	   for i = 0, grid.width-1, 1 do
	      for j = 0, grid.height-1, 1 do
		     local check = grid.get({i,j})
			 local inv = game.get_player(pindex).get_main_inventory()
		     if check ~= nil and inv.can_insert({name = check.name}) then
			    inv.insert({name = check.name})
				grid.take{position = {i,j}}
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

function check_and_play_enemy_alert_sound(mode_in)
   for pindex, player in pairs(players) do
      local mode = mode_in or 1
      local p = game.get_player(pindex)
      if p ~= nil and p.valid then
         local nearest_enemy = p.surface.find_nearest_enemy{position = p.position, max_distance = 100, force = p.force}
         local dist = -1
         if nearest_enemy ~= nil and nearest_enemy.valid then
            dist = math.floor(util.distance(nearest_enemy.position,p.position))
         else
            return
         end
         --Attempt to detect if west or east
         local diffx = nearest_enemy.position.x - p.position.x
         local diffy = nearest_enemy.position.y - p.position.y
         local x_offset = 0
         if math.abs(diffx) > 2 * math.abs(diffy) then
            --Counts as east or west
            if diffx > 0 then 
               x_offset = 7
            elseif diffx < 0 then
               x_offset = -7
            end
         end
         local pos = {x = p.position.x + x_offset, y = p.position.y } 
         
         --Play sounds according to mode
         if mode == 1 then     -- Nearest enemy is far (lowest freq)
            if dist < 100 then
               p.play_sound{path = "alert-enemy-presence-low", position = pos}
            end
            --Additional alert if there are more than 5 enemies nearby
            local enemies = p.surface.find_enemy_units(p.position, 25, p.force)
            if #enemies > 5 then
               p.play_sound{path = "alert-enemy-presence-high", position = pos}
            else
               for i, enemy in ipairs(enemies) do 
                  --Also check for strong enemies: big/huge biters, huge spitters, medium or larger worms, not spawners
                  if enemy.prototype.max_health > 360 then
                     p.play_sound{path = "alert-enemy-presence-high", position = pos}
                     return
                  end
               end
            end
         elseif mode == 2 then -- Nearest enemy is closer (medium freq)
            if dist < 50 then
               p.play_sound{path = "alert-enemy-presence-low", position = pos}
            end
            --Additional alert if there are more than 10 enemies nearby
            local enemies = p.surface.find_enemy_units(p.position, 25, p.force)
            if #enemies > 10 then
               p.play_sound{path = "alert-enemy-presence-high", position = pos}
            end
         elseif mode == 3 then -- Nearest enemy is too close (highest freq)
            if dist < 25 then
               p.play_sound{path = "alert-enemy-presence-low", position = pos}
            end
         end
      end
   end
end

--Locks the cursor to the nearest enemy within 50 tiles. Also plays a sound if the enemy is within range of the gun in hand.
function aim_gun_at_nearest_enemy(pindex,enemy_in)
   local p = game.get_player(pindex)
   if p == nil or p.character == nil or p.character.valid == false then
      return
   end
   local gun_index  = p.character.selected_gun_index
   local guns_inv   = p.get_inventory(defines.inventory.character_guns)
   local ammo_inv   = game.get_player(pindex).get_inventory(defines.inventory.character_ammo)
   local gun_stack  = guns_inv[gun_index]
   local ammo_stack = ammo_inv[gun_index]
   local enemy = enemy_in
   --Return if missing a gun or ammo
   if gun_stack == nil or not gun_stack.valid_for_read or not gun_stack.valid then
      return false
   end
   if ammo_stack == nil or not ammo_stack.valid_for_read or not ammo_stack.valid then
      return false
   end
   --Return if in Cursor Mode
   if players[pindex].cursor then
      return false
   end
   --Return if in a menu
   if players[pindex].in_menu then
      return false
   end
   --Check for nearby enemies
   if enemy_in == nil or not enemy_in.valid then
      enemy = p.surface.find_nearest_enemy{position = p.position, max_distance = 50, force = p.force}
   end
   if enemy == nil or not enemy.valid then
      return false
   end
   --Play a sound when the enemy is within range of the gun 
   local range = gun_stack.prototype.attack_parameters.range
   local dist = util.distance(p.position,enemy.position)
   if dist < range and p.character.can_shoot(enemy,enemy.position) then      
      p.play_sound{path = "player-aim-locked",volume_modifier=0.5}
   end
   --Return if there is a gun and ammo combination that already aims by itself
   if gun_stack.name == "pistol" or gun_stack.name == "submachine-gun" and dist < 10 then --or ammo_stack.name == "rocket" or ammo_stack.name == "explosive-rocket" then
      --**Note: normal/explosive rockets only fire when they lock on a target anyway. Meanwhile the SMG auto-aims only when close enough 
      return true
   end 
   --If in range, move the cursor onto the enemy to aim the gun
   if dist < range then 
      players[pindex].cursor_pos = enemy.position
      move_mouse_pointer(enemy.position,pindex)
      cursor_highlight(pindex,nil,nil,true)
   end
   return true
end

--One-click repair pack usage.
function repair_pack_used(ent,pindex)
   local p = game.get_player(pindex)
   local stack = p.cursor_stack
   --Repair the entity found
   if ent and ent.valid and ent.is_entity_with_health and ent.get_health_ratio() < 1 
   and ent.type ~= "resource" and not ent.force.is_enemy(p.force) and ent.name ~= "character" then
      p.play_sound{path = "utility/default_manual_repair"}
      local health_diff = ent.prototype.max_health - ent.health
      local dura = stack.durability
      if health_diff < 10 then --free repair for tiny damages
         ent.health = ent.prototype.max_health 
         printout("Fully repaired " .. ent.name, pindex)
      elseif health_diff < dura then
         ent.health = ent.prototype.max_health 
         stack.drain_durability(health_diff)
         printout("Fully repaired " .. ent.name, pindex)
      else--if health_diff >= dura then
         stack.drain_durability(dura)
         ent.health = ent.health + dura
         printout("Partially repaired " .. ent.name .. " and consumed a repair pack", pindex)
         --Note: This automatically subtracts correctly and decerements the pack in hand.
      end
   end
   --Note: game.get_player(pindex).use_from_cursor{players[pindex].cursor_pos.x,players[pindex].cursor_pos.y}--This does not work.
end

--Tries to repair all relevant entities within a certain distance from the player
function repair_area(radius_in,pindex)
   local p = game.get_player(pindex)
   local stack = p.cursor_stack
   local repaired_count = 0
   local packs_used = 0
   local radius = math.min(radius_in,25)
   if stack.count < 2 then
      --If you are low on repair packs, stop
      printout("You need at least 2 repair packs to repair the area.",pindex)
      return 
   end
   local ents = p.surface.find_entities_filtered{position = p.position, radius = radius}
   for i,ent in ipairs(ents) do 
      --Repair the entity found
      if ent and ent.valid and ent.is_entity_with_health and ent.get_health_ratio() < 1 
      and ent.type ~= "resource" and not ent.force.is_enemy(p.force) and ent.name ~= "character" then
         p.play_sound{path = "utility/default_manual_repair"}
         local health_diff = ent.prototype.max_health - ent.health
         local dura = stack.durability
         if health_diff < 10 then --free repair for tiny damages
            ent.health = ent.prototype.max_health 
            repaired_count = repaired_count + 1
         elseif health_diff < dura then
            ent.health = ent.prototype.max_health 
            stack.drain_durability(health_diff)
            repaired_count = repaired_count + 1
         elseif stack.count < 2 then
            --If you are low on repair packs, stop
            printout("Repaired " .. repaired_count .. " structures using " .. packs_used .. " repair packs, stopped because you are low on repair packs.",pindex)
            return 
         else
            --Finish the current repair pack
            stack.drain_durability(dura)
            packs_used = packs_used + 1
            ent.health = ent.health + dura
            
            --Repeat unhtil fully repaired or out of packs
            while ent.get_health_ratio() < 1 do
               health_diff = ent.prototype.max_health - ent.health
               dura = stack.durability
               if health_diff < 10 then --free repair for tiny damages
                  ent.health = ent.prototype.max_health 
                  repaired_count = repaired_count + 1
               elseif health_diff < dura then
                  ent.health = ent.prototype.max_health 
                  stack.drain_durability(health_diff)
                  repaired_count = repaired_count + 1
               elseif stack.count < 2 then
                  --If you are low on repair packs, stop
                  printout("Repaired " .. repaired_count .. " structures using " .. packs_used .. " repair packs, stopped because you are low on repair packs.",pindex)
                  return 
               else
                  --Finish the current repair pack
                  stack.drain_durability(dura)
                  packs_used = packs_used + 1
                  ent.health = ent.health + dura
               end
            end 
         end
      end
   end
   if repaired_count == 0 then
      printout("Nothing to repair within " .. radius .. " tiles of you.",pindex)
      return
   end
   printout("Repaired all " .. repaired_count .. " structures within " .. radius .. " tiles of you, using " .. packs_used .. " repair packs.",pindex)
end