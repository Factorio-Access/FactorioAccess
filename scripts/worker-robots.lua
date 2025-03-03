--Here: Functions relating worker robots, roboports, logistic network systems
--Does not include event handlers directly, but can have functions called by them.
local util = require("util")
local fa_utils = require("scripts.fa-utils")
local fa_equipment = require("scripts.equipment")
local fa_graphics = require("scripts.graphics")
local Localising = require("scripts.localising")
local MessageBuilder = require("scripts.message-builder")
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

   error("Unreachable")
end

---@param point LuaLogisticPoint
---@param allow_create boolean? If true try to create the section.
---@return LuaLogisticSection?
local function find_first_manual_section(point, allow_create)
   local sec_count = point.sections_count
   for i = 1, sec_count do
      local sec = point.get_section(i)
      if sec and sec.is_manual then return sec end
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

local function logistics_request_toggle_personal_logistics(pindex)
   local p = game.get_player(pindex)
   local point = p.get_requester_point()
   if not point then return end
   point.enabled = not point.enabled
   if point.enabled then
      printout("Resumed personal logistics requests", pindex)
   else
      printout("Paused personal logistics requests", pindex)
   end
end

local function logistics_request_toggle_spidertron_logistics(spidertron, pindex)
   spidertron.vehicle_logistic_requests_enabled = not spidertron.vehicle_logistic_requests_enabled
   if spidertron.vehicle_logistic_requests_enabled then
      printout("Resumed spidertron logistics requests", pindex)
   else
      printout("Paused spidertron logistics requests", pindex)
   end
end

--Checks if a player logistic request is fulfilled at the moment (as in, you have the desired item count in your inventory and hand).
--Empty requesrs return nil.
local function get_player_logistic_request_missing_count(pindex, slot_id)
   local p = game.get_player(pindex)
   local point = p.get_requester_point()
   if not point then return nil, nil end

   local section = find_first_manual_section(point)
   if not section then return nil end

   local slot = section.get_slot(slot_id)
   if slot == nil then return nil end
   local missing = slot.min
   if missing == nil then return nil end
   local name = slot.value.name
   --Check player hand
   if p.cursor_stack and p.cursor_stack.valid_for_read and p.cursor_stack.name == name then
      missing = missing - stack.count
   end
   if missing <= 0 then return 0 end
   --Check all player inventories
   missing = missing - p.get_inventory(defines.inventory.character_ammo).get_item_count(name)
   missing = missing - p.get_inventory(defines.inventory.character_armor).get_item_count(name)
   missing = missing - p.get_inventory(defines.inventory.character_guns).get_item_count(name)
   missing = missing - p.get_inventory(defines.inventory.character_main).get_item_count(name)
   missing = missing - p.get_inventory(defines.inventory.character_trash).get_item_count(name)
   if missing <= 0 then return 0 end
   return missing
end

--Returns info string on the current logistics network, or the nearest one, for the current position
function mod.logistics_networks_info(ent, pos_in)
   local result = ""
   local result_code = -1
   ---@type LuaLogisticNetwork?
   local network = nil
   local pos = pos_in
   if pos_in == nil then pos = ent.position end
   --Check if in range of a logistic network
   network = ent.surface.find_logistic_network_by_position(pos, ent.force)
   if network ~= nil and network.valid then
      result_code = 1
      result = "Logistics connected to a network with "
         .. (network.all_logistic_robots + network.all_construction_robots)
         .. " robots"
   else
      --If not, report nearest logistic network
      network = ent.surface.find_closest_logistic_network_by_position(pos, ent.force)
      if network ~= nil and network.valid then
         result_code = 2
         local pos_n = network.find_cell_closest_to(pos).owner.position
         result = "No logistics connected, nearest network is "
            .. util.distance(pos, pos_n)
            .. " tiles "
            .. fa_utils.direction_lookup(fa_utils.get_direction_biased(pos_n, pos))
      else
         result_code = 3
         result = "No logistics connected, no logistic networks nearby, "
      end
   end
   return result, result_code
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
   -- The first point (0) is the requester for (almost) everything.  Rocket
   -- silos in space age are not yet supported.  Important note: if you don't
   -- pass an index you get a 1-based array.
   if ent.type == "rocket-silo" then return nil, nil end
   local point = ent.get_logistic_point(defines.logistic_member_index.character_requester)
   if not point then return nil, nil end

   -- Or create it
   local sec = find_first_manual_section(point, true)
   if not sec then return nil, nil end

   -- If we got a section and it contains an existing filter for the item,
   -- return that.
   for i = 1, sec.filters_count do
      local filt = sec.get_slot(i)
      if filt.value.name == name then return sec, i end
   end

   return sec, sec.filters_count + 1
