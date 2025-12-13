--[[
Weapon selector for choosing weapons to equip.
Shows weapons from current entity and optionally from player inventory.
Returns selection result - caller handles the action.
]]

local InventoryUtils = require("scripts.inventory-utils")
local ItemInfo = require("scripts.item-info")
local ItemStackUtils = require("scripts.item-stack-utils")
local KeyGraph = require("scripts.ui.key-graph")
local Menu = require("scripts.ui.menu")
local TabList = require("scripts.ui.tab-list")
local UiRouter = require("scripts.ui.router")

local mod = {}

---@enum fa.WeaponSelectorKind
mod.KIND = {
   EQUIP = "equip",
   REMOVE_TO_HAND = "remove-to-hand",
   REMOVE_TO_INVENTORY = "remove-to-inventory",
   REMOVE_TO_PLAYER = "remove-to-player",
}

---@class fa.WeaponSelectorResult
---@field type "weapon"
---@field kind fa.WeaponSelectorKind
---@field stack LuaItemStack? The weapon stack (for EQUIP kind)

---Get all weapons from an inventory
---@param inventory LuaInventory?
---@return table[] Array of {name, quality, count, stacks}
local function get_weapons_from_inventory(inventory)
   if not inventory then return {} end
   return ItemStackUtils.aggregate_inventory(inventory, function(stack)
      return stack.type == "gun"
   end)
end

---Build the weapon selector menu
---@param ctx fa.ui.graph.Ctx
---@return fa.ui.graph.Render?
local function render_weapon_selector(ctx)
   local params = ctx.global_parameters
   local entity = params.entity
   local character = params.character
   local slot = params.slot

   if not entity or not entity.valid then return nil end

   local builder = Menu.MenuBuilder.new()
   local is_character = entity.type == "character"

   -- Removal options row (if weapon exists)
   local current_gun = InventoryUtils.get_gun_in_slot(entity, slot)
   if current_gun then
      builder:start_row("remove-options")

      -- Remove to inventory - always available
      builder:add_clickable("remove-to-inventory", function(label_ctx)
         label_ctx.message:fragment({ "fa.weapon-selector-remove-to-inventory" })
      end, {
         on_click = function()
            ctx.controller:close_with_result({ type = "weapon", kind = mod.KIND.REMOVE_TO_INVENTORY })
         end,
      })

      -- Remove to hand - always available
      builder:add_clickable("remove-to-hand", function(label_ctx)
         label_ctx.message:fragment({ "fa.weapon-selector-remove-to-hand" })
      end, {
         on_click = function()
            ctx.controller:close_with_result({ type = "weapon", kind = mod.KIND.REMOVE_TO_HAND })
         end,
      })

      -- Remove to player inventory - only if viewing something other than player's character
      if not is_character and character and character.valid then
         builder:add_clickable("remove-to-player", function(label_ctx)
            label_ctx.message:fragment({ "fa.weapon-selector-remove-to-player" })
         end, {
            on_click = function()
               ctx.controller:close_with_result({ type = "weapon", kind = mod.KIND.REMOVE_TO_PLAYER })
            end,
         })
      end

      builder:end_row()
   end

   -- Get weapons from entity's main inventory
   local entity_main_inv = InventoryUtils.get_main_inventory(entity)
   local entity_weapons = get_weapons_from_inventory(entity_main_inv)

   -- Add weapons from entity
   if #entity_weapons > 0 then
      builder:start_row("entity-weapons")
      for _, weapon_data in ipairs(entity_weapons) do
         local key = string.format("entity-%s-%s", weapon_data.name, weapon_data.quality)
         builder:add_clickable(key, function(label_ctx)
            label_ctx.message:fragment(ItemInfo.item_info(weapon_data.stacks[1]))
         end, {
            on_click = function()
               ctx.controller:close_with_result({
                  type = "weapon",
                  kind = mod.KIND.EQUIP,
                  stack = weapon_data.stacks[1],
               })
            end,
         })
      end
      builder:end_row()
   end

   -- If not character, also show weapons from player inventory
   if not is_character and character and character.valid then
      local char_main_inv = InventoryUtils.get_main_inventory(character)
      local char_weapons = get_weapons_from_inventory(char_main_inv)

      if #char_weapons > 0 then
         builder:add_label("player-weapons-header", { "fa.weapon-selector-your-inventory" })
         builder:start_row("player-weapons")
         for _, weapon_data in ipairs(char_weapons) do
            local key = string.format("player-%s-%s", weapon_data.name, weapon_data.quality)
            builder:add_clickable(key, function(label_ctx)
               label_ctx.message:fragment(ItemInfo.item_info(weapon_data.stacks[1]))
            end, {
               on_click = function()
                  ctx.controller:close_with_result({
                     type = "weapon",
                     kind = mod.KIND.EQUIP,
                     stack = weapon_data.stacks[1],
                  })
               end,
            })
         end
         builder:end_row()
      end
   end

   -- If no weapons available
   if
      #entity_weapons == 0
      and (
         is_character
         or not character
         or #get_weapons_from_inventory(InventoryUtils.get_main_inventory(character)) == 0
      )
   then
      builder:add_label("no-weapons", { "fa.weapon-selector-no-weapons" })
   end

   return builder:build()
end

local weapon_selector_tab = KeyGraph.declare_graph({
   name = "weapon_selector",
   title = { "fa.weapon-selector-title" },
   render_callback = render_weapon_selector,
})

mod.weapon_selector_menu = TabList.declare_tablist({
   ui_name = UiRouter.UI_NAMES.WEAPON_SELECTOR,
   resets_to_first_tab_on_open = true,
   tabs_callback = function()
      return {
         {
            name = "weapon_selector",
            tabs = { weapon_selector_tab },
         },
      }
   end,
})

UiRouter.register_ui(mod.weapon_selector_menu)

return mod
