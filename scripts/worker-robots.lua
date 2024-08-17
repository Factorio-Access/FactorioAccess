--Here: Functions relating worker robots, roboports, logistic network systems
--Does not include event handlers directly, but can have functions called by them.
local util = require("util")
local fa_utils = require("scripts.fa-utils")

local dirs = defines.direction
local MAX_STACK_COUNT = 10

local mod = {}

--Increments: nil, 1, half-stack, 1 stack, n stacks
local function increment_logistic_request_min_amount(stack_size, amount_min_in)
   local amount_min = amount_min_in

   if amount_min == nil or amount_min == 0 then
      amount_min = 1
   elseif amount_min == 1 then
      amount_min = math.max(math.floor(stack_size / 2), 2) -- 0 --> 2
   elseif amount_min <= math.floor(stack_size / 2) then
      amount_min = stack_size
   elseif amount_min <= stack_size then
      amount_min = amount_min + stack_size
   elseif amount_min > stack_size then
      amount_min = amount_min + stack_size
   end

   return amount_min
end

--Increments: nil, 1, half-stack, 1 stack, n stacks
local function decrement_logistic_request_min_amount(stack_size, amount_min_in)
   local amount_min = amount_min_in

   if amount_min == nil or amount_min == 0 then
      amount_min = nil
   elseif amount_min == 1 then
      amount_min = nil
   elseif amount_min <= math.floor(stack_size / 2) then
      amount_min = 1
   elseif amount_min <= stack_size then
      amount_min = math.floor(stack_size / 2)
   elseif amount_min > stack_size then
      amount_min = amount_min - stack_size
   end

   if amount_min == 0 then -- 0 --> "0"
      amount_min = nil
   end

   return amount_min
end

--Increments: 0, 1, half-stack, 1 stack, n stacks
local function increment_logistic_request_max_amount(stack_size, amount_max_in)
   local amount_max = amount_max_in
   if amount_max >= stack_size * MAX_STACK_COUNT then
      amount_max = nil
   elseif amount_max > stack_size then
      amount_max = amount_max + stack_size
   elseif amount_max >= stack_size then
      amount_max = amount_max + stack_size
   elseif amount_max >= math.floor(stack_size / 2) then
      amount_max = stack_size
   elseif amount_max >= 1 then
      amount_max = math.max(math.floor(stack_size / 2), 2) -- 0 --> 2
   elseif amount_max == nil or amount_max == 0 then
      amount_max = stack_size
   end

   return amount_max
end

--Increments: 0, 1, half-stack, 1 stack, n stacks
local function decrement_logistic_request_max_amount(stack_size, amount_max_in)
   local amount_max = amount_max_in

   if amount_max > stack_size * MAX_STACK_COUNT then
      amount_max = stack_size * MAX_STACK_COUNT
   elseif amount_max > stack_size then
      amount_max = amount_max - stack_size
   elseif amount_max >= stack_size then
      amount_max = math.floor(stack_size / 2)
   elseif amount_max >= math.floor(stack_size / 2) then
      amount_max = 1
      if stack_size == 1 then -- 0 --> 0
         amount_max = 0
      end
   elseif amount_max >= 1 then
      amount_max = 0
   elseif amount_max >= 0 then
      amount_max = 0
   elseif amount_max == nil then
      amount_max = stack_size
   end

   return amount_max
end

local function logistics_request_toggle_personal_logistics(pindex)
   local p = game.get_player(pindex)
   p.character_personal_logistic_requests_enabled = not p.character_personal_logistic_requests_enabled
   if p.character_personal_logistic_requests_enabled then
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
   local slot = p.get_personal_logistic_slot(slot_id)
   if slot == nil or slot.name == nil then return nil end
   local missing = slot.min
   if missing == nil then return nil end
   --Check player hand
   if p.cursor_stack and p.cursor_stack.valid_for_read and p.cursor_stack.name == slot.name then
      missing = missing - stack.count
   end
   if missing <= 0 then return 0 end
   --Check all player inventories
   missing = missing - p.get_inventory(defines.inventory.character_ammo).get_item_count(slot.name)
   missing = missing - p.get_inventory(defines.inventory.character_armor).get_item_count(slot.name)
   missing = missing - p.get_inventory(defines.inventory.character_guns).get_item_count(slot.name)
   missing = missing - p.get_inventory(defines.inventory.character_main).get_item_count(slot.name)
   missing = missing - p.get_inventory(defines.inventory.character_trash).get_item_count(slot.name)
   if missing <= 0 then return 0 end
   return missing
end

--Returns info string on the current logistics network, or the nearest one, for the current position
function mod.logistics_networks_info(ent, pos_in)
   local result = ""
   local result_code = -1
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

--Finds or assigns the logistic request slot for the item
local function get_personal_logistic_slot_index(item_stack, pindex)
   local p = game.get_player(pindex)
   local slots_nil_counter = 0
   local slot_found = false
   local current_slot = nil
   local correct_slot_id = nil
   local slot_id = 0

   --Find the correct request slot for this item, if any
   while not slot_found and slots_nil_counter < 250 do
      slot_id = slot_id + 1
      current_slot = p.get_personal_logistic_slot(slot_id)
      if current_slot == nil or current_slot.name == nil then
         slots_nil_counter = slots_nil_counter + 1
      elseif current_slot.name == item_stack.name then
         slot_found = true
         correct_slot_id = slot_id
      else
         --do nothing
      end
   end

   --If needed, find the first empty slot and set it as the correct one
   if not slot_found then
      slot_id = 0
      while not slot_found and slot_id < 250 do
         slot_id = slot_id + 1
         current_slot = p.get_personal_logistic_slot(slot_id)
         if current_slot == nil or current_slot.name == nil then
            slot_found = true
            correct_slot_id = slot_id
         else
            --do nothing
         end
      end
   end

   --If no correct or empty slots found then return with error (all slots full)
   if not slot_found then return -1 end

   return correct_slot_id
end

local function count_active_personal_logistic_slots(pindex) --**laterdo count fulfilled ones in the same loop ; also try p.character.request_slot_count
   local p = game.get_player(pindex)
   local slots_nil_counter = 0
   local slots_found = 0
   local current_slot = nil
   local slot_id = 0

   --Find non-empty request slots
   while slots_nil_counter < 250 do
      slot_id = slot_id + 1
      current_slot = p.get_personal_logistic_slot(slot_id)
      if current_slot == nil or current_slot.name == nil then
         slots_nil_counter = slots_nil_counter + 1
      else
         slots_found = slots_found + 1
      end
   end
   return slots_found
end

local function count_active_spidertron_logistic_slots(spidertron, pindex)
   local slots_max_count = spidertron.request_slot_count
   local slots_nil_counter = 0
   local slots_found = 0
   local current_slot = nil
   local slot_id = 0

   --Find non-empty request slots
   while slots_nil_counter < slots_max_count do
      slot_id = slot_id + 1
      current_slot = spidertron.get_vehicle_logistic_slot(slot_id)
      if current_slot == nil or current_slot.name == nil then
         slots_nil_counter = slots_nil_counter + 1
      else
         slot_founds = slots_found + 1
      end
   end

   return slots_found
end

