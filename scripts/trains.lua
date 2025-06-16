--Here: Functions relating to train topics such as train info, instant train scheduling
--Does not include event handlers, train stops, rails

local util = require("util")
local FaUtils = require("scripts.fa-utils")
local Rails = require("scripts.rails")
local Graphics = require("scripts.graphics")
local UiRouter = require("scripts.ui.router")

local dirs = defines.direction

local mod = {}

--Look up and translate the train state.
function mod.get_train_state_info(train)
   local train_state_id = train.state
   local train_state_text = ""
   local state_lookup = FaUtils.into_lookup(defines.train_state)
   if train_state_id ~= nil then
      train_state_text = state_lookup[train_state_id]
   else
      train_state_text = "None"
   end

   --Explanations
   if train_state_text == "wait_station" then
      train_state_text = "waiting at a station"
   elseif train_state_text == "wait_signal" then
      train_state_text = "waiting at a closed rail signal"
   elseif train_state_text == "on_the_path" then
      train_state_text = "traveling"
   end
   return train_state_text
end

--Gets a train's name. The idea is that every locomotive on a train has the same backer name and this is the train's name. If there are multiple names, a warning returned.
function mod.get_train_name(train)
   local locos = train.locomotives
   local train_name = ""
   local multiple_names = false

   if locos == nil then return "without locomotives" end

   for i, loco in ipairs(locos["front_movers"]) do
      if train_name ~= "" and train_name ~= loco.backer_name then multiple_names = true end
      train_name = loco.backer_name
   end
   for i, loco in ipairs(locos["back_movers"]) do
      if train_name ~= "" and train_name ~= loco.backer_name then multiple_names = true end
      train_name = loco.backer_name
   end

   if train_name == "" then
      return "without a name"
   elseif multiple_names then
      local oldest_name = mod.resolve_train_name(train)
      mod.set_train_name(train, oldest_name)
      return oldest_name
   else
      return train_name
   end
end

--Sets a train's name. The idea is that every locomotive on a train has the same backer name and this is the train's name.
function mod.set_train_name(train, new_name)
   if new_name == nil or new_name == "" then return false end
   local locos = train.locomotives
   if locos == nil then return false end
   for i, loco in ipairs(locos["front_movers"]) do
      loco.backer_name = new_name
   end
   for i, loco in ipairs(locos["back_movers"]) do
      loco.backer_name = new_name
   end
   return true
end

--Finds the oldest locomotive and applies its name across the train. Any new loco will be newwer and so the older names will be kept.
function mod.resolve_train_name(train)
   local locos = train.locomotives
   local oldest_loco = nil

   if locos == nil then return "without locomotives" end

   for i, loco in ipairs(locos["front_movers"]) do
      if oldest_loco == nil then
         oldest_loco = loco
      elseif oldest_loco.unit_number > loco.unit_number then
         oldest_loco = loco
      end
   end
   for i, loco in ipairs(locos["back_movers"]) do
      if oldest_loco == nil then
         oldest_loco = loco
      elseif oldest_loco.unit_number > loco.unit_number then
         oldest_loco = loco
      end
   end

   if oldest_loco ~= nil then
      return oldest_loco.backer_name
   else
      return "error resolving train name"
   end
end

--Checks if the train is all in one segment, which means the front and back rails are in the same segment.
function mod.train_is_all_in_one_segment(train)
   return train.front_rail.is_rail_in_same_rail_segment_as(train.back_rail)
end

