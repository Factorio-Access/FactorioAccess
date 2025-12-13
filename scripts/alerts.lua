--[[
Alerts system for reading and managing Factorio alerts.

Provides utilities to:
- Verbalize alerts using built-in locale strings
- Get alert targets (entity or position)
- Build stable keys for deduplication and sorting
]]

local FaUtils = require("scripts.fa-utils")
local Localising = require("scripts.localising")

local mod = {}

-- Map from defines.alert_type to gui-alert-tooltip locale key
-- The locale keys take a count parameter for pluralization
local ALERT_TYPE_TO_LOCALE = {
   [defines.alert_type.entity_destroyed] = "destroyed",
   [defines.alert_type.entity_under_attack] = "attack",
   [defines.alert_type.turret_fire] = "turret-fire",
   [defines.alert_type.turret_out_of_ammo] = "turret-out-of-ammo",
   [defines.alert_type.train_no_path] = "train-no-path",
   [defines.alert_type.train_out_of_fuel] = "train-out-of-fuel",
   [defines.alert_type.no_material_for_construction] = "no-material-for-construction",
   [defines.alert_type.not_enough_construction_robots] = "not-enough-construction-robots",
   [defines.alert_type.not_enough_repair_packs] = "not-enough-repair-packs",
   [defines.alert_type.no_storage] = "no-storage",
   [defines.alert_type.no_platform_storage] = "no-platform-storage",
   [defines.alert_type.no_roboport_storage] = "no-roboport-storage",
   [defines.alert_type.collector_path_blocked] = "collector-path-blocked",
   [defines.alert_type.platform_tile_building_blocked] = "platform-tile-building-blocked",
   [defines.alert_type.pipeline_overextended] = "pipeline-overextended",
   [defines.alert_type.unclaimed_cargo] = "unclaimed-cargo",
   [defines.alert_type.custom] = "custom-alert",
}

-- Cache for alert type name lookup
local alert_type_lookup = nil

---Get the string name of an alert type from defines
---@param alert_type defines.alert_type
---@return string
function mod.get_alert_type_name(alert_type)
   if alert_type_lookup == nil then alert_type_lookup = FaUtils.into_lookup(defines.alert_type) end
   return alert_type_lookup[alert_type] or "unknown"
end

---Get the locale key for an alert type
---@param alert_type defines.alert_type
---@return string
function mod.get_alert_locale_key(alert_type)
   return ALERT_TYPE_TO_LOCALE[alert_type] or "custom-alert"
end

---Get the target of an alert (entity or position)
---@param alert Alert
---@return LuaEntity | MapPosition | nil
function mod.get_alert_target(alert)
   if alert.target and alert.target.valid then
      return alert.target
   elseif alert.position then
      return alert.position
   end
   return nil
end

---Check if an alert target is an entity (userdata) vs a position (table)
---@param target LuaEntity | MapPosition | nil
---@return boolean
function mod.target_is_entity(target)
   return type(target) == "userdata"
end

---Read an alert to a message builder
---@param message fa.MessageBuilder
---@param alert Alert
---@param alert_type defines.alert_type
function mod.read_alert_to_msgbuilder(message, alert, alert_type)
   -- For custom alerts, use the custom message
   if alert_type == defines.alert_type.custom then
      if alert.message then
         message:fragment(alert.message)
      else
         message:fragment({ "gui-alert-tooltip.custom-alert" })
      end
      return
   end

   -- Use the built-in locale string
   local locale_key = mod.get_alert_locale_key(alert_type)
   message:fragment({ "gui-alert-tooltip." .. locale_key, 1 })

   -- Add entity info if available
   local target = mod.get_alert_target(alert)
   if target then
      if mod.target_is_entity(target) then
         ---@cast target LuaEntity
         message:fragment(Localising.get_localised_name_with_fallback(target))
         local pos = target.position
         message:fragment({ "fa.alerts-at-position", math.floor(pos.x), math.floor(pos.y) })
      else
         ---@cast target MapPosition
         message:fragment({ "fa.alerts-at-position", math.floor(target.x), math.floor(target.y) })
      end
   end