local function player_logistic_request_increment_min(item_stack, pindex)
   local p = game.get_player(pindex)
   local current_slot = nil
   local correct_slot_id = nil

   --Check if logistics have been researched
   for i, tech in pairs(game.get_player(pindex).force.technologies) do
      if tech.name == "logistic-robotics" and not tech.researched then
         printout("Error: You need to research logistic robotics to use this feature.", pindex)
         return
      end
   end

   --Find the correct request slot for this item
   local correct_slot_id = get_personal_logistic_slot_index(item_stack, pindex)

   if correct_slot_id == -1 then
      printout("Error: No empty slots available for this request", pindex)
      return false
   elseif correct_slot_id == nil or correct_slot_id < 1 then
      printout("Error: Invalid slot ID", pindex)
      return false
   end

   --Read the correct slot id value, increment it, set it
   current_slot = p.get_personal_logistic_slot(correct_slot_id)
   if current_slot == nil or current_slot.name == nil then
      --Create a fresh request
      local new_slot = { name = item_stack.name, min = 1, max = nil }
      p.set_personal_logistic_slot(correct_slot_id, new_slot)
   else
      --Update existing request
      local stack_size = 1
      if item_stack.object_name == "LuaItemStack" then
         stack_size = item_stack.prototype.stack_size
      elseif item_stack.object_name == "LuaItemPrototype" then
         stack_size = item_stack.stack_size
      end
      current_slot.min = increment_logistic_request_min_amount(stack_size, current_slot.min)
      --Force min <= max
      if current_slot.min ~= nil and current_slot.max ~= nil and current_slot.min > current_slot.max then
         printout("Error: Minimum request value cannot exceed maximum", pindex)
         return
      end
      p.set_personal_logistic_slot(correct_slot_id, current_slot)
   end

   --Read new status
   mod.player_logistic_request_read(item_stack, pindex, false)
end

local function player_logistic_request_decrement_min(item_stack, pindex)
   local p = game.get_player(pindex)
   local current_slot = nil
   local correct_slot_id = nil

   --Check if logistics have been researched
   for i, tech in pairs(game.get_player(pindex).force.technologies) do
      if tech.name == "logistic-robotics" and not tech.researched then
         printout("Error: You need to research logistic robotics to use this feature.", pindex)
         return
      end
   end

   --Find the correct request slot for this item
   local correct_slot_id = get_personal_logistic_slot_index(item_stack, pindex)

   if correct_slot_id == -1 then
      printout("Error: No empty slots available for this request", pindex)
      return false
   elseif correct_slot_id == nil or correct_slot_id < 1 then
      printout("Error: Invalid slot ID", pindex)
      return false
   end

   --Read the correct slot id value, decrement it, set it
   current_slot = p.get_personal_logistic_slot(correct_slot_id)
   if current_slot == nil or current_slot.name == nil then
      --Create a fresh request
      local new_slot = { name = item_stack.name, min = 0, max = nil }
      p.set_personal_logistic_slot(correct_slot_id, new_slot)
   else
      --Update existing request
      local stack_size = 1
      if item_stack.object_name == "LuaItemStack" then
         stack_size = item_stack.prototype.stack_size
      elseif item_stack.object_name == "LuaItemPrototype" then
         stack_size = item_stack.stack_size
      end
      current_slot.min = decrement_logistic_request_min_amount(stack_size, current_slot.min)
      --Force min <= max
      if current_slot.min ~= nil and current_slot.max ~= nil and current_slot.min > current_slot.max then
         printout("Error: Minimum request value cannot exceed maximum", pindex)
         return
      end
      p.set_personal_logistic_slot(correct_slot_id, current_slot)
   end

   --Read new status
   mod.player_logistic_request_read(item_stack, pindex)
end

local function player_logistic_request_increment_max(item_stack, pindex)
   local p = game.get_player(pindex)
   local current_slot = nil
   local correct_slot_id = nil

   --Check if logistics have been researched
   for i, tech in pairs(game.get_player(pindex).force.technologies) do
      if tech.name == "logistic-robotics" and not tech.researched then
         printout("Error: You need to research logistic robotics to use this feature.", pindex)
         return
      end
   end

   --Find the correct request slot for this item
   correct_slot_id = get_personal_logistic_slot_index(item_stack, pindex)

   if correct_slot_id == -1 then
      printout("Error: No empty slots available for this request", pindex)
      return false
   elseif correct_slot_id == nil or correct_slot_id < 1 then
      printout("Error: Invalid slot ID", pindex)
      return false
   end

   --Read the correct slot id value, decrement it, set it
   current_slot = p.get_personal_logistic_slot(correct_slot_id)
   local stack_size = 1
   if item_stack.object_name == "LuaItemStack" then
      stack_size = item_stack.prototype.stack_size
   elseif item_stack.object_name == "LuaItemPrototype" then
      stack_size = item_stack.stack_size
   end
   if current_slot == nil or current_slot.name == nil then
      --Create a fresh request
      local new_slot = { name = item_stack.name, min = 0, max = MAX_STACK_COUNT * stack_size }
      p.set_personal_logistic_slot(correct_slot_id, new_slot)
   else
      --Update existing request
      current_slot.max = increment_logistic_request_max_amount(stack_size, current_slot.max)
      --Force min <= max
      if current_slot.min ~= nil and current_slot.max ~= nil and current_slot.min > current_slot.max then
         printout("Error: Minimum request value cannot exceed maximum", pindex)
         return
      end
      p.set_personal_logistic_slot(correct_slot_id, current_slot)
   end

   --Read new status
   mod.player_logistic_request_read(item_stack, pindex)
end

local function player_logistic_request_decrement_max(item_stack, pindex)
   local p = game.get_player(pindex)
   local current_slot = nil
   local correct_slot_id = nil

   --Check if logistics have been researched
   for i, tech in pairs(game.get_player(pindex).force.technologies) do
      if tech.name == "logistic-robotics" and not tech.researched then
         printout("Error: You need to research logistic robotics to use this feature.", pindex)
         return
      end
   end

   --Find the correct request slot for this item
   correct_slot_id = get_personal_logistic_slot_index(item_stack, pindex)

   if correct_slot_id == -1 then
      printout("Error: No empty slots available for this request", pindex)
      return false
   elseif correct_slot_id == nil or correct_slot_id < 1 then
      printout("Error: Invalid slot ID", pindex)
      return false
   end

   --Read the correct slot id value, increment it, set it
   current_slot = p.get_personal_logistic_slot(correct_slot_id)

   local stack_size = 1
   if item_stack.object_name == "LuaItemStack" then
      stack_size = item_stack.prototype.stack_size
   elseif item_stack.object_name == "LuaItemPrototype" then
      stack_size = item_stack.stack_size
   end
   if current_slot == nil or current_slot.name == nil then
      --Create a fresh request
      local new_slot = { name = item_stack.name, min = 0, max = MAX_STACK_COUNT * stack_size }
      p.set_personal_logistic_slot(correct_slot_id, new_slot)
   else
      --Update existing request
      current_slot.max = decrement_logistic_request_max_amount(stack_size, current_slot.max)
      --Force min <= max
      if current_slot.min ~= nil and current_slot.max ~= nil and current_slot.min > current_slot.max then
         printout("Error: Minimum request value cannot exceed maximum", pindex)
         return
      end
      p.set_personal_logistic_slot(correct_slot_id, current_slot)
   end

   --Read new status
   mod.player_logistic_request_read(item_stack, pindex, false)
end

--Clears a logistic request entirely
local function player_logistic_request_clear(item_stack, pindex)
   local p = game.get_player(pindex)
   local current_slot = nil
   local correct_slot_id = nil

   --Check if logistics have been researched
   for i, tech in pairs(game.get_player(pindex).force.technologies) do
      if tech.name == "logistic-robotics" and not tech.researched then
         printout("Error: You need to research logistic robotics to use this feature.", pindex)
         return
      end
   end

   --Find the correct request slot for this item
   correct_slot_id = get_personal_logistic_slot_index(item_stack, pindex)

   if correct_slot_id == -1 then
      printout("Error: No empty slots available for this request", pindex)
      return false
   elseif correct_slot_id == nil or correct_slot_id < 1 then
      printout("Error: Invalid slot ID", pindex)
      return false
   end

   --Read the correct slot id value, increment it, set it
   current_slot = p.get_personal_logistic_slot(correct_slot_id)

   if current_slot == nil or current_slot.name == nil then
      --(done)
   else
      --Clear this request
      p.clear_personal_logistic_slot(correct_slot_id)
   end

   --Read new status
   printout("Request cleared", pindex)
end

