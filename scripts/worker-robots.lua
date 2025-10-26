local util = require("util")
local Equipment = require("scripts.equipment")
local FaUtils = require("scripts.fa-utils")
local Graphics = require("scripts.graphics")
local Localising = require("scripts.localising")
local Speech = require("scripts.speech")
local MessageBuilder = Speech.MessageBuilder
local UiRouter = require("scripts.ui.router")
local Sounds = require("scripts.ui.sounds")
local Viewpoint = require("scripts.viewpoint")
local StorageManager = require("scripts.storage-manager")
local dirs = defines.direction
local MAX_STACK_COUNT = 10

local mod = {}

-- Storage for pending logistics announcements
local worker_robots_storage = StorageManager.declare_storage_module("worker_robots", {
   pending_logistic_state_announcement = false,
})

---Cache of roboport-compatible item names, built at script load
---@type string[]
local roboport_compatible_items = nil

---Get list of items that roboports can request (repair tools and robots)
---@return string[]
function mod.get_roboport_compatible_items()
   if roboport_compatible_items then return roboport_compatible_items end

   roboport_compatible_items = {}

   -- Iterate over all item prototypes and find roboport-compatible types
   for name, proto in pairs(prototypes.item) do
      if proto.type == "repair-tool" or proto.type == "construction-robot" or proto.type == "logistic-robot" then
         table.insert(roboport_compatible_items, name)
      end
   end

   table.sort(roboport_compatible_items)
   return roboport_compatible_items
end

---Determine the appropriate logistic group type for an entity
---Does not validate entity
---@param entity LuaEntity
---@return defines.logistic_group_type
function mod.get_logistic_group_type_for_entity(entity)
   if entity.type == "roboport" then return defines.logistic_group_type.roboport end
   return defines.logistic_group_type.with_trash
end

local function personal_logistics_enabled(pindex)
   local p = game.get_player(pindex)
   local char = p.character
   if not char then return false end
   local point = char.get_logistic_point(defines.logistic_member_index.character_requester)
   for _, sec in pairs(point.sections) do
      if sec.active then return true end
   end

   return false
end

local function schedule_personal_logistics_announcement(pindex)
   -- The game's toggle-personal-logistic-requests control will handle the actual toggle
   -- We just set a flag to announce the new state on the next tick
   worker_robots_storage[pindex].pending_logistic_state_announcement = true
end

-- Push a readout of a logistic request to the provided builder as a fragment.
---@param msg_builder fa.MessageBuilder
---@param req LogisticFilter
local function push_request_readout(msg_builder, req)
   -- Error conditions are unlocalised because they should never happen.  We
   -- should probably change these to asserts in the long run, but for now this
   -- is very new code and it is better to function partially.

   local protoname = req.value
   if not protoname then
      msg_builder:fragment({ "fa.error-unable-to-determine-item" })
      return
   end

   if type(protoname) ~= "string" then protoname = protoname.name end

   local bottom = req.min
   local top = req.max

   local localised_item = Localising.get_localised_name_with_fallback(prototypes.item[protoname])
   if not bottom and not top then
      msg_builder:fragment({ "fa.bots-request-unconstrained", localised_item })
      return
   elseif bottom and top then
      if bottom == top then
         msg_builder:fragment({ "fa.bots-request-exactly", localised_item, bottom })
      else
         msg_builder:fragment({ "fa.bots-request-range", localised_item, bottom, top })
      end

      return
   elseif not bottom or bottom == 0 then
      msg_builder:fragment({ "fa.bots-request-max-only", localised_item, top })
      return
   elseif not top then
      msg_builder:fragment({ "fa.bots-request-min-only", localised_item, bottom })
      return
   end

   msg_builder:fragment({ "fa.error-unable-to-handle-request" }):fragment(serpent.line(req))
end

function mod.logistics_info_key_handler(pindex)
   local p = game.get_player(pindex)
   local ent = p.selected
   if not ent then return end

   -- At least as of right now there is no entity which can do both requests and filters, and players cannot do filters.
   if mod.can_set_logistic_filter(ent) then
      local filter = ent.storage_filter
      ---@type LocalisedString
      local result
      if filter ~= nil then
         ---@diagnostic disable-next-line param-type-mismatch
         result = { "fa.logistic-storage-filter-set", Localising.get_localised_name_with_fallback(filter) }
      else
         result = { "fa.logistic-storage-filter-nothing" }
      end
      Speech.speak(pindex, result)
      return
   end
end

function mod.logistics_request_toggle_handler(pindex)
   -- Now only toggles personal logistics
   schedule_personal_logistics_announcement(pindex)
end

function mod.can_set_logistic_filter(ent)
   if ent == nil or ent.valid == false then return false end
   return ent.type == "logistic-container" and ent.prototype.logistic_mode == "storage"
end

