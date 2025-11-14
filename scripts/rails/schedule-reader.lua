--Here: Functions for reading train schedules into speech messages
--Recursive descent parser in reverse: each function handles one level and pushes to the message builder

local CircuitNetwork = require("scripts.circuit-network")
local Speech = require("scripts.speech")

local mod = {}

---Convert ticks to seconds for time display
---@param ticks number
---@return number
local function ticks_to_seconds(ticks)
   return ticks / 60
end

---Read a single wait condition into a message builder
---@param mb fa.MessageBuilder
---@param condition WaitCondition
function mod.read_wait_condition(mb, condition)
   local cond_type = condition.type

   -- Time-based conditions
   if cond_type == "time" then
      local seconds = ticks_to_seconds(condition.ticks or 0)
      mb:fragment({ "fa.schedule-time", tostring(seconds) })
   elseif cond_type == "inactivity" then
      local seconds = ticks_to_seconds(condition.ticks or 0)
      mb:fragment({ "fa.schedule-inactivity", tostring(seconds) })
   -- Cargo/inventory conditions
   elseif cond_type == "full" then
      mb:fragment({ "fa.schedule-full" })
   elseif cond_type == "empty" then
      mb:fragment({ "fa.schedule-empty" })
   elseif cond_type == "not_empty" then
      mb:fragment({ "fa.schedule-not-empty" })
   -- Item count (cargo) - don't say "cargo", it's obvious from item
   elseif cond_type == "item_count" then
      ---@diagnostic disable-next-line: param-type-mismatch
      CircuitNetwork.read_condition(mb, condition.condition, { empty_message = { "fa.schedule-no-condition" } })
   -- Fluid count - don't say "fluid", it's obvious from fluid name
   elseif cond_type == "fluid_count" then
      ---@diagnostic disable-next-line: param-type-mismatch
      CircuitNetwork.read_condition(mb, condition.condition, { empty_message = { "fa.schedule-no-condition" } })
   -- Fuel conditions - DO say "fuel" to disambiguate from cargo
   elseif cond_type == "fuel_item_count_all" then
      mb:fragment({ "fa.schedule-fuel-all" })
      ---@diagnostic disable-next-line: param-type-mismatch
      CircuitNetwork.read_condition(mb, condition.condition, { empty_message = { "fa.schedule-no-condition" } })
   elseif cond_type == "fuel_item_count_any" then
      mb:fragment({ "fa.schedule-fuel-any" })
      ---@diagnostic disable-next-line: param-type-mismatch
      CircuitNetwork.read_condition(mb, condition.condition, { empty_message = { "fa.schedule-no-condition" } })
   elseif cond_type == "fuel_full" then
      mb:fragment({ "fa.schedule-fuel-full" })
   -- Circuit condition - DO say "circuit" to disambiguate
   elseif cond_type == "circuit" then
      mb:fragment({ "fa.schedule-circuit" })
      ---@diagnostic disable-next-line: param-type-mismatch
      CircuitNetwork.read_condition(mb, condition.condition, { empty_message = { "fa.schedule-no-condition" } })
   -- Robot conditions
   elseif cond_type == "robots_inactive" then
      mb:fragment({ "fa.schedule-robots-inactive" })
   -- Passenger conditions
   elseif cond_type == "passenger_present" then
      mb:fragment({ "fa.schedule-passenger-present" })
   elseif cond_type == "passenger_not_present" then
      mb:fragment({ "fa.schedule-passenger-not-present" })
   -- Request conditions (space platforms)
   elseif cond_type == "request_satisfied" then
      -- condition.condition is BlueprintItemIDAndQualityIDPair, always present
      mb:fragment({ "fa.schedule-request-satisfied", condition.condition.name })
   elseif cond_type == "request_not_satisfied" then
      mb:fragment({ "fa.schedule-request-not-satisfied", condition.condition.name })
   elseif cond_type == "all_requests_satisfied" then
      mb:fragment({ "fa.schedule-all-requests-satisfied" })
   elseif cond_type == "any_request_not_satisfied" then
      mb:fragment({ "fa.schedule-any-request-not-satisfied" })
   elseif cond_type == "any_request_zero" then
      mb:fragment({ "fa.schedule-any-request-zero" })
   -- Planet conditions (space platforms) - planet field is optional
   elseif cond_type == "any_planet_import_zero" then
      if condition.planet then
         mb:fragment({ "fa.schedule-planet-import-zero", condition.planet })
      else
         mb:fragment({ "fa.schedule-any-planet-import-zero" })
      end
   -- Destination conditions
   elseif cond_type == "destination_full_or_no_path" then
      mb:fragment({ "fa.schedule-destination-full-or-no-path" })
   elseif cond_type == "specific_destination_full" then
      -- Station is always present for specific destination conditions
      mb:fragment({ "fa.schedule-destination-full", condition.station })
   elseif cond_type == "specific_destination_not_full" then
      mb:fragment({ "fa.schedule-destination-not-full", condition.station })
   -- Station conditions - station is always present
   elseif cond_type == "at_station" then
      mb:fragment({ "fa.schedule-at-station", condition.station })
   elseif cond_type == "not_at_station" then
      mb:fragment({ "fa.schedule-not-at-station", condition.station })
   -- Damage condition
   elseif cond_type == "damage_taken" then
      mb:fragment({ "fa.schedule-damage-taken", tostring(condition.damage or 1000) })
   -- Unknown condition type
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