end

---@param point LuaLogisticPoint?
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
---@return number?, boolean, string? The new value if a set could happen at all. true or false to indicate if there was a change. If false, explain why.
local function modify_logistic_request(ent, item, min_or_max, up_or_down)
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
   local wanted = new_val[up_or_down]
   if cur == nil and wanted == nil and up_or_down == "up" then return math.huge, false end

   -- If wanted is nil and we are going up that's fine. Otherwise, nothing happened.
   if wanted == nil and up_or_down == "down" then return cur, false end

   slot[min_or_max] = wanted
   if slot.min and slot.max and slot.min > slot.max then return cur, false, "Request minimum cannot exceed maximum" end

   sec.set_slot(index, slot)
   return wanted, cur ~= wanted
end

---@param ent LuaEntity
---@param item string
---@param min_or_max "min" | "max"
---@param up_or_down "up" | "down"
local function modify_logistic_request_with_announcement(pindex, ent, item, min_or_max, up_or_down)
   local new, did, err = modify_logistic_request(ent, item, min_or_max, up_or_down)
   if err then
      printout(err, pindex)
      return
   end

   local msg = MessageBuilder.MessageBuilder.new()
   if not did then
      Sounds.play_ui_edge(pindex)
      msg:fragment(min_or_max):fragment("Unchanged. Current value is"):fragment(tostring(new))
   else
      msg:fragment("Set"):fragment(min_or_max):fragment("to"):fragment(new == math.huge and "infinity" or tostring(new))
   end

   printout(msg:build(), pindex)
end

---@param pindex number
---@param item string
---@param min_or_max "min" | "max"
---@param up_or_down "up" | "down"
local function modify_player_logistic_request(pindex, item, min_or_max, up_or_down)
   local p = game.get_player(pindex)
   if not p then return nil, false end
   local force = p.force
   if not force.character_logistic_requests then
      printout("Error: You need to research logistic robotics to use this feature.", pindex)
   end

   local char = p.character
   if not char then
      Sounds.play_ui_edge(pindex)
      printout("You don't control a character right now", pindex)
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
      printout("Cleared request", pindex)
   else
      printout("Request already cleared", pindex)
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

