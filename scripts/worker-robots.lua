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

---@class fa.WorkerRobots.State
---@field pending_logistic_state_announcement boolean
---@field pending_dispatch_state_announcement boolean

---@type table<number, fa.WorkerRobots.State>
local worker_robots_storage = StorageManager.declare_storage_module("worker_robots", {
   pending_logistic_state_announcement = false,
   pending_dispatch_state_announcement = false,
})

---Cache of roboport-compatible item names, built at script load
---@type string[]?
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

local function schedule_personal_logistics_announcement(pindex)
   -- The game's toggle-personal-logistic-requests control will handle the actual toggle
   -- We just set a flag to announce the new state on the next tick
   worker_robots_storage[pindex].pending_logistic_state_announcement = true
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

function mod.announce_robot_dispatch_status(pindex)
   -- The game's toggle-personal-roboport control will handle the actual toggle
   -- We just set a flag to announce the new state on the next tick
   worker_robots_storage[pindex].pending_dispatch_state_announcement = true
end

function mod.can_set_logistic_filter(ent)
   if ent == nil or ent.valid == false then return false end
   return ent.type == "logistic-container" and ent.prototype.logistic_mode == "storage"
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

   -- Without an index, the API returns the array of all points
   return entity.get_logistic_point() --[[@as LuaLogisticPoint[]?]]
      or {}
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
---@return LocalisedString?
function mod.get_network_name_for_point(point)
   if not point or not point.valid then return nil end

   local network = point.logistic_network
   if not network then return nil end
   -- API surprise! Points not in a network also return networks, they're just invalid.
   if not network.valid then return nil end

   return mod.get_network_name_from_network(network)
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

---Calculate the distance from a position to the edge of a logistic cell's coverage box.
---Logistic coverage is a square with half-side = logistic_radius.
---@param position fa.Point
---@param cell LuaLogisticCell
---@return number distance Positive if outside, negative if inside
local function distance_to_cell_coverage(position, cell)
   local center = cell.owner.position --[[@as MapPosition.struct]]
   local radius = cell.logistic_radius

   -- Box bounds
   local min_x = center.x - radius
   local max_x = center.x + radius
   local min_y = center.y - radius
   local max_y = center.y + radius

   local px, py = position.x, position.y

   -- Check if inside the box
   local inside = px >= min_x and px <= max_x and py >= min_y and py <= max_y

   if inside then
      -- Distance to nearest edge (negative = inside)
      local dist_to_left = px - min_x
      local dist_to_right = max_x - px
      local dist_to_top = py - min_y
      local dist_to_bottom = max_y - py
      return -math.min(dist_to_left, dist_to_right, dist_to_top, dist_to_bottom)
   else
      -- Closest point on box
      local closest_x = math.max(min_x, math.min(px, max_x))
      local closest_y = math.max(min_y, math.min(py, max_y))
      return util.distance(position, { x = closest_x, y = closest_y })
   end
end

---Find the closest logistic network and calculate distance to its coverage area.
---@param surface LuaSurface
---@param position fa.Point
---@param force ForceID
---@return LuaLogisticNetwork? network The closest network, or nil if none found
---@return number? distance Distance to coverage edge (positive=outside, negative=inside), nil if no network
---@return defines.direction? direction Direction toward the network, nil if no network or inside coverage
function mod.find_closest_network_with_distance(surface, position, force)
   local network = surface.find_closest_logistic_network_by_position(position, force)
   if not network then return nil, nil, nil end

   local cell = network.find_cell_closest_to(position)
   if not cell then return network, nil, nil end

   local distance = distance_to_cell_coverage(position, cell)

   -- Only provide direction if outside the coverage
   local direction = nil
   if distance > 0 then direction = FaUtils.get_direction_biased(cell.owner.position, position) end

   return network, distance, direction
end

---On tick handler to announce logistics state changes after the game has processed them
---@param pindex integer
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

   if player_storage.pending_dispatch_state_announcement then
      player_storage.pending_dispatch_state_announcement = false

      local p = game.get_player(pindex)
      local char = p.character
      if not char then return end

      if char.allow_dispatching_robots then
         Speech.speak(pindex, { "fa.robots-dispatch-enabled" })
      else
         Speech.speak(pindex, { "fa.robots-dispatch-disabled" })
      end
   end
end

return mod
