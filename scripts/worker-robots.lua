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
local dirs = defines.direction
local MAX_STACK_COUNT = 10

local mod = {}

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

local function toggle_personal_logistics(pindex)
   local p = game.get_player(pindex)
   local point = p.get_requester_point()
   if not point then return end
   point.enabled = not point.enabled
   if point.enabled then
      Speech.speak(pindex, { "fa.robots-resumed-personal-logistics" })
   else
      Speech.speak(pindex, { "fa.robots-paused-personal-logistics" })
   end
end

local function logistics_request_toggle_spidertron_logistics(spidertron, pindex)
   spidertron.vehicle_logistic_requests_enabled = not spidertron.vehicle_logistic_requests_enabled
   if spidertron.vehicle_logistic_requests_enabled then
      Speech.speak(pindex, { "fa.robots-resumed-spidertron-logistics" })
   else
      Speech.speak(pindex, { "fa.robots-paused-spidertron-logistics" })
   end
end

-- Find, if possible, the item name that a player is currently "looking at" in
-- the context of how we do logistic requests.
---@return string?, LocalisedString?
local function find_player_item_name(pindex)
   -- Now defaults to personal logistics behavior only

   local p = game.get_player(pindex)
   assert(p)
   local char = p.character
   if not char then return nil, { "fa.no-character" } end

   --Personal logistics only
   local stack = game.get_player(pindex).cursor_stack
   local stack_inv = game.get_player(pindex).get_main_inventory()[storage.players[pindex].inventory.index]

   if stack ~= nil and stack.valid_for_read and stack.valid then
      --Item in hand
      return stack.name, nil
   else
      --Empty hand, empty inventory slot
      return nil, "No actions"
   end
end

-- Find the item stack target of the player trying to set a logistic request.
---@param pindex number
---@return LuaEntity?, LocalisedString?
local function find_player_logistic_target(pindex)
   local p = game.players[pindex]
   assert(p)
   local char = p.character
   if not char then return nil, { "fa.no-character" } end

   if p.opened_self then return char end

   -- So this is actually the easy one.  The mod always sets player.opened for every menu we care about.  We just have
   -- to check that it is something supporting logistics.
   local target = p.opened or p.selected
   if not target then return nil, { "fa.bots-nothing-to-control" } end

   ---@cast target LuaEntity
   if not type(target) == "userdata" or not target.object_name == "LuaEntity" then
      return nil, { "fa.bots-nothing-to-control" }
   end

   return target
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
      msg_builder:fragment("ERROR: unable to determine item")
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

   msg_builder:fragment("Unable to handle this request. Serpent:"):fragment(serpent.line(req))
end

function mod.logistics_info_key_handler(pindex)
   local p = game.get_player(pindex)
   local ent = nil
   local err = nil
   local item = nil
   ent, err = find_player_logistic_target(pindex)
   if err then
      Speech.speak(pindex, err)
      return
   end

   -- At least as of right now there is no entity which can do both requests and filters, and players cannot do filters.
   if mod.can_set_logistic_filter(ent) then
      local filter = ent.storage_filter
      ---@type LocalisedString
      local result
      if filter ~= nil then
         ---@diagnostic disable-next-line param-type-mismatch
         result = { "", Localising.get_localised_name_with_fallback(filter), " set as logistic storage filter" }
      else
         result = { "", "Nothing set as logistic storage filter" }
      end
      Speech.speak(pindex, result)
      return
   end
end

function mod.logistics_request_toggle_handler(pindex)
   -- Now only toggles personal logistics
   local ent = game.get_player(pindex).opened
   toggle_personal_logistics(pindex)
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
      Speech.speak(
         pindex,
         { "", Localising.get_localised_name_with_fallback(proto), " set as logistic storage filter " }
      )
   else
      Speech.speak(pindex, { "", name, " set as logistic storage filter " })
   end
end

---Format a compiled logistic filter for readout (from point.filters)
---@param msg_builder fa.MessageBuilder
---@param filter table CompiledLogisticFilter
---@param min_only boolean? If true, only show min value (for constant combinators)
function mod.push_compiled_filter_readout(msg_builder, filter, min_only)
   local item_name = filter.name
   if not item_name then
      msg_builder:fragment("ERROR: unable to determine item")
      return
   end

   local quality_name = filter.quality or "normal"
   local min_val = filter.count or 0
   local max_val = filter.max_count

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
      if min_val > 0 then
         msg_builder:fragment("x")
         msg_builder:fragment(tostring(min_val))
      end
   else
      -- For logistic requests, show min and/or max
      if min_val > 0 and max_val then
         msg_builder:fragment("min")
         msg_builder:fragment(tostring(min_val))
         msg_builder:fragment("max")
         msg_builder:fragment(tostring(max_val))
      elseif min_val > 0 then
         msg_builder:fragment("min")
         msg_builder:fragment(tostring(min_val))
      elseif max_val then
         msg_builder:fragment("max")
         msg_builder:fragment(tostring(max_val))
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