--Finds or assigns the logistic request slot for the item, for chests or vehicles
local function get_entity_logistic_slot_index(item_stack, chest)
   local slots_max_count = chest.request_slot_count
   local slot_found = false
   local current_slot = nil
   local correct_slot_id = nil
   local slot_id = 0

   --Find the correct request slot for this item, if any
   while not slot_found and slot_id < slots_max_count do
      slot_id = slot_id + 1
      current_slot = chest.get_request_slot(slot_id)
      if current_slot == nil or current_slot.name == nil then
         --do nothing
      elseif current_slot.name == item_stack.name then
         slot_found = true
         correct_slot_id = slot_id
      else
         --do nothing
      end
   end

   --If needed, find the first empty slot and set it as the correct one
   if not slot_found then
      slot_id = 0
      while not slot_found and slot_id < 100 do
         slot_id = slot_id + 1
         current_slot = chest.get_request_slot(slot_id)
         if current_slot == nil or current_slot.name == nil then
            slot_found = true
            correct_slot_id = slot_id
         else
            --do nothing
         end
      end
   end

   --If no correct or empty slots found then return with error (all slots full)
   if not slot_found then return -1 end

   return correct_slot_id
end

--Increments min value
local function chest_logistic_request_increment_min(item_stack, chest, pindex)
   local current_slot = nil
   local correct_slot_id = nil

   --Check if logistics have been researched
   for i, tech in pairs(game.get_player(pindex).force.technologies) do
      if tech.name == "logistic-system" and not tech.researched then
         printout("Error: You need to research logistic system, with utility science, to use this feature.", pindex)
         return
      end
   end

   --Find the correct request slot for this item
   correct_slot_id = get_entity_logistic_slot_index(item_stack, chest)

   if correct_slot_id == -1 then
      printout("Error: No empty slots available for this request", pindex)
      return false
   elseif correct_slot_id == nil or correct_slot_id < 1 then
      printout("Error: Invalid slot ID", pindex)
      return false
   end

   --Read the correct slot id value, increment it, set it
   current_slot = chest.get_request_slot(correct_slot_id)
   local stack_size = 1
   if item_stack.object_name == "LuaItemStack" then
      stack_size = item_stack.prototype.stack_size
   elseif item_stack.object_name == "LuaItemPrototype" then
      stack_size = item_stack.stack_size
   end
   if current_slot == nil or current_slot.name == nil then
      --Create a fresh request
      local new_slot = { name = item_stack.name, count = stack_size }
      chest.set_request_slot(new_slot, correct_slot_id)
   else
      --Update existing request
      current_slot.count = increment_logistic_request_min_amount(stack_size, current_slot.count)
      chest.set_request_slot(current_slot, correct_slot_id)
   end

   --Read new status
   mod.chest_logistic_request_read(item_stack, chest, pindex)
end

--Decrements min value
local function chest_logistic_request_decrement_min(item_stack, chest, pindex)
   local current_slot = nil
   local correct_slot_id = nil

   --Check if logistics have been researched
   for i, tech in pairs(game.get_player(pindex).force.technologies) do
      if tech.name == "logistic-system" and not tech.researched then
         printout("Error: You need to research logistic system, with utility science, to use this feature.", pindex)
         return
      end
   end

   --Find the correct request slot for this item
   correct_slot_id = get_entity_logistic_slot_index(item_stack, chest)

   if correct_slot_id == -1 then
      printout("Error: No empty slots available for this request", pindex)
      return false
   elseif correct_slot_id == nil or correct_slot_id < 1 then
      printout("Error: Invalid slot ID", pindex)
      return false
   end

   --Read the correct slot id value, decrement it, set it
   current_slot = chest.get_request_slot(correct_slot_id)
   local stack_size = 1
   if item_stack.object_name == "LuaItemStack" then
      stack_size = item_stack.prototype.stack_size
   elseif item_stack.object_name == "LuaItemPrototype" then
      stack_size = item_stack.stack_size
   end
   if current_slot == nil or current_slot.name == nil then
      --Create a fresh request
      local new_slot = { name = item_stack.name, count = stack_size }
      chest.set_request_slot(new_slot, correct_slot_id)
   else
      --Update existing request
      current_slot.count = decrement_logistic_request_min_amount(stack_size, current_slot.count)
      if current_slot.count == nil or current_slot.count == 0 then
         chest.clear_request_slot(correct_slot_id)
      else
         chest.set_request_slot(current_slot, correct_slot_id)
      end
   end

   --Read new status
   mod.chest_logistic_request_read(item_stack, chest, pindex)
end

--Clears a logistic request entirely
local function chest_logistic_request_clear(item_stack, chest, pindex)
   local current_slot = nil
   local correct_slot_id = nil

   --Check if logistics have been researched
   for i, tech in pairs(game.get_player(pindex).force.technologies) do
      if tech.name == "logistic-system" and not tech.researched then
         printout("Error: You need to research logistic system, with utility science, to use this feature.", pindex)
         return
      end
   end

   --Find the correct request slot for this item
   correct_slot_id = get_entity_logistic_slot_index(item_stack, chest)

   if correct_slot_id == -1 then
      printout("Error: No empty slots available for this request", pindex)
      return false
   elseif correct_slot_id == nil or correct_slot_id < 1 then
      printout("Error: Invalid slot ID", pindex)
      return false
   end

   --Read the correct slot id value, increment it, set it
   current_slot = chest.get_request_slot(correct_slot_id)
   if current_slot == nil or current_slot.name == nil then
      --(done))
   else
      --Clear this request
      chest.clear_request_slot(correct_slot_id)
   end

   --Read new status
   printout("Request cleared", pindex)
end

local function spidertron_logistic_request_increment_min(item_stack, spidertron, pindex)
   local current_slot = nil
   local correct_slot_id = nil

   --Check if logistics have been researched
   for i, tech in pairs(game.get_player(pindex).force.technologies) do
      if tech.name == "logistic-robotics" and not tech.researched then
         printout("Error: You need to research logistic robotics to use this feature.", pindex)
         return
      end
   end

   --Find the correct request slot for this item
   correct_slot_id = get_entity_logistic_slot_index(item_stack, spidertron)

   if correct_slot_id == -1 then
      printout("Error: No empty slots available for this request", pindex)
      return false
   elseif correct_slot_id == nil or correct_slot_id < 1 then
      printout("Error: Invalid slot ID", pindex)
      return false
   end

   --Read the correct slot id value, increment it, set it
   current_slot = spidertron.get_vehicle_logistic_slot(correct_slot_id)
   if current_slot == nil or current_slot.name == nil then
      --Create a fresh request
      local new_slot = { name = item_stack.name, min = 1, max = nil }
      spidertron.set_vehicle_logistic_slot(correct_slot_id, new_slot)
   else
      --Update existing request
      local stack_size = 1
      if item_stack.object_name == "LuaItemStack" then
         stack_size = item_stack.prototype.stack_size
      elseif item_stack.object_name == "LuaItemPrototype" then
         stack_size = item_stack.stack_size
      end
      current_slot.min = increment_logistic_request_min_amount(stack_size, current_slot.min)
      --Force min <= max
      if current_slot.min ~= nil and current_slot.max ~= nil and current_slot.min > current_slot.max then
         printout("Error: Minimum request value cannot exceed maximum", pindex)
         return
      end
      spidertron.set_vehicle_logistic_slot(correct_slot_id, current_slot)
   end

   --Read new status
   mod.spidertron_logistic_request_read(item_stack, spidertron, pindex, false)
end

