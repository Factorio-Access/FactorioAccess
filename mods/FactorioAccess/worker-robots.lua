--Here: Functions relating worker robots, roboports, logistic systems, blueprints and other planners, ghosts
--Does not include event handlers directly, but can have functions called by them.

dirs = defines.direction
MAX_STACK_COUNT = 10

--https://lua-api.factorio.com/latest/classes/LuaLogisticCell.html
--defines.inventory.character_trash

--Increments: nil, 1, half-stack, 1 stack, n stacks
function increment_logistic_request_min_amount(stack_size, amount_min_in)
   local amount_min = amount_min_in
   
   if amount_min == nil or amount_min == 0 then
      amount_min = 1
   elseif amount_min == 1 then
      amount_min = math.max(math.floor(stack_size/2),2)-- 0 --> 2
   elseif amount_min <= math.floor(stack_size/2) then
      amount_min = stack_size
   elseif amount_min <= stack_size then
      amount_min = amount_min + stack_size
   elseif amount_min > stack_size then
      amount_min = amount_min + stack_size
   end
   
   return amount_min
end

--Increments: nil, 1, half-stack, 1 stack, n stacks
function decrement_logistic_request_min_amount(stack_size, amount_min_in)
   local amount_min = amount_min_in
   
   if amount_min == nil or amount_min == 0 then
      amount_min = nil
   elseif amount_min == 1 then
      amount_min = nil
   elseif amount_min <= math.floor(stack_size/2) then
      amount_min = 1
   elseif amount_min <= stack_size then
      amount_min = math.floor(stack_size/2)
   elseif amount_min > stack_size then
      amount_min = amount_min - stack_size
   end
   
   if amount_min == 0 then -- 0 --> "0"
      amount_min = nil
   end
   
   return amount_min
end

--Increments: 0, 1, half-stack, 1 stack, n stacks
function increment_logistic_request_max_amount(stack_size, amount_max_in)
   local amount_max = amount_max_in
   if amount_max >= stack_size * MAX_STACK_COUNT then
      amount_max = nil
   elseif amount_max > stack_size then
      amount_max = amount_max + stack_size
   elseif amount_max >= stack_size then
      amount_max = amount_max + stack_size
   elseif amount_max >= math.floor(stack_size/2) then
      amount_max = stack_size
   elseif amount_max >= 1 then
      amount_max = math.max(math.floor(stack_size/2),2)-- 0 --> 2
   elseif amount_max == nil or amount_max == 0 then
      amount_max = stack_size
   end
   
   return amount_max
end

--Increments: 0, 1, half-stack, 1 stack, n stacks
function decrement_logistic_request_max_amount(stack_size, amount_max_in)
   local amount_max = amount_max_in
   
   if amount_max > stack_size * MAX_STACK_COUNT then
      amount_max = stack_size * MAX_STACK_COUNT 
   elseif amount_max > stack_size then
      amount_max = amount_max - stack_size
   elseif amount_max >= stack_size then
      amount_max = math.floor(stack_size/2)
   elseif amount_max >= math.floor(stack_size/2) then
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

function logistics_request_toggle_personal_logistics(pindex)
   local p = game.get_player(pindex)
   p.character_personal_logistic_requests_enabled = not p.character_personal_logistic_requests_enabled
   if p.character_personal_logistic_requests_enabled then
      printout("Resumed personal logistics requests",pindex)
   else
      printout("Paused personal logistics requests",pindex)
   end   
end

function logistics_request_toggle_spidertron_logistics(spidertron,pindex)
   spidertron.vehicle_logistic_requests_enabled = not spidertron.vehicle_logistic_requests_enabled
   if spidertron.vehicle_logistic_requests_enabled then
      printout("Resumed spidertron logistics requests",pindex)
   else
      printout("Paused spidertron logistics requests",pindex)
   end   
end

--Checks if the request for the given item is fulfilled. You can pass the personal logistics request slot index if you have it already
function is_this_player_logistic_request_fulfilled(item_stack,pindex,slot_index_in)
   local result = false
   local slot_index = slot_index_in or nil
   --todo**
   return result
end

--Returns info string on the current logistics network, or the nearest one, for the current position
function logistics_networks_info(ent,pos_in)
   local result = ""
   local result_code = -1
   local network = nil
   local pos = pos_in
   if pos_in == nil then
      pos = ent.position
   end
   --Check if in range of a logistic network 
   network = ent.surface.find_logistic_network_by_position(pos, ent.force)
   if network ~= nil and network.valid then
      result_code = 1
      result = "Logistics connected to a network with " .. (network.all_logistic_robots + network.all_construction_robots) .. " robots"
   else
      --If not, report nearest logistic network
      network = ent.surface.find_closest_logistic_network_by_position(pos, ent.force)
      if network ~= nil and network.valid then
         result_code = 2
         local pos_n = network.find_cell_closest_to(pos).owner.position
         result = "No logistics connected, nearest network is " .. util.distance(pos,pos_n) .. " tiles " .. direction_lookup(get_direction_of_that_from_this(pos_n,pos))
      else
         result_code = 3
         result = "No logistics connected, no logistic networks nearby, "
      end
   end
   return result, result_code
end

--Finds or assigns the logistic request slot for the item
function get_personal_logistic_slot_index(item_stack,pindex)
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
   if not slot_found then
      return -1
   end
   
   return correct_slot_id
end

function count_active_personal_logistic_slots(pindex) --**laterdo count fulfilled ones in the same loop ; also try p.character.request_slot_count
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
         slot_founds = slots_found + 1
      end
   end
   
   return slots_found
end

function count_active_spidertron_logistic_slots(spidertron,pindex) 
   local slots_max_count = spidertron.request_slot_count
   local slots_nil_counter = 0
   local slots_found = 0
   local current_slot = nil
   local slot_id = 0
   
   --Find non-empty request slots 
   while slots_nil_counter < slots_max_count  do
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

function logistics_info_key_handler(pindex)
   if players[pindex].in_menu == false or players[pindex].menu == "inventory" then
      --Personal logistics
      local stack = game.get_player(pindex).cursor_stack
      local stack_inv = game.get_player(pindex).get_main_inventory()[players[pindex].inventory.index]
      --Check item in hand or item in inventory
      if stack and stack.valid_for_read and stack.valid then
         --Item in hand
         player_logistic_request_read(stack,pindex,true)
      elseif players[pindex].menu == "inventory" and stack_inv and stack_inv.valid_for_read and stack_inv.valid then
         --Item in inv
         player_logistic_request_read(stack_inv,pindex,true)
      else
         --Logistic chest in front
         local ent = get_selected_ent(pindex)
         if can_make_logistic_requests(ent) then
            read_entity_requests_summary(ent,pindex)
            return
         elseif can_set_logistic_filter(ent) then
            local filter = ent.storage_filter
            local result = "Nothing"
            if filter ~= nil then
               result = filter.name
            end
            printout(result .. " set as logistic storage filter",pindex)
            return
         end
         --Empty hand and empty inventory slot
         local result = player_logistic_requests_summary_info(pindex)
         printout(result,pindex)
      end
   elseif players[pindex].menu == "building" and can_make_logistic_requests(game.get_player(pindex).opened) then
      --Chest logistics
      local stack = game.get_player(pindex).cursor_stack
      local stack_inv = game.get_player(pindex).opened.get_output_inventory()[players[pindex].building.index]
      local chest = game.get_player(pindex).opened
      --Check item in hand or item in inventory
      if stack ~= nil and stack.valid_for_read and stack.valid then
         --Item in hand
         chest_logistic_request_read(stack, chest, pindex)
      elseif stack_inv ~= nil and stack_inv.valid_for_read and stack_inv.valid then
         --Item in output inv
         chest_logistic_request_read(stack_inv, chest, pindex)
      else
         --Empty hand, empty inventory slot
         read_entity_requests_summary(chest,pindex)
      end
   elseif players[pindex].menu == "vehicle" and can_make_logistic_requests(game.get_player(pindex).opened) then
      --spidertron logistics
      local stack = game.get_player(pindex).cursor_stack
      local invs = defines.inventory
      local stack_inv = game.get_player(pindex).opened.get_inventory(invs.spider_trunk)[players[pindex].building.index]
      local spidertron = game.get_player(pindex).opened
      --Check item in hand or item in inventory
      if stack ~= nil and stack.valid_for_read and stack.valid then
         --Item in hand
         spidertron_logistic_request_read(stack, spidertron, pindex, true)
      elseif stack_inv ~= nil and stack_inv.valid_for_read and stack_inv.valid then
         --Item in output inv
         spidertron_logistic_request_read(stack_inv, spidertron, pindex, true)
      else
         --Empty hand, empty inventory slot
         read_entity_requests_summary(spidertron,pindex)      
end
   elseif players[pindex].menu == "building" and can_set_logistic_filter(game.get_player(pindex).opened) then
      local filter = game.get_player(pindex).opened.storage_filter
      local result = "Nothing"
      if filter ~= nil then
         result = filter.name
      end
      printout(result .. " set as logistic storage filter",pindex)
   elseif players[pindex].menu == "building" then
      printout("Logistic requests not supported for this building",pindex)
   else
      printout("No logistics summary available in this menu",pindex)
   end
end

function logistics_request_increment_min_handler(pindex)
   if not players[pindex].in_menu or players[pindex].menu == "inventory" then
      --Personal logistics
      local stack = game.get_player(pindex).cursor_stack
      local stack_inv = game.get_player(pindex).get_main_inventory()[players[pindex].inventory.index]
      --Check item in hand or item in inventory
      if stack ~= nil and stack.valid_for_read and stack.valid then
         --Item in hand
         player_logistic_request_increment_min(stack,pindex)
      elseif players[pindex].menu == "inventory" and stack_inv ~= nil and stack_inv.valid_for_read and stack_inv.valid then
         --Item in inv
         player_logistic_request_increment_min(stack_inv,pindex)
      else
         --Empty hand, empty inventory slot
         --(do nothing)
      end
   elseif players[pindex].menu == "building" and can_make_logistic_requests(game.get_player(pindex).opened) then
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
         printout("No actions",pindex)
      end
   elseif players[pindex].menu == "vehicle" and can_make_logistic_requests(game.get_player(pindex).opened) then
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
         printout("No actions",pindex)
      end
   elseif players[pindex].menu == "building" and can_set_logistic_filter(game.get_player(pindex).opened) then
      --Chest logistics
      local stack = game.get_player(pindex).cursor_stack
      local stack_inv = game.get_player(pindex).opened.get_output_inventory()[players[pindex].building.index]
      local chest = game.get_player(pindex).opened
      --Check item in hand or item in inventory
      if stack ~= nil and stack.valid_for_read and stack.valid then
         --Item in hand
         set_logistic_filter(stack, chest, pindex)
      elseif stack_inv ~= nil and stack_inv.valid_for_read and stack_inv.valid then
         --Item in output inv
         set_logistic_filter(stack_inv, chest, pindex)
      else
         --Empty hand, empty inventory slot
         set_logistic_filter(nil, chest, pindex)
      end
   elseif players[pindex].menu == "building" then
      printout("Logistic requests not supported for this building",pindex)
   else
      --Other menu
      printout("No actions",pindex)
   end
end

