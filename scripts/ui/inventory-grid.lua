--[[
Generic inventory grid UI component

Renders any inventory as a 10-column grid with navigation

Each inventory grid stores its state in a subfield of params, specified on inventory creation.
]]

local Grid = require("scripts.ui.grid")
local Localising = require("scripts.localising")
local Speech = require("scripts.speech")
local UiKeyGraph = require("scripts.ui.key-graph")
local sounds = require("scripts.ui.sounds")
local Consts = require("scripts.consts")
local Equipment = require("scripts.equipment")
local FaInfo = require("scripts.fa-info")
local UiRouter = require("scripts.ui.router")
local ItemInfo = require("scripts.item-info")
local InventoryUtils = require("scripts.inventory-utils")
local Help = require("scripts.ui.help")
local EntityAccess = require("scripts.entity-access")
local MessageBuilder = Speech.MessageBuilder

local mod = {}

---@class fa.ui.InventoryGrid.Parameters
---@field entity LuaEntity The entity containing the inventory
---@field inventory_index defines.inventory The inventory to display
---@field title LocalisedString? Optional title for the inventory
---@field sibling_entity LuaEntity? Entity for quick transfer destination (typically player or opened entity)
---@field sibling_inventory_id defines.inventory? Inventory index for quick transfer destination

---@class fa.ui.InventoryGrid.State
---@field entity LuaEntity
---@field inventory_index defines.inventory

---@class fa.ui.InventoryGrid.Context: fa.ui.graph.Ctx
---@field parameters fa.ui.InventoryGrid.Parameters
---@field tablist_shared_state table<string, fa.ui.InventoryGrid.State>

-- Constants
local GRID_WIDTH = 10 -- Match the old inventory system

---Get recipe-based locks for crafting machine inventories
---@param entity LuaEntity
---@param inventory_index defines.inventory
---@return table<number, string> Sparse array mapping slot indices to item names
local function get_recipe_locks(entity, inventory_index)
   -- Only applies to crafting machines
   if not Consts.CRAFTING_MACHINES[entity.type] then return {} end

   local recipe = entity.get_recipe()
   if not recipe then return {} end

   local locks = {}
   if
      inventory_index == defines.inventory.assembling_machine_input
      or inventory_index == defines.inventory.furnace_source
   then
      -- Map ingredients to slots
      local slot = 1
      for _, ingredient in ipairs(recipe.ingredients) do
         if ingredient.type == "item" then
            locks[slot] = ingredient.name
            slot = slot + 1
         end
      end
   elseif
      inventory_index == defines.inventory.assembling_machine_output
      or inventory_index == defines.inventory.furnace_result
   then
      -- Map products to slots
      local slot = 1
      for _, product in ipairs(recipe.products) do
         if product.type == "item" then
            locks[slot] = product.name
            slot = slot + 1
         end
      end
   end

   return locks
end

---Build a label for an inventory slot into a MessageBuilder
---@param message fa.MessageBuilder
---@param inv LuaInventory
---@param slot_index number
---@param locks table<number, string>? Recipe locks for this inventory
local function build_slot_label(message, inv, slot_index, locks)
   local stack = inv[slot_index]
   local lock_name = locks and locks[slot_index]

   -- Get filter info if inventory supports filters
   local filter = nil
   if inv.supports_filters() then filter = inv.get_filter(slot_index) end

   -- If empty slot with a lock, show what it's locked to
   if not stack or not stack.valid_for_read then
      message:fragment({ "fa.ui-inventory-empty-slot" })
      if lock_name then
         message:list_item({ "fa.ui-inventory-slot-locked-to", ItemInfo.item_info({ name = lock_name }) })
      end
   else
      -- Build the item label with count and quality
      message:fragment(ItemInfo.item_info(stack))

      -- Add lock info if this slot has one
      if lock_name then
         message:list_item({ "fa.ui-inventory-slot-locked-to", ItemInfo.item_info({ name = lock_name }) })
      end
   end

   -- Add filter info if a filter is set
   if filter then
      local filter_name = type(filter) == "string" and filter or filter.name
      if filter_name and prototypes.item[filter_name] then
         local item_name = Localising.get_localised_name_with_fallback(prototypes.item[filter_name])
         message:list_item({ "fa.ui-inventory-filtered-to", item_name })
      end
   end