---@param pindex number
---@param ent LuaEntity
---@param name string
function mod.set_logistic_filter(pindex, ent, name)
   local filt = ent.get_filter(1)

   if filt and filt.name.name == name then
      ent.set_filter(1, nil)
      Speech.speak(pindex, { "fa.robots-storage-filter-cleared" })
      return
   end

   ent.set_filter(1, name)
   local proto = prototypes.item[name]
   if proto then
      Speech.speak(pindex, { "fa.logistic-storage-filter-set", Localising.get_localised_name_with_fallback(proto) })
   else
      Speech.speak(pindex, { "fa.logistic-storage-filter-set", name })
   end
end

---Format a compiled logistic filter for readout (from point.filters)
---@param msg_builder fa.MessageBuilder
---@param filter table CompiledLogisticFilter
---@param min_only boolean? If true, only show min value (for constant combinators)
function mod.push_compiled_filter_readout(msg_builder, filter, min_only)
   local item_name = filter.name
   if not item_name then
      msg_builder:fragment({ "fa.error-unable-to-determine-item" })
      return
   end

   local quality_name = filter.quality or "normal"
   local min_val = filter.count or 0
   local max_val = filter.max_count

   -- In compiled filters, infinity is represented as 4294967295 (2^32 - 1)
   local INFINITY_SENTINEL = 4294967295
   if max_val and max_val >= INFINITY_SENTINEL then
      max_val = nil -- Treat as infinity
   end

   -- Get localized names
   local localised_item = Localising.get_localised_name_with_fallback(prototypes.item[item_name])
   local quality_proto = prototypes.quality[quality_name]
   local localised_quality = quality_proto and Localising.get_localised_name_with_fallback(quality_proto)
      or quality_name

   -- Build the message: "quality item min X max Y"
   -- Only show quality if it's not "normal" to keep common case clean
   if quality_name ~= "normal" then msg_builder:fragment(localised_quality) end

   msg_builder:fragment(localised_item)

   if min_only then
      -- For constant combinators, only show the count
      if min_val > 0 then msg_builder:fragment({ "fa.filter-count-x", tostring(min_val) }) end
   else
      -- For logistic requests, show min and/or max
      if min_val > 0 and max_val then
         msg_builder:fragment({ "fa.filter-count-min-max", tostring(min_val), tostring(max_val) })
      elseif min_val > 0 then
         msg_builder:fragment({ "fa.filter-count-min", tostring(min_val) })
      elseif max_val then
         msg_builder:fragment({ "fa.filter-count-max", tostring(max_val) })
      end
   end
   -- If neither min nor max, just the item name (unconstrained)
end

---Get all logistic points from an entity
---@param entity LuaEntity
---@return LuaLogisticPoint[]
function mod.get_all_logistic_points(entity)
   if not entity or not entity.valid then return {} end

   local points_result = entity.get_logistic_point()
   if not points_result then return {} end

   -- If called without index, returns array of points
   if type(points_result) == "table" then
      return points_result
   else
      -- Single point returned
      return { points_result }
   end
end

---Get unique group names from all sections in a point (excluding empty string)
---@param point LuaLogisticPoint
---@return string[]
function mod.get_unique_groups_from_point(point)
   if not point or not point.valid then return {} end

   local groups_set = {}
   for _, section in pairs(point.sections) do
      if section.group and section.group ~= "" then groups_set[section.group] = true end
   end

   local groups = {}
   for group, _ in pairs(groups_set) do
      table.insert(groups, group)
   end

   table.sort(groups)
   return groups
end

---Get the network name directly from a network
---@param network LuaLogisticNetwork
---@return LocalisedString
function mod.get_network_name_from_network(network)
   if not network or not network.valid then return { "fa.error-no-network" } end

   -- Use custom_name if set, else fall back to network ID
   if network.custom_name and network.custom_name ~= "" then return network.custom_name end

   return tostring(network.network_id)
end

---Get the network name for a logistic point's network
---@param point LuaLogisticPoint
---@return string?
function mod.get_network_name_for_point(point)
   if not point or not point.valid then return nil end

   local network = point.logistic_network
   if not network then return nil end

   return mod.get_network_name_from_network(network)
end

---Add formatted compiled filters from a point to a message builder
---@param point LuaLogisticPoint
---@param msg_builder fa.MessageBuilder
---@param filter_type "filters" | "targeted_items_pickup" | "targeted_items_deliver"
function mod.add_formatted_filters(point, msg_builder, filter_type)
   if not point or not point.valid then return end

   local items
   if filter_type == "filters" then
      items = point.filters
   elseif filter_type == "targeted_items_pickup" then
      items = point.targeted_items_pickup
   elseif filter_type == "targeted_items_deliver" then
      items = point.targeted_items_deliver
   end

   if not items or not next(items) then
      msg_builder:list_item({ "fa.logistics-no-items" })
      return
   end

   -- For filters (CompiledLogisticFilter array)
   if filter_type == "filters" then
      for _, filter in ipairs(items) do
         if filter and filter.value then
            msg_builder:list_item()
            ---@diagnostic disable-next-line: param-type-mismatch
            push_request_readout(msg_builder, filter)
         end
      end
   else
      -- For targeted_items (ItemWithQualityCounts - table of item_name -> count)
      for item_name, count in pairs(items) do
         if count and count > 0 then
            msg_builder:list_item()
            msg_builder:fragment(Localising.get_localised_name_with_fallback(prototypes.item[item_name]))
            msg_builder:fragment(tostring(count))
         end
      end
   end
