local util = require("util")
local Equipment = require("scripts.equipment")
local FaUtils = require("scripts.fa-utils")
local Graphics = require("scripts.graphics")
local Localising = require("scripts.localising")
local Speech = require("scripts.speech")
local UiRouter = require("scripts.ui.router")
local Sounds = require("scripts.ui.sounds")

local dirs = defines.direction
local MAX_STACK_COUNT = 10

local mod = {}

-- Return the previous and next value to move a logistic filter to, when the
-- player presses the keys. Down is nil if amount == 0. up is nil if there would
-- be more than 10 stacks (which represents infinity).
---@param item LuaItemPrototype | LuaItemStack | string
---@param cur_val number
---@return { down: number?, up: number }
local function compute_increment_decrement(item, cur_val)
   local proto
   if type(item) == "string" then
      proto = prototypes.item[item]
   elseif item.object_name == "LuaItemPrototype" then
      proto = item
   elseif item.object_name == "LuaItemStack" then
      proto = item.prototype
   end

   assert(proto)

   local stack_size = proto.stack_size
   local half = math.floor(stack_size / 2)

   if cur_val == nil then
      return { down = stack_size * 10, up = nil }
   elseif cur_val == 0 then
      return { down = nil, up = 1 }
   elseif cur_val == 1 then
      return { down = 0, up = half }
   elseif cur_val < half then
      return { down = 1, up = half }
   elseif cur_val == half then
      return { down = 1, up = stack_size }
   elseif cur_val < stack_size then
      return { down = half, up = stack_size }
   else
      local stacks = math.floor(cur_val / stack_size)
      assert(stacks >= 1)
      if stacks == 1 then
         return { down = half, up = stack_size * 2 }
      else
         local down = stack_size * (stacks - 1)
         ---@type number?
         local up = stack_size * (stacks + 1)
         if stacks >= 10 then up = nil end
         return { down = down, up = up }
      end
   end
end

---@param point LuaLogisticPoint
---@param allow_create boolean? If true try to create the section.
---@return LuaLogisticSection?
local function find_first_manual_section(point, allow_create)
   local sec_count = point.sections_count
   for i = 1, sec_count do
      local sec = point.get_section(i)

      -- Careful! Manual sections might be in groups, and we need to actively
      -- avoid supporting groups for the time being.
      if sec and sec.is_manual and sec.group == "" then return sec end
   end

   return point.add_section()
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

--Checks if a player logistic request is fulfilled at the moment (as in, you have the desired item count in your inventory and hand).
--Empty requests return 0.
---@param pindex number
---@param slot_id number
---@return number
local function get_player_logistic_request_missing_count(pindex, slot_id)
   local p = game.get_player(pindex)
   local stack = p.cursor_stack
   local point = p.get_requester_point()
   if not point then return 0 end

   local section = find_first_manual_section(point)
   if not section then return 0 end

   local slot = section.get_slot(slot_id)
   if slot == nil then return 0 end
   local missing = slot.min
   if missing == nil then return 0 end
   local name = slot.value.name
   --Check player hand
   if stack and stack.valid_for_read and stack.name == name then missing = missing - stack.count end
   if missing <= 0 then return 0 end
   --Check all player inventories
   missing = missing - p.get_inventory(defines.inventory.character_ammo).get_item_count(name)
   missing = missing - p.get_inventory(defines.inventory.character_armor).get_item_count(name)
   missing = missing - p.get_inventory(defines.inventory.character_guns).get_item_count(name)
   missing = missing - p.get_inventory(defines.inventory.character_main).get_item_count(name)
   if missing <= 0 then return 0 end
   return missing
end

