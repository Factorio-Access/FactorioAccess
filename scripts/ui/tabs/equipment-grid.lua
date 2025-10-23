--[[
Equipment grid tab for displaying character/armor equipment grid.
Readonly interface showing equipment layout and status.
]]

local Grid = require("scripts.ui.grid")
local Localising = require("scripts.localising")
local Speech = require("scripts.speech")
local UiKeyGraph = require("scripts.ui.key-graph")
local UiRouter = require("scripts.ui.router")
local UiSounds = require("scripts.ui.sounds")
local Equipment = require("scripts.equipment")
local MessageBuilder = Speech.MessageBuilder

local mod = {}

---Check if equipment grid tab is available for an entity
---@param entity LuaEntity
---@return boolean
function mod.is_available(entity)
   if not entity or not entity.valid then return false end
   return entity.grid ~= nil
end

---Build a map of occupied cells for equipment positioning
---@param grid LuaEquipmentGrid
---@return table<string, LuaEquipment> Map of "x,y" to equipment occupying that cell
local function build_cell_map(grid)
   local cell_map = {}

   for _, equipment in ipairs(grid.equipment) do
      local pos = equipment.position
      local shape = equipment.shape

      -- Equipment occupies cells from position to position + shape
      for dx = 0, shape.width - 1 do
         for dy = 0, shape.height - 1 do
            local cell_x = pos.x + dx
            local cell_y = pos.y + dy
            local key = string.format("%d,%d", cell_x, cell_y)
            cell_map[key] = equipment
         end
      end
   end

   return cell_map
end

---Handle equipment removal to inventory (left bracket / on_click)
---@param ctx fa.ui.graph.Ctx
---@param grid LuaEquipmentGrid
---@param equipment LuaEquipment
local function handle_remove_to_inventory(ctx, grid, equipment)
   local player = game.get_player(ctx.pindex)
   if not player then return end

   local name = Localising.get_localised_name_with_fallback(equipment.prototype)
   -- Invalidates the equipment
   local result = grid.take({ equipment = equipment, by_player = ctx.pindex })
   if result then
      ctx.message:fragment({
         "fa.equipment-removed-to-inventory",
         name,
      })
      UiSounds.play_menu_click(ctx.pindex)
   else
      ctx.message:fragment({ "fa.equipment-cannot-remove" })
   end
end

---Handle marking equipment for removal (backspace / on_clear)
---@param ctx fa.ui.graph.Ctx
---@param grid LuaEquipmentGrid
---@param equipment LuaEquipment
local function handle_mark_for_removal(ctx, grid, equipment)
   if equipment.to_be_removed then
      ctx.message:fragment({ "fa.equipment-already-marked" })
      return
   end

   local success = grid.order_removal(equipment)
   if success then
      ctx.message:fragment({ "fa.equipment-marked-for-removal" })
   else
      ctx.message:fragment({ "fa.equipment-cannot-mark" })
   end
end

---Handle dragging equipment in a direction
---@param ctx fa.ui.graph.Ctx
---@param grid LuaEquipmentGrid
---@param equipment LuaEquipment
---@param dx number Change in x position
---@param dy number Change in y position
local function handle_drag_equipment(ctx, grid, equipment, dx, dy)
   local current_pos = equipment.position
   local new_x = current_pos.x + dx
   local new_y = current_pos.y + dy

   -- Check if moving past edge
   local shape = equipment.shape
   if new_x < 0 or new_y < 0 or (new_x + shape.width) > grid.width or (new_y + shape.height) > grid.height then
      UiSounds.play_ui_edge(ctx.pindex)
      return
   end

   -- Try to move
   local new_pos = { x = new_x, y = new_y }
   if grid.can_move({ equipment = equipment, position = new_pos }) then
      local success = grid.move({ equipment = equipment, position = new_pos })
      if success then
         UiSounds.play_menu_move(ctx.pindex)
         ctx.message:fragment({ "fa.equipment-moved" })
         -- Suggest moving to the new position (convert to 1-based grid coordinates)
         local new_grid_key = Grid.make_key(new_x + 1, new_y + 1)
         ctx.graph_controller:suggest_move(new_grid_key)
      else
         ctx.message:fragment({ "fa.equipment-cannot-move" })
      end
   else
      ctx.message:fragment({ "fa.equipment-blocked" })
   end
