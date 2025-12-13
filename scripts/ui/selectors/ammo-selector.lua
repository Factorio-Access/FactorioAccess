--[[
Ammo selector for choosing ammunition to load.
Only shows ammo compatible with the current weapon, from the current entity only.
Returns selection result - caller handles the action.
]]

local CombatData = require("scripts.combat.combat-data")
local InventoryUtils = require("scripts.inventory-utils")
local ItemInfo = require("scripts.item-info")
local ItemStackUtils = require("scripts.item-stack-utils")
local KeyGraph = require("scripts.ui.key-graph")
local Menu = require("scripts.ui.menu")
local TabList = require("scripts.ui.tab-list")
local UiRouter = require("scripts.ui.router")

local mod = {}

---@enum fa.AmmoSelectorKind
mod.KIND = {
   LOAD = "load",
   REMOVE_TO_HAND = "remove-to-hand",
   REMOVE_TO_INVENTORY = "remove-to-inventory",
   REMOVE_TO_PLAYER = "remove-to-player",
}

---@class fa.AmmoSelectorResult
---@field type "ammo"
---@field kind fa.AmmoSelectorKind
---@field stack LuaItemStack? The ammo stack (for LOAD kind)

---Get the ammo categories accepted by a gun
---@param gun_name string
---@return string[]
local function get_gun_ammo_categories(gun_name)
   local gun_data = CombatData.get_gun_data(gun_name)
   if gun_data then return gun_data.ammo_categories end
   return {}
end

---Check if ammo is compatible with a gun
---@param gun_name string
---@param ammo_name string
---@return boolean
local function is_ammo_compatible(gun_name, ammo_name)
   local gun_categories = get_gun_ammo_categories(gun_name)
   local ammo_proto = prototypes.item[ammo_name]
   if not ammo_proto or not ammo_proto.ammo_category then return false end

   local ammo_category = ammo_proto.ammo_category.name
   for _, cat in ipairs(gun_categories) do
      if cat == ammo_category then return true end
   end
   return false
end

---Get all ammo from an inventory compatible with a gun
---@param inventory LuaInventory?
---@param gun_name string?
---@return table[] Array of {name, quality, count, stacks}
local function get_compatible_ammo_from_inventory(inventory, gun_name)
   if not inventory or not gun_name then return {} end
   return ItemStackUtils.aggregate_inventory(inventory, function(stack)
      if stack.type ~= "ammo" then return false end
      return is_ammo_compatible(gun_name, stack.name)
   end)
end

---Build the ammo selector menu
---@param ctx fa.ui.graph.Ctx
---@return fa.ui.graph.Render?
local function render_ammo_selector(ctx)
   local params = ctx.global_parameters
   local entity = params.entity
   local character = params.character
   local slot = params.slot
   local gun_name = params.gun_name

   if not entity or not entity.valid or not gun_name then return nil end

   local builder = Menu.MenuBuilder.new()
   local is_character = entity.type == "character"

   -- Removal options row (if ammo exists)
   local current_ammo = InventoryUtils.get_ammo_in_slot(entity, slot)
   if current_ammo then
      builder:start_row("remove-options")

      -- Remove to inventory - always available
      builder:add_clickable("remove-to-inventory", function(label_ctx)
         label_ctx.message:fragment({ "fa.ammo-selector-remove-to-inventory" })
      end, {
         on_click = function()
            ctx.controller:close_with_result({ type = "ammo", kind = mod.KIND.REMOVE_TO_INVENTORY })
         end,
      })

      -- Remove to hand - always available
      builder:add_clickable("remove-to-hand", function(label_ctx)
         label_ctx.message:fragment({ "fa.ammo-selector-remove-to-hand" })
      end, {
         on_click = function()
            ctx.controller:close_with_result({ type = "ammo", kind = mod.KIND.REMOVE_TO_HAND })
         end,
      })

      -- Remove to player inventory - only if viewing something other than player's character
      if not is_character and character and character.valid then
         builder:add_clickable("remove-to-player", function(label_ctx)
            label_ctx.message:fragment({ "fa.ammo-selector-remove-to-player" })
         end, {
            on_click = function()
               ctx.controller:close_with_result({ type = "ammo", kind = mod.KIND.REMOVE_TO_PLAYER })
            end,
         })
      end

      builder:end_row()
   end

   -- Get compatible ammo from entity's main inventory
   local entity_main_inv = InventoryUtils.get_main_inventory(entity)
   local compatible_ammo = get_compatible_ammo_from_inventory(entity_main_inv, gun_name)

   -- Add compatible ammo options
   if #compatible_ammo > 0 then
      builder:start_row("ammo")
      for _, ammo_data in ipairs(compatible_ammo) do
         local key = string.format("ammo-%s-%s", ammo_data.name, ammo_data.quality)
         builder:add_clickable(key, function(label_ctx)
            label_ctx.message:fragment(ItemInfo.item_info(ammo_data.stacks[1]))
         end, {
            on_click = function()
               ctx.controller:close_with_result({ type = "ammo", kind = mod.KIND.LOAD, stack = ammo_data.stacks[1] })
            end,
         })
      end
      builder:end_row()
   else
      builder:add_label("no-ammo", { "fa.ammo-selector-no-compatible-ammo" })
   end

   -- If not character, explain that ammo must be in the entity
   if not is_character then builder:add_label("ammo-note", { "fa.ammo-selector-must-be-in-entity" }) end

   return builder:build()
end

local ammo_selector_tab = KeyGraph.declare_graph({
   name = "ammo_selector",
   title = { "fa.ammo-selector-title" },
   render_callback = render_ammo_selector,
})

mod.ammo_selector_menu = TabList.declare_tablist({
   ui_name = UiRouter.UI_NAMES.AMMO_SELECTOR,
   resets_to_first_tab_on_open = true,
   tabs_callback = function()
      return {
         {
            name = "ammo_selector",
            tabs = { ammo_selector_tab },
         },
      }
   end,
})

UiRouter.register_ui(mod.ammo_selector_menu)

return mod