--[[ 
 Returns the leading rail and the direction on it that is "ahead" and the leading stock. This is the direction that the currently boarded locomotive or wagon is facing.
 * Checks whether the current locomotive is one of the front or back locomotives and gives leading rail and leading stock accordingly.
 * If this is not a locomotive, takes the front as the leading side.
 * Checks distances with respect to the front/back stocks of the train
 * Does not require any specific position or rotation for any of the stock.
 * For the leading rail, the connected rail that is farthest from the leading stock is in the "ahead" direction.

--]]
function mod.get_relative_leading_rail_and_train_dir(pindex, train)
   local leading_rail = nil
   local trailing_rail = nil
   local leading_stock = nil
   local ahead_rail_dir = nil

   local vehicle = game.get_player(pindex).vehicle
   local front_rail = train.front_rail
   local back_rail = train.back_rail
   local locos = train.locomotives
   local vehicle_is_a_front_loco = nil

   --Find the leading rail. If any "front" locomotive velocity is positive, the front stock is the one going ahead and its rail is the leading rail.
   if vehicle.name == "locomotive" then
      --Leading direction is the one this loconotive faces
      for i, loco in ipairs(locos["front_movers"]) do
         if vehicle.unit_number == loco.unit_number then vehicle_is_a_front_loco = true end
      end
      if vehicle_is_a_front_loco == true then
         leading_rail = front_rail
         trailing_rail = back_rail
         leading_stock = train.front_stock
      else
         for i, loco in ipairs(locos["back_movers"]) do
            if vehicle.unit_number == loco.unit_number then vehicle_is_a_front_loco = false end
         end
         if vehicle_is_a_front_loco == false then
            leading_rail = back_rail
            trailing_rail = front_rail
            leading_stock = train.back_stock
         else
            --Unexpected place
            return nil, -1, nil
         end
      end
   else
      --Just assume the front stock is leading
      leading_rail = front_rail
      trailing_rail = back_rail
      leading_stock = train.front_stock
   end

   --Error check
   if leading_rail == nil then return nil, -2, nil end

   --Find the ahead direction. For the leading rail, the connected rail that is farthest from the leading stock is in the "ahead" direction.
   --Repurpose the variables named front_rail and back_rail
   front_rail = leading_rail.get_connected_rail({
      rail_direction = defines.rail_direction.front,
      rail_connection_direction = defines.rail_connection_direction.straight,
   })
   if front_rail == nil then
      front_rail = leading_rail.get_connected_rail({
         rail_direction = defines.rail_direction.front,
         rail_connection_direction = defines.rail_connection_direction.left,
      })
   end
   if front_rail == nil then
      front_rail = leading_rail.get_connected_rail({
         rail_direction = defines.rail_direction.front,
         rail_connection_direction = defines.rail_connection_direction.right,
      })
   end
   if front_rail == nil then
      --The leading rail is an end rail at the front direction
      return leading_rail, defines.rail_direction.front, leading_stock
   end

   back_rail = leading_rail.get_connected_rail({
      rail_direction = defines.rail_direction.back,
      rail_connection_direction = defines.rail_connection_direction.straight,
   })
   if back_rail == nil then
      back_rail = leading_rail.get_connected_rail({
         rail_direction = defines.rail_direction.back,
         rail_connection_direction = defines.rail_connection_direction.left,
      })
   end
   if back_rail == nil then
      back_rail = leading_rail.get_connected_rail({
         rail_direction = defines.rail_direction.back,
         rail_connection_direction = defines.rail_connection_direction.right,
      })
   end
   if back_rail == nil then
      --The leading rail is an end rail at the back direction
      return leading_rail, defines.rail_direction.back, leading_stock
   end

   local front_dist = math.abs(util.distance(leading_stock.position, front_rail.position))
   local back_dist = math.abs(util.distance(leading_stock.position, back_rail.position))
   --The connected rail that is farther from the leading stock is in the ahead direction.
   if front_dist > back_dist then
      return leading_rail, defines.rail_direction.front, leading_stock
   else
      return leading_rail, defines.rail_direction.back, leading_stock
   end
end
--[[ALT:To find the leading rail, checks the velocity sign of any "front-facing" locomotive. 
   --f any "front" locomotive velocity is positive, the front stock is the one going ahead and its rail is the leading rail. 
   --if front_facing_loco.speed >= 0 then
   --   leading_rail = front_rail
   --   leading_stock = train.front_stock 
   --else
   --   leading_rail = back_rail
   --   leading_stock = train.back_stock
   --end
--]]

