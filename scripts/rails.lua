--Here: Functions about rail systems, excluding those about building them
--Does not include event handlers

local util = require("util")
local FaUtils = require("scripts.fa-utils")
local Mouse = require("scripts.mouse")
local dirs = defines.direction

local mod = {}

--Key information about rail units.
function mod.rail_ent_info(pindex, ent, description)
   local result = ""
   local is_end_rail = false
   local is_horz_or_vert = false

   --Check if end rail: The rail is at the end of its segment and is also not connected to another rail
   is_end_rail, end_rail_dir, build_comment = mod.check_end_rail(ent, pindex)
   if is_end_rail then
      --Further check if it is a single rail
      if build_comment == "single rail" then result = result .. "Single " end
      result = result .. "End rail "
   else
      result = result .. "Rail "
   end

   --Explain the rail facing direction
   if ent.name == "straight-rail" and is_end_rail then
      result = result .. " straight "
      if end_rail_dir == dirs.north then
         result = result .. " facing North "
      elseif end_rail_dir == dirs.northeast then
         result = result .. " facing Northeast "
      elseif end_rail_dir == dirs.east then
         result = result .. " facing East "
      elseif end_rail_dir == dirs.southeast then
         result = result .. " facing Southeast "
      elseif end_rail_dir == dirs.south then
         result = result .. " facing South "
      elseif end_rail_dir == dirs.southwest then
         result = result .. " facing Southwest "
      elseif end_rail_dir == dirs.west then
         result = result .. " facing West "
      elseif end_rail_dir == dirs.northwest then
         result = result .. " facing Northwest "
      end
   elseif ent.name == "straight-rail" and is_end_rail == false then
      if ent.direction == dirs.north or ent.direction == dirs.south then --always reports 0 it seems
         result = result .. " vertical "
         is_horz_or_vert = true
      elseif ent.direction == dirs.east or ent.direction == dirs.west then --always reports 2 it seems
         result = result .. " horizontal "
         is_horz_or_vert = true
      elseif ent.direction == dirs.northeast then
         result = result .. " on falling diagonal, left half "
      elseif ent.direction == dirs.southwest then
         result = result .. " on falling diagonal, right half "
      elseif ent.direction == dirs.southeast then
         result = result .. " on rising diagonal, left half "
      elseif ent.direction == dirs.northwest then
         result = result .. " on rising diagonal, right half "
      end
   elseif ent.name == "curved-rail" and is_end_rail == true then
      result = result .. " curved "
      if end_rail_dir == dirs.north then
         result = result .. " facing North "
      elseif end_rail_dir == dirs.northeast then
         result = result .. " facing Northeast "
      elseif end_rail_dir == dirs.east then
         result = result .. " facing East "
      elseif end_rail_dir == dirs.southeast then
         result = result .. " facing Southeast "
      elseif end_rail_dir == dirs.south then
         result = result .. " facing South "
      elseif end_rail_dir == dirs.southwest then
         result = result .. " facing Southwest "
      elseif end_rail_dir == dirs.west then
         result = result .. " facing West "
      elseif end_rail_dir == dirs.northwest then
         result = result .. " facing Northwest "
      end
   elseif ent.name == "curved-rail" and is_end_rail == false then
      result = result .. " curved "
      if ent.direction == dirs.north then --0
         result = result .. " south and northwest "
      elseif ent.direction == dirs.northeast then
         result = result .. " south and northeast "
      elseif ent.direction == dirs.east then
         result = result .. " west  and northeast "
      elseif ent.direction == dirs.southeast then
         result = result .. " west  and southeast "
      elseif ent.direction == dirs.south then
         result = result .. " north and southeast "
      elseif ent.direction == dirs.southwest then
         result = result .. " north and southwest "
      elseif ent.direction == dirs.west then
         result = result .. " east  and southwest "
      elseif ent.direction == dirs.northwest then --7
         result = result .. " east  and northwest "
      end
   end

   --Check if intersection
   if mod.is_intersection_rail(ent, pindex) then result = result .. ", intersection " end
   --Check if at junction: The rail has at least 3 connections
   local connection_count = mod.count_rail_connections(ent)
   if connection_count > 2 then result = result .. ", fork " end

   --Check if it has rail signals
   local chain_s_count = 0
   local rail_s_count = 0
   local signals =
      ent.surface.find_entities_filtered({ position = ent.position, radius = 2, name = "rail-chain-signal" })
   for i, s in ipairs(signals) do
      chain_s_count = chain_s_count + 1
      rendering.draw_circle({
         color = { 0.5, 0.5, 1 },
         radius = 2,
         width = 2,
         target = ent,
         surface = ent.surface,
         time_to_live = 90,
      })
   end

   signals = ent.surface.find_entities_filtered({ position = ent.position, radius = 2, name = "rail-signal" })
   for i, s in ipairs(signals) do
      rail_s_count = rail_s_count + 1
      rendering.draw_circle({
         color = { 0.5, 0.5, 1 },
         radius = 2,
         width = 2,
         target = ent,
         surface = ent.surface,
         time_to_live = 90,
      })
   end

   if chain_s_count + rail_s_count == 0 then
      --(nothing)
   elseif chain_s_count + rail_s_count == 1 then
      result = result .. " with one signal, "
   elseif chain_s_count + rail_s_count == 2 then
      result = result .. " with a pair of signals, "
   elseif chain_s_count + rail_s_count > 2 then
      result = result .. " with many signals, "
   end

   --Check if there is a train stop nearby, to announce station spaces
   if is_horz_or_vert then
      local stop = nil
      local segment_ent_1 = ent.get_rail_segment_entity(defines.rail_direction.front, false)
      local segment_ent_2 = ent.get_rail_segment_entity(defines.rail_direction.back, false)
      if
         segment_ent_1 ~= nil
         and segment_ent_1.name == "train-stop"
         and util.distance(ent.position, segment_ent_1.position) < 45
      then
         stop = segment_ent_1
      elseif
         segment_ent_2 ~= nil
         and segment_ent_2.name == "train-stop"
         and util.distance(ent.position, segment_ent_2.position) < 45
      then
         stop = segment_ent_2
      end
      if stop == nil then return result end

      --Check if this rail is in the correct direction of the train stop
      local rail_dir_1 = segment_ent_1 == stop
      local rail_dir_2 = segment_ent_2 == stop
      local stop_dir = stop.connected_rail_direction
      local pairing_correct = false

      if rail_dir_1 and stop_dir == defines.rail_direction.front then
         --result = result .. ", pairing 1, "
         pairing_correct = true
      elseif rail_dir_1 and stop_dir == defines.rail_direction.back then
         --result = result .. ", pairing 2, "
         pairing_correct = false
      elseif rail_dir_2 and stop_dir == defines.rail_direction.front then
         --result = result .. ", pairing 3, "
         pairing_correct = false
      elseif rail_dir_2 and stop_dir == defines.rail_direction.back then
         --result = result .. ", pairing 4, "
         pairing_correct = true
      else
         result = result .. ", pairing error, "
         pairing_correct = false
      end

      if not pairing_correct then return result end

      --Count distance and determine railcar slot
      local dist = util.distance(ent.position, stop.position)
      --result = result .. " stop distance " .. dist
      if dist < 2 then
         result = result .. " station locomotive space front"
      elseif dist < 3 then
         result = result .. " station locomotive space middle"
      elseif dist < 5 then
         result = result .. " station locomotive space middle"
      elseif dist < 7 then
         result = result .. " station locomotive end and gap 1"
      elseif dist < 9 then
         result = result .. " station space 1 front"
      elseif dist < 11 then
         result = result .. " station space 1 middle"
      elseif dist < 13 then
         result = result .. " station space 1 end"
      elseif dist < 15 then
         result = result .. " station gap 2 and station space 2 front"
      elseif dist < 17 then
         result = result .. " station space 2 middle"
      elseif dist < 19 then
         result = result .. " station space 2 middle"
      elseif dist < 21 then
         result = result .. " station space 2 end and gap 3"
      elseif dist < 23 then
         result = result .. " station space 3 front"
      elseif dist < 25 then
         result = result .. " station space 3 middle"
      elseif dist < 27 then
         result = result .. " station space 3 end"
      elseif dist < 29 then
         result = result .. " station gap 4 and station space 4 front"
      elseif dist < 31 then
         result = result .. " station space 4 middle"
      elseif dist < 33 then
         result = result .. " station space 4 middle"
      elseif dist < 35 then
         result = result .. " station space 4 end and gap 5"
      elseif dist < 37 then
         result = result .. " station space 5 front"
      elseif dist < 39 then
         result = result .. " station space 5 middle"
      elseif dist < 41 then
         result = result .. " station space 5 end"
      elseif dist < 43 then
         result = result .. " station gap 6 and station space 6 front"
      elseif dist < 45 then
         result = result .. " station space 6 middle"
      end
   end

   return result
