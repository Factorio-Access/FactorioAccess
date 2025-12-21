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

---Calculate inserter swings per second from rotation speed.
---Inserters must complete half-turns in whole ticks, so actual cycle time
---is truncated to the next lowest even number of ticks.
---@param rotation_speed number Rotation speed in rotations per tick
---@return number swings_per_second
function mod.inserter_swings_per_second(rotation_speed)
   local ticks_per_half_turn = math.floor(1 / rotation_speed / 2)
   return 60 / (ticks_per_half_turn * 2)
end

---Get the base stack size for an inserter from its prototype.
---This is the stack size without force research bonuses.
---@param prototype LuaEntityPrototype
---@return number
function mod.inserter_base_stack_size(prototype)
   local base_size = prototype.inserter_stack_size_bonus or 0
   return base_size + 1
end

---Get the stack size for an inserter prototype with force research bonuses.
---@param prototype LuaEntityPrototype
---@param force LuaForce
---@return number
function mod.inserter_stack_size_with_force(prototype, force)
   local base_size = prototype.inserter_stack_size_bonus or 0
   base_size = base_size + 1

   if prototype.bulk then
      return base_size + force.bulk_inserter_capacity_bonus
   else
      return base_size + force.inserter_stack_size_bonus
   end
end

---Get the maximum stack size for a placed inserter entity.
---Accounts for force research bonuses but not any override.
---@param entity LuaEntity
---@return number
function mod.inserter_max_stack_size(entity)
   return mod.inserter_stack_size_with_force(entity.prototype, entity.force)
end

---Get the effective stack size for a placed inserter entity.
---Uses override if set, otherwise returns max stack size with force bonuses.
---@param entity LuaEntity
---@return number
function mod.inserter_effective_stack_size(entity)
   local override = entity.inserter_stack_size_override
   if override and override > 0 then return override end
   return mod.inserter_max_stack_size(entity)
end

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
---@field quality LuaQualityPrototype
---@field force LuaForce? Optional force for research bonus calculations

---Add equipment power consumption info to message
---@param ctx fa.ItemInfo.EquipmentContext
local function equipment_power_consumption_info(ctx)
   local consumption = ctx.prototype.get_energy_consumption(ctx.quality) * 60
   if consumption and consumption > 0 then
      ctx.message:list_item({ "fa.item-info-consumes", FaUtils.format_power(consumption) })
   end
end

---Add equipment battery storage info to message
---@param ctx fa.ItemInfo.EquipmentContext
local function equipment_battery_storage_info(ctx)
   if ctx.prototype.electric_energy_source_prototype then
      local buffer = ctx.prototype.electric_energy_source_prototype.buffer_capacity
      if buffer and buffer > 0 then
         ctx.message:list_item({ "fa.item-info-stores", FaUtils.format_power(buffer, "j") })
      end
   end
end

---Add equipment power generation info to message
---@param ctx fa.ItemInfo.EquipmentContext
local function equipment_power_generation_info(ctx)
   if ctx.prototype.energy_production and ctx.prototype.energy_production > 0 then
      if ctx.prototype.solar_panel_performance_at_day then
         ctx.message:list_item({
            "fa.item-info-generates-solar",
            FaUtils.format_power(ctx.prototype.energy_production * 60),
         })
      else
         ctx.message:list_item({ "fa.item-info-generates", FaUtils.format_power(ctx.prototype.energy_production * 60) })
      end
   end
end

---Add equipment dimensions info to message
---@param ctx fa.ItemInfo.EquipmentContext
local function equipment_dimensions_info(ctx)
   local shape = ctx.prototype.shape
   ctx.message:list_item({ "fa.item-info-equipment", shape.width, shape.height })
end