function logistics_request_decrement_min_handler(pindex)
   if not players[pindex].in_menu or players[pindex].menu == "inventory" then
      --Personal logistics
      local stack = game.get_player(pindex).cursor_stack
      local stack_inv = game.get_player(pindex).get_main_inventory()[players[pindex].inventory.index]
      --Check item in hand or item in inventory
      if stack ~= nil and stack.valid_for_read and stack.valid then
         --Item in hand
         player_logistic_request_decrement_min(stack,pindex)
      elseif players[pindex].menu == "inventory" and stack_inv ~= nil and stack_inv.valid_for_read and stack_inv.valid then
         --Item in inv
         player_logistic_request_decrement_min(stack_inv,pindex)
      else
         --Empty hand, empty inventory slot
         --(do nothing)
      end
   elseif players[pindex].menu == "building" and can_make_logistic_requests(game.get_player(pindex).opened) then
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
         printout("No actions",pindex)
      end
   elseif players[pindex].menu == "vehicle" and can_make_logistic_requests(game.get_player(pindex).opened) then
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
         printout("No actions",pindex)
      end
   elseif players[pindex].menu == "building" and can_set_logistic_filter(game.get_player(pindex).opened) then
      --Chest logistics
      local stack = game.get_player(pindex).cursor_stack
      local stack_inv = game.get_player(pindex).opened.get_output_inventory()[players[pindex].building.index]
      local chest = game.get_player(pindex).opened
      --Check item in hand or item in inventory
      if stack ~= nil and stack.valid_for_read and stack.valid then
         --Item in hand
         set_logistic_filter(stack, chest, pindex)
      elseif stack_inv ~= nil and stack_inv.valid_for_read and stack_inv.valid then
         --Item in output inv
         set_logistic_filter(stack, chest, pindex)
      else
         --Empty hand, empty inventory slot
         set_logistic_filter(nil, chest, pindex)
      end
   elseif players[pindex].menu == "building" then
      printout("Logistic requests not supported for this building",pindex)
   else
      --Other menu
      printout("No actions",pindex)
   end
end

function logistics_request_increment_max_handler(pindex)
   if not players[pindex].in_menu or players[pindex].menu == "inventory" then
      --Personal logistics
      local stack = game.get_player(pindex).cursor_stack
      local stack_inv = game.get_player(pindex).get_main_inventory()[players[pindex].inventory.index]
      --Check item in hand or item in inventory
      if stack ~= nil and stack.valid_for_read and stack.valid then
         --Item in hand
         player_logistic_request_increment_max(stack,pindex)
      elseif players[pindex].menu == "inventory" and stack_inv ~= nil and stack_inv.valid_for_read and stack_inv.valid then
         --Item in inv
         player_logistic_request_increment_max(stack_inv,pindex)
      else
         --Empty hand, empty inventory slot
         --(do nothing)
      end
   elseif players[pindex].menu == "vehicle" and can_make_logistic_requests(game.get_player(pindex).opened) then
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
         printout("No actions",pindex)
      end
   else
      --Other menu
      --(do nothing)
   end
end

function logistics_request_decrement_max_handler(pindex)
   if not players[pindex].in_menu or players[pindex].menu == "inventory" then
      --Personal logistics
      local stack = game.get_player(pindex).cursor_stack
      local stack_inv = game.get_player(pindex).get_main_inventory()[players[pindex].inventory.index]
      --Check item in hand or item in inventory
      if stack ~= nil and stack.valid_for_read and stack.valid then
         --Item in hand
         player_logistic_request_decrement_max(stack,pindex)
      elseif players[pindex].menu == "inventory" and stack_inv ~= nil and stack_inv.valid_for_read and stack_inv.valid then
         --Item in inv
         player_logistic_request_decrement_max(stack_inv,pindex)
      else
         --Empty hand, empty inventory slot
         --(do nothing)
      end
   elseif players[pindex].menu == "vehicle" and can_make_logistic_requests(game.get_player(pindex).opened) then
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
         printout("No actions",pindex)
      end
   else
      --Other menu
      --(do nothing)
   end
end

function logistics_request_toggle_handler(pindex)
   local ent = game.get_player(pindex).opened
   if not players[pindex].in_menu or players[pindex].menu == "inventory" then
      --Player: Toggle enabling requests
      logistics_request_toggle_personal_logistics(pindex)
   elseif players[pindex].menu == "vehicle" and can_make_logistic_requests(ent) then
      --Vehicles: Toggle enabling requests
      logistics_request_toggle_spidertron_logistics(ent, pindex)
   elseif players[pindex].menu == "building" then
      --Requester chests: Toggle requesting from buffers
      if can_make_logistic_requests(ent) then
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

--Returns summary info string
function player_logistic_requests_summary_info(pindex)
   --***todo improve: "y of z personal logistic requests fulfilled, x items in trash, missing items include [3], take an item in hand and press L to check its request status." maybe use logistics_networks_info(ent,pos_in)
   local p = game.get_player(pindex)
   local current_slot = nil
   local correct_slot_id = nil
   local result = ""
   
   --Check if logistics have been researched
   for i, tech in pairs(game.get_player(pindex).force.technologies) do
      if tech.name == "logistic-robotics" and not tech.researched == true then
         printout("Logistic requests not available, research required.",pindex)
         return
      end
   end
   
   --Check if inside any logistic network or not (simpler than logistics network info)
   local network = p.surface.find_logistic_network_by_position(p.position, p.force)
   if network == nil or not network.valid then
      --Check whether in construction range
      local nearest, min_dist = find_nearest_roboport(p.surface,p.position,60)
      if nearest == nil or min_dist > 55 then
         result = result .. "Not in a network, "
      else
         result = result .. "In construction range of network " .. nearest.backer_name .. ", " 
      end
   else
      --Definitely within range
      local nearest, min_dist = find_nearest_roboport(p.surface,p.position,30)
      result = result .. "In logistic range of network " .. nearest.backer_name .. ", " 
   end
   
   --Check if personal logistics are enabled
   if not p.character_personal_logistic_requests_enabled then
      result = result .. "Requests paused, "
   end
   
   --Count logistics requests
   result = result .. count_active_personal_logistic_slots(pindex) .. " personal logistic requests set, "
   return result
end

--Read the current personal logistics request set for this item
function player_logistic_request_read(item_stack,pindex,additional_checks)
   local p = game.get_player(pindex)
   local current_slot = nil
   local correct_slot_id = nil
   local result = ""
   
   --Check if logistics have been researched
   for i, tech in pairs(game.get_player(pindex).force.technologies) do
      if tech.name == "logistic-robotics" and not tech.researched then
         printout("Logistic requests not available, research required.",pindex)
         return
      end
   end
   
   if additional_checks then
      --Check if inside any logistic network or not (simpler than logistics network info)
      local network = p.surface.find_logistic_network_by_position(p.position, p.force)
      if network == nil or not network.valid then
         result = result .. "Not in a network, "
      end
      
      --Check if personal logistics are enabled
      if not p.character_personal_logistic_requests_enabled then
         result = result .. "Requests paused, "
      end
   end
   
   --Find the correct request slot for this item
   local correct_slot_id = get_personal_logistic_slot_index(item_stack,pindex)
   
   if correct_slot_id == nil or correct_slot_id < 1 then
      printout(result .. "Error: Invalid slot ID",pindex)
      return 
   end
   
   --Read the correct slot id value
   current_slot = p.get_personal_logistic_slot(correct_slot_id)
   if current_slot == nil or current_slot.name == nil then
      --No requests found
      printout(result .. "No personal logistic requests set for " .. item_stack.name .. ", use the L key and modifier keys to set requests.",pindex)
      return
   else
      --Report request counts and inventory counts
      if current_slot.max ~= nil or current_slot.min ~= nil then
         local min_result = ""
         local max_result = ""
         local inv_result = ""
         local trash_result = ""
         
         if current_slot.min ~= nil then
            min_result = get_unit_or_stack_count(current_slot.min, item_stack.prototype.stack_size, false) .. " minimum and "
         end
         
         if current_slot.max ~= nil then
            max_result = get_unit_or_stack_count(current_slot.max, item_stack.prototype.stack_size, false) .. " maximum "
         end
         
         local inv_count = p.get_main_inventory().get_item_count(item_stack.name)
         inv_result = get_unit_or_stack_count(inv_count, item_stack.prototype.stack_size, false) .. " in inventory, "
         
         local trash_count = p.get_inventory(defines.inventory.character_trash).get_item_count(item_stack.name)
         trash_result = get_unit_or_stack_count(trash_count, item_stack.prototype.stack_size, false) .. " in personal trash, "
         
         printout(result .. min_result .. max_result .. " requested for " .. item_stack.name .. ", " .. inv_result .. trash_result .. " use the L key and modifier keys to set requests.",pindex)
         return
      else
         --All requests are nil
         printout(result .. "No personal logistic requests set for " .. item_stack.name .. ", use the L key and modifier keys to set requests.",pindex)
         return
      end
   end
end

--Returns a quantity of an item in terms of stacks, if there is at least one stack
function get_unit_or_stack_count(count,stack_size,precise)
   local result = ""
   local new_count = "unknown amount of"
   local units = " units "
   if count == nil then
      new_count = "no"
   elseif count == 0 then 
      units = " units "
      new_count = 0
   elseif count == 1 then 
      units = " unit "
      new_count = 1
   elseif count < stack_size  then 
      units = " units "
      new_count = count
   elseif count == stack_size then
      units = " stack "
      new_count = 1
   elseif count > stack_size then
      units = " stacks "
      new_count = math.floor(count / stack_size)
   end
   result = new_count .. units
   if precise and count > stack_size and count % stack_size > 0 then
      result = result .. " and " .. count % stack_size .. " units "
   end
   if count > 10000 then
      result = "infinite"
   end
   return result
end

function player_logistic_request_increment_min(item_stack,pindex)
   local p = game.get_player(pindex)
   local current_slot = nil
   local correct_slot_id = nil
   
   --Check if logistics have been researched
   for i, tech in pairs(game.get_player(pindex).force.technologies) do
      if tech.name == "logistic-robotics" and not tech.researched then
         printout("Error: You need to research logistic robotics to use this feature.",pindex)
         return
      end
   end
   
   --Find the correct request slot for this item
   local correct_slot_id = get_personal_logistic_slot_index(item_stack,pindex)
   
   if correct_slot_id == -1 then
      printout("Error: No empty slots available for this request",pindex)
      return false
   elseif correct_slot_id == nil or correct_slot_id < 1 then
      printout("Error: Invalid slot ID",pindex)
      return false
   end
   
   --Read the correct slot id value, increment it, set it
   current_slot = p.get_personal_logistic_slot(correct_slot_id)
   if current_slot == nil or current_slot.name == nil then
      --Create a fresh request
      local new_slot = {name = item_stack.name, min = 1, max = nil}
      p.set_personal_logistic_slot(correct_slot_id,new_slot)
   else
      --Update existing request
      current_slot.min = increment_logistic_request_min_amount(item_stack.prototype.stack_size,current_slot.min)
      --Force min <= max
      if current_slot.min ~= nil and current_slot.max ~= nil and current_slot.min > current_slot.max then
         printout("Error: Minimum request value cannot exceed maximum",pindex)
         return
      end
      p.set_personal_logistic_slot(correct_slot_id,current_slot)
   end
   
   --Read new status
   player_logistic_request_read(item_stack,pindex,false)
end

function player_logistic_request_decrement_min(item_stack,pindex)
   local p = game.get_player(pindex)
   local current_slot = nil
   local correct_slot_id = nil
   
   --Check if logistics have been researched
   for i, tech in pairs(game.get_player(pindex).force.technologies) do
      if tech.name == "logistic-robotics" and not tech.researched then
         printout("Error: You need to research logistic robotics to use this feature.",pindex)
         return
      end
   end
   
   --Find the correct request slot for this item
   local correct_slot_id = get_personal_logistic_slot_index(item_stack,pindex)
   
   if correct_slot_id == -1 then
      printout("Error: No empty slots available for this request",pindex)
      return false
   elseif correct_slot_id == nil or correct_slot_id < 1 then
      printout("Error: Invalid slot ID",pindex)
      return false
   end
   
   --Read the correct slot id value, decrement it, set it
   current_slot = p.get_personal_logistic_slot(correct_slot_id)
   if current_slot == nil or current_slot.name == nil then
      --Create a fresh request
      local new_slot = {name = item_stack.name, min = 0, max = nil}
      p.set_personal_logistic_slot(correct_slot_id,new_slot)
   else
      --Update existing request
      current_slot.min = decrement_logistic_request_min_amount(item_stack.prototype.stack_size,current_slot.min)
      --Force min <= max
      if current_slot.min ~= nil and current_slot.max ~= nil and current_slot.min > current_slot.max then
         printout("Error: Minimum request value cannot exceed maximum",pindex)
         return
      end
      p.set_personal_logistic_slot(correct_slot_id,current_slot)
   end
   
   --Read new status
   player_logistic_request_read(item_stack,pindex)