--Calls the appropriate function after a keypress for logistic info
function mod.logistics_info_key_handler(pindex)
   local p = game.get_player(pindex)
   if p.character == nil then
      printout("No logistic information available at the moment.", pindex)
      return
   elseif
      players[pindex].in_menu == false
      or players[pindex].menu == "inventory"
      or players[pindex].menu == "player_trash"
      or players[pindex].menu == "guns"
      or players[pindex].menu == "crafting"
   then
      --Personal logistics
      local stack = p.cursor_stack
      local stack_inv = p.get_main_inventory()[players[pindex].inventory.index]
      local stack_tra = nil
      --Check item in hand or item in inventory
      if stack and stack.valid_for_read and stack.valid then
         --Item in hand
         mod.player_logistic_request_read(stack, pindex, true)
      elseif players[pindex].menu == "inventory" then
         --Item in inv
         mod.player_logistic_request_read(stack_inv, pindex, true)
      elseif players[pindex].menu == "player_trash" then
         stack_tra = p.get_inventory(defines.inventory.character_trash)[players[pindex].inventory.index]
         mod.player_logistic_request_read(stack_tra, pindex, true)
      elseif players[pindex].menu == "guns" then
         local stack = fa_equipment.guns_menu_get_selected_slot(pindex)
         mod.player_logistic_request_read(stack, pindex, true)
      elseif players[pindex].menu == "crafting" then
         --Use the first found item product of the selected recipe, pass it as a stack
         local prototype = fa_utils.get_prototype_of_item_product(pindex)
         if prototype then mod.player_logistic_request_read(prototype, pindex, true) end
      else
         --Logistic chest in front
         local ent = p.selected
         if not ent then
            return
         elseif mod.can_make_logistic_requests(ent) then
            mod.read_entity_requests_summary(ent, pindex)
            return
         elseif mod.can_set_logistic_filter(ent) then
            local filter = ent.storage_filter
            local result = "Nothing"
            if filter ~= nil then result = filter.item.name end
            printout(result .. " set as logistic storage filter", pindex)
            return
         end
         --Empty hand and empty inventory slot
         local result = mod.player_logistic_requests_summary_info(pindex)
         printout(result, pindex)
      end
   elseif players[pindex].menu == "building" and mod.can_make_logistic_requests(p.opened) then
      --Chest logistics
      local stack = p.cursor_stack
      local stack_inv = p.opened.get_output_inventory()[players[pindex].building.index]
      local chest = p.opened
      ---@cast chest any
      if not chest or not type(chest) == "userdata" or not chest.object_name == "LuaEntity" then return end
      ---@cast chest LuaEntity
      --Check item in hand or item in inventory
      if stack ~= nil and stack.valid_for_read and stack.valid then
         --Item in hand
         mod.logistic_request_read(stack, chest, pindex)
      elseif stack_inv ~= nil and stack_inv.valid_for_read and stack_inv.valid then
         --Item in output inv
         mod.logistic_request_read(stack_inv, chest, pindex)
      else
         --Empty hand, empty inventory slot
         mod.read_entity_requests_summary(chest, pindex)
      end
   elseif players[pindex].menu == "vehicle" and mod.can_make_logistic_requests(p.opened) then
      --spidertron logistics
      local stack = p.cursor_stack
      local invs = defines.inventory
      local stack_inv = p.opened.get_inventory(invs.spider_trunk)[players[pindex].building.index]
      local spidertron = p.opened
      ---@cast spidertron any
      if not spidertron or not type(spidertron) == "userdata" or not spidertron.object_name == "LuaEntity" then
         return
      end
      ---@cast spidertron LuaEntity
      --Check item in hand or item in inventory
      if stack ~= nil and stack.valid_for_read and stack.valid then
         --Item in hand
         mod.logistic_request_read(stack, spidertron, pindex, true)
      elseif stack_inv ~= nil and stack_inv.valid_for_read and stack_inv.valid then
         --Item in output inv
         mod.logistic_request_read(stack_inv, spidertron, pindex, true)
      else
         --Empty hand, empty inventory slot
         mod.read_entity_requests_summary(spidertron, pindex)
      end
   elseif players[pindex].menu == "building" and mod.can_set_logistic_filter(p.opened) then
      local filter = p.opened.storage_filter
      local result = "Nothing"
      if filter ~= nil then result = filter.item.name end
      printout(result .. " set as logistic storage filter", pindex)
   elseif players[pindex].menu == "building" then
      printout("Logistic requests not supported for this building", pindex)
   else
      printout("No logistics summary available in this menu", pindex)
   end
end

