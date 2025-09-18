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

local mod = {}

---@class fa.ui.InventoryGrid.Parameters
---@field inventory LuaInventory The inventory to display
---@field title LocalisedString? Optional title for the inventory

---@class fa.ui.InventoryGrid.State
---@field inventory LuaInventory

---@class fa.ui.InventoryGrid.Context: fa.ui.graph.Ctx
---@field parameters table<string, fa.ui.InventoryGrid.Parameters>
---@field tablist_shared_state table<string, fa.ui.InventoryGrid.State>

-- Constants
local GRID_WIDTH = 10 -- Match the old inventory system

---Generate a label for an inventory slot
---@param inv LuaInventory
---@param slot_index number
---@return LocalisedString
local function get_slot_label(inv, slot_index)
   local stack = inv[slot_index]

   if not stack or not stack.valid_for_read then return { "fa.ui-inventory-empty-slot" } end

   -- Build the item label with count and quality
   return Localising.localise_item({
      name = stack.name,
      count = stack.count,
      quality = stack.quality and stack.quality.name or nil,
   })
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
---@param subkey string The subkey that this is using for params and state
---@return fa.ui.graph.Render?
local function render_inventory_grid(ctx, subkey)
   -- Get inventory from shared state if available, otherwise from parameters
   local inv = ctx.tablist_shared_state[subkey].inventory

   if not inv or not inv.valid then return nil end

   local builder = Grid.grid_builder()
   builder:set_dimension_labeler(inventory_dimension_labeler)

   -- Calculate grid dimensions
   local total_slots = #inv
   local grid_height = math.ceil(total_slots / GRID_WIDTH)

   -- Build the grid
   for slot_index = 1, total_slots do
      local x, y = slot_to_grid_pos(slot_index)
      local label = get_slot_label(inv, slot_index)

      builder:add_control(x, y, function(label_ctx)
         label_ctx.message:fragment(label)

         -- Add bar/locked status if applicable
         if inv.supports_bar() and slot_index >= inv.get_bar() then
            label_ctx.message:fragment({ "fa.ui-inventory-slot-locked" })
         end
      end, {
         on_click = function(click_ctx)
            -- Handle inventory slot clicks (item transfers - left click swaps stacks)
            local player = game.get_player(click_ctx.pindex)
            local cursor_stack = player.cursor_stack
            local inv_stack = inv[slot_index]

            -- Play inventory click sound
            sounds.play_inventory_click(click_ctx.pindex)

            -- Swap stacks between cursor and inventory
            if cursor_stack and inv_stack then
               cursor_stack.swap_stack(inv_stack)

               -- Announce what's now in hand (or that hand is empty)
               if cursor_stack.valid_for_read then
                  local item_description = Localising.localise_item({
                     name = cursor_stack.name,
                     count = cursor_stack.count,
                     quality = cursor_stack.quality and cursor_stack.quality.name or nil,
                  })
                  Speech.speak(click_ctx.pindex, { "fa.grabbed-stuff", item_description })
               else
                  Speech.speak(click_ctx.pindex, { "fa.grabbed-nothing" })
               end
            end
         end,
         on_right_click = function(click_ctx)
            -- Handle right click (split stack)
            local player = game.get_player(click_ctx.pindex)
            local cursor_stack = player.cursor_stack
            local inv_stack = inv[slot_index]

            -- Play inventory click sound
            sounds.play_inventory_click(click_ctx.pindex)

            -- Right click logic: split stack or transfer half
            if cursor_stack and inv_stack then
               if cursor_stack.valid_for_read and not inv_stack.valid_for_read then
                  -- Cursor has items, inventory slot is empty - transfer half to inventory
                  local half = math.floor(cursor_stack.count / 2)
                  if half > 0 then
                     inv_stack.set_stack({ name = cursor_stack.name, count = half, quality = cursor_stack.quality })
                     cursor_stack.count = cursor_stack.count - half
                     Speech.speak(click_ctx.pindex, { "fa.placed-stuff", { "fa.half-stack" } })
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
                     Speech.speak(click_ctx.pindex, { "fa.grabbed-stuff", item_description })
                  end
               elseif cursor_stack.valid_for_read and inv_stack.valid_for_read then
                  -- Both have items - swap like left click
                  cursor_stack.swap_stack(inv_stack)
                  local item_description = Localising.localise_item({
                     name = cursor_stack.name,
                     count = cursor_stack.count,
                     quality = cursor_stack.quality and cursor_stack.quality.name or nil,
                  })
                  Speech.speak(click_ctx.pindex, { "fa.grabbed-stuff", item_description })
               end
            end
         end,
         on_read_coords = function(coord_ctx)
            -- Read the slot position
            local slot_index = grid_pos_to_slot(coord_ctx.x, coord_ctx.y)
            local row = coord_ctx.y
            Speech.speak(coord_ctx.pindex, { "fa.ui-inventory-slot-position", slot_index, row })
         end,
      })
   end

   return builder:build()
end

---Create an inventory grid graph declaration
---@param params { name: string, title?: LocalisedString, subkey: string }
---@return fa.ui.TabDescriptor
function mod.create_inventory_grid(params)
   return UiKeyGraph.declare_graph({
      name = params.name,
      title = params.title or { "fa.ui-inventory-title" },
      render_callback = function(ctx)
         return render_inventory_grid(ctx, params.subkey)
      end,
   })
end

return mod
