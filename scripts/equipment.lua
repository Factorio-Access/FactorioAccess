--Here: functions relating to guns and equipment management
--Does not include event handlers, combat, repair packs

local Electrical = require("scripts.electrical")
local FaUtils = require("scripts.fa-utils")
local localising = require("scripts.localising")
local Speech = require("scripts.speech")
local UiRouter = require("scripts.ui.router")

local mod = {}

--Tries to equip a stack. For now called only for a stack in hand when the only the inventory is open.
-- Precondition: Caller must ensure stack is valid_for_read
function mod.equip_it(stack, pindex)
   local router = UiRouter.get_router(pindex)

   local message = Speech.new()

   if stack.is_armor then
      local armor = game.get_player(pindex).get_inventory(defines.inventory.character_armor)
      if armor.is_empty() then
         message:fragment({ "fa.equipment-equipped", localising.get_localised_name_with_fallback(stack) })
      else
         message:fragment({
            "fa.equipment-equipped-swap",
            localising.get_localised_name_with_fallback(stack),
            localising.get_localised_name_with_fallback(armor[1]),
         })
      end
      stack.swap_stack(armor[1])
      storage.players[pindex].skip_read_hand = true
   elseif stack.type == "gun" then
      --Equip gun ("arms")
      local gun_inv = game.get_player(pindex).get_inventory(defines.inventory.character_guns)
      if gun_inv.can_insert(stack) then
         local inserted = gun_inv.insert(stack)
         message:fragment({ "fa.equipment-equipped", localising.get_localised_name_with_fallback(stack) })
         stack.count = stack.count - inserted
         storage.players[pindex].skip_read_hand = true
      else
         if gun_inv.count_empty_stacks() == 0 then
            message:fragment({ "fa.equipment-gun-slots-full" })
         else
            message:fragment({ "fa.equipment-cannot-insert", localising.get_localised_name_with_fallback(stack) })
         end
      end
   elseif stack.type == "ammo" then
      --Equip ammo
      local ammo_inv = game.get_player(pindex).get_inventory(defines.inventory.character_ammo)
      if ammo_inv.can_insert(stack) then
         local inserted = ammo_inv.insert(stack)
         message:fragment({ "fa.equipment-reloaded", localising.get_localised_name_with_fallback(stack) })
         stack.count = stack.count - inserted
         storage.players[pindex].skip_read_hand = true
      else
         if ammo_inv.count_empty_stacks() == 0 then
            message:fragment({ "fa.equipment-ammo-slots-full" })
         else
            message:fragment({ "fa.equipment-cannot-insert", localising.get_localised_name_with_fallback(stack) })
         end
      end
   elseif stack.prototype.place_as_equipment_result ~= nil then
      --Equip equipment ("gear")
      local armor_inv
      local grid
      armor_inv = game.get_player(pindex).get_inventory(defines.inventory.character_armor)
      if armor_inv.is_empty() then return "Equipment requires armor with an equipment grid." end
      if armor_inv[1].grid == nil or not armor_inv[1].grid.valid then
         return "Equipment requires armor with an equipment grid."
      end
      grid = armor_inv[1].grid
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
         message:fragment({
            "fa.equipment-equipped-grid",
            localising.get_localised_name_with_fallback(stack),
            tostring(slots_left),
         })
         stack.count = stack.count - 1
         storage.players[pindex].skip_read_hand = true
      else
         --Check if the grid is full
         if slots_left == 0 then
            message:fragment({ "fa.equipment-grid-full" })
         else
            message:fragment({ "fa.equipment-no-fit", tostring(slots_left) })
         end
      end
   elseif stack.prototype.place_result ~= nil or stack.prototype.place_as_tile_result ~= nil then
      return ""
   else
      message:fragment({ "fa.equipment-cannot-equip", localising.get_localised_name_with_fallback(stack) })
   end

   return message:build()
end