end

---@class fa.alerts.SortKey
---@field surface_index uint32
---@field has_unit_number boolean
---@field unit_number uint32?
---@field distance number
---@field pos_x number
---@field pos_y number
---@field tick uint32

---Build a sortable key table for an alert
---Sort order: surface, has_unit_number (true first), unit_number/distance, position, tick
---@param alert Alert
---@param surface_index uint32
---@return fa.alerts.SortKey
function mod.build_alert_sort_key(alert, surface_index)
   local pos = nil
   local unit_number = nil

   if alert.target and alert.target.valid then
      pos = alert.target.position
      unit_number = alert.target.unit_number
   elseif alert.position then
      pos = alert.position
   end

   local distance = 0
   local pos_x = 0
   local pos_y = 0
   if pos then
      distance = math.sqrt(pos.x * pos.x + pos.y * pos.y)
      pos_x = pos.x
      pos_y = pos.y
   end

   return {
      surface_index = surface_index,
      has_unit_number = unit_number ~= nil,
      unit_number = unit_number or 0,
      distance = distance,
      pos_x = pos_x,
      pos_y = pos_y,
      tick = alert.tick,
   }
end

---Compare two alert sort keys
---@param a fa.alerts.SortKey
---@param b fa.alerts.SortKey
---@return boolean true if a < b
function mod.compare_sort_keys(a, b)
   -- Surface first
   if a.surface_index ~= b.surface_index then return a.surface_index < b.surface_index end

   -- Has unit number sorts before no unit number
   if a.has_unit_number ~= b.has_unit_number then return a.has_unit_number end

   -- If both have unit numbers, sort by unit number
   if a.has_unit_number then
      if a.unit_number ~= b.unit_number then return a.unit_number < b.unit_number end
   else
      -- Otherwise sort by distance
      if a.distance ~= b.distance then return a.distance < b.distance end
   end

   -- Position tie-break
   if a.pos_x ~= b.pos_x then return a.pos_x < b.pos_x end
   if a.pos_y ~= b.pos_y then return a.pos_y < b.pos_y end

   -- Tick for final tie-break
   return a.tick < b.tick
end

---Build a string key for deduplication
---@param alert Alert
---@param alert_type defines.alert_type
---@param surface_index uint32
---@return string
function mod.build_alert_dedup_key(alert, alert_type, surface_index)
   local pos = nil
   local unit_number = nil

   if alert.target and alert.target.valid then
      pos = alert.target.position
      unit_number = alert.target.unit_number
   elseif alert.position then
      pos = alert.position
   end

   -- Build a unique string from the identifying properties
   local type_name = mod.get_alert_type_name(alert_type)
   if unit_number then
      return string.format("%d-%s-%d", surface_index, type_name, unit_number)
   elseif pos then
      return string.format("%d-%s-%.1f-%.1f", surface_index, type_name, pos.x, pos.y)
   else
      return string.format("%d-%s-%d", surface_index, type_name, alert.tick)
   end
end

---@class fa.alerts.AlertEntry
---@field alert Alert
---@field surface_index uint32
---@field dedup_key string
---@field sort_key fa.alerts.SortKey