end

--Determines how many connections a rail has
function mod.count_rail_connections(ent)
   local front_left_rail, r_dir_back, c_dir_back = ent.get_connected_rail({
      rail_direction = defines.rail_direction.front,
      rail_connection_direction = defines.rail_connection_direction.left,
   })
   local front_right_rail, r_dir_back, c_dir_back = ent.get_connected_rail({
      rail_direction = defines.rail_direction.front,
      rail_connection_direction = defines.rail_connection_direction.right,
   })
   local back_left_rail, r_dir_back, c_dir_back = ent.get_connected_rail({
      rail_direction = defines.rail_direction.back,
      rail_connection_direction = defines.rail_connection_direction.left,
   })
   local back_right_rail, r_dir_back, c_dir_back = ent.get_connected_rail({
      rail_direction = defines.rail_direction.back,
      rail_connection_direction = defines.rail_connection_direction.right,
   })
   local next_rail, r_dir_back, c_dir_back = ent.get_connected_rail({
      rail_direction = defines.rail_direction.front,
      rail_connection_direction = defines.rail_connection_direction.straight,
   })
   local prev_rail, r_dir_back, c_dir_back = ent.get_connected_rail({
      rail_direction = defines.rail_direction.back,
      rail_connection_direction = defines.rail_connection_direction.straight,
   })

   local connection_count = 0
   if next_rail ~= nil then connection_count = connection_count + 1 end
   if prev_rail ~= nil then connection_count = connection_count + 1 end
   if front_left_rail ~= nil then connection_count = connection_count + 1 end
   if front_right_rail ~= nil then connection_count = connection_count + 1 end
   if back_left_rail ~= nil then connection_count = connection_count + 1 end
   if back_right_rail ~= nil then connection_count = connection_count + 1 end
   return connection_count
end

--Determines how many connections a rail has
function mod.list_rail_fork_directions(ent)
   local result = ""
   local front_left_rail, r_dir_back, c_dir_back = ent.get_connected_rail({
      rail_direction = defines.rail_direction.front,
      rail_connection_direction = defines.rail_connection_direction.left,
   })
   local front_right_rail, r_dir_back, c_dir_back = ent.get_connected_rail({
      rail_direction = defines.rail_direction.front,
      rail_connection_direction = defines.rail_connection_direction.right,
   })
   local back_left_rail, r_dir_back, c_dir_back = ent.get_connected_rail({
      rail_direction = defines.rail_direction.back,
      rail_connection_direction = defines.rail_connection_direction.left,
   })
   local back_right_rail, r_dir_back, c_dir_back = ent.get_connected_rail({
      rail_direction = defines.rail_direction.back,
      rail_connection_direction = defines.rail_connection_direction.right,
   })
   local next_rail, r_dir_back, c_dir_back = ent.get_connected_rail({
      rail_direction = defines.rail_direction.front,
      rail_connection_direction = defines.rail_connection_direction.straight,
   })
   local prev_rail, r_dir_back, c_dir_back = ent.get_connected_rail({
      rail_direction = defines.rail_direction.back,
      rail_connection_direction = defines.rail_connection_direction.straight,
   })

   if next_rail ~= nil then result = result .. "straight forward, " end
   if front_left_rail ~= nil then result = result .. "left forward, " end
   if front_right_rail ~= nil then result = result .. "right forward, " end
   if prev_rail ~= nil then result = result .. "straight back, " end
   if back_left_rail ~= nil then result = result .. "left back, " end
   if back_right_rail ~= nil then result = result .. "right back, " end
   return result
end