---Get the network name for a logistic point's network
---@param point LuaLogisticPoint
---@return string?
function mod.get_network_name_for_point(point)
   if not point or not point.valid then return nil end

   local network = point.logistic_network
   if not network or not network.valid then return nil end

   -- Find a roboport in this network to get the name
   local cells = network.cells
   if not cells or #cells == 0 then return nil end

   for _, cell in ipairs(cells) do
      if cell and cell.owner and cell.owner.valid and cell.owner.supports_backer_name then
         return cell.owner.backer_name
      end
   end

   return nil
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

-- vanilla does not have network names.  We add this ourselves: all roboports in the same network get the same backer
-- name.
function mod.get_network_name(port)
   mod.fixup_network_name(port)
   return port.backer_name
end

function mod.set_network_name(port, new_name)
   --Rename this port
   if new_name == nil or new_name == "" then return false end
   port.backer_name = new_name
   --Rename the rest, if any.  Note that this is not the same as the fixup function because this doesn't want to account
   --for the oldest roboport.
   local nw = port.logistic_network
   if nw == nil then return true end
   local cells = nw.cells or {}
   for i, cell in ipairs(cells) do
      if cell.owner.supports_backer_name then cell.owner.backer_name = new_name end
   end
   return true
end

--Finds the oldest roboport and applies its name across the network. Any built roboport will be newer and so the older
--names will be kept.  This can happen if the mod is added to a save, roboports are built in ways which don't go through
--the mod, if a roboport joins two networks, or (inn theory, though perhaps not in practice) if there is a power outage.
function mod.fixup_network_name(port_in)
   local oldest_port = port_in
   local nw = oldest_port.logistic_network
   --No network means resolved
   if nw == nil then return end
   local cells = nw.cells
   --Check others
   for i, cell in ipairs(cells) do
      local port = cell.owner
      if port ~= nil and port.valid and oldest_port.unit_number > port.unit_number then oldest_port = port end
   end
   --Rename all
   mod.set_network_name(oldest_port, oldest_port.backer_name)
   return
end

function mod.roboport_contents_info(port)
   local result = ""
   local cell = port.logistic_cell
   result = result
      .. " charging "
      .. cell.charging_robot_count
      .. " robots with "
      .. cell.to_charge_robot_count
      .. " in queue, "
      .. " stationed "
      .. cell.stationed_logistic_robot_count
      .. " logistic robots and "
      .. cell.stationed_construction_robot_count
      .. " construction robots "
      .. " and "
      .. port.get_inventory(defines.inventory.roboport_material).get_item_count()
      .. " repair packs "
   return result
end

function mod.roboport_neighbours_info(port)
   local result = ""
   local cell = port.logistic_cell
   local neighbour_count = #cell.neighbours
   local neighbour_dirs = ""
   for i, neighbour in ipairs(cell.neighbours) do
      local dir = FaUtils.direction_lookup(FaUtils.get_direction_biased(neighbour.owner.position, port.position))
      if i > 1 then neighbour_dirs = neighbour_dirs .. " and " end
      neighbour_dirs = neighbour_dirs .. dir
   end
   if neighbour_count > 0 then
      result = neighbour_count .. " neighbours" .. ", at the " .. neighbour_dirs
   else
      result = neighbour_count .. " neighbours"
   end

   return result
end

function mod.logistic_network_members_info(port)
   local result = ""
   local cell = port.logistic_cell
   local nw = cell.logistic_network
   if nw == nil or nw.valid == false then
      result = " Error: no network "
      return result
   end
   result = " Network has "
      .. #nw.cells
      .. " roboports, and "
      .. nw.all_logistic_robots
      .. " logistic robots with "
      .. nw.available_logistic_robots
      .. " available, and "
      .. nw.all_construction_robots
      .. " construction robots with "
      .. nw.available_construction_robots
      .. " available "
   return result
end

function mod.logistic_network_chests_info(port)
   local result = ""
   local cell = port.logistic_cell
   local nw = cell.logistic_network

   if nw == nil or nw.valid == false then
      result = " Error, no network "
      return result
   end

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
   result = " Network has "
      .. total_chest_count
      .. " chests in total, with "
      .. storage_chest_count
      .. " storage chests, "
      .. passive_provider_chest_count
      .. " passive provider chests, "
      .. active_provider_chest_count
      .. " active provider chests, "
      .. requester_chest_count
      .. " requester chests or buffer chests, "
   return result
end

return mod