--Takes all the output from the get_next_rail_entity_ahead and adds extra info before reading them out. Does NOT detect trains.
function mod.train_read_next_rail_entity_ahead(pindex, invert, mute_in)
   local message = "Ahead, "
   local honk_score = 0
   local train = game.get_player(pindex).vehicle.train
   local leading_rail, dir_ahead, leading_stock = mod.get_relative_leading_rail_and_train_dir(pindex, train)
   if invert then
      dir_ahead = Rails.get_opposite_rail_direction(dir_ahead)
      message = "Behind, "
   end
   --Correction for trains: Flip the correct direction ahead for mismatching diagonal rails
   if
      leading_rail.name == "straight-rail"
      and (leading_rail.direction == dirs.southwest or leading_rail.direction == dirs.northwest)
   then
      dir_ahead = Rails.get_opposite_rail_direction(dir_ahead)
   end
   --Correction for trains: Curved rails report different directions based on where the train sits and so are unreliable.
   if leading_rail.name == "curved-rail" then
      if mute_in == true then return -1 end
      printout("Curved rail analysis error, check from another rail.", pindex)
      return -1
   end
   local next_entity, next_entity_label, result_extra, next_is_forward, iteration_count =
      Rails.get_next_rail_entity_ahead(leading_rail, dir_ahead, false)
   if next_entity == nil then
      if mute_in == true then return -1 end
      printout("Analysis error, this rail might be looping.", pindex)
      return -1
   end
   local distance = math.floor(util.distance(leading_stock.position, next_entity.position))
   if distance < 10 then honk_score = honk_score + 1 end

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
      honk_score = -100
   end

   --Add more info depending on entity label
   if next_entity_label == "end rail" then
      message = message .. next_entity_label
   elseif next_entity_label == "fork split" then
      local entering_segment_rail = result_extra
      message = message .. "rail fork splitting "
      message = message .. Rails.list_rail_fork_directions(next_entity)
   elseif next_entity_label == "fork merge" then
      local entering_segment_rail = result_extra
      message = message .. "rail fork merging "
   elseif next_entity_label == "neighbor end" then
      local entering_segment_rail = result_extra
      message = message .. "end rail "
   elseif next_entity_label == "rail signal" then
      local signal_state = Rails.get_signal_state_info(next_entity)
      message = message .. "rail signal with state " .. signal_state .. " "
      if signal_state == "closed" then honk_score = honk_score + 1 end
   elseif next_entity_label == "chain signal" then
      local signal_state = Rails.get_signal_state_info(next_entity)
      message = message .. "chain signal with state " .. signal_state .. " "
      if signal_state == "closed" then honk_score = honk_score + 1 end
   elseif next_entity_label == "train stop" then
      local stop_name = next_entity.backer_name
      --Add more specific distance info
      if math.abs(distance) > 25 or next_is_forward == false then
         message = message .. "Train stop " .. stop_name .. ", in " .. distance .. " meters. "
      else
         distance = util.distance(leading_stock.position, next_entity.position) - 3.6
         if math.abs(distance) <= 0.2 then
            message = " Aligned with train stop " .. stop_name
         elseif distance > 0.2 then
            message = math.floor(distance * 10) / 10
               .. " meters away from train stop "
               .. stop_name
               .. ", for the frontmost vehicle. "
         elseif distance < 0.2 then
            message = math.floor(-distance * 10) / 10
               .. " meters past train stop "
               .. stop_name
               .. ", for the frontmost vehicle. "
         end
      end
   elseif next_entity_label == "other rail" then
      message = message .. "unspecified entity"
   elseif next_entity_label == "other entity" then
      message = message .. next_entity.name
   end

   --Add general distance info
   if next_entity_label ~= "train stop" then
      message = message .. " in " .. distance .. " meters. "
      if next_entity_label == "end rail" then
         message = message .. " facing " .. FaUtils.direction_lookup(result_extra)
      end
   end
   --If a train stop is close behind, read that instead
   if leading_stock.name == "locomotive" and next_entity_label ~= "train stop" then
      local heading = FaUtils.get_heading_info(leading_stock)
      local pos = leading_stock.position
      local scan_area = nil
      local passed_stop = nil
      local first_reset = false
      --Scan behind the leading stock for 15m for passed train stops
      if heading == "North" then --scan the south
         scan_area = { { pos.x - 4, pos.y - 4 }, { pos.x + 4, pos.y + 15 } }
      elseif heading == "South" then
         scan_area = { { pos.x - 4, pos.y - 15 }, { pos.x + 4, pos.y + 4 } }
      elseif heading == "East" then --scan the west
         scan_area = { { pos.x - 15, pos.y - 4 }, { pos.x + 4, pos.y + 4 } }
      elseif heading == "West" then
         scan_area = { { pos.x - 4, pos.y - 4 }, { pos.x + 15, pos.y + 4 } }
      else
         --message = " Rail object scan error " .. heading .. " "
         scan_area = { { pos.x + 4, pos.y + 4 }, { pos.x + 4, pos.y + 4 } }
      end
      local ents = game.get_player(pindex).surface.find_entities_filtered({ area = scan_area, name = "train-stop" })
      for i, passed_stop in ipairs(ents) do
         distance = util.distance(leading_stock.position, passed_stop.position) - 0
         --message = message .. " found stop "
         if
            distance < 12.5
            and FaUtils.direction_lookup(passed_stop.direction) == FaUtils.get_heading_info(leading_stock)
         then
            if not first_reset then
               message = ""
               first_reset = true
            end
            message = message
               .. math.floor(distance + 0.5)
               .. " meters past train stop "
               .. passed_stop.backer_name
               .. ", "
         end
      end
      if first_reset then message = message .. " for the front vehicle. " end
   end
   if not mute_in == true then
      printout(message, pindex)
      --Draw circle for visual confirmation or debugging of the next entity
      rendering.draw_circle({
         color = { 0, 0.5, 1 },
         radius = 1,
         width = 8,
         target = next_entity,
         surface = next_entity.surface,
         time_to_live = 100,
      })
   end

   if honk_score > 1 then
      --Draw circle for visual confirmation or debugging of the next entity
      rendering.draw_circle({
         color = { 1, 0, 0 },
         radius = 1,
         width = 4,
         target = next_entity,
         surface = next_entity.surface,
         time_to_live = 60,
      })
   end
   return honk_score
end

