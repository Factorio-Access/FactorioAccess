--[[
Item Descriptions Module
Provides detailed information about items, especially equipment and buildings.
]]

local Localising = require("scripts.localising")
local FaUtils = require("scripts.fa-utils")
local Speech = require("scripts.speech")
local MessageBuilder = Speech.MessageBuilder

local mod = {}

---Push detailed information about an item to a message builder
---Includes equipment specs, building dimensions, etc.
---@param message fa.MessageBuilder
---@param stack LuaItemStack
function mod.push_equipment_info(message, stack)
   if not stack or not stack.valid_for_read then
      message:fragment({ "fa.item-info-no-item" })
      return
   end

   local proto = stack.prototype
   local quality = stack.quality

   -- Start with item name and quality
   message:fragment(Localising.localise_item({
      name = stack.name,
      count = 1,
      quality = quality and quality.name or nil,
   }))

   -- Check if this is equipment
   if proto.place_as_equipment_result then
      local equip_proto = proto.place_as_equipment_result

      -- Equipment dimensions
      local shape = equip_proto.shape
      message:fragment({ "fa.item-info-dimensions", shape.width, shape.height })

      -- Power consumption (get_energy_consumption is a method that takes quality)
      local consumption = equip_proto.get_energy_consumption(quality)
      if consumption and consumption > 0 then
         message:fragment({ "fa.item-info-consumes", FaUtils.format_power(consumption) })
      end

      -- Battery storage (energy_source.buffer_capacity for battery equipment)
      if equip_proto.electric_energy_source_prototype then
         local buffer = equip_proto.electric_energy_source_prototype.buffer_capacity
         if buffer and buffer > 0 then message:fragment({ "fa.item-info-stores", FaUtils.format_power(buffer) }) end
      end

      -- Power generation
      if equip_proto.energy_production and equip_proto.energy_production > 0 then
         -- Special case for solar panels - check if it has solar panel properties
         if equip_proto.solar_panel_performance_at_day then
            message:fragment({
               "fa.item-info-generates-solar",
               FaUtils.format_power(equip_proto.energy_production),
            })
         else
            message:fragment({ "fa.item-info-generates", FaUtils.format_power(equip_proto.energy_production) })
         end
      end
   elseif proto.place_result then
      -- This is a building
      local entity_proto = proto.place_result
      message:fragment({
         "fa.item-info-building",
         entity_proto.tile_width,
         entity_proto.tile_height,
      })
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
   mod.push_equipment_info(message, cursor_stack)
   Speech.speak(pindex, message:build())
end

return mod