-- Find the item stack target of the player trying to set a logistic request.
---@param pindex number
---@return LuaEntity?, string?, string?
local function find_player_logistic_target(pindex)
   local p = game.get_player(pindex)
   assert(p)
   local char = p.character
   if not char then return nil, nil, "You are not controlling a character" end

   if
      not players[pindex].in_menu
      or players[pindex].menu == "inventory"
      or players[pindex].menu == "player_trash"
      or players[pindex].menu == "crafting"
   then
      --Personal logistics
      local stack = game.get_player(pindex).cursor_stack
      local stack_inv = game.get_player(pindex).get_main_inventory()[players[pindex].inventory.index]

      if stack ~= nil and stack.valid_for_read and stack.valid then
         --Item in hand
         return char, stack.name, nil
      elseif players[pindex].menu == "inventory" and stack_inv ~= nil and stack_inv.valid_for_read then
         --Item in inv
         return char, stack_inv.name, nil
      elseif players[pindex].menu == "player_trash" then
         --Item in trash
         return nil, nil, "Take this item in hand to change its requests"
      elseif players[pindex].menu == "crafting" then
         --Use the first found item product of the selected recipe, pass it as a stack
         local prototype = fa_utils.get_prototype_of_item_product(pindex)
         return char, prototype.name, nil
      else
         --Empty hand, empty inventory slot
         return nil, nil, "No actions"
      end
   elseif players[pindex].menu == "building" then
      --Chest logistics
      local stack = game.get_player(pindex).cursor_stack
      local stack_inv = game.get_player(pindex).opened.get_output_inventory()[players[pindex].building.index]
      local chest = game.get_player(pindex).opened --[[@as LuaEntity]]
      --Check item in hand or item in inventory
      if stack ~= nil and stack.valid_for_read and stack.valid then
         --Item in hand
         return chest, stack.name, nil
      elseif stack_inv ~= nil and stack_inv.valid_for_read and stack_inv.valid then
         --Item in output inv
         return chest, stack_inv.name, nil
      else
         --Empty hand, empty inventory slot
         return nil, nil, "No actions"
      end
   elseif players[pindex].menu == "vehicle" then
      --spidertron logistics
      local stack = game.get_player(pindex).cursor_stack
      local invs = defines.inventory
      local stack_inv = game.get_player(pindex).opened.get_inventory(invs.spider_trunk)[players[pindex].building.index]
      local spidertron = game.get_player(pindex).opened --[[@as LuaEntity]]
      --Check item in hand or item in inventory
      if stack ~= nil and stack.valid_for_read and stack.valid then
         --Item in hand
         return spidertron, stack.name, nil
      elseif stack_inv ~= nil and stack_inv.valid_for_read and stack_inv.valid then
         --Item in output inv
         return spidertron, stack_inv.name, nil
      else
         --Empty hand, empty inventory slot
         return nil, nil, "No actions"
      end
   end

   return nil, nil, "Could not find item or entity to set logistic request"
end

---@param min_or_max "min" | "max"
---@param up_or_down "up" | "down"
local function modify_logistic_request_kb(pindex, min_or_max, up_or_down)
   local target, name, err = find_player_logistic_target(pindex)
   if err then
      printout(err, pindex)
      return
   end

   assert(target)
   assert(name)

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
   local ent = game.get_player(pindex).opened
   if
      not players[pindex].in_menu
      or players[pindex].menu == "inventory"
      or players[pindex].menu == "player_trash"
      or players[pindex].menu == "crafting"
   then
      --Player: Toggle enabling requests
      logistics_request_toggle_personal_logistics(pindex)
   elseif players[pindex].menu == "vehicle" and mod.can_make_logistic_requests(ent) then
      --Vehicles: Toggle enabling requests
      logistics_request_toggle_spidertron_logistics(ent, pindex)
   elseif players[pindex].menu == "building" then
      --Requester chests: Toggle requesting from buffers
      if mod.can_make_logistic_requests(ent) then
         ent.request_from_buffers = not ent.request_from_buffers
      else
         return
      end
      if ent.request_from_buffers then
         printout("Enabled requesting from buffers", pindex)
      else
         printout("Disabled requesting from buffers", pindex)
      end
   end
end

--Clears the selected logistic request
function mod.logistics_request_clear_handler(pindex)
   local target, name, err = find_player_logistic_target(pindex)
   if not target or not name then
      printout(err, pindex)
      return
   end
   clear_logistic_request_with_announcement(pindex, target, name)
end

