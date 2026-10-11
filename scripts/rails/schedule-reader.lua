--Here: Functions for reading train and space platform schedules into speech messages
--Recursive descent parser in reverse: each function handles one level and pushes to the message builder

local CircuitNetwork = require("scripts.circuit-network")
local Localising = require("scripts.localising")

local mod = {}

-- Shared options for circuit condition reading
local CONDITION_READ_OPTS = { empty_message = { "fa.schedule-contents-condition-not-configured" } }

-- Simple conditions that just map to a locale key (no parameters)
---@type table<string, string?>
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
---@type table<string, string|false|nil>
local CIRCUIT_CONDITIONS = {
   item_count = false,
   fluid_count = false,
   fuel_item_count_all = "fa.schedule-fuel-all",
   fuel_item_count_any = "fa.schedule-fuel-any",
   circuit = "fa.schedule-circuit",
}

-- Conditions with a station parameter
---@type table<string, string?>
local STATION_CONDITIONS = {
   specific_destination_full = "fa.schedule-destination-full",
   specific_destination_not_full = "fa.schedule-destination-not-full",
   at_station = "fa.schedule-at-station",
   not_at_station = "fa.schedule-not-at-station",
}

---Name a schedule's station: a platform's stations are space locations, a train's are stop names
---@param station string
---@param platform boolean
---@return LocalisedString
function mod.localise_station(station, platform)
   if platform then return Localising.get_localised_name_with_fallback(prototypes.space_location[station]) end
   return station
end

---Read a single wait condition into a message builder
---@param mb fa.MessageBuilder
---@param condition WaitCondition
---@param platform boolean? The condition belongs to a space platform's schedule
function mod.read_wait_condition(mb, condition, platform)
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
      -- These condition types carry a CircuitCondition (an item pair only belongs to the request conditions)
      CircuitNetwork.read_condition(mb, condition.condition --[[@as CircuitCondition]], CONDITION_READ_OPTS)
      return
   end

   -- Station conditions
   local station_key = STATION_CONDITIONS[cond_type]
   if station_key then
      local station_name = condition.station
      if station_name and station_name ~= "" then
         mb:fragment({ station_key, mod.localise_station(station_name, platform or false) })
      else
         mb:fragment({ station_key, { "fa.schedule-station-not-set" } })
      end
      return
   end

   -- Time-based conditions
   if cond_type == "time" then
      mb:fragment({ "fa.schedule-time", tostring((condition.ticks or 0) / 60) })
   elseif cond_type == "inactivity" then
      mb:fragment({ "fa.schedule-inactivity", tostring((condition.ticks or 0) / 60) })
   -- Request conditions name an item pair once one is chosen
   elseif cond_type == "request_satisfied" or cond_type == "request_not_satisfied" then
      local satisfied = cond_type == "request_satisfied"
      local item = condition.condition --[[@as BlueprintItemIDAndQualityIDPair?]]
      if item then
         local key = satisfied and "fa.schedule-request-satisfied" or "fa.schedule-request-not-satisfied"
         mb:fragment({ key, Localising.get_localised_name_with_fallback(prototypes.item[item.name]) })
      else
         mb:fragment({
            satisfied and "fa.schedule-request-satisfied-no-item" or "fa.schedule-request-not-satisfied-no-item",
         })
      end
   -- Planet condition (optional planet parameter)
   elseif cond_type == "any_planet_import_zero" then
      if condition.planet then
         mb:fragment({ "fa.schedule-planet-import-zero", mod.localise_station(condition.planet, true) })
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

return mod