---Map entity types to their locale keys for building intro
local BUILDING_TYPE_LOCALE = {
   ["electric-pole"] = "fa.item-info-electric-pole",
   ["beacon"] = "fa.item-info-beacon",
   ["inserter"] = "fa.item-info-inserter",
   ["transport-belt"] = "fa.item-info-belt",
   ["splitter"] = "fa.item-info-splitter",
   ["underground-belt"] = "fa.item-info-underground-belt",
   ["pipe-to-ground"] = "fa.item-info-pipe-to-ground",
   ["roboport"] = "fa.item-info-roboport",
   ["assembling-machine"] = "fa.item-info-crafting-machine",
   ["furnace"] = "fa.item-info-crafting-machine",
   ["rocket-silo"] = "fa.item-info-crafting-machine",
   ["lab"] = "fa.item-info-lab",
   ["mining-drill"] = "fa.item-info-mining-drill",
   ["pump"] = "fa.item-info-pump",
   ["offshore-pump"] = "fa.item-info-pump",
   ["generator"] = "fa.item-info-generator",
   ["burner-generator"] = "fa.item-info-generator",
   ["solar-panel"] = "fa.item-info-solar-panel",
   ["accumulator"] = "fa.item-info-accumulator",
   ["ammo-turret"] = "fa.item-info-turret",
   ["electric-turret"] = "fa.item-info-turret",
   ["fluid-turret"] = "fa.item-info-turret",
   ["artillery-turret"] = "fa.item-info-turret",
   ["radar"] = "fa.item-info-radar",
   ["reactor"] = "fa.item-info-reactor",
   ["container"] = "fa.item-info-container",
   ["logistic-container"] = "fa.item-info-container",
}

---Add electric pole info to message
---@param ctx fa.ItemInfo.BuildingContext
local function building_electric_pole_info(ctx)
   local proto = ctx.prototype
   local quality = ctx.quality

   local supply_radius = proto.get_supply_area_distance(quality)
   local wire_distance = proto.get_max_wire_distance(quality)

   if supply_radius and supply_radius > 0 then
      local diameter = math.floor(supply_radius * 2)
      ctx.message:list_item({ "fa.item-info-supply-area", diameter })
   end
   if wire_distance and wire_distance > 0 then
      ctx.message:list_item({ "fa.item-info-wire-reach", string.format("%.1f", wire_distance) })
   end
end

---Add beacon info to message
---@param ctx fa.ItemInfo.BuildingContext
local function building_beacon_info(ctx)
   local proto = ctx.prototype
   local quality = ctx.quality

   local supply_radius = proto.get_supply_area_distance(quality)
   local effectivity = proto.distribution_effectivity
   local effectivity_bonus = proto.distribution_effectivity_bonus_per_quality_level

   if supply_radius and supply_radius > 0 then
      local diameter = math.floor(supply_radius * 2)
      ctx.message:list_item({ "fa.item-info-supply-area", diameter })
   end

   if effectivity then
      local total_effectivity = effectivity
      if effectivity_bonus and quality then total_effectivity = effectivity + (effectivity_bonus * quality.level) end
      ctx.message:list_item({ "fa.item-info-transmission-efficiency", string.format("%.0f%%", total_effectivity * 100) })
   end

   if proto.module_inventory_size then
      ctx.message:list_item({ "fa.item-info-module-slots", proto.module_inventory_size })
   end
end

---Add inserter info to message
---@param ctx fa.ItemInfo.BuildingContext
local function building_inserter_info(ctx)
   local proto = ctx.prototype

   local rotation_speed = proto.get_inserter_rotation_speed(ctx.quality)
   if rotation_speed then
      local swings_per_second = mod.inserter_swings_per_second(rotation_speed)
      local stack_size
      if ctx.force then
         stack_size = mod.inserter_stack_size_with_force(proto, ctx.force)
      else
         stack_size = mod.inserter_base_stack_size(proto)
      end
      ctx.message:list_item({
         "fa.item-info-inserter-speed",
         string.format("%.1f", swings_per_second),
         stack_size,
      })
   end

   if proto.bulk then ctx.message:list_item({ "fa.item-info-bulk-inserter" }) end
end

---Add transport belt info to message
---@param ctx fa.ItemInfo.BuildingContext
local function building_transport_belt_info(ctx)
   local proto = ctx.prototype

   if proto.belt_speed then
      local items_per_second = proto.belt_speed * 480
      ctx.message:list_item({ "fa.item-info-belt-speed", string.format("%.1f", items_per_second) })
   end
end

---Add splitter info to message
---@param ctx fa.ItemInfo.BuildingContext
local function building_splitter_info(ctx)
   local proto = ctx.prototype

   if proto.belt_speed then
      -- Splitters have two lanes, so throughput is doubled
      local items_per_second = proto.belt_speed * 480 * 2
      ctx.message:list_item({ "fa.item-info-belt-speed", string.format("%.1f", items_per_second) })
   end
end

