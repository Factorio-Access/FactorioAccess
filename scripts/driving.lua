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

---The remote interface of the Pavement Driving Assist mod, as this file uses it
---@class fa.Driving.PdaInterface
---@field get_state_of_cruise_control fun(pindex: integer): boolean
---@field set_state_of_cruise_control fun(pindex: integer, new_state: boolean)
---@field get_cruise_control_limit fun(pindex: integer): number
---@field set_cruise_control_limit fun(pindex: integer, new_value: number)
---@field get_state_of_driving_assistant fun(pindex: integer): boolean
---@field set_state_of_driving_assistant fun(pindex: integer, new_state: boolean)

---@class (partial) LuaRemote.InterfaceMap
---@field PDA fa.Driving.PdaInterface

---Whether the Pavement Driving Assist mod is present and has this remote function
---@param fname string
---@return boolean
local function pda_has(fname)
   ---@type table<string, true?>?
   local pda = remote.interfaces["PDA"]
   return pda ~= nil and pda[fname] ~= nil
end

--Pavement Driving Assist: Read CC state
---@param pindex integer
function mod.pda_get_state_of_cruise_control(pindex)
   if pda_has("get_state_of_cruise_control") then
      return remote.call("PDA", "get_state_of_cruise_control", pindex)
   else
      return nil
   end
end

--Pavement Driving Assist: Set CC state
---@param pindex integer
---@param new_state boolean
function mod.pda_set_state_of_cruise_control(pindex, new_state)
   if pda_has("set_state_of_cruise_control") then
      remote.call("PDA", "set_state_of_cruise_control", pindex, new_state)
      return 1
   else
      return nil
   end
end

--Pavement Driving Assist: Read CC speed limit in kmh
---@param pindex integer
function mod.pda_get_cruise_control_limit(pindex)
   if pda_has("get_cruise_control_limit") then
      return remote.call("PDA", "get_cruise_control_limit", pindex)
   else
      return nil
   end
end

--Pavement Driving Assist: Set CC speed limit in kmh
---@param pindex integer
---@param new_value number
function mod.pda_set_cruise_control_limit(pindex, new_value)
   if pda_has("set_cruise_control_limit") then
      remote.call("PDA", "set_cruise_control_limit", pindex, new_value)
      return 1
   else
      return nil
   end
end

--Pavement Driving Assist: Read assistant state
---@param pindex integer
function mod.pda_get_state_of_driving_assistant(pindex)
   if pda_has("get_state_of_driving_assistant") then
      return remote.call("PDA", "get_state_of_driving_assistant", pindex)
   else
      return nil
   end
end

--Pavement Driving Assist: Set assistant state
---@param pindex integer
---@param new_state boolean
function mod.pda_set_state_of_driving_assistant(pindex, new_state)
   if pda_has("set_state_of_driving_assistant") then
      remote.call("PDA", "set_state_of_driving_assistant", pindex, new_state)
      return 1
   else
      return nil
   end
end

--Pavement Driving Assist: Read assistant state after it has been toggled
function mod.pda_read_assistant_toggled_info(pindex)
   if game.get_player(pindex).driving then
      -- The state is read before the toggle reaches PDA, so the new state is its opposite
      local was_on = mod.pda_get_state_of_driving_assistant(pindex)
      if was_on == nil then
         Speech.speak(pindex, { "fa.driving-pda-missing" })
      elseif not was_on then
         Speech.speak(pindex, { "fa.driving-pda-enabled" })
      else
         Speech.speak(pindex, { "fa.driving-pda-disabled" })
      end
   end
end

--Pavement Driving Assist: Read CC state after it has been toggled
function mod.pda_read_cruise_control_toggled_info(pindex)
   if game.get_player(pindex).driving then
      -- The state is read before the toggle reaches PDA, so the new state is its opposite
      local was_on = mod.pda_get_state_of_cruise_control(pindex)
      if was_on == nil then
         Speech.speak(pindex, { "fa.driving-cruise-missing" })
      elseif not was_on then
         Speech.speak(pindex, { "fa.driving-cruise-enabled" })
      else
         Speech.speak(pindex, { "fa.driving-cruise-disabled" })
      end
      mod.pda_set_cruise_control_limit(pindex, 0.16)
   end
end

return mod