--Returns summary info string
function mod.player_logistic_requests_summary_info(pindex)
   local p = game.get_player(pindex)
   local msg = MessageBuilder.MessageBuilder.new()
   local char = p.character

   local network = p.surface.find_logistic_network_by_position(p.position, p.force)
   if network == nil or not network.valid then
      --Check whether in construction range
      local nearest, min_dist = fa_utils.find_nearest_roboport(p.surface, p.position, 60)
      if nearest == nil or min_dist > 55 then
         msg:list_item("Not in a network")
      else
         msg:list_item("In construction range of network"):fragment(nearest.backer_name)
      end
   else
      --Definitely within range
      local nearest, min_dist = fa_utils.find_nearest_roboport(p.surface, p.position, 30)
      msg:list_item("In network"):fragment(nearest.backer_name)
   end

   if char then
      local personal_point = char.get_logistic_point(defines.logistic_member_index.character_requester)
      assert(personal_point)
      local personal_sec = find_first_manual_section(personal_point)
      assert(personal_sec)

      if not personal_sec.active then
         msg:list_item("personal logistics disabled")
      else
         msg:fragment("personal logistics enabled")
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
function mod.player_logistic_request_read(item_object, pindex, additional_checks)
   local p = game.get_player(pindex)
   local char = p.character
   if not char then
      printout("You are not controlling a character", pindex)
      return
   end

   local current_slot = nil
   local correct_slot_id = nil
   local result = ""

   --Check if logistics have been researched

   if not char.force.character_logistic_requests then
      printout("Logistic requests not available, research required.", pindex)
      return
   end

   if additional_checks then
      --Check if inside any logistic network or not (simpler than logistics network info)
      local network = p.surface.find_logistic_network_by_position(p.position, p.force)
      if network == nil or not network.valid then result = result .. "Not in a network, " end

      --Check if personal logistics are enabled
      if not personal_logistics_enabled(pindex) then result = result .. "Requests paused, " end
   end

   if item_object == nil or item_object.valid == false then
      printout(result .. "Error: Unknown or missing item", pindex)
      return
   end

   --Find the correct request slot for this item
   local sec, index = get_logistic_slot_pos(char, item_object.name)

   if not sec or index > sec.filters_count then
      printout(result .. "Error: Invalid slot ID", pindex)
      return
   end

   --Read the correct slot id value
   local current_slot = sec.get_slot(index --[[@as integer]])
   if current_slot == nil or current_slot.value == nil or current_slot.value.name == nil then
      --No requests found
      printout(
         result
            .. item_object.name
            .. " has no personal logistic requests set,"
            .. " use the L key and modifier keys to set requests.",
         pindex
      )
      return
   else
      --Report request counts and inventory counts
      if current_slot.max ~= nil or current_slot.min ~= nil then
         local min_result = ""
         local max_result = ""
         local inv_result = ""
         local trash_result = ""
         local stack_size = 1
         if item_object.object_name == "LuaItemStack" then
            stack_size = item_object.prototype.stack_size
         elseif item_object.object_name == "LuaItemPrototype" then
            stack_size = item_object.stack_size
         end

         if current_slot.min ~= nil then
            min_result = fa_utils.express_in_stacks(current_slot.min, stack_size, false) .. " minimum and "
         end

         if current_slot.max ~= nil then
            max_result = fa_utils.express_in_stacks(current_slot.max, stack_size, false) .. " maximum "
         end

         local inv_count = p.get_main_inventory().get_item_count(item_object.name)
         inv_result = fa_utils.express_in_stacks(inv_count, stack_size, false) .. " in inventory, "

         local trash_count = p.get_inventory(defines.inventory.character_trash).get_item_count(item_object.name)
         trash_result = fa_utils.express_in_stacks(trash_count, stack_size, false) .. " in personal trash, "

         printout(
            result
               .. min_result
               .. max_result
               .. " requested for "
               .. item_object.name
               .. ", "
               .. inv_result
               .. trash_result
               .. " use the L key and modifier keys to set requests.",
            pindex
         )
         return
      else
         --All requests are nil
         printout(
            result
               .. item_object.name
               .. " has no personal logistic requests set,"
               .. " use the L key and modifier keys to set requests.",
            pindex
         )
         return
      end
   end
end

function mod.send_selected_stack_to_logistic_trash(pindex)
   local p = game.get_player(pindex)
   local stack = p.cursor_stack
   --Check cursor stack
   if stack == nil or stack.valid_for_read == false or stack.is_deconstruction_item or stack.is_upgrade_item then
      stack = p.get_main_inventory()[players[pindex].inventory.index]
   end
   --Check inventory stack
   if
      players[pindex].menu ~= "inventory"
      or stack == nil
      or stack.valid_for_read == false
      or stack.is_deconstruction_item
      or stack.is_upgrade_item
   then
      return
   end
   local trash_inv = p.get_inventory(defines.inventory.character_trash)
   if trash_inv.can_insert(stack) then
      local inserted_count = trash_inv.insert(stack)
      if inserted_count < stack.count then
         stack.set_stack({ name = stack.name, count = stack.count - inserted_count })
         printout("Partially sent stack to logistic trash", pindex)
      else
         stack.set_stack(nil)
         printout("Sent stack to logistic trash", pindex)
      end
   end