--[[
Get the section and slot index to add a request for the given item.  If there is
no section and it was not possible to create one, return nil.  If there was a
section or it was possible to create one, return either the index of a filter
with the given item or filters_count + 1.  Either both return values are nil, or
neither are.
]]
---@param ent LuaEntity
---@param name string
---@return LuaLogisticSection?, number?
local function get_logistic_slot_pos(ent, name)
   -- The first point (0) is the requester for (almost) everything.  Rocket silos in space age are not yet supported.
   -- Important note: if you don't pass an index you get a 1-based array.
   if ent.type == "rocket-silo" then return nil, nil end

   if ent.type == "logistic-container" and ent.prototype.logistic_mode == defines.logistic_mode.storage then
      return nil, nil
   end

   local point = ent.get_logistic_point(defines.logistic_member_index.character_requester)
   if not point then return nil, nil end

   -- Or create it
   local sec = find_first_manual_section(point, true)
   if not sec then return nil, nil end

   -- If we got a section and it contains an existing filter for the item,
   -- return that.
   for i = 1, sec.filters_count do
      local filt = sec.get_slot(i)
      if filt and filt.value and filt.value.name == name then return sec, i end
   end

   return sec, sec.filters_count + 1
end

---@param point LuaLogisticPoint
local function count_active_slots(point)
   local sections = point.sections
   local count = 0

   for _, sec in pairs(sections) do
      count = count + sec.filters_count
   end

   return count
end

---@param ent LuaEntity
---@param item string
---@param min_or_max "min" | "max"
---@param up_or_down "up" | "down"
---@return number?, boolean, LocalisedString? The new value if a set could happen at all. true or false to indicate if there was a change. If false, explain why.
local function modify_logistic_request(ent, item, min_or_max, up_or_down)
   if not mod.can_make_logistic_requests(ent) then return 0, false, { "fa.bots-requests-not-supported" } end

   local sec, index = get_logistic_slot_pos(ent, item)
   if not sec then return nil, false, "This entity does not support manual logistics" end
   assert(index)
   local slot = sec.get_slot(index)
   local cur = slot[min_or_max]
   if not cur then
      -- If it's the minimum, cur goes to 0, and we will move from there.
      if min_or_max == "min" then cur = 0 end
      -- Otherwise this is currently at infinity, which is fine.
   end

   local dirs = compute_increment_decrement(item, cur)
   local new_val = dirs[up_or_down]
   -- If this is nil and we are going up then infinite; if this is nil and we are going down then 0.
   local wanted = dirs[up_or_down]
   local ret = wanted
   if min_or_max == "min" then
      -- Min special cases: nil in cur means 0, that's what the engine sometimes
      -- gives back.
      if cur == nil then cur = 0 end
      -- If wanted is nil for min, we don't do anything.
      if wanted == nil then return cur, false end
   else
      -- For max, down and nil is do nothing, but up and nil is infinity.  Cur
      -- is also infinity on nil.
      cur = cur or math.huge
      if wanted == nil and up_or_down == "down" then
         return cur, false
      elseif wanted == nil then
         ret = cur
      end
   end

   slot[min_or_max] = wanted
   slot.value = item
   if slot.min and slot.max and slot.min > slot.max then return cur, false, "Request minimum cannot exceed maximum" end

   sec.set_slot(index, slot)
   return ret, cur ~= ret
end

---@param ent LuaEntity
---@param item string
---@param min_or_max "min" | "max"
---@param up_or_down "up" | "down"
local function modify_logistic_request_with_announcement(pindex, ent, item, min_or_max, up_or_down)
   local new, did, err = modify_logistic_request(ent, item, min_or_max, up_or_down)
   if err then
      Speech.speak(pindex, err)
      return
   end

   local msg = Speech.new()
   if not did then
      Sounds.play_ui_edge(pindex)
      msg:fragment(min_or_max):fragment("Unchanged. Current value is"):fragment(tostring(new))
   else
      msg:fragment("Set"):fragment(min_or_max):fragment("to"):fragment(new == math.huge and "infinity" or tostring(new))
   end

   Speech.speak(pindex, msg:build())
end

---@param pindex number
---@param item string
---@param min_or_max "min" | "max"
---@param up_or_down "up" | "down"
local function modify_player_logistic_request(pindex, item, min_or_max, up_or_down)
   local p = game.get_player(pindex)
   if not p then return nil, false end
   local force = p.force
   if not force.character_logistic_requests then Speech.speak(pindex, { "fa.robots-error-need-research" }) end

   local char = p.character
   if not char then
      Sounds.play_ui_edge(pindex)
      Speech.speak(pindex, { "fa.robots-no-character-control" })
      return
   end

   modify_logistic_request_with_announcement(pindex, char, item, min_or_max, up_or_down)
