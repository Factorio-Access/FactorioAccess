--Here: Functions for reading train schedules into speech messages
--Recursive descent parser in reverse: each function handles one level and pushes to the message builder

local CircuitNetwork = require("scripts.circuit-network")
local Speech = require("scripts.speech")

local mod = {}

-- Shared options for circuit condition reading
local CONDITION_READ_OPTS = { empty_message = { "fa.schedule-contents-condition-not-configured" } }

-- Simple conditions that just map to a locale key (no parameters)
local SIMPLE_CONDITIONS = {
   full = "fa.schedule-full",
   empty = "fa.schedule-empty",
   not_empty = "fa.schedule-not-empty",
   fuel_full = "fa.schedule-fuel-full",
   robots_inactive = "fa.schedule-robots-inactive",
   passenger_present = "fa.schedule-passenger-present",
   passenger_not_present = "fa.schedule-passenger-not-present",
   all_requests_satisfied = "fa.schedule-all-requests-satisfied",
   any_request_not_satisfied = "fa.schedule-any-request-not-satisfied",
   any_request_zero = "fa.schedule-any-request-zero",
   destination_full_or_no_path = "fa.schedule-destination-full-or-no-path",
}

-- Conditions with circuit condition data (uses CircuitNetwork.read_condition)
-- Value is prefix locale key to speak before the condition (false = no prefix)
local CIRCUIT_CONDITIONS = {
   item_count = false,
   fluid_count = false,
   fuel_item_count_all = "fa.schedule-fuel-all",
   fuel_item_count_any = "fa.schedule-fuel-any",
   circuit = "fa.schedule-circuit",
}

-- Conditions with a station parameter
local STATION_CONDITIONS = {
   specific_destination_full = "fa.schedule-destination-full",
   specific_destination_not_full = "fa.schedule-destination-not-full",
   at_station = "fa.schedule-at-station",
   not_at_station = "fa.schedule-not-at-station",
}

---Read a single wait condition into a message builder
---@param mb fa.MessageBuilder
---@param condition WaitCondition
function mod.read_wait_condition(mb, condition)
   local cond_type = condition.type

   -- Simple conditions (no parameters)
   local simple_key = SIMPLE_CONDITIONS[cond_type]
   if simple_key then
      mb:fragment({ simple_key })
      return
   end

   -- Circuit conditions (with optional prefix)
   local circuit_prefix = CIRCUIT_CONDITIONS[cond_type]
   if circuit_prefix ~= nil then
      if circuit_prefix then mb:fragment({ circuit_prefix }) end
      ---@diagnostic disable-next-line: param-type-mismatch
      CircuitNetwork.read_condition(mb, condition.condition, CONDITION_READ_OPTS)
      return
   end

   -- Station conditions
   local station_key = STATION_CONDITIONS[cond_type]
   if station_key then
      mb:fragment({ station_key, condition.station })
      return
   end

   -- Time-based conditions
   if cond_type == "time" then
      mb:fragment({ "fa.schedule-time", tostring((condition.ticks or 0) / 60) })
   elseif cond_type == "inactivity" then
      mb:fragment({ "fa.schedule-inactivity", tostring((condition.ticks or 0) / 60) })
   -- Request conditions with item parameter
   elseif cond_type == "request_satisfied" then
      mb:fragment({ "fa.schedule-request-satisfied", condition.condition.name })
   elseif cond_type == "request_not_satisfied" then
      mb:fragment({ "fa.schedule-request-not-satisfied", condition.condition.name })
   -- Planet condition (optional planet parameter)
   elseif cond_type == "any_planet_import_zero" then
      if condition.planet then
         mb:fragment({ "fa.schedule-planet-import-zero", condition.planet })
      else
         mb:fragment({ "fa.schedule-any-planet-import-zero" })
      end
   -- Damage condition
   elseif cond_type == "damage_taken" then
      mb:fragment({ "fa.schedule-damage-taken", tostring(condition.damage or 1000) })
   -- Unknown
   else
      mb:fragment({ "fa.schedule-unknown-condition", tostring(cond_type) })
   end
end

---Read multiple wait conditions with and/or connectors
---@param mb fa.MessageBuilder
---@param wait_conditions WaitCondition[]
function mod.read_wait_conditions(mb, wait_conditions)
   if not wait_conditions or #wait_conditions == 0 then return end

   for i, condition in ipairs(wait_conditions) do
      -- Add connector for conditions after the first
      if i > 1 then
         local connector = condition.compare_type or "and"
         mb:fragment({ "fa.schedule-connector-" .. connector })
      end

      mod.read_wait_condition(mb, condition)
   end
end

---Read a schedule record (destination + wait conditions)
---Starting point for reading schedule entries
---@param mb fa.MessageBuilder
---@param record ScheduleRecord
function mod.read_schedule_record(mb, record)
   -- Destination
   if record.station then
      mb:fragment({ "fa.schedule-station", record.station })
   elseif record.rail then
      mb:fragment({ "fa.schedule-rail-position" })
   else
      mb:fragment({ "fa.schedule-no-destination" })
   end

   -- Wait conditions
   if record.wait_conditions and #record.wait_conditions > 0 then
      mb:fragment({ "fa.schedule-waiting-for" })
      mod.read_wait_conditions(mb, record.wait_conditions)
   end
end

return mod
