--Here: functions relating to guns and equipment management
--Does not include event handlers, combat, repair packs

local Electrical = require("scripts.electrical")
local FaUtils = require("scripts.fa-utils")
local ItemStackUtils = require("scripts.item-stack-utils")
local localising = require("scripts.localising")
local Localising = require("scripts.localising")
local Speech = require("scripts.speech")
local MessageBuilder = Speech.MessageBuilder
local UiRouter = require("scripts.ui.router")
local TH = require("scripts.table-helpers")

local mod = {}

---Common equip logic: equips from a LuaItemStack to an entity
---Modifies the source stack (decrements count or swaps for armor)
---@param stack LuaItemStack The stack to equip from (will be modified)
---@param target_entity LuaEntity Entity to equip to
---@param pindex number Player index (for by_player parameter)
---@param message fa.MessageBuilder Message builder to append results to
---@return boolean success True if anything was equipped
local function equip_stack_to_entity(stack, target_entity, pindex, message)
   if not stack.valid_for_read then
      message:fragment("Error: stack not valid for read")
      return false
   end

   local item_name = stack.name
   local item_type = stack.type
   local prototype = stack.prototype

   if stack.is_armor then
      local armor_inv = target_entity.get_inventory(defines.inventory.character_armor)
      if not armor_inv then return false end

      if armor_inv.is_empty() then
         message:fragment({ "fa.equipment-equipped", localising.get_localised_name_with_fallback(stack) })
      else
         message:fragment({
            "fa.equipment-equipped-swap",
            localising.get_localised_name_with_fallback(stack),
            localising.get_localised_name_with_fallback(armor_inv[1]),
         })
      end
      stack.swap_stack(armor_inv[1])
      return true
   elseif item_type == "gun" then
      local gun_inv = target_entity.get_inventory(defines.inventory.character_guns)
      if not gun_inv then return false end

      if gun_inv.can_insert(stack) then
         local inserted = gun_inv.insert(stack)
         message:fragment({ "fa.equipment-equipped", localising.get_localised_name_with_fallback(stack) })
         stack.count = stack.count - inserted
         return inserted > 0
      else
         if gun_inv.count_empty_stacks() == 0 then
            message:fragment({ "fa.equipment-gun-slots-full" })
         else
            message:fragment({ "fa.equipment-cannot-insert", localising.get_localised_name_with_fallback(stack) })
         end
         return false
      end
   elseif item_type == "ammo" then
      local ammo_inv = target_entity.get_inventory(defines.inventory.character_ammo)
      if not ammo_inv then return false end

      if ammo_inv.can_insert(stack) then
         local inserted = ammo_inv.insert(stack)
         message:fragment({ "fa.equipment-reloaded", localising.get_localised_name_with_fallback(stack) })
         stack.count = stack.count - inserted
         return inserted > 0
      else
         if ammo_inv.count_empty_stacks() == 0 then
            message:fragment({ "fa.equipment-ammo-slots-full" })
         else
            message:fragment({ "fa.equipment-cannot-insert", localising.get_localised_name_with_fallback(stack) })
         end
         return false
      end
   elseif prototype.place_as_equipment_result ~= nil then
      -- Get grid - either from armor (characters) or directly from entity (vehicles)
      local grid = target_entity.grid
      if not grid then
         message:fragment({ "fa.equipment-error-no-grid", target_entity.name })
         return false
      end
      local placed = nil
      for i = 0, grid.width - 1 do
         for j = 0, grid.height - 1 do
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
         return true
      else
         if slots_left == 0 then
            message:fragment({ "fa.equipment-grid-full" })
         else
            message:fragment({ "fa.equipment-no-fit", tostring(slots_left) })
         end
         return false
      end
   elseif prototype.place_result ~= nil or prototype.place_as_tile_result ~= nil then
      return false -- Buildable item, not equippable
   else
      -- Fall through. For bad code quality reasons, not setting a message lets inventory transfers work. Soon, this
      -- will be done via an equipment grid instead.
      return false
   end
end