end

local function player_logistic_request_increment_min(item_stack, pindex)
   modify_player_logistic_request(pindex, item_stack.name, "min", "up")
end

local function player_logistic_request_decrement_min(item_stack, pindex)
   modify_player_logistic_request(pindex, item_stack.name, "min", "down")
end

local function player_logistic_request_increment_max(item_stack, pindex)
   modify_player_logistic_request(pindex, item_stack.name, "max", "up")
end

local function player_logistic_request_decrement_max(item_stack, pindex)
   modify_player_logistic_request(pindex, item_stack.name, "max", "down")
end

---@param ent LuaEntity
---@param name string
---@return boolean
local function clear_logistic_request(ent, name)
   local sec, index = get_logistic_slot_pos(ent, name)
   if not sec then return false end
   assert(index)
   if index > sec.filters_count then return false end
   sec.clear_slot(index)
   return true
end

---@param ent LuaEntity
---@param name string
local function clear_logistic_request_with_announcement(pindex, ent, name)
   local did = clear_logistic_request(ent, name)
   if did then
      Speech.speak(pindex, { "fa.robots-cleared-request" })
   else
      Speech.speak(pindex, { "fa.robots-request-already-cleared" })
   end
end

--Clears a logistic request entirely
local function player_logistic_request_clear(item_stack, pindex)
   local p = game.get_player(pindex)
   if not p then return end
   local char = p.character
   if not char then return end
   clear_logistic_request_with_announcement(pindex, char, item_stack.name)
end

-- Find, if possible, the item name that a player is currently "looking at" in
-- the context of how we do logistic requests.
---@return string?, LocalisedString?
local function find_player_item_name(pindex)
   -- [UI CHECKS REMOVED] Logistic request context detection removed
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
---@param msg_builder fa.Speech
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

-- Announce a logistic request.
---@param pindex number
---@param req LogisticFilter
function mod.readout_logistic_request(pindex, req)
   local msg = Speech.new()
   push_request_readout(msg, req)
   Speech.speak(pindex, msg:build())
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
      local result
      if filter ~= nil then
         result = { "", Localising.get_localised_name_with_fallback(filter), " set as logistic storage filter" }
      else
         result = { "", "Nothing set as logistic storage filter" }
      end
      Speech.speak(pindex, result)
      return
   end

   item, err = find_player_item_name(pindex)

   if ent.type == "character" and ent.player.index == pindex then
      if item then
         mod.player_logistic_request_read(item, pindex, true)
      else
         mod.player_logistic_requests_summary_info(pindex)
      end
   elseif ent then
      mod.read_entity_requests_summary(ent, pindex)
   end
end

---@param min_or_max "min" | "max"
---@param up_or_down "up" | "down"
local function modify_logistic_request_kb(pindex, min_or_max, up_or_down)
   local err = nil
   local name = nil
   local target = nil
   name, err = find_player_item_name(pindex)
   if err then
      Speech.speak(pindex, err)
      return
   end
   target, err = find_player_logistic_target(pindex)
   if err then
      Speech.speak(pindex, err)
      return
   end

   assert(target)
   assert(name)

   -- This maps to shift+l, which for logistic filter items is really set filter.
   if up_or_down == "up" and min_or_max == "min" and mod.can_set_logistic_filter(target) then
      mod.set_logistic_filter(pindex, target, name)
      return
   end

   modify_logistic_request_with_announcement(pindex, target, name, min_or_max, up_or_down)
end

function mod.logistics_request_increment_min_handler(pindex)
   modify_logistic_request_kb(pindex, "min", "up")
end

function mod.logistics_request_decrement_min_handler(pindex)
   modify_logistic_request_kb(pindex, "min", "down")
end

function mod.logistics_request_increment_max_handler(pindex)
   modify_logistic_request_kb(pindex, "max", "up")
end

function mod.logistics_request_decrement_max_handler(pindex)
   modify_logistic_request_kb(pindex, "max", "down")
end