local function spidertron_logistic_request_decrement_min(item_stack, spidertron, pindex)
   local current_slot = nil
   local correct_slot_id = nil

   --Check if logistics have been researched
   for i, tech in pairs(game.get_player(pindex).force.technologies) do
      if tech.name == "logistic-robotics" and not tech.researched then
         printout("Error: You need to research logistic robotics to use this feature.", pindex)
         return
      end
   end

   --Find the correct request slot for this item
   correct_slot_id = get_entity_logistic_slot_index(item_stack, spidertron)

   if correct_slot_id == -1 then
      printout("Error: No empty slots available for this request", pindex)
      return false
   elseif correct_slot_id == nil or correct_slot_id < 1 then
      printout("Error: Invalid slot ID", pindex)
      return false
   end

   --Read the correct slot id value, decrement it, set it
   current_slot = spidertron.get_vehicle_logistic_slot(correct_slot_id)
   if current_slot == nil or current_slot.name == nil then
      --Create a fresh request
      local new_slot = { name = item_stack.name, min = 0, max = nil }
      spidertron.set_vehicle_logistic_slot(correct_slot_id, new_slot)
   else
      --Update existing request
      local stack_size = 1
      if item_stack.object_name == "LuaItemStack" then
         stack_size = item_stack.prototype.stack_size
      elseif item_stack.object_name == "LuaItemPrototype" then
         stack_size = item_stack.stack_size
      end
      current_slot.min = decrement_logistic_request_min_amount(stack_size, current_slot.min)
      --Force min <= max
      if current_slot.min ~= nil and current_slot.max ~= nil and current_slot.min > current_slot.max then
         printout("Error: Minimum request value cannot exceed maximum", pindex)
         return
      end
      spidertron.set_vehicle_logistic_slot(correct_slot_id, current_slot)
   end

   --Read new status
   mod.spidertron_logistic_request_read(item_stack, spidertron, pindex, false)
end

local function spidertron_logistic_request_increment_max(item_stack, spidertron, pindex)
   local current_slot = nil
   local correct_slot_id = nil

   --Check if logistics have been researched
   for i, tech in pairs(game.get_player(pindex).force.technologies) do
      if tech.name == "logistic-robotics" and not tech.researched then
         printout("Error: You need to research logistic robotics to use this feature.", pindex)
         return
      end
   end

   --Find the correct request slot for this item
   correct_slot_id = get_entity_logistic_slot_index(item_stack, spidertron)

   if correct_slot_id == -1 then
      printout("Error: No empty slots available for this request", pindex)
      return false
   elseif correct_slot_id == nil or correct_slot_id < 1 then
      printout("Error: Invalid slot ID", pindex)
      return false
   end

   --Read the correct slot id value, decrement it, set it
   current_slot = spidertron.get_vehicle_logistic_slot(correct_slot_id)
   local stack_size = 1
   if item_stack.object_name == "LuaItemStack" then
      stack_size = item_stack.prototype.stack_size
   elseif item_stack.object_name == "LuaItemPrototype" then
      stack_size = item_stack.stack_size
   end
   if current_slot == nil or current_slot.name == nil then
      --Create a fresh request
      local new_slot = { name = item_stack.name, min = 0, max = MAX_STACK_COUNT * stack_size }
      spidertron.set_vehicle_logistic_slot(correct_slot_id, new_slot)
   else
      --Update existing request
      current_slot.max = increment_logistic_request_max_amount(stack_size, current_slot.max)
      --Force min <= max
      if current_slot.min ~= nil and current_slot.max ~= nil and current_slot.min > current_slot.max then
         printout("Error: Minimum request value cannot exceed maximum", pindex)
         return
      end
      spidertron.set_vehicle_logistic_slot(correct_slot_id, current_slot)
   end

   --Read new status
   mod.spidertron_logistic_request_read(item_stack, spidertron, pindex, false)
end

local function spidertron_logistic_request_decrement_max(item_stack, spidertron, pindex)
   local current_slot = nil
   local correct_slot_id = nil

   --Check if logistics have been researched
   for i, tech in pairs(game.get_player(pindex).force.technologies) do
      if tech.name == "logistic-robotics" and not tech.researched then
         printout("Error: You need to research logistic robotics to use this feature.", pindex)
         return
      end
   end

   --Find the correct request slot for this item
   correct_slot_id = get_entity_logistic_slot_index(item_stack, spidertron)

   if correct_slot_id == -1 then
      printout("Error: No empty slots available for this request", pindex)
      return false
   elseif correct_slot_id == nil or correct_slot_id < 1 then
      printout("Error: Invalid slot ID", pindex)
      return false
   end

   --Read the correct slot id value, increment it, set it
   current_slot = spidertron.get_vehicle_logistic_slot(correct_slot_id)
   local stack_size = 1
   if item_stack.object_name == "LuaItemStack" then
      stack_size = item_stack.prototype.stack_size
   elseif item_stack.object_name == "LuaItemPrototype" then
      stack_size = item_stack.stack_size
   end
   if current_slot == nil or current_slot.name == nil then
      --Create a fresh request
      local new_slot = { name = item_stack.name, min = 0, max = MAX_STACK_COUNT * stack_size }
      spidertron.set_vehicle_logistic_slot(correct_slot_id, new_slot)
   else
      --Update existing request
      current_slot.max = decrement_logistic_request_max_amount(stack_size, current_slot.max)
      --Force min <= max
      if current_slot.min ~= nil and current_slot.max ~= nil and current_slot.min > current_slot.max then
         printout("Error: Minimum request value cannot exceed maximum", pindex)
         return
      end
      spidertron.set_vehicle_logistic_slot(correct_slot_id, current_slot)
   end

   --Read new status
   mod.spidertron_logistic_request_read(item_stack, spidertron, pindex, false)
end

--Clears a logistic request entirely
local function spidertron_logistic_request_clear(item_stack, spidertron, pindex)
   local current_slot = nil
   local correct_slot_id = nil

   --Check if logistics have been researched
   for i, tech in pairs(game.get_player(pindex).force.technologies) do
      if tech.name == "logistic-robotics" and not tech.researched then
         printout("Error: You need to research logistic robotics to use this feature.", pindex)
         return
      end
   end

   --Find the correct request slot for this item
   correct_slot_id = get_entity_logistic_slot_index(item_stack, spidertron)

   if correct_slot_id == -1 then
      printout("Error: No empty slots available for this request", pindex)
      return false
   elseif correct_slot_id == nil or correct_slot_id < 1 then
      printout("Error: Invalid slot ID", pindex)
      return false
   end

   --Read the correct slot id value, increment it, set it
   current_slot = spidertron.get_vehicle_logistic_slot(correct_slot_id)
   if current_slot == nil or current_slot.name == nil then
      --(done)
   else
      --Clear this request
      spidertron.clear_vehicle_logistic_slot(correct_slot_id)
   end

   --Read new status
   printout("Request cleared", pindex)
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
      elseif players[pindex].menu == "inventory" and stack_inv and stack_inv.valid_for_read and stack_inv.valid then
         --Item in inv
         mod.player_logistic_request_read(stack_inv, pindex, true)
      elseif players[pindex].menu == "player_trash" and stack_tra and stack_tra.valid_for_read and stack_tra.valid then
         stack_tra =
            p.get_inventory(defines.inventory.character_trash)[players[pindex].inventory.index]
         mod.player_logistic_request_read(stack_tra, pindex, true)
      elseif players[pindex].menu == "crafting" then
         --Use the first found item product of the selected recipe, pass it as a stack
         local prototype = fa_utils.get_prototype_of_item_product(pindex)
         if prototype then mod.player_logistic_request_read(prototype, pindex, true) end
      else
         --Logistic chest in front
         local ent = p.selected
         if mod.can_make_logistic_requests(ent) then
            mod.read_entity_requests_summary(ent, pindex)
            return
         elseif mod.can_set_logistic_filter(ent) then
            local filter = ent.storage_filter
            local result = "Nothing"
            if filter ~= nil then result = filter.name end
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
      --Check item in hand or item in inventory
      if stack ~= nil and stack.valid_for_read and stack.valid then
         --Item in hand
         mod.chest_logistic_request_read(stack, chest, pindex)
      elseif stack_inv ~= nil and stack_inv.valid_for_read and stack_inv.valid then
         --Item in output inv
         mod.chest_logistic_request_read(stack_inv, chest, pindex)
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
      --Check item in hand or item in inventory
      if stack ~= nil and stack.valid_for_read and stack.valid then
         --Item in hand
         mod.spidertron_logistic_request_read(stack, spidertron, pindex, true)
      elseif stack_inv ~= nil and stack_inv.valid_for_read and stack_inv.valid then
         --Item in output inv
         mod.spidertron_logistic_request_read(stack_inv, spidertron, pindex, true)
      else
         --Empty hand, empty inventory slot
         mod.read_entity_requests_summary(spidertron, pindex)
      end
   elseif players[pindex].menu == "building" and mod.can_set_logistic_filter(p.opened) then
      local filter = p.opened.storage_filter
      local result = "Nothing"
      if filter ~= nil then result = filter.name end
      printout(result .. " set as logistic storage filter", pindex)
   elseif players[pindex].menu == "building" then
      printout("Logistic requests not supported for this building", pindex)
   else
      printout("No logistics summary available in this menu", pindex)
   end
