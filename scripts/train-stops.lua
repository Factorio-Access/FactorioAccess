--Here: Functions relating to train train stops and train scheduling from them (which is a unique mod feature)
--Does not include event handlers
local Graphics = require("scripts.graphics")
local MessageBuilder = require("scripts.message-builder")
local UiRouter = require("scripts.ui.router")

local mod = {}

--This menu opens when the cursor presses LEFT BRACKET on a train stop.
function mod.run_train_stop_menu(menu_index, pindex, clicked, other_input)
   local index = menu_index
   local other = other_input or -1
   local train_stop = nil
   if players[pindex].tile.ents[1] ~= nil and players[pindex].tile.ents[1].name == "train-stop" then
      train_stop = players[pindex].tile.ents[1]
      players[pindex].train_stop_menu.stop = train_stop
   else
      printout({ "fa.train-stops-menu-error" }, pindex)
      players[pindex].train_stop_menu.stop = nil
      return
   end

   if index == 0 then
      printout(
         "Train stop "
            .. train_stop.backer_name
            .. ", Press W and S to navigate options, press LEFT BRACKET to select an option or press E to exit this menu.",
         pindex
      )
   elseif index == 1 then
      if not clicked then
         printout({ "fa.train-stops-rename-prompt" }, pindex)
      else
         printout(
            "Enter a new name for this train stop, then press 'ENTER' to confirm, or press 'ESC' to cancel.",
            pindex
         )
         players[pindex].train_stop_menu.renaming = true
         local frame = Graphics.create_text_field_frame(pindex, "train-stop-rename")
         game.get_player(pindex).opened = frame
      end
   elseif index == 2 then
      local result = mod.nearby_train_schedule_read_this_stop(train_stop)
      local message = MessageBuilder.new()
      message:fragment(result)
      message:fragment({ "fa.train-stop-modify-schedule-prompt" })
      printout(message:build(), pindex)
   elseif index == 3 then
      if not clicked then
         if players[pindex].train_stop_menu.wait_condition == nil then
            players[pindex].train_stop_menu.wait_condition = "time"
         end
         printout(
            "Proposed wait condition: "
               .. players[pindex].train_stop_menu.wait_condition
               .. " selected, change by selecting here, this change needs to also be applied.",
            pindex
         )
      else
         local condi = players[pindex].train_stop_menu.wait_condition
         if condi == "time" then
            condi = "inactivity"
         elseif condi == "inactivity" then
            condi = "empty"
         elseif condi == "empty" then
            condi = "full"
         elseif condi == "full" then
            condi = "passenger_present"
         elseif condi == "passenger_present" then
            condi = "passenger_not_present"
         else
            condi = "time"
         end
         players[pindex].train_stop_menu.wait_condition = condi
         printout(
            " "
               .. players[pindex].train_stop_menu.wait_condition
               .. " condition proposed, change by selecting here, this change needs to also be applied.",
            pindex
         )
      end
   elseif index == 4 then
      if players[pindex].train_stop_menu.wait_time_seconds == nil then
         players[pindex].train_stop_menu.wait_time_seconds = 60
      end
      printout(
         "Proposed wait time: "
            .. players[pindex].train_stop_menu.wait_time_seconds
            .. " seconds selected, if applicable, change using page up or page down, and hold control to increase step size. This change needs to also be applied.",
         pindex
      )
   elseif index == 5 then
      if not clicked then
         if players[pindex].train_stop_menu.safety_wait_enabled == nil then
            players[pindex].train_stop_menu.safety_wait_enabled = true
         end
         local result = ""
         if players[pindex].train_stop_menu.safety_wait_enabled == true then
            result =
               "ENABLED proposed safety waiting, select here to disable it, Enabling it makes the train wait at this stop for 5 seconds regardless of the main wait condition, this change needs to also be applied."
         else
            result =
               "DISABLED proposed safety waiting, select here to enable it, Enabling it makes the train wait at this stop for 5 seconds regardless of the main wait condition, this change needs to also be applied."
         end
         printout(result, pindex)
      else
         players[pindex].train_stop_menu.safety_wait_enabled = not players[pindex].train_stop_menu.safety_wait_enabled
         if players[pindex].train_stop_menu.safety_wait_enabled == true then
            result =
               "ENABLED proposed safety waiting, select here to disable it, Enabling it makes the train wait at this stop for 5 seconds regardless of the main wait condition, this change needs to also be applied."
         else
            result =
               "DISABLED proposed safety waiting, select here to enable it, Enabling it makes the train wait at this stop for 5 seconds regardless of the main wait condition, this change needs to also be applied."
         end
         printout(result, pindex)
      end
   elseif index == 6 then
      if not clicked then
         printout(
            "ADD A NEW ENTRY for this train stop by selecting here, with the proposed conditions applied, for a train parked by this train stop.",
            pindex
         )
      else
         local result = mod.nearby_train_schedule_add_stop(
            train_stop,
            players[pindex].train_stop_menu.wait_condition,
            players[pindex].train_stop_menu.wait_time_seconds
         )
         printout(result, pindex)
      end
   elseif index == 7 then
      if not clicked then
         printout(
            "UPDATE ALL ENTRIES for this train stop by selecting here, with the proposed conditions applied, for a train parked by this train stop.",
            pindex
         )
      else
         local result = mod.nearby_train_schedule_update_stop(
            train_stop,
            players[pindex].train_stop_menu.wait_condition,
            players[pindex].train_stop_menu.wait_time_seconds
         )
         printout(result, pindex)
      end
   elseif index == 8 then
      if not clicked then
         printout(
            "REMOVE ALL ENTRIES for this train stop by selecting here, for a train parked by this train stop.",
            pindex
         )
      else
         local result = mod.nearby_train_schedule_remove_stop(train_stop)
         printout(result, pindex)
      end
   elseif index == 9 then
      if not clicked then
         printout({ "fa.train-stops-set-limit" }, pindex)
      else
         printout({ "fa.train-stops-enter-number" }, pindex)
         players[pindex].train_limit_editing = true
         local frame = Graphics.create_text_field_frame(pindex, "train-limit-edit")
      end
   end
