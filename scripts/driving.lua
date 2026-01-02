--Here: Functions about driving, mainly cars.

local util = require("util")
local FaUtils = require("scripts.fa-utils")
local Speech = require("scripts.speech")
local MessageBuilder = Speech.MessageBuilder
local VanillaMode = require("scripts.vanilla-mode")
local dirs = defines.direction

local mod = {}

--Report more info about a vehicle.
function mod.vehicle_info(pindex)
   if not game.get_player(pindex).driving then return { "fa.driving-not-in-vehicle" } end

   local vehicle = game.get_player(pindex).vehicle
   return { "fa.driving-car", { "entity-name." .. vehicle.name }, mod.fuel_inventory_info(vehicle) }
end

--Return fuel content in a fuel inventory
function mod.fuel_inventory_info(ent)
   local itemtable = ent.get_fuel_inventory().get_contents()
   table.sort(itemtable, function(k1, k2)
      return k1.count > k2.count
   end)
   if #itemtable == 0 then return { "fa.driving-no-fuel" } end

   local fuel_items = {}
   for i = 1, math.min(3, #itemtable) do
      table.insert(
         fuel_items,
         { "fa.driving-fuel-item", { "item-name." .. itemtable[i].name }, tostring(itemtable[i].count) }
      )
   end

   return { "fa.driving-contains-fuel", FaUtils.build_list(fuel_items) }
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
   if VanillaMode.is_enabled(pindex) then return end
   --Return if beeped recently
   local min_delay = 15
   if storage.players[pindex].last_driving_alert_tick == nil then
      storage.players[pindex].last_driving_alert_tick = tick
      return false
   end
   local last_driving_alert_tick = storage.players[pindex].last_driving_alert_tick
   local time_since = tick - last_driving_alert_tick
   if last_driving_alert_tick ~= nil and time_since < min_delay then return false end
   --Scan area "ahead" according to direction
   local v = p.vehicle
   local dir = FaUtils.get_heading_value(v)
   if v.speed < 0 then dir = FaUtils.rotate_180(dir) end

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

   --Scan for entities within the radius (cars only)
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
            "corpse",
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
   end

   --Filter entities by direction
   local ents_ahead = {}
   for i, ent in ipairs(ents_around) do
      local dir_ent = FaUtils.get_direction_biased(ent.position, v.position)
      if dir_ent == dir then
         if p.vehicle.type == "car" and ent.unit_number ~= p.vehicle.unit_number then
            --For cars, take the entity as it is
            table.insert(ents_ahead, ent)
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
      storage.players[pindex].last_driving_alert_tick = last_driving_alert_tick
      storage.players[pindex].last_driving_alert_ent = nearest
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
   if vehicle and vehicle.valid then vehicle.speed = 0 end
end

function mod.halve_vehicle_speed(pindex)
   local vehicle = game.get_player(pindex).vehicle
   if vehicle and vehicle.valid then vehicle.speed = vehicle.speed / 2 end
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
         Speech.speak(pindex, { "fa.driving-pda-enabled" })
      elseif is_on == false then
         Speech.speak(pindex, { "fa.driving-pda-disabled" })
      else
         Speech.speak(pindex, { "fa.driving-pda-missing" })
      end
   end
end

--Pavement Driving Assist: Read CC state after it has been toggled
function mod.pda_read_cruise_control_toggled_info(pindex)
   if game.get_player(pindex).driving then
      local is_on = not mod.pda_get_state_of_cruise_control(pindex)
      if is_on == true then
         Speech.speak(pindex, { "fa.driving-cruise-enabled" })
      elseif is_on == false then
         Speech.speak(pindex, { "fa.driving-cruise-disabled" })
      else
         Speech.speak(pindex, { "fa.driving-cruise-missing" })
      end
      mod.pda_set_cruise_control_limit(pindex, 0.16)
   end
end

return mod