---Add underground belt info to message
---@param ctx fa.ItemInfo.BuildingContext
local function building_underground_belt_info(ctx)
   local proto = ctx.prototype

   if proto.belt_speed then
      local items_per_second = proto.belt_speed * 480
      ctx.message:list_item({ "fa.item-info-belt-speed", string.format("%.1f", items_per_second) })
   end
   if proto.max_underground_distance then
      ctx.message:list_item({ "fa.item-info-underground-distance", proto.max_underground_distance })
   end
end

---Add pipe to ground info to message
---@param ctx fa.ItemInfo.BuildingContext
local function building_pipe_to_ground_info(ctx)
   local proto = ctx.prototype

   if proto.max_underground_distance then
      ctx.message:list_item({ "fa.item-info-underground-distance", proto.max_underground_distance })
   end
end

---Add roboport info to message
---@param ctx fa.ItemInfo.BuildingContext
local function building_roboport_info(ctx)
   local proto = ctx.prototype

   if proto.logistic_radius then
      local diameter = math.floor(proto.logistic_radius * 2)
      ctx.message:list_item({ "fa.item-info-logistics-area", diameter })
   end
   if proto.construction_radius then
      local diameter = math.floor(proto.construction_radius * 2)
      ctx.message:list_item({ "fa.item-info-construction-area", diameter })
   end
end

---Add crafting machine info to message
---@param ctx fa.ItemInfo.BuildingContext
local function building_crafting_machine_info(ctx)
   local proto = ctx.prototype
   local quality = ctx.quality

   local speed = proto.get_crafting_speed(quality)
   if speed then ctx.message:list_item({ "fa.item-info-crafting-speed", string.format("%.1f", speed) }) end

   if proto.module_inventory_size then
      ctx.message:list_item({ "fa.item-info-module-slots", proto.module_inventory_size })
   end
end

---Add lab info to message
---@param ctx fa.ItemInfo.BuildingContext
local function building_lab_info(ctx)
   local proto = ctx.prototype
   local quality = ctx.quality

   local speed = proto.get_researching_speed(quality)
   if speed then ctx.message:list_item({ "fa.item-info-research-speed", string.format("%.1f", speed) }) end

   if proto.module_inventory_size then
      ctx.message:list_item({ "fa.item-info-module-slots", proto.module_inventory_size })
   end
end

---Add mining drill info to message
---@param ctx fa.ItemInfo.BuildingContext
local function building_mining_drill_info(ctx)
   local proto = ctx.prototype
   local quality = ctx.quality

   local radius = proto.get_mining_drill_radius(quality)
   if radius then ctx.message:list_item({ "fa.item-info-mining-radius", string.format("%.1f", radius) }) end

   if proto.mining_speed then
      ctx.message:list_item({ "fa.item-info-mining-speed", string.format("%.1f", proto.mining_speed) })
   end

   if proto.module_inventory_size then
      ctx.message:list_item({ "fa.item-info-module-slots", proto.module_inventory_size })
   end
end

---Add pump info to message
---@param ctx fa.ItemInfo.BuildingContext
local function building_pump_info(ctx)
   local proto = ctx.prototype
   local quality = ctx.quality

   local speed = proto.get_pumping_speed(quality)
   if speed then
      local per_second = speed * 60
      ctx.message:list_item({ "fa.item-info-pumping-speed", string.format("%.0f", per_second) })
   end
end

---Add generator info to message
---@param ctx fa.ItemInfo.BuildingContext
local function building_generator_info(ctx)
   local proto = ctx.prototype
   local quality = ctx.quality

   -- Use get_max_energy_production for consistency with fa-info.lua
   -- This returns energy per tick, multiply by 60 to get Watts
   local max_energy = proto.get_max_energy_production(quality)
   if max_energy and max_energy > 0 then
      ctx.message:list_item({ "fa.item-info-generates", FaUtils.format_power(max_energy * 60) })
   end
end

---Add solar panel info to message
---@param ctx fa.ItemInfo.BuildingContext
local function building_solar_panel_info(ctx)
   local proto = ctx.prototype
   local quality = ctx.quality

   local max_power = proto.get_max_energy_production(quality)
   if max_power and max_power > 0 then
      ctx.message:list_item({ "fa.item-info-generates-solar", FaUtils.format_power(max_power * 60) })
   end
end

