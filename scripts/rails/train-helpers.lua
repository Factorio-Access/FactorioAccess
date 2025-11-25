--[[
Helper functions for managing trains and rolling stock.
Provides utilities for naming trains, identifying locomotives, and describing train state.
]]

local mod = {}

---Iterate over all locomotives in a train
---@param train LuaTrain
---@param callback fun(loco: LuaEntity)
local function for_each_locomotive(train, callback)
   local locos = train.locomotives
   for _, loco in ipairs(locos.front_movers or {}) do
      callback(loco)
   end
   for _, loco in ipairs(locos.back_movers or {}) do
      callback(loco)
   end
end

---Get the identifying locomotive for a train (the one with the lowest unit_number).
---This provides a stable reference point for train-level operations.
---@param rolling_stock LuaEntity A rolling stock entity (locomotive, wagon, etc)
---@return LuaEntity? The locomotive with the lowest unit_number, or nil if no locomotives
function mod.get_identifying_locomotive(rolling_stock)
   local train = rolling_stock.train
   if not train then return nil end

   local identifying_loco = nil
   for_each_locomotive(train, function(loco)
      if not identifying_loco or loco.unit_number < identifying_loco.unit_number then identifying_loco = loco end
   end)

   return identifying_loco
end

---Set the name of all locomotives in a train.
---@param rolling_stock LuaEntity A rolling stock entity (locomotive, wagon, etc)
---@param name string The name to set
function mod.set_name(rolling_stock, name)
   local train = rolling_stock.train
   if not train then return end

   for_each_locomotive(train, function(loco)
      loco.backer_name = name
   end)
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

   local all_fuel = {}
   for_each_locomotive(train, function(loco)
      local fuel_inv = loco.get_fuel_inventory()
      if fuel_inv then
         for _, item in ipairs(fuel_inv.get_contents()) do
            table.insert(all_fuel, item)
         end
      end
   end)

   return all_fuel
end

---Collect unique non-empty string values from trains, sorted
---@param force ForceID
---@param extractor fun(train: LuaTrain): string[]|string|nil Returns value(s) to collect
---@return string[]
local function collect_unique_from_trains(force, extractor)
   local seen, result = {}, {}
   for _, train in ipairs(game.train_manager.get_trains({ force = force })) do
      local values = extractor(train)
      if type(values) == "string" then values = { values } end
      for _, value in ipairs(values or {}) do
         if value ~= "" and not seen[value] then
            seen[value] = true
            table.insert(result, value)
         end
      end
   end
   table.sort(result)
   return result
end

---Get all unique train groups for a force.
---@param force ForceID The force to get groups for
---@return string[] Sorted array of group names (excluding empty groups)
function mod.get_train_groups(force)
   return collect_unique_from_trains(force, function(train)
      return train.group
   end)
end

---Get all unique train interrupt names for a force.
---@param force ForceID The force to get interrupts for
---@return string[] Sorted array of interrupt names (excluding empty names)
function mod.get_train_interrupts(force)
   return collect_unique_from_trains(force, function(train)
      local schedule = train.get_schedule()
      if not schedule then return {} end
      local names = {}
      for _, interrupt in ipairs(schedule.get_interrupts()) do
         table.insert(names, interrupt.name)
      end
      return names
   end)
end

---Check if an interrupt name is unique within a schedule
---@param schedule LuaSchedule
---@param name string
---@param exclude_index number? Optional index to exclude (for renames)
---@return boolean
function mod.is_interrupt_name_unique(schedule, name, exclude_index)
   local interrupts = schedule.get_interrupts()
   for i, interrupt in ipairs(interrupts) do
      if i ~= exclude_index and interrupt.name == name then return false end
   end
   return true
end

return mod
