--Here: Info functions that are meant to be read out without much further processing.
--Examples: Selected entity info, pollution info, etc.
--Note: Some of these functions may later be moved to their own modules when sufficiently developed.
local dirs = defines.direction
local util = require("util")
local fa_utils = require("scripts.fa-utils")
local fa_localising = require("scripts.localising")
local fa_electrical = require("scripts.electrical")
local fa_equipment = require("scripts.equipment")
local fa_graphics = require("scripts.graphics")
local fa_building_tools = require("scripts.building-tools")
local fa_rails = require("scripts.rails")
local fa_trains = require("scripts.trains")
local fa_driving = require("scripts.driving")
local fa_belts = require("scripts.transport-belts")
local fa_bot_logistics = require("scripts.worker-robots")
local fa_circuits = require("scripts.circuit-networks")

local mod = {}

--Ent info: Gives the distance and direction of a fluidbox connection target?
--Todo: update to clarify comments and include localization
local function get_adjacent_source(box, pos, dir)
   local result = { position = pos, direction = "" }
   ebox = table.deepcopy(box)
   if dir == 1 or dir == 3 then
      ebox.left_top.x = box.left_top.y
      ebox.left_top.y = box.left_top.x
      ebox.right_bottom.x = box.right_bottom.y
      ebox.right_bottom.y = box.right_bottom.x
   end
   --   print(ebox.left_top.x .. " " .. ebox.left_top.y)
   ebox.left_top.x = math.ceil(ebox.left_top.x * 2) / 2
   ebox.left_top.y = math.ceil(ebox.left_top.y * 2) / 2
   ebox.right_bottom.x = math.floor(ebox.right_bottom.x * 2) / 2
   ebox.right_bottom.y = math.floor(ebox.right_bottom.y * 2) / 2

   if pos.x < ebox.left_top.x then
      result.position.x = result.position.x + 1
      result.direction = "West"
   elseif pos.x > ebox.right_bottom.x then
      result.position.x = result.position.x - 1
      result.direction = "East"
   elseif pos.y < ebox.left_top.y then
      result.position.y = result.position.y + 1
      result.direction = "North"
   elseif pos.y > ebox.right_bottom.y then
      result.position.y = result.position.y - 1
      result.direction = "South"
   end
   return result
end