---Add accumulator info to message
---@param ctx fa.ItemInfo.BuildingContext
local function building_accumulator_info(ctx)
   local proto = ctx.prototype

   if proto.electric_energy_source_prototype then
      local buffer = proto.electric_energy_source_prototype.buffer_capacity
      if buffer and buffer > 0 then
         ctx.message:list_item({ "fa.item-info-stores", FaUtils.format_power(buffer, "j") })
      end
   end
end

---Add turret info to message
---@param ctx fa.ItemInfo.BuildingContext
local function building_turret_info(ctx)
   local proto = ctx.prototype

   if proto.turret_range then ctx.message:list_item({ "fa.item-info-turret-range", proto.turret_range }) end
end

---Add radar info to message
---@param ctx fa.ItemInfo.BuildingContext
local function building_radar_info(ctx)
   local proto = ctx.prototype
   local quality = ctx.quality

   local nearby = proto.get_max_distance_of_nearby_sector_revealed(quality)
   local scan = proto.get_max_distance_of_sector_revealed(quality)

   if nearby then ctx.message:list_item({ "fa.item-info-radar-nearby", nearby }) end
   if scan then ctx.message:list_item({ "fa.item-info-radar-scan", scan }) end
end

---Add reactor info to message
---@param ctx fa.ItemInfo.BuildingContext
local function building_reactor_info(ctx)
   local proto = ctx.prototype
   local quality = ctx.quality

   local max_power = proto.get_max_energy_production(quality)
   if max_power and max_power > 0 then
      ctx.message:list_item({ "fa.item-info-generates", FaUtils.format_power(max_power * 60) })
   end

   if proto.neighbour_bonus then
      ctx.message:list_item({ "fa.item-info-neighbor-bonus", string.format("%.0f%%", proto.neighbour_bonus * 100) })
   end
end

---Add container info to message
---@param ctx fa.ItemInfo.BuildingContext
local function building_container_info(ctx)
   local proto = ctx.prototype
   local quality = ctx.quality

   local size = proto.get_inventory_size(defines.inventory.chest, quality)
   if size then ctx.message:list_item({ "fa.item-info-inventory-size", size }) end
end

---Map of entity type to info function
local BUILDING_INFO_HANDLERS = {
   ["electric-pole"] = building_electric_pole_info,
   ["beacon"] = building_beacon_info,
   ["inserter"] = building_inserter_info,
   ["transport-belt"] = building_transport_belt_info,
   ["splitter"] = building_splitter_info,
   ["underground-belt"] = building_underground_belt_info,
   ["pipe-to-ground"] = building_pipe_to_ground_info,
   ["roboport"] = building_roboport_info,
   ["assembling-machine"] = building_crafting_machine_info,
   ["furnace"] = building_crafting_machine_info,
   ["rocket-silo"] = building_crafting_machine_info,
   ["lab"] = building_lab_info,
   ["mining-drill"] = building_mining_drill_info,
   ["pump"] = building_pump_info,
   ["offshore-pump"] = building_pump_info,
   ["generator"] = building_generator_info,
   ["burner-generator"] = building_generator_info,
   ["solar-panel"] = building_solar_panel_info,
   ["accumulator"] = building_accumulator_info,
   ["ammo-turret"] = building_turret_info,
   ["electric-turret"] = building_turret_info,
   ["fluid-turret"] = building_turret_info,
   ["artillery-turret"] = building_turret_info,
   ["radar"] = building_radar_info,
   ["reactor"] = building_reactor_info,
   ["container"] = building_container_info,
   ["logistic-container"] = building_container_info,
}

---Add fuel info to message if the item is a fuel
---@param message fa.MessageBuilder
---@param item_proto LuaItemPrototype
local function fuel_info(message, item_proto)
   local fuel_value = item_proto.fuel_value
   if not fuel_value or fuel_value <= 0 then return end

   message:list_item({ "fa.item-info-fuel-value", FaUtils.format_power(fuel_value, "j") })

   local fuel_category = item_proto.fuel_category
   if fuel_category then message:list_item({ "fa.item-info-fuel-category", fuel_category }) end
end

---@class fa.ItemInfo.GetItemStackInfoOptions
---@field verbosity integer VERBOSITY.BRIEF or VERBOSITY.VERBOSE
---@field force LuaForce? Optional force for research bonus calculations