---Get all alerts for a player, organized by type
---@param pindex integer
---@return table<defines.alert_type, fa.alerts.AlertEntry[]>
function mod.get_alerts_by_type(pindex)
   local player = game.get_player(pindex)
   if not player then return {} end

   local raw_alerts = player.get_alerts({})
   local by_type = {}

   -- raw_alerts is Dictionary[surface_index, Dictionary[alert_type, Alert[]]]
   for surface_index, alerts_by_type in pairs(raw_alerts) do
      for alert_type, alerts in pairs(alerts_by_type) do
         if not by_type[alert_type] then by_type[alert_type] = {} end

         for _, alert in ipairs(alerts) do
            local dedup_key = mod.build_alert_dedup_key(alert, alert_type, surface_index)
            local sort_key = mod.build_alert_sort_key(alert, surface_index)
            table.insert(by_type[alert_type], {
               alert = alert,
               surface_index = surface_index,
               dedup_key = dedup_key,
               sort_key = sort_key,
            })
         end
      end
   end

   -- Sort each type's alerts using the sort key comparison
   for _, alerts in pairs(by_type) do
      table.sort(alerts, function(a, b)
         return mod.compare_sort_keys(a.sort_key, b.sort_key)
      end)
   end

   -- Deduplicate by dedup_key (keep first occurrence)
   for alert_type, alerts in pairs(by_type) do
      local seen = {}
      local deduped = {}
      for _, entry in ipairs(alerts) do
         if not seen[entry.dedup_key] then
            seen[entry.dedup_key] = true
            table.insert(deduped, entry)
         end
      end
      by_type[alert_type] = deduped
   end

   return by_type
end

---Get a count of alerts by type
---@param pindex integer
---@return table<defines.alert_type, integer>
function mod.get_alert_counts(pindex)
   local alerts_by_type = mod.get_alerts_by_type(pindex)
   local counts = {}
   for alert_type, alerts in pairs(alerts_by_type) do
      counts[alert_type] = #alerts
   end
   return counts
end

---Get the ordered list of alert types that have alerts
---@param pindex integer
---@param include_muted boolean Whether to include muted alert types
---@return defines.alert_type[]
function mod.get_active_alert_types(pindex, include_muted)
   local player = game.get_player(pindex)
   if not player then return {} end

   local counts = mod.get_alert_counts(pindex)
   local active_types = {}

   for alert_type, count in pairs(counts) do
      if count > 0 then
         if include_muted or not player.is_alert_muted(alert_type) then table.insert(active_types, alert_type) end
      end
   end

   -- Sort by alert type name for consistent ordering
   table.sort(active_types, function(a, b)
      return mod.get_alert_type_name(a) < mod.get_alert_type_name(b)
   end)

   return active_types
end

---Get the display name for an alert type (for tab titles)
---@param alert_type defines.alert_type
---@return LocalisedString
function mod.get_alert_type_name_localised(alert_type)
   local locale_key = mod.get_alert_locale_key(alert_type)
   -- Use the tooltip key with count 1 as the name
   return { "gui-alert-tooltip." .. locale_key, 1 }
end

---@class fa.alerts.CustomAlertGroup
---@field message LocalisedString The custom alert message
---@field count integer Number of alerts with this message
---@field alerts { alert: Alert, surface_index: uint32, key: string }[]

---Get custom alerts grouped by their message
---@param pindex integer
---@return fa.alerts.CustomAlertGroup[]
function mod.get_custom_alerts_by_message(pindex)
   local alerts_by_type = mod.get_alerts_by_type(pindex)
   local custom_alerts = alerts_by_type[defines.alert_type.custom] or {}

   -- Group by message (using serpent or simple string conversion for key)
   local by_message = {}
   local message_order = {}

   for _, entry in ipairs(custom_alerts) do
      local alert = entry.alert
      local msg = alert.message or { "gui-alert-tooltip.custom-alert" }
      -- Use serpent to create a stable key from the localised string
      local msg_key = serpent.line(msg, { compact = true })

      if not by_message[msg_key] then
         by_message[msg_key] = {
            message = msg,
            count = 0,
            alerts = {},
         }
         table.insert(message_order, msg_key)
      end

      by_message[msg_key].count = by_message[msg_key].count + 1
      table.insert(by_message[msg_key].alerts, entry)
   end

   -- Convert to ordered list
   local result = {}
   for _, msg_key in ipairs(message_order) do
      table.insert(result, by_message[msg_key])
   end

   return result
end

return mod
