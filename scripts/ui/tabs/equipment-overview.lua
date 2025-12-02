--[[
Equipment overview tab showing armor, equipment, and quick equip options.
Works with any entity that has an equipment grid (character armor, vehicles, etc).
]]

local Menu = require("scripts.ui.menu")
local KeyGraph = require("scripts.ui.key-graph")
local Controls = require("scripts.ui.controls")
local Equipment = require("scripts.equipment")
local ItemInfo = require("scripts.item-info")
local ItemStackUtils = require("scripts.item-stack-utils")
local Localising = require("scripts.localising")
local Speech = require("scripts.speech")
local MessageBuilder = Speech.MessageBuilder
local UiRouter = require("scripts.ui.router")
local UiSounds = require("scripts.ui.sounds")

local mod = {}

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
   local is_character = entity.type == "character"

   -- Get equipment grid
   local grid = entity.grid

   -- Get player main inventory (used for unequipping equipment)
   local main_inv = player.character and player.get_inventory(defines.inventory.character_main)

   -- Get armor inventory (only for characters)
   local armor_inv = is_character and player.get_inventory(defines.inventory.character_armor)
   local has_armor = armor_inv and not armor_inv.is_empty() and armor_inv[1].valid_for_read

   -- Row 1: Armor management or Equipment Bonuses
   if is_character then
      -- Armor management (current + available) - only for characters

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
      if #armor_items > 0 then
         -- Add each armor type/quality as a clickable
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
      end

      builder:end_row()

      -- Personal roboport dispatch control (only for characters)
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
   else
      -- For non-character entities (vehicles, etc), show equipment bonuses directly
      if grid then
         builder:add_label("equipment-bonuses", function(ctx)
            ctx.message:fragment({ "fa.equipment-overview-entity-bonuses" })
            Equipment.add_equipment_bonuses_to_message(ctx.message, grid)
         end)
      else
         builder:add_label("no-grid", { "fa.equipment-overview-no-grid" })
      end
   end

   -- Row 2: Equipment in armor (aggregated)
   if grid and #grid.equipment > 0 then
      builder:add_clickable("equipment-list", function(ctx)
         ctx.message:fragment({ "fa.equipment-overview-contains" })
         local contents = grid.get_contents()
         for i, item in ipairs(contents) do
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
            if grid and main_inv then
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
            end
         end,
      })
   else
      builder:add_label("equipment-list", { "fa.equipment-overview-no-equipment" })
   end

   -- Quick equip rows (from entity and player inventories)
   -- Use the shared equipment selection row builder
   local max_x = grid and grid.width or nil
   local max_y = grid and grid.height or nil

   Equipment.add_equipment_selection_rows(builder, {
      character = player.character,
      equip_target = entity,
      max_x = max_x,
      max_y = max_y,
   }, function(equip_data)
      -- When equipment is selected, try to equip it to the target entity
      local result_msg = Equipment.equip_it(equip_data.stacks[1], ctx.pindex, entity)
      ctx.message:fragment(result_msg)
      UiSounds.play_menu_click(ctx.pindex)
   end)

   return builder:build()
end

---Check if equipment overview is available for an entity
---@param entity LuaEntity
---@return boolean
function mod.is_available(entity)
   if not entity or not entity.valid then return false end
   return entity.grid ~= nil
end

mod.equipment_overview_tab = KeyGraph.declare_graph({
   name = "equipment_overview",
   title = { "fa.equipment-overview-title" },
   render_callback = render_equipment_overview,
})

return mod