end
mod.TRAIN_STOP_MENU_LENGTH = 9

function mod.train_stop_menu_open(pindex)
   local router = UiRouter.get_router(pindex)

   if players[pindex].vanilla_mode then return end

   router:open_ui(UiRouter.UI_NAMES.TRAIN_STOP)
   players[pindex].move_queue = {}

   --Set the menu line counter to 0
   players[pindex].train_stop_menu.index = 0

   --Play sound
   game.get_player(pindex).play_sound({ path = "Open-Inventory-Sound" })

   --Load menu
   mod.run_train_stop_menu(players[pindex].train_stop_menu.index, pindex, false)
end

function mod.train_stop_menu_close(pindex, mute_in)
   local router = UiRouter.get_router(pindex)

   local mute = mute_in
   router:close_ui()

   --Set the menu line counter to 0
   players[pindex].train_stop_menu.index = 0

   --Destroy GUI
   if game.get_player(pindex).gui.screen["train-stop-rename"] ~= nil then
      game.get_player(pindex).gui.screen["train-stop-rename"].destroy()
   end

   --play sound
   if not mute then game.get_player(pindex).play_sound({ path = "Close-Inventory-Sound" }) end
end

function mod.train_stop_menu_up(pindex)
   players[pindex].train_stop_menu.index = players[pindex].train_stop_menu.index - 1
   if players[pindex].train_stop_menu.index < 0 then
      players[pindex].train_stop_menu.index = 0
      game.get_player(pindex).play_sound({ path = "inventory-edge" })
   else
      --Play sound
      game.get_player(pindex).play_sound({ path = "Inventory-Move" })
   end
   --Load menu
   mod.run_train_stop_menu(players[pindex].train_stop_menu.index, pindex, false)
end

function mod.train_stop_menu_down(pindex)
   players[pindex].train_stop_menu.index = players[pindex].train_stop_menu.index + 1
   if players[pindex].train_stop_menu.index > mod.TRAIN_STOP_MENU_LENGTH then
      players[pindex].train_stop_menu.index = mod.TRAIN_STOP_MENU_LENGTH
      game.get_player(pindex).play_sound({ path = "inventory-edge" })
   else
      --Play sound
      game.get_player(pindex).play_sound({ path = "Inventory-Move" })
   end
   --Load menu
   mod.run_train_stop_menu(players[pindex].train_stop_menu.index, pindex, false)