end

---Get the network name (custom name if set, else network ID)
---@param port LuaEntity
---@return LocalisedString
function mod.get_network_name(port)
   local nw = port.logistic_network
   if not nw then return { "fa.error-no-network" } end

   return mod.get_network_name_from_network(nw)
end

---Set the network's custom name
---@param port LuaEntity
---@param new_name string
---@return boolean
function mod.set_network_name(port, new_name)
   if new_name == nil or new_name == "" then return false end

   local nw = port.logistic_network
   if not nw then return false end

   nw.custom_name = new_name
   return true
end

function mod.roboport_contents_info(port)
   local cell = port.logistic_cell
   local repair_pack_count = port.get_inventory(defines.inventory.roboport_material).get_item_count()
   return {
      "fa.roboport-charging-info",
      tostring(cell.charging_robot_count),
      tostring(cell.to_charge_robot_count),
      tostring(cell.stationed_logistic_robot_count),
      tostring(cell.stationed_construction_robot_count),
      tostring(repair_pack_count),
   }
end

function mod.roboport_neighbours_info(port)
   local cell = port.logistic_cell
   local neighbour_count = #cell.neighbours

   if neighbour_count == 0 then return { "fa.roboport-neighbours-none", tostring(neighbour_count) } end

   -- Build list of directions
   local dirs = {}
   for _, neighbour in ipairs(cell.neighbours) do
      local dir = FaUtils.direction_lookup(FaUtils.get_direction_biased(neighbour.owner.position, port.position))
      table.insert(dirs, dir)
   end
   local neighbour_dirs = table.concat(dirs, " and ")

   return { "fa.roboport-neighbours-info", tostring(neighbour_count), neighbour_dirs }
end

function mod.logistic_network_members_info(port)
   local cell = port.logistic_cell
   local nw = cell.logistic_network
   if nw == nil or nw.valid == false then return { "fa.error-no-network" } end

   return {
      "fa.network-members-info",
      tostring(#nw.cells),
      tostring(nw.all_logistic_robots),
      tostring(nw.available_logistic_robots),
      tostring(nw.all_construction_robots),
      tostring(nw.available_construction_robots),
   }
end

function mod.logistic_network_chests_info(port)
   local cell = port.logistic_cell
   local nw = cell.logistic_network

   if nw == nil or nw.valid == false then return { "fa.error-no-network" } end

   local storage_chest_count = 0
   for i, ent in ipairs(nw.storage_points) do
      if ent.owner.type == "logistic-container" then storage_chest_count = storage_chest_count + 1 end
   end
   local passive_provider_chest_count = 0
   for i, ent in ipairs(nw.passive_provider_points) do
      if ent.owner.type == "logistic-container" then passive_provider_chest_count = passive_provider_chest_count + 1 end
   end
   local active_provider_chest_count = 0
   for i, ent in ipairs(nw.active_provider_points) do
      if ent.owner.type == "logistic-container" then active_provider_chest_count = active_provider_chest_count + 1 end
   end
   local requester_chest_count = 0
   for i, ent in ipairs(nw.requester_points) do
      if ent.owner.type == "logistic-container" then requester_chest_count = requester_chest_count + 1 end
   end
   local total_chest_count = storage_chest_count
      + passive_provider_chest_count
      + active_provider_chest_count
      + requester_chest_count

   return {
      "fa.network-chests-info",
      tostring(total_chest_count),
      tostring(storage_chest_count),
      tostring(passive_provider_chest_count),
      tostring(active_provider_chest_count),
      tostring(requester_chest_count),
   }
end

---On tick handler to announce logistics state changes after the game has processed them
---@param pindex number
function mod.on_tick(pindex)
   local player_storage = worker_robots_storage[pindex]

   if player_storage.pending_logistic_state_announcement then
      player_storage.pending_logistic_state_announcement = false

      local p = game.get_player(pindex)
      local char = p.character
      if not char then return end

      local point = char.get_logistic_point(defines.logistic_member_index.character_requester)
      if not point then return end

      if point.enabled then
         Speech.speak(pindex, { "fa.robots-resumed-personal-logistics" })
      else
         Speech.speak(pindex, { "fa.robots-paused-personal-logistics" })
      end
   end
end

return mod