--[[ Train menu options summary
   0. name, id, menu instructions
   1. Train state , destination info. Click to toggle manual mode.
   2. Click to rename
   3. Vehicles info
   4. Cargo info
   5. Read schedule
   6. Set instant schedule + wait time info
   7. Clear schedule
   8. Subautomatic travel

   This menu opens when the player presses LEFT BRACKET on a locomotive that they are either riding or looking at with the cursor.
]]
function mod.run_train_menu(menu_index, pindex, clicked, other_input)
   local index = menu_index
   local other = other_input or -1
   local locomotive = nil
   local ent = game.get_player(pindex).selected
   if game.get_player(pindex).vehicle ~= nil and game.get_player(pindex).vehicle.name == "locomotive" then
      locomotive = game.get_player(pindex).vehicle
      players[pindex].train_menu.locomotive = locomotive
   elseif ent ~= nil and ent.valid and ent.name == "locomotive" then
      locomotive = ent
      players[pindex].train_menu.locomotive = locomotive
   else
      players[pindex].train_menu.locomotive = nil
      printout("Train menu requires a locomotive", pindex)
      return
   end
   local train = locomotive.train

   if index == 0 then
      --Give basic info about this train, such as its name and ID. Instructions.
      printout(
         "Train "
            .. mod.get_train_name(train)
            .. ", with ID "
            .. train.id
            .. ", Press UP ARROW and DOWN ARROW to navigate options, press LEFT BRACKET to select an option or press E to exit this menu.",
         pindex
      )
   elseif index == 1 then
      --Get train state and toggle manual control
      if not clicked then
         local result = "Train state, " .. mod.get_train_state_info(train)
         if train.path_end_stop ~= nil then
            result = result .. ", going to station " .. train.path_end_stop.backer_name
         end
         result = result .. ", press LEFT BRACKET to toggle manual control "
         printout(result, pindex)
      else
         train.manual_mode = not train.manual_mode
         if train.manual_mode then
            printout("Manual mode enabled, press LEFT BRACKET to toggle,", pindex)
         else
            printout("Automatic mode enabled, press LEFT BRACKET to toggle,", pindex)
         end
      end
   elseif index == 2 then
      --Rename this train
      if not clicked then
         printout("Rename this train, press LEFT BRACKET.", pindex)
      else
         if train.locomotives == nil then
            printout("The train must have locomotives for it to be named.", pindex)
            return
         end
         printout("Enter a new name for this train, then press 'ENTER' to confirm, or press 'ESC' to cancel.", pindex)
         players[pindex].train_menu.renaming = true
         local frame = Graphics.create_text_field_frame(pindex, "train-rename")
         game.get_player(pindex).opened = frame
      end
   elseif index == 3 then
      --Train vehicles info
      local locos = train.locomotives
      printout(
         "Vehicle counts, "
            .. #locos["front_movers"]
            .. " locomotives facing front, "
            .. #locos["back_movers"]
            .. " locomotives facing back, "
            .. #train.cargo_wagons
            .. " cargo wagons, "
            .. #train.fluid_wagons
            .. " fluid wagons, ",
         pindex
      )
   elseif index == 4 then
      --Train cargo info
      local click_count = players[pindex].menu_click_count
      if clicked then
         click_count = click_count + 1
      else
         click_count = 1
      end
      players[pindex].menu_click_count = click_count
      local result = { "" }
      if click_count == 1 then table.insert(result, "Cargo, ") end
      table.insert(result, mod.train_top_contents_info(train, click_count))
      printout(result, pindex)
   elseif index == 5 then
      --Train schedule info
      local result = ""
      local namelist = ""
      local schedule = train.schedule
      local records = {}
      if schedule ~= nil then records = schedule.records end
      if schedule == nil or records == nil or #records == 0 then
         result = " No schedule, "
      else
         for i, record in ipairs(records) do
            if record.station ~= nil then
               if record.temporary == false or record.temporary == nil then
                  namelist = namelist .. ", station " .. record.station
               else
                  namelist = namelist .. ", temporary station " .. record.station
               end
               if record.wait_conditions ~= nil then
                  local wait_cond_1 = record.wait_conditions[1]
                  if wait_cond_1 ~= nil then
                     local cond = wait_cond_1.type
                     namelist = namelist .. ", waiting for " .. cond
                     if cond == "time" or cond == "inactivity" then
                        namelist = namelist .. " " .. math.ceil(wait_cond_1.ticks / 60) .. " seconds "
                     end
                  end
                  local wait_cond_2 = record.wait_conditions[2]
                  if wait_cond_2 ~= nil then
                     local cond = wait_cond_2.type
                     namelist = namelist .. ", and waiting for " .. cond
                     if cond == "time" or cond == "inactivity" then
                        namelist = namelist .. " " .. math.ceil(wait_cond_2.ticks / 60) .. " seconds "
                     end
                  end
               end
               namelist = namelist .. ", "
            end
         end
         if namelist == "" then namelist = " is empty" end
         result = " Train schedule" .. namelist
      end
      printout(result, pindex)
   elseif index == 6 then
      --Set instant schedule
      if players[pindex].train_menu.wait_time == nil then players[pindex].train_menu.wait_time = 300 end
      if not clicked then
         printout(
            " Set a new instant schedule for the train here by pressing LEFT BRACKET, where the train waits for a set amount of time at immediately reachable station, modify this time with PAGE UP or PAGE DOWN before settting the schedule and hold CONTROL to increase the step size",
            pindex
         )
      else
         local comment = mod.instant_schedule(train, players[pindex].train_menu.wait_time)
         printout(comment, pindex)
      end
   elseif index == 7 then
      --Clear schedule
      if not clicked then
         printout("Clear the schedule here by pressing LEFT BRACKET ", pindex)
      else
         train.schedule = nil
         train.manual_mode = true
         printout("Train schedule cleared.", pindex)
      end
   elseif index == 8 then
      if not players[pindex].train_menu.selecting_station then
         --Subautomatic travel to a selected train stop
         if not clicked then
            printout(
               "Single-time travel to a reachable train stop, press LEFT BRACKET to select one, the train waits there until all passengers get off, then it resumes its original schedule.",
               pindex
            )
         else
            local comment = "Select a station with LEFT and RIGHT arrow keys and confirm with LEFT BRACKET."
            printout(comment, pindex)
            players[pindex].train_menu.selecting_station = true
            mod.refresh_valid_train_stop_list(train, pindex)
            train.manual_mode = true
         end
      else
         train.manual_mode = true
         if not clicked then
            --Read the list item
            mod.read_valid_train_stop_from_list(pindex)
         else
            --Go to the list item
            mod.go_to_valid_train_stop_from_list(pindex, train)
            players[pindex].train_menu.selecting_station = false
         end
      end
   end
