--Here: Functions about driving, mainly cars.
--Note: Some train-specific functions are in rails-and-trains.lua

local util = require("util")
local fa_utils = require("scripts.fa-utils")
local fa_trains = require("scripts.trains")
local dirs = defines.direction

local mod = {}

--Report more info about a vehicle. For trains, this would include the name, ID, and train state.
function mod.vehicle_info(pindex)
   local result = ""
   if not game.get_player(pindex).driving then return "Not in a vehicle." end

   local vehicle = game.get_player(pindex).vehicle
   local train = game.get_player(pindex).vehicle.train
   if train == nil then
      --This is a type of car or tank.
      result = "Driving " .. vehicle.name .. ", " .. mod.fuel_inventory_info(vehicle)
      --laterdo**: car info: health, ammo contents, trunk contents
      return result
   else
      --This is a type of locomotive or wagon.

      --Add the train name
      result = "On board " .. vehicle.name .. " of train " .. fa_trains.get_train_name(train) .. ", "

      --Add the train state
      result = result .. fa_trains.get_train_state_info(train) .. ", "

      --Declare destination if any.
      if train.path_end_stop ~= nil then
         result = result .. " heading to station " .. train.path_end_stop.backer_name .. ", "
         --   result = result .. " traveled a distance of " .. train.path.travelled_distance .. " out of " train.path.total_distance " distance, "
      end

      --Note that more info and options are found in the train menu
      if vehicle.name == "locomotive" then result = result .. " Press LEFT BRACKET to open the train menu. " end
      return result
   end
end

--Return fuel content in a fuel inventory
function mod.fuel_inventory_info(ent)
   local result = "Contains no fuel."
   local itemset = ent.get_fuel_inventory().get_contents()
   local itemtable = {}
   for name, count in pairs(itemset) do
      table.insert(itemtable, { name = name, count = count })
   end
   table.sort(itemtable, function(k1, k2)
      return k1.count > k2.count
   end)
   if #itemtable > 0 then
      result = "Contains as fuel, " .. itemtable[1].name .. " times " .. itemtable[1].count .. " "
      if #itemtable > 1 then
         result = result .. " and " .. itemtable[2].name .. " times " .. itemtable[2].count .. " "
      end
      if #itemtable > 2 then
         result = result .. " and " .. itemtable[3].name .. " times " .. itemtable[3].count .. " "
      end
   end
   return result
end