--Determines if an entity is an end rail. Returns boolean is_end_rail, integer end rail direction, and string comment for errors.
function mod.check_end_rail(check_rail, pindex)
   local is_end_rail = false
   ---@type defines.direction | int
   local dir = -1
   local comment = "Check function error."

   --Check if the entity is a rail
   if check_rail == nil then
      is_end_rail = false
      comment = "Nil."
      return is_end_rail, -1, comment
   end
   if not check_rail.valid then
      is_end_rail = false
      comment = "Invalid."
      return is_end_rail, -1, comment
   end
   if not (check_rail.name == "straight-rail" or check_rail.name == "curved-rail") then
      is_end_rail = false
      comment = "Not a rail."
      return is_end_rail, -1, comment
   end

   --Check if end rail: The rail is at the end of its segment and has only 1 connection.
   end_rail_1, end_dir_1 = check_rail.get_rail_segment_end(defines.rail_direction.front)
   end_rail_2, end_dir_2 = check_rail.get_rail_segment_end(defines.rail_direction.back)
   local connection_count = mod.count_rail_connections(check_rail)
   if
      (check_rail.unit_number == end_rail_1.unit_number or check_rail.unit_number == end_rail_2.unit_number)
      and connection_count < 2
   then
      --End rail confirmed, get direction
      is_end_rail = true
      comment = "End rail confirmed."
      if connection_count == 0 then comment = "single rail" end
      if check_rail.name == "straight-rail" then
         local next_rail_straight, temp1, temp2 = check_rail.get_connected_rail({
            rail_direction = defines.rail_direction.front,
            rail_connection_direction = defines.rail_connection_direction.straight,
         })
         local next_rail_left, temp1, temp2 = check_rail.get_connected_rail({
            rail_direction = defines.rail_direction.front,
            rail_connection_direction = defines.rail_connection_direction.left,
         })
         local next_rail_right, temp1, temp2 = check_rail.get_connected_rail({
            rail_direction = defines.rail_direction.front,
            rail_connection_direction = defines.rail_connection_direction.right,
         })
         local next_rail = nil
         if next_rail_straight ~= nil then
            next_rail = next_rail_straight
         elseif next_rail_left ~= nil then
            next_rail = next_rail_left
         elseif next_rail_right ~= nil then
            next_rail = next_rail_right
         end
         local prev_rail_straight, temp1, temp2 = check_rail.get_connected_rail({
            rail_direction = defines.rail_direction.back,
            rail_connection_direction = defines.rail_connection_direction.straight,
         })
         local prev_rail_left, temp1, temp2 = check_rail.get_connected_rail({
            rail_direction = defines.rail_direction.back,
            rail_connection_direction = defines.rail_connection_direction.left,
         })
         local prev_rail_right, temp1, temp2 = check_rail.get_connected_rail({
            rail_direction = defines.rail_direction.back,
            rail_connection_direction = defines.rail_connection_direction.right,
         })
         local prev_rail = nil
         if prev_rail_straight ~= nil then
            prev_rail = prev_rail_straight
         elseif prev_rail_left ~= nil then
            prev_rail = prev_rail_left
         elseif prev_rail_right ~= nil then
            prev_rail = prev_rail_right
         end
         if check_rail.direction == dirs.north and next_rail == nil then
            dir = dirs.north
         elseif check_rail.direction == dirs.north and prev_rail == nil then
            dir = dirs.south
         elseif check_rail.direction == dirs.northeast and next_rail == nil then
            dir = dirs.northwest
         elseif check_rail.direction == dirs.northeast and prev_rail == nil then
            dir = dirs.southeast
         elseif check_rail.direction == dirs.east and next_rail == nil then
            dir = dirs.east
         elseif check_rail.direction == dirs.east and prev_rail == nil then
            dir = dirs.west
         elseif check_rail.direction == dirs.southeast and next_rail == nil then
            dir = dirs.northeast
         elseif check_rail.direction == dirs.southeast and prev_rail == nil then
            dir = dirs.southwest
         elseif check_rail.direction == dirs.south and next_rail == nil then
            dir = dirs.south
         elseif check_rail.direction == dirs.south and prev_rail == nil then
            dir = dirs.north
         elseif check_rail.direction == dirs.southwest and next_rail == nil then
            dir = dirs.southeast
         elseif check_rail.direction == dirs.southwest and prev_rail == nil then
            dir = dirs.northwest
         elseif check_rail.direction == dirs.west and next_rail == nil then
            dir = dirs.west
         elseif check_rail.direction == dirs.west and prev_rail == nil then
            dir = dirs.east
         elseif check_rail.direction == dirs.northwest and next_rail == nil then
            dir = dirs.southwest
         elseif check_rail.direction == dirs.northwest and prev_rail == nil then
            dir = dirs.northeast
         else
            --This line should not be reachable
            is_end_rail = false
            comment = "Rail direction error."
            return is_end_rail, -3, comment
         end
      elseif check_rail.name == "curved-rail" then
         local next_rail, r_dir_back, c_dir_back = check_rail.get_connected_rail({
            rail_direction = defines.rail_direction.front,
            rail_connection_direction = defines.rail_connection_direction.straight,
         })
         local prev_rail, r_dir_back, c_dir_back = check_rail.get_connected_rail({
            rail_direction = defines.rail_direction.back,
            rail_connection_direction = defines.rail_connection_direction.straight,
         })
         if check_rail.direction == dirs.north and next_rail == nil then
            dir = dirs.south
         elseif check_rail.direction == dirs.north and prev_rail == nil then
            dir = dirs.northwest
         elseif check_rail.direction == dirs.northeast and next_rail == nil then
            dir = dirs.south
         elseif check_rail.direction == dirs.northeast and prev_rail == nil then
            dir = dirs.northeast
         elseif check_rail.direction == dirs.east and next_rail == nil then
            dir = dirs.west
         elseif check_rail.direction == dirs.east and prev_rail == nil then
            dir = dirs.northeast
         elseif check_rail.direction == dirs.southeast and next_rail == nil then
            dir = dirs.west
         elseif check_rail.direction == dirs.southeast and prev_rail == nil then
            dir = dirs.southeast
         elseif check_rail.direction == dirs.south and next_rail == nil then
            dir = dirs.north
         elseif check_rail.direction == dirs.south and prev_rail == nil then
            dir = dirs.southeast
         elseif check_rail.direction == dirs.southwest and next_rail == nil then
            dir = dirs.north
         elseif check_rail.direction == dirs.southwest and prev_rail == nil then
            dir = dirs.southwest
         elseif check_rail.direction == dirs.west and next_rail == nil then
            dir = dirs.east
         elseif check_rail.direction == dirs.west and prev_rail == nil then
            dir = dirs.southwest
         elseif check_rail.direction == dirs.northwest and next_rail == nil then
            dir = dirs.east
         elseif check_rail.direction == dirs.northwest and prev_rail == nil then
            dir = dirs.northwest
         else
            --This line should not be reachable
            is_end_rail = false
            comment = "Rail direction error."
            return is_end_rail, -3, comment
         end
      end
   else
      --Not the end rail
      is_end_rail = false
      comment = "This rail is not the end rail."
      return is_end_rail, -4, comment
   end

   return is_end_rail, dir, comment