end

--Call the appropriate function after a keypress for modifying a logistic request
function mod.logistics_request_increment_min_handler(pindex)
   if
      not players[pindex].in_menu
      or players[pindex].menu == "inventory"
      or players[pindex].menu == "player_trash"
      or players[pindex].menu == "crafting"
   then
      --Personal logistics
      local stack = game.get_player(pindex).cursor_stack
      local stack_inv = game.get_player(pindex).get_main_inventory()[players[pindex].inventory.index]
      --Check item in hand or item in inventory
      if stack ~= nil and stack.valid_for_read and stack.valid then
         --Item in hand
         player_logistic_request_increment_min(stack, pindex)
      elseif
         players[pindex].menu == "inventory"
         and stack_inv ~= nil
         and stack_inv.valid_for_read
         and stack_inv.valid
      then
         --Item in inv
         player_logistic_request_increment_min(stack_inv, pindex)
      elseif players[pindex].menu == "player_trash" then
         --Item in trash
         printout("Take this item in hand to change its requests", pindex)
      elseif players[pindex].menu == "crafting" then
         --Use the first found item product of the selected recipe, pass it as a stack
         local prototype = fa_utils.get_prototype_of_item_product(pindex)
         if prototype then player_logistic_request_increment_min(prototype, pindex) end
      else
         --Empty hand, empty inventory slot
         --(do nothing)
      end
   elseif players[pindex].menu == "building" and mod.can_make_logistic_requests(game.get_player(pindex).opened) then
      --Chest logistics
      local stack = game.get_player(pindex).cursor_stack
      local stack_inv = game.get_player(pindex).opened.get_output_inventory()[players[pindex].building.index]
      local chest = game.get_player(pindex).opened
      --Check item in hand or item in inventory
      if stack ~= nil and stack.valid_for_read and stack.valid then
         --Item in hand
         chest_logistic_request_increment_min(stack, chest, pindex)
      elseif stack_inv ~= nil and stack_inv.valid_for_read and stack_inv.valid then
         --Item in output inv
         chest_logistic_request_increment_min(stack_inv, chest, pindex)
      else
         --Empty hand, empty inventory slot
         printout("No actions", pindex)
      end
   elseif players[pindex].menu == "vehicle" and mod.can_make_logistic_requests(game.get_player(pindex).opened) then
      --spidertron logistics
      local stack = game.get_player(pindex).cursor_stack
      local invs = defines.inventory
      local stack_inv = game.get_player(pindex).opened.get_inventory(invs.spider_trunk)[players[pindex].building.index]
      local spidertron = game.get_player(pindex).opened
      --Check item in hand or item in inventory
      if stack ~= nil and stack.valid_for_read and stack.valid then
         --Item in hand
         spidertron_logistic_request_increment_min(stack, spidertron, pindex)
      elseif stack_inv ~= nil and stack_inv.valid_for_read and stack_inv.valid then
         --Item in output inv
         spidertron_logistic_request_increment_min(stack_inv, spidertron, pindex)
      else
         --Empty hand, empty inventory slot
         printout("No actions", pindex)
      end
   elseif players[pindex].menu == "building" and mod.can_set_logistic_filter(game.get_player(pindex).opened) then
      --Chest logistics
      local stack = game.get_player(pindex).cursor_stack
      local stack_inv = game.get_player(pindex).opened.get_output_inventory()[players[pindex].building.index]
      local chest = game.get_player(pindex).opened
      --Check item in hand or item in inventory
      if stack ~= nil and stack.valid_for_read and stack.valid then
         --Item in hand
         mod.set_logistic_filter(stack, chest, pindex)
      elseif stack_inv ~= nil and stack_inv.valid_for_read and stack_inv.valid then
         --Item in output inv
         mod.set_logistic_filter(stack_inv, chest, pindex)
      else
         --Empty hand, empty inventory slot
         mod.set_logistic_filter(nil, chest, pindex)
      end
   elseif players[pindex].menu == "building" then
      printout("Logistic requests not supported for this building", pindex)
   else
      --Other menu
      printout("No actions", pindex)
   end
end

--Call the appropriate function after a keypress for modifying a logistic request
function mod.logistics_request_decrement_min_handler(pindex)
   if
      not players[pindex].in_menu
      or players[pindex].menu == "inventory"
      or players[pindex].menu == "player_trash"
      or players[pindex].menu == "crafting"
   then
      --Personal logistics
      local stack = game.get_player(pindex).cursor_stack
      local stack_inv = game.get_player(pindex).get_main_inventory()[players[pindex].inventory.index]
      --Check item in hand or item in inventory
      if stack ~= nil and stack.valid_for_read and stack.valid then
         --Item in hand
         player_logistic_request_decrement_min(stack, pindex)
      elseif
         players[pindex].menu == "inventory"
         and stack_inv ~= nil
         and stack_inv.valid_for_read
         and stack_inv.valid
      then
         --Item in inv
         player_logistic_request_decrement_min(stack_inv, pindex)
      elseif players[pindex].menu == "player_trash" then
         --Item in trash
         printout("Take this item in hand to change its requests", pindex)
      elseif players[pindex].menu == "crafting" then
         --Use the first found item product of the selected recipe, pass it as a stack
         local prototype = fa_utils.get_prototype_of_item_product(pindex)
         if prototype then player_logistic_request_decrement_min(prototype, pindex) end
      else
         --Empty hand, empty inventory slot
         --(do nothing)
      end
   elseif players[pindex].menu == "building" and mod.can_make_logistic_requests(game.get_player(pindex).opened) then
      --Chest logistics
      local stack = game.get_player(pindex).cursor_stack
      local stack_inv = game.get_player(pindex).opened.get_output_inventory()[players[pindex].building.index]
      local chest = game.get_player(pindex).opened
      --Check item in hand or item in inventory
      if stack ~= nil and stack.valid_for_read and stack.valid then
         --Item in hand
         chest_logistic_request_decrement_min(stack, chest, pindex)
      elseif stack_inv ~= nil and stack_inv.valid_for_read and stack_inv.valid then
         --Item in output inv
         chest_logistic_request_decrement_min(stack_inv, chest, pindex)
      else
         --Empty hand, empty inventory slot
         printout("No actions", pindex)
      end
   elseif players[pindex].menu == "vehicle" and mod.can_make_logistic_requests(game.get_player(pindex).opened) then
      --spidertron logistics
      local stack = game.get_player(pindex).cursor_stack
      local invs = defines.inventory
      local stack_inv = game.get_player(pindex).opened.get_inventory(invs.spider_trunk)[players[pindex].building.index]
      local spidertron = game.get_player(pindex).opened
      --Check item in hand or item in inventory
      if stack ~= nil and stack.valid_for_read and stack.valid then
         --Item in hand
         spidertron_logistic_request_decrement_min(stack, spidertron, pindex)
      elseif stack_inv ~= nil and stack_inv.valid_for_read and stack_inv.valid then
         --Item in output inv
         spidertron_logistic_request_decrement_min(stack_inv, spidertron, pindex)
      else
         --Empty hand, empty inventory slot
         printout("No actions", pindex)
      end
   elseif players[pindex].menu == "building" and mod.can_set_logistic_filter(game.get_player(pindex).opened) then
      --Chest logistics
      local stack = game.get_player(pindex).cursor_stack
      local stack_inv = game.get_player(pindex).opened.get_output_inventory()[players[pindex].building.index]
      local chest = game.get_player(pindex).opened
      --Check item in hand or item in inventory
      if stack ~= nil and stack.valid_for_read and stack.valid then
         --Item in hand
         mod.set_logistic_filter(stack, chest, pindex)
      elseif stack_inv ~= nil and stack_inv.valid_for_read and stack_inv.valid then
         --Item in output inv
         mod.set_logistic_filter(stack, chest, pindex)
      else
         --Empty hand, empty inventory slot
         mod.set_logistic_filter(nil, chest, pindex)
      end
   elseif players[pindex].menu == "building" then
      printout("Logistic requests not supported for this building", pindex)
   else
      --Other menu
      printout("No actions", pindex)
   end