end

---Calculate grid position from slot index
---@param slot_index number 1-based slot index
---@return number x, number y Grid coordinates (1-based)
local function slot_to_grid_pos(slot_index)
   -- Convert to 0-based for calculation
   local index = slot_index - 1
   local x = (index % GRID_WIDTH) + 1
   local y = math.floor(index / GRID_WIDTH) + 1
   return x, y
end

---Calculate slot index from grid position
---@param x number Grid X (1-based)
---@param y number Grid Y (1-based)
---@return number Slot index (1-based)
local function grid_pos_to_slot(x, y)
   return (y - 1) * GRID_WIDTH + x
end

---Check if a write operation is allowed for the given entity
---Returns true if allowed, false if denied (and appends error message)
---@param ctx { pindex: integer, controller: { message: fa.MessageBuilder } }
---@param entity LuaEntity
---@param sibling_entity LuaEntity? If this is a transfer, the destination entity
---@return boolean allowed
local function check_write_access(ctx, entity, sibling_entity)
   if sibling_entity then
      -- Transfer operation: check both source and destination
      local result = EntityAccess.can_transfer_between(ctx.pindex, entity, sibling_entity)
      if not result.allowed then
         ctx.controller.message:fragment(result.reason)
         return false
      end
   else
      -- Single entity operation
      local result = EntityAccess.can_write_to_entity(ctx.pindex, entity)
      if not result.allowed then
         ctx.controller.message:fragment(result.reason)
         return false
      end
   end
   return true
end

---Custom dimension labeler for inventory slots
---@param ctx fa.ui.InventoryGrid.Context
---@param x number
---@param y number
local function inventory_dimension_labeler(ctx, x, y)
   local slot_index = grid_pos_to_slot(x, y)
   local row = y
   ctx.message:fragment({ "fa.ui-inventory-slot-position", slot_index, row })
end

---Handle bar movement for an inventory
---@param ctx fa.ui.InventoryGrid.Context
---@param delta integer Change in bar position (positive = unlock more, negative = lock more)
local function move_bar(ctx, delta)
   local entity = ctx.parameters.entity
   local inventory_index = ctx.parameters.inventory_index

   if not entity or not entity.valid then
      ctx.message:fragment({ "fa.equipment-error-invalid-entity" })
      return
   end

   -- Bar adjustment is a configuration operation, not an item transfer.
   -- If the inventory is open, the player should be able to adjust it.

   local inv = entity.get_inventory(inventory_index)
   if not inv or not inv.valid then return end

   if not inv.supports_bar() then
      ctx.message:fragment({ "fa.ui-inventory-bar-not-supported" })
      return
   end

   local total_slots = #inv
   local current_bar = inv.get_bar()
   local new_bar = current_bar + delta

   -- Clamp to valid range: 1 (all locked) to total_slots + 1 (all unlocked)
   if new_bar < 1 then
      new_bar = 1
   elseif new_bar > total_slots + 1 then
      new_bar = total_slots + 1
   end

   -- Check if bar actually moved
   if new_bar == current_bar then
      sounds.play_ui_edge(ctx.pindex)
      -- Re-announce current state
      local unlocked_count = new_bar - 1
      if new_bar == 1 then
         ctx.message:fragment({ "fa.ui-inventory-bar-all-locked" })
      elseif new_bar > total_slots then
         ctx.message:fragment({ "fa.ui-inventory-bar-all-unlocked" })
      else
         ctx.message:fragment({ "fa.ui-inventory-bar-moved", unlocked_count })
      end
      return
   end

   inv.set_bar(new_bar)

   -- Announce the new state
   local unlocked_count = new_bar - 1
   if new_bar == 1 then
      ctx.message:fragment({ "fa.ui-inventory-bar-all-locked" })
   elseif new_bar > total_slots then
      ctx.message:fragment({ "fa.ui-inventory-bar-all-unlocked" })
   else
      ctx.message:fragment({ "fa.ui-inventory-bar-moved", unlocked_count })
   end
end