---@class fa.ItemInfo.GetItemInfoFromPrototypeOptions
---@field verbosity integer VERBOSITY.BRIEF or VERBOSITY.VERBOSE
---@field name_override LocalisedString? Override the name announced (for cases where name is already known)
---@field force LuaForce? Optional force for research bonus calculations

---Get detailed information about an item from its prototype and quality
---This is the core function used by both stack-based and prototype-based queries
---@param message fa.MessageBuilder
---@param item_proto LuaItemPrototype
---@param quality LuaQualityPrototype?
---@param options fa.ItemInfo.GetItemInfoFromPrototypeOptions?
function mod.get_item_info_from_prototype(message, item_proto, quality, options)
   options = options or { verbosity = mod.VERBOSITY.BRIEF }
   quality = quality or prototypes.quality["normal"]

   -- Start with item name (unless overridden)
   if not options.name_override then
      message:fragment(mod.item_info({
         name = item_proto,
         count = 1,
         quality = quality and quality.name or nil,
      }))
   end

   -- Only add detailed info for VERBOSE mode
   if options.verbosity == mod.VERBOSITY.BRIEF then return end

   -- Check if this is equipment
   if item_proto.place_as_equipment_result then
      local equip_proto = item_proto.place_as_equipment_result
      local ctx = {
         message = message,
         prototype = equip_proto,
         quality = quality,
      }

      equipment_dimensions_info(ctx)
      equipment_power_consumption_info(ctx)
      equipment_battery_storage_info(ctx)
      equipment_power_generation_info(ctx)
   elseif item_proto.place_result then
      -- This is a building
      local entity_proto = item_proto.place_result
      local ctx = {
         message = message,
         prototype = entity_proto,
         quality = quality,
         force = options.force,
      }

      -- Add building intro with type-specific or generic description
      local locale_key = BUILDING_TYPE_LOCALE[entity_proto.type] or "fa.item-info-building"
      message:list_item({ locale_key, entity_proto.tile_width, entity_proto.tile_height })

      -- Call type-specific handler if available
      local handler = BUILDING_INFO_HANDLERS[entity_proto.type]
      if handler then handler(ctx) end
   end

   -- Add fuel info for any item that can be used as fuel
   fuel_info(message, item_proto)
end

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

   mod.get_item_info_from_prototype(message, stack.prototype, stack.quality, options)
end

---@alias fa.ItemInfo.Product ItemProduct | FluidProduct

---Get detailed information about a recipe product (item or fluid)
---For item products, provides full building/equipment info
---For fluid products, just announces the fluid name
---@param message fa.MessageBuilder
---@param product fa.ItemInfo.Product
---@param quality LuaQualityPrototype? Quality level (for item products)
---@param options fa.ItemInfo.GetItemInfoFromPrototypeOptions?
function mod.get_product_info(message, product, quality, options)
   options = options or { verbosity = mod.VERBOSITY.VERBOSE }
   quality = quality or prototypes.quality["normal"]

   if product.type == "item" then
      local item_proto = prototypes.item[product.name]
      if item_proto then
         mod.get_item_info_from_prototype(message, item_proto, quality, options)
      else
         -- Fallback if item not found (shouldn't happen)
         message:fragment(product.name)
      end
   elseif product.type == "fluid" then
      -- For fluids, just announce the fluid name
      local fluid_proto = prototypes.fluid[product.name]
      if fluid_proto then
         message:fragment(Localising.get_localised_name_with_fallback(fluid_proto))
      else
         message:fragment(product.name)
      end
   else
      -- Unknown product type
      message:fragment(product.name)
   end
end

---Get info for all products of a recipe
---@param message fa.MessageBuilder
---@param recipe LuaRecipe | LuaRecipePrototype
---@param quality LuaQualityPrototype?
---@param options fa.ItemInfo.GetItemInfoFromPrototypeOptions?
function mod.get_recipe_products_info(message, recipe, quality, options)
   options = options or { verbosity = mod.VERBOSITY.VERBOSE }

   local products = recipe.products
   if not products or #products == 0 then
      message:fragment({ "fa.item-info-no-products" })
      return
   end

   for _, product in ipairs(products) do
      mod.get_product_info(message, product, quality, options)
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
   mod.get_item_stack_info(message, cursor_stack, { verbosity = mod.VERBOSITY.VERBOSE, force = player.force })
   Speech.speak(pindex, message:build())
end

return mod