end
TRAIN_MENU_LENGTH = 8

--Loads and opens the train menu
function mod.menu_open(pindex)
   local router = UiRouter.get_router(pindex)

   if players[pindex].vanilla_mode then return end
   router:open_ui(UiRouter.UI_NAMES.TRAIN)
   players[pindex].move_queue = {}

   --Set the menu line counter to 0
   players[pindex].train_menu.index = 0

   --Play sound
   game.get_player(pindex).play_sound({ path = "Open-Inventory-Sound" })

   --Load menu
   mod.run_train_menu(players[pindex].train_menu.index, pindex, false)
end

--Resets and closes the train menu
function mod.menu_close(pindex, mute_in)
   local router = UiRouter.get_router(pindex)

   local mute = mute_in

   router:close_ui()

   --Set the menu line counter to 0
   players[pindex].train_menu.index = 0
   players[pindex].train_menu.index_2 = 0
   players[pindex].train_menu.selecting_station = false

   --play sound
   if not mute then game.get_player(pindex).play_sound({ path = "Close-Inventory-Sound" }) end

   --Destroy GUI
   if game.get_player(pindex).gui.screen["train-rename"] ~= nil then
      game.get_player(pindex).gui.screen["train-rename"].destroy()
   end
   if game.get_player(pindex).opened ~= nil then game.get_player(pindex).opened = nil end
end

function mod.menu_up(pindex)
   players[pindex].train_menu.index = players[pindex].train_menu.index - 1
   if players[pindex].train_menu.index < 0 then
      players[pindex].train_menu.index = 0
      game.get_player(pindex).play_sound({ path = "inventory-edge" })
   else
      game.get_player(pindex).play_sound({ path = "Inventory-Move" })
   end
   players[pindex].menu_click_count = 0
   --Load menu
   mod.run_train_menu(players[pindex].train_menu.index, pindex, false)
end

function mod.menu_down(pindex)
   players[pindex].train_menu.index = players[pindex].train_menu.index + 1
   if players[pindex].train_menu.index > TRAIN_MENU_LENGTH then
      players[pindex].train_menu.index = TRAIN_MENU_LENGTH
      game.get_player(pindex).play_sound({ path = "inventory-edge" })
   else
      game.get_player(pindex).play_sound({ path = "Inventory-Move" })
   end
   players[pindex].menu_click_count = 0
   --Load menu
   mod.run_train_menu(players[pindex].train_menu.index, pindex, false)
end

function mod.menu_left(pindex)
   local index = players[pindex].train_menu.index_2
   if index == nil then
      index = 1
   else
      index = index - 1
   end
   if index == 0 then
      index = 1
      game.get_player(pindex).play_sound({ path = "Inventory-Move" })
   end
   players[pindex].train_menu.index_2 = index
   --Load menu
   mod.run_train_menu(players[pindex].train_menu.index, pindex, false)
end

function mod.menu_right(pindex)
   local index = players[pindex].train_menu.index_2
   if index == nil then
      index = 1
   else
      index = index + 1
   end
   if index > #players[pindex].valid_train_stop_list then
      index = #players[pindex].valid_train_stop_list
      game.get_player(pindex).play_sound({ path = "Inventory-Move" })
   end
   players[pindex].train_menu.index_2 = index
   --Load menu
   mod.run_train_menu(players[pindex].train_menu.index, pindex, false)
end

--Returns most common items in a cargo wagon.
function mod.cargo_wagon_top_contents_info(wagon)
   local result = ""
   local itemset = wagon.get_inventory(defines.inventory.cargo_wagon).get_contents()
   local itemtable = {}
   for name, count in pairs(itemset) do
      table.insert(itemtable, { name = name, count = count })
   end
   table.sort(itemtable, function(k1, k2)
      return k1.count > k2.count
   end)
   if #itemtable == 0 then
      result = result .. " Contains no items. "
   else
      result = result .. " Contains " .. itemtable[1].name .. " times " .. itemtable[1].count .. ", "
      if #itemtable > 1 then result = result .. itemtable[2].name .. " times " .. itemtable[2].count .. ", " end
      if #itemtable > 2 then result = result .. itemtable[3].name .. " times " .. itemtable[3].count .. ", " end
      if #itemtable > 3 then result = result .. itemtable[4].name .. " times " .. itemtable[4].count .. ", " end
      if #itemtable > 4 then result = result .. itemtable[5].name .. " times " .. itemtable[5].count .. ", " end
      if #itemtable > 5 then result = result .. " and other items, " end
   end
   result = result .. " open the wagon menu to browse the full inventory. "
   return result