end

--Call the appropriate function after a keypress for modifying a logistic request
function mod.logistics_request_increment_max_handler(pindex)
   if
      not players[pindex].in_menu
      or players[pindex].menu == "inventory"
      or players[pindex].menu == "player_trash"
      or players[pindex].menu == "crafting"
   then
      --Personal logistics
      local stack = game.get_player(pindex).cursor_stack
      local stack_inv = game.get_player(pindex).get_main_inventory()[players[pindex].inventory.index]
      --Check item in hand or item in inventory
      if stack ~= nil and stack.valid_for_read and stack.valid then
         --Item in hand
         player_logistic_request_increment_max(stack, pindex)
      elseif
         players[pindex].menu == "inventory"
         and stack_inv ~= nil
         and stack_inv.valid_for_read
         and stack_inv.valid
      then
         --Item in inv
         player_logistic_request_increment_max(stack_inv, pindex)
      elseif players[pindex].menu == "player_trash" then
         --Item in trash
         printout("Take this item in hand to change its requests", pindex)
      elseif players[pindex].menu == "crafting" then
         --Use the first found item product of the selected recipe, pass it as a stack
         local prototype = fa_utils.get_prototype_of_item_product(pindex)
         if prototype then player_logistic_request_increment_max(prototype, pindex) end
      else
         --Empty hand, empty inventory slot
         --(do nothing)
      end
   elseif players[pindex].menu == "vehicle" and mod.can_make_logistic_requests(game.get_player(pindex).opened) then
      --spidertron logistics
      local stack = game.get_player(pindex).cursor_stack
      local invs = defines.inventory
      local stack_inv = game.get_player(pindex).opened.get_inventory(invs.spider_trunk)[players[pindex].building.index]
      local spidertron = game.get_player(pindex).opened
      --Check item in hand or item in inventory
      if stack ~= nil and stack.valid_for_read and stack.valid then
         --Item in hand
         spidertron_logistic_request_increment_max(stack, spidertron, pindex)
      elseif stack_inv ~= nil and stack_inv.valid_for_read and stack_inv.valid then
         --Item in output inv
         spidertron_logistic_request_increment_max(stack_inv, spidertron, pindex)
      else
         --Empty hand, empty inventory slot
         printout("No actions", pindex)
      end
   else
      --Other menu
      --(do nothing)
   end
end

--Call the appropriate function after a keypress for modifying a logistic request
function mod.logistics_request_decrement_max_handler(pindex)
   if
      not players[pindex].in_menu
      or players[pindex].menu == "inventory"
      or players[pindex].menu == "player_trash"
      or players[pindex].menu == "crafting"
   then
      --Personal logistics
      local stack = game.get_player(pindex).cursor_stack
      local stack_inv = game.get_player(pindex).get_main_inventory()[players[pindex].inventory.index]
      --Check item in hand or item in inventory
      if stack ~= nil and stack.valid_for_read and stack.valid then
         --Item in hand
         player_logistic_request_decrement_max(stack, pindex)
      elseif
         players[pindex].menu == "inventory"
         and stack_inv ~= nil
         and stack_inv.valid_for_read
         and stack_inv.valid
      then
         --Item in inv
         player_logistic_request_decrement_max(stack_inv, pindex)
      elseif players[pindex].menu == "player_trash" then
         --Item in trash
         printout("Take this item in hand to change its requests", pindex)
      elseif players[pindex].menu == "crafting" then
         --Use the first found item product of the selected recipe, pass it as a stack
         local prototype = fa_utils.get_prototype_of_item_product(pindex)
         if prototype then player_logistic_request_decrement_max(prototype, pindex) end
      else
         --Empty hand, empty inventory slot
         --(do nothing)
      end
   elseif players[pindex].menu == "vehicle" and mod.can_make_logistic_requests(game.get_player(pindex).opened) then
      --spidertron logistics
      local stack = game.get_player(pindex).cursor_stack
      local invs = defines.inventory
      local stack_inv = game.get_player(pindex).opened.get_inventory(invs.spider_trunk)[players[pindex].building.index]
      local spidertron = game.get_player(pindex).opened
      --Check item in hand or item in inventory
      if stack ~= nil and stack.valid_for_read and stack.valid then
         --Item in hand
         spidertron_logistic_request_decrement_max(stack, spidertron, pindex)
      elseif stack_inv ~= nil and stack_inv.valid_for_read and stack_inv.valid then
         --Item in output inv
         spidertron_logistic_request_decrement_max(stack_inv, spidertron, pindex)
      else
         --Empty hand, empty inventory slot
         printout("No actions", pindex)
      end
   else
      --Other menu
      --(do nothing)
   end
end

--Call the appropriate function after a keypress for modifying a logistic request
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
   if
      not players[pindex].in_menu
      or players[pindex].menu == "inventory"
      or players[pindex].menu == "player_trash"
      or players[pindex].menu == "crafting"
   then
      --Personal logistics
      local stack = game.get_player(pindex).cursor_stack
      local stack_inv = game.get_player(pindex).get_main_inventory()[players[pindex].inventory.index]
      --Check item in hand or item in inventory
      if stack ~= nil and stack.valid_for_read and stack.valid then
         --Item in hand
         player_logistic_request_clear(stack, pindex)
      elseif
         players[pindex].menu == "inventory"
         and stack_inv ~= nil
         and stack_inv.valid_for_read
         and stack_inv.valid
      then
         --Item in inv
         player_logistic_request_clear(stack_inv, pindex)
      elseif players[pindex].menu == "player_trash" then
         --Item in trash
         printout("Take this item in hand to change its requests", pindex)
      elseif players[pindex].menu == "crafting" then
         --Use the first found item product of the selected recipe, pass it as a stack
         local prototype = fa_utils.get_prototype_of_item_product(pindex)
         if prototype then player_logistic_request_clear(prototype, pindex) end
      else
         --Empty hand, empty inventory slot
         --(do nothing)
      end
   elseif players[pindex].menu == "building" and mod.can_make_logistic_requests(game.get_player(pindex).opened) then
      --Chest logistics
      local stack = game.get_player(pindex).cursor_stack
      local stack_inv = game.get_player(pindex).opened.get_output_inventory()[players[pindex].building.index]
      local chest = game.get_player(pindex).opened
      --Check item in hand or item in inventory
      if stack ~= nil and stack.valid_for_read and stack.valid then
         --Item in hand
         chest_logistic_request_clear(stack, chest, pindex)
      elseif stack_inv ~= nil and stack_inv.valid_for_read and stack_inv.valid then
         --Item in output inv
         chest_logistic_request_clear(stack_inv, chest, pindex)
      else
         --Empty hand, empty inventory slot
         printout("No actions", pindex)
      end
   elseif players[pindex].menu == "vehicle" and mod.can_make_logistic_requests(game.get_player(pindex).opened) then
      --spidertron logistics
      local stack = game.get_player(pindex).cursor_stack
      local invs = defines.inventory
      local stack_inv = game.get_player(pindex).opened.get_inventory(invs.spider_trunk)[players[pindex].building.index]
      local spidertron = game.get_player(pindex).opened
      --Check item in hand or item in inventory
      if stack ~= nil and stack.valid_for_read and stack.valid then
         --Item in hand
         spidertron_logistic_request_clear(stack, spidertron, pindex)
      elseif stack_inv ~= nil and stack_inv.valid_for_read and stack_inv.valid then
         --Item in output inv
         spidertron_logistic_request_clear(stack_inv, spidertron, pindex)
      else
         --Empty hand, empty inventory slot
         printout("No actions", pindex)
      end
   else
      --Other menu
      --(do nothing)
   end