end

---Render the equipment grid
---@param ctx fa.ui.graph.Ctx
---@return fa.ui.graph.Render?
local function render_equipment_grid(ctx)
   local params = ctx.global_parameters
   local player = game.get_player(ctx.pindex)
   if not player then return nil end

   -- Get target entity from params (defaults to player character for main menu)
   local entity = params.entity or player.character
   if not entity or not entity.valid then return nil end

   local grid = entity.grid
   if not grid then
      ctx.message:fragment({ "fa.equipment-no-grid" })
      return nil
   end

   local builder = Grid.grid_builder()
   local cell_map = build_cell_map(grid)

   -- Build grid cells
   for y = 0, grid.height - 1 do
      for x = 0, grid.width - 1 do
         local cell_x = x + 1 -- Convert to 1-based for grid display
         local cell_y = y + 1
         local key = string.format("%d,%d", x, y)
         local equipment = cell_map[key]

         if equipment then
            -- Show full equipment label on ALL cells occupied by this equipment
            builder:add_control(cell_x, cell_y, {
               label = function(label_ctx)
                  label_ctx.message:fragment(Equipment.get_equipment_label(grid, equipment))
               end,
               on_read_coords = function(info_ctx)
                  info_ctx.message:fragment(Equipment.get_equipment_info(grid, equipment))
               end,
               on_click = function(click_ctx)
                  handle_remove_to_inventory(click_ctx, grid, equipment)
               end,
               on_clear = function(clear_ctx)
                  handle_mark_for_removal(clear_ctx, grid, equipment)
               end,
               on_drag_up = function(drag_ctx)
                  handle_drag_equipment(drag_ctx, grid, equipment, 0, -1)
               end,
               on_drag_down = function(drag_ctx)
                  handle_drag_equipment(drag_ctx, grid, equipment, 0, 1)
               end,
               on_drag_left = function(drag_ctx)
                  handle_drag_equipment(drag_ctx, grid, equipment, -1, 0)
               end,
               on_drag_right = function(drag_ctx)
                  handle_drag_equipment(drag_ctx, grid, equipment, 1, 0)
               end,
            })
         else
            -- Empty cell - clicking opens equipment selector
            builder:add_control(cell_x, cell_y, {
               label = function(label_ctx)
                  label_ctx.message:fragment({ "fa.equipment-empty-slot" })
               end,
               on_click = function(click_ctx)
                  -- Open equipment selector with grid dimensions
                  click_ctx.controller:open_child_ui(UiRouter.UI_NAMES.EQUIPMENT_SELECTOR, {
                     character = player.character,
                     equip_target = entity,
                     max_x = grid.width,
                     max_y = grid.height,
                  }, { node = Grid.make_key(cell_x, cell_y), x = x, y = y }) -- node key + target position
               end,
               on_child_result = function(result_ctx, result)
                  if not result then return end

                  -- Context is stored in result_ctx.child_context by key-graph
                  local context = result_ctx.child_context

                  -- Try to place the equipment at the target position
                  local placed = grid.put({
                     name = result.prototype_name,
                     position = { x = context.x, y = context.y },
                     quality = result.quality_name,
                     by_player = result_ctx.pindex,
                  })

                  if placed then
                     result_ctx.message:fragment({
                        "fa.equipment-placed",
                        Localising.get_localised_name_with_fallback(placed.prototype),
                     })
                     UiSounds.play_menu_click(result_ctx.pindex)
                  else
                     result_ctx.message:fragment({ "fa.equipment-cannot-place" })
                  end
               end,
            })
         end
      end
   end

   return builder:build()
end

mod.equipment_grid_tab = UiKeyGraph.declare_graph({
   name = "equipment_grid",
   title = { "fa.equipment-grid-title" },
   render_callback = render_equipment_grid,
})

return mod
