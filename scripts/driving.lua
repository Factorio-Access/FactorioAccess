--Here: Functions about driving, mainly cars.

local FaUtils = require("scripts.fa-utils")
local Speech = require("scripts.speech")
local MessageBuilder = Speech.MessageBuilder
local dirs = defines.direction

local mod = {}

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

return mod