--Plays an alert depending on the distance to the entity ahead. Returns whether a larger radius check is needed. Driving proximity alert
function mod.check_and_play_driving_alert_sound(pindex, tick, mode_in)
   --Inits
   local mode = mode_in or 1
   local p = game.get_player(pindex)
   local surf = p.surface
   --Return in inapplicable cases
   if p == nil or p.valid == false or p.driving == false or p.vehicle == nil then return false end
   --Return in vanilla mode
   if players[pindex].vanilla_mode == true then return end
   --Return if beeped recently
   local min_delay = 15
   if players[pindex].last_driving_alert_tick == nil then
      players[pindex].last_driving_alert_tick = tick
      return false
   end
   local last_driving_alert_tick = players[pindex].last_driving_alert_tick
   local time_since = tick - last_driving_alert_tick
   if last_driving_alert_tick ~= nil and time_since < min_delay then return false end
   --Scan area "ahead" according to direction
   local v = p.vehicle
   local dir = fa_utils.get_heading_value(v)
   if v.speed < 0 then dir = fa_utils.rotate_180(dir) end

   --Set the trigger distance
   local trigger = 1
   if mode == 1 then
      trigger = 3
   elseif mode == 2 then
      trigger = 10
   elseif mode == 3 then
      trigger = 25
   else
      trigger = 50
   end

   --Scan for entities within the radius
   local ents_around = {}
   if p.vehicle.type == "car" then
      local radius = trigger + 5
      --For cars, exclude anything they cannot collide with
      ents_around = surf.find_entities_filtered({
         area = {
            { v.position.x - radius, v.position.y - radius },
            { v.position.x + radius, v.position.y + radius },
         },
         type = {
            "resource",
            "highlight-box",
            "flying-text",
            "corpse",
            "straight-rail",
            "curved-rail",
            "rail-signal",
            "rail-chain-signal",
            "transport-belt",
            "underground-belt",
            "splitter",
            "item-entity",
            "pipe",
            "pipe-to-ground",
            "inserter",
            "small-electric-pole",
            "medium-electric-pole",
         },
         invert = true,
      })
   elseif p.vehicle.train ~= nil then
      trigger = trigger * 3
      local radius = trigger + 5
      --For trains, search for anything they can collide with
      ents_around = surf.find_entities_filtered({
         area = {
            { v.position.x - radius, v.position.y - radius },
            { v.position.x + radius, v.position.y + radius },
         },
         type = { "locomotive", "cargo-wagon", "fluid-wagon", "artillery-wagon", "character", "car", "unit" },
         invert = false,
      })
   end

   --Filter entities by direction
   local ents_ahead = {}
   for i, ent in ipairs(ents_around) do
      local dir_ent = fa_utils.get_direction_biased(ent.position, v.position)
      if dir_ent == dir then
         if p.vehicle.type == "car" and ent.unit_number ~= p.vehicle.unit_number then
            --For cars, take the entity as it is
            table.insert(ents_ahead, ent)
         elseif p.vehicle.train ~= nil and ent.unit_number ~= p.vehicle.unit_number then
            --For trains, the entity must also be near/on rails
            local ent_straight_rails =
               surf.find_entities_filtered({ position = ent.position, radius = 2, type = { "straight-rail" } })
            local ent_curved_rails =
               surf.find_entities_filtered({ position = ent.position, radius = 4, type = { "curved-rail" } })
            if
               (ent_straight_rails ~= nil and #ent_straight_rails > 0)
               or (ent_curved_rails ~= nil and #ent_curved_rails > 0)
            then
               if not (ent.train and ent.train.id == v.train.id) then table.insert(ents_ahead, ent) end
            end
         end
      elseif
         mode < 2
         and util.distance(v.position, ent.position) < 5
         and (math.abs(dir_ent - dir) == 1 or math.abs(dir_ent - dir) == 7)
      then
         --Take very nearby ents at diagonal directions
         if p.vehicle.type == "car" and ent.unit_number ~= p.vehicle.unit_number then
            --For cars, take the entity as it is
            table.insert(ents_ahead, ent)
         elseif p.vehicle.train ~= nil and ent.unit_number ~= p.vehicle.unit_number then
            --For trains, the entity must also be near/on rails and not from the same train (if reversing)
            local ent_straight_rails =
               surf.find_entities_filtered({ position = ent.position, radius = 2, type = { "straight-rail" } })
            local ent_curved_rails =
               surf.find_entities_filtered({ position = ent.position, radius = 4, type = { "curved-rail" } })
            if
               (ent_straight_rails ~= nil and #ent_straight_rails > 0)
               or (ent_curved_rails ~= nil and #ent_curved_rails > 0)
            then
               if not (ent.train and ent.train.id == v.train.id) then table.insert(ents_ahead, ent) end
            end
         end
      end
   end

   --Skip if nothing is ahead
   if #ents_ahead == 0 then
      return true
   else
   end

   --Get distance to nearest entity ahead
   local nearest = v.surface.get_closest(v.position, ents_ahead)
   if nearest == nil then
      --Skip if nearest does not exist
      return true
   end
   local edge_dist = util.distance(v.position, nearest.position) - 1 / 4 * (nearest.tile_width + nearest.tile_height)
   --Draw a circle around the nearest potentially beeping entity
   rendering.draw_circle({
      color = { 0.8, 0.8, 0.8 },
      radius = 2,
      width = 2,
      target = nearest,
      surface = p.surface,
      time_to_live = 15,
   })

   --Beep
   if edge_dist < trigger then
      p.play_sound({ path = "player-bump-stuck-alert" })
      players[pindex].last_driving_alert_tick = last_driving_alert_tick
      players[pindex].last_driving_alert_ent = nearest
      --Draw a circle around the nearest confirmed beeping entity
      rendering.draw_circle({
         color = { 1.0, 0.4, 0.2 },
         radius = 2,
         width = 2,
         target = nearest,
         surface = p.surface,
         time_to_live = 15,
      })
      return false
   end
   return true
end

function mod.stop_vehicle(pindex)
   local vehicle = game.get_player(pindex).vehicle
   if vehicle and vehicle.valid then
      if vehicle.train == nil then
         vehicle.speed = 0
      elseif vehicle.train.state == defines.train_state.manual_control then
         vehicle.train.speed = 0
      end
   end
end

function mod.halve_vehicle_speed(pindex)
   local vehicle = game.get_player(pindex).vehicle
   if vehicle and vehicle.valid then
      if vehicle.train == nil then
         vehicle.speed = vehicle.speed / 2
      elseif vehicle.train.state == defines.train_state.manual_control then
         vehicle.train.speed = vehicle.train.speed / 2
      end
   end
end

--Pavement Driving Assist: Read CC state
function mod.pda_get_state_of_cruise_control(pindex)
   if remote.interfaces.PDA and remote.interfaces.PDA.get_state_of_cruise_control then
      return remote.call("PDA", "get_state_of_cruise_control", pindex)
   else
      return nil
   end
end

--Pavement Driving Assist: Set CC state
function mod.pda_set_state_of_cruise_control(pindex, new_state)
   if remote.interfaces.PDA and remote.interfaces.PDA.set_state_of_cruise_control then
      remote.call("PDA", "set_state_of_cruise_control", pindex, new_state)
      return 1
   else
      return nil
   end
end

--Pavement Driving Assist: Read CC speed limit in kmh
function mod.pda_get_cruise_control_limit(pindex)
   if remote.interfaces.PDA and remote.interfaces.PDA.get_cruise_control_limit then
      return remote.call("PDA", "get_cruise_control_limit", pindex)
   else
      return nil
   end
end

--Pavement Driving Assist: Set CC speed limit in kmh
function mod.pda_set_cruise_control_limit(pindex, new_value)
   if remote.interfaces.PDA and remote.interfaces.PDA.set_cruise_control_limit then
      remote.call("PDA", "set_cruise_control_limit", pindex, new_value)
      return 1
   else
      return nil
   end
end

--Pavement Driving Assist: Read assistant state
function mod.pda_get_state_of_driving_assistant(pindex)
   if remote.interfaces.PDA and remote.interfaces.PDA.get_state_of_driving_assistant then
      return remote.call("PDA", "get_state_of_driving_assistant", pindex)
   else
      return nil
   end
end

--Pavement Driving Assist: Set assistant state
function mod.pda_set_state_of_driving_assistant(pindex, new_state)
   if remote.interfaces.PDA and remote.interfaces.PDA.set_state_of_driving_assistant then
      remote.call("PDA", "set_state_of_driving_assistant", pindex, new_state)
      return 1
   else
      return nil
   end
end

--Pavement Driving Assist: Read assistant state after it has been toggled
function mod.pda_read_assistant_toggled_info(pindex)
   if game.get_player(pindex).driving then
      local is_on = not mod.pda_get_state_of_driving_assistant(pindex)
      if is_on == true then
         printout("Enabled pavement driving asssistant", pindex)
      elseif is_on == false then
         printout("Disabled pavement driving asssistant", pindex)
      else
         printout("Missing pavement driving asssistant", pindex)
      end
   end
end

--Pavement Driving Assist: Read CC state after it has been toggled
function mod.pda_read_cruise_control_toggled_info(pindex)
   if game.get_player(pindex).driving then
      local is_on = not mod.pda_get_state_of_cruise_control(pindex)
      if is_on == true then
         printout("Enabled constant speed driving", pindex)
      elseif is_on == false then
         printout("Disabled constant speed driving", pindex)
      else
         printout("Missing constant speed driving", pindex)
      end
      mod.pda_set_cruise_control_limit(pindex, 0.16)
   end
end

return mod