end

--For the selected train stop, changes assigned wait time in seconds for the parked train. The increment is a positive or negative integer.
function mod.nearby_train_schedule_add_to_wait_time(increment, pindex)
   local seconds = players[pindex].train_stop_menu.wait_time_seconds
   if seconds == nil then seconds = 300 end
   seconds = seconds + increment
   if seconds < 5 then
      seconds = 5
   elseif seconds > 10000 then
      seconds = 10000
   end
   players[pindex].train_stop_menu.wait_time_seconds = seconds
   printout({ "fa.train-stop-wait-time-set", tostring(players[pindex].train_stop_menu.wait_time_seconds) }, pindex)
end

--Returns an info string on what the parked train at this stop is scheduled to do at this stop.
function mod.nearby_train_schedule_read_this_stop(train_stop)
   local result = "Reading parked train: "
   local found_any = false

   --Locate the nearby train
   local train = train_stop.get_stopped_train()
   if train == nil or not train.valid then
      local locos =
         train_stop.surface.find_entities_filtered({ position = train_stop.position, radius = 5, name = "locomotive" })
      if locos[1] ~= nil and locos[1].valid then
         train = locos[1].train
      else
         result = "Reading parked train: Error: No locomotive found nearby,"
         return result
      end
   end
   if train == nil or not train.valid then
      result = "Reading parked train: Error: No train found nearby,"
      return result
   end
   --Read the schedule and find this station's entry
   local schedule = train.schedule
   if schedule == nil then
      result = "Reading parked train: Error: The nearby train schedule is empty,"
      return result
   else
      local records = schedule.records
      result = "Reading parked train, "
      for i, r in ipairs(records) do
         if r.station == train_stop.backer_name then
            found_any = true
            result = result .. ", at this stop it waits for "
            local wait_condition_read_1 = r.wait_conditions[1]
            local wait_condition_read_2 = r.wait_conditions[2]
            if wait_condition_read_1 == nil then
               result = result .. " nothing "
            else
               result = result .. wait_condition_read_1.type
               if wait_condition_read_1.type == "time" or wait_condition_read_1.type == "inactivity" then
                  result = result .. ", " .. math.ceil(wait_condition_read_1.ticks / 60) .. " seconds"
               end
            end
            if wait_condition_read_2 ~= nil and wait_condition_read_2.type == "time" then
               result = result .. ", and a safety wait of " .. math.ceil(wait_condition_read_2.ticks / 60) .. " seconds"
            end
         end
      end
   end

   if found_any == false then
      result = "Reading parked train: Error: The nearby train schedule does not contain this train stop,"
   end
   return result
end

