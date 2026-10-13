--[[
Coupling and uncoupling train cars (Ctrl+G and Shift+G), standing in for the game's connect-train and
disconnect-train controls, which the mod's config changes unbind.

The car is the one the player rides, else the selected one (the cursor's). Both ends are tried.
]]
local Speech = require("scripts.speech")

local mod = {}

local ENDS = { defines.rail_direction.front, defines.rail_direction.back }

---@param player LuaPlayer
---@return LuaEntity?
local function target_car(player)
   local vehicle = player.vehicle
   if vehicle and vehicle.train then return vehicle end
   local selected = player.selected
   if selected and selected.valid and selected.train then return selected end
   return nil
end

---@param car LuaEntity
---@return boolean
local function has_neighbour(car)
   for _, side in ipairs(ENDS) do
      if car.get_connected_rolling_stock(side) then return true end
   end
   return false
end

---@param pindex integer
function mod.couple(pindex)
   local car = target_car(assert(game.get_player(pindex)))
   if not car then
      Speech.speak(pindex, { "fa.coupling-no-car" })
      return
   end
   local coupled = false
   for _, side in ipairs(ENDS) do
      if car.connect_rolling_stock(side) then coupled = true end
   end
   local cars = #assert(car.train).carriages
   if coupled then
      Speech.speak(pindex, { "fa.coupling-coupled", cars })
   elseif has_neighbour(car) then
      Speech.speak(pindex, { "fa.coupling-already-coupled", cars })
   else
      Speech.speak(pindex, { "fa.coupling-nothing-to-couple" })
   end
end

---@param pindex integer
function mod.uncouple(pindex)
   local car = target_car(assert(game.get_player(pindex)))
   if not car then
      Speech.speak(pindex, { "fa.coupling-no-car" })
      return
   end
   local uncoupled = false
   for _, side in ipairs(ENDS) do
      if car.disconnect_rolling_stock(side) then uncoupled = true end
   end
   if uncoupled then
      Speech.speak(pindex, { "fa.coupling-uncoupled", #assert(car.train).carriages })
   elseif has_neighbour(car) then
      Speech.speak(pindex, { "fa.coupling-cannot-uncouple" })
   else
      Speech.speak(pindex, { "fa.coupling-not-coupled" })
   end
end

return mod