function mod.logistics_request_toggle_handler(pindex)
   local router = UiRouter.get_router(pindex)

   -- [UI CHECKS REMOVED] Context-specific toggle removed
   -- Now only toggles personal logistics
   local ent = game.get_player(pindex).opened
   toggle_personal_logistics(pindex)
end

--Clears the selected logistic request
function mod.logistics_request_clear_handler(pindex)
   local err = nil
   local name = nil
   local target = nil
   name, err = find_player_item_name(pindex)
   if err then
      Speech.speak(pindex, err)
      return
   end
   target, err = find_player_logistic_target(pindex)
   if err then
      Speech.speak(pindex, err)
      return
   end

   assert(name)
   assert(target)
   clear_logistic_request_with_announcement(pindex, target, name)
end

--Returns summary info string
function mod.player_logistic_requests_summary_info(pindex)
   local p = game.get_player(pindex)
   local msg = Speech.new()
   local char = p.character

   local position = FaUtils.get_player_relative_origin(pindex)
   if not position then
      msg:fragment("Error: Unable to determine position")
      return msg:build()
   end

   local network = p.surface.find_logistic_network_by_position(position, p.force)
   if network == nil or not network.valid then
      --Check whether in construction range
      local nearest, min_dist = FaUtils.find_nearest_roboport(p.surface, position, 60)
      if nearest == nil or min_dist > 55 then
         msg:fragment("Not in a network.")
      else
         msg:list_item("In construction range of network"):fragment(nearest.backer_name)
      end
   else
      --Definitely within range
      local nearest, min_dist = FaUtils.find_nearest_roboport(p.surface, position, 30)
      msg:list_item("In network"):fragment(nearest.backer_name)
   end

   if char then
      local personal_point = char.get_logistic_point(defines.logistic_member_index.character_requester)
      assert(personal_point)
      local personal_sec = find_first_manual_section(personal_point, true)
      assert(personal_sec)

      if not personal_sec.active then
         msg:list_item("personal logistics disabled")
      else
         msg:list_item("personal logistics enabled")
      end

      local req_count = count_active_slots(personal_point)
      msg:list_item(tostring(req_count)):fragment("personal logistic requests set")

      local unfulfilled_count = 0
      for i = 1, personal_sec.filters_count do
         local missing_check = get_player_logistic_request_missing_count(pindex, i)
         if missing_check ~= nil then
            if missing_check > 0 then unfulfilled_count = unfulfilled_count + 1 end
         end
      end
      if unfulfilled_count > 0 then
         msg:list_item(tostring(unfulfilled_count)):fragment("unfulfilled, missing items include")
         for i = 1, personal_sec.filters_count do
            local missing_check = get_player_logistic_request_missing_count(pindex, i)
            if missing_check ~= nil then
               if missing_check > 0 then
                  local slot = personal_sec.get_slot(i)
                  if slot.value then msg:list_item(tostring(missing_check)):fragment(slot.value.name) end
               end
            end
         end
      else
         msg:fragment("All are fulfilled")
      end
   end

   return msg:build()
end