--Returns an info string after adding this train stop to the parked train.
--NOTE: This function is effectively dead code - trains functionality is not currently active
function mod.nearby_train_schedule_add_stop(train_stop, wait_condition_type, wait_time_seconds)
   local result = "initial"
   --Locate the nearby train
   local train = train_stop.get_stopped_train()
   if train == nil or not train.valid then
      local locos =
         train_stop.surface.find_entities_filtered({ position = train_stop.position, radius = 5, name = "locomotive" })
      if locos[1] ~= nil and locos[1].valid then
         train = locos[1].train
      else
         result = "Error: No locomotive found nearby."
         return result
      end
   end
   if train == nil or not train.valid then
      result = "Error: No train found nearby."
      return result
   end
   --Create new record
   local wait_condition_1 = { type = wait_condition_type, ticks = wait_time_seconds * 60, compare_type = "and" }
   local wait_condition_2 = { type = "time", ticks = 300, compare_type = "and" }
   local new_record = { wait_conditions = { wait_condition_1 }, station = train_stop.backer_name, temporary = false }
   if players[pindex].train_stop_menu.safety_wait_enabled then
      new_record = {
         wait_conditions = { wait_condition_1, wait_condition_2 },
         station = train_stop.backer_name,
         temporary = false,
      }
   end
   --Copy and modify the schedule
   local schedule = train.schedule
   local records = nil
   if schedule == nil then
      schedule = { current = 1, records = { new_record } }
   else
      records = schedule.records
      table.insert(records, #records + 1, new_record)
   end
   --Apply the new schedule
   train.manual_mode = true
   train.schedule = schedule
   --Return result
   result = "Successfully added this train stop to the nearby train's schedule."
   return result
end

--Returns an info string after updating every entry for this train stop for the parked train.
function mod.nearby_train_schedule_update_stop(train_stop, wait_condition_type, wait_time_seconds)
   local result = "initial"
   --Locate the nearby train
   local train = train_stop.get_stopped_train()
   if train == nil or not train.valid then
      local locos =
         train_stop.surface.find_entities_filtered({ position = train_stop.position, radius = 5, name = "locomotive" })
      if locos[1] ~= nil and locos[1].valid then
         train = locos[1].train
      else
         result = "Error: No locomotive found nearby."
         return result
      end
   end
   if train == nil or not train.valid then
      result = "Error: No train found nearby."
      return result
   end
   --Create new record
   local wait_condition_1 = { type = wait_condition_type, ticks = wait_time_seconds * 60, compare_type = "and" }
   local wait_condition_2 = { type = "time", ticks = 300, compare_type = "and" }
   local new_record = { wait_conditions = { wait_condition_1 }, station = train_stop.backer_name, temporary = false }
   if players[pindex].train_stop_menu.safety_wait_enabled then
      new_record = {
         wait_conditions = { wait_condition_1, wait_condition_2 },
         station = train_stop.backer_name,
         temporary = false,
      }
   end
   --Copy and modify the schedule
   local schedule = train.schedule
   local records = nil
   local updated_any = false
   if schedule == nil then
      result = "Error: The nearby train schedule is empty."
      return result
   else
      records = schedule.records
      local new_records = {}
      for i, r in ipairs(records) do
         if r.station == train_stop.backer_name then
            updated_any = true
            table.insert(new_records, new_record)
            --game.get_player(pindex).print(" hit " .. i)
         else
            table.insert(new_records, r)
            --game.get_player(pindex).print(" miss " .. i)
         end
      end
      schedule.records = new_records
   end
   --Apply the new schedule
   train.manual_mode = true
   train.schedule = schedule
   --Return result
   if updated_any == true then
      result = "Successfully updated all entries for this train stop on the nearby train's schedule."
   else
      result = "Error: The nearby train schedule did not include this stop."
   end
   return result
end

--Returns an info string after removing every entry for this train stop for the parked train.
function mod.nearby_train_schedule_remove_stop(train_stop)
   local result = "initial"
   --Locate the nearby train
   local train = train_stop.get_stopped_train()
   if train == nil or not train.valid then
      local locos =
         train_stop.surface.find_entities_filtered({ position = train_stop.position, radius = 5, name = "locomotive" })
      if locos[1] ~= nil and locos[1].valid then
         train = locos[1].train
      else
         result = "Error: No locomotive found nearby."
         return result
      end
   end
   if train == nil or not train.valid then
      result = "Error: No train found nearby."
      return result
   end
   --Copy and modify the schedule
   local schedule = train.schedule
   local records = nil
   local updated_any = false
   if schedule == nil then
      result = "Error: The nearby train schedule is already empty."
      return result
   else
      records = schedule.records
      local new_records = {}
      for i, r in ipairs(records) do
         if r.station == train_stop.backer_name then
            records[i] = nil
            updated_any = true
            --game.get_player(pindex).print(" hit ".. i)
         else
            table.insert(new_records, r)
            --game.get_player(pindex).print(" miss ".. i)
         end
      end
      schedule.records = new_records
      schedule.current = 1
   end
   --Apply the new schedule
   if records == nil or #records == 0 then
      train.schedule = nil
      train.manual_mode = true
   else
      train.manual_mode = true
      train.schedule = schedule
   end
   --Return result
   if updated_any then
      result = "Successfully removed all entries for this train stop on the nearby train's schedule."
   else
      result = "Error: The nearby train schedule already did not include this stop."
   end
   return result
end

return mod
