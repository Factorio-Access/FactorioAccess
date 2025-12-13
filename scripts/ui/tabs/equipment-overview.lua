--[[
Equipment overview tab showing armor, equipment, and quick equip options.
Works with any entity that has an equipment grid (character armor, vehicles, etc).
]]

local Menu = require("scripts.ui.menu")
local KeyGraph = require("scripts.ui.key-graph")
local Controls = require("scripts.ui.controls")
local Equipment = require("scripts.equipment")
local InventoryUtils = require("scripts.inventory-utils")
local ItemInfo = require("scripts.item-info")
local ItemStackUtils = require("scripts.item-stack-utils")
local Localising = require("scripts.localising")
local Speech = require("scripts.speech")
local MessageBuilder = Speech.MessageBuilder
local UiRouter = require("scripts.ui.router")
local UiSounds = require("scripts.ui.sounds")

-- Load selectors (registers them with router)
local WeaponSelector = require("scripts.ui.selectors.weapon-selector")
local AmmoSelector = require("scripts.ui.selectors.ammo-selector")

local mod = {}

--------------------------------------------------------------------------------
-- Weapon Actions
--------------------------------------------------------------------------------

---Clear ammo from slot to a target inventory
---@param entity LuaEntity
---@param slot number
---@param target_inv LuaInventory
---@return boolean success
local function clear_ammo_to_inventory(entity, slot, target_inv)
   local ammo_inv = InventoryUtils.get_ammo_inventory(entity)
   if ammo_inv and slot <= #ammo_inv then
      local ammo_stack = ammo_inv[slot]
      if ammo_stack and ammo_stack.valid_for_read then
         if not target_inv.can_insert(ammo_stack) then return false end
         target_inv.insert(ammo_stack)
         ammo_stack.clear()
      end
   end
   return true
end

