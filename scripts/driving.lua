--Here: Functions about driving, mainly cars.

local util = require("util")
local FaUtils = require("scripts.fa-utils")
local Speech = require("scripts.speech")
local MessageBuilder = Speech.MessageBuilder
local VanillaMode = require("scripts.vanilla-mode")
local dirs = defines.direction

local mod = {}

--Report more info about a vehicle.
function mod.vehicle_info(pindex)
   if not game.get_player(pindex).driving then return { "fa.driving-not-in-vehicle" } end

   local vehicle = game.get_player(pindex).vehicle
   return { "fa.driving-car", { "entity-name." .. vehicle.name }, mod.fuel_inventory_info(vehicle) }
end

--Return fuel content in a fuel inventory
function mod.fuel_inventory_info(ent)
   local itemtable = ent.get_fuel_inventory().get_contents()
   table.sort(itemtable, function(k1, k2)
      return k1.count > k2.count
   end)
   if #itemtable == 0 then return { "fa.driving-no-fuel" } end

   local fuel_items = {}
   for i = 1, math.min(3, #itemtable) do
      table.insert(
         fuel_items,
         { "fa.driving-fuel-item", { "item-name." .. itemtable[i].name }, tostring(itemtable[i].count) }
      )
   end

   return { "fa.driving-contains-fuel", FaUtils.build_list(fuel_items) }
end

function mod.stop_vehicle(pindex)
   local vehicle = game.get_player(pindex).vehicle
   if vehicle and vehicle.valid then vehicle.speed = 0 end
end

function mod.halve_vehicle_speed(pindex)
   local vehicle = game.get_player(pindex).vehicle
   if vehicle and vehicle.valid then vehicle.speed = vehicle.speed / 2 end
end

return mod