end

--Determines whether the cursor is at the outer tip of a rail, by checking the 8 tiles around the cursor and confirming that they do not contain other rails.
function mod.cursor_is_at_straight_end_rail_tip(pindex)
   local p = game.get_player(pindex)
   local pos = players[pindex].cursor_pos
   --Get the rail at the cursor
   --local rails_at_cursor = p.surface.find_entities_filtered({ name = "straight-rail", position = pos })
   -- TODO: #271, need old rails back
   local rails_at_cursor = nil
   if rails_at_cursor == nil or #rails_at_cursor == 0 then return false end
   --Check if it is an end rail that faces a cardinal direction
   local rail_at_cursor = rails_at_cursor[1]
   local is_end_rail, dir, comment = mod.check_end_rail(rail_at_cursor, pindex)
   if is_end_rail == false or (dir ~= dirs.north and dir ~= dirs.south and dir ~= dirs.east and dir ~= dirs.west) then
      return false
   end
   --Check if any rails around the cursor position have a different unit number
   local perimeter = {}
   perimeter[1] = FaUtils.add_position(pos, { x = -1, y = -1 })
   perimeter[2] = FaUtils.add_position(pos, { x = -1, y = 0 })
   perimeter[3] = FaUtils.add_position(pos, { x = -1, y = 1 })
   perimeter[4] = FaUtils.add_position(pos, { x = 0, y = -1 })
   perimeter[5] = FaUtils.add_position(pos, { x = 0, y = 1 })
   perimeter[6] = FaUtils.add_position(pos, { x = 1, y = -1 })
   perimeter[7] = FaUtils.add_position(pos, { x = 1, y = 0 })
   perimeter[8] = FaUtils.add_position(pos, { x = 1, y = 1 })
   for i, pos_p in ipairs(perimeter) do
      --Find rails, if any
      -- TODO: #271, we need old rails back or the query crashes.
      --local ents = p.surface.find_entities_filtered({ name = { "straight-rail", "curved-rail" }, position = pos_p })
      local ents = {}
      if ents ~= nil and #ents > 0 then
         for j, rail in ipairs(ents) do
            --For rails found, check whether the unit number is different
            if rail.unit_number ~= rail_at_cursor.unit_number then return false end
         end
      end
   end
   --Given that the cursor is on an end rail and no other rails are around the cursor, return true
   return true
end

--Look up and translate the signal state.
function mod.get_signal_state_info(signal)
   local state_id = 0
   local state_lookup = nil
   local state_name = ""
   local result = ""
   if signal.name == "rail-signal" then
      state_id = signal.signal_state
      state_lookup = FaUtils.into_lookup(defines.signal_state)
      state_name = state_lookup[state_id]
      result = state_name
   elseif signal.name == "rail-chain-signal" then
      state_id = signal.chain_signal_state
      state_lookup = FaUtils.into_lookup(defines.chain_signal_state)
      state_name = state_lookup[state_id]
      result = state_name
      if state_name == "none_open" then result = "closed" end
   end
   return result
end

--Returns the rail at the end of an input rail's segment. If the input rail is already one end of the segment then it returns the other end. NOT TESTED
function mod.get_rail_segment_other_end(rail)
   local end_rail_1, end_dir_1 = rail.get_rail_segment_end(defines.rail_direction.front) --Cannot be nil
   local end_rail_2, end_dir_2 = rail.get_rail_segment_end(defines.rail_direction.back) --Cannot be nil

   if rail.unit_number == end_rail_1.unit_number and rail.unit_number ~= end_rail_2.unit_number then
      return end_rail_2
   elseif rail.unit_number ~= end_rail_1.unit_number and rail.unit_number == end_rail_2.unit_number then
      return end_rail_1
   else
      --The other end is either both options or neither, so return any.
      return end_rail_1
   end
end

--For a rail at the end of its segment, returns the neighboring rail segment's end rail. Respects dir in terms of left/right/straight if it is given, else returns the first found option.
function mod.get_neighbor_rail_segment_end(rail, con_dir_in)
   local dir = con_dir_in or nil
   local requested_neighbor_rail_1 = nil
   local requested_neighbor_rail_2 = nil
   local neighbor_rail, r_dir_back, c_dir_back = nil, nil, nil

   if dir ~= nil then
      --Check requested neighbor
      requested_neighbor_rail_1, req_dir_1, req_con_dir_1 =
         rail.get_connected_rail({ rail_direction = defines.rail_direction.front, rail_connection_direction = dir })
      requested_neighbor_rail_2, req_dir_2, req_con_dir_2 =
         rail.get_connected_rail({ rail_direction = defines.rail_direction.back, rail_connection_direction = dir })
      if requested_neighbor_rail_1 ~= nil and not rail.is_rail_in_same_rail_segment_as(requested_neighbor_rail_1) then
         return requested_neighbor_rail_1, req_dir_1, req_con_dir_1
      elseif
         requested_neighbor_rail_2 ~= nil and not rail.is_rail_in_same_rail_segment_as(requested_neighbor_rail_2)
      then
         return requested_neighbor_rail_2, req_dir_2, req_con_dir_2
      else
         return nil, nil, nil
      end
   else
      --Try all 6 options until you get any
      neighbor_rail, r_dir_back, c_dir_back = rail.get_connected_rail({
         rail_direction = defines.rail_direction.front,
         rail_connection_direction = defines.rail_connection_direction.straight,
      })
      if neighbor_rail ~= nil and not neighbor_rail.is_rail_in_same_rail_segment_as(rail) then
         return neighbor_rail, r_dir_back, c_dir_back
      end

      neighbor_rail, r_dir_back, c_dir_back = rail.get_connected_rail({
         rail_direction = defines.rail_direction.back,
         rail_connection_direction = defines.rail_connection_direction.straight,
      })
      if neighbor_rail ~= nil and not neighbor_rail.is_rail_in_same_rail_segment_as(rail) then
         return neighbor_rail, r_dir_back, c_dir_back
      end

      neighbor_rail, r_dir_back, c_dir_back = rail.get_connected_rail({
         rail_direction = defines.rail_direction.front,
         rail_connection_direction = defines.rail_connection_direction.left,
      })
      if neighbor_rail ~= nil and not neighbor_rail.is_rail_in_same_rail_segment_as(rail) then
         return neighbor_rail, r_dir_back, c_dir_back
      end

      neighbor_rail, r_dir_back, c_dir_back = rail.get_connected_rail({
         rail_direction = defines.rail_direction.front,
         rail_connection_direction = defines.rail_connection_direction.right,
      })
      if neighbor_rail ~= nil and not neighbor_rail.is_rail_in_same_rail_segment_as(rail) then
         return neighbor_rail, r_dir_back, c_dir_back
      end

      neighbor_rail, r_dir_back, c_dir_back = rail.get_connected_rail({
         rail_direction = defines.rail_direction.back,
         rail_connection_direction = defines.rail_connection_direction.left,
      })
      if neighbor_rail ~= nil and not neighbor_rail.is_rail_in_same_rail_segment_as(rail) then
         return neighbor_rail, r_dir_back, c_dir_back
      end

      neighbor_rail, r_dir_back, c_dir_back = rail.get_connected_rail({
         rail_direction = defines.rail_direction.back,
         rail_connection_direction = defines.rail_connection_direction.right,
      })
      if neighbor_rail ~= nil and not neighbor_rail.is_rail_in_same_rail_segment_as(rail) then
         return neighbor_rail, r_dir_back, c_dir_back
      end

      return nil, nil, nil
   end