--Read the current personal logistics request set for this item object, which is a stack or a prototype
function mod.player_logistic_request_read(item_name, pindex, additional_checks)
   local p = game.get_player(pindex)
   local char = p.character
   if not char then
      Speech.speak(pindex, { "fa.robots-not-controlling-character" })
      return
   end

   local current_slot = nil
   local correct_slot_id = nil
   local result = ""

   if additional_checks then
      --Check if inside any logistic network or not (simpler than logistics network info)
      local position = FaUtils.get_player_relative_origin(pindex)
      if position then
         local network = p.surface.find_logistic_network_by_position(position, p.force)
         if network == nil or not network.valid then result = result .. "Not in a network, " end
      end

      --Check if personal logistics are enabled
      if not personal_logistics_enabled(pindex) then result = result .. "Requests paused, " end
   end

   --Find the correct request slot for this item
   local sec, index = get_logistic_slot_pos(char, item_name)

   --Read the correct slot id value
   current_slot = sec.get_slot(index --[[@as integer]])
   if current_slot == nil or current_slot.value == nil or current_slot.value.name == nil then
      --No requests found
      Speech.speak(
         pindex,
         result
            .. item_name
            .. " has no personal logistic requests set,"
            .. " use the L key and modifier keys to set requests."
      )
      return
   else
      --Report request counts and inventory counts
      local msg = Speech.new()

      if current_slot.max ~= nil or current_slot.min ~= nil then
         local min_result = ""
         local max_result = ""
         local inv_result = ""
         local stack_size = 1

         stack_size = prototypes.item[item_name].stack_size

         if current_slot.min ~= nil then
            min_result = FaUtils.express_in_stacks(current_slot.min, stack_size, false) .. " minimum and "
         end

         if current_slot.max ~= nil then
            max_result = FaUtils.express_in_stacks(current_slot.max, stack_size, false) .. " maximum "
         end

         local inv_count = p.get_main_inventory().get_item_count(item_name)
         inv_result = FaUtils.express_in_stacks(inv_count, stack_size, false) .. " in inventory, "

         msg:list_item(result):list_item()
         push_request_readout(msg, current_slot)
         msg:list_item(inv_result):list_item("use the L key and modifier keys to set requests.")
         Speech.speak(pindex, msg:build())
         return
      else
         --All requests are nil
         Speech.speak(
            pindex,
            result
               .. item_name
               .. " has no personal logistic requests set,"
               .. " use the L key and modifier keys to set requests."
         )
         return
      end
   end
end

function mod.spidertron_logistic_requests_summary_info(spidertron, pindex)
   local p = game.get_player(pindex)
   local current_slot = nil
   local correct_slot_id = nil
   local result = "Spidertron "

   --2. Check if inside any logistic network or not (simpler than logistics network info)
   local network = p.surface.find_logistic_network_by_position(spidertron.position, p.force)
   if network == nil or not network.valid then
      --Check whether in construction range
      local nearest, min_dist = FaUtils.find_nearest_roboport(p.surface, spidertron.position, 60)
      if nearest == nil or min_dist > 55 then
         result = result .. "Not in a network, "
      else
         result = result .. "In construction range of network " .. nearest.backer_name .. ", "
      end
   else
      --Definitely within range
      local nearest, min_dist = FaUtils.find_nearest_roboport(p.surface, spidertron.position, 30)
      result = result .. "In logistic range of network " .. nearest.backer_name .. ", "
   end

   --3. Check if spidertron logistics are enabled
   if not spidertron.vehicle_logistic_requests_enabled then result = result .. "Requests paused, " end

   result = result
      .. count_active_slots(spidertron.get_logistic_point(defines.logistic_member_index.vehicle_storage))
      .. " spidertron logistic requests set, "
   return result
end

--Logistic requests can be made by anything with a logistic point of the appropriate role, except for rocket silos which
--we dummy out until we can properly support them.
---@return boolean
function mod.can_make_logistic_requests(ent)
   if ent == nil or ent.valid == false then return false end
   if ent.type == "logistic-container" and ent.prototype.logistic_mode == "storage" then return false end

   local point = ent.get_logistic_point()
   if point == nil or not next(point) then return false end
   for _, p in pairs(point) do
      if p.mode == defines.logistic_mode.requester or p.mode == defines.logistic_mode.buffer then return true end
   end

   return false
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

---@param ent LuaEntity
---@param pindex number
function mod.read_entity_requests_summary(ent, pindex)
   local req_count = 0
   local unfulfilled_count = 0
   local reqs = {}
   for _, p in
      pairs(ent.get_logistic_point() --[=[@as LuaLogisticPoint[]]=])
   do
      for _, sec in pairs(p.sections) do
         req_count = req_count + sec.filters_count
         for req_i = 1, sec.filters_count do
            table.insert(reqs, sec.get_slot(req_i))
         end
      end
   end

   local msg = Speech.new():fragment(tostring(req_count)):fragment("requests.")
   for _, req in pairs(reqs) do
      msg:list_item()
      push_request_readout(msg, req)
   end

   Speech.speak(pindex, msg:build())
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

-- Old roboport menu functions removed - now handled by scripts/ui/menus/roboport-menu.lua

-- Keep shared helper functions that provide generic utility for other modules
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