end

function player_logistic_request_increment_max(item_stack,pindex)
   local p = game.get_player(pindex)
   local current_slot = nil
   local correct_slot_id = nil
   
   --Check if logistics have been researched
   for i, tech in pairs(game.get_player(pindex).force.technologies) do
      if tech.name == "logistic-robotics" and not tech.researched then
         printout("Error: You need to research logistic robotics to use this feature.",pindex)
         return
      end
   end
   
   --Find the correct request slot for this item
   local correct_slot_id = get_personal_logistic_slot_index(item_stack,pindex)
   
   if correct_slot_id == -1 then
      printout("Error: No empty slots available for this request",pindex)
      return false
   elseif correct_slot_id == nil or correct_slot_id < 1 then
      printout("Error: Invalid slot ID",pindex)
      return false
   end
   
   --Read the correct slot id value, decrement it, set it
   current_slot = p.get_personal_logistic_slot(correct_slot_id)
   if current_slot == nil or current_slot.name == nil then
      --Create a fresh request
      local new_slot = {name = item_stack.name, min = 0, max = MAX_STACK_COUNT * item_stack.prototype.stack_size}
      p.set_personal_logistic_slot(correct_slot_id,new_slot)
   else
      --Update existing request
      current_slot.max = increment_logistic_request_max_amount(item_stack.prototype.stack_size,current_slot.max)
      --Force min <= max
      if current_slot.min ~= nil and current_slot.max ~= nil and current_slot.min > current_slot.max then
         printout("Error: Minimum request value cannot exceed maximum",pindex)
         return
      end
      p.set_personal_logistic_slot(correct_slot_id,current_slot)
   end
   
   --Read new status
   player_logistic_request_read(item_stack,pindex)
end

function player_logistic_request_decrement_max(item_stack,pindex)
   local p = game.get_player(pindex)
   local current_slot = nil
   local correct_slot_id = nil
   
   --Check if logistics have been researched
   for i, tech in pairs(game.get_player(pindex).force.technologies) do
      if tech.name == "logistic-robotics" and not tech.researched then
         printout("Error: You need to research logistic robotics to use this feature.",pindex)
         return
      end
   end
   
   --Find the correct request slot for this item
   local correct_slot_id = get_personal_logistic_slot_index(item_stack,pindex)
   
   if correct_slot_id == -1 then
      printout("Error: No empty slots available for this request",pindex)
      return false
   elseif correct_slot_id == nil or correct_slot_id < 1 then
      printout("Error: Invalid slot ID",pindex)
      return false
   end
   
   --Read the correct slot id value, increment it, set it
   current_slot = p.get_personal_logistic_slot(correct_slot_id)
   if current_slot == nil or current_slot.name == nil then
      --Create a fresh request
      local new_slot = {name = item_stack.name, min = 0, max = MAX_STACK_COUNT * item_stack.prototype.stack_size}
      p.set_personal_logistic_slot(correct_slot_id,new_slot)
   else
      --Update existing request
      current_slot.max = decrement_logistic_request_max_amount(item_stack.prototype.stack_size,current_slot.max)
      --Force min <= max
      if current_slot.min ~= nil and current_slot.max ~= nil and current_slot.min > current_slot.max then
         printout("Error: Minimum request value cannot exceed maximum",pindex)
         return
      end
      p.set_personal_logistic_slot(correct_slot_id,current_slot)
   end
   
   --Read new status
   player_logistic_request_read(item_stack,pindex,false)
end

--Finds or assigns the logistic request slot for the item, for chests or vehicles 
function get_entity_logistic_slot_index(item_stack,chest)
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
   if not slot_found then
      return -1
   end
   
   return correct_slot_id
end

--Read the chest's current logistics request set for this item
function chest_logistic_request_read(item_stack,chest,pindex)
   local current_slot = nil
   local correct_slot_id = nil
   local result = ""
   
   --Check if logistics have been researched
   for i, tech in pairs(game.get_player(pindex).force.technologies) do
      if tech.name == "logistic-system" and not tech.researched then
         printout("Error: You need to research logistic system, with utility science, to use this feature.",pindex)
         return
      end
   end
   
   --Find the correct request slot for this item
   local correct_slot_id = get_entity_logistic_slot_index(item_stack,chest)
   
   if correct_slot_id == -1 then
      printout("Error: No empty slots available for this request",pindex)
      return false
   elseif correct_slot_id == nil or correct_slot_id < 1 then
      printout("Error: Invalid slot ID",pindex)
      return false
   end

   --Read the correct slot id value
   current_slot = chest.get_request_slot(correct_slot_id)
   if current_slot == nil or current_slot.name == nil then
      --No requests found
      printout("No logistic requests set for " .. item_stack.name .. ", use the 'L' key and modifier keys to set requests.",pindex)
      return
   else
      --Report request counts and inventory counts
      local req_result = ""
      local inv_result = ""
      
      if current_slot.count ~= nil then
         req_result = get_unit_or_stack_count(current_slot.count, item_stack.prototype.stack_size, false) 
      end
      
      local inv_count = chest.get_output_inventory().get_item_count(item_stack.name)
      inv_result = get_unit_or_stack_count(inv_count, item_stack.prototype.stack_size, false) 
      
      printout(req_result .. " requested and " .. inv_result .. " supplied for " .. item_stack.name .. ", use the 'L' key and modifier keys to set requests.",pindex)
      return
   end
end

--Increments min value
function chest_logistic_request_increment_min(item_stack,chest,pindex)
   local current_slot = nil
   local correct_slot_id = nil
   
   --Check if logistics have been researched
   for i, tech in pairs(game.get_player(pindex).force.technologies) do
      if tech.name == "logistic-system" and not tech.researched then
         printout("Error: You need to research logistic system, with utility science, to use this feature.",pindex)
         return
      end
   end
   
   --Find the correct request slot for this item
   local correct_slot_id = get_entity_logistic_slot_index(item_stack,chest)
   
   if correct_slot_id == -1 then
      printout("Error: No empty slots available for this request",pindex)
      return false
   elseif correct_slot_id == nil or correct_slot_id < 1 then
      printout("Error: Invalid slot ID",pindex)
      return false
   end
   
   --Read the correct slot id value, increment it, set it
   current_slot = chest.get_request_slot(correct_slot_id)
   if current_slot == nil or current_slot.name == nil then
      --Create a fresh request
      local new_slot = {name = item_stack.name, count = item_stack.prototype.stack_size}
      chest.set_request_slot(new_slot, correct_slot_id)
   else
      --Update existing request
      current_slot.count = increment_logistic_request_min_amount(item_stack.prototype.stack_size,current_slot.count)
      chest.set_request_slot(current_slot,correct_slot_id)
   end
   
   --Read new status
   chest_logistic_request_read(item_stack,chest,pindex,false)
end

--Decrements min value
function chest_logistic_request_decrement_min(item_stack,chest, pindex)
   local current_slot = nil
   local correct_slot_id = nil
   
   --Check if logistics have been researched
   for i, tech in pairs(game.get_player(pindex).force.technologies) do
      if tech.name == "logistic-system" and not tech.researched then
         printout("Error: You need to research logistic system, with utility science, to use this feature.",pindex)
         return
      end
   end
   
   --Find the correct request slot for this item
   local correct_slot_id = get_entity_logistic_slot_index(item_stack,chest)
   
   if correct_slot_id == -1 then
      printout("Error: No empty slots available for this request",pindex)
      return false
   elseif correct_slot_id == nil or correct_slot_id < 1 then
      printout("Error: Invalid slot ID",pindex)
      return false
   end
   
   --Read the correct slot id value, decrement it, set it
   current_slot = chest.get_request_slot(correct_slot_id)
   if current_slot == nil or current_slot.name == nil then
      --Create a fresh request
      local new_slot = {name = item_stack.name, count = item_stack.prototype.stack_size}
      chest.set_request_slot(new_slot, correct_slot_id)
   else
      --Update existing request
      current_slot.count = decrement_logistic_request_min_amount(item_stack.prototype.stack_size,current_slot.count)
      if current_slot.count == nil or current_slot.count == 0 then 
         chest.clear_request_slot(correct_slot_id)
      else
         chest.set_request_slot(current_slot,correct_slot_id)
      end
   end
   
   --Read new status
   chest_logistic_request_read(item_stack,chest,pindex,false)
end

function send_selected_stack_to_logistic_trash(pindex)
   local p = game.get_player(pindex)
   local stack = p.cursor_stack
   --Check cursor stack 
   if stack == nil or stack.valid_for_read == false or stack.is_deconstruction_item or stack.is_upgrade_item then
      stack = p.get_main_inventory()[players[pindex].inventory.index]
   end
   --Check inventory stack
   if players[pindex].menu ~= "inventory" or stack == nil or stack.valid_for_read == false or stack.is_deconstruction_item or stack.is_upgrade_item then
      return
   end
   local trash_inv = p.get_inventory(defines.inventory.character_trash)
   if trash_inv.can_insert(stack) then
      local inserted_count = trash_inv.insert(stack)
      if inserted_count < stack.count then
         stack.set_stack({name = stack.name, count = stack.count - inserted_count})
         printout("Partially sent stack to logistic trash",pindex)
      else
         stack.set_stack(nil)
         printout("Sent stack to logistic trash",pindex)
      end
   end
end

function spidertron_logistic_requests_summary_info(spidertron,pindex)
   --***todo improve: "y of z personal logistic requests fulfilled, x items in trash, missing items include [3], take an item in hand and press L to check its request status." maybe use logistics_networks_info(ent,pos_in)
   local p = game.get_player(pindex)
   local current_slot = nil
   local correct_slot_id = nil
   local result = "Spidertron "
   
   --Check if logistics have been researched
   for i, tech in pairs(game.get_player(pindex).force.technologies) do
      if tech.name == "logistic-robotics" and not tech.researched == true then
         printout("Logistic requests not available, research required.",pindex)
         return
      end
   end
   
   --Check if inside any logistic network or not (simpler than logistics network info)
   local network = p.surface.find_logistic_network_by_position(spidertron.position, p.force)
   if network == nil or not network.valid then
      --Check whether in construction range
      local nearest, min_dist = find_nearest_roboport(p.surface,spidertron.position,60)
      if nearest == nil or min_dist > 55 then
         result = result .. "Not in a network, "
      else
         result = result .. "In construction range of network " .. nearest.backer_name .. ", " 
      end
   else
      --Definitely within range
      local nearest, min_dist = find_nearest_roboport(p.surface,spidertron.position,30)
      result = result .. "In logistic range of network " .. nearest.backer_name .. ", " 
   end
   
   --Check if personal logistics are enabled
   if not spidertron.vehicle_logistic_requests_enabled then
      result = result .. "Requests paused, "
   end
   
   --Count logistics requests
   result = result .. count_active_spidertron_logistic_slots(pindex) .. " spidertron logistic requests set, "
   return result
end