end

--Returns summary info string
function mod.player_logistic_requests_summary_info(pindex)
   local p = game.get_player(pindex)
   local result = ""

   --1. Check if logistics have been researched
   for i, tech in pairs(game.get_player(pindex).force.technologies) do
      if tech.name == "logistic-robotics" and not tech.researched == true then
         printout("Logistic requests not available, research required.", pindex)
         return
      end
   end

   --2. Check if inside any logistic network or not (simpler than logistics network info)
   local network = p.surface.find_logistic_network_by_position(p.position, p.force)
   if network == nil or not network.valid then
      --Check whether in construction range
      local nearest, min_dist = fa_utils.find_nearest_roboport(p.surface, p.position, 60)
      if nearest == nil or min_dist > 55 then
         result = result .. "Not in a network, "
      else
         result = result .. "In construction range of network " .. nearest.backer_name .. ", "
      end
   else
      --Definitely within range
      local nearest, min_dist = fa_utils.find_nearest_roboport(p.surface, p.position, 30)
      result = result .. "In network " .. nearest.backer_name .. ", "
   end

   --3. Check if personal logistics are enabled
   if not p.character_personal_logistic_requests_enabled then result = result .. "Requests paused, " end

   --4. Count logistics requests
   local req_count = count_active_personal_logistic_slots(pindex)
   result = result .. req_count .. " personal logistic requests set, "

   --5. Count unfulfilled requests and list missing request items
   local unfulfilled_count = 0
   for i = 1, 250 do
      local missing_check = get_player_logistic_request_missing_count(pindex, i)
      if missing_check ~= nil then
         if missing_check > 0 then unfulfilled_count = unfulfilled_count + 1 end
      end
   end
   if unfulfilled_count > 0 then
      result = result .. unfulfilled_count .. " unfulfilled, missing items include "
      for i = 1, 250 do
         local missing_check = get_player_logistic_request_missing_count(pindex, i)
         if missing_check ~= nil then
            if missing_check > 0 then
               local slot_name = p.get_personal_logistic_slot(i).name
               result = result .. missing_check .. " " .. slot_name .. ", "
            end
         end
      end
   else
      result = result .. " all are fulfilled"
   end
   return result
end