end

--Reads all rail segment entities around a rail.
--Result 1: A rail or chain signal creates a new segment and is at the end of one of the two segments.
--Result 2: A train creates a new segment and is at the end of one of the two segments. It can be reported twice for FW1 and BACK2 or for FW2 and BACK1.
function mod.read_all_rail_segment_entities(pindex, rail)
   local message = ""
   local ent_f1 = rail.get_rail_segment_entity(defines.rail_direction.front, true)
   local ent_f2 = rail.get_rail_segment_entity(defines.rail_direction.front, false)
   local ent_b1 = rail.get_rail_segment_entity(defines.rail_direction.back, true)
   local ent_b2 = rail.get_rail_segment_entity(defines.rail_direction.back, false)

   if ent_f1 == nil then
      message = message .. "forward 1 is nil, "
   elseif ent_f1.name == "train-stop" then
      message = message .. "forward 1 is train stop " .. ent_f1.backer_name .. ", "
   elseif ent_f1.name == "rail-signal" then
      message = message .. "forward 1 is rails signal with signal " .. mod.get_signal_state_info(ent_f1) .. ", "
   elseif ent_f1.name == "rail-chain-signal" then
      message = message .. "forward 1 is chain signal with signal " .. mod.get_signal_state_info(ent_f1) .. ", "
   else
      message = message .. "forward 1 is else, " .. ent_f1.name .. ", "
   end

   if ent_f2 == nil then
      message = message .. "forward 2 is nil, "
   elseif ent_f2.name == "train-stop" then
      message = message .. "forward 2 is train stop " .. ent_f2.backer_name .. ", "
   elseif ent_f2.name == "rail-signal" then
      message = message .. "forward 2 is rails signal with signal " .. mod.get_signal_state_info(ent_f2) .. ", "
   elseif ent_f2.name == "rail-chain-signal" then
      message = message .. "forward 2 is chain signal with signal " .. mod.get_signal_state_info(ent_f2) .. ", "
   else
      message = message .. "forward 2 is else, " .. ent_f2.name .. ", "
   end

   if ent_b1 == nil then
      message = message .. "back 1 is nil, "
   elseif ent_b1.name == "train-stop" then
      message = message .. "back 1 is train stop " .. ent_b1.backer_name .. ", "
   elseif ent_b1.name == "rail-signal" then
      message = message .. "back 1 is rails signal with signal " .. mod.get_signal_state_info(ent_b1) .. ", "
   elseif ent_b1.name == "rail-chain-signal" then
      message = message .. "back 1 is chain signal with signal " .. mod.get_signal_state_info(ent_b1) .. ", "
   else
      message = message .. "back 1 is else, " .. ent_b1.name .. ", "
   end

   if ent_b2 == nil then
      message = message .. "back 2 is nil, "
   elseif ent_b2.name == "train-stop" then
      message = message .. "back 2 is train stop " .. ent_b2.backer_name .. ", "
   elseif ent_b2.name == "rail-signal" then
      message = message .. "back 2 is rails signal with signal " .. mod.get_signal_state_info(ent_b2) .. ", "
   elseif ent_b2.name == "rail-chain-signal" then
      message = message .. "back 2 is chain signal with signal " .. mod.get_signal_state_info(ent_b2) .. ", "
   else
      message = message .. "back 2 is else, " .. ent_b2.name .. ", "
   end

   printout(message, pindex)
   return
end

--Gets opposite rail direction
function mod.get_opposite_rail_direction(dir)
   if dir == defines.rail_direction.front then
      return defines.rail_direction.back
   else
      return defines.rail_direction.front
   end
end