--Read the current spidertron's logistics request set for this item
function spidertron_logistic_request_read(item_stack,spidertron,pindex,additional_checks)
   local current_slot = nil
   local correct_slot_id = nil
   local result = ""
   
   --Check if logistics have been researched
   for i, tech in pairs(game.get_player(pindex).force.technologies) do
      if tech.name == "logistic-robotics" and not tech.researched then
         printout("Logistic requests not available, research required.",pindex)
         return
      end
   end
   
   if additional_checks then
      --Check if inside any logistic network or not (simpler than logistics network info)
      local network = spidertron.surface.find_logistic_network_by_position(spidertron.position, spidertron.force)
      if network == nil or not network.valid then
         result = result .. "Not in a network, "
      end
      
      --Check if personal logistics are enabled
      if not spidertron.vehicle_logistic_requests_enabled then
         result = result .. "Requests paused, "
      end
   end
   
   --Find the correct request slot for this item
   local correct_slot_id = get_entity_logistic_slot_index(item_stack,spidertron)
   
   if correct_slot_id == nil or correct_slot_id < 1 then
      printout(result .. "Error: Invalid slot ID",pindex)
      return 
   end
   
   --Read the correct slot id value
   current_slot = spidertron.get_vehicle_logistic_slot(correct_slot_id)
   if current_slot == nil or current_slot.name == nil then
      --No requests found
      printout(result .. "No logistic requests set for " .. item_stack.name .. " in this spidertron, use the L key and modifier keys to set requests.",pindex)
      return
   else
      --Report request counts and inventory counts
      if current_slot.max ~= nil or current_slot.min ~= nil then
         local min_result = ""
         local max_result = ""
         local inv_result = ""
         local trash_result = ""
         
         if current_slot.min ~= nil then
            min_result = get_unit_or_stack_count(current_slot.min, item_stack.prototype.stack_size, false) .. " minimum and "
         end
         
         if current_slot.max ~= nil then
            max_result = get_unit_or_stack_count(current_slot.max, item_stack.prototype.stack_size, false) .. " maximum "
         end
         
         local inv_count = spidertron.get_inventory(defines.inventory.spider_trunk).get_item_count(item_stack.name)
         inv_result = get_unit_or_stack_count(inv_count, item_stack.prototype.stack_size, false) .. " in inventory, "
         
         local trash_count = spidertron.get_inventory(defines.inventory.spider_trash).get_item_count(item_stack.name)
         trash_result = get_unit_or_stack_count(trash_count, item_stack.prototype.stack_size, false) .. " in spidertron trash, "
         
         printout(result .. min_result .. max_result .. " requested for " .. item_stack.name .. ", " .. inv_result .. trash_result .. " use the L key and modifier keys to set requests.",pindex)
         return
      else
         --All requests are nil
         printout(result .. "No spidertron logistic requests set for " .. item_stack.name .. ", use the L key and modifier keys to set requests.",pindex)
         return
      end
   end
end

function spidertron_logistic_request_increment_min(item_stack,spidertron,pindex)
   local current_slot = nil
   local correct_slot_id = nil
   
   --Check if logistics have been researched
   for i, tech in pairs(game.get_player(pindex).force.technologies) do
      if tech.name == "logistic-robotics" and not tech.researched then
         printout("Error: You need to research logistic robotics to use this feature.",pindex)
         return
      end
   end
   
   --Find the correct request slot for this item
   local correct_slot_id = get_entity_logistic_slot_index(item_stack,spidertron)
   
   if correct_slot_id == -1 then
      printout("Error: No empty slots available for this request",pindex)
      return false
   elseif correct_slot_id == nil or correct_slot_id < 1 then
      printout("Error: Invalid slot ID",pindex)
      return false
   end
   
   --Read the correct slot id value, increment it, set it
   current_slot = spidertron.get_vehicle_logistic_slot(correct_slot_id)
   if current_slot == nil or current_slot.name == nil then
      --Create a fresh request
      local new_slot = {name = item_stack.name, min = 1, max = nil}
      spidertron.set_vehicle_logistic_slot(correct_slot_id,new_slot)
   else
      --Update existing request
      current_slot.min = increment_logistic_request_min_amount(item_stack.prototype.stack_size,current_slot.min)
      --Force min <= max
      if current_slot.min ~= nil and current_slot.max ~= nil and current_slot.min > current_slot.max then
         printout("Error: Minimum request value cannot exceed maximum",pindex)
         return
      end
      spidertron.set_vehicle_logistic_slot(correct_slot_id,current_slot)
   end
   
   --Read new status
   spidertron_logistic_request_read(item_stack,spidertron,pindex,false)
end

function spidertron_logistic_request_decrement_min(item_stack,spidertron,pindex)
   local current_slot = nil
   local correct_slot_id = nil
   
   --Check if logistics have been researched
   for i, tech in pairs(game.get_player(pindex).force.technologies) do
      if tech.name == "logistic-robotics" and not tech.researched then
         printout("Error: You need to research logistic robotics to use this feature.",pindex)
         return
      end
   end
   
   --Find the correct request slot for this item
   local correct_slot_id = get_entity_logistic_slot_index(item_stack,spidertron)
   
   if correct_slot_id == -1 then
      printout("Error: No empty slots available for this request",pindex)
      return false
   elseif correct_slot_id == nil or correct_slot_id < 1 then
      printout("Error: Invalid slot ID",pindex)
      return false
   end
   
   --Read the correct slot id value, decrement it, set it
   current_slot = spidertron.get_vehicle_logistic_slot(correct_slot_id)
   if current_slot == nil or current_slot.name == nil then
      --Create a fresh request
      local new_slot = {name = item_stack.name, min = 0, max = nil}
      spidertron.set_vehicle_logistic_slot(correct_slot_id,new_slot)
   else
      --Update existing request
      current_slot.min = decrement_logistic_request_min_amount(item_stack.prototype.stack_size,current_slot.min)
      --Force min <= max
      if current_slot.min ~= nil and current_slot.max ~= nil and current_slot.min > current_slot.max then
         printout("Error: Minimum request value cannot exceed maximum",pindex)
         return
      end
      spidertron.set_vehicle_logistic_slot(correct_slot_id,current_slot)
   end
   
   --Read new status
   spidertron_logistic_request_read(item_stack,spidertron,pindex,false)
end

function spidertron_logistic_request_increment_max(item_stack,spidertron,pindex)
   local current_slot = nil
   local correct_slot_id = nil
   
   --Check if logistics have been researched
   for i, tech in pairs(game.get_player(pindex).force.technologies) do
      if tech.name == "logistic-robotics" and not tech.researched then
         printout("Error: You need to research logistic robotics to use this feature.",pindex)
         return
      end
   end
   
   --Find the correct request slot for this item
   local correct_slot_id = get_entity_logistic_slot_index(item_stack,spidertron)
   
   if correct_slot_id == -1 then
      printout("Error: No empty slots available for this request",pindex)
      return false
   elseif correct_slot_id == nil or correct_slot_id < 1 then
      printout("Error: Invalid slot ID",pindex)
      return false
   end
   
   --Read the correct slot id value, decrement it, set it
   current_slot = spidertron.get_vehicle_logistic_slot(correct_slot_id)
   if current_slot == nil or current_slot.name == nil then
      --Create a fresh request
      local new_slot = {name = item_stack.name, min = 0, max = MAX_STACK_COUNT * item_stack.prototype.stack_size}
      spidertron.set_vehicle_logistic_slot(correct_slot_id,new_slot)
   else
      --Update existing request
      current_slot.max = increment_logistic_request_max_amount(item_stack.prototype.stack_size,current_slot.max)
      --Force min <= max
      if current_slot.min ~= nil and current_slot.max ~= nil and current_slot.min > current_slot.max then
         printout("Error: Minimum request value cannot exceed maximum",pindex)
         return
      end
      spidertron.set_vehicle_logistic_slot(correct_slot_id,current_slot)
   end
   
   --Read new status
   spidertron_logistic_request_read(item_stack,spidertron,pindex,false)
end

function spidertron_logistic_request_decrement_max(item_stack,spidertron,pindex)
   local current_slot = nil
   local correct_slot_id = nil
   
   --Check if logistics have been researched
   for i, tech in pairs(game.get_player(pindex).force.technologies) do
      if tech.name == "logistic-robotics" and not tech.researched then
         printout("Error: You need to research logistic robotics to use this feature.",pindex)
         return
      end
   end
   
   --Find the correct request slot for this item
   local correct_slot_id = get_entity_logistic_slot_index(item_stack,spidertron)
   
   if correct_slot_id == -1 then
      printout("Error: No empty slots available for this request",pindex)
      return false
   elseif correct_slot_id == nil or correct_slot_id < 1 then
      printout("Error: Invalid slot ID",pindex)
      return false
   end
   
   --Read the correct slot id value, increment it, set it
   current_slot = spidertron.get_vehicle_logistic_slot(correct_slot_id)
   if current_slot == nil or current_slot.name == nil then
      --Create a fresh request
      local new_slot = {name = item_stack.name, min = 0, max = MAX_STACK_COUNT * item_stack.prototype.stack_size}
      spidertron.set_vehicle_logistic_slot(correct_slot_id,new_slot)
   else
      --Update existing request
      current_slot.max = decrement_logistic_request_max_amount(item_stack.prototype.stack_size,current_slot.max)
      --Force min <= max
      if current_slot.min ~= nil and current_slot.max ~= nil and current_slot.min > current_slot.max then
         printout("Error: Minimum request value cannot exceed maximum",pindex)
         return
      end
      spidertron.set_vehicle_logistic_slot(correct_slot_id,current_slot)
   end
   
   --Read new status
   spidertron_logistic_request_read(item_stack,spidertron,pindex,false)
end

--Logistic requests can be made by chests or spidertrons
function can_make_logistic_requests(ent)
   if ent == nil or ent.valid == false then
      return false
   end
   if ent.type == "spider-vehicle" then
      return true
   end
   local point = ent.get_logistic_point(defines.logistic_member_index.logistic_container)
   if point == nil or point.valid == false then 
      return false
   end
   if point.mode == defines.logistic_mode.requester or point.mode == defines.logistic_mode.buffer then
      return true
   else
      return false 
   end
end

--Logistic filters are set by storage chests
function can_set_logistic_filter(ent)
   if ent == nil or ent.valid == false then
      return false
   end
   local point = ent.get_logistic_point(defines.logistic_member_index.logistic_container)
   if point == nil or point.valid == false then 
      return false
   end
   if point.mode == defines.logistic_mode.storage then
      return true
   else
      return false 
   end
end

function set_logistic_filter(stack, ent, pindex)
   if stack == nil or stack.valid_for_read == false then
      ent.storage_filter = nil
      printout("logistic storage filter cleared",pindex)
      return
   end
   
   if ent.storage_filter == stack.prototype then
      ent.storage_filter = nil
      printout("logistic storage filter cleared",pindex)
   else
      ent.storage_filter = stack.prototype
      printout(stack.name .. " set as logistic storage filter ",pindex)
   end
end

function read_entity_requests_summary(ent,pindex)--**laterdo improve
   if ent.type == "spider-vehicle" then
      printout(ent.request_slot_count .. " spidertron logistic requests set", pindex)
   else
      printout(ent.request_slot_count .. " chest logistic requests set", pindex)
   end
end

--Finds the nearest roboport
function find_nearest_roboport(surf,pos,radius_in)
   local nearest = nil
   local min_dist = radius_in
   local ports = surf.find_entities_filtered{name = "roboport" , position = pos , radius = radius_in}
   for i,port in ipairs(ports) do
      local dist = math.ceil(util.distance(pos, port.position))
      if dist < min_dist then
         min_dist = dist
         nearest = port
      end
   end
   if nearest ~= nil then
      rendering.draw_circle{color = {1, 1, 0}, radius = 4, width = 4, target = nearest.position, surface = surf, time_to_live = 90}
   end
   return nearest, min_dist
end

--laterdo** maybe use surf.find_closest_logistic_network_by_position(position, force)

--The idea is that every roboport of the network has the same backer name and this is the networks's name.
function get_network_name(port)
   resolve_network_name(port)
   return port.backer_name
end


--Sets a logistic network's name. The idea is that every roboport of the network has the same backer name and this is the networks's name.
function set_network_name(port,new_name)
   --Rename this port
   if new_name == nil or new_name == "" then
      return false
   end
   port.backer_name = new_name
   --Rename the rest, if any
   local nw = port.logistic_network
   if nw == nil then
      return true
   end
   local cells = nw.cells
   if cells == nil or cells == {} then
      return true
   end
   for i,cell in ipairs(cells) do
      if cell.owner.supports_backer_name then
         cell.owner.backer_name = new_name
      end
   end
   return true
end