--Outputs basic entity info, usually called when the cursor selects an entity.
function mod.ent_info(pindex, ent, description)
   local p = game.get_player(pindex)
   local result = fa_localising.get(ent, pindex)
   if result == nil or result == "" then result = ent.name end
   if game.players[pindex].name == "Crimso" then result = result .. " " .. ent.type .. " " end
   if ent.type == "resource" then
      if ent.name ~= "crude-oil" then
         result = result .. ", x " .. ent.amount
      else
         result = result .. ", x " .. math.floor(ent.amount / 3000) .. "%"
      end
   end
   if ent.name == "entity-ghost" then
      result = fa_localising.get(ent.ghost_prototype, pindex) .. " " .. fa_localising.get(ent, pindex)
   elseif ent.name == "straight-rail" or ent.name == "curved-rail" then
      return fa_rails.rail_ent_info(pindex, ent, description)
   end

   result = result .. (description or "")

   --Give character names
   if ent.name == "character" then
      local p = ent.player
      local p2 = ent.associated_player
      if p ~= nil and p.valid and p.name ~= nil and p.name ~= "" then
         result = result .. " " .. p.name
      elseif p2 ~= nil and p2.valid and p2.name ~= nil and p2.name ~= "" then
         result = result .. " " .. p2.name
      elseif p ~= nil and p.valid and p.index == pindex then
         result = result .. " you "
      elseif pindex ~= nil then
         result = result .. " " .. pindex
      else
         result = result .. " X "
      end

      if p ~= nil and p.valid and p.index == pindex and not players[pindex].cursor then return "" end
   elseif ent.name == "character-corpse" then
      if ent.character_corpse_player_index == pindex then
         result = result .. " of your character "
      elseif ent.character_corpse_player_index ~= nil then
         result = result .. " of another character "
      end
   end
   --Explain the contents of a container
   if ent.type == "container" or ent.type == "logistic-container" or ent.type == "infinity-container" then
      --Chests etc: Report the most common item and say "and other items" if there are other types.
      local itemset = ent.get_inventory(defines.inventory.chest).get_contents()
      local itemtable = {}
      for name, count in pairs(itemset) do
         table.insert(itemtable, { name = name, count = count })
      end
      table.sort(itemtable, function(k1, k2)
         return k1.count > k2.count
      end)
      if #itemtable == 0 then
         result = result .. " with nothing "
      else
         result = result
            .. " with "
            .. fa_localising.get_item_from_name(itemtable[1].name, pindex)
            .. " times "
            .. itemtable[1].count
            .. ", "
         if #itemtable > 1 then
            result = result
               .. " and "
               .. fa_localising.get_item_from_name(itemtable[2].name, pindex)
               .. " times "
               .. itemtable[2].count
               .. ", "
         end
         if #itemtable > 2 then
            result = result
               .. " and "
               .. fa_localising.get_item_from_name(itemtable[3].name, pindex)
               .. " times "
               .. itemtable[3].count
               .. ", "
         end
         if #itemtable > 3 then result = result .. "and other items " end
      end
      if ent.type == "logistic-container" then
         local network = ent.surface.find_logistic_network_by_position(ent.position, ent.force)
         if network == nil then
            local nearest_roboport = fa_utils.find_nearest_roboport(ent.surface, ent.position, 5000)
            if nearest_roboport == nil then
               result = result .. ", not in a network, no networks found within 5000 tiles"
            else
               local dist = math.ceil(util.distance(ent.position, nearest_roboport.position) - 25)
               local dir =
                  fa_utils.direction_lookup(fa_utils.get_direction_biased(nearest_roboport.position, ent.position))
               result = result
                  .. ", not in a network, nearest network "
                  .. nearest_roboport.backer_name
                  .. " is about "
                  .. dist
                  .. " to the "
                  .. dir
            end
         else
            local network_name = network.cells[1].owner.backer_name
            result = result .. ", in network " .. network_name
         end
      end
   elseif ent.name == "infinity-pipe" then
      local filter = ent.get_infinity_pipe_filter()
      if filter == nil then
         result = result .. " draining "
      else
         result = result .. " of " .. filter.name
      end
   end
   --Pipe ends are labelled to distinguish them
   if ent.name == "pipe" and fa_building_tools.is_a_pipe_end(ent, pindex) then result = result .. " end, " end
   --Explain the contents of a pipe or storage tank or etc.
   if
      ent.type == "pipe"
      or ent.type == "pipe-to-ground"
      or ent.type == "storage-tank"
      or ent.type == "pump"
      or ent.name == "boiler"
      or ent.name == "heat-exchanger"
      or ent.type == "generator"
   then
      local dict = ent.get_fluid_contents()
      local fluids = {}
      for name, count in pairs(dict) do
         table.insert(fluids, { name = name, count = count })
      end
      table.sort(fluids, function(k1, k2)
         return k1.count > k2.count
      end)
      if #fluids > 0 and fluids[1].count ~= nil then
         result = result
            .. " with "
            .. fa_localising.get_fluid_from_name(fluids[1].name, pindex)
            .. " times "
            .. math.floor(0.5 + fluids[1].count)
         if #fluids > 1 and fluids[2].count ~= nil then
            --This normally should not happen because it means different fluids mixed!
            result = result
               .. " and "
               .. fa_localising.get_fluid_from_name(fluids[2].name, pindex)
               .. " times "
               .. math.floor(0.5 + fluids[2].count)
         end
         if #fluids > 2 then result = result .. ", and other fluids " end
      else
         result = result .. " empty "
      end
   end
   --Explain the type and content of a transport belt
   if ent.type == "transport-belt" then
      --Check if corner or junction or end
      local sideload_count = 0
      local backload_count = 0
      local outload_count = 0
      local inputs = ent.belt_neighbours["inputs"]
      local outputs = ent.belt_neighbours["outputs"]
      local outload_dir = nil
      local outload_is_corner = false
      local this_dir = ent.direction
      for i, belt in pairs(inputs) do
         if ent.direction ~= belt.direction then
            sideload_count = sideload_count + 1
         else
            backload_count = backload_count + 1
         end
      end
      for i, belt in pairs(outputs) do
         outload_count = outload_count + 1
         outload_dir = belt.direction --Note: there should be only one of these belts anyway.2
         if belt.type == "transport-belt" and (belt.belt_shape == "right" or belt.belt_shape == "left") then
            outload_is_corner = true
         end
      end
      --Check what the neighbor info reveals about the belt
      local say_middle = false
      result = result
         .. fa_belts.transport_belt_junction_info(
            sideload_count,
            backload_count,
            outload_count,
            this_dir,
            outload_dir,
            say_middle,
            outload_is_corner
         )

      --Check contents
      local left = ent.get_transport_line(1).get_contents()
      local right = ent.get_transport_line(2).get_contents()

      for name, count in pairs(right) do
         if left[name] ~= nil then
            left[name] = left[name] + count
         else
            left[name] = count
         end
      end
      local contents = {}
      for name, count in pairs(left) do
         table.insert(contents, { name = name, count = count })
      end
      table.sort(contents, function(k1, k2)
         return k1.count > k2.count
      end)
      if #contents > 0 then
         result = result .. " carrying " .. fa_localising.get_item_from_name(contents[1].name, pindex) --***localize
         if #contents > 1 then
            result = result .. ", and " .. fa_localising.get_item_from_name(contents[2].name, pindex)
            if #contents > 2 then result = result .. ", and other item types " end
         end
      else
         --No currently carried items: Report recently carried items by checking the next belt over
         --Those items must be from this belt if this belt is the only input to the next belt and there are no inserters or loaders around it.
         local next_belt = ent.belt_neighbours["outputs"][1]
         local next_contents = {}
         local next_belt_nearby_inserters = nil
         if next_belt ~= nil then
            next_belt_nearby_inserters = next_belt.surface.find_entities_filtered({
               position = next_belt.position,
               radius = 3,
               type = { "inserter", "loader", "loader-1x1" },
            })
         end
         --check contents
         --Ignore multiple input belts, ghosts, circuit connected transport belts, and belts with inserters near them
         --Also do not assume this belt if the next belt is a stopping end (has no exits)
         if
            next_belt ~= nil
            and next_belt.valid
            and #next_belt.belt_neighbours["inputs"] == 1
            and next_belt.type ~= "entity-ghost"
            and (
               next_belt.type ~= "transport-belt" --Skip this check for non-belts, e.g. underground belts
               or (
                  next_belt.get_circuit_network(defines.wire_type.red) == nil
                  and next_belt.get_circuit_network(defines.wire_type.green) == nil
               )
            )
            and #next_belt.belt_neighbours["outputs"] > 0
            and ent.get_circuit_network(defines.wire_type.red) == nil
            and ent.get_circuit_network(defines.wire_type.green) == nil
            and (next_belt_nearby_inserters == nil or #next_belt_nearby_inserters == 0)
         then
            --Check contents of next belt
            local left = next_belt.get_transport_line(1).get_contents()
            local right = next_belt.get_transport_line(2).get_contents()

            for name, count in pairs(right) do
               if left[name] ~= nil then
                  left[name] = left[name] + count
               else
                  left[name] = count
               end
            end
            for name, count in pairs(left) do
               table.insert(next_contents, { name = name, count = count })
            end
            table.sort(next_contents, function(k1, k2)
               return k1.count > k2.count
            end)
         end

         --Check contents of prev belt
         local prev_belts = ent.belt_neighbours["inputs"]
         local prev_contents = {}
         local this_belt_nearby_inserters =
            ent.surface.find_entities_filtered({ position = ent.position, radius = 5, type = { "inserter" } })
         for i, prev_belt in ipairs(prev_belts) do
            --Check contents
            --Ignore ghosts, circuit connected transport belts, and belts with inserters near them
            if
               prev_belt ~= nil
               and prev_belt.valid
               and prev_belt.type ~= "entity-ghost"
               and (
                  prev_belt.type ~= "transport-belt" --Skip this check for non-belts, e.g. underground belts
                  or (
                     prev_belt.get_circuit_network(defines.wire_type.red) == nil
                     and prev_belt.get_circuit_network(defines.wire_type.green) == nil
                  )
               )
               and ent.get_circuit_network(defines.wire_type.red) == nil
               and ent.get_circuit_network(defines.wire_type.green) == nil
               and (this_belt_nearby_inserters == nil or #this_belt_nearby_inserters == 0)
            then
               local left = prev_belt.get_transport_line(1).get_contents()
               local right = prev_belt.get_transport_line(2).get_contents()

               for name, count in pairs(right) do
                  if left[name] ~= nil then
                     left[name] = left[name] + count
                  else
                     left[name] = count
                  end
               end
               for name, count in pairs(left) do
                  table.insert(prev_contents, { name = name, count = count })
               end
               table.sort(prev_contents, function(k1, k2)
                  return k1.count > k2.count
               end)
            end
         end

         --Report assumed carried items based on input/output neighbors
         if #next_contents > 0 then
            result = result .. " carrying " .. fa_localising.get_item_from_name(next_contents[1].name, pindex)
            if #next_contents > 1 then
               result = result .. ", and " .. fa_localising.get_item_from_name(next_contents[2].name, pindex)
               if #next_contents > 2 then result = result .. ", and other item types " end
            end
         elseif #prev_contents > 0 then
            result = result .. " carrying " .. fa_localising.get_item_from_name(prev_contents[1].name, pindex)
            if #prev_contents > 1 then
               result = result .. ", and " .. fa_localising.get_item_from_name(prev_contents[2].name, pindex)
               if #prev_contents > 2 then result = result .. ", and other item types " end
            end
         else
            --No currently or recently carried items
            result = result .. " carrying nothing, "
         end
      end
   end

   --For underground belts, note whether entrance or exit, and report contents
   if ent.type == "underground-belt" then
      if ent.belt_to_ground_type == "input" then
         result = result .. " entrance "
      elseif ent.belt_to_ground_type == "output" then
         result = result .. " exit "
      end
   end

   --Explain the recipe of a machine without pause and before the direction
   pcall(function()
      if ent.get_recipe() ~= nil then
         result = result .. " producing " .. fa_localising.get_recipe_from_name(ent.get_recipe().name, pindex)
      end
   end)
   --For furnaces (which produce only 1 output item type at a time) state how many output units are ready
   if ent.type == "furnace" then
      local output_stack = ent.get_output_inventory()[1]
      if output_stack and output_stack.valid_for_read then
         result = result .. ", " .. output_stack.count .. " ready, "
      end
   end
   --State the name of a train stop
   if ent.name == "train-stop" then
      result = result .. " " .. ent.backer_name .. " "
      if ent.trains_limit ~= nil and ent.trains_limit < 10000 then
         result = result .. ", trains limit " .. ent.trains_limit
      end
   --State the ID number of a train
   elseif ent.name == "locomotive" or ent.name == "cargo-wagon" or ent.name == "fluid-wagon" then
      result = result .. " of train " .. fa_trains.get_train_name(ent.train)
   --State the signal state of a rail signal
   elseif ent.name == "rail-signal" or ent.name == "rail-chain-signal" then
      if ent.status == defines.entity_status.not_connected_to_rail then
         result = result .. " not connected to rails "
      else
         result = result .. ", " .. fa_rails.get_signal_state_info(ent)
      end
   end
   --Report the entity facing direction
   if
      (ent.prototype.is_building and ent.supports_direction)
      or (ent.name == "entity-ghost" and ent.ghost_prototype.is_building and ent.ghost_prototype.supports_direction)
   then
      result = result .. ", Facing " .. fa_utils.direction_lookup(ent.direction)
      if ent.type == "generator" then
         --For steam engines and steam turbines, north = south and east = west
         result = result .. " and " .. fa_utils.direction_lookup(fa_utils.rotate_180(ent.direction))
      end
   elseif ent.type == "locomotive" or ent.type == "car" then
      result = result .. " facing " .. fa_utils.get_heading_info(ent)
   end
   if ent.name == "rail-signal" or ent.name == "rail-chain-signal" then
      result = result .. ", Heading " .. fa_utils.direction_lookup(fa_utils.rotate_180(ent.direction))
   end
   if ent.type == "wall" and ent.get_control_behavior() ~= nil then result = result .. ", gate control circuit, " end
   --Report if marked for deconstruction or upgrading
   if ent.to_be_deconstructed() == true then
      result = result .. " marked for deconstruction, "
   elseif ent.to_be_upgraded() == true then
      result = result .. " marked for upgrading, "
   end
   --Generator power production
   if ent.prototype.type == "generator" then
      result = result .. ", "
      local power1 = ent.energy_generated_last_tick * 60
      local power2 = ent.prototype.max_energy_production * 60
      local power_load_pct = math.ceil(power1 / power2 * 100)
      if power2 ~= nil then
         result = result
            .. " at "
            .. power_load_pct
            .. " percent load, producing "
            .. fa_electrical.get_power_string(power1)
            .. " out of "
            .. fa_electrical.get_power_string(power2)
            .. " capacity, "
      else
         result = result .. " producing " .. fa_electrical.get_power_string(power1) .. " "
      end
   end
   if ent.type == "underground-belt" then
      if ent.neighbours ~= nil then
         result = result
            .. ", Connected to "
            .. fa_utils.direction(ent.position, ent.neighbours.position)
            .. " via "
            .. math.floor(fa_utils.distance(ent.position, ent.neighbours.position)) - 1
            .. " tiles underground, "
      else
         result = result .. ", not connected "
      end
   elseif ent.type == "splitter" then
      --Splitter priority info
      result = result .. fa_belts.splitter_priority_info(ent)
   elseif (ent.name == "pipe") and ent.neighbours ~= nil then
      --List connected neighbors
      result = result .. " connects "
      local con_counter = 0
      for i, nbrs in pairs(ent.neighbours) do
         for j, nbr in pairs(nbrs) do
            local box = nil
            local f_name = nil
            local dir_from_pos = nil
            box, f_name, dir_from_pos =
               fa_building_tools.get_relevant_fluidbox_and_fluid_name(nbr, ent.position, dirs.north)
            --Extra checks for pipes to ground
            if f_name == nil then
               box, f_name, dir_from_pos =
                  fa_building_tools.get_relevant_fluidbox_and_fluid_name(nbr, ent.position, dirs.east)
            end
            if f_name == nil then
               box, f_name, dir_from_pos =
                  fa_building_tools.get_relevant_fluidbox_and_fluid_name(nbr, ent.position, dirs.south)
            end
            if f_name == nil then
               box, f_name, dir_from_pos =
                  fa_building_tools.get_relevant_fluidbox_and_fluid_name(nbr, ent.position, dirs.west)
            end
            if f_name ~= nil then --"empty" is a name too
               result = result .. fa_utils.direction_lookup(dir_from_pos) .. ", "
               --game.print("found " .. f_name .. " at " .. nbr.name ,{volume_modifier=0})
               con_counter = con_counter + 1
            end
         end
      end
      if con_counter == 0 then result = result .. " to nothing" end
   elseif (ent.name == "pipe-to-ground") and ent.neighbours ~= nil then
      result = result .. " connects "
      local connections = ent.fluidbox.get_pipe_connections(1)
      local aboveground_found = false
      local underground_found = false
      for i, con in ipairs(connections) do
         if con.target ~= nil then
            local dist = math.ceil(util.distance(ent.position, con.target.get_pipe_connections(1)[1].position))
            result = result
               .. fa_utils.direction_lookup(fa_utils.get_direction_biased(con.target_position, ent.position))
               .. " "
            if con.connection_type == "underground" then
               result = result .. " via " .. dist - 1 .. " tiles underground, "
               underground_found = true
            else
               result = result .. " directly "
               aboveground_found = true
            end
            result = result .. ", "
         end
      end
      if aboveground_found == false and underground_found == false then
         result = result .. " nothing "
      elseif aboveground_found == true and underground_found == false then
         result = result .. " nothing underground "
      elseif aboveground_found == false and underground_found == true then
         result = result .. " nothing directly "
      end
   elseif next(ent.prototype.fluidbox_prototypes) ~= nil then
      --For a fluidbox inside a building, give info about the connection directions
      local relative_position =
         { x = players[pindex].cursor_pos.x - ent.position.x, y = players[pindex].cursor_pos.y - ent.position.y }
      local direction = ent.direction / 2
      local inputs = 0
      for i, box in pairs(ent.prototype.fluidbox_prototypes) do
         for i1, pipe in pairs(box.pipe_connections) do
            if pipe.type == "input" then inputs = inputs + 1 end
            local adjusted = { position = nil, direction = nil }
            if ent.name == "offshore-pump" then
               adjusted.position = { x = 0, y = 0 }
               if direction == 0 then
                  adjusted.direction = "South"
               elseif direction == 1 then
                  adjusted.direction = "West"
               elseif direction == 2 then
                  adjusted.direction = "North"
               elseif direction == 3 then
                  adjusted.direction = "East"
               end
            else
               adjusted = get_adjacent_source(ent.prototype.selection_box, pipe.positions[direction + 1], direction)
            end
            if adjusted.position.x == relative_position.x and adjusted.position.y == relative_position.y then
               if ent.type == "assembling-machine" and ent.get_recipe() ~= nil then
                  if ent.name == "oil-refinery" and ent.get_recipe().name == "basic-oil-processing" then
                     if i == 2 then
                        result = result
                           .. ", "
                           .. fa_localising.get_fluid_from_name("crude-oil", pindex)
                           .. " Flow "
                           .. pipe.type
                           .. " 1 "
                           .. adjusted.direction
                           .. ", at "
                           .. fa_utils.get_entity_part_at_cursor(pindex)
                     elseif i == 5 then
                        result = result
                           .. ", "
                           .. fa_localising.get_fluid_from_name("petroleum-gas", pindex)
                           .. " Flow "
                           .. pipe.type
                           .. " 1 "
                           .. adjusted.direction
                           .. ", at "
                           .. fa_utils.get_entity_part_at_cursor(pindex)
                     else
                        result = result
                           .. ", "
                           .. "Unused"
                           .. " Flow "
                           .. pipe.type
                           .. " 1 "
                           .. adjusted.direction
                           .. ", at "
                           .. fa_utils.get_entity_part_at_cursor(pindex)
                     end
                  else
                     if pipe.type == "input" then
                        local inputs = ent.get_recipe().ingredients
                        for i2 = #inputs, 1, -1 do
                           if inputs[i2].type ~= "fluid" then table.remove(inputs, i2) end
                        end
                        if #inputs > 0 then
                           local i3 = (i % #inputs)
                           if i3 == 0 then i3 = #inputs end
                           local filter = inputs[i3]
                           result = result
                              .. ", "
                              .. filter.name
                              .. " Flow "
                              .. pipe.type
                              .. " 1 "
                              .. adjusted.direction
                              .. ", at "
                              .. fa_utils.get_entity_part_at_cursor(pindex)
                        else
                           result = result
                              .. ", "
                              .. "Unused"
                              .. " Flow "
                              .. pipe.type
                              .. " 1 "
                              .. adjusted.direction
                              .. ", at "
                              .. fa_utils.get_entity_part_at_cursor(pindex)
                        end
                     else
                        local outputs = ent.get_recipe().products
                        for i2 = #outputs, 1, -1 do
                           if outputs[i2].type ~= "fluid" then table.remove(outputs, i2) end
                        end
                        if #outputs > 0 then
                           local i3 = ((i - inputs) % #outputs)
                           if i3 == 0 then i3 = #outputs end
                           local filter = outputs[i3]
                           result = result
                              .. ", "
                              .. filter.name
                              .. " Flow "
                              .. pipe.type
                              .. " 1 "
                              .. adjusted.direction
                              .. ", at "
                              .. fa_utils.get_entity_part_at_cursor(pindex)
                        else
                           result = result
                              .. ", "
                              .. "Unused"
                              .. " Flow "
                              .. pipe.type
                              .. " 1 "
                              .. adjusted.direction
                              .. ", at "
                              .. fa_utils.get_entity_part_at_cursor(pindex)
                        end
                     end
                  end
               else
                  --Other ent types and assembling machines with no recipes
                  local filter = box.filter or { name = "" }
                  result = result
                     .. ", "
                     .. filter.name
                     .. " Flow "
                     .. pipe.type
                     .. " 1 "
                     .. adjusted.direction
                     .. ", at "
                     .. fa_utils.get_entity_part_at_cursor(pindex)
               end
            end
         end
      end
   end

   if ent.type == "transport-belt" then
      --Check whether items on the belt are stopped or moving (based on whether you can insert at the back of the belt)
      local left = ent.get_transport_line(1)
      local right = ent.get_transport_line(2)

      local left_dir = "left"
      local right_dir = "right"
      if ent.direction == dirs.north then
         left_dir = fa_utils.direction_lookup(dirs.west) or "left"
         right_dir = fa_utils.direction_lookup(dirs.east) or "right"
      elseif ent.direction == dirs.east then
         left_dir = fa_utils.direction_lookup(dirs.north) or "left"
         right_dir = fa_utils.direction_lookup(dirs.south) or "right"
      elseif ent.direction == dirs.south then
         left_dir = fa_utils.direction_lookup(dirs.east) or "left"
         right_dir = fa_utils.direction_lookup(dirs.west) or "right"
      elseif ent.direction == dirs.west then
         left_dir = fa_utils.direction_lookup(dirs.south) or "left"
         right_dir = fa_utils.direction_lookup(dirs.north) or "right"
      end

      local insert_spots_left = 0
      local insert_spots_right = 0
      if not left.can_insert_at_back() and right.can_insert_at_back() then
         result = result .. ", " .. left_dir .. " lane full, "
      elseif left.can_insert_at_back() and not right.can_insert_at_back() then
         result = result .. ", " .. right_dir .. " lane full, "
      elseif not left.can_insert_at_back() and not right.can_insert_at_back() then
         result = result .. ", both lanes full, "
         --game.get_player(pindex).print(", both lanes full, ")
      else
         result = result .. ", both lanes open, "
         --game.get_player(pindex).print(", both lanes open, ")
      end
   elseif ent.name == "cargo-wagon" then
      --Explain contents
      local itemset = ent.get_inventory(defines.inventory.cargo_wagon).get_contents()
      local itemtable = {}
      for name, count in pairs(itemset) do
         table.insert(itemtable, { name = name, count = count })
      end
      table.sort(itemtable, function(k1, k2)
         return k1.count > k2.count
      end)
      if #itemtable == 0 then
         result = result .. " containing nothing "
      else
         result = result .. " containing " .. itemtable[1].name .. " times " .. itemtable[1].count .. ", "
         if #itemtable > 1 then
            result = result .. " and " .. itemtable[2].name .. " times " .. itemtable[2].count .. ", "
         end
         if #itemtable > 2 then result = result .. "and other items " end
      end
   elseif ent.type == "radar" then
      result = result .. ", " .. mod.radar_charting_info(ent)
      --game.print(result)--test
   elseif ent.type == "electric-pole" then
      --List connected wire neighbors
      result = result .. fa_circuits.wire_neighbours_info(ent, false)
      --Count number of entities being supplied within supply area.
      local pos = ent.position
      local sdist = ent.prototype.supply_area_distance
      local supply_area = { { pos.x - sdist, pos.y - sdist }, { pos.x + sdist, pos.y + sdist } }
      local supplied_ents = ent.surface.find_entities_filtered({ area = supply_area })
      local supplied_count = 0
      local producer_count = 0
      for i, ent2 in ipairs(supplied_ents) do
         if
            ent2.prototype.max_energy_usage ~= nil
            and ent2.prototype.max_energy_usage > 0
            and ent2.prototype.is_building
         then
            supplied_count = supplied_count + 1
         elseif
            ent2.prototype.max_energy_production ~= nil
            and ent2.prototype.max_energy_production > 0
            and ent2.prototype.is_building
         then
            producer_count = producer_count + 1
         end
      end
      result = result .. " supplying " .. supplied_count .. " buildings, "
      if producer_count > 0 then result = result .. " drawing from " .. producer_count .. " buildings, " end
      result = result .. "Check status for power flow information. "
   elseif ent.type == "power-switch" then
      if ent.power_switch_state == false then
         result = result .. " off, "
      elseif ent.power_switch_state == true then
         result = result .. " on, "
      end
      if (#ent.neighbours.red + #ent.neighbours.green) > 0 then result = result .. " observes circuit condition, " end
      result = result .. fa_circuits.wire_neighbours_info(ent, true)
   elseif ent.name == "roboport" then
      local cell = ent.logistic_cell
      local network = ent.logistic_cell.logistic_network
      result = result
         .. " of network "
         .. fa_bot_logistics.get_network_name(ent)
         .. ","
         .. fa_bot_logistics.roboport_contents_info(ent)
   elseif ent.type == "spider-vehicle" then
      local label = ent.entity_label
      if label == nil then label = "" end
      result = result .. label
   elseif ent.type == "spider-leg" then
      local spiders =
         ent.surface.find_entities_filtered({ position = ent.position, radius = 5, type = "spider-vehicle" })
      local spider = ent.surface.get_closest(ent.position, spiders)
      local label = spider.entity_label
      if label == nil then label = "" end
      result = result .. label
   end
   --Inserters: Explain held items, pickup and drop positions
   if ent.type == "inserter" then
      --Declare filters
      if ent.filter_slot_count > 0 then
         local filter_result = " Filters for "
         local active_filter_count = 0
         for i = 1, ent.filter_slot_count, 1 do
            local filt = ent.get_filter(i)
            if filt ~= nil then
               active_filter_count = active_filter_count + 1
               if active_filter_count > 1 then filter_result = filter_result .. " and " end
               local local_name = fa_localising.get(game.item_prototypes[filt], pindex)
               if local_name == nil then local_name = filt or " unknown item " end
               filter_result = filter_result .. local_name
            end
         end
         if active_filter_count > 0 then result = result .. filter_result .. ", " end
      end
      --Read held item
      if ent.held_stack ~= nil and ent.held_stack.valid_for_read and ent.held_stack.valid then
         result = result .. ", holding " .. ent.held_stack.name
         if ent.held_stack.count > 1 then result = result .. " times " .. ent.held_stack.count end
      end
      --Take note of long handed inserters
      local pickup_dist_dir = " at 1 " .. fa_utils.direction_lookup(ent.direction)
      local drop_dist_dir = " at 1 " .. fa_utils.direction_lookup(fa_utils.rotate_180(ent.direction))
      if ent.name == "long-handed-inserter" then
         pickup_dist_dir = " at 2 " .. fa_utils.direction_lookup(ent.direction)
         drop_dist_dir = " at 2 " .. fa_utils.direction_lookup(fa_utils.rotate_180(ent.direction))
      end
      --Read the pickup position
      local pickup = ent.pickup_target
      local pickup_name = nil
      if pickup ~= nil and pickup.valid then
         pickup_name = fa_localising.get(pickup, pindex)
      else
         pickup_name = "ground"
         local area_ents = ent.surface.find_entities_filtered({ position = ent.pickup_position })
         for i, area_ent in ipairs(area_ents) do
            if area_ent.type == "straight-rail" or area_ent.type == "curved-rail" then
               pickup_name = fa_localising.get(area_ent, pindex)
            end
         end
      end
      result = result .. " picks up from " .. pickup_name .. pickup_dist_dir
      --Read the drop position
      local drop = ent.drop_target
      local drop_name = nil
      if drop ~= nil and drop.valid then
         drop_name = fa_localising.get(drop, pindex)
      else
         drop_name = "ground"
         local drop_area_ents = ent.surface.find_entities_filtered({ position = ent.drop_position })
         for i, drop_area_ent in ipairs(drop_area_ents) do
            if drop_area_ent.type == "straight-rail" or drop_area_ent.type == "curved-rail" then
               drop_name = fa_localising.get(drop_area_ent, pindex)
            end
         end
      end
      result = result .. ", drops to " .. drop_name .. drop_dist_dir
   end
   if ent.type == "mining-drill" then
      local pos = ent.position
      local radius = ent.prototype.mining_drill_radius
      local area = { { pos.x - radius, pos.y - radius }, { pos.x + radius, pos.y + radius } }
      local resources = ent.surface.find_entities_filtered({ area = area, type = "resource" })
      local dict = {}
      for i, resource in pairs(resources) do
         if dict[resource.name] == nil then
            dict[resource.name] = resource.amount
         else
            dict[resource.name] = dict[resource.name] + resource.amount
         end
      end
      local drop = ent.drop_target
      local drop_name = nil
      if drop ~= nil and drop.valid then
         drop_name = fa_localising.get(drop, pindex)
      else
         drop_name = "ground"
         local drop_area_ents = ent.surface.find_entities_filtered({ position = ent.drop_position })
         for i, drop_area_ent in ipairs(drop_area_ents) do
            if drop_area_ent.type == "straight-rail" or drop_area_ent.type == "curved-rail" then
               drop_name = fa_localising.get(drop_area_ent, pindex)
            end
         end
      end
      if drop ~= nil and drop.valid then result = result .. " outputs to " .. drop_name end
      if ent.status == defines.entity_status.waiting_for_space_in_destination then
         result = result .. " output full "
      end
      if table_size(dict) > 0 then
         result = result .. ", Mining from "
         for i, amount in pairs(dict) do
            if i == "crude-oil" then
               result = result .. " " .. i .. " times " .. math.floor(amount / 3000) / 10 .. " per second "
            else
               result = result .. " " .. i .. " times " .. fa_utils.simplify_large_number(amount)
            end
         end
      end
   end
   --Explain if no fuel
   if ent.prototype.burner_prototype ~= nil then
      if ent.energy == 0 and fa_driving.fuel_inventory_info(ent) == "Contains no fuel." then
         result = result .. ", Out of Fuel "
      end
   end
   --Explain other problematic status messages
   local status = ent.status
   local stat = defines.entity_status
   if status ~= nil and status ~= stat.normal and status ~= stat.working then
      if
         status == stat.no_ingredients
         or status == stat.no_input_fluid
         or status == stat.no_minable_resources
         or status == stat.item_ingredient_shortage
         or status == stat.missing_required_fluid
         or status == stat.no_ammo
      then
         result = result .. ", input missing "
      elseif status == stat.full_output or status == stat.full_burnt_result_output then
         result = result .. " output full "
      end
   end
   --Explain power connected status
   if ent.prototype.electric_energy_source_prototype ~= nil and ent.is_connected_to_electric_network() == false then
      result = result .. " power not Connected"
   elseif ent.prototype.electric_energy_source_prototype ~= nil and ent.energy == 0 and ent.type ~= "solar-panel" then
      result = result .. " out of power "
   end
   if ent.type == "accumulator" then
      local level = math.ceil(ent.energy / 50000) --In percentage
      local charge = math.ceil(ent.energy / 1000) --In kilojoules
      result = result .. ", " .. level .. " percent full, containing " .. charge .. " kilojoules. "
   elseif ent.type == "solar-panel" then
      local s_time = ent.surface.daytime * 24 --We observed 18 = peak solar start, 6 = peak solar end, 11 = night start, 13 = night end
      local solar_status = ""
      if s_time > 13 and s_time <= 18 then
         solar_status = ", increasing production, morning hours. "
      elseif s_time > 18 or s_time < 6 then
         solar_status = ", full production, day time. "
      elseif s_time > 6 and s_time <= 11 then
         solar_status = ", decreasing production, evening hours. "
      elseif s_time > 11 and s_time <= 13 then
         solar_status = ", zero production, night time. "
      end
      result = result .. solar_status
   elseif ent.name == "rocket-silo" then
      if ent.rocket_parts ~= nil and ent.rocket_parts < 100 then
         result = result .. ", " .. ent.rocket_parts .. " finished out of 100. "
      elseif ent.rocket_parts ~= nil then
         result = result .. ", rocket ready, press SPACE to launch. "
      end
   elseif ent.name == "beacon" then
      local modules = ent.get_module_inventory()
      if modules.get_item_count() == 0 then
         result = result .. " with no modules "
      elseif modules.get_item_count() == 1 then
         result = result .. " with " .. modules[1].name
      elseif modules.get_item_count() == 2 then
         result = result .. " with " .. modules[1].name .. " and " .. modules[2].name
      elseif modules.get_item_count() > 2 then
         result = result .. " with " .. modules[1].name .. " and " .. modules[2].name .. " and other modules "
      end
   elseif ent.temperature ~= nil and ent.name ~= "heat-pipe" then --ent.name == "nuclear-reactor" or ent.name == "heat-pipe" or ent.name == "heat-exchanger" then
      result = result .. ", temperature " .. math.floor(ent.temperature) .. " degrees C "
      if ent.name == "nuclear-reactor" then
         if ent.temperature > 900 then result = result .. ", danger " end
         if ent.energy > 0 then result = result .. ", consuming fuel cell " end
         result = result .. ", neighbour bonus " .. ent.neighbour_bonus * 100 .. " percent "
      end
   elseif ent.name == "item-on-ground" then
      result = result .. ", " .. ent.stack.name
   end
   --Explain heat connection neighbors
   if ent.prototype.heat_buffer_prototype ~= nil then
      result = result .. " connects "
      local con_targets = fa_building_tools.get_heat_connection_target_positions(ent.name, ent.position, ent.direction)
      local con_count = 0
      local con_counts = { 0, 0, 0, 0, 0, 0, 0, 0 }
      con_counts[dirs.north + 1] = 0
      con_counts[dirs.south + 1] = 0
      con_counts[dirs.east + 1] = 0
      con_counts[dirs.west + 1] = 0
      if #con_targets > 0 then
         for i, con_target_pos in ipairs(con_targets) do
            --For each heat connection target position, mark it and check for target ents
            rendering.draw_circle({
               color = { 1.0, 0.0, 0.5 },
               radius = 0.1,
               width = 2,
               target = con_target_pos,
               surface = ent.surface,
               time_to_live = 30,
            })
            local target_ents = ent.surface.find_entities_filtered({ position = con_target_pos })
            for j, target_ent in ipairs(target_ents) do
               if
                  target_ent.valid
                  and #fa_building_tools.get_heat_connection_positions(
                        target_ent.name,
                        target_ent.position,
                        target_ent.direction
                     )
                     > 0
               then
                  for k, spot in
                     ipairs(
                        fa_building_tools.get_heat_connection_positions(
                           target_ent.name,
                           target_ent.position,
                           target_ent.direction
                        )
                     )
                  do
                     --For each heat connection of the found target entity, mark it and check for a match
                     rendering.draw_circle({
                        color = { 1.0, 1.0, 0.5 },
                        radius = 0.2,
                        width = 2,
                        target = spot,
                        surface = ent.surface,
                        time_to_live = 30,
                     })
                     if util.distance(con_target_pos, spot) < 0.2 then
                        --For each match, mark it and count it
                        rendering.draw_circle({
                           color = { 0.5, 1.0, 0.5 },
                           radius = 0.3,
                           width = 2,
                           target = spot,
                           surface = ent.surface,
                           time_to_live = 30,
                        })
                        con_count = con_count + 1
                        local con_dir = fa_utils.get_direction_biased(con_target_pos, ent.position)
                        if con_count > 1 then result = result .. " and " end
                        result = result .. fa_utils.direction_lookup(con_dir)
                     end
                  end
               end
            end
         end
      end
      if con_count == 0 then result = result .. " to nothing " end
      if ent.name == "heat-pipe" then --For this ent in particular, read temp after direction
         result = result .. ", temperature " .. math.floor(ent.temperature) .. " degrees C "
      end
   end
   if ent.type == "constant-combinator" then
      result = result .. fa_circuits.constant_combinator_signals_info(ent, pindex)
   end
   return result
end

--Reports the charting range of a radar and how much of it has been charted so far.
function mod.radar_charting_info(radar)
   local charting_range = radar.prototype.max_distance_of_sector_revealed
   local count = 0
   local total = 0
   local centerx = math.floor(radar.position.x / 32)
   local centery = math.floor(radar.position.y / 32)
   for i = (centerx - charting_range), (centerx + charting_range), 1 do
      for j = (centery - charting_range), (centery + charting_range), 1 do
         if radar.force.is_chunk_charted(radar.surface, { i, j }) then count = count + 1 end
         total = total + 1
      end
   end
   local percent_charted = math.floor(count / total * 100)
   local result = percent_charted .. " percent charted, " .. charting_range * 32 .. " tiles charting range "
   return result
end

--Reads out the relative pollution level at the input position. The categories are based on data like map view shaders, water discoloration rates. For example, in default settings trees are damaged after pollution exceeds 60 and water is discolored after 90, and the deepest shader applies after 150.
function mod.read_pollution_level_at_position(pos, pindex)
   local p = game.get_player(pindex)
   local pol = p.surface.get_pollution(pos)
   local result = " pollution detected"
   if pol <= 0.1 then
      result = "No" .. result
   elseif pol < 10 then
      result = "Minimal" .. result
   elseif pol < 30 then
      result = "Low" .. result
   elseif pol < 60 then
      result = "Medium" .. result
   elseif pol < 100 then
      result = "High" .. result
   elseif pol < 150 then
      result = "Very high" .. result
   elseif pol < 250 then
      result = "Extremely high" .. result
   elseif pol >= 250 then
      result = "Maximal" .. result
   end
   printout(result, pindex)
end

--Reads out the distance and direction to the nearest damaged entity within 1000 tiles.
function mod.read_nearest_damaged_ent_info(pos, pindex)
   local p = game.get_player(pindex)
   --Scan for ents of your force
   local ents =
      p.surface.find_entities_filtered({ position = players[pindex].cursor_pos, radius = 1000, force = p.force })
   --Check for entities with health
   if ents == nil or #ents == 0 then
      printout("No damaged structures within 1000 tiles.", pindex)
      return
   end
   local at_least_one_has_damage = false
   local damaged_ents = {}
   for i, ent in ipairs(ents) do
      if ent.is_entity_with_health == true and ent.type ~= "character" and ent.get_health_ratio() < 1 then
         at_least_one_has_damage = true
         table.insert(damaged_ents, ent)
      end
   end
   if at_least_one_has_damage == false then
      printout("No damaged structures within 1000 tiles.", pindex)
      return
   end
   --Narrow by distance
   local closest = nil
   local min_dist = 1001
   for i, ent in ipairs(damaged_ents) do
      local dist = util.distance(pos, ent.position)
      if dist < min_dist then
         min_dist = dist
         closest = ent
         if min_dist < 2 then break end
      end
   end
   if closest == nil then
      printout("No damaged structures within 1000 tiles.", pindex)
      return
   else
      --Move cursor to closest
      players[pindex].cursor_pos = closest.position
      fa_graphics.draw_cursor_highlight(pindex, closest, nil, nil)

      --Report the result
      min_dist = math.floor(min_dist)
      local dir = fa_utils.get_direction_biased(closest.position, pos)
      local aligned_note = ""
      if fa_utils.is_direction_aligned(closest.position, pos) then aligned_note = "aligned " end
      local result = fa_localising.get(closest, pindex)
         .. "  damaged at "
         .. min_dist
         .. " "
         .. aligned_note
         .. fa_utils.direction_lookup(dir)
         .. ", cursor moved. "
      printout(result, pindex)
   end
end

--Report total produced and consumed in last minute, ten minutes,  hour,
--thousand hours for the selected item.  The selected item comes from the item
--in hand, the selected item in an inventory, or the crafting menu's current
--selection, in that order.  Since the latter two are disjunct, this can also be
--phrased as "in hand, otherwise examine menus".  Note that Factorio stores
--fluids and items in different places, and that the complicated branching below
--must also account for that.
--
-- Recipes may also produce items as well as fluids.  In vanilla, the example is
-- barrels.  We can't do the right thing in all cases, but in vanilla it happens
-- that the stats on barrels aren't super important and, additionally, there's a
-- separate recipe one can check for that.  Since this only outputs one entry
-- when selecting a recipe, we choose the first fluid if there is one, otherwise
-- the first item.  Ultimately for mods, we're going to need a GUI for it: there
-- are too many cases in the wild.
function mod.selected_item_production_stats_info(pindex)
   local p = game.get_player(pindex)
   local stats = p.force.item_production_statistics
   local item_stack = nil
   local recipe = nil
   local prototype = nil

   -- Try the cursor stack
   item_stack = p.cursor_stack
   if item_stack and item_stack.valid_for_read then prototype = item_stack.prototype end

   --Otherwise try to get it from the inventory slots
   if prototype == nil and players[pindex].menu == "inventory" then
      item_stack = players[pindex].inventory.lua_inventory[players[pindex].inventory.index]
      if item_stack and item_stack.valid_for_read then prototype = item_stack.prototype end
   elseif prototype == nil and players[pindex].menu == "guns" then
      item_stack = fa_equipment.guns_menu_get_selected_slot(pindex)
      if item_stack and item_stack.valid_for_read then prototype = item_stack.prototype end
   end

   --Try crafting menu.
   if prototype == nil and players[pindex].menu == "crafting" then
      recipe = players[pindex].crafting.lua_recipes[players[pindex].crafting.category][players[pindex].crafting.index]
      if recipe and recipe.valid and recipe.products then
         local first_item, first_fluid
         for i, prod in ipairs(recipe.products) do
            if first_item and first_fluid then
               break
            elseif prod.type == "item" then
               first_item = prod
            elseif prod.type == "fluid" then
               first_fluid = prod
            end
         end

         local chosen = first_fluid or first_item

         if not chosen then
            -- do nothing
         elseif chosen.type == "item" then
            --Select product item #1
            prototype = game.item_prototypes[chosen.name]
         elseif chosen.type == "fluid" then
            --Select product fluid #1
            stats = p.force.fluid_production_statistics
            prototype = game.fluid_prototypes[chosen.name]
         end
      end
   end

   -- For now, we give up.
   if not prototype then return "Error: No selected item or fluid" end

   -- We need both inputs and outputs. That's the same code, with one boolean
   -- changed.
   local get_stats = function(is_input)
      local name = prototype.name
      local interval = defines.flow_precision_index
      local last_minute =
         stats.get_flow_count({ name = name, input = is_input, precision_index = interval.one_minute, count = true })
      local last_10_minutes =
         stats.get_flow_count({ name = name, input = is_input, precision_index = interval.ten_minutes, count = true })
      local last_hour =
         stats.get_flow_count({ name = name, input = is_input, precision_index = interval.one_hour, count = true })
      local thousand_hours = stats.get_flow_count({
         name = name,
         input = is_input,
         precision_index = interval.one_thousand_hours,
         count = true,
      })
      last_minute = fa_utils.simplify_large_number(last_minute)
      last_10_minutes = fa_utils.simplify_large_number(last_10_minutes)
      last_hour = fa_utils.simplify_large_number(last_hour)
      thousand_hours = fa_utils.simplify_large_number(thousand_hours)
      return last_minute, last_10_minutes, last_hour, thousand_hours
   end

   local m1_in, m10_in, h1_in, h1000_in = get_stats(true)
   local m1_out, m10_out, h1_out, h1000_out = get_stats(false)

   return fa_utils.spacecat(
      fa_localising.get(prototype, pindex) .. ",",
      "Produced",
      m1_in,
      "last minute,",
      m10_in,
      "last ten min,",
      h1_in,
      "last hour,",
      h1000_in,
      "last thousand hours.",
      "Consumed",
      m1_out,
      "last minute,",
      m10_out,
      "last ten min,",
      h1_out,
      "last hour,",
      h1000_out,
      "last thousand hours."
   )
end

--Report the status of the selected entity as well as additional dynamic info depending on the entity type
function mod.read_selected_entity_status(pindex)
   local ent = game.get_player(pindex).selected
   if not ent then return end
   local stack = game.get_player(pindex).cursor_stack
   if players[pindex].in_menu then return end
   --Print out the status of a machine, if it exists.
   local result = { "" }
   local ent_status_id = ent.status
   local ent_status_text = ""
   local status_lookup = fa_utils.into_lookup(defines.entity_status)
   status_lookup[23] = "Full burnt result output" --weird exception
   if ent.name == "cargo-wagon" then
      --Instead of status, read contents
      table.insert(result, fa_trains.cargo_wagon_top_contents_info(ent))
   elseif ent.name == "fluid-wagon" then
      --Instead of status, read contents
      table.insert(result, fa_trains.fluid_contents_info(ent))
   elseif ent_status_id ~= nil then
      --Print status if it exists
      ent_status_text = status_lookup[ent_status_id]
      if ent_status_text == nil then
         print("Weird no entity status lookup" .. ent.name .. "-" .. ent.type .. "-" .. ent.status)
      end
      table.insert(result, { "entity-status." .. ent_status_text:gsub("_", "-") })
   else --There is no status
      --When there is no status, for entities with fuel inventories, read that out instead. This is typical for vehicles.
      if ent.get_fuel_inventory() ~= nil then
         table.insert(result, fa_driving.fuel_inventory_info(ent))
      elseif ent.type == "electric-pole" then
         --For electric poles with no power flow, report the nearest electric pole with a power flow.
         if fa_electrical.get_electricity_satisfaction(ent) > 0 then
            table.insert(
               result,
               fa_electrical.get_electricity_satisfaction(ent)
                  .. " percent network satisfaction, with "
                  .. fa_electrical.get_electricity_flow_info(ent)
            )
         else
            table.insert(result, "No power, " .. fa_electrical.report_nearest_supplied_electric_pole(ent))
         end
      else
         table.insert(result, "No status.")
      end
   end
   --For working or normal entities, give some extra info about specific entities.
   if #result == 1 then table.insert(result, "result error") end

   --For working or normal entities, give some extra info about specific entities in terms of speeds or bonuses.
   local list = defines.entity_status
   if
      ent.status ~= nil
      and ent.status ~= list.no_power
      and ent.status ~= list.no_power
      and ent.status ~= list.no_fuel
   then
      if ent.type == "inserter" then --items per minute based on rotation speed and the STATED hand capacity
         local cap = ent.force.inserter_stack_size_bonus + 1
         if ent.name == "stack-inserter" or ent.name == "stack-filter-inserter" then
            cap = ent.force.stack_inserter_capacity_bonus + 1
         end
         local rate = string.format(" %.1f ", cap * ent.prototype.inserter_rotation_speed * 57.5)
         table.insert(result, ", can move " .. rate .. " items per second, with a hand capacity of " .. cap)
      end
      if ent.prototype ~= nil and ent.prototype.belt_speed ~= nil and ent.prototype.belt_speed > 0 then --items per minute by simple reading
         if ent.type == "splitter" then
            table.insert(
               result,
               ", can process " .. math.floor(ent.prototype.belt_speed * 480 * 2) .. " items per second"
            )
         else
            table.insert(result, ", can move " .. math.floor(ent.prototype.belt_speed * 480) .. " items per second")
         end
      end
      if ent.type == "assembling-machine" or ent.type == "furnace" then --Crafting cycles per minute based on recipe time and the STATED craft speed ; laterdo maybe extend this to all "crafting machine" types?
         local progress = ent.crafting_progress
         local speed = ent.crafting_speed
         local recipe_time = 0
         local cycles = 0 -- crafting cycles completed per minute for this recipe
         if ent.get_recipe() ~= nil and ent.get_recipe().valid then
            recipe_time = ent.get_recipe().energy
            cycles = 60 / recipe_time * speed
         end
         local cycles_string = string.format(" %.2f ", cycles)
         if cycles == math.floor(cycles) then cycles_string = string.format(" %d ", cycles) end
         local speed_string = string.format(" %.2f ", speed)
         if speed == math.floor(speed) then speed_string = string.format(" %d ", cycles) end
         if cycles < 10 then --more than 6 seconds to craft
            table.insert(result, ", recipe progress " .. math.floor(progress * 100) .. " percent ")
         end
         if cycles > 0 then table.insert(result, ", can complete " .. cycles_string .. " recipe cycles per minute ") end
         table.insert(
            result,
            ", with a crafting speed of "
               .. speed_string
               .. ", at "
               .. math.floor(100 * (1 + ent.speed_bonus) + 0.5)
               .. " percent "
         )
         if ent.productivity_bonus ~= 0 then
            table.insert(
               result,
               ", with productivity bonus " .. math.floor(100 * (0 + ent.productivity_bonus) + 0.5) .. " percent "
            )
         end
      elseif ent.type == "mining-drill" then
         table.insert(
            result,
            ", producing "
               .. string.format(" %.2f ", ent.prototype.mining_speed * 60 * (1 + ent.speed_bonus))
               .. " items per minute "
         )
         if ent.speed_bonus ~= 0 then
            table.insert(result, ", with speed " .. math.floor(100 * (1 + ent.speed_bonus) + 0.5) .. " percent ")
         end
         if ent.productivity_bonus ~= 0 then
            table.insert(
               result,
               ", with productivity bonus " .. math.floor(100 * (0 + ent.productivity_bonus) + 0.5) .. " percent "
            )
         end
      elseif ent.name == "lab" then
         if ent.speed_bonus ~= 0 then
            table.insert(
               result,
               ", with speed "
                  .. math.floor(
                     100
                           * (1 + ent.force.laboratory_speed_modifier * (1 + (ent.speed_bonus - ent.force.laboratory_speed_modifier)))
                        + 0.5
                  )
                  .. " percent "
            ) --laterdo fix bug**
            --game.get_player(pindex).print(result)
         end
         if ent.productivity_bonus ~= 0 then
            table.insert(
               result,
               ", with productivity bonus "
                  .. math.floor(100 * (0 + ent.productivity_bonus + ent.force.laboratory_productivity_bonus) + 0.5)
                  .. " percent "
            )
         end
      else --All other entities with the an applicable status
         if ent.speed_bonus ~= 0 then
            table.insert(result, ", with speed " .. math.floor(100 * (1 + ent.speed_bonus) + 0.5) .. " percent ")
         end
         if ent.productivity_bonus ~= 0 then
            table.insert(
               result,
               ", with productivity bonus " .. math.floor(100 * (0 + ent.productivity_bonus) + 0.5) .. " percent "
            )
         end
      end
      --laterdo maybe pump speed?
   end

   --Entity power usage
   local power_rate = (1 + ent.consumption_bonus)
   local drain = ent.electric_drain
   if drain ~= nil then
      drain = drain * 60
   else
      drain = 0
   end
   local uses_energy = false
   if
      drain > 0
      or (ent.prototype ~= nil and ent.prototype.max_energy_usage ~= nil and ent.prototype.max_energy_usage > 0)
   then
      uses_energy = true
   end
   if ent.status ~= nil and uses_energy and ent.status == list.working then
      table.insert(
         result,
         ", consuming " .. fa_electrical.get_power_string(ent.prototype.max_energy_usage * 60 * power_rate + drain)
      )
   elseif ent.status ~= nil and uses_energy and ent.status == list.no_power or ent.status == list.low_power then
      table.insert(
         result,
         ", consuming less than "
            .. fa_electrical.get_power_string(ent.prototype.max_energy_usage * 60 * power_rate + drain)
      )
   elseif
      ent.status ~= nil and uses_energy
      or (ent.prototype ~= nil and ent.prototype.max_energy_usage ~= nil and ent.prototype.max_energy_usage > 0)
   then
      table.insert(result, ", idle and consuming " .. fa_electrical.get_power_string(drain))
   end
   if uses_energy and ent.prototype.burner_prototype ~= nil then table.insert(result, " as burner fuel ") end

   --Entity Health
   if ent.is_entity_with_health and ent.get_health_ratio() == 1 then
      table.insert(result, { "access.full-health" })
   elseif ent.is_entity_with_health then
      table.insert(result, { "access.percent-health", math.floor(ent.get_health_ratio() * 100) })
   end

   -- Report nearest rail intersection position -- laterdo find better keybind
   if ent.name == "straight-rail" then
      local nearest, dist = fa_rails.find_nearest_intersection(ent, pindex)
      if nearest == nil then
         table.insert(result, ", no rail intersections within " .. dist .. " tiles ")
      else
         table.insert(
            result,
            ", nearest rail intersection at "
               .. dist
               .. " "
               .. fa_utils.direction_lookup(fa_utils.get_direction_biased(nearest.position, ent.position))
         )
      end
   end

   --Spawners: Report evolution factor
   if ent.type == "unit-spawner" then
      table.insert(result, ", evolution factor " .. math.floor(1000 * ent.force.evolution_factor) / 1000)
   end

   return result
end

function mod.read_character_status(pindex)
   local p = game.get_player(pindex)
   local char = p.character
   local result = { "" }
   --Report if character missing
   if char == nil or char.valid == false then
      printout(pindex, "No character")
      return
   end
   --Check character has any energy shield health remaining
   local shield_left = 0
   local armor_inv = p.get_inventory(defines.inventory.character_armor)
   if
      armor_inv[1]
      and armor_inv[1].valid_for_read
      and armor_inv[1].valid
      and armor_inv[1].grid
      and armor_inv[1].grid.valid
   then
      local grid = armor_inv[1].grid
      if grid.shield > 0 and grid.shield == grid.max_shield then
         table.insert(result, "Shield full, ")
      elseif grid.shield > 0 then
         shield_left = math.floor(grid.shield / grid.max_shield * 100 + 0.5)
         table.insert(result, "Shield " .. shield_left .. " percent, ")
      else
         --Say nothing
      end
   end
   --Character health
   if char.is_entity_with_health and char.get_health_ratio() == 1 then
      table.insert(result, { "access.full-health" })
   elseif char.is_entity_with_health then
      table.insert(result, { "access.percent-health", math.floor(char.get_health_ratio() * 100) })
   end
   printout(result, pindex)
   return
end

return mod
