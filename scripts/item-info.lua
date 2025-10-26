--[[
Item Info Module
Provides detailed information about items, especially equipment and buildings.
Includes item localization (moved from localising.lua).
]]

local Localising = require("scripts.localising")
local FaUtils = require("scripts.fa-utils")
local Speech = require("scripts.speech")
local MessageBuilder = Speech.MessageBuilder

local mod = {}

---Verbosity levels for item information
mod.VERBOSITY = {
   BRIEF = 1,
   VERBOSE = 2,
}

---Marker to say "other item" in localise_item
mod.ITEM_OTHER = {}

---@class fa.ItemInfo.LocaliseItemOpts
---@field name LuaItemPrototype | LuaFluidPrototype | string | `mod.ITEM_OTHER`
---@field quality (LuaQualityPrototype|string)?
---@field count number?

--[[
Localise an item, or fluid, possibly with count and quality.

This function can take two things. An LuaItemStack, or a table with 3 keys:
name, quality, and count. In that table, name and quality may either be a
string or a LuaXXXPrototype. It:

- For the case of stacks, "transport belt X 50" or (for non-normal quality)
  "legendary transport belt X 50".
- For the case of the table, announce item with (if present and non-normal)
  quality and (if present) count. That is, leaving stuff out is how you prevent
  it being announced.

for the case of "and 5 other items" you may use mod.ITEM_OTHER in place of the
name.
]]
---Get item or fluid info as a LocalisedString
---@param what LuaItemStack | fa.ItemInfo.LocaliseItemOpts
---@param protos table<string, LuaItemPrototype|LuaFluidPrototype>
---@return LocalisedString
function mod.item_or_fluid_info(what, protos)
   ---@type fa.ItemInfo.LocaliseItemOpts
   local final_opts

   if type(what) == "userdata" then
      ---@type LuaItemStack
      local stack = what --[[@as LuaItemStack ]]
      assert(stack.object_name == "LuaItemStack")

      final_opts = {
         name = stack.prototype,
         quality = stack.quality,
         count = stack.count,
         is_blueprint = stack.is_blueprint,
         blueprint_label = stack.is_blueprint and stack.label or nil,
         is_blueprint_book = stack.is_blueprint_book,
         blueprint_book_label = stack.is_blueprint_book and stack.label or nil,
      }
   else
      if what.name == mod.ITEM_OTHER then
         assert(what.count, "it does not make sense to ask to localise ITEM_OTHER without also giving a count")
         return { "fa.item-other", what.count }
      end

      final_opts = what --[[ @as fa.ItemInfo.LocaliseItemOpts ]]
   end

   local quality = final_opts.quality
   local name = final_opts.name
   local count = final_opts.count

   local item_proto, quality_proto

   if type(name) == "string" then
      item_proto = protos[name]
   elseif name then
      item_proto = name
   end
   if not item_proto then error("unable to find item " .. name) end

   if quality and type(quality) == "string" then
      quality_proto = prototypes.quality[quality]
   elseif quality then
      quality_proto = quality --[[@as LuaQualityPrototype ]]
   else
      quality_proto = prototypes.quality["normal"]
   end
   assert((not quality) or quality_proto)

   local item_str = Localising.get_localised_name_with_fallback(item_proto)
   local quality_str = Localising.get_localised_name_with_fallback(quality_proto)
   local has_quality = (quality and quality_proto.name ~= "normal") and 1 or 0
   local has_count = (count and count > 1) and 1 or 0

   -- Special case for blueprints with labels
   if final_opts.is_blueprint and final_opts.blueprint_label then
      return { "fa.item-blueprint", final_opts.blueprint_label, has_quality, quality_str, has_count, count }
   end

   -- Special case for blueprint books with labels
   if final_opts.is_blueprint_book and final_opts.blueprint_book_label then
      return { "fa.item-blueprint-book", final_opts.blueprint_book_label, has_quality, quality_str, has_count, count }
   end

   return { "fa.item-quantity-quality", item_str, has_quality, quality_str, has_count, count }
end

---Get item info as a LocalisedString
---@param what LuaItemStack | fa.ItemInfo.LocaliseItemOpts
---@return LocalisedString
function mod.item_info(what)
   return mod.item_or_fluid_info(what, prototypes.item)
end