--Finds the oldest roboport and applies its name across the network. Any built roboport will be newer and so the older names will be kept.
function resolve_network_name(port_in)
   local oldest_port = port_in
   local nw = oldest_port.logistic_network
   --No network means resolved
   if nw == nil then
      return 
   end
   local cells = nw.cells
   --Check others
   for i,cell in ipairs(cells) do
      local port = cell.owner
      if port ~= nil and port.valid and oldest_port.unit_number > port.unit_number then
         oldest_port = port
      end
   end
   --Rename all
   set_network_name(oldest_port, oldest_port.backer_name)
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
function roboport_menu(menu_index, pindex, clicked)
   local index = menu_index
   local port = nil
   local ent = get_selected_ent(pindex)
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
      printout("Roboport of logistic network ".. get_network_name(port)
      .. ", Press 'W' and 'S' to navigate options, press 'LEFT BRACKET' to select an option or press 'E' to exit this menu.", pindex)
   elseif index == 1 then
      --1. Rename roboport networks
      if not clicked then
         printout("Rename this network", pindex)
      else
         printout("Enter a new name for this network, then press 'ENTER' to confirm, or press 'ESC' to cancel.", pindex)
         players[pindex].roboport_menu.renaming = true
         local frame = game.get_player(pindex).gui.screen.add{type = "frame", name = "network-rename"}
         frame.bring_to_front()
         frame.force_auto_center()
         frame.focus()
         --game.get_player(pindex).opened = frame
         local input = frame.add{type="textfield", name = "input"}
         input.focus()
      end
   elseif index == 2 then
      --2. This roboport: Check neighbor counts and dirs
      if not clicked then
         printout("Read roboport neighbours", pindex)
      else
         local result = roboport_neighbours_info(port)
         printout(result, pindex)
      end
   elseif index == 3 then
      --3. This roboport: Check robot counts
      if not clicked then
         printout("Read roboport contents", pindex)
      else
         local result = roboport_contents_info(port)
         printout(result, pindex)
      end
   elseif index == 4 then
      --4. Check network roboport & robot & chest(?) counts
      if not clicked then
         printout("Read robots info for the network", pindex)
      else
         if nw ~= nil then
            local result = logistic_network_members_info(port)
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
            local result = logistic_network_chests_info(port)
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
            local result = logistic_network_items_info(port)
            printout(result, pindex)
         else
            printout("Error: No network", pindex)
         end
      end
   end
end
ROBOPORT_MENU_LENGTH = 6

function roboport_menu_open(pindex)
   if players[pindex].vanilla_mode then
      return 
   end
   --Set the player menu tracker to this menu
   players[pindex].menu = "roboport_menu"
   players[pindex].in_menu = true
   players[pindex].move_queue = {}
   
   --Initialize if needed
   if players[pindex].roboport_menu == nil then
      players[pindex].roboport_menu = {}
   end
   --Set the menu line counter to 0
   players[pindex].roboport_menu.index = 0
   
   --Play sound
   game.get_player(pindex).play_sound{path = "Open-Inventory-Sound"}
   
   --Load menu 
   roboport_menu(players[pindex].roboport_menu.index, pindex, false)
end

function roboport_menu_close(pindex, mute_in)
   local mute = mute_in
   --Set the player menu tracker to none
   players[pindex].menu = "none"
   players[pindex].in_menu = false

   --Set the menu line counter to 0
   players[pindex].roboport_menu.index = 0
   players[pindex].roboport_menu.port = nil
   
   --play sound
   if not mute then
      game.get_player(pindex).play_sound{path="Close-Inventory-Sound"}
   end
   
   --Destroy GUI
   if game.get_player(pindex).gui.screen["network-rename"] ~= nil then
      game.get_player(pindex).gui.screen["network-rename"].destroy()
   end
   if game.get_player(pindex).opened ~= nil then
      game.get_player(pindex).opened = nil
   end
end

function roboport_menu_up(pindex)
   players[pindex].roboport_menu.index = players[pindex].roboport_menu.index - 1
   if players[pindex].roboport_menu.index < 0 then
      players[pindex].roboport_menu.index = 0
      game.get_player(pindex).play_sound{path = "inventory-edge"}
   else
      --Play sound
      game.get_player(pindex).play_sound{path = "Inventory-Move"}
   end
   --Load menu
   roboport_menu(players[pindex].roboport_menu.index, pindex, false)
end

function roboport_menu_down(pindex)
   players[pindex].roboport_menu.index = players[pindex].roboport_menu.index + 1
   if players[pindex].roboport_menu.index > ROBOPORT_MENU_LENGTH then
      players[pindex].roboport_menu.index = ROBOPORT_MENU_LENGTH
      game.get_player(pindex).play_sound{path = "inventory-edge"}
   else
      --Play sound
      game.get_player(pindex).play_sound{path = "Inventory-Move"}
   end
   --Load menu
   roboport_menu(players[pindex].roboport_menu.index, pindex, false)
end

function roboport_contents_info(port)
   local result = ""
   local cell = port.logistic_cell
   result = result .. " charging " .. cell.charging_robot_count .. " robots with " .. cell.to_charge_robot_count .. " in queue, " .. 
            " stationed " .. cell.stationed_logistic_robot_count .. " logistic robots and " .. cell.stationed_construction_robot_count .. " construction robots " ..
            " and " .. port.get_inventory(defines.inventory.roboport_material).get_item_count() .. " repair packs "
   return result
end

function roboport_neighbours_info(port)
   local result = ""
   local cell = port.logistic_cell
   local neighbour_count = #cell.neighbours
   local neighbour_dirs = ""
   for i, neighbour in ipairs(cell.neighbours) do 
      local dir = direction_lookup(get_direction_of_that_from_this(neighbour.owner.position, port.position))
      if i > 1 then
         neighbour_dirs = neighbour_dirs .. " and "
      end
      neighbour_dirs = neighbour_dirs .. dir 
   end
   if neighbour_count > 0 then 
      result = neighbour_count .. " neighbours" .. ", at the " .. neighbour_dirs
   else
      result = neighbour_count .. " neighbours"
   end
   
   return result
end

function logistic_network_members_info(port)
   local result = ""
   local cell = port.logistic_cell
   local nw = cell.logistic_network
   if nw == nil or nw.valid == false then
      result = " Error: no network "
      return result
   end
   result = " Network has " .. #nw.cells .. " roboports, and " .. nw.all_logistic_robots .. " logistic robots with " .. nw.available_logistic_robots .. " available, and " .. nw.all_construction_robots .. " construction robots with " .. nw.available_construction_robots .. " available "
   return result
end

function logistic_network_chests_info(port)
   local result = ""
   local cell = port.logistic_cell
   local nw = cell.logistic_network
   
   if nw == nil or nw.valid == false then
      result = " Error, no network "
      return result
   end
   
   local storage_chest_count = 0
   for i,ent in ipairs(nw.storage_points) do 
      if ent.owner.type == "logistic-container" then
         storage_chest_count = storage_chest_count + 1
      end
   end
   local passive_provider_chest_count = 0
   for i,ent in ipairs(nw.passive_provider_points) do 
      if ent.owner.type == "logistic-container" then
         passive_provider_chest_count = passive_provider_chest_count + 1
      end
   end
   local active_provider_chest_count = 0
   for i,ent in ipairs(nw.active_provider_points) do 
      if ent.owner.type == "logistic-container" then
         active_provider_chest_count = active_provider_chest_count + 1
      end
   end
   local requester_chest_count = 0
   for i,ent in ipairs(nw.requester_points) do 
      if ent.owner.type == "logistic-container" then
         requester_chest_count = requester_chest_count + 1
      end
   end
   local total_chest_count = storage_chest_count + passive_provider_chest_count + active_provider_chest_count + requester_chest_count
   result = " Network has " .. total_chest_count .. " chests in total, with " ..
            storage_chest_count .. " storage chests, " .. 
            passive_provider_chest_count .. " passive provider chests, " .. 
            active_provider_chest_count .. " active provider chests, " .. 
            requester_chest_count .. " requester chests or buffer chests, "
   --game.print(result,{volume_modifier=0})--
   return result
end

function logistic_network_items_info(port)
   local result = " Network "
   local nw = port.logistic_cell.logistic_network
   if nw == nil or nw.valid == false then
      result = " Error: no network "
      return result
   end
   local itemset = nw.get_contents()
   local itemtable = {}
   for name, count in pairs(itemset) do
      table.insert(itemtable, {name = name, count = count})
   end
   table.sort(itemtable, function(k1, k2)
      return k1.count > k2.count
   end)
   if #itemtable == 0 then
      result = result .. " contains no items. "
   else
      result = result .. " contains " .. itemtable[1].name .. " times " .. itemtable[1].count .. ", "
      if #itemtable > 1 then
         result = result .. " and " .. itemtable[2].name .. " times " .. itemtable[2].count .. ", "
      end
      if #itemtable > 2 then
         result = result .. " and " .. itemtable[3].name .. " times " .. itemtable[3].count .. ", "
      end
      if #itemtable > 3 then
         result = result .. " and " .. itemtable[4].name .. " times " .. itemtable[4].count .. ", "
      end
      if #itemtable > 4 then
         result = result .. " and " .. itemtable[5].name .. " times " .. itemtable[5].count .. ", "
      end
      if #itemtable > 5 then
         result = result .. " and other items "
      end
   end
   return result
end

--laterdo add or remove stacks from player trash

--laterdo full personal logistics menu where you can go line by line along requests and edit them, iterate through trash?


-------------Blueprints------------

function get_bp_data_for_edit(stack)
   return game.json_to_table(game.decode_string(string.sub(stack.export_stack(),2)))
end

local function set_stack_bp_from_data(stack,bp_data)
   stack.import_stack("0"..game.encode_string(game.table_to_json(bp_data)))
end

function set_blueprint_description(stack,description)
   local bp_data = get_bp_data_for_edit(stack)
   bp_data.blueprint.description = description
   set_stack_bp_from_data(stack,bp_data)
end

function get_blueprint_description(stack)
   local bp_data = get_bp_data_for_edit(stack)
   local desc = bp_data.blueprint.description
   if desc == nil then
      desc = ""
   end
   return desc
end

function set_blueprint_label(stack,label)
   local bp_data=get_bp_data_for_edit(stack)
   bp_data.blueprint.label = label
   set_stack_bp_from_data(stack,bp_data)
end

function get_blueprint_label(stack)
   local bp_data = get_bp_data_for_edit(stack)
   local label = bp_data.blueprint.label
   if label == nil then
      label = ""
   end
   return label
end

function get_top_left_and_bottom_right(pos_1, pos_2)
   local top_left = {x = math.min(pos_1.x, pos_2.x), y = math.min(pos_1.y, pos_2.y)}
   local bottom_right = {x = math.max(pos_1.x, pos_2.x), y = math.max(pos_1.y, pos_2.y)}
   return top_left, bottom_right
end

--Create a blueprint from a rectangle between any two points and give it to the player's hand
function create_blueprint(pindex, point_1, point_2, prior_bp_data)
   local top_left, bottom_right = get_top_left_and_bottom_right(point_1, point_2)
   local p = game.get_player(pindex)
   if prior_bp_data ~= nil then
      --First clear the bp in hand
      p.cursor_stack.set_stack({name = "blueprint", count = 1})
   end
   if not p.cursor_stack.valid_for_read or p.cursor_stack.valid_for_read and not (p.cursor_stack.is_blueprint and p.cursor_stack.is_blueprint_setup() == false and prior_bp_data == nil) then
      local cleared = p.clear_cursor()
      if not cleared then
         printout("Error: cursor full.", pindex)
         return
      end
   end
   p.cursor_stack.set_stack({name = "blueprint"})
   p.cursor_stack.create_blueprint{surface = p.surface, force = p.force, area = {top_left,bottom_right}}
   
   --Avoid empty blueprints 
   local ent_count = p.cursor_stack.get_blueprint_entity_count()
   if ent_count == 0 then
      if prior_bp_data == nil then
         p.cursor_stack.set_stack({name = "blueprint"})
      end
      local result = "Blueprint selection area was empty, "
      if prior_bp_data ~= nil then
         result = result .. " keeping old entities "
      end
      printout(result, pindex)
   else
      local prior_name = ""
      if prior_bp_data ~= nil then
         prior_name = prior_bp_data.blueprint.label
      end
      printout("Blueprint ".. prior_name .. " with " .. ent_count .. " entities created in hand.", pindex)
   end
   
   --Copy label and description and icons from previous version
   if prior_bp_data ~= nil then
      local bp_data = get_bp_data_for_edit(p.cursor_stack)
      bp_data.blueprint.label = prior_bp_data.blueprint.label
      bp_data.blueprint.label_color = prior_bp_data.blueprint.label_color
      bp_data.blueprint.description = prior_bp_data.blueprint.description
      bp_data.blueprint.icons = prior_bp_data.blueprint.icons
      if ent_count == 0 then
         bp_data.blueprint.entities = prior_bp_data.blueprint.entities
      end
      set_stack_bp_from_data(p.cursor_stack,bp_data) 
   end
