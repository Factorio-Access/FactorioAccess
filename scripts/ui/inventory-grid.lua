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
local UiRouter = require("scripts.ui.router")
local ItemDescriptions = require("scripts.item-descriptions")

local mod = {}

---@class fa.ui.InventoryGrid.Parameters
---@field entity LuaEntity The entity containing the inventory
---@field inventory_index defines.inventory The inventory to display
---@field title LocalisedString? Optional title for the inventory

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

---Generate a label for an inventory slot
---@param inv LuaInventory
---@param slot_index number
---@param locks table<number, string>? Recipe locks for this inventory
---@return LocalisedString
local function get_slot_label(inv, slot_index, locks)
   local stack = inv[slot_index]
   local lock_name = locks and locks[slot_index]

   -- If empty slot with a lock, show what it's locked to
   if not stack or not stack.valid_for_read then
      if lock_name then
         return {
            "",
            { "fa.ui-inventory-empty-slot" },
            {
               "fa.ui-inventory-slot-locked-to",
               Localising.localise_item({ name = lock_name }),
            },
         }
      end
      return { "fa.ui-inventory-empty-slot" }
   end

   -- Build the item label with count and quality
   local item_label = Localising.localise_item({
      name = stack.name,
      count = stack.count,
      quality = stack.quality and stack.quality.name or nil,
   })

   -- Add lock info if this slot has one
   if lock_name then
      return {
         "",
         item_label,
         { "fa.ui-inventory-slot-locked-to", Localising.localise_item({ name = lock_name }) },
      }
   end

   return item_label
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

---Custom dimension labeler for inventory slots
---@param ctx fa.ui.InventoryGrid.Context
---@param x number
---@param y number
local function inventory_dimension_labeler(ctx, x, y)
   local slot_index = grid_pos_to_slot(x, y)
   local row = y
   ctx.message:fragment({ "fa.ui-inventory-slot-position", slot_index, row })
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
      local label = get_slot_label(inv, slot_index, locks)

      builder:add_control(x, y, {
         label = function(label_ctx)
            label_ctx.message:fragment(label)

            -- Add bar/locked status if applicable
            if inv.supports_bar() and slot_index >= inv.get_bar() then
               label_ctx.message:fragment({ "fa.ui-inventory-slot-locked" })
            end
         end,
         on_click = function(click_ctx)
            local player = game.get_player(click_ctx.pindex)
            local cursor_stack = player.cursor_stack
            local inv_stack = inv[slot_index]

            -- SHIFT+[ : Equip from slot or repair item in slot
            if click_ctx.modifiers.shift then
               -- Check if hand has repair pack
               if cursor_stack and cursor_stack.valid_for_read and cursor_stack.is_repair_tool then
                  -- Repair item in this slot
                  local result = Equipment.repair_item_in_slot(click_ctx.pindex, entity, inventory_index, slot_index)
                  click_ctx.controller.message:fragment(result)
               else
                  -- Equip item from this slot to entity
                  local result = Equipment.equip_item_from_slot(click_ctx.pindex, entity, inventory_index, slot_index)
                  click_ctx.controller.message:fragment(result)
               end
               return
            end

            -- Normal click: swap stacks between cursor and inventory
            sounds.play_menu_click(click_ctx.pindex)

            if cursor_stack and inv_stack then
               cursor_stack.swap_stack(inv_stack)

               -- Announce what's now in hand (or that hand is empty)
               if cursor_stack.valid_for_read then
                  local item_description = Localising.localise_item({
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
            -- Handle right click (split stack)
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
                     inv_stack.set_stack({ name = cursor_stack.name, count = half, quality = cursor_stack.quality })
                     cursor_stack.count = cursor_stack.count - half
                     click_ctx.controller.message:fragment({ "fa.placed-stuff", { "fa.half-stack" } })
                  end
               elseif not cursor_stack.valid_for_read and inv_stack.valid_for_read then
                  -- Cursor is empty, inventory has items - take half
                  local half = math.floor(inv_stack.count / 2)
                  if half > 0 then
                     cursor_stack.set_stack({ name = inv_stack.name, count = half, quality = inv_stack.quality })
                     inv_stack.count = inv_stack.count - half
                     local item_description = Localising.localise_item({
                        name = cursor_stack.name,
                        count = cursor_stack.count,
                        quality = cursor_stack.quality and cursor_stack.quality.name or nil,
                     })
                     click_ctx.controller.message:fragment({ "fa.grabbed-stuff", item_description })
                  end
               elseif cursor_stack.valid_for_read and inv_stack.valid_for_read then
                  -- Both have items - swap like left click
                  cursor_stack.swap_stack(inv_stack)
                  local item_description = Localising.localise_item({
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
            ItemDescriptions.push_equipment_info(coord_ctx.message, stack)
         end,
         on_read_info = function(info_ctx, x, y)
            -- Read detailed item info (y = just item info)
            local slot_index = grid_pos_to_slot(x, y)
            local stack = inv[slot_index]
            ItemDescriptions.push_equipment_info(info_ctx.message, stack)
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
   if accelerator_name == UiRouter.ACCELERATORS.RELOAD_WEAPONS then
      -- Reload weapons FROM this inventory TO entity's guns
      local result = Equipment.reload_weapons(ctx.pindex, entity, inv_index, entity)
      ctx.message:fragment(result)
   elseif accelerator_name == UiRouter.ACCELERATORS.UNLOAD_GUNS then
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
---@param params { name: string, title?: LocalisedString }
---@return fa.ui.TabDescriptor
function mod.create_inventory_grid(params)
   return UiKeyGraph.declare_graph({
      name = params.name,
      title = params.title or { "fa.ui-inventory-title" },
      render_callback = render_inventory_grid,
      on_accelerator = handle_accelerator,
   })
end

return mod