--Return what is ahead at the end of this rail's segment in this given direction.
--Return the entity, a label, an extra value sometimes, and whether the entity faces the forward direction
function mod.identify_rail_segment_end_object(rail, dir_ahead, accept_only_forward, prefer_back)
   local result_entity = nil
   local result_entity_label = ""
   local result_extra = nil
   local result_is_forward = nil

   if rail == nil or rail.valid == false then
      --Error
      result_entity = nil
      result_entity_label = "missing rail"
      return result_entity, result_entity_label, result_extra, result_is_forward
   end

   --Correction: Flip the correct direction ahead for mismatching diagonal rails
   if
      rail.name == "straight-rail" and (rail.direction == dirs.southwest or rail.direction == dirs.northwest)
      or rail.name == "curved-rail"
         and (rail.direction == dirs.north or rail.direction == dirs.northeast or rail.direction == dirs.east or rail.direction == dirs.southeast)
   then
      dir_ahead = mod.get_opposite_rail_direction(dir_ahead)
   end

   local segment_last_rail = rail.get_rail_segment_end(dir_ahead)
   local entity_ahead = nil
   local entity_ahead_forward = rail.get_rail_segment_entity(dir_ahead, false)
   local entity_ahead_reverse = rail.get_rail_segment_entity(dir_ahead, true)

   local segment_last_is_end_rail, end_rail_dir, comment = mod.check_end_rail(segment_last_rail, pindex)
   local segment_last_neighbor_count = mod.count_rail_connections(segment_last_rail)

   if entity_ahead_forward ~= nil then
      entity_ahead = entity_ahead_forward
      result_is_forward = true
   elseif entity_ahead_reverse ~= nil and accept_only_forward == false then
      entity_ahead = entity_ahead_reverse
      result_is_forward = false
   end

   if prefer_back == true and entity_ahead_reverse ~= nil and accept_only_forward == false then
      entity_ahead = entity_ahead_reverse
      result_is_forward = false
   end

   --When no entity ahead, check if the segment end is an end rail or fork rail?
   if entity_ahead == nil then
      if segment_last_is_end_rail then
         --End rail
         result_entity = segment_last_rail
         result_entity_label = "end rail"
         result_extra = end_rail_dir
         return result_entity, result_entity_label, result_extra, result_is_forward
      elseif segment_last_neighbor_count > 2 then
         --Junction rail
         result_entity = segment_last_rail
         result_entity_label = "fork split"
         result_extra = rail --A rail from the segment "entering" the junction
         return result_entity, result_entity_label, result_extra, result_is_forward
      else
         --The neighbor of the segment end rail is either a fork or an end rail or has an entity instead
         neighbor_rail, neighbor_r_dir, neighbor_c_dir = mod.get_neighbor_rail_segment_end(segment_last_rail, nil)
         if neighbor_rail == nil then
            --This must be a closed loop?
            result_entity = nil
            result_entity_label = "loop"
            result_extra = nil
            return result_entity, result_entity_label, result_extra, result_is_forward
         elseif mod.count_rail_connections(neighbor_rail) > 2 then
            --The neighbor is a forking rail
            result_entity = neighbor_rail
            result_entity_label = "fork merge"
            result_extra = nil
            return result_entity, result_entity_label, result_extra, result_is_forward
         elseif mod.count_rail_connections(neighbor_rail) == 1 then
            --The neighbor is an end rail
            local neighbor_is_end_rail, end_rail_dir, comment = mod.check_end_rail(neighbor_rail, pindex)
            result_entity = neighbor_rail
            result_entity_label = "neighbor end"
            result_extra = end_rail_dir
            return result_entity, result_entity_label, result_extra, result_is_forward
         else
            --The neighbor rail should have an entity?
            result_entity = segment_last_rail
            result_entity_label = "other rail"
            result_extra = nil
            return result_entity, result_entity_label, result_extra, result_is_forward
         end
      end
   --When entity ahead, check its type
   else
      if entity_ahead.name == "rail-signal" then
         result_entity = entity_ahead
         result_entity_label = "rail signal"
         result_extra = mod.get_signal_state_info(entity_ahead)
         return result_entity, result_entity_label, result_extra, result_is_forward
      elseif entity_ahead.name == "rail-chain-signal" then
         result_entity = entity_ahead
         result_entity_label = "chain signal"
         result_extra = mod.get_signal_state_info(entity_ahead)
         return result_entity, result_entity_label, result_extra, result_is_forward
      elseif entity_ahead.name == "train-stop" then
         result_entity = entity_ahead
         result_entity_label = "train stop"
         result_extra = entity_ahead.backer_name
         return result_entity, result_entity_label, result_extra, result_is_forward
      else
         --This is NOT expected.
         result_entity = entity_ahead
         result_entity_label = "other entity"
         result_extra = "Unidentified " .. entity_ahead.name
         return result_entity, result_entity_label, result_extra, result_is_forward
      end
   end
end

--Reads out the nearest railway object ahead with relevant details. Skips to the next segment if needed.
--The output could be an end rail, junction rail, rail signal, chain signal, or train stop.
function mod.get_next_rail_entity_ahead(origin_rail, dir_ahead, only_this_segment)
   local next_entity, next_entity_label, result_extra, next_is_forward =
      mod.identify_rail_segment_end_object(origin_rail, dir_ahead, false, false)
   local iteration_count = 1
   local segment_end_ahead, dir_se = origin_rail.get_rail_segment_end(dir_ahead)
   local prev_rail = segment_end_ahead
   local current_rail = origin_rail
   local neighbor_r_dir = dir_ahead
   local neighbor_c_dir = nil

   --First correction for the train stop exception
   if next_entity_label == "train stop" and next_is_forward == false then
      next_entity, next_entity_label, result_extra, next_is_forward =
         mod.identify_rail_segment_end_object(current_rail, neighbor_r_dir, true, false)
   end

   --Skip all "other rail" cases
   while not only_this_segment and next_entity_label == "other rail" and iteration_count < 100 do
      if iteration_count % 2 == 1 then
         --Switch to neighboring segment
         current_rail, neighbor_r_dir, neighbor_c_dir = mod.get_neighbor_rail_segment_end(prev_rail, nil)
         prev_rail = current_rail
         next_entity, next_entity_label, result_extra, next_is_forward =
            mod.identify_rail_segment_end_object(current_rail, neighbor_r_dir, false, true)
         --Correction for the train stop exception
         if next_entity_label == "train stop" and next_is_forward == false then
            next_entity, next_entity_label, result_extra, next_is_forward =
               mod.identify_rail_segment_end_object(current_rail, neighbor_r_dir, true, true)
         end
         --Correction for flipped direction
         if next_is_forward ~= nil then next_is_forward = not next_is_forward end
         iteration_count = iteration_count + 1
      else
         --Check other end of the segment. NOTE: Never got more than 2 iterations in tests so far...
         neighbor_r_dir = mod.get_opposite_rail_direction(neighbor_r_dir)
         next_entity, next_entity_label, result_extra, next_is_forward =
            mod.identify_rail_segment_end_object(current_rail, neighbor_r_dir, false, false)
         --Correction for the train stop exception
         if next_entity_label == "train stop" and next_is_forward == false then
            next_entity, next_entity_label, result_extra, next_is_forward =
               mod.identify_rail_segment_end_object(current_rail, neighbor_r_dir, true, false)
         end
         iteration_count = iteration_count + 1
      end
   end

   return next_entity, next_entity_label, result_extra, next_is_forward, iteration_count
end