---Render the inventory grid
---@param ctx fa.ui.InventoryGrid.Context
---@return fa.ui.graph.Render?
local function render_inventory_grid(ctx)
   local entity = ctx.parameters.entity
   local inventory_index = ctx.parameters.inventory_index

   if not entity or not entity.valid then return nil end

   local inv = entity.get_inventory(inventory_index)
   if not inv or not inv.valid then return nil end

   -- Get recipe locks if applicable
   local locks = get_recipe_locks(entity, inventory_index)

   local builder = Grid.grid_builder()
   builder:set_dimension_labeler(inventory_dimension_labeler)

   -- Calculate grid dimensions
   local total_slots = #inv
   local grid_height = math.ceil(total_slots / GRID_WIDTH)

   -- Build the grid
   for slot_index = 1, total_slots do
      local x, y = slot_to_grid_pos(slot_index)
      builder:add_control(x, y, {
         label = function(label_ctx)
            build_slot_label(label_ctx.message, inv, slot_index, locks)

            -- Add bar/locked status if applicable
            if inv.supports_bar() and slot_index >= inv.get_bar() then
               label_ctx.message:list_item({ "fa.ui-inventory-slot-locked" })
            end
         end,
         on_bar_min = function(bar_ctx)
            if not inv.supports_bar() then
               move_bar(bar_ctx, 0) -- Will show "not supported" message
               return
            end
            move_bar(bar_ctx, 1 - inv.get_bar())
         end,
         on_bar_max = function(bar_ctx)
            if not inv.supports_bar() then
               move_bar(bar_ctx, 0) -- Will show "not supported" message
               return
            end
            local total_slots = #inv
            move_bar(bar_ctx, (total_slots + 1) - inv.get_bar())
         end,
         on_bar_up_small = function(bar_ctx)
            move_bar(bar_ctx, 1)
         end,
         on_bar_down_small = function(bar_ctx)
            move_bar(bar_ctx, -1)
         end,
         on_bar_up_large = function(bar_ctx)
            move_bar(bar_ctx, 5)
         end,
         on_bar_down_large = function(bar_ctx)
            move_bar(bar_ctx, -5)
         end,
         on_click = function(click_ctx)
            local player = game.get_player(click_ctx.pindex)
            local cursor_stack = player.cursor_stack
            local inv_stack = inv[slot_index]

            -- CTRL+SHIFT+[ : Blueprint book insertion or repair
            if click_ctx.modifiers.control and click_ctx.modifiers.shift then
               -- Check write access for entity operations
               if not check_write_access(click_ctx, entity, nil) then return end

               -- Check if hand has bookable item and slot has blueprint book
               local is_bookable = cursor_stack
                  and cursor_stack.valid_for_read
                  and (cursor_stack.is_blueprint or cursor_stack.is_upgrade_item or cursor_stack.is_deconstruction_item)
               if is_bookable then
                  if inv_stack and inv_stack.valid_for_read and inv_stack.is_blueprint_book then
                     -- Insert item into book
                     local book_inv = inv_stack.get_inventory(defines.inventory.item_main)
                     if book_inv then
                        local inserted = book_inv.insert(cursor_stack)
                        if inserted > 0 then
                           cursor_stack.clear()
                           click_ctx.controller.message:fragment({ "fa.blueprint-inserted-into-book" })
                           return
                        else
                           click_ctx.controller.message:fragment({ "fa.blueprint-book-full" })
                           return
                        end
                     end
                  end
               end

               -- Check if hand has repair pack
               if cursor_stack and cursor_stack.valid_for_read and cursor_stack.is_repair_tool then
                  -- Repair item in this slot
                  local result = Equipment.repair_item_in_slot(click_ctx.pindex, entity, inventory_index, slot_index)
                  click_ctx.controller.message:fragment(result)
                  return
               end

               -- No action available
               click_ctx.controller.message:fragment({ "fa.ui-inventory-no-action" })
               return
            end

            -- ALT+[ : Set slot filter (open item chooser)
            if click_ctx.modifiers.alt then
               if not inv.supports_filters() then
                  click_ctx.controller.message:fragment({ "fa.ui-inventory-filters-not-supported" })
                  return
               end
               -- Open item chooser to select filter
               local grid_x, grid_y = slot_to_grid_pos(slot_index)
               click_ctx.controller:open_child_ui(
                  UiRouter.UI_NAMES.ITEM_CHOOSER,
                  {},
                  { node = Grid.make_key(grid_x, grid_y), slot_index = slot_index }
               )
               return
            end

            -- SHIFT+[ : Quick transfer full stack
            if click_ctx.modifiers.shift then
               if ctx.parameters.sibling_entity and ctx.parameters.sibling_inventory_id then
                  -- Check write access for both source and destination
                  if not check_write_access(click_ctx, entity, ctx.parameters.sibling_entity) then return end

                  InventoryUtils.quick_transfer(
                     click_ctx.pindex,
                     click_ctx.controller.message,
                     entity,
                     inventory_index,
                     slot_index,
                     ctx.parameters.sibling_entity,
                     ctx.parameters.sibling_inventory_id
                  )
                  return
               end

               -- No sibling configured
               click_ctx.controller.message:fragment({ "fa.ui-inventory-no-action" })
               return
            end

            -- Normal click: swap stacks between cursor and inventory
            -- Check write access for entity
            if not check_write_access(click_ctx, entity, nil) then return end

            sounds.play_menu_click(click_ctx.pindex)

            if cursor_stack and inv_stack then
               cursor_stack.swap_stack(inv_stack)

               -- Announce what's now in hand (or that hand is empty)
               if cursor_stack.valid_for_read then
                  local item_description = ItemInfo.item_info({
                     name = cursor_stack.name,
                     count = cursor_stack.count,
                     quality = cursor_stack.quality and cursor_stack.quality.name or nil,
                  })
                  click_ctx.controller.message:fragment({ "fa.grabbed-stuff", item_description })
               else
                  click_ctx.controller.message:fragment({ "fa.grabbed-nothing" })
               end
            end
         end,
         on_right_click = function(click_ctx)
            -- SHIFT+] : Quick transfer half stack
            if click_ctx.modifiers.shift then
               if ctx.parameters.sibling_entity and ctx.parameters.sibling_inventory_id then
                  -- Check write access for both source and destination
                  if not check_write_access(click_ctx, entity, ctx.parameters.sibling_entity) then return end

                  local inv_stack = inv[slot_index]
                  if inv_stack and inv_stack.valid_for_read then
                     local half = math.floor(inv_stack.count / 2)
                     if half > 0 then
                        InventoryUtils.quick_transfer(
                           click_ctx.pindex,
                           click_ctx.controller.message,
                           entity,
                           inventory_index,
                           slot_index,
                           ctx.parameters.sibling_entity,
                           ctx.parameters.sibling_inventory_id,
                           half
                        )
                     else
                        click_ctx.controller.message:fragment({ "fa.transfer-empty-slot" })
                     end
                  else
                     click_ctx.controller.message:fragment({ "fa.transfer-empty-slot" })
                  end
               else
                  click_ctx.controller.message:fragment({ "fa.ui-inventory-no-action" })
               end
               return
            end

            -- Handle right click (split stack)
            -- Check write access for entity
            if not check_write_access(click_ctx, entity, nil) then return end

            local player = game.get_player(click_ctx.pindex)
            local cursor_stack = player.cursor_stack
            local inv_stack = inv[slot_index]

            -- Play inventory click sound
            sounds.play_menu_click(click_ctx.pindex)

            -- Right click logic: split stack or transfer half
            if cursor_stack and inv_stack then
               if cursor_stack.valid_for_read and not inv_stack.valid_for_read then
                  -- Cursor has items, inventory slot is empty - transfer half to inventory
                  local half = math.floor(cursor_stack.count / 2)
                  if half > 0 then
                     inv_stack.set_stack({
                        name = cursor_stack.name,
                        count = half,
                        quality = cursor_stack.quality,
                     })
                     cursor_stack.count = cursor_stack.count - half
                     click_ctx.controller.message:fragment({ "fa.placed-stuff", { "fa.half-stack" } })
                  end
               elseif not cursor_stack.valid_for_read and inv_stack.valid_for_read then
                  -- Cursor is empty, inventory has items - take half
                  local half = math.floor(inv_stack.count / 2)
                  if half > 0 then
                     cursor_stack.set_stack({ name = inv_stack.name, count = half, quality = inv_stack.quality })
                     inv_stack.count = inv_stack.count - half
                     local item_description = ItemInfo.item_info({
                        name = cursor_stack.name,
                        count = cursor_stack.count,
                        quality = cursor_stack.quality and cursor_stack.quality.name or nil,
                     })
                     click_ctx.controller.message:fragment({ "fa.grabbed-stuff", item_description })
                  end
               elseif cursor_stack.valid_for_read and inv_stack.valid_for_read then
                  -- Both have items - swap like left click
                  cursor_stack.swap_stack(inv_stack)
                  local item_description = ItemInfo.item_info({
                     name = cursor_stack.name,
                     count = cursor_stack.count,
                     quality = cursor_stack.quality and cursor_stack.quality.name or nil,
                  })
                  click_ctx.controller.message:fragment({ "fa.grabbed-stuff", item_description })
               end
            end
         end,
         on_read_coords = function(coord_ctx, x, y)
            -- Read the slot position
            local slot_index = grid_pos_to_slot(x, y)
            local row = y
            coord_ctx.message:fragment({ "fa.ui-inventory-slot-position", slot_index, row })

            -- Also read item info (k = slot position + item info)
            local stack = inv[slot_index]
            local player = game.get_player(coord_ctx.pindex)
            ItemInfo.get_item_stack_info(
               coord_ctx.message,
               stack,
               { verbosity = ItemInfo.VERBOSITY.VERBOSE, force = player.force }
            )
         end,
         on_read_info = function(info_ctx, x, y)
            -- Read detailed item info (y = just item info)
            local slot_index = grid_pos_to_slot(x, y)
            local stack = inv[slot_index]
            local player = game.get_player(info_ctx.pindex)
            ItemInfo.get_item_stack_info(
               info_ctx.message,
               stack,
               { verbosity = ItemInfo.VERBOSITY.VERBOSE, force = player.force }
            )
         end,
         on_production_stats_announcement = function(stats_ctx, x, y)
            -- Read production stats for item in slot (u = production stats)
            local slot_index = grid_pos_to_slot(x, y)
            local stack = inv[slot_index]
            if stack and stack.valid_for_read then
               local stats_message = FaInfo.selected_item_production_stats_info(stats_ctx.pindex, stack.name)
               stats_ctx.message:fragment(stats_message)
            end
         end,
         on_dangerous_delete = function(delete_ctx, x, y)
            -- Check write access for entity
            if not check_write_access(delete_ctx, entity, nil) then return end

            -- Delete blueprint/decon/upgrade planners from slot
            local slot_index = grid_pos_to_slot(x, y)
            local stack = inv[slot_index]

            if not stack or not stack.valid_for_read then
               delete_ctx.message:fragment({ "fa.dangerous-delete-nothing-to-delete" })
               return
            end

            -- Check if it's a planner item using API flags
            if stack.is_blueprint or stack.is_deconstruction_item or stack.is_upgrade_item then
               local item_description = ItemInfo.item_info({
                  name = stack.name,
                  count = stack.count,
                  quality = stack.quality and stack.quality.name or nil,
               })

               -- Clear the stack
               stack.clear()

               delete_ctx.message:fragment({ "fa.dangerous-delete-deleted", item_description })
            else
               delete_ctx.message:fragment({ "fa.dangerous-delete-not-planner" })
            end
         end,
         on_trash = function(trash_ctx)
            -- Check write access for entity
            if not check_write_access(trash_ctx, entity, nil) then return end

            -- Send item in slot to trash (slot_index captured from loop)
            local stack = inv[slot_index]

            if not stack or not stack.valid_for_read then
               trash_ctx.message:fragment({ "fa.trash-nothing-in-slot" })
               return
            end

            -- Get the entity's trash inventory
            local trash_inv = InventoryUtils.find_trash_inventory(entity)
            if not trash_inv then
               trash_ctx.message:fragment({ "fa.trash-not-available" })
               return
            end

            -- Try to insert into trash
            local item_name = stack.name
            local item_count = stack.count
            local item_quality = stack.quality and stack.quality.name or nil

            local inserted = trash_inv.insert({ name = item_name, count = item_count, quality = item_quality })

            if inserted > 0 then
               -- Remove from slot
               stack.count = stack.count - inserted

               -- Announce success
               local item_description = ItemInfo.item_info({
                  name = item_name,
                  count = inserted,
                  quality = item_quality,
               })
               trash_ctx.message:fragment({ "fa.trash-sent-to-trash", item_description })

               if inserted < item_count then
                  trash_ctx.message:fragment({ "fa.trash-full", tostring(item_count - inserted) })
               end
            else
               trash_ctx.message:fragment({ "fa.trash-full-none-inserted" })
            end
         end,
         on_child_result = function(result_ctx, result)
            -- Handle item chooser result for setting slot filter
            if result and type(result) == "string" then
               -- Filters are configuration, not item transfers - no distance check needed

               -- Set the filter
               local success = inv.set_filter(slot_index, result)
               if success then
                  local item_name = Localising.get_localised_name_with_fallback(prototypes.item[result])
                  result_ctx.controller.message:fragment({ "fa.ui-inventory-filter-set", item_name })
               else
                  result_ctx.controller.message:fragment({ "fa.ui-inventory-filter-cannot-set" })
               end
            end
         end,
         on_clear_filter = function(clear_ctx, x, y)
            -- Check if filters are supported
            if not inv.supports_filters() then
               clear_ctx.message:fragment({ "fa.ui-inventory-filters-not-supported" })
               return
            end

            -- Filters are configuration, not item transfers - no distance check needed

            local current_filter = inv.get_filter(slot_index)
            if not current_filter then
               clear_ctx.message:fragment({ "fa.ui-inventory-filter-already-clear" })
               return
            end

            -- Clear the filter
            inv.set_filter(slot_index, nil)
            clear_ctx.message:fragment({ "fa.ui-inventory-filter-cleared" })
         end,
      })
   end

   return builder:build()
end

---Handle accelerator events for inventory grids
---@param ctx fa.ui.InventoryGrid.Context
---@param accelerator_name string
local function handle_accelerator(ctx, accelerator_name)
   -- Get current entity and inventory context from parameters
   local entity = ctx.parameters.entity
   local inv_index = ctx.parameters.inventory_index

   if not entity or not entity.valid then
      ctx.message:fragment({ "fa.equipment-error-invalid-entity" })
      return
   end

   -- Handle different accelerators
   if accelerator_name == UiRouter.ACCELERATORS.UNLOAD_GUNS then
      -- Unload guns FROM entity TO this inventory
      local result = Equipment.remove_weapons_and_ammo(ctx.pindex, entity, entity, inv_index)
      ctx.message:fragment(result)
   elseif accelerator_name == UiRouter.ACCELERATORS.UNLOAD_EQUIPMENT then
      -- Unload equipment FROM entity TO this inventory
      local result = Equipment.remove_equipment_and_armor(ctx.pindex, entity, entity, inv_index)
      ctx.message:fragment(result)
   end
end

---Create an inventory grid graph declaration
---@param params { name: string, title?: LocalisedString, entity?: LuaEntity, inventory_index?: defines.inventory }
---@return fa.ui.TabDescriptor
function mod.create_inventory_grid(params)
   local base_title = params.title or { "fa.ui-inventory-title" }

   -- Build title with bar info if available
   local title = base_title
   if params.entity and params.entity.valid and params.inventory_index then
      local inv = params.entity.get_inventory(params.inventory_index)
      if inv and inv.valid and inv.supports_bar() then
         local bar = inv.get_bar()
         local total_slots = #inv
         local unlocked_count = bar - 1

         -- Add bar status to title
         if bar == 1 then
            -- All locked
            title = { "", base_title, ", ", { "fa.ui-inventory-bar-all-locked" } }
         elseif bar <= total_slots then
            -- Some unlocked
            title = { "", base_title, ", ", { "fa.ui-inventory-bar-slots-unlocked", unlocked_count } }
         end
         -- If bar > total_slots, all unlocked - don't show anything
      end
   end

   return UiKeyGraph.declare_graph({
      name = params.name,
      title = title,
      render_callback = render_inventory_grid,
      on_accelerator = handle_accelerator,
      get_help_metadata = function(ctx)
         return { Help.message_list("inventory-grid-help") }
      end,
   })
end

return mod