end 

--Building function for bluelprints
function paste_blueprint(pindex)
   local p = game.get_player(pindex)
   local bp = p.cursor_stack
   local pos = players[pindex].cursor_pos
   
   --Not a blueprint
   if bp.is_blueprint == false then
      return nil
   end
   --Empty blueprint
   if not bp.is_blueprint_setup() then
      return nil
   end
   
   --Get the offset blueprint positions
   local left_top, right_bottom, build_pos = get_blueprint_corners(pindex, false)
   
   --Clear build area (if not far away)
   if util.distance(p.position, build_pos) < 2 * p.reach_distance then
      clear_obstacles_in_rectangle(left_top, right_bottom, pindex)
   end
   
   --Build it and check if successful
   local dir = players[pindex].blueprint_hand_direction
   local result = bp.build_blueprint{surface = p.surface, force = p.force, position = build_pos, direction = dir, by_player = p, force_build = false}
   if result == nil or #result == 0 then
      p.play_sound{path = "utility/cannot_build"}
      --Explain build error
      local result = "Cannot place there "
      local build_area = {left_top, right_bottom}
      local ents_in_area = p.surface.find_entities_filtered{area = build_area, invert = true, type = ENT_TYPES_YOU_CAN_BUILD_OVER}
      local tiles_in_area = p.surface.find_tiles_filtered{area = build_area, invert = false, name = {"water", "deepwater", "water-green", "deepwater-green", "water-shallow", "water-mud", "water-wube"}}
      local obstacle_ent_name = nil
      local obstacle_tile_name = nil
      --Check for an entity in the way
      for i, area_ent in ipairs(ents_in_area) do 
         if area_ent.valid and area_ent.prototype.tile_width and area_ent.prototype.tile_width > 0 and area_ent.prototype.tile_height and area_ent.prototype.tile_height > 0 then
            obstacle_ent_name = localising.get(area_ent,pindex)
         end
      end
      
      --Report obstacles
      if obstacle_ent_name ~= nil then
         result = result .. ", " .. obstacle_ent_name .. " in the way."
      elseif #tiles_in_area > 0 then
         result = result .. ", water is in the way."
      end
      printout(result, pindex)
      return false
   else
      p.play_sound{path = "Close-Inventory-Sound"}--laterdo maybe better blueprint placement sound
      printout("Placed blueprint "  .. get_blueprint_label(bp), pindex)
      return true
   end
end

--Returns the left top and right bottom corners of the blueprint
function get_blueprint_corners(pindex, draw_rect)
   local p = game.get_player(pindex)
   local bp = p.cursor_stack
   if bp == nil or bp.valid_for_read == false or bp.is_blueprint == false then
      return nil, nil
   end
   local pos = players[pindex].cursor_pos
   local ents = bp.get_blueprint_entities()
   local west_most_x = nil 
   local east_most_x = nil
   local north_most_y = nil
   local south_most_y = nil
   
   --Empty blueprint: Just circle the cursor 
   if bp.is_blueprint_setup() == false then
      local left_top = {x = math.floor(pos.x), y = math.floor(pos.y)}
      local right_bottom = {x = math.ceil(pos.x), y = math.ceil(pos.y)}
      --local rect = rendering.draw_rectangle{left_top = left_top, right_bottom = right_bottom, color = {r = 0.25, b = 0.25, g = 1.0, a = 0.75}, draw_on_ground = true, surface = game.get_player(pindex).surface, players = nil }
      return left_top, right_bottom, pos
   end
   
   --Find the blueprint borders and corners 
   for i, ent in ipairs(ents) do 
      local ent_width = game.entity_prototypes[ent.name].tile_width
      local ent_height = game.entity_prototypes[ent.name].tile_height
      if ent.direction == dirs.east or ent.direction == dirs.west then
         ent_width = game.entity_prototypes[ent.name].tile_height
         ent_height = game.entity_prototypes[ent.name].tile_width
      end
      local ent_north = ent.position.y - math.floor(ent_height/2)
      local ent_east  = ent.position.x + math.floor(ent_width/2)
      local ent_south = ent.position.y + math.floor(ent_height/2)
      local ent_west  = ent.position.x - math.floor(ent_width/2)
      if west_most_x == nil then
         west_most_x = ent_west 
         east_most_x = ent_east
         north_most_y = ent_north
         south_most_y = ent_south
      end
      if west_most_x > ent_west then
         west_most_x = ent_west
      end
      if east_most_x < ent_east then 
         east_most_x = ent_east
      end
      if north_most_y > ent_north then
         north_most_y = ent_north
      end
      if south_most_y < ent_south then
         south_most_y = ent_south 
      end
   end
   local bp_left_top = {x = math.floor(west_most_x), y = math.floor(north_most_y)}
   local bp_right_bottom = {x = math.ceil(east_most_x), y = math.ceil(south_most_y)}
   local bp_width = bp_right_bottom.x - bp_left_top.x - 1
   local bp_height = bp_right_bottom.y - bp_left_top.y - 1
   if players[pindex].blueprint_hand_direction == dirs.east or players[pindex].blueprint_hand_direction == dirs.west then
      --Flip width and height
      bp_width = bp_right_bottom.y - bp_left_top.y - 1
      bp_height = bp_right_bottom.x - bp_left_top.x - 1
   end
   local left_top = {x = math.floor(pos.x), y = math.floor(pos.y)}
   local right_bottom = {x = math.ceil(pos.x + bp_width), y = math.ceil(pos.y + bp_height)}
   
   --Draw the build preview (default is false)
   if draw_rect == true then
      --Draw a temporary rectangle for debugging
      rendering.draw_rectangle{left_top = left_top, right_bottom = right_bottom, color = {r = 0.25, b = 0.25, g = 1.0, a = 0.75}, width = 2, draw_on_ground = true, surface = p.surface, players = nil, time_to_live = 100}
   end
   
   --Get the mouse pointer position
   local mouse_pos = {x = pos.x + bp_width/2, y = pos.y + bp_height/2}
   
   return left_top, right_bottom, mouse_pos
end 

function get_blueprint_width_and_height(pindex)
   local p = game.get_player(pindex)
   local bp = p.cursor_stack
   if bp == nil or bp.valid_for_read == false or bp.is_blueprint == false then
      return nil, nil
   end
   local pos = players[pindex].cursor_pos
   local ents = bp.get_blueprint_entities()
   local west_most_x = nil 
   local east_most_x = nil
   local north_most_y = nil
   local south_most_y = nil
   
   --Empty blueprint
   if bp.is_blueprint_setup() == false then
      return 0, 0
   end
   
   --Find the blueprint borders and corners 
   for i, ent in ipairs(ents) do 
      local ent_width = game.entity_prototypes[ent.name].tile_width
      local ent_height = game.entity_prototypes[ent.name].tile_height
      if ent.direction == dirs.east or ent.direction == dirs.west then
         ent_width = game.entity_prototypes[ent.name].tile_height
         ent_height = game.entity_prototypes[ent.name].tile_width
      end
      local ent_north = ent.position.y - math.floor(ent_height/2)
      local ent_east  = ent.position.x + math.floor(ent_width/2)
      local ent_south = ent.position.y + math.floor(ent_height/2)
      local ent_west  = ent.position.x - math.floor(ent_width/2)
      if west_most_x == nil then
         west_most_x = ent_west 
         east_most_x = ent_east
         north_most_y = ent_north
         south_most_y = ent_south
      end
      if west_most_x > ent_west then
         west_most_x = ent_west
      end
      if east_most_x < ent_east then 
         east_most_x = ent_east
      end
      if north_most_y > ent_north then
         north_most_y = ent_north
      end
      if south_most_y < ent_south then
         south_most_y = ent_south 
      end
   end
   local bp_left_top = {x = math.floor(west_most_x), y = math.floor(north_most_y)}
   local bp_right_bottom = {x = math.ceil(east_most_x), y = math.ceil(south_most_y)}
   local bp_width = bp_right_bottom.x - bp_left_top.x - 1
   local bp_height = bp_right_bottom.y - bp_left_top.y - 1
   if players[pindex].blueprint_hand_direction == dirs.east or players[pindex].blueprint_hand_direction == dirs.west then
      --Flip width and height
      bp_width = bp_right_bottom.y - bp_left_top.y - 1
      bp_height = bp_right_bottom.x - bp_left_top.x - 1
   end
   return bp_width, bp_height
end 

--Export and import the same blueprint so that its parameters reset, e.g. rotation.
function refresh_blueprint_in_hand(pindex)
   local p = game.get_player(pindex)
   if p.cursor_stack.is_blueprint_setup() == false then 
      return 
   end
   local bp_data = get_bp_data_for_edit(p.cursor_stack)
   set_stack_bp_from_data(p.cursor_stack, bp_data)
end

--Basic info for when the blueprint item is read.
function get_blueprint_info(stack, in_hand)
   --Not a blueprint
   if stack.is_blueprint == false then
      return ""
   end
   --Empty blueprint
   if not stack.is_blueprint_setup() then
      return "Blueprint empty"
   end
   
   --Get name
   local name = get_blueprint_label(stack)
   if name == nil then
      name = ""
   end
   --Construct result 
   local result = "Blueprint " .. name .. " features "
   if in_hand then
      result = "Blueprint " .. name .. "in hand, features "
   end
   --Use icons as extra info (in case it is not named)
   local icons = stack.blueprint_icons
   if icons == nil or #icons == 0 then
      result = result .. " no details "
      return result
   end
   
   for i, signal in ipairs(icons) do 
      if signal.index > 1 then
         result = result .. " and "
      end
      result = result .. signal.signal.name
   end
   
   result = result .. ", " .. stack.get_blueprint_entity_count() .. " entities in total "
   --game.print(result)
   return result
end

function get_blueprint_icons_info(bp_table)
   local result = ""
   --Use icons as extra info (in case it is not named)
   local icons = bp_table.icons
   if icons == nil or #icons == 0 then
      result = result .. " no icons "
      return result
   end
   
   for i, signal in ipairs(icons) do 
      if signal.index > 1 then
         result = result .. " and "
      end
      result = result .. signal.signal.name
   end
   return result
end

function apply_blueprint_import(pindex, text)
   local bp = game.get_player(pindex).cursor_stack
   --local result = bp.import_stack("0"..text)
   local result = bp.import_stack(text)
   if result == 0 then
      if bp.is_blueprint then
         printout("Successfully imported blueprint " .. get_blueprint_label(bp), pindex)
      elseif bp.is_blueprint_book then
         printout("Successfully imported blueprint book ", pindex)
      else
         printout("Successfully imported unknown planner item", pindex)
      end
   elseif result == -1 then 
      if bp.is_blueprint then
         printout("Imported with errors, blueprint " .. get_blueprint_label(bp), pindex)
      elseif bp.is_blueprint_book then
         printout("Imported with errors, blueprint book ", pindex)
      else
         printout("Imported with errors, unknown planner item", pindex)
      end
   else--result == 1
      printout("Failed to import blueprint item", pindex)
   end