end

function mod.spidertron_logistic_requests_summary_info(spidertron, pindex)
   local p = game.get_player(pindex)
   local current_slot = nil
   local correct_slot_id = nil
   local result = "Spidertron "

   --1. Check if logistics have been researched
   for i, tech in pairs(game.get_player(pindex).force.technologies) do
      if tech.name == "logistic-robotics" and not tech.researched == true then
         printout("Logistic requests not available, research required.", pindex)
         return
      end
   end

   --2. Check if inside any logistic network or not (simpler than logistics network info)
   local network = p.surface.find_logistic_network_by_position(spidertron.position, p.force)
   if network == nil or not network.valid then
      --Check whether in construction range
      local nearest, min_dist = fa_utils.find_nearest_roboport(p.surface, spidertron.position, 60)
      if nearest == nil or min_dist > 55 then
         result = result .. "Not in a network, "
      else
         result = result .. "In construction range of network " .. nearest.backer_name .. ", "
      end
   else
      --Definitely within range
      local nearest, min_dist = fa_utils.find_nearest_roboport(p.surface, spidertron.position, 30)
      result = result .. "In logistic range of network " .. nearest.backer_name .. ", "
   end

   --3. Check if spidertron logistics are enabled
   if not spidertron.vehicle_logistic_requests_enabled then result = result .. "Requests paused, " end

   result = result
      .. count_active_slots(spidertron.get_logistic_point(defines.logistic_member_index.vehicle_storage))
      .. " spidertron logistic requests set, "
   return result
end

--Logistic requests can be made by chests or spidertrons
function mod.can_make_logistic_requests(ent)
   if ent == nil or ent.valid == false then return false end
   if ent.type == "spider-vehicle" then return true end
   local point = ent.get_logistic_point(defines.logistic_member_index.logistic_container)
   if point == nil then return false end
   if point.mode == defines.logistic_mode.requester or point.mode == defines.logistic_mode.buffer then
      return true
   else
      return false
   end
end

--Logistic filters are set by storage chests
function mod.can_set_logistic_filter(ent)
   if ent == nil or ent.valid == false then return false end
   local point = ent.get_logistic_point(defines.logistic_member_index.logistic_container)
   if point == nil then return false end
   if point.mode == defines.logistic_mode.storage then
      return true
   else
      return false
   end
end

---@param stack LuaItemStack
---@param ent LuaEntity
---@param pindex number
function mod.set_logistic_filter(stack, ent, pindex)
   local filt = ent.get_filter(1)
   if not filt then return end
   local proto = filt.name

   if stack == nil or stack.valid_for_read == false or proto == stack.name then
      ent.set_filter(1, nil)
      printout("logistic storage filter cleared", pindex)
      return
   end

   ent.set_filter(1, stack.name)
   printout(stack.name .. " set as logistic storage filter ", pindex)
end

---@param ent LuaEntity
---@param pindex number
function mod.read_entity_requests_summary(ent, pindex)
   local req_count = 0
   local unfulfilled_count = 0
   for _, p in
      pairs(ent.get_logistic_point() --[=[@as LuaLogisticPoint[]]=])
   do
      for _, sec in pairs(p.sections) do
         req_count = req_count + sec.filters_count
      end
   end

   printout(MessageBuilder.MessageBuilder.new():fragment(tostring(req_count)):fragment("requests set"):build(), pindex)
end

-- vanilla does not have network names.  We add this ourselves: all roboports in
-- the same network get the same backer name.
function mod.get_network_name(port)
   mod.fixup_network_name(port)
   return port.backer_name
end