end

--Returns most common items in a fluid wagon or train.
function mod.fluid_contents_info(wagon)
   local result = ""
   local itemset = wagon.get_fluid_contents()
   local itemtable = {}
   for name, amount in pairs(itemset) do
      table.insert(itemtable, { name = name, amount = amount })
   end
   table.sort(itemtable, function(k1, k2)
      return k1.amount > k2.amount
   end)
   if #itemtable == 0 then
      result = result .. " Contains no fluids. "
   else
      result = result
         .. " Contains "
         .. itemtable[1].name
         .. " times "
         .. string.format(" %.0f ", itemtable[1].amount)
         .. ", "
      if #itemtable > 1 then
         result = result
            .. " and "
            .. itemtable[2].name
            .. " times "
            .. string.format(" %.0f ", itemtable[2].amount)
            .. ", "
      end
      if #itemtable > 2 then
         result = result
            .. " and "
            .. itemtable[3].name
            .. " times "
            .. string.format(" %.0f ", itemtable[3].amount)
            .. ", "
      end
      if #itemtable > 3 then result = result .. " and other fluids " end
   end
   if wagon.object_name ~= "LuaTrain" and wagon.name == "fluid-wagon" then
      result = result .. ", Use pumps to fill and empty this wagon. "
   end
   return result
end