---Set a weapon in a slot using swap
---@param entity LuaEntity
---@param slot number
---@param weapon_stack LuaItemStack
---@return boolean success
---@return LocalisedString message
local function set_weapon_in_slot(entity, slot, weapon_stack)
   local gun_inv = InventoryUtils.get_gun_inventory(entity)
   local ammo_inv = InventoryUtils.get_ammo_inventory(entity)
   if not gun_inv then return false, { "fa.weapon-error-no-gun-inventory" } end
   assert(slot <= #gun_inv, "slot out of bounds for gun inventory")

   local main_inv = InventoryUtils.get_main_inventory(entity)

   -- Clear ammo first - need to validate space
   if ammo_inv and slot <= #ammo_inv then
      local ammo_stack = ammo_inv[slot]
      if ammo_stack and ammo_stack.valid_for_read then
         if not main_inv or not main_inv.can_insert(ammo_stack) then
            return false, { "fa.weapon-error-inventory-full-for-ammo" }
         end
         main_inv.insert(ammo_stack)
         ammo_stack.clear()
      end
   end

   -- Swap weapons - old weapon goes where new weapon was
   local gun_slot = gun_inv[slot]
   local success = gun_slot.swap_stack(weapon_stack)
   if success then
      return true, { "fa.weapon-equipped", Localising.get_localised_name_with_fallback(gun_slot) }
   else
      return false, { "fa.weapon-error-cannot-equip" }
   end
end

---Remove weapon from slot to entity's inventory
---@param entity LuaEntity
---@param slot number
---@return boolean success
---@return LocalisedString message
local function remove_weapon_to_inventory(entity, slot)
   local gun_inv = InventoryUtils.get_gun_inventory(entity)
   if not gun_inv then return false, { "fa.weapon-error-no-gun-inventory" } end

   local main_inv = InventoryUtils.get_main_inventory(entity)
   if not main_inv then return false, { "fa.weapon-error-no-main-inventory" } end

   local gun_slot = gun_inv[slot]
   if not gun_slot or not gun_slot.valid_for_read then return false, { "fa.weapon-error-no-weapon-in-slot" } end

   -- Validate weapon space first
   if not main_inv.can_insert(gun_slot) then return false, { "fa.weapon-error-inventory-full" } end

   -- Clear ammo first
   if not clear_ammo_to_inventory(entity, slot, main_inv) then
      return false, { "fa.weapon-error-inventory-full-for-ammo" }
   end

   local weapon_name = Localising.get_localised_name_with_fallback(gun_slot)
   main_inv.insert(gun_slot)
   gun_slot.clear()

   return true, { "fa.weapon-removed-to-inventory", weapon_name }
end

---Remove weapon from slot to player's hand
---@param entity LuaEntity
---@param slot number
---@param pindex number
---@return boolean success
---@return LocalisedString message
local function remove_weapon_to_hand(entity, slot, pindex)
   local player = game.get_player(pindex)
   if not player then return false, { "fa.weapon-error-no-player" } end

   local gun_inv = InventoryUtils.get_gun_inventory(entity)
   if not gun_inv then return false, { "fa.weapon-error-no-gun-inventory" } end

   local gun_slot = gun_inv[slot]
   if not gun_slot or not gun_slot.valid_for_read then return false, { "fa.weapon-error-no-weapon-in-slot" } end

   if player.cursor_stack and player.cursor_stack.valid_for_read then
      return false, { "fa.weapon-error-hand-not-empty" }
   end

   -- Clear ammo to entity's inventory first
   local entity_main_inv = InventoryUtils.get_main_inventory(entity)
   assert(entity_main_inv, "entity with guns must have a main inventory")
   if not clear_ammo_to_inventory(entity, slot, entity_main_inv) then
      return false, { "fa.weapon-error-inventory-full-for-ammo" }
   end

   local weapon_name = Localising.get_localised_name_with_fallback(gun_slot)
   player.cursor_stack.transfer_stack(gun_slot)

   return true, { "fa.weapon-removed-to-hand", weapon_name }
end

---Remove weapon from slot to player's inventory
---@param entity LuaEntity
---@param slot number
---@param character LuaEntity
---@return boolean success
---@return LocalisedString message
local function remove_weapon_to_player(entity, slot, character)
   local gun_inv = InventoryUtils.get_gun_inventory(entity)
   if not gun_inv then return false, { "fa.weapon-error-no-gun-inventory" } end

   local char_main_inv = InventoryUtils.get_main_inventory(character)
   if not char_main_inv then return false, { "fa.weapon-error-no-main-inventory" } end

   local gun_slot = gun_inv[slot]
   if not gun_slot or not gun_slot.valid_for_read then return false, { "fa.weapon-error-no-weapon-in-slot" } end

   -- Validate weapon space first
   if not char_main_inv.can_insert(gun_slot) then return false, { "fa.weapon-error-inventory-full" } end

   -- Clear ammo to player's inventory first
   if not clear_ammo_to_inventory(entity, slot, char_main_inv) then
      return false, { "fa.weapon-error-inventory-full-for-ammo" }
   end

   local weapon_name = Localising.get_localised_name_with_fallback(gun_slot)
   char_main_inv.insert(gun_slot)
   gun_slot.clear()

   return true, { "fa.weapon-removed-to-player", weapon_name }
end

--------------------------------------------------------------------------------
-- Ammo Actions
--------------------------------------------------------------------------------

---Set ammo in a slot using swap
---@param entity LuaEntity
---@param slot number
---@param ammo_stack LuaItemStack
---@return boolean success
---@return LocalisedString message
local function set_ammo_in_slot(entity, slot, ammo_stack)
   local ammo_inv = InventoryUtils.get_ammo_inventory(entity)
   if not ammo_inv then return false, { "fa.weapon-error-no-ammo-inventory" } end
   assert(slot <= #ammo_inv, "slot out of bounds for ammo inventory")

   local ammo_slot = ammo_inv[slot]
   local success = ammo_slot.swap_stack(ammo_stack)
   if success then
      return true, { "fa.ammo-loaded", Localising.get_localised_name_with_fallback(ammo_slot) }
   else
      return false, { "fa.weapon-error-cannot-load-ammo" }
   end
end

---Remove ammo from slot to entity's inventory
---@param entity LuaEntity
---@param slot number
---@return boolean success
---@return LocalisedString message
local function remove_ammo_to_inventory(entity, slot)
   local ammo_inv = InventoryUtils.get_ammo_inventory(entity)
   if not ammo_inv then return false, { "fa.weapon-error-no-ammo-inventory" } end

   local main_inv = InventoryUtils.get_main_inventory(entity)
   if not main_inv then return false, { "fa.weapon-error-no-main-inventory" } end

   local ammo_slot = ammo_inv[slot]
   if not ammo_slot or not ammo_slot.valid_for_read then return false, { "fa.ammo-error-no-ammo-in-slot" } end

   if not main_inv.can_insert(ammo_slot) then return false, { "fa.ammo-error-inventory-full" } end

   local ammo_name = Localising.get_localised_name_with_fallback(ammo_slot)
   main_inv.insert(ammo_slot)
   ammo_slot.clear()

   return true, { "fa.ammo-removed-to-inventory", ammo_name }
end

---Remove ammo from slot to player's hand
---@param entity LuaEntity
---@param slot number
---@param pindex number
---@return boolean success
---@return LocalisedString message
local function remove_ammo_to_hand(entity, slot, pindex)
   local player = game.get_player(pindex)
   if not player then return false, { "fa.weapon-error-no-player" } end

   local ammo_inv = InventoryUtils.get_ammo_inventory(entity)
   if not ammo_inv then return false, { "fa.weapon-error-no-ammo-inventory" } end

   local ammo_slot = ammo_inv[slot]
   if not ammo_slot or not ammo_slot.valid_for_read then return false, { "fa.ammo-error-no-ammo-in-slot" } end

   if player.cursor_stack and player.cursor_stack.valid_for_read then
      return false, { "fa.weapon-error-hand-not-empty" }
   end

   local ammo_name = Localising.get_localised_name_with_fallback(ammo_slot)
   player.cursor_stack.transfer_stack(ammo_slot)

   return true, { "fa.ammo-removed-to-hand", ammo_name }
end

---Remove ammo from slot to player's inventory
---@param entity LuaEntity
---@param slot number
---@param character LuaEntity
---@return boolean success
---@return LocalisedString message
local function remove_ammo_to_player(entity, slot, character)
   local ammo_inv = InventoryUtils.get_ammo_inventory(entity)
   if not ammo_inv then return false, { "fa.weapon-error-no-ammo-inventory" } end

   local char_main_inv = InventoryUtils.get_main_inventory(character)
   if not char_main_inv then return false, { "fa.weapon-error-no-main-inventory" } end

   local ammo_slot = ammo_inv[slot]
   if not ammo_slot or not ammo_slot.valid_for_read then return false, { "fa.ammo-error-no-ammo-in-slot" } end

   if not char_main_inv.can_insert(ammo_slot) then return false, { "fa.ammo-error-inventory-full" } end

   local ammo_name = Localising.get_localised_name_with_fallback(ammo_slot)
   char_main_inv.insert(ammo_slot)
   ammo_slot.clear()

   return true, { "fa.ammo-removed-to-player", ammo_name }
end

---Get total ammo count in main inventory for a specific ammo type
---@param entity LuaEntity
---@param ammo_name string
---@param quality string?
---@return number
local function get_ammo_in_inventory(entity, ammo_name, quality)
   local main_inv = InventoryUtils.get_main_inventory(entity)
   if not main_inv then return 0 end
   local count = 0
   for i = 1, #main_inv do
      local stack = main_inv[i]
      if stack.valid_for_read and stack.name == ammo_name then
         if not quality or stack.quality.name == quality then count = count + stack.count end
      end
   end
   return count
end

---Build the weapon row label for a slot
---@param entity LuaEntity
---@param slot number
---@return LocalisedString
local function build_weapon_row_label(entity, slot)
   local mb = MessageBuilder.new()

   local gun_info = InventoryUtils.get_gun_info_for_slot(entity, slot)
   local ammo_stack = InventoryUtils.get_ammo_in_slot(entity, slot)

   if gun_info then
      -- Display gun name (with quality for inventory guns, without for built-in)
      if gun_info.quality then
         mb:fragment(ItemInfo.item_info({ name = gun_info.name, quality = gun_info.quality }))
      else
         mb:fragment({ "item-name." .. gun_info.name })
      end

      if ammo_stack then
         mb:fragment({ "fa.weapon-with-ammo", ItemInfo.item_info(ammo_stack) })
         local inv_count = get_ammo_in_inventory(entity, ammo_stack.name, ammo_stack.quality.name)
         local total = ammo_stack.count + inv_count
         mb:list_item({ "fa.weapon-total-in-inventory", tostring(total) })
      else
         mb:list_item({ "fa.weapon-no-ammo-loaded" })
      end

      -- Different hints for built-in vs swappable guns
      if gun_info.is_builtin then
         mb:fragment({ "fa.weapon-hints-builtin" })
      else
         mb:fragment({ "fa.weapon-hints" })
      end
   else
      mb:fragment({ "fa.weapon-empty-slot", tostring(slot) })
      mb:fragment({ "fa.weapon-hint-m-only" })
   end

   return mb:build()
end

---Handle weapon selector result
---@param entity LuaEntity
---@param character LuaEntity?
---@param slot number
---@param pindex number
---@param result fa.WeaponSelectorResult
---@return boolean success
---@return LocalisedString message
local function handle_weapon_result(entity, character, slot, pindex, result)
   local K = WeaponSelector.KIND
   if result.kind == K.EQUIP then
      return set_weapon_in_slot(entity, slot, result.stack)
   elseif result.kind == K.REMOVE_TO_INVENTORY then
      return remove_weapon_to_inventory(entity, slot)
   elseif result.kind == K.REMOVE_TO_HAND then
      return remove_weapon_to_hand(entity, slot, pindex)
   elseif result.kind == K.REMOVE_TO_PLAYER then
      return remove_weapon_to_player(entity, slot, character)
   end
   return false, ""
end

---Handle ammo selector result
---@param entity LuaEntity
---@param character LuaEntity?
---@param slot number
---@param pindex number
---@param result fa.AmmoSelectorResult
---@return boolean success
---@return LocalisedString message
local function handle_ammo_result(entity, character, slot, pindex, result)
   local K = AmmoSelector.KIND
   if result.kind == K.LOAD then
      return set_ammo_in_slot(entity, slot, result.stack)
   elseif result.kind == K.REMOVE_TO_INVENTORY then
      return remove_ammo_to_inventory(entity, slot)
   elseif result.kind == K.REMOVE_TO_HAND then
      return remove_ammo_to_hand(entity, slot, pindex)
   elseif result.kind == K.REMOVE_TO_PLAYER then
      return remove_ammo_to_player(entity, slot, character)
   end
   return false, ""
end

---Add weapon row to a menu builder
---@param builder fa.ui.menu.MenuBuilder
---@param entity LuaEntity
---@param character LuaEntity?
---@param pindex number
local function add_weapon_row(builder, entity, character, pindex)
   local slot_count = InventoryUtils.get_weapon_slot_count(entity)
   if slot_count == 0 then return end

   -- Check if this entity has built-in guns (no gun inventory)
   local has_gun_inventory = InventoryUtils.get_gun_inventory(entity) ~= nil

   builder:start_row("weapons")
   for slot = 1, slot_count do
      local key = string.format("weapon-slot-%d", slot)

      builder:add_clickable(key, function(ctx)
         ctx.message:fragment(build_weapon_row_label(entity, slot))
      end, {
         on_action1 = function(ctx)
            -- Only allow weapon selector if entity has a gun inventory (not built-in guns)
            if not has_gun_inventory then
               ctx.message:fragment({ "fa.weapon-builtin-cannot-change" })
               return
            end
            ctx.controller:open_child_ui(UiRouter.UI_NAMES.WEAPON_SELECTOR, {
               entity = entity,
               character = character,
               slot = slot,
               pindex = pindex,
            }, { node = key })
         end,
         on_action3 = function(ctx)
            local gun_info = InventoryUtils.get_gun_info_for_slot(entity, slot)
            if not gun_info then
               ctx.message:fragment({ "fa.weapon-error-no-weapon-for-ammo" })
               return
            end
            ctx.controller:open_child_ui(UiRouter.UI_NAMES.AMMO_SELECTOR, {
               entity = entity,
               character = character,
               slot = slot,
               gun_name = gun_info.name,
               pindex = pindex,
            }, { node = key })
         end,
         on_child_result = function(result_ctx, result)
            if not result then return end

            local success, message
            if result.type == "weapon" then
               success, message = handle_weapon_result(entity, character, slot, pindex, result)
            elseif result.type == "ammo" then
               success, message = handle_ammo_result(entity, character, slot, pindex, result)
            end

            if message then result_ctx.message:fragment(message) end
            if success then UiSounds.play_menu_click(pindex) end
         end,
      })
   end
   builder:end_row()
end

--------------------------------------------------------------------------------
-- Equipment Overview - Section Builders
--------------------------------------------------------------------------------

---Add character armor management section
---@param builder fa.ui.menu.MenuBuilder
---@param player LuaPlayer
---@param entity LuaEntity
---@param grid LuaEquipmentGrid?
---@param main_inv LuaInventory?
local function add_character_armor_section(builder, player, entity, grid, main_inv)
   local armor_inv = player.get_inventory(defines.inventory.character_armor)
   local has_armor = armor_inv and not armor_inv.is_empty() and armor_inv[1].valid_for_read

   -- Get aggregated armor from inventory
   local armor_filter = function(stack)
      return stack.is_armor
   end
   local armor_items = main_inv and ItemStackUtils.aggregate_inventory(main_inv, armor_filter) or {}

   builder:start_row("armor-management")

   if has_armor then
      local armor_stack = armor_inv[1]
      builder:add_clickable("current-armor", function(ctx)
         ctx.message:fragment({ "fa.equipment-overview-equipped" })
         ctx.message:list_item(ItemInfo.item_info(armor_stack))

         -- Add equipment bonuses if available
         if grid then Equipment.add_equipment_bonuses_to_message(ctx.message, grid) end

         -- Add backspace hint
         ctx.message:fragment({ "fa.equipment-overview-backspace-to-unequip" })
      end, {
         on_clear = function(ctx)
            -- Unequip armor to player inventory
            if main_inv and main_inv.can_insert(armor_stack) then
               local armor_name = ItemInfo.item_info(armor_stack)
               local inserted = main_inv.insert(armor_stack)
               if inserted > 0 then
                  armor_stack.clear()
                  ctx.message:fragment({ "fa.equipment-overview-unequipped", armor_name })
                  UiSounds.play_menu_click(ctx.pindex)
               else
                  ctx.message:fragment({ "fa.equipment-overview-inventory-full" })
               end
            else
               ctx.message:fragment({ "fa.equipment-overview-inventory-full" })
            end
         end,
      })
   else
      builder:add_label("no-armor", { "fa.equipment-overview-no-armor-move-right" })
   end

   -- Add available armors from inventory to the same row
   for _, armor_data in ipairs(armor_items) do
      local key = string.format("armor-%s-%s", armor_data.name, armor_data.quality)
      builder:add_clickable(key, function(ctx)
         ctx.message:fragment(ItemInfo.item_info(armor_data.stacks[1]))
      end, {
         on_click = function(ctx)
            -- Equip the first stack
            local result_msg = Equipment.equip_it(armor_data.stacks[1], ctx.pindex)
            ctx.message:fragment(result_msg)
            UiSounds.play_menu_click(ctx.pindex)
         end,
      })
   end

   builder:end_row()

   -- Personal roboport dispatch control
   builder:add_item(
      "roboport-dispatch",
      Controls.checkbox({
         label = { "fa.equipment-allow-roboport-dispatch" },
         get = function()
            return entity.allow_dispatching_robots
         end,
         set = function(v)
            entity.allow_dispatching_robots = v
         end,
      })
   )
end

---Add equipment bonuses label for vehicles with grids
---@param builder fa.ui.menu.MenuBuilder
---@param grid LuaEquipmentGrid
local function add_vehicle_equipment_bonuses(builder, grid)
   builder:add_label("equipment-bonuses", function(ctx)
      ctx.message:fragment({ "fa.equipment-overview-entity-bonuses" })
      Equipment.add_equipment_bonuses_to_message(ctx.message, grid)
   end)
end

---Add equipment list section showing grid contents
---@param builder fa.ui.menu.MenuBuilder
---@param grid LuaEquipmentGrid
---@param main_inv LuaInventory?
local function add_equipment_list_section(builder, grid, main_inv)
   local empty_slots = Equipment.count_empty_equipment_slots(grid)
   if #grid.equipment > 0 then
      builder:add_clickable("equipment-list", function(ctx)
         ctx.message:fragment({ "fa.equipment-empty-slots", tostring(empty_slots) })
         ctx.message:fragment({ "fa.equipment-overview-contains" })
         local contents = grid.get_contents()
         for _, item in ipairs(contents) do
            local stack = {
               name = item.name,
               count = item.count,
               quality = prototypes.quality[item.quality],
            }
            ctx.message:list_item(ItemInfo.item_info(stack))
         end
         ctx.message:fragment({ "fa.equipment-overview-backspace-to-clear-all" })
      end, {
         on_clear = function(ctx)
            -- Remove all equipment from grid to player inventory
            if not main_inv then return end

            local equipment_list = grid.equipment
            local total_count = #equipment_list
            local removed_count = 0

            -- Loop through all equipment and take each one
            for i = total_count, 1, -1 do
               local equipment = equipment_list[i]
               if equipment and equipment.valid then
                  -- Save position before taking
                  local position = equipment.position
                  local taken = grid.take({ equipment = equipment })
                  if taken then
                     -- Try to insert to inventory
                     ---@diagnostic disable-next-line: param-type-mismatch
                     local inserted = main_inv.insert(taken)
                     if inserted > 0 then
                        removed_count = removed_count + 1
                     else
                        -- Failed to insert - put it back in the grid
                        grid.put({
                           name = taken.name,
                           position = position,
                           quality = taken.quality,
                        })
                     end
                  end
               end
            end

            if removed_count == total_count then
               ctx.message:fragment({ "fa.equipment-overview-cleared-all-equipment" })
               UiSounds.play_menu_click(ctx.pindex)
            elseif removed_count > 0 then
               ctx.message:fragment({ "fa.equipment-overview-cleared-partial-equipment", tostring(removed_count) })
               UiSounds.play_menu_click(ctx.pindex)
            else
               ctx.message:fragment({ "fa.equipment-overview-inventory-full" })
            end
         end,
      })
   else
      builder:add_label("equipment-list", function(ctx)
         ctx.message:fragment({ "fa.equipment-empty-slots", tostring(empty_slots) })
         ctx.message:fragment({ "fa.equipment-overview-no-equipment" })
      end)
   end
end

---Add quick equip rows for selecting equipment from inventories
---@param builder fa.ui.menu.MenuBuilder
---@param ctx fa.ui.graph.Ctx
---@param player LuaPlayer
---@param entity LuaEntity
---@param grid LuaEquipmentGrid
local function add_quick_equip_section(builder, ctx, player, entity, grid)
   Equipment.add_equipment_selection_rows(builder, {
      character = player.character,
      equip_target = entity,
      max_x = grid.width,
      max_y = grid.height,
   }, function(equip_data)
      -- When equipment is selected, try to equip it to the target entity
      local result_msg = Equipment.equip_it(equip_data.stacks[1], ctx.pindex, entity)
      ctx.message:fragment(result_msg)
      UiSounds.play_menu_click(ctx.pindex)
   end)
end

--------------------------------------------------------------------------------
-- Equipment Overview - Main Render
--------------------------------------------------------------------------------

---Build the equipment overview for a character (always shows armor section)
---@param ctx fa.ui.graph.Ctx
---@param builder fa.ui.menu.MenuBuilder
---@param player LuaPlayer
---@param entity LuaEntity
local function render_character_overview(ctx, builder, player, entity)
   local grid = entity.grid
   local main_inv = player.get_inventory(defines.inventory.character_main)

   -- Characters always get armor management (even without armor equipped)
   add_character_armor_section(builder, player, entity, grid, main_inv)

   -- Equipment list and quick equip only if grid exists (armor equipped)
   if grid then
      add_equipment_list_section(builder, grid, main_inv)
      add_quick_equip_section(builder, ctx, player, entity, grid)
   end

   add_weapon_row(builder, entity, player.character, ctx.pindex)
end

---Build the equipment overview for a vehicle with equipment grid support
---@param ctx fa.ui.graph.Ctx
---@param builder fa.ui.menu.MenuBuilder
---@param player LuaPlayer
---@param entity LuaEntity
local function render_vehicle_with_grid(ctx, builder, player, entity)
   local grid = entity.grid
   local main_inv = player.character and player.get_inventory(defines.inventory.character_main)

   if grid then
      add_vehicle_equipment_bonuses(builder, grid)
      add_equipment_list_section(builder, grid, main_inv)
      add_quick_equip_section(builder, ctx, player, entity, grid)
   end

   add_weapon_row(builder, entity, player.character, ctx.pindex)
end

---Build the equipment overview for an entity with only weapons (no grid support)
---@param ctx fa.ui.graph.Ctx
---@param builder fa.ui.menu.MenuBuilder
---@param player LuaPlayer
---@param entity LuaEntity
local function render_weapons_only(ctx, builder, player, entity)
   add_weapon_row(builder, entity, player.character, ctx.pindex)
end

---Build the equipment overview menu
---@param ctx fa.ui.graph.Ctx
---@return fa.ui.graph.Render?
local function render_equipment_overview(ctx)
   local params = ctx.global_parameters
   local player = game.get_player(ctx.pindex)
   if not player then return nil end

   -- Get target entity from params (defaults to player character for main menu)
   local entity = params.entity or player.character
   if not entity or not entity.valid then return nil end

   local builder = Menu.MenuBuilder.new()

   if entity.type == "character" then
      render_character_overview(ctx, builder, player, entity)
   elseif entity.prototype.grid_prototype then
      render_vehicle_with_grid(ctx, builder, player, entity)
   else
      render_weapons_only(ctx, builder, player, entity)
   end

   return builder:build()
end

---Check if equipment overview is available for an entity
---Available if entity is a character, could have equipment grid, or has weapons
---@param entity LuaEntity
---@return boolean
function mod.is_available(entity)
   if not entity or not entity.valid then return false end
   -- Characters always have armor management
   if entity.type == "character" then return true end
   -- Vehicles that could have equipment grids
   if entity.prototype.grid_prototype then return true end
   -- Entities with weapons
   if InventoryUtils.get_weapon_slot_count(entity) > 0 then return true end
   return false
end

mod.equipment_overview_tab = KeyGraph.declare_graph({
   name = "equipment_overview",
   title = { "fa.equipment-overview-title" },
   render_callback = render_equipment_overview,
})

return mod
