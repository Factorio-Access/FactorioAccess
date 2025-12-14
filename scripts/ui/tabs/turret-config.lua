--[[
Turret configuration tab.

Provides controls for:
- Summary row with ammo and range
- Ignore unprioritized targets checkbox
- Priority target slots
]]

local Controls = require("scripts.ui.controls")
local InventoryUtils = require("scripts.inventory-utils")
local Localising = require("scripts.localising")
local Menu = require("scripts.ui.menu")
local UiKeyGraph = require("scripts.ui.key-graph")
local UiRouter = require("scripts.ui.router")
local UiSounds = require("scripts.ui.sounds")

local mod = {}

-- Number of priority target slots (Factorio standard)
local PRIORITY_SLOT_COUNT = 10

-- Entity types that can be turret priority targets
local TARGETABLE_TYPES = {
   ["unit"] = true,
   ["unit-spawner"] = true,
   ["turret"] = true,
   ["car"] = true,
   ["spider-vehicle"] = true,
   ["asteroid"] = true,
   ["segment"] = true,
   ["segmented-unit"] = true,
}

---Check if an entity prototype can be a turret target
---@param proto LuaEntityPrototype
---@return boolean
local function is_targetable_entity(proto)
   return TARGETABLE_TYPES[proto.type] or false
end

---Get ammo summary for a turret
---@param entity LuaEntity
---@return LocalisedString
local function get_ammo_summary(entity)
   local ammo_inv = InventoryUtils.get_ammo_inventory(entity)
   if not ammo_inv then return { "fa.turret-no-ammo-slot" } end

   local contents = ammo_inv.get_contents()
   local presenting = InventoryUtils.present_list(contents)
   if presenting then
      return presenting
   else
      return { "fa.empty" }
   end
end

---Render the turret configuration form
---@param ctx fa.ui.TabContext
---@return fa.ui.graph.Render?
local function render_turret_config(ctx)
   local entity = ctx.tablist_shared_state.entity
   if not entity or not entity.valid then return nil end

   local builder = Menu.MenuBuilder.new()

   -- Summary row: ammo and range
   builder:add_label("summary", function(label_ctx)
      local ammo = get_ammo_summary(entity)
      local range = entity.prototype.turret_range or 0
      label_ctx.message:fragment({ "fa.turret-summary", ammo, tostring(range) })
   end)

   -- Ignore unprioritized targets checkbox
   builder:add_item(
      "ignore_unprioritized",
      Controls.checkbox({
         label = { "fa.turret-ignore-unprioritized" },
         get = function()
            return entity.ignore_unprioritised_targets
         end,
         set = function(value)
            entity.ignore_unprioritised_targets = value
         end,
      })
   )

   -- Priority targets row
   builder:start_row("priority_targets")

   -- Label for the row
   builder:add_item("priority_label", {
      label = function(label_ctx)
         label_ctx.message:fragment({ "fa.turret-priority-targets" })
      end,
   })

   -- Priority target slots
   for i = 1, PRIORITY_SLOT_COUNT do
      local slot_index = i
      local slot_key = "priority_" .. i

      builder:add_item(slot_key, {
         label = function(label_ctx)
            local target = entity.get_priority_target(slot_index)
            if target then
               label_ctx.message:fragment(Localising.get_localised_name_with_fallback(target))
            else
               label_ctx.message:fragment({ "fa.empty" })
            end
         end,
         on_click = function(click_ctx)
            -- Open entity chooser filtered to targetable entities
            click_ctx.controller:open_child_ui(UiRouter.UI_NAMES.ENTITY_CHOOSER, {
               filter_func = is_targetable_entity,
            }, { node = slot_key })
         end,
         on_child_result = function(result_ctx, result)
            if result then
               entity.set_priority_target(slot_index, result)
               local proto = prototypes.entity[result]
               if proto then
                  result_ctx.controller.message:fragment(Localising.get_localised_name_with_fallback(proto))
               end
            end
         end,
         on_clear = function(clear_ctx)
            entity.set_priority_target(slot_index, nil)
            clear_ctx.controller.message:fragment({ "fa.empty" })
         end,
         on_drag_up = function(drag_ctx)
            -- Swap with previous slot
            if slot_index > 1 then
               local current = entity.get_priority_target(slot_index)
               local prev = entity.get_priority_target(slot_index - 1)
               entity.set_priority_target(slot_index, prev and prev.name or nil)
               entity.set_priority_target(slot_index - 1, current and current.name or nil)
               UiSounds.play_menu_move(drag_ctx.pindex)
               drag_ctx.controller.message:fragment({ "fa.turret-swapped-with-previous" })
            else
               UiSounds.play_ui_edge(drag_ctx.pindex)
            end
         end,
         on_drag_down = function(drag_ctx)
            -- Swap with next slot
            if slot_index < PRIORITY_SLOT_COUNT then
               local current = entity.get_priority_target(slot_index)
               local next_target = entity.get_priority_target(slot_index + 1)
               entity.set_priority_target(slot_index, next_target and next_target.name or nil)
               entity.set_priority_target(slot_index + 1, current and current.name or nil)
               UiSounds.play_menu_move(drag_ctx.pindex)
               drag_ctx.controller.message:fragment({ "fa.turret-swapped-with-next" })
            else
               UiSounds.play_ui_edge(drag_ctx.pindex)
            end
         end,
      })
   end

   builder:end_row()

   return builder:build()
end

-- Create the tab descriptor
mod.turret_config_tab = UiKeyGraph.declare_graph({
   name = "turret-config",
   title = { "fa.turret-config-title" },
   render_callback = render_turret_config,
})

---Check if this tab is available for the given entity
---@param entity LuaEntity
---@return boolean
function mod.is_available(entity)
   -- Check if entity is a turret type (has turret-specific properties)
   local proto = entity.prototype
   if not proto then return false end

   -- Check for turret types
   local turret_types = {
      ["ammo-turret"] = true,
      ["electric-turret"] = true,
      ["fluid-turret"] = true,
   }

   return turret_types[proto.type] or false
end

return mod