--Read the current personal logistics request set for this item
function mod.player_logistic_request_read(item_stack, pindex, additional_checks)
   local p = game.get_player(pindex)
   local current_slot = nil
   local correct_slot_id = nil
   local result = ""

   --Check if logistics have been researched
   for i, tech in pairs(game.get_player(pindex).force.technologies) do
      if tech.name == "logistic-robotics" and not tech.researched then
         printout("Logistic requests not available, research required.", pindex)
         return
      end
   end

   if additional_checks then
      --Check if inside any logistic network or not (simpler than logistics network info)
      local network = p.surface.find_logistic_network_by_position(p.position, p.force)
      if network == nil or not network.valid then result = result .. "Not in a network, " end

      --Check if personal logistics are enabled
      if not p.character_personal_logistic_requests_enabled then result = result .. "Requests paused, " end
   end

   if item_stack == nil or item_stack.valid_for_read == false then 
      printout(result .. "Error: Unknown or missing item", pindex)
      return
   end

   --Find the correct request slot for this item
   local correct_slot_id = get_personal_logistic_slot_index(item_stack, pindex)

   if correct_slot_id == nil or correct_slot_id < 1 then
      printout(result .. "Error: Invalid slot ID", pindex)
      return
   end

   --Read the correct slot id value
   current_slot = p.get_personal_logistic_slot(correct_slot_id)
   if current_slot == nil or current_slot.name == nil then
      --No requests found
      printout(
         result
            .. "No personal logistic requests set for "
            .. item_stack.name
            .. ", use the L key and modifier keys to set requests.",
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
         if item_stack.object_name == "LuaItemStack" then
            stack_size = item_stack.prototype.stack_size
         elseif item_stack.object_name == "LuaItemPrototype" then
            stack_size = item_stack.stack_size
         end

         if current_slot.min ~= nil then
            min_result = fa_utils.express_in_stacks(current_slot.min, stack_size, false) .. " minimum and "
         end

         if current_slot.max ~= nil then
            max_result = fa_utils.express_in_stacks(current_slot.max, stack_size, false) .. " maximum "
         end

         local inv_count = p.get_main_inventory().get_item_count(item_stack.name)
         inv_result = fa_utils.express_in_stacks(inv_count, stack_size, false) .. " in inventory, "

         local trash_count = p.get_inventory(defines.inventory.character_trash).get_item_count(item_stack.name)
         trash_result = fa_utils.express_in_stacks(trash_count, stack_size, false) .. " in personal trash, "

         printout(
            result
               .. min_result
               .. max_result
               .. " requested for "
               .. item_stack.name
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
               .. "No personal logistic requests set for "
               .. item_stack.name
               .. ", use the L key and modifier keys to set requests.",
            pindex
         )
         return
      end
   end
end

--Read the chest's current logistics request set for this item
function mod.chest_logistic_request_read(item_stack, chest, pindex)
   local current_slot = nil
   local correct_slot_id = nil
   local result = ""

   --Check if logistics have been researched
   for i, tech in pairs(game.get_player(pindex).force.technologies) do
      if tech.name == "logistic-system" and not tech.researched then
         printout("Error: You need to research logistic system, with utility science, to use this feature.", pindex)
         return
      end
   end

   --Find the correct request slot for this item
   local correct_slot_id = get_entity_logistic_slot_index(item_stack, chest)

   if correct_slot_id == -1 then
      printout("Error: No empty slots available for this request", pindex)
      return false
   elseif correct_slot_id == nil or correct_slot_id < 1 then
      printout("Error: Invalid slot ID", pindex)
      return false
   end

   --Read the correct slot id value
   current_slot = chest.get_request_slot(correct_slot_id)
   if current_slot == nil or current_slot.name == nil then
      --No requests found
      printout(
         "No logistic requests set for " .. item_stack.name .. ", use the 'L' key and modifier keys to set requests.",
         pindex
      )
      return
   else
      local stack_size = 1
      if item_stack.object_name == "LuaItemStack" then
         stack_size = item_stack.prototype.stack_size
      elseif item_stack.object_name == "LuaItemPrototype" then
         stack_size = item_stack.stack_size
      end
      --Report request counts and inventory counts
      local req_result = ""
      local inv_result = ""

      if current_slot.count ~= nil then
         req_result = fa_utils.express_in_stacks(current_slot.count, stack_size, false)
      end

      local inv_count = chest.get_output_inventory().get_item_count(item_stack.name)
      inv_result = fa_utils.express_in_stacks(inv_count, stack_size, false)

      printout(
         req_result
            .. " requested and "
            .. inv_result
            .. " supplied for "
            .. item_stack.name
            .. ", use the 'L' key and modifier keys to set requests.",
         pindex
      )
      return
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

   --4. Count logistics requests
   result = result .. count_active_spidertron_logistic_slots(pindex) .. " spidertron logistic requests set, "
   return result
end

--Read the current spidertron's logistics request set for this item
function mod.spidertron_logistic_request_read(item_stack, spidertron, pindex, additional_checks)
   local current_slot = nil
   local correct_slot_id = nil
   local result = ""

   --Check if logistics have been researched
   for i, tech in pairs(game.get_player(pindex).force.technologies) do
      if tech.name == "logistic-robotics" and not tech.researched then
         printout("Logistic requests not available, research required.", pindex)
         return
      end
   end

   if additional_checks then
      --Check if inside any logistic network or not (simpler than logistics network info)
      local network = spidertron.surface.find_logistic_network_by_position(spidertron.position, spidertron.force)
      if network == nil or not network.valid then result = result .. "Not in a network, " end

      --Check if personal logistics are enabled
      if not spidertron.vehicle_logistic_requests_enabled then result = result .. "Requests paused, " end
   end

   --Find the correct request slot for this item
   local correct_slot_id = get_entity_logistic_slot_index(item_stack, spidertron)

   if correct_slot_id == nil or correct_slot_id < 1 then
      printout(result .. "Error: Invalid slot ID", pindex)
      return
   end

   --Read the correct slot id value
   current_slot = spidertron.get_vehicle_logistic_slot(correct_slot_id)
   if current_slot == nil or current_slot.name == nil then
      --No requests found
      printout(
         result
            .. "No logistic requests set for "
            .. item_stack.name
            .. " in this spidertron, use the L key and modifier keys to set requests.",
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
         if item_stack.object_name == "LuaItemStack" then
            stack_size = item_stack.prototype.stack_size
         elseif item_stack.object_name == "LuaItemPrototype" then
            stack_size = item_stack.stack_size
         end

         if current_slot.min ~= nil then
            min_result = fa_utils.express_in_stacks(current_slot.min, stack_size, false) .. " minimum and "
         end

         if current_slot.max ~= nil then
            max_result = fa_utils.express_in_stacks(current_slot.max, stack_size, false) .. " maximum "
         end

         local inv_count = spidertron.get_inventory(defines.inventory.spider_trunk).get_item_count(item_stack.name)
         inv_result = fa_utils.express_in_stacks(inv_count, stack_size, false) .. " in inventory, "

         local trash_count = spidertron.get_inventory(defines.inventory.spider_trash).get_item_count(item_stack.name)
         trash_result = fa_utils.express_in_stacks(trash_count, stack_size, false) .. " in spidertron trash, "

         printout(
            result
               .. min_result
               .. max_result
               .. " requested for "
               .. item_stack.name
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
               .. "No spidertron logistic requests set for "
               .. item_stack.name
               .. ", use the L key and modifier keys to set requests.",
            pindex
         )
         return
      end
   end
end

--Logistic requests can be made by chests or spidertrons
function mod.can_make_logistic_requests(ent)
   if ent == nil or ent.valid == false then return false end
   if ent.type == "spider-vehicle" then return true end
   local point = ent.get_logistic_point(defines.logistic_member_index.logistic_container)
   if point == nil or point.valid == false then return false end
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
   if point == nil or point.valid == false then return false end
   if point.mode == defines.logistic_mode.storage then
      return true
   else
      return false
   end
end

function mod.set_logistic_filter(stack, ent, pindex)
   if stack == nil or stack.valid_for_read == false then
      ent.storage_filter = nil
      printout("logistic storage filter cleared", pindex)
      return
   end

   if ent.storage_filter == stack.prototype then
      ent.storage_filter = nil
      printout("logistic storage filter cleared", pindex)
   else
      ent.storage_filter = stack.prototype
      printout(stack.name .. " set as logistic storage filter ", pindex)
   end
end

function mod.read_entity_requests_summary(ent, pindex) --**laterdo improve
   if ent.type == "spider-vehicle" then
      printout(ent.request_slot_count .. " spidertron logistic requests set", pindex)
   else
      printout(ent.request_slot_count .. " chest logistic requests set", pindex)
   end
end

--laterdo** maybe use surf.find_closest_logistic_network_by_position(position, force)

--The idea is that every roboport of the network has the same backer name and this is the networks's name.
function mod.get_network_name(port)
   mod.resolve_network_name(port)
   return port.backer_name
end

--Sets a logistic network's name. The idea is that every roboport of the network has the same backer name and this is the networks's name.
function mod.set_network_name(port, new_name)
   --Rename this port
   if new_name == nil or new_name == "" then return false end
   port.backer_name = new_name
   --Rename the rest, if any
   local nw = port.logistic_network
   if nw == nil then return true end
   local cells = nw.cells
   if cells == nil or cells == {} then return true end
   for i, cell in ipairs(cells) do
      if cell.owner.supports_backer_name then cell.owner.backer_name = new_name end
   end
   return true
end

--Finds the oldest roboport and applies its name across the network. Any built roboport will be newer and so the older names will be kept.
function mod.resolve_network_name(port_in)
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
         local frame = game.get_player(pindex).gui.screen.add({ type = "frame", name = "network-rename" })
         frame.bring_to_front()
         frame.force_auto_center()
         frame.focus()
         --game.get_player(pindex).opened = frame
         local input = frame.add({ type = "textfield", name = "input" })
         input.focus()
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
      else
         if nw ~= nil then
            local result = mod.logistic_network_items_info(port)
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

function mod.logistic_network_items_info(port)
   local result = " Network "
   local nw = port.logistic_cell.logistic_network
   if nw == nil or nw.valid == false then
      result = " Error: no network "
      return result
   end
   local itemset = nw.get_contents()
   local itemtable = {}
   for name, count in pairs(itemset) do
      table.insert(itemtable, { name = name, count = count })
   end
   table.sort(itemtable, function(k1, k2)
      return k1.count > k2.count
   end)
   if #itemtable == 0 then
      result = result .. " contains no items. "
   else
      result = result
         .. " contains "
         .. itemtable[1].name
         .. " times "
         .. fa_utils.simplify_large_number(itemtable[1].count)
         .. ", "
      if #itemtable > 1 then
         result = result
            .. " and "
            .. itemtable[2].name
            .. " times "
            .. fa_utils.simplify_large_number(itemtable[2].count)
            .. ", "
      end
      if #itemtable > 2 then
         result = result
            .. " and "
            .. itemtable[3].name
            .. " times "
            .. fa_utils.simplify_large_number(itemtable[3].count)
            .. ", "
      end
      if #itemtable > 3 then
         result = result
            .. " and "
            .. itemtable[4].name
            .. " times "
            .. fa_utils.simplify_large_number(itemtable[4].count)
            .. ", "
      end
      if #itemtable > 4 then
         result = result
            .. " and "
            .. itemtable[5].name
            .. " times "
            .. fa_utils.simplify_large_number(itemtable[5].count)
            .. ", "
      end
      if #itemtable > 5 then
         result = result
            .. " and "
            .. itemtable[6].name
            .. " times "
            .. fa_utils.simplify_large_number(itemtable[6].count)
            .. ", "
      end
      if #itemtable > 6 then
         result = result
            .. " and "
            .. itemtable[7].name
            .. " times "
            .. fa_utils.simplify_large_number(itemtable[7].count)
            .. ", "
      end
      if #itemtable > 7 then
         result = result
            .. " and "
            .. itemtable[8].name
            .. " times "
            .. fa_utils.simplify_large_number(itemtable[8].count)
            .. ", "
      end
      if #itemtable > 8 then
         result = result
            .. " and "
            .. itemtable[9].name
            .. " times "
            .. fa_utils.simplify_large_number(itemtable[9].count)
            .. ", "
      end
      if #itemtable > 9 then
         result = result
            .. " and "
            .. itemtable[10].name
            .. " times "
            .. fa_utils.simplify_large_number(itemtable[10].count)
            .. ", "
      end
      if #itemtable > 10 then result = result .. " and other items " end
   end
   return result
end

--laterdo full personal logistics menu where you can go line by line along requests and edit them, iterate through trash?

return mod
