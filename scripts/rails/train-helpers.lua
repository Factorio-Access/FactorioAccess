--[[
Helper functions for managing trains and rolling stock.
Provides utilities for naming trains, identifying locomotives, and describing train state.
]]

local mod = {}

---Get the identifying locomotive for a train (the one with the lowest unit_number).
---This provides a stable reference point for train-level operations.
---@param rolling_stock LuaEntity A rolling stock entity (locomotive, wagon, etc)
---@return LuaEntity? The locomotive with the lowest unit_number, or nil if no locomotives
function mod.get_identifying_locomotive(rolling_stock)
   local train = rolling_stock.train
   if not train then return nil end

   local locomotives = train.locomotives

   -- No locomotive can be both a front and back mover, so check each list separately
   local identifying_loco = nil

   -- Check front movers
   if locomotives.front_movers then
      for _, loco in ipairs(locomotives.front_movers) do
         if not identifying_loco or loco.unit_number < identifying_loco.unit_number then identifying_loco = loco end
      end
   end

   -- Check back movers
   if locomotives.back_movers then
      for _, loco in ipairs(locomotives.back_movers) do
         if not identifying_loco or loco.unit_number < identifying_loco.unit_number then identifying_loco = loco end
      end
   end

   return identifying_loco
end

---Set the name of all locomotives in a train.
---@param rolling_stock LuaEntity A rolling stock entity (locomotive, wagon, etc)
---@param name string The name to set
function mod.set_name(rolling_stock, name)
   local train = rolling_stock.train
   if not train then return end

   local locomotives = train.locomotives

   -- Set name on all front movers
   if locomotives.front_movers then
      for _, loco in ipairs(locomotives.front_movers) do
         loco.backer_name = name
      end
   end

   -- Set name on all back movers
   if locomotives.back_movers then
      for _, loco in ipairs(locomotives.back_movers) do
         loco.backer_name = name
      end
   end
end

---Get the name of a train.
---@param rolling_stock LuaEntity A rolling stock entity (locomotive, wagon, etc)
---@return string The train name (backer_name of identifying locomotive), or fallback
function mod.get_name(rolling_stock)
   local identifying_loco = mod.get_identifying_locomotive(rolling_stock)
   if identifying_loco then return identifying_loco.backer_name end

   -- No locomotive: fallback based on whether we have a train
   local train = rolling_stock.train
   if train then
      return "id " .. train.id
   else
      return "unnamed train"
   end
end

---Add train state information to a message builder.
---@param msgbuilder fa.MessageBuilder The message builder to add fragments to
---@param rolling_stock LuaEntity A rolling stock entity (locomotive, wagon, etc)
---@return boolean True if state was added, false if no state to report
function mod.push_state_message(msgbuilder, rolling_stock)
   local train = rolling_stock.train
   if not train then return false end

   -- Check if in manual mode
   if train.manual_mode then
      msgbuilder:fragment({ "fa.train-state-manual" })
      return true
   end

   -- Check if headed to a station
   local path_end_stop = train.path_end_stop
   if path_end_stop then
      local station_name = path_end_stop.backer_name
      if station_name and station_name ~= "" then
         msgbuilder:fragment({ "fa.train-state-headed-to", station_name })
         return true
      end
   end

   -- No verbalizable state
   return false
end

---Get the combined fuel contents from all locomotives in a train.
---@param rolling_stock LuaEntity A rolling stock entity (locomotive, wagon, etc)
---@return ({ name: string, quality: string, count: number})[] Array of fuel items
function mod.get_fuel(rolling_stock)
   local train = rolling_stock.train
   if not train then return {} end

   local locomotives = train.locomotives
   local all_fuel = {}

   -- Collect fuel from all front movers
   if locomotives.front_movers then
      for _, loco in ipairs(locomotives.front_movers) do
         local fuel_inv = loco.get_fuel_inventory()
         if fuel_inv then
            local contents = fuel_inv.get_contents()
            for _, item in ipairs(contents) do
               table.insert(all_fuel, item)
            end
         end
      end
   end

   -- Collect fuel from all back movers
   if locomotives.back_movers then
      for _, loco in ipairs(locomotives.back_movers) do
         local fuel_inv = loco.get_fuel_inventory()
         if fuel_inv then
            local contents = fuel_inv.get_contents()
            for _, item in ipairs(contents) do
               table.insert(all_fuel, item)
            end
         end
      end
   end

   return all_fuel
end

return mod
