--Here: Electricity related functions and menus
local util = require("util")
local fa_utils = require("scripts.fa-utils")

local mod = {}

--Formats a power value in watts to summarize it as a string according to its magnitude.
---@param power float
function mod.get_power_string(power)
   result = ""
   if power > 1000000000000 then
      power = power / 1000000000000
      result = result .. string.format(" %.1f Terawatts", power)
   elseif power > 1000000000 then
      power = power / 1000000000
      result = result .. string.format(" %.1f Gigawatts", power)
   elseif power > 1000000 then
      power = power / 1000000
      result = result .. string.format(" %.1f Megawatts", power)
   elseif power > 1000 then
      power = power / 1000
      result = result .. string.format(" %.1f Kilowatts", power)
   else
      result = result .. string.format(" %.1f Watts", power)
   end
   return result
end

--Spawns a lamp at the electric pole and uses its energy level to approximate the network satisfaction percentage with high accuracy
function mod.get_electricity_satisfaction(electric_pole)
   local satisfaction = -1
   local test_lamp = electric_pole.surface.create_entity({
      name = "small-lamp",
      position = electric_pole.position,
      raise_built = false,
      force = electric_pole.force,
   })
   satisfaction = math.ceil(test_lamp.energy * 9 / 8) --Experimentally found coefficient
   test_lamp.destroy({})
   return satisfaction
end

--For an electricity producer, returns an info string on the current and maximum production.
---@param ent LuaEntity
function mod.get_electricity_flow_info(ent)
   local result = ""
   local power = 0
   local capacity = 0
   for i, v in pairs(ent.electric_network_statistics.output_counts) do
      power = power
         + (
            ent.electric_network_statistics.get_flow_count({
               name = i,
               input = false,
               precision_index = defines.flow_precision_index.five_seconds,
               category = "input",
            })
         )
      local cap_add = 0
      for _, power_ent in pairs(ent.surface.find_entities_filtered({ name = i, force = ent.force })) do
         if power_ent.electric_network_id == ent.electric_network_id then cap_add = cap_add + 1 end
      end
      cap_add = cap_add * prototypes.entity[i].max_energy_production
      if prototypes.entity[i].type == "solar-panel" then
         cap_add = cap_add * ent.surface.solar_power_multiplier * (1 - ent.surface.darkness)
      end
      capacity = capacity + cap_add
   end
   power = power * 60
   capacity = capacity * 60
   result = result
      .. mod.get_power_string(power)
      .. " being produced out of "
      .. mod.get_power_string(capacity)
      .. " capacity, "
   return result
end

--Finds the neearest electric pole. Can be set to determine whether to check only for poles with electricity flow. Can call using only the first two parameters.
function mod.find_nearest_electric_pole(ent, require_supplied, radius, alt_surface, alt_pos)
   ---@type LuaEntity
   local nearest = nil
   local min_dist = 99999
   require_supplied = require_supplied or false
   radius = radius or 10
   ---@type LuaSurface
   local surface = nil
   local pos = nil
   if ent ~= nil and ent.valid then
      surface = ent.surface
      pos = ent.position
   else
      surface = alt_surface
      pos = alt_pos
   end

   --Scan nearby for electric poles, expand radius if not successful
   local poles = surface.find_entities_filtered({ type = "electric-pole", position = pos, radius = radius })
   if #poles == 0 then
      if radius < 100 then
         radius = 100
         return mod.find_nearest_electric_pole(ent, require_supplied, radius, alt_surface, alt_pos)
      elseif radius < 1000 then
         radius = 1000
         return mod.find_nearest_electric_pole(ent, require_supplied, radius, alt_surface, alt_pos)
      elseif radius < 10000 then
         radius = 10000
         return mod.find_nearest_electric_pole(ent, require_supplied, radius, alt_surface, alt_pos)
      else
         return nil, nil --Nothing within 10000 tiles!
      end
   end

   --Find the nearest among the poles with electric networks
   for i, pole in ipairs(poles) do
      --Check if the pole's network has power producers
      local has_power = mod.get_electricity_satisfaction(pole) > 0
      local dict = pole.electric_network_statistics.output_counts
      local network_producers = {}
      for name, count in pairs(dict) do
         table.insert(network_producers, { name = name, count = count })
      end
      local network_producer_count = #network_producers --laterdo test again if this is working, it should pick up even 0.001% satisfaction...
      local dist = 0
      if has_power or network_producer_count > 0 or not require_supplied then
         dist = math.ceil(util.distance(pos, pole.position))
         --Set as nearest if valid
         if dist < min_dist then
            min_dist = dist
            nearest = pole
         end
      end
   end
   --Return the nearst found, possibly nil
   if nearest == nil then
      if radius < 100 then
         radius = 100
         return mod.find_nearest_electric_pole(ent, require_supplied, radius, alt_surface, alt_pos)
      elseif radius < 1000 then
         radius = 1000
         return mod.find_nearest_electric_pole(ent, require_supplied, radius, alt_surface, alt_pos)
      elseif radius < 10000 then
         radius = 10000
         return mod.find_nearest_electric_pole(ent, require_supplied, radius, alt_surface, alt_pos)
      else
         return nil, nil --Nothing within 10000 tiles!
      end
   end
   --Draw a circle around the nearest electric pole
   rendering.draw_circle({
      color = { 1, 1, 0 },
      radius = 2,
      width = 2,
      target = nearest.position,
      surface = nearest.surface,
      time_to_live = 60,
   })
   return nearest, min_dist
end

--Returns an info string on the nearest supplied electric pole for this entity.
function mod.report_nearest_supplied_electric_pole(ent)
   local result = ""
   local pole, dist = mod.find_nearest_electric_pole(ent, true)
   local dir
   if pole ~= nil then
      dir = fa_utils.get_direction_biased(pole.position, ent.position)
      result = "The nearest powered electric pole is " .. dist .. " tiles to the " .. fa_utils.direction_lookup(dir)
   else
      result = "And there are no powered electric poles within ten thousand tiles. Generators may be out of energy."
   end
   return result
end

return mod