--Returns info on weapons and ammo
function mod.read_weapons_and_ammo(pindex)
   local guns_inv = game.get_player(pindex).get_inventory(defines.inventory.character_guns)
   local ammo_inv = game.get_player(pindex).get_inventory(defines.inventory.character_ammo)
   local guns_count = #guns_inv - guns_inv.count_empty_stacks()
   local ammos_count = #ammo_inv - ammo_inv.count_empty_stacks()

   if guns_count == 0 then return { "fa.equipment-no-weapons" } end

   local result = Speech.new()
   result:fragment({ "fa.equipment-weapons-header" })

   for i = 1, 3, 1 do
      if i > 1 then result:fragment({ "fa.equipment-and" }) end
      if guns_inv[i] and guns_inv[i].valid and guns_inv[i].valid_for_read then
         result:fragment(localising.get_localised_name_with_fallback(guns_inv[i]))
      else
         result:fragment({ "fa.equipment-empty-weapon-slot" })
      end
      if ammo_inv[i] ~= nil and ammo_inv[i].valid and ammo_inv[i].valid_for_read then
         result:fragment({
            "fa.equipment-with-ammo",
            tostring(ammo_inv[i].count),
            localising.get_localised_name_with_fallback(ammo_inv[i]),
         })
      else
         result:fragment({ "fa.equipment-no-ammunition" })
      end
   end

   return result:build()
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

   message = { "fa.equipment-collected-stacks", tostring(resulted_remove_count), tostring(expected_remove_count) }
   if main_inv.count_empty_stacks() == 0 then message = { "", message, { "fa.inventory-full" } } end

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
   local restore_count = storage.players[pindex].restore_count
   if restore_count == nil or restore_count < resulted_remove_count then
      storage.players[pindex].restore_count = resulted_remove_count
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
   local restore_count = storage.players[pindex].restore_count
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
         table.insert(result, { "fa.equipment-shield-percent", tostring(shield_left) })
      else
         empty_shield = true
      end
   end
   --Check health
   if ent.is_entity_with_health then
      if ent.get_health_ratio() == 1 then
         table.insert(result, { "fa.ent-status-full-health" })
      else
         table.insert(result, { "fa.ent-status-percent-health", math.floor(ent.get_health_ratio() * 100) })
      end
   end
   -- State shield empty at the end (if supported)
   if grid and empty_shield then table.insert(result, { "fa.armor-shield-empty" }) end
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
         table.insert(result, { "fa.armor-no-armor" })
         return result
      elseif armor_inv[1].grid == nil or not armor_inv[1].grid.valid then
         table.insert(
            result,
            { "fa.armor-equipped-no-grid", localising.get_localised_name_with_fallback(armor_inv[1].prototype) }
         )
         return result
      end
      --Player armor with non-empty equipment grid
      grid = armor_inv[1].grid
      table.insert(result, { "fa.armor-equipped", localising.get_localised_name_with_fallback(armor_inv[1].prototype) })
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
      table.insert(result, { "fa.armor-no-equipment" })
      return result
   end
   --Read battery level
   if grid.battery_capacity > 0 then
      if grid.available_in_batteries == grid.battery_capacity then
         table.insert(result, { "fa.armor-batteries-full" })
      elseif grid.available_in_batteries == 0 then
         table.insert(result, { "fa.armor-batteries-empty" })
      else
         local battery_level = math.ceil(100 * grid.available_in_batteries / grid.battery_capacity)
         table.insert(result, { "fa.armor-batteries-percent", tostring(battery_level) })
      end
   else
      table.insert(result, { "fa.armor-no-batteries" })
   end
   --Energy Producers
   if grid.get_generator_energy() > 0 or grid.max_solar_energy > 0 then
      table.insert(result, { "fa.armor-generating" })
      if grid.get_generator_energy() > 0 then
         table.insert(
            result,
            { "fa.armor-power-nonstop", Electrical.get_power_string(grid.get_generator_energy() * 60) }
         )
      end
      if grid.max_solar_energy > 0 then
         table.insert(result, { "fa.armor-power-daytime", Electrical.get_power_string(grid.max_solar_energy * 60) })
      end
   end
   --Movement bonus
   if grid.count("exoskeleton-equipment") > 0 then
      table.insert(result, {
         "fa.armor-movement-bonus",
         tostring(grid.count("exoskeleton-equipment") * 30),
         Electrical.get_power_string(grid.count("exoskeleton-equipment") * 200000),
      })
   end
   return result
end

--List armor equipment
function mod.read_equipment_list(pindex)
   local router = UiRouter.get_router(pindex)

   local armor_inv = game.get_player(pindex).get_inventory(defines.inventory.character_armor)
   if armor_inv.is_empty() then return { "fa.equipment-no-armor" } end
   if armor_inv[1].grid == nil or not armor_inv[1].grid.valid then return { "fa.equipment-no-grid" } end
   --Armor with Equipment
   local grid
   local result = Speech.new()
   grid = armor_inv[1].grid
   result:fragment({ "fa.equipment-armor" })
   if grid.equipment == nil or grid.equipment == {} then return { "fa.equipment-no-equipment-installed" } end
   --Read Equipment List
   result:fragment({ "fa.equipment-equipped-header" })
   local contents = grid.get_contents()
   local itemtable = {}
   for name, count in pairs(contents) do
      table.insert(itemtable, { name = name, count = count })
   end
   if #itemtable == 0 then
      result:fragment({ "fa.equipment-nothing" })
   else
      for i = 1, #itemtable, 1 do
         result:fragment({
            "fa.equipment-item-count",
            tostring(itemtable[i].count),
            { "item-name." .. itemtable[i].name },
         })
         result:fragment(", ")
      end
   end

   result:fragment({ "fa.equipment-empty-slots", tostring(mod.count_empty_equipment_slots(grid)) })

   return result:build()
end

--Remove all armor equipment and then the armor. laterdo "inv full" checks
function mod.remove_equipment_and_armor(pindex)
   local router = UiRouter.get_router(pindex)

   local armor_inv = game.get_player(pindex).get_inventory(defines.inventory.character_armor)
   local char_main_inv = game.get_player(pindex).get_inventory(defines.inventory.character_main)
   local result = ""
   if armor_inv.is_empty() then return "No armor." end

   local grid
   grid = armor_inv[1].grid
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
      result = {
         "fa.equipment-collected-items",
         tostring(initial_equipment_count - grid.count()),
         tostring(initial_equipment_count),
      }
   end

   --Remove armor
   if char_main_inv.count_empty_stacks() == 0 then
      result = { "", result, { "fa.inventory-full" } }
   else
      result =
         { "", result, { "fa.equipment-removed-armor", localising.get_localised_name_with_fallback(armor_inv[1]) } }
      game.get_player(pindex).clear_cursor()
      local stack2 = game.get_player(pindex).cursor_stack
      stack2.swap_stack(armor_inv[1])
      game.get_player(pindex).clear_cursor()
   end

   return result
end

return mod