function mod.set_network_name(port, new_name)
   --Rename this port
   if new_name == nil or new_name == "" then return false end
   port.backer_name = new_name
   --Rename the rest, if any.  Note that this is not the same as the fixup
   --function because this doesn't want to account for the oldest roboport.
   local nw = port.logistic_network
   if nw == nil then return true end
   local cells = nw.cells or {}
   for i, cell in ipairs(cells) do
      if cell.owner.supports_backer_name then cell.owner.backer_name = new_name end
   end
   return true
end

--Finds the oldest roboport and applies its name across the network. Any built
--roboport will be newer and so the older names will be kept.  This can happen
--if the mod is added to a save, roboports are built in ways which don't go
--through the mod, if a roboport joins two networks, or (inn theory, though
--perhaps not in practice) if there is a power outage.
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

--[[--Logistic network menu options summary 
   0. Roboport of logistic network NAME, instructions
   1. Rename roboport network
   2. This roboport: Check neighbor counts and dirs
   3. This roboport: Check contents
   4. Check network roboport & robot & chest(?) counts
   5. Ongoing jobs info
   6. Check network item contents

   This menu opens when you click on a roboport.
]]
function mod.run_roboport_menu(menu_index, pindex, clicked)
   local index = menu_index
   local port = nil
   local ent = game.get_player(pindex).selected
   if game.get_player(pindex).opened ~= nil and game.get_player(pindex).opened.name == "roboport" then
      port = game.get_player(pindex).opened
      players[pindex].roboport_menu.port = port
   elseif ent ~= nil and ent.valid and ent.name == "roboport" then
      port = ent
      ---@cast port LuaEntity
      players[pindex].roboport_menu.port = port
   else
      players[pindex].roboport.port = nil
      printout("Roboport menu requires a roboport", pindex)
      return
   end
   local nw = port.logistic_network

   if index == 0 then
      --0. Roboport of logistic network NAME, instructions
      printout(
         "Roboport of logistic network "
            .. mod.get_network_name(port)
            .. ", Press 'W' and 'S' to navigate options, press 'LEFT BRACKET' to select an option or press 'E' to exit this menu.",
         pindex
      )
   elseif index == 1 then
      --1. Rename roboport networks
      if not clicked then
         printout("Rename this network", pindex)
      else
         printout("Enter a new name for this network, then press 'ENTER' to confirm, or press 'ESC' to cancel.", pindex)
         players[pindex].roboport_menu.renaming = true
         local frame = fa_graphics.create_text_field_frame(pindex, "network-rename")
      end
   elseif index == 2 then
      --2. This roboport: Check neighbor counts and dirs
      if not clicked then
         printout("Read roboport neighbours", pindex)
      else
         local result = mod.roboport_neighbours_info(port)
         printout(result, pindex)
      end
   elseif index == 3 then
      --3. This roboport: Check robot counts
      if not clicked then
         printout("Read roboport contents", pindex)
      else
         local result = mod.roboport_contents_info(port)
         printout(result, pindex)
      end
   elseif index == 4 then
      --4. Check network roboport & robot & chest(?) counts
      if not clicked then
         printout("Read robots info for the network", pindex)
      else
         if nw ~= nil then
            local result = mod.logistic_network_members_info(port)
            printout(result, pindex)
         else
            printout("Error: No network", pindex)
         end
      end
   elseif index == 5 then
      --5. Points/chests info
      if not clicked then
         printout("Read chests info for the network", pindex)
      else
         if nw ~= nil then
            local result = mod.logistic_network_chests_info(port)
            printout(result, pindex)
         else
            printout("Error: No network", pindex)
         end
      end
   elseif index == 6 then
      --6. Check network item contents
      if not clicked then
         printout("Read items info for the network", pindex)
         players[pindex].menu_click_count = 0
      else
         if nw ~= nil then
            local click_count = players[pindex].menu_click_count
            click_count = click_count + 1
            local result = mod.logistic_network_items_info(port --[[@as LuaEntity]], click_count)
            players[pindex].menu_click_count = click_count
            printout(result, pindex)
         else
            printout("Error: No network", pindex)
         end
      end
   end
end
ROBOPORT_MENU_LENGTH = 6