--Tries to equip a stack from hand. Called when SHIFT+[ pressed with inventory open.
-- Precondition: Caller must ensure stack is valid_for_read
function mod.equip_it(stack, pindex, target_entity)
   local p = game.get_player(pindex)
   if not p then return "" end

   -- Default to player character if no target specified
   local entity = target_entity or p.character
   if not entity then return "" end

   local message = MessageBuilder.new()

   local success = equip_stack_to_entity(stack, entity, pindex, message)

   if success then storage.players[pindex].skip_read_hand = true end

   return message:build()
end

--Returns info on weapons and ammo
function mod.read_weapons_and_ammo(pindex)
   local guns_inv = game.get_player(pindex).get_inventory(defines.inventory.character_guns)
   local ammo_inv = game.get_player(pindex).get_inventory(defines.inventory.character_ammo)
   local guns_count = #guns_inv - guns_inv.count_empty_stacks()
   local ammos_count = #ammo_inv - ammo_inv.count_empty_stacks()

   if guns_count == 0 then return { "fa.equipment-no-weapons" } end

   local result = MessageBuilder.new()
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
---@param pindex number
---@param source_entity LuaEntity? Entity containing source inventory (defaults to player character)
---@param source_inv_index defines.inventory? Source inventory index (defaults to character_main)
---@param target_entity LuaEntity? Entity containing ammo inventory (defaults to player character)
function mod.reload_weapons(pindex, source_entity, source_inv_index, target_entity)
   local p = game.get_player(pindex)

   -- Default to player character inventories
   local ammo_ent = target_entity or p.character
   local source_ent = source_entity or p.character

   if not ammo_ent or not source_ent then return { "fa.equipment-error-no-character-entity" } end

   local ammo_inv = ammo_ent.get_inventory(defines.inventory.character_ammo)
   local main_inv = source_ent.get_inventory(source_inv_index or defines.inventory.character_main)

   if not ammo_inv or not main_inv then return "Error: Invalid inventory" end

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
      result = { "fa.equipment-fully-reloaded" }
   elseif moved_key_count == 0 then
      result = { "fa.equipment-error-no-ammo-found" }
   else
      result = { "fa.equipment-reloaded-partial" }
   end
   return result
end

--Move all weapons and ammo back to inventory
---@param pindex number
---@param source_entity LuaEntity? Entity containing guns/ammo (defaults to player character)
---@param target_entity LuaEntity? Entity to receive items (defaults to player character)
---@param target_inv_index defines.inventory? Target inventory index (defaults to character_main)
function mod.remove_weapons_and_ammo(pindex, source_entity, target_entity, target_inv_index)
   local p = game.get_player(pindex)

   -- Default to player character inventories
   local source_ent = source_entity or p.character
   local target_ent = target_entity or p.character

   if not source_ent or not target_ent then return { "fa.equipment-error-no-character-entity" } end

   local guns_inv = source_ent.get_inventory(defines.inventory.character_guns)
   local ammo_inv = source_ent.get_inventory(defines.inventory.character_ammo)
   local main_inv = target_ent.get_inventory(target_inv_index or defines.inventory.character_main)

   if not guns_inv or not ammo_inv or not main_inv then return "Error: Invalid inventory" end

   local guns_count = #guns_inv - guns_inv.count_empty_stacks()
   local ammos_count = #ammo_inv - ammo_inv.count_empty_stacks()
   local expected_remove_count = guns_count + ammos_count
   local resulted_remove_count = 0
   local message = ""

   --Abort if not enough empty slots in inventory
   if main_inv.count_empty_stacks() < 6 then return { "fa.equipment-error-not-enough-slots" } end

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
         table.insert(result, { "fa.equipment-no-character" })
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
   local result = MessageBuilder.new()
   grid = armor_inv[1].grid
   result:fragment({ "fa.equipment-armor" })
   if grid.equipment == nil or grid.equipment == {} then return { "fa.equipment-no-equipment-installed" } end
   --Read Equipment List
   result:fragment({ "fa.equipment-equipped-header" })
   local contents = grid.get_contents()
   -- contents is an array of {name=string, count=uint, quality=string}
   if #contents == 0 then
      result:fragment({ "fa.equipment-nothing" })
   else
      for i = 1, #contents do
         local item = contents[i]
         result:list_item({
            "fa.equipment-item-count",
            tostring(item.count),
            { "equipment-name." .. item.name },
         })
      end
   end

   result:fragment({ "fa.equipment-empty-slots", tostring(mod.count_empty_equipment_slots(grid)) })

   return result:build()
end

--Remove all armor equipment and then the armor
---@param pindex number
---@param source_entity LuaEntity? Entity containing armor (defaults to player character)
---@param target_entity LuaEntity? Entity to receive items (defaults to player character)
---@param target_inv_index defines.inventory? Target inventory index (defaults to character_main)
function mod.remove_equipment_and_armor(pindex, source_entity, target_entity, target_inv_index)
   local p = game.get_player(pindex)

   -- Default to player character inventories
   local source_ent = source_entity or p.character
   local target_ent = target_entity or p.character

   if not source_ent or not target_ent then return { "fa.equipment-error-no-character-entity" } end

   local armor_inv = source_ent.get_inventory(defines.inventory.character_armor)
   local char_main_inv = target_ent.get_inventory(target_inv_index or defines.inventory.character_main)

   if not armor_inv or not char_main_inv then return "Error: Invalid inventory" end

   local result = ""
   if armor_inv.is_empty() then return { "fa.equipment-error-no-armor" } end

   local grid
   grid = armor_inv[1].grid
   if grid ~= nil and grid.valid then
      local initial_equipment_count = grid.count()
      --Take all items
      for i = 0, grid.width - 1, 1 do
         for j = 0, grid.height - 1, 1 do
            local check = grid.get({ i, j })
            if check ~= nil and char_main_inv.can_insert({ name = check.name }) then
               char_main_inv.insert({ name = check.name })
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
      p.clear_cursor()
      local stack2 = p.cursor_stack
      stack2.swap_stack(armor_inv[1])
      p.clear_cursor()
   end

   return result
end

--Repair an item in a specific inventory slot using repair pack from hand
---@param pindex number
---@param entity LuaEntity Entity containing the inventory
---@param inv_index defines.inventory Inventory index
---@param slot_index number Slot index (1-based)
---@return LocalisedString|string Result message
function mod.repair_item_in_slot(pindex, entity, inv_index, slot_index)
   local p = game.get_player(pindex)
   if not p then return "Error: No player" end

   local repair_pack = p.cursor_stack
   if not repair_pack or not repair_pack.valid_for_read or not repair_pack.is_repair_tool then
      return "Error: No repair pack in hand"
   end

   if not entity or not entity.valid then return "Error: Invalid entity" end

   local inv = entity.get_inventory(inv_index)
   if not inv then return "Error: Invalid inventory" end

   local stack = inv[slot_index]
   if not stack or not stack.valid_for_read then return { "fa.equipment-no-item-to-repair" } end

   -- Check if item has durability/health
   local health = stack.health
   if not health or health >= 1.0 then
      return { "fa.equipment-item-full-health", localising.get_localised_name_with_fallback(stack) }
   end

   -- Repair the item
   local repair_amount = 0.1 -- 10% repair per use, adjust as needed
   stack.health = math.min(1.0, health + repair_amount)

   -- Consume repair pack durability
   repair_pack.drain_durability(10) -- Adjust cost as needed

   return {
      "fa.equipment-repaired-item",
      localising.get_localised_name_with_fallback(stack),
      tostring(math.floor(stack.health * 100)),
   }
end

--Equip an item from a specific inventory slot to an entity
---@param pindex number
---@param source_entity LuaEntity Entity containing the inventory with the item
---@param inv_index defines.inventory Inventory index
---@param slot_index number Slot index (1-based)
---@return LocalisedString|string Result message
function mod.equip_item_from_slot(pindex, source_entity, inv_index, slot_index)
   local p = game.get_player(pindex)
   if not p then return "Error: No player" end

   if not source_entity or not source_entity.valid then return "Error: Invalid entity" end

   local inv = source_entity.get_inventory(inv_index)
   if not inv then return "Error: Invalid inventory" end

   local stack = inv[slot_index]
   if not stack or not stack.valid_for_read then return { "fa.equipment-empty-slot" } end

   local message = MessageBuilder.new()

   -- Equip to the entity that owns this inventory
   equip_stack_to_entity(stack, source_entity, pindex, message)

   return message:build()
end

---Get category description for equipment
---@param equipment LuaEquipment
---@return LocalisedString
function mod.get_equipment_category(equipment)
   local type_name = equipment.type
   if type_name == "battery-equipment" then
      return { "fa.equipment-category-battery" }
   elseif type_name == "energy-shield-equipment" then
      return { "fa.equipment-category-shield" }
   elseif type_name == "solar-panel-equipment" then
      return { "fa.equipment-category-solar-panel" }
   elseif type_name == "generator-equipment" then
      return { "fa.equipment-category-generator" }
   elseif type_name == "roboport-equipment" then
      return { "fa.equipment-category-roboport" }
   elseif type_name == "night-vision-equipment" then
      return { "fa.equipment-category-night-vision" }
   elseif type_name == "belt-immunity-equipment" then
      return { "fa.equipment-category-belt-immunity" }
   elseif type_name == "active-defense-equipment" then
      return { "fa.equipment-category-active-defense" }
   elseif type_name == "movement-bonus-equipment" then
      return { "fa.equipment-category-exoskeleton" }
   elseif type_name == "inventory-bonus-equipment" then
      return { "fa.equipment-category-inventory-expansion" }
   else
      return { "fa.equipment-category-generic" }
   end
end

---Get the ordinal number for an equipment piece when there are multiple of the same type
---@param grid LuaEquipmentGrid
---@param equipment_to_find LuaEquipment
---@return number? ordinal The ordinal number (1, 2, 3...) or nil if only one exists
function mod.get_ordinal_for_equipment(grid, equipment_to_find)
   -- Get all equipment of the same type and quality
   local matching = {}
   for _, equip in ipairs(grid.equipment) do
      if
         equip.prototype.name == equipment_to_find.prototype.name
         and equip.quality.name == equipment_to_find.quality.name
      then
         table.insert(matching, equip)
      end
   end

   -- If only one of this type, no ordinal needed
   if #matching <= 1 then return nil end

   -- Sort by position (top to bottom, left to right)
   table.sort(matching, function(a, b)
      if a.position.y ~= b.position.y then return a.position.y < b.position.y end
      return a.position.x < b.position.x
   end)

   -- Find the ordinal
   for i, equip in ipairs(matching) do
      if equip == equipment_to_find then return i end
   end

   return nil
end

---Get label for an equipment piece (main navigation label)
---@param grid LuaEquipmentGrid
---@param equipment LuaEquipment
---@return LocalisedString
function mod.get_equipment_label(grid, equipment)
   local mb = MessageBuilder.new()

   -- Equipment name with quality
   local equip_name = localising.get_localised_name_with_fallback(equipment.prototype)

   -- Get ordinal if multiple of same type exist
   local ordinal = mod.get_ordinal_for_equipment(grid, equipment)

   if equipment.quality and equipment.quality.name ~= "normal" then
      local quality_name = localising.get_localised_name_with_fallback(equipment.quality)
      mb:fragment(quality_name):fragment(equip_name)
   else
      mb:fragment(equip_name)
   end

   -- Add ordinal if needed
   if ordinal then mb:fragment(tostring(ordinal)) end

   -- Add to be removed flag
   if equipment.to_be_removed then mb:list_item("marked for removal") end

   -- Add category
   mb:list_item(mod.get_equipment_category(equipment))

   -- Add power production if applicable
   if equipment.max_solar_power > 0 then
      mb:list_item({ "fa.equipment-produces", FaUtils.format_power(equipment.max_solar_power) })
   end

   if equipment.generator_power > 0 then
      mb:list_item({ "fa.equipment-produces", FaUtils.format_power(equipment.generator_power * 60) })
   end

   -- Add shield status if applicable
   if equipment.max_shield > 0 then
      local shield_percent = math.floor((equipment.shield / equipment.max_shield) * 100)
      mb:list_item({ "fa.equipment-shield-percent", shield_percent })
   end

   return mb:build()
end

---Get detailed info for an equipment piece (for read_coords / k key)
---@param grid LuaEquipmentGrid
---@param equipment LuaEquipment
---@return LocalisedString
function mod.get_equipment_info(grid, equipment)
   local mb = MessageBuilder.new()

   -- Basic label
   mb:fragment(mod.get_equipment_label(grid, equipment))

   -- Add dimensions
   local shape = equipment.shape
   mb:list_item(string.format("%d by %d", shape.width, shape.height))

   -- Add battery capacity if applicable
   if equipment.max_energy > 0 then
      mb:list_item({ "fa.equipment-capacity", FaUtils.format_power(equipment.max_energy) })
   end

   -- Add movement bonus if applicable
   if equipment.movement_bonus > 0 then
      local bonus_percent = math.floor(equipment.movement_bonus * 100)
      mb:list_item({ "fa.equipment-movement-bonus", bonus_percent })
   end

   -- Add inventory bonus if applicable
   if equipment.inventory_bonus > 0 then mb:list_item({ "fa.equipment-inventory-bonus", equipment.inventory_bonus }) end

   -- Add current energy for batteries
   if equipment.max_energy > 0 then
      local energy_percent = math.floor((equipment.energy / equipment.max_energy) * 100)
      mb:list_item({ "fa.equipment-energy-stored", FaUtils.format_power(equipment.energy), energy_percent })
   end

   return mb:build()
end

---Get aggregated equipment items from an entity
---@param entity LuaEntity
---@return table[] Array of {name, quality, count, stacks}
function mod.get_equipment_items_from_entity(entity)
   if not entity or not entity.valid then return {} end

   -- Equipment filter: only items that can be placed as equipment
   local equipment_filter = function(stack)
      return stack.prototype.place_as_equipment_result ~= nil
   end

   -- Collect all inventories from entity
   local inventories = {}
   for _, inv_type in ipairs({
      defines.inventory.character_main,
      defines.inventory.car_trunk,
      defines.inventory.cargo_wagon,
      defines.inventory.chest,
      defines.inventory.spider_trunk,
   }) do
      local inv = entity.get_inventory(inv_type)
      if inv then table.insert(inventories, inv) end
   end

   -- Aggregate across all inventories
   return ItemStackUtils.aggregate_inventories(inventories, equipment_filter)
end

---Check if equipment can fit in given dimensions
---@param equipment_proto_name string
---@param max_x number?
---@param max_y number?
---@return boolean
function mod.can_equipment_fit(equipment_proto_name, max_x, max_y)
   if not max_x or not max_y then return true end

   local item_proto = prototypes.item[equipment_proto_name]
   if not item_proto or not item_proto.place_as_equipment_result then return false end

   local equipment_proto = item_proto.place_as_equipment_result
   return equipment_proto.shape.width <= max_x and equipment_proto.shape.height <= max_y
end

---Sort aggregated equipment for selection menu
---@param items table[] Array from get_equipment_items_from_entity
---@param max_x number?
---@param max_y number?
---@return table[] Sorted array of {name, quality, count, stacks, fits}
function mod.sort_equipment_items(items, max_x, max_y)
   -- Add fit information to each item
   for _, item in ipairs(items) do
      item.fits = mod.can_equipment_fit(item.name, max_x, max_y)
   end

   -- Sort
   table.sort(items, function(a, b)
      -- If dimensions given, sort by fit first (fits come first)
      if max_x and max_y then
         if a.fits ~= b.fits then return a.fits end
      end

      -- Sort by prototype name (string)
      if a.name ~= b.name then return a.name < b.name end

      -- Sort by quality level (decreasing)
      local a_quality = prototypes.quality[a.quality]
      local b_quality = prototypes.quality[b.quality]
      return a_quality.level > b_quality.level
   end)

   return items
end

---Add equipment selection rows to a menu builder
---@param builder fa.ui.menu.MenuBuilder
---@param params table {character, equip_target, max_x, max_y}
---@param on_select_callback fun(equip_data: table) Called when equipment is selected
function mod.add_equipment_selection_rows(builder, params, on_select_callback)
   local character = params.character
   local equip_target = params.equip_target
   local max_x = params.max_x
   local max_y = params.max_y

   -- Gather and sort equipment from both sources
   local character_items = character and mod.get_equipment_items_from_entity(character) or {}
   local character_sorted = mod.sort_equipment_items(character_items, max_x, max_y)

   -- Only show entity items if it's a different entity from character
   local show_entity_row = equip_target and (not character or equip_target ~= character)
   local entity_items = show_entity_row and mod.get_equipment_items_from_entity(equip_target) or {}
   local entity_sorted = mod.sort_equipment_items(entity_items, max_x, max_y)

   -- Helper to get equipment prototype for dimensions
   local function get_equipment_dimensions(proto_name)
      local item_proto = prototypes.item[proto_name]
      if not item_proto or not item_proto.place_as_equipment_result then return nil end
      local equip_proto = item_proto.place_as_equipment_result
      return equip_proto.shape.width, equip_proto.shape.height
   end

   -- Row 1: Equipment from character inventory
   if #character_sorted > 0 then
      builder:start_row("inventory")
      -- Add row header
      builder:add_label("inventory-header", { "fa.equipment-selector-your-inventory" })
      for _, equip_data in ipairs(character_sorted) do
         local key = string.format("inventory-%s-%s", equip_data.name, equip_data.quality)
         local width, height = get_equipment_dimensions(equip_data.name)

         builder:add_clickable(key, function(label_ctx)
            -- Use localise_item to build label (handles quality automatically)
            label_ctx.message:list_item(Localising.localise_item(equip_data.stacks[1]))

            -- Add dimensions
            if width and height then label_ctx.message:list_item(string.format("%d by %d", width, height)) end

            -- Add "doesn't fit" if dimensions provided and doesn't fit
            if max_x and max_y and not equip_data.fits then
               label_ctx.message:list_item({ "fa.equipment-selector-doesnt-fit" })
            end
         end, {
            on_click = function(click_ctx)
               on_select_callback(equip_data)
            end,
            on_read_coords = function(info_ctx)
               -- Show full equipment info (dimensions, category, power, etc.)
               -- Since we don't have an actual placed equipment, build info manually
               local item_proto = prototypes.item[equip_data.name]
               if item_proto and item_proto.place_as_equipment_result then
                  local equip_proto = item_proto.place_as_equipment_result
                  local mb = MessageBuilder.new()

                  -- Dimensions
                  mb:list_item(string.format("%d by %d", equip_proto.shape.width, equip_proto.shape.height))

                  -- Category
                  mb:list_item(mod.get_equipment_category_from_type(equip_proto.type))

                  info_ctx.message:fragment(mb:build())
               end
            end,
         })
      end
      builder:end_row()
   else
      builder:add_label("inventory-empty", { "fa.equipment-selector-no-inventory" })
   end

   -- Row 2: Equipment from entity (only if different from character)
   if show_entity_row and #entity_sorted > 0 then
      builder:start_row("entity")
      -- Add row header
      builder:add_label("entity-header", { "fa.equipment-selector-entity-inventory" })
      for _, equip_data in ipairs(entity_sorted) do
         local key = string.format("entity-%s-%s", equip_data.name, equip_data.quality)
         local width, height = get_equipment_dimensions(equip_data.name)

         builder:add_clickable(key, function(label_ctx)
            -- Use localise_item to build label (handles quality automatically)
            label_ctx.message:list_item(Localising.localise_item(equip_data.stacks[1]))

            -- Add dimensions
            if width and height then label_ctx.message:list_item(string.format("%d by %d", width, height)) end

            -- Add "doesn't fit" if dimensions provided and doesn't fit
            if max_x and max_y and not equip_data.fits then
               label_ctx.message:list_item({ "fa.equipment-selector-doesnt-fit" })
            end
         end, {
            on_click = function(click_ctx)
               on_select_callback(equip_data)
            end,
            on_read_coords = function(info_ctx)
               -- Show full equipment info
               local item_proto = prototypes.item[equip_data.name]
               if item_proto and item_proto.place_as_equipment_result then
                  local equip_proto = item_proto.place_as_equipment_result
                  local mb = MessageBuilder.new()

                  -- Dimensions
                  mb:list_item(string.format("%d by %d", equip_proto.shape.width, equip_proto.shape.height))

                  -- Category
                  mb:list_item(mod.get_equipment_category_from_type(equip_proto.type))

                  info_ctx.message:fragment(mb:build())
               end
            end,
         })
      end
      builder:end_row()
   elseif show_entity_row then
      builder:add_label("entity-empty", { "fa.equipment-selector-no-entity" })
   end
end

---Get equipment category string from equipment type
---@param equip_type string
---@return LocalisedString
function mod.get_equipment_category_from_type(equip_type)
   if equip_type == "battery-equipment" then
      return { "fa.equipment-category-battery" }
   elseif equip_type == "energy-shield-equipment" then
      return { "fa.equipment-category-shield" }
   elseif equip_type == "solar-panel-equipment" then
      return { "fa.equipment-category-solar-panel" }
   elseif equip_type == "generator-equipment" then
      return { "fa.equipment-category-generator" }
   elseif equip_type == "roboport-equipment" then
      return { "fa.equipment-category-roboport" }
   elseif equip_type == "active-defense-equipment" then
      return { "fa.equipment-category-active-defense" }
   elseif equip_type == "night-vision-equipment" then
      return { "fa.equipment-category-night-vision" }
   elseif equip_type == "belt-immunity-equipment" then
      return { "fa.equipment-category-belt-immunity" }
   elseif equip_type == "movement-bonus-equipment" then
      return { "fa.equipment-category-movement-bonus" }
   elseif equip_type == "inventory-bonus-equipment" then
      return { "fa.equipment-category-inventory-expansion" }
   else
      return { "fa.equipment-category-generic" }
   end
end

return mod