end

--[[ Blueprint menu options summary
   0. name, menu instructions
   1. Read the description of this blueprint
   2. Read the icons of this blueprint, which are its features components
   3. Read the blueprint dimensions and total component count
   4. List all components of this blueprint
   5. List all missing components for building this blueprint 
   6. Edit the label of this blueprint
   7. Edit the description of this blueprint
   8. Create a copy of this blueprint
   9. Clear this blueprint 
   10. Export this blueprint as a text string
   11. Import a text string to overwrite this blueprint
   12. Reselect the area for this blueprint 
   13. Use the last selected area to reselect this blueprint --todo add***

   This menu opens when you press RIGHT BRACKET on a blueprint in hand 
]]
function blueprint_menu(menu_index, pindex, clicked, other_input)
   local index = menu_index
   local other = other_input or -1
   local p = game.get_player(pindex)
   local bp = p.cursor_stack
   
   if bp.is_blueprint_setup() == false then
      if index == 0 then
         --Give basic info ...
         printout("Empty blueprint with limited options" 
         .. ", Press 'W' and 'S' to navigate options, press 'LEFT BRACKET' to select an option or press 'E' to exit this menu.", pindex)
      elseif index == 1 then 
         --Import a text string to save into this blueprint
         if not clicked then
            local result = "Import a text string to fill this blueprint"
            printout(result, pindex)
         else
            players[pindex].blueprint_menu.edit_import = true
            local frame = game.get_player(pindex).gui.screen.add{type = "frame", name = "blueprint-edit-import"}
            frame.bring_to_front()
            frame.force_auto_center()
            frame.focus()
            local input = frame.add{type="textfield", name = "input"}
            input.focus()
            local result = "Paste a copied blueprint text string in this box and then press ENTER to load it"
            printout(result, pindex)
         end
      --elseif index == 2 then --use last selected area ***
      else 
         players[pindex].blueprint_menu.index = 0
         p.play_sound{path = "inventory-wrap-around"}
         printout("Empty blueprint with limited options" 
         .. ", Press 'W' and 'S' to navigate options, press 'LEFT BRACKET' to select an option or press 'E' to exit this menu.", pindex)
      end
      return
   end
   
   if index == 0 then
      --Give basic info ...
      printout("Blueprint " .. get_blueprint_label(bp) 
      .. ", Press 'W' and 'S' to navigate options, press 'LEFT BRACKET' to select an option or press 'E' to exit this menu.", pindex)
   elseif index == 1 then
      --Read the description of this blueprint
      if not clicked then
         local result = "Read the description of this blueprint"
         printout(result, pindex)
      else
         local result = get_blueprint_description(bp)
         if result == nil or result == "" then
            result = "no description"
         end
         printout(result, pindex)
      end
   elseif index == 2 then
      --Read the icons of this blueprint, which are its features components
      if not clicked then
         local result = "Read the icons of this blueprint, which are its featured components"
         printout(result, pindex)
      else
         local result = "This blueprint features "
         if bp.blueprint_icons and #bp.blueprint_icons > 0 then
            --Icon 1
            if bp.blueprint_icons[1] ~= nil then
               result = result .. bp.blueprint_icons[1].signal.name .. ", "
            end
            if bp.blueprint_icons[2] ~= nil then
               result = result .. bp.blueprint_icons[2].signal.name .. ", "
            end
            if bp.blueprint_icons[3] ~= nil then
               result = result .. bp.blueprint_icons[3].signal.name .. ", "
            end
            if bp.blueprint_icons[4] ~= nil then
               result = result .. bp.blueprint_icons[4].signal.name .. ", "
            end
         else
            result = result .. "nothing"
         end
         printout(result, pindex)
      end
   elseif index == 3 then
       --Read the blueprint dimensions and total component count
      if not clicked then
         local result = "Read the blueprint dimensions and total component count"
         printout(result, pindex)
      else
         local count = bp.get_blueprint_entity_count()
         local width, height = get_blueprint_width_and_height(pindex)
         local result = "This blueprint is " .. width .. " tiles wide and " .. height .. " tiles high and contains " .. count .. " entities "
         printout(result, pindex)
      end
   elseif index == 4 then
      --List all components of this blueprint
      if not clicked then
         local result = "List all components of this blueprint"
         printout(result, pindex)
      else
         --Create a table of entity counts
         local ents = bp.get_blueprint_entities()
         local ent_counts = {}
         local unique_ent_count = 0
         --p.print("blueprint total entity count: " .. #ents)--
         for i, ent in ipairs(ents) do 
            local str = ent.name
            if ent_counts[str] == nil then
               ent_counts[str] = 1
               --p.print("adding " .. str)--
               unique_ent_count = unique_ent_count + 1
            else
               ent_counts[str] = ent_counts[str] + 1
               --p.print(str .. " x " .. ent_counts[str])--
            end
         end
         --p.print("blueprint unique entity count: " .. unique_ent_count)
         --Sort by count
         table.sort(ent_counts, function(a,b)
            return ent_counts[a] < ent_counts[b]
         end)
         --List results
         local result = "Blueprint contains "
         for name, count in pairs(ent_counts) do 
            result = result .. count .. " " .. name .. ", "
         end
         if unique_ent_count == 0 then
            result = result .. "nothing"
         end
         printout(result, pindex)
         --p.print(result)--
      end
   elseif index == 5 then
      --List all missing components for building this blueprint from your inventory
      if not clicked then
         local result = "List all missing components for building this blueprint from your inventory"
         printout(result, pindex)
      else
         --Create a table of entity counts
         local ents = bp.get_blueprint_entities()
         local ent_counts = {}
         local unique_ent_count = 0
         --p.print("blueprint total entity count: " .. #ents)--
         for i, ent in ipairs(ents) do 
            local str = ent.name
            if ent_counts[str] == nil then
               ent_counts[str] = 1
               --p.print("adding " .. str)--
               unique_ent_count = unique_ent_count + 1
            else
               ent_counts[str] = ent_counts[str] + 1
               --p.print(str .. " x " .. ent_counts[str])--
            end
         end
         --p.print("blueprint unique entity count: " .. unique_ent_count)
         --Subtract inventory amounts
         local result = "Blueprint contains "
         for name, count in pairs(ent_counts) do 
            local inv_count = p.get_main_inventory().get_item_count(name)
            if inv_count >= count then
               ent_counts[name] = 0
            else
               ent_counts[name] = ent_counts[name] - inv_count
            end
         end
         --Sort by count
         table.sort(ent_counts, function(a,b)
            return ent_counts[a] < ent_counts[b]
         end)
         --Read results
         local result = "You are missing "
         unique_ent_count = 0
         for name, count in pairs(ent_counts) do 
            if count > 0 then
               result = result .. count .. " " .. name .. ", "
               unique_ent_count = unique_ent_count + 1
            end
         end
         if unique_ent_count == 0 then
            result = result .. "nothing"
         end
         result = result .. " to build this blueprint "
         printout(result, pindex)
         --p.print(result)--
      end
   elseif index == 6 then
      --Rename this blueprint (edit its label)
      if not clicked then
         local result = "Rename this blueprint"
         printout(result, pindex)
      else
         players[pindex].blueprint_menu.edit_label = true
         local frame = game.get_player(pindex).gui.screen.add{type = "frame", name = "blueprint-edit-label"}
         frame.bring_to_front()
         frame.force_auto_center()
         frame.focus()
         local input = frame.add{type="textfield", name = "input"}
         input.focus()
         local result = "Type in a new name for this blueprint and press 'ENTER' to confirm, or press 'ESC' to cancel."
         printout(result, pindex)
      end
   elseif index == 7 then
      --Rewrite the description of this blueprint
      if not clicked then
         local result = "Rewrite the description of this blueprint"
         printout(result, pindex)
      else
         players[pindex].blueprint_menu.edit_description = true
         local frame = game.get_player(pindex).gui.screen.add{type = "frame", name = "blueprint-edit-description"}
         frame.bring_to_front()
         frame.force_auto_center()
         frame.focus()
         local input = frame.add{type="textfield", name = "input"}--, text = get_blueprint_description(bp)}
         input.focus()
         local result = "Type in the new description text box for this blueprint and press 'ENTER' to confirm, or press 'ESC' to cancel."
         printout(result, pindex)
      end
   elseif index == 8 then
      --Create a copy of this blueprint
      if not clicked then
         local result = "Create a copy of this blueprint"
         printout(result, pindex)
      else
         p.insert(table.deepcopy(bp))
         local result = "Blue print copy inserted to inventory"
         printout(result, pindex)
      end
   elseif index == 9 then
      --Delete this blueprint
      if not clicked then
         local result = "Delete this blueprint"
         printout(result, pindex)
      else
         bp.set_stack({name = "blueprint", count = 1})
         bp.set_stack(nil)--calls event handler to delete empty planners.
         local result = "Blueprint deleted and menu closed"
         printout(result, pindex)
         blueprint_menu_close(pindex)
      end
   elseif index == 10 then
      --Export this blueprint as a text string
      if not clicked then
         local result = "Export this blueprint as a text string"
         printout(result, pindex)
      else
         players[pindex].blueprint_menu.edit_export = true
         local frame = game.get_player(pindex).gui.screen.add{type = "frame", name = "blueprint-edit-export"}
         frame.bring_to_front()
         frame.force_auto_center()
         frame.focus()
         local input = frame.add{type="textfield", name = "input", text = bp.export_stack()} 
         input.focus()
         local result = "Copy the text from this boz using 'CONTROL + A' and then 'CONTROL + C' and then press ENTER to exit"
         printout(result, pindex)
      end
   elseif index == 11 then
      --Import a text string to save into this blueprint
      if not clicked then
         local result = "Import a text string to save into this blueprint"
         printout(result, pindex)
      else
         players[pindex].blueprint_menu.edit_import = true
         local frame = game.get_player(pindex).gui.screen.add{type = "frame", name = "blueprint-edit-import"}
         frame.bring_to_front()
         frame.force_auto_center()
         frame.focus()
         local input = frame.add{type="textfield", name = "input"}
         input.focus()
         local result = "Paste a copied blueprint text string in this box and then press ENTER to load it"
         printout(result, pindex)
      end
   elseif index == 12 then
      --Reselect the area for this blueprint
      if not clicked then
         local result = "Re-select the area for this blueprint"
         printout(result, pindex)
      else
         players[pindex].blueprint_reselecting = true
         local result = "Select the first point now."
         printout(result, pindex)
         blueprint_menu_close(pindex, true)
      end
   end
end
BLUEPRINT_MENU_LENGTH = 12

function blueprint_menu_open(pindex)
   if players[pindex].vanilla_mode then
      return 
   end
   --Set the player menu tracker to this menu
   players[pindex].menu = "blueprint_menu"
   players[pindex].in_menu = true
   players[pindex].move_queue = {}
   
   --Set the menu line counter to 0
   players[pindex].blueprint_menu = {
      index = 0,
      edit_label = false,
      edit_description = false,
      edit_export = false,
      edit_import = false
      }
   
   --Play sound
   game.get_player(pindex).play_sound{path = "Open-Inventory-Sound"}
   
   --Load menu 
   blueprint_menu(players[pindex].blueprint_menu.index, pindex, false)
end

function blueprint_menu_close(pindex, mute_in)
   local mute = mute_in
   --Set the player menu tracker to none
   players[pindex].menu = "none"
   players[pindex].in_menu = false

   --Set the menu line counter to 0
   players[pindex].blueprint_menu.index = 0
   
   --play sound
   if not mute then
      game.get_player(pindex).play_sound{path="Close-Inventory-Sound"}
   end
   
   --Destroy text fields
   if game.get_player(pindex).gui.screen["blueprint-edit-label"] ~= nil then 
      game.get_player(pindex).gui.screen["blueprint-edit-label"].destroy()
   end
   if game.get_player(pindex).gui.screen["blueprint-edit-description"] ~= nil then 
      game.get_player(pindex).gui.screen["blueprint-edit-description"].destroy()
   end
   if game.get_player(pindex).gui.screen["blueprint-edit-export"] ~= nil then 
      game.get_player(pindex).gui.screen["blueprint-edit-export"].destroy()
   end
   if game.get_player(pindex).gui.screen["blueprint-edit-import"] ~= nil then
      game.get_player(pindex).gui.screen["blueprint-edit-import"].destroy()
   end
   if game.get_player(pindex).opened ~= nil then
      game.get_player(pindex).opened = nil
   end
end

function blueprint_menu_up(pindex)
   players[pindex].blueprint_menu.index = players[pindex].blueprint_menu.index - 1
   if players[pindex].blueprint_menu.index < 0 then
      players[pindex].blueprint_menu.index = 0
      game.get_player(pindex).play_sound{path = "inventory-edge"}
   else
      --Play sound
      game.get_player(pindex).play_sound{path = "Inventory-Move"}
   end
   --Load menu
   blueprint_menu(players[pindex].blueprint_menu.index, pindex, false)
end

function blueprint_menu_down(pindex)
   players[pindex].blueprint_menu.index = players[pindex].blueprint_menu.index + 1
   if players[pindex].blueprint_menu.index > BLUEPRINT_MENU_LENGTH then
      players[pindex].blueprint_menu.index = BLUEPRINT_MENU_LENGTH
      game.get_player(pindex).play_sound{path = "inventory-edge"}
   else
      --Play sound
      game.get_player(pindex).play_sound{path = "Inventory-Move"}
   end
   --Load menu
   blueprint_menu(players[pindex].blueprint_menu.index, pindex, false)
end

function get_bp_book_data_for_edit(stack)
   --return game.json_to_table(game.decode_string(string.sub(stack.export_stack(),2)))
   return game.json_to_table(game.decode_string(string.sub(stack.export_stack(),2)))
end

--We run the export just once because it eats UPS
local function set_bp_book_data_from_cursor(pindex)
   players[pindex].blueprint_book_menu.book_data = get_bp_book_data_for_edit(game.get_player(pindex).cursor_stack)
end

function blueprint_book_get_name(pindex)
   local bp_data = players[pindex].blueprint_book_menu.book_data
   local label = bp_data.blueprint_book.label
   if label == nil then
      label = ""
   end
   return label
end

function blueprint_book_set_name(pindex, new_name)
   local bp_data = players[pindex].blueprint_book_menu.book_data
   bp_data.blueprint_book.label = label
   set_stack_bp_from_data(stack,bp_data)
end

function blueprint_book_get_item_count(pindex)
   local bp_data = players[pindex].blueprint_book_menu.book_data
   local items = bp_data.blueprint_book.blueprints
   if items == nil or items == {} then
      return 0 
   else
      return #items
   end
end

function blueprint_book_data_get_item_count(book_data)
   local items = bp_data.blueprint_book.blueprints
   if items == nil or items == {} then
      return 0 
   else
      return #items
   end
end

function blueprint_book_read_item(pindex,i)
   local bp_data = players[pindex].blueprint_book_menu.book_data
   local items = bp_data.blueprint_book.blueprints
   return items[i]["blueprint"]
end

--Puts the book away and imports the selected blueprint to hand 
function blueprint_book_copy_item_to_hand(pindex,i)
   local bp_data = players[pindex].blueprint_book_menu.book_data
   local items = bp_data.blueprint_book.blueprints
   local item = items[i]["blueprint"]
   local item_string = "0" .. game.encode_string(game.table_to_json(items[i]))
   
   local p = game.get_player(pindex) 
   p.clear_cursor()
   p.cursor_stack.import_stack(item_string)
   printout("Copied blueprint to hand",pindex)
end

function blueprint_book_take_out_item(pindex,index)
   --todo ***
end

function blueprint_book_add_item(pindex,bp)
   --todo ***
end

--[[ Blueprint book menu options summary
   List Mode (Press LEFT BRACKET on the BPB in hand)
   0. name, menu instructions
   X. Read/copy/take out blueprint number X
   
   Settings Mode (Press RIGHT BRACKET on the BPB in hand)
   0. name, bp count, menu instructions
   1. Read the description (?) and icons (?) of this blueprint book, which are its featured components
   2. Rename this book 
   3. Create a copy of this blueprint book
   4. Clear this blueprint book 
   5. Export this blueprint book as a text string
   6. Import a text string to overwrite this blueprint book

   Note: BPB normally supports description and icons, but it is unclear whether the json tables can access these.
]]
function blueprint_book_menu(pindex, menu_index, list_mode, left_clicked, right_clicked)
   local index = menu_index
   local p = game.get_player(pindex)
   local bpb = p.cursor_stack
   local item_count = blueprint_book_get_item_count(pindex)
   --Update menu length
   players[pindex].blueprint_book_menu.menu_length = BLUEPRINT_BOOK_SETTINGS_MENU_LENGTH
   if list_mode then 
      players[pindex].blueprint_book_menu.menu_length = item_count
   end
   
   --Run menu
   if list_mode then
      --Blueprint book list mode 
      if index == 0 then
         --stuff
         printout("Browsing blueprint book "  .. blueprint_book_get_name(pindex) .. ", with "  .. item_count .. " items,"
         .. ", Press 'W' and 'S' to navigate options, press 'LEFT BRACKET' to copy a blueprint to hand, press 'E' to exit this menu.", pindex)
      else
         --Examine items 
         local item = blueprint_book_read_item(pindex, index)
         local name = ""
         if item == nil or item.item == nil then
            name = "Unknown item (" .. index .. ")"
         elseif item.item == "blueprint" then
            local label = item.label
            if label == nil then
               label = ""
            end
            name = "Blueprint " .. label .. ", featuring " .. get_blueprint_icons_info(item)
         elseif item.item == "blueprint-book" or item.item == "blueprint_book" or item.item == "book" then
            local label = item.label
            if label == nil then
               label = ""
            end
            name = "Blueprint book " .. label .. ", with " .. blueprint_book_data_get_item_count(book_data) .. " items "
         else
            name = "unknown item " .. item.item
         end
         if left_clicked == false and right_clicked == false then 
            --Read blueprint info
            local result = name
            printout(result, pindex)
         elseif left_clicked == true  and right_clicked == false then 
            --Copy the blueprint to hand
            if item == nil or item.item == nil then
               printout("Cannot get this.", pindex)
            elseif item.item == "blueprint" or item.item == "blueprint-book" then
               blueprint_book_copy_item_to_hand(pindex,index)
            else
               printout("Cannot get this.", pindex)
            end
         elseif left_clicked == false and right_clicked == true  then 
            --Take the blueprint to hand (Therefore both copy and delete)
            --...
         end
      end
   else
      --Blueprint book settings mode 
      if true then
         printout("Settings for blueprint book "  .. blueprint_book_get_name(pindex) .. " not yet implemented ", pindex)--***
      elseif index == 0 then
         printout("Settings for blueprint book "  .. blueprint_book_get_name(pindex) .. ", with "  .. item_count .. " items,"
         .. " Press 'W' and 'S' to navigate options, press 'LEFT BRACKET' to select, press 'E' to exit this menu.", pindex)
      elseif index == 1 then
         --Read the icons of this blueprint book, which are its featured components
         if left_clicked ~= true then
            local result = "Read the icons of this blueprint book, which are its featured components"
            printout(result, pindex)
         else
            --Stuff ***
         end
      elseif index == 2 then
         --Rename this book
         if left_clicked ~= true then
            local result = "Rename this book"
            printout(result, pindex)
         else
            --Stuff ***
         end
      elseif index == 3 then
         --Create a copy of this blueprint book
         if left_clicked ~= true then
            local result = "Create a copy of this blueprint book"
            printout(result, pindex)
         else
            --Stuff ***
         end
      elseif index == 4 then
         --Clear this blueprint book 
         if left_clicked ~= true then
            local result = "Clear this blueprint book"
            printout(result, pindex)
         else
            --Stuff ***
         end
      elseif index == 5 then
         --Export this blueprint book as a text string 
         if left_clicked ~= true then
            local result = "Export this blueprint book as a text string"
            printout(result, pindex)
         else
            --Stuff ***
         end
      elseif index == 6 then
         --Import a text string to overwrite this blueprint book
         if left_clicked ~= true then
            local result = "Import a text string to overwrite this blueprint book"
            printout(result, pindex)
         else
            --Stuff ***
         end
      end
   end 
end
BLUEPRINT_BOOK_SETTINGS_MENU_LENGTH = 1

function blueprint_book_menu_open(pindex, open_in_list_mode)
   if players[pindex].vanilla_mode then
      return 
   end
   --Set the player menu tracker to this menu
   players[pindex].menu = "blueprint_book_menu"
   players[pindex].in_menu = true
   players[pindex].move_queue = {}
   
   --Set the menu line counter to 0
   players[pindex].blueprint_book_menu = {
      book_data = nil,
      index = 0,
      menu_length = 0,
      list_mode = open_in_list_mode, 
      edit_label = false,
      edit_description = false,
      edit_export = false,
      edit_import = false
      }
   set_bp_book_data_from_cursor(pindex)
   
   --Play sound
   game.get_player(pindex).play_sound{path = "Open-Inventory-Sound"}
   
   --Load menu 
   local bpb_menu = players[pindex].blueprint_book_menu
   blueprint_book_menu(pindex, bpb_menu.index, bpb_menu.list_mode, false, false)
end

function blueprint_book_menu_close(pindex, mute_in)
   local mute = mute_in
   --Set the player menu tracker to none
   players[pindex].menu = "none"
   players[pindex].in_menu = false

   --Set the menu line counter to 0
   players[pindex].blueprint_book_menu.index = 0
   
   --play sound
   if not mute then
      game.get_player(pindex).play_sound{path="Close-Inventory-Sound"}
   end
   
   --Destroy text fields
   if game.get_player(pindex).gui.screen["blueprint-book-edit-label"] ~= nil then 
      game.get_player(pindex).gui.screen["blueprint-book-edit-label"].destroy()
   end
   if game.get_player(pindex).gui.screen["blueprint-book-edit-description"] ~= nil then 
      game.get_player(pindex).gui.screen["blueprint-book-edit-description"].destroy()
   end
   if game.get_player(pindex).gui.screen["blueprint-book-edit-export"] ~= nil then 
      game.get_player(pindex).gui.screen["blueprint-book-edit-export"].destroy()
   end
   if game.get_player(pindex).gui.screen["blueprint-book-edit-import"] ~= nil then
      game.get_player(pindex).gui.screen["blueprint-book-edit-import"].destroy()
   end
   if game.get_player(pindex).opened ~= nil then
      game.get_player(pindex).opened = nil
   end
end

function blueprint_book_menu_up(pindex)
   players[pindex].blueprint_book_menu.index = players[pindex].blueprint_book_menu.index - 1
   if players[pindex].blueprint_book_menu.index < 0 then
      players[pindex].blueprint_book_menu.index = 0
      game.get_player(pindex).play_sound{path = "inventory-edge"}
   else
      --Play sound
      game.get_player(pindex).play_sound{path = "Inventory-Move"}
   end
   --Load menu
   local bpb_menu = players[pindex].blueprint_book_menu
   blueprint_book_menu(pindex, bpb_menu.index, bpb_menu.list_mode, false, false)
end

function blueprint_book_menu_down(pindex)
   players[pindex].blueprint_book_menu.index = players[pindex].blueprint_book_menu.index + 1
   if players[pindex].blueprint_book_menu.index > players[pindex].blueprint_book_menu.menu_length then
      players[pindex].blueprint_book_menu.index = players[pindex].blueprint_book_menu.menu_length
      game.get_player(pindex).play_sound{path = "inventory-edge"}
   else
      --Play sound
      game.get_player(pindex).play_sound{path = "Inventory-Move"}
   end
   --Load menu
   local bpb_menu = players[pindex].blueprint_book_menu
   blueprint_book_menu(pindex, bpb_menu.index, bpb_menu.list_mode, false, false)
end