--Takes all the output from the get_next_rail_entity_ahead and adds extra info before reading them out. Does NOT detect trains.
function mod.rail_read_next_rail_entity_ahead(pindex, rail, is_forward)
   local message = "Up this rail, "
   local origin_rail = rail
   ---@type defines.rail_direction
   local dir_ahead = defines.rail_direction.front
   if not is_forward then
      dir_ahead = defines.rail_direction.back
      message = "Down this rail, "
   end
   local next_entity, next_entity_label, result_extra, next_is_forward, iteration_count =
      mod.get_next_rail_entity_ahead(origin_rail, dir_ahead, false)
   if next_entity == nil then
      printout("Analysis error. This rail might be looping.", pindex)
      return
   end
   local distance = math.floor(util.distance(origin_rail.position, next_entity.position))

   --Test message
   --message = message .. iteration_count .. " iterations, "

   --Maybe check for trains here, but there is no point because the checks use signal blocks...
   --local trains_in_origin_block = origin_rail.trains_in_block
   --local trains_in_current_block = current_rail.trains_in_block

   --Report opposite direction entities.
   if
      next_is_forward == false
      and (
         next_entity_label == "train stop"
         or next_entity_label == "rail signal"
         or next_entity_label == "chain signal"
      )
   then
      message = message .. " Opposite direction's "
   end

   --Add more info depending on entity label
   if next_entity_label == "end rail" then
      message = message .. next_entity_label
   elseif next_entity_label == "fork split" then
      local entering_segment_rail = result_extra
      message = message .. "rail fork splitting "
      message = message .. mod.list_rail_fork_directions(next_entity)
   elseif next_entity_label == "fork merge" then
      local entering_segment_rail = result_extra
      message = message .. "rail fork merging "
   elseif next_entity_label == "neighbor end" then
      local entering_segment_rail = result_extra
      message = message .. "end rail "
   elseif next_entity_label == "rail signal" then
      message = message .. "rail signal with state " .. mod.get_signal_state_info(next_entity) .. " "
   elseif next_entity_label == "chain signal" then
      message = message .. "chain signal with state " .. mod.get_signal_state_info(next_entity) .. " "
   elseif next_entity_label == "train stop" then
      local stop_name = next_entity.backer_name
      --Add more specific distance info
      if math.abs(distance) > 25 or next_is_forward == false then
         message = message .. "Train stop " .. stop_name .. ", in " .. distance .. " meters, "
      else
         distance = util.distance(origin_rail.position, next_entity.position) - 2.5
         if math.abs(distance) <= 0.2 then
            message = " Aligned with train stop " .. stop_name
         elseif distance > 0.2 then
            message = math.floor(distance * 10) / 10 .. " meters away from train stop " .. stop_name .. ". "
         elseif distance < 0.2 then
            message = math.floor(-distance * 10) / 10 .. " meters past train stop " .. stop_name .. ". "
         end
      end
   elseif next_entity_label == "other rail" then
      message = message .. "unspecified entity"
   elseif next_entity_label == "other entity" then
      message = message .. next_entity.name
   end

   --Add general distance info
   if next_entity_label ~= "train stop" then
      message = message .. " in " .. distance .. " meters, "
      if next_entity_label == "end rail" then
         message = message .. " facing " .. FaUtils.direction_lookup(result_extra)
      end
   end
   printout(message, pindex)
   --Draw circles for visual debugging
   rendering.draw_circle({
      color = { 0, 1, 0 },
      radius = 1,
      width = 10,
      target = next_entity,
      surface = next_entity.surface,
      time_to_live = 100,
   })
end

--WIP #92. laterdo here: Rail analyzer menu where you will use arrow keys to go forward/back and left/right along a rail. A little like the structure travel feature.
function mod.run_rail_analyzer_menu(pindex, origin_rail, is_called_from_train)
   return
end

--Counts rails within range of a selected rail.
function mod.count_rails_within_range(rail, range, pindex)
   --1. Scan around the rail for other rails
   local counter = 0
   local pos = rail.position
   local scan_area = { { pos.x - range, pos.y - range }, { pos.x + range, pos.y + range } }
   local ents = game.get_player(pindex).surface.find_entities_filtered({ area = scan_area, name = "straight-rail" })
   for i, other_rail in ipairs(ents) do
      --2. Increase counter for each straight rail
      counter = counter + 1
   end
   --ents = game.get_player(pindex).surface.find_entities_filtered({ area = scan_area, name = "curved-rail" })
   ents = {}
   for i, other_rail in ipairs(ents) do
      --3. Increase counter for each curved rail
      counter = counter + 1
   end
   --Draw the range for visual debugging
   rendering.draw_circle({
      color = { 0, 1, 0 },
      radius = range,
      width = range,
      target = rail,
      surface = rail.surface,
      time_to_live = 100,
   })
   return counter
end

--Checks if the rail is parallel to another neighboring segment.
function mod.has_parallel_neighbor(rail, pindex)
   --1. Scan around the rail for other rails
   local pos = rail.position
   local dir = rail.direction
   local range = 4
   if dir % 2 == 1 then range = 3 end
   local scan_area = { { pos.x - range, pos.y - range }, { pos.x + range, pos.y + range } }
   local ents = game.get_player(pindex).surface.find_entities_filtered({ area = scan_area, name = "straight-rail" })
   for i, other_rail in ipairs(ents) do
      --2. For each rail, does it have the same rotation but a different segment? If yes return true.
      local pos2 = other_rail.position
      if rail.direction == other_rail.direction and not rail.is_rail_in_same_rail_segment_as(other_rail) then
         --3. Also ignore cases where the rails are directly facing each other so that they can be connected
         if (pos.x ~= pos2.x) and (pos.y ~= pos2.y) and (math.abs(pos.x - pos2.x) - math.abs(pos.y - pos2.y)) > 1 then
            --4. Parallel neighbor found
            rendering.draw_circle({
               color = { 1, 0, 0 },
               radius = range,
               width = range,
               target = pos,
               surface = rail.surface,
               time_to_live = 100,
            })
            return true
         end
      end
   end
   --4. No parallel neighbor found
   return false
end

--Checks if the rail is amid an intersection.
function mod.is_intersection_rail(rail, pindex)
   --1. Scan around the rail for other rails
   local pos = rail.position
   local dir = rail.direction
   local scan_area = { { pos.x - 1, pos.y - 1 }, { pos.x + 1, pos.y + 1 } }
   local ents = game.get_player(pindex).surface.find_entities_filtered({ area = scan_area, name = "straight-rail" })
   for i, other_rail in ipairs(ents) do
      --2. For each rail, does it have a different rotation and a different segment? If yes return true.
      local dir_2 = other_rail.direction
      dir = dir % dirs.south --N/S or E/W does not matter
      dir_2 = dir_2 % dirs.south --N/S or E/W does not matter
      if dir ~= dir_2 and not rail.is_rail_in_same_rail_segment_as(other_rail) then
         rendering.draw_circle({
            color = { 0, 0, 1 },
            radius = 1.5,
            width = 1.5,
            target = pos,
            surface = rail.surface,
            time_to_live = 100,
         })
         return true
      end
   end
   return false
end