function mod.roboport_menu_open(pindex)
   if players[pindex].vanilla_mode then return end
   --Set the player menu tracker to this menu
   players[pindex].menu = "roboport_menu"
   players[pindex].in_menu = true
   players[pindex].move_queue = {}

   --Initialize if needed
   if players[pindex].roboport_menu == nil then players[pindex].roboport_menu = {} end
   --Set the menu line counter to 0
   players[pindex].roboport_menu.index = 0

   --Play sound
   game.get_player(pindex).play_sound({ path = "Open-Inventory-Sound" })

   --Load menu
   mod.run_roboport_menu(players[pindex].roboport_menu.index, pindex, false)
end

function mod.roboport_menu_close(pindex, mute_in)
   local mute = mute_in
   --Set the player menu tracker to none
   players[pindex].menu = "none"
   players[pindex].in_menu = false

   --Set the menu line counter to 0
   players[pindex].roboport_menu.index = 0
   players[pindex].roboport_menu.port = nil

   --play sound
   if not mute then game.get_player(pindex).play_sound({ path = "Close-Inventory-Sound" }) end

   --Destroy GUI
   if game.get_player(pindex).gui.screen["network-rename"] ~= nil then
      game.get_player(pindex).gui.screen["network-rename"].destroy()
   end
   if game.get_player(pindex).opened ~= nil then game.get_player(pindex).opened = nil end
end

function mod.roboport_menu_up(pindex)
   players[pindex].roboport_menu.index = players[pindex].roboport_menu.index - 1
   if players[pindex].roboport_menu.index < 0 then
      players[pindex].roboport_menu.index = 0
      game.get_player(pindex).play_sound({ path = "inventory-edge" })
   else
      --Play sound
      game.get_player(pindex).play_sound({ path = "Inventory-Move" })
   end
   --Load menu
   mod.run_roboport_menu(players[pindex].roboport_menu.index, pindex, false)
end

function mod.roboport_menu_down(pindex)
   players[pindex].roboport_menu.index = players[pindex].roboport_menu.index + 1
   if players[pindex].roboport_menu.index > ROBOPORT_MENU_LENGTH then
      players[pindex].roboport_menu.index = ROBOPORT_MENU_LENGTH
      game.get_player(pindex).play_sound({ path = "inventory-edge" })
   else
      --Play sound
      game.get_player(pindex).play_sound({ path = "Inventory-Move" })
   end
   --Load menu
   mod.run_roboport_menu(players[pindex].roboport_menu.index, pindex, false)
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
      local dir = fa_utils.direction_lookup(fa_utils.get_direction_biased(neighbour.owner.position, port.position))
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
   --game.print(result,{volume_modifier=0})--
   return result
end

---@param port LuaEntity
function mod.logistic_network_items_info(port, group_no)
   local msg = MessageBuilder.MessageBuilder.new()
   local nw = port.logistic_cell.logistic_network
   if nw == nil or nw.valid == false then
      msg:fragment("Error: no network ")
      return msg:build()
   elseif group_no == 1 then
      msg:fragment("Network contains")
   end
   local itemset = nw.get_contents()
   local itemtable = {}
   for name, count in pairs(itemset) do
      table.insert(itemtable, { name = name, count = count })
   end
   table.sort(itemtable, function(k1, k2)
      return k1.count > k2.count
   end)
   --Use a cached list to handle changes in the list while reading
   if group_no == 1 then
      players[pindex].cached_list = itemtable
   else
      itemtable = players[pindex].cached_list
   end
   if #itemtable == 0 then
      msg:fragment("no items.")
      return msg:build()
   else
      local group_start = (group_no - 1) * 5 + 1
      local group_end = group_start + 4
      if #itemtable < group_start then
         msg:fragment("no other items.")
         return msg:build()
      end
      for i = group_start, group_end, 1 do
         if itemtable[i] then
            msg:list_item(itemtable[i].name)
               :fragment("times")
               :fragment(fa_utils.simplify_large_number(itemtable[i].count))
         end
      end
      if #itemtable > group_end then
         msg:list_item("and other items, "):fragment(#itemtable):fragment("total, press LEFT BRACKET to list more.")
      end
   end
   return msg:build()
end

--laterdo full personal logistics menu where you can go line by line along requests and edit them, iterate through trash?

return mod