--Returns most common items and fluids in a train (sum of all wagons)
function mod.train_top_contents_info(train, group_no)
   local result = { "" }
   local itemset = train.get_contents()
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
      table.insert(result, " Contains no items, ")
      return result
   else
      local group_start = (group_no - 1) * 5 + 1
      local group_end = group_start + 4
      if #itemtable < group_start then
         table.insert(result, " no other items.")
         return result
      end
      for i = group_start, group_end, 1 do
         if itemtable[i] then
            table.insert(
               result,
               ", " .. itemtable[i].name .. " times " .. FaUtils.simplify_large_number(itemtable[i].count)
            )
         end
      end
      if #itemtable > group_end then
         table.insert(result, ", and other items, " .. #itemtable .. " total, press LEFT BRACKET to list more")
      end
   end
   table.insert(result, ", ")
   table.insert(result, mod.fluid_contents_info(train))
   return result
end

--For the selected train, adds every reachable train stop to its schedule with the waiting condition of 5 minutes.
function mod.instant_schedule(train, seconds_in)
   local seconds = seconds_in or 300
   local surf = train.front_stock.surface
   local train_stops = surf.get_train_stops()
   local valid_stops = 0
   train.schedule = nil
   for i, stop in ipairs(train_stops) do
      --Add the stop to the schedule's first row
      local wait_condition_1 = { type = "time", ticks = seconds * 60, compare_type = "and" }
      local new_record = { wait_conditions = { wait_condition_1 }, station = stop.backer_name, temporary = false }

      local schedule = train.schedule
      if schedule == nil then
         schedule = { current = 1, records = { new_record } }
      --game.get_player(pindex).print("made new schedule")
      else
         local records = schedule.records
         table.insert(records, 1, new_record)
         --game.get_player(pindex).print("added to schedule row 1, schedule length now " .. #records)
      end
      train.schedule = schedule

      --Make the train aim for the stop
      train.go_to_station(1)
      train.recalculate_path()

      --React according to valid path
      if not train.has_path then
         --Clear the invalid schedule record
         --game.get_player(pindex).print("invalid " .. stop.backer_name)
         local schedule = train.schedule
         if schedule ~= nil then
            --game.get_player(pindex).print("Removing " .. stop.backer_name)
            local records = schedule.records
            table.remove(records, 1)
            if records == nil or #records == 0 then
               train.schedule = nil
               train.manual_mode = true
            else
               train.schedule = schedule
            end
            --game.get_player(pindex).print("schedule length now " .. #records)
         end
      else
         --Valid station and path selected.
         valid_stops = valid_stops + 1
         --game.get_player(pindex).print("valid " .. stop.backer_name .. ", path size " .. train.path.size)
      end
   end
   if valid_stops == 0 then
      --Announce error to all passengers
      str =
         " Error: No reachable trainstops detected. Check whether you have locomotives facing both directions as required."
      for i, player in ipairs(train.passengers) do
         players[player.index].last = str
         localised_print({ "", "out ", str })
      end
   elseif valid_stops == 1 then
      --Announce error to all passengers
      str =
         " Error: Only one reachable trainstop detected. Check whether you have locomotives facing both directions as required."
      for i, player in ipairs(train.passengers) do
         players[player.index].last = str
         localised_print({ "", "out ", str })
      end
      train.schedule = nil
   else
      if seconds_in == nil then
         str = "Train schedule created with " .. valid_stops .. " stops, waiting " .. seconds .. " seconds at each. "
      else
         str = seconds .. " seconds waited at each of " .. valid_stops .. " stops. "
      end
      for i, player in ipairs(train.passengers) do
         players[player.index].last = str
         localised_print({ "", "out ", str })
      end
   end
   return str
end

function mod.change_instant_schedule_wait_time(increment, pindex)
   local seconds = players[pindex].train_menu.wait_time
   if seconds == nil then seconds = 300 end
   seconds = seconds + increment
   if seconds < 5 then
      seconds = 5
   elseif seconds > 10000 then
      seconds = 10000
   end
   players[pindex].train_menu.wait_time = seconds
   printout(
      players[pindex].train_menu.wait_time
         .. " seconds waited at each station. Use arrow keys to navigate the train menu and apply the new wait time by re-creating the schedule.",
      pindex
   )
end

--Subautomatic one-time travel to a reachable train stop that is at least 3 rails away. Does not delete the train schedule. Note: Now obsolete?
function mod.sub_automatic_travel_to_other_stop(train)
   local surf = train.front_stock.surface
   local train_stops = surf.get_train_stops()
   local str = ""
   for i, stop in ipairs(train_stops) do
      --Set a stop
      local wait_condition_1 = { type = "passenger_not_present", compare_type = "and" }
      local wait_condition_2 = { type = "time", ticks = 60, compare_type = "and" }
      local new_record = { wait_conditions = nil, station = stop.backer_name, temporary = true }
      --{ wait_conditions = { wait_condition_1, wait_condition_2 }, station = stop.backer_name, temporary = true }

      --train.schedule = {current = 1, records = {new_record}}
      local schedule = train.schedule
      if schedule == nil then
         schedule = { current = 1, records = { new_record } }
      --game.get_player(pindex).print("made new schedule")
      else
         local records = schedule.records
         table.insert(records, 1, new_record)
      end
      train.schedule = schedule

      --Make the train aim for the stop
      train.go_to_station(1)
      if not train.has_path or train.path.size < 3 then
         --Invalid path or path to an station nearby
         local records = schedule.records
         table.remove(records, 1)
         if records == nil or #records == 0 then
            train.schedule = nil
            train.manual_mode = true
         else
            train.schedule = schedule
         end
      else
         --Valid station and path selected.
         --(do nothing)
      end
   end

   if train.path_end_stop == nil then
      --Announce error to all passengers
      str = " No reachable trainstops detected. Check whether you have locomotives facing both directions as required."
      for i, player in ipairs(train.passengers) do
         players[player.index].last = str
         localised_print({ "", "out ", str })
      end
   else
      str = "Path set."
   end
   return str
end

--Tries to travel to every station on the surface to determine the valid ones
function mod.refresh_valid_train_stop_list(train, pindex)
   players[pindex].valid_train_stop_list = {}
   train.manual_mode = true
   local surf = train.front_stock.surface
   local train_stops = surf.get_train_stops()
   local str = ""
   for i, stop in ipairs(train_stops) do
      --Set a stop
      local wait_condition_1 = { type = "passenger_not_present", compare_type = "and" }
      local wait_condition_2 = { type = "time", ticks = 60, compare_type = "and" }
      local new_record = { wait_conditions = nil, station = stop.backer_name, temporary = true }
      --{ wait_conditions = { wait_condition_1, wait_condition_2 }, station = stop.backer_name, temporary = true }

      local schedule = train.schedule
      if schedule == nil then
         schedule = { current = 1, records = { new_record } }
      --game.get_player(pindex).print("made new schedule")
      else
         local records = schedule.records
         table.insert(records, 1, new_record)
      end
      train.schedule = schedule

      --Make the train aim for the stop
      train.go_to_station(1)
      if not train.has_path then
      --Invalid path: Do not add to list
      else
         --Valid station and path selected.
         table.insert(players[pindex].valid_train_stop_list, stop.backer_name)
      end

      --Clear the record
      local records = schedule.records
      table.remove(records, 1)
      if records == nil or #records == 0 then
         train.schedule = nil
         train.manual_mode = true
      else
         train.schedule = schedule
      end
   end
   return #players[pindex].valid_train_stop_list
end

--Train menu: Reads out a valid train stop from the reachable train stops list
function mod.read_valid_train_stop_from_list(pindex)
   local index = players[pindex].train_menu.index_2
   local name = ""
   if players[pindex].valid_train_stop_list == nil or #players[pindex].valid_train_stop_list == 0 then
      printout("Error: No reachable train stops found", pindex)
      return
   end
   if index == nil then index = 1 end
   players[pindex].train_menu.index_2 = index

   name = players[pindex].valid_train_stop_list[index]
   --Return the name
   printout(name, pindex)
end

function mod.go_to_valid_train_stop_from_list(pindex, train)
   local index = players[pindex].train_menu.index_2
   local name = ""
   if players[pindex].valid_train_stop_list == nil or #players[pindex].valid_train_stop_list == 0 then
      printout("Error: No reachable train stops found", pindex)
      return
   end
   if index == nil then index = 1 end
   players[pindex].train_menu.index_2 = index
   name = players[pindex].valid_train_stop_list[index]

   --Set the station target
   local wait_condition_1 = { type = "passenger_not_present", compare_type = "and" }
   local new_record = { wait_conditions = { wait_condition_1 }, station = name, temporary = true }

   local schedule = train.schedule
   if schedule == nil then
      schedule = { current = 1, records = { new_record } }
   --game.get_player(pindex).print("made new schedule")
   else
      local records = schedule.records
      -- If other temporary stops are present they are probably from us. For
      -- example sending a train to a station multiple times without leaving it.
      for i = #records, 1, -1 do
         if records[i].temporary == true then table.remove(records, i) end
      end
      table.insert(records, 1, new_record)
   end
   train.schedule = schedule

   --Make the train aim for the stop
   train.go_to_station(1)
   if not train.has_path or train.path.size < 3 then
      --Invalid path or path to an station nearby
      local records = schedule.records
      table.remove(records, 1)
      if records == nil or #records == 0 then
         train.schedule = nil
         train.manual_mode = true
      else
         train.schedule = schedule
      end
   else
      --Valid station and path selected.
      --(do nothing)
   end

   --Check valid path again
   local str = ""
   if train.path_end_stop == nil then
      --Announce error to all passengers
      str = "Error: Train stop pathing error."
      for i, player in ipairs(train.passengers) do
         players[player.index].last = str
         localised_print({ "", "out ", str })
      end
   else
      --Train will announce its new path by itself
   end

   mod.menu_close(pindex, false)
end

--Checks whether the train schedule contains any temporary train stops.
function mod.schedule_contains_temporary_stops(train)
   local schedule = train.schedule
   if schedule == nil or schedule == {} then return false end
   local records = schedule.records
   if records == nil or records == {} then return false end
   for i, record in ipairs(records) do
      if record.temporary == true then return true end
   end
   return false
end

--Honks if the following conditions are met: 1. The player is manually driving a train, 2. The train is moving, 3. Ahead of the train is a closed rail signal or rail chain signal, 4. It has been 5 seconds since the last honk.
function mod.check_and_honk_at_closed_signal(tick, pindex)
   if not check_for_player(pindex) then return end
   --0. Check if it has been 5 seconds since the last honk
   if players[pindex].last_honk_tick == nil then players[pindex].last_honk_tick = 1 end
   if tick - players[pindex].last_honk_tick < 300 then return end
   --1. Check if the player is on a train
   local p = game.get_player(pindex)
   local train = nil
   if p.vehicle == nil or p.vehicle.train == nil then
      return
   else
      train = p.vehicle.train
   end
   --2. Check if the train is manually driving and has nonzero speed
   if train.speed == 0 or not train.manual_mode then return end
   --3. Check if ahead of the train is a closed rail signal or rail chain signal
   local honk_score = mod.train_read_next_rail_entity_ahead(pindex, false, true)
   if honk_score < 2 then return end
   --4. HONK (short)
   game.get_player(pindex).play_sound({ path = "train-honk-short" })
   players[pindex].last_honk_tick = tick
end

--Honks if the following conditions are met: 1. The player is on a train, 2. The train is moving, 3. There is another train within the same rail block, 4. It has been 5 seconds since the last honk.
function mod.check_and_honk_at_trains_in_same_block(tick, pindex)
   if not check_for_player(pindex) then return end
   --0. Check if it has been 5 seconds since the last honk
   if players[pindex].last_honk_tick == nil then players[pindex].last_honk_tick = 1 end
   if tick - players[pindex].last_honk_tick < 300 then return end
   --1. Check if the player is on a train
   local p = game.get_player(pindex)
   local train = nil
   if p.vehicle == nil or p.vehicle.train == nil then
      return
   else
      train = p.vehicle.train
   end
   --2. Check if the train has nonzero speed
   if train.speed == 0 then return end
   --3. Check if there is another train within the same rail block (for both the front rail and the back rail)
   if train.front_rail == nil or not train.front_rail.valid or train.back_rail == nil or not train.back_rail.valid then
      return
   end
   if train.front_rail.trains_in_block < 2 and train.back_rail.trains_in_block < 2 then return end
   --4. HONK (long)
   game.get_player(pindex).play_sound({ path = "train-honk-long" })
   players[pindex].last_honk_tick = tick
end

--Play a sound to indicate the train is turning
function mod.check_and_play_sound_for_turning_trains(pindex)
   local p = game.get_player(pindex)
   if p.vehicle == nil or p.vehicle.valid == false or p.vehicle.train == nil then return end
   local ori = p.vehicle.orientation
   if players[pindex].last_train_orientation ~= nil and players[pindex].last_train_orientation ~= ori then
      p.play_sound({ path = "train-clack" })
   end
   players[pindex].last_train_orientation = ori
end

return mod