function mod.find_nearest_intersection(rail, pindex, radius_in)
   --1. Scan around the rail for other rails
   local radius = radius_in or 1000
   local pos = rail.position
   local scan_area = { { pos.x - radius, pos.y - radius }, { pos.x + radius, pos.y + radius } }

   local ents = {}
   --      .get_player(pindex).surface
   --      .find_entities_filtered({ area = scan_area, name = { "straight-rail", "curved-rail" } })
   local nearest = nil
   local min_dist = radius
   for i, other_rail in ipairs(ents) do
      --2. For each rail, is it an intersection rail?
      if other_rail.valid and mod.is_intersection_rail(other_rail, pindex) then
         local dist = math.ceil(util.distance(pos, other_rail.position))
         --Set as nearest if valid
         if dist < min_dist then
            min_dist = dist
            nearest = other_rail
         end
      end
   end
   --Return the nearest found, possibly nil
   if nearest == nil then
      return nil, radius --Nothing within radius tiles!
   end
   rendering.draw_circle({
      color = { 0, 0, 1 },
      radius = 2,
      width = 2,
      target = nearest.position,
      surface = nearest.surface,
      time_to_live = 60,
   })
   return nearest, min_dist
end

--Mines for the player the rail signals around a rail.
function mod.mine_signals(rail, pindex)
   local chains =
      rail.surface.find_entities_filtered({ position = rail.position, radius = 2, name = "rail-chain-signal" })
   for i, chain in ipairs(chains) do
      game.get_player(pindex).mine_entity(chain, true)
   end
   local signals = rail.surface.find_entities_filtered({ position = rail.position, radius = 2, name = "rail-signal" })
   for i, signal in ipairs(signals) do
      game.get_player(pindex).mine_entity(signal, true)
   end
end

--Plays a train track alert sound for every player standing on or facing train tracks that meet the condition.
function mod.check_and_play_train_track_alert_sounds(step)
   for pindex, player in pairs(players) do
      --Check if the player is standing on a rail
      local p = game.get_player(pindex)
      local floor_ents = {}
      --p.surface.find_entities_filtered({ position = p.position, name = { "straight-rail", "curved-rail" } })
      local nearby_ents = {}
      --p.surface.find_entities_filtered({ position = p.position, radius = 4, name = { "curved-rail" } })
      local found_rail = nil
      if #floor_ents > 0 then
         found_rail = floor_ents[1]
      elseif #nearby_ents > 0 then
         found_rail = nearby_ents[1]
      else
         --The player is not on rails.
         return
      end

      --Cancel if the player is in a spidertron or train
      local v = p.vehicle
      if v ~= nil and v.valid and (v.type == "spider-vehicle" or v.train ~= nil) then return end

      --Condition for step 1: Any moving trains nearby (within 400 tiles)
      if step == 1 then
         local trains = p.surface.get_trains()
         for i, train in ipairs(trains) do
            if
               train.speed ~= 0
               and (
                  util.distance(p.position, train.front_stock.position) < 400
                  or util.distance(p.position, train.back_stock.position) < 400
               )
            then
               p.play_sound({ path = "train-alert-low" })
               rendering.draw_circle({
                  color = { 1, 1, 0 },
                  radius = 2,
                  width = 2,
                  target = found_rail.position,
                  surface = found_rail.surface,
                  time_to_live = 15,
               })
            end
         end
      --Condition for step 2: Any moving trains nearby (within 200 tiles), and heading towards the player
      elseif step == 2 then
         local trains = p.surface.get_trains()
         for i, train in ipairs(trains) do
            if
               train.speed ~= 0
               and (util.distance(p.position, train.front_stock.position) < 200 or util.distance(
                  p.position,
                  train.back_stock.position
               ) < 200)
               and (
                  (
                     train.speed > 0
                     and util.distance(p.position, train.front_stock.position)
                        <= util.distance(p.position, train.back_stock.position)
                  )
                  or (
                     train.speed < 0
                     and util.distance(p.position, train.front_stock.position)
                        >= util.distance(p.position, train.back_stock.position)
                  )
               )
            then
               p.play_sound({ path = "train-alert-low" })
               rendering.draw_circle({
                  color = { 1, 0.5, 0 },
                  radius = 3,
                  width = 4,
                  target = found_rail.position,
                  surface = found_rail.surface,
                  time_to_live = 15,
               })
            end
         end
      --Condition for step 3: Any moving trains in the same rail block, and heading towards the player OR if the block inbound signals are yellow. More urgent sound if also within 200 distance of the player
      elseif step == 3 then
         local trains = p.surface.get_trains()
         for i, train in ipairs(trains) do
            if
               train.speed ~= 0
               and (found_rail.is_rail_in_same_rail_block_as(train.front_rail) or found_rail.is_rail_in_same_rail_block_as(
                  train.back_rail
               ))
               and (
                  (
                     train.speed > 0
                     and util.distance(p.position, train.front_stock.position)
                        <= util.distance(p.position, train.back_stock.position)
                  )
                  or (
                     train.speed < 0
                     and util.distance(p.position, train.front_stock.position)
                        >= util.distance(p.position, train.back_stock.position)
                  )
               )
            then
               if
                  util.distance(p.position, train.front_stock.position) < 200
                  or util.distance(p.position, train.back_stock.position) < 200
               then
                  p.play_sound({ path = "train-alert-high" })
                  rendering.draw_circle({
                     color = { 1, 0.0, 0 },
                     radius = 4,
                     width = 8,
                     target = found_rail.position,
                     surface = found_rail.surface,
                     time_to_live = 15,
                  })
               else
                  p.play_sound({ path = "train-alert-low" })
                  rendering.draw_circle({
                     color = { 1, 0.4, 0 },
                     radius = 4,
                     width = 8,
                     target = found_rail.position,
                     surface = found_rail.surface,
                     time_to_live = 15,
                  })
               end
            end
         end
         local signals = found_rail.get_inbound_signals()
         for i, signal in ipairs(signals) do
            if signal.signal_state == defines.signal_state.reserved then
               for i, train in ipairs(trains) do
                  if
                     util.distance(p.position, train.front_stock.position) < 200
                     or util.distance(p.position, train.back_stock.position) < 200
                  then
                     p.play_sound({ path = "train-alert-high" })
                     rendering.draw_circle({
                        color = { 1, 0.0, 0 },
                        radius = 4,
                        width = 8,
                        target = found_rail.position,
                        surface = found_rail.surface,
                        time_to_live = 15,
                     })
                  else
                     p.play_sound({ path = "train-alert-low" })
                     rendering.draw_circle({
                        color = { 1, 0.4, 0 },
                        radius = 4,
                        width = 8,
                        target = found_rail.position,
                        surface = found_rail.surface,
                        time_to_live = 15,
                     })
                  end
               end
            end
         end
      end
   end
end

return mod