---@class fa.ItemInfo.EquipmentContext
---@field message fa.MessageBuilder
---@field prototype LuaEquipmentPrototype
---@field quality LuaQualityPrototype

---@class fa.ItemInfo.BuildingContext
---@field message fa.MessageBuilder
---@field prototype LuaEntityPrototype

---Add equipment power consumption info to message
---@param ctx fa.ItemInfo.EquipmentContext
local function equipment_power_consumption_info(ctx)
   local consumption = ctx.prototype.get_energy_consumption(ctx.quality) * 60
   if consumption and consumption > 0 then
      ctx.message:fragment({ "fa.item-info-consumes", FaUtils.format_power(consumption) })
   end
end

---Add equipment battery storage info to message
---@param ctx fa.ItemInfo.EquipmentContext
local function equipment_battery_storage_info(ctx)
   if ctx.prototype.electric_energy_source_prototype then
      local buffer = ctx.prototype.electric_energy_source_prototype.buffer_capacity
      if buffer and buffer > 0 then ctx.message:fragment({ "fa.item-info-stores", FaUtils.format_power(buffer) }) end
   end
end

---Add equipment power generation info to message
---@param ctx fa.ItemInfo.EquipmentContext
local function equipment_power_generation_info(ctx)
   if ctx.prototype.energy_production and ctx.prototype.energy_production > 0 then
      if ctx.prototype.solar_panel_performance_at_day then
         ctx.message:fragment({
            "fa.item-info-generates-solar",
            FaUtils.format_power(ctx.prototype.energy_production * 60),
         })
      else
         ctx.message:fragment({ "fa.item-info-generates", FaUtils.format_power(ctx.prototype.energy_production * 60) })
      end
   end
end

---Add equipment dimensions info to message
---@param ctx fa.ItemInfo.EquipmentContext
local function equipment_dimensions_info(ctx)
   local shape = ctx.prototype.shape
   ctx.message:fragment({ "fa.item-info-dimensions", shape.width, shape.height })
end

---Add building dimensions info to message
---@param ctx fa.ItemInfo.BuildingContext
local function building_dimensions_info(ctx)
   ctx.message:fragment({
      "fa.item-info-building",
      ctx.prototype.tile_width,
      ctx.prototype.tile_height,
   })
end

---@class fa.ItemInfo.GetItemStackInfoOptions
---@field verbosity integer VERBOSITY.BRIEF or VERBOSITY.VERBOSE

---Get detailed information about an item stack
---@param message fa.MessageBuilder
---@param stack LuaItemStack
---@param options fa.ItemInfo.GetItemStackInfoOptions?
function mod.get_item_stack_info(message, stack, options)
   options = options or { verbosity = mod.VERBOSITY.BRIEF }

   if not stack or not stack.valid_for_read then
      message:fragment({ "fa.item-info-no-item" })
      return
   end

   local proto = stack.prototype
   local quality = stack.quality

   -- Start with item name and quality (BRIEF mode - just the item localization)
   message:fragment(mod.item_info({
      name = stack.name,
      count = 1,
      quality = quality and quality.name or nil,
   }))

   -- Only add detailed info for VERBOSE mode
   if options.verbosity == mod.VERBOSITY.BRIEF then return end

   -- Check if this is equipment
   if proto.place_as_equipment_result then
      local equip_proto = proto.place_as_equipment_result
      local ctx = {
         message = message,
         prototype = equip_proto,
         quality = quality,
      }

      equipment_dimensions_info(ctx)
      equipment_power_consumption_info(ctx)
      equipment_battery_storage_info(ctx)
      equipment_power_generation_info(ctx)
   elseif proto.place_result then
      -- This is a building
      local entity_proto = proto.place_result
      local ctx = {
         message = message,
         prototype = entity_proto,
      }
      building_dimensions_info(ctx)
   end
end

---Read item info for item in hand (global fa-y handler)
---@param pindex number
function mod.read_item_in_hand(pindex)
   local player = game.get_player(pindex)
   local cursor_stack = player.cursor_stack

   if not cursor_stack or not cursor_stack.valid_for_read then
      Speech.speak(pindex, { "fa.item-info-no-item" })
      return
   end

   local message = MessageBuilder.new()
   mod.get_item_stack_info(message, cursor_stack, { verbosity = mod.VERBOSITY.VERBOSE })
   Speech.speak(pindex, message:build())
end

return mod
