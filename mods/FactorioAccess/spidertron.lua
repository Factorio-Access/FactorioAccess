function spider_menu(menu_index, pindex, spiderin, clicked, other_input)
   local index = menu_index
   local spider
   local remote =  game.get_player(pindex).cursor_stack
   local other = other_input or -1
   local cursortarget = get_selected_ent(pindex)
   local spidertron = game.get_player(pindex).cursor_stack.connected_entity
   if spiderin ~= nil then
      spider = spiderin
   end
   if index == 0 then
      --Give basic info about this spider, such as its name and ID.
      local res
      if remote.connected_entity ~= nil then
         if spidertron.entity_label ~= nil then
            res = spidertron.entity_label .. "connected to this remote. "
         else 
            res = "unlabelled spidertron connected"
         end
      else
         res = "this remote is not connected to a spidertron"
      end
      printout(res
      .. ", Press UP ARROW and DOWN ARROW to navigate options, press LEFT BRACKET to select an option or press E to exit this menu.", pindex)
   elseif index == 1 then
      --spidertron linking and unlinking from the remote
      if not clicked then
         if remote.connected_entity ~= nil then
            local spidername
            if game.get_player(pindex).cursor_stack.connected_entity.entity_label~= nil  then
               spidername = game.get_player(pindex).cursor_stack.connected_entity.entity_label
            else
               spidername = "an unlabelled spidertron"
            end
            local result = "the remote is connected to " .. spidername
            result = result .. ", press LEFT BRACKET to unlink it. "
            printout(result, pindex)
         else
            local result = "the remote is not connected. "
            result = result .. ", press LEFT BRACKET to link it to the focused spidertron. "
            printout(result, pindex)
         end
      else
         if remote.connected_entity ~= nil then
            remote.connected_entity = nil
            printout("remote link severed.", pindex)
         else
            local result 
            if cursortarget == nil or (cursortarget.type ~= "spider-vehicle" and cursortarget.type ~= "spider-leg") then
               result = "Invalid object to link to this remote. "
            else
               if cursortarget.type == "spider-vehicle" then
                  remote.connected_entity = cursortarget
               else
                  local spiders = cursortarget.surface.find_entities_filtered{position = cursortarget.position, radius = 5, type = "spider-vehicle"}
                  if spiders[1] and spiders[1].valid then
                     remote.connected_entity = spiders[1]
                  end
               end
               result = "remote connected to "
               if game.get_player(pindex).cursor_stack.connected_entity.entity_label ~= nil then
                  result = result .. game.get_player(pindex).cursor_stack.connected_entity.entity_label
               else
                  result = result .. "an unlabelled spidertron."
               end
            end
            printout(result, pindex)
         end
      end
   elseif index == 2 then
      --Rename the connected spidertron
      if not clicked then
         printout("Rename this spidertron, press LEFT BRACKET.", pindex)
      else
         if remote.connected_entity == nil then
            printout("To rename a spidertron, link it to this remote first. ", pindex)
         else
            printout("Enter a new name for this spidertron, then press ENTER to confirm.", pindex)
            players[pindex].spider_menu.renaming = true
            local frame = game.get_player(pindex).gui.screen.add{type = "frame", name = "spider-rename"}
            frame.bring_to_front()
            frame.force_auto_center()
            frame.focus()
            game.get_player(pindex).opened = frame
            local input = frame.add{type="textfield", name = "input"}
            input.focus()
         end
      end
   elseif index == 3 then
      --Set the cursor position as the spidertron autopilot target 
      if not clicked then
         printout("Set the cursor position as the spidertron autopilot target ", pindex)
      else
         if remote.connected_entity == nil then
            printout("To move a spidertron, link it to this remote first.", pindex)
         else
            cursor = players[pindex].cursor_pos
            game.get_player(pindex).cursor_stack.connected_entity.autopilot_destination = cursor
            printout("Spidertron sent to coordinates" .. math.floor(cursor.x) .. ", " .. math.floor(cursor.y), pindex)
         end
      end
   elseif index == 4 then
      --Add the cursor position to the spidertron autopilot queue 
      if not clicked then
         printout("add the cursor position to the spidertron autopilot queue", pindex)
      else
         if remote.connected_entity == nil then
            printout("To move a spidertron, link it to this remote first.", pindex)
         else
            cursor = players[pindex].cursor_pos
            game.get_player(pindex).cursor_stack.connected_entity.add_autopilot_destination(cursor)
            printout("Coordinates " .. math.floor(cursor.x) .. ", " .. math.floor(cursor.y) .. "added to this spidertron's autopilot queue.", pindex)
         end
      end
   elseif index == 5 then
      --Toggle automatically targetting enemies when the spidertron is working by itself
      if remote.connected_entity == nil then
         printout("No linked spidertron.", pindex)
      else
         if not clicked then
            local targetstate
            if game.get_player(pindex).cursor_stack.connected_entity.vehicle_automatic_targeting_parameters.auto_target_without_gunner == true then
               targetstate = "enabled"
            else
               targetstate = "disabled"
            end
            printout("auto target enemies when the spidertron is working by itself, currently" .. targetstate, pindex)
         else
            local switch = {auto_target_without_gunner = not game.get_player(pindex).cursor_stack.connected_entity.vehicle_automatic_targeting_parameters.auto_target_without_gunner, auto_target_with_gunner = game.get_player(pindex).cursor_stack.connected_entity.vehicle_automatic_targeting_parameters.auto_target_with_gunner}
            game.get_player(pindex).cursor_stack.connected_entity.vehicle_automatic_targeting_parameters = switch
            local targetstate
            if game.get_player(pindex).cursor_stack.connected_entity.vehicle_automatic_targeting_parameters.auto_target_without_gunner == true then
               targetstate = "enabled"
            else
               targetstate = "disabled"
            end
            printout(targetstate .. " auto target enemies when the spidertron is working by itself", pindex)
         end
      end
   elseif index == 6 then
      --Toggle automatically targetting enemies when there is a gunner insider
      if remote.connected_entity == nil then
         printout("No linked spidertron.", pindex)
      else
         if not clicked then
            local targetstate
            if game.get_player(pindex).cursor_stack.connected_entity.vehicle_automatic_targeting_parameters.auto_target_with_gunner == true then
               targetstate = "enabled"
            else
               targetstate = "disabled"
            end
            printout("auto target enemies with gunner inside, currently" .. targetstate, pindex)
         else
            local switch = {auto_target_without_gunner = game.get_player(pindex).cursor_stack.connected_entity.vehicle_automatic_targeting_parameters.auto_target_without_gunner, auto_target_with_gunner = not game.get_player(pindex).cursor_stack.connected_entity.vehicle_automatic_targeting_parameters.auto_target_with_gunner}
            game.get_player(pindex).cursor_stack.connected_entity.vehicle_automatic_targeting_parameters = switch
            local targetstate
            if game.get_player(pindex).cursor_stack.connected_entity.vehicle_automatic_targeting_parameters.auto_target_with_gunner == true then
               targetstate = "enabled"
            else
               targetstate = "disabled"
            end
            printout(targetstate .. " auto target enemies with gunner inside ", pindex)
         end
      end
   elseif index == 7 then
      --Set the spidertron autopilot to follow the selected entity
      if not clicked then
         printout("Set the spidertron autopilot to follow the selected entity", pindex)
      else
         if remote.connected_entity ~= nil then
            game.get_player(pindex).cursor_stack.connected_entity.follow_target = cursortarget
            printout("spider started to follow the unit.", pindex)
         else
            printout("To use this menu item, link a spidertron to this remote.", pindex)
         end
      end

   end
end
SPIDER_MENU_LENGTH = 7

function spider_menu_open(pindex, stack)
   if players[pindex].vanilla_mode then
      return 
   end
   --Set the player menu tracker to this menu
   players[pindex].menu = "spider_menu"
   players[pindex].in_menu = true
   players[pindex].move_queue = {}
   local spider = stack
   --Set the menu line counter to 0
   players[pindex].spider_menu.index = 0
   
   --Play sound
   game.get_player(pindex).play_sound{path = "Open-Inventory-Sound"}
   
   --Load menu 
   spider_menu(players[pindex].spider_menu.index, pindex, spider, false)
end


function spider_menu_close(pindex, mute_in)
   local mute = mute_in
   --Set the player menu tracker to none
   players[pindex].menu = "none"
   players[pindex].in_menu = false

   --Set the menu line counter to 0
   players[pindex].spider_menu.index = 0
   
   --play sound
   if not mute then
      game.get_player(pindex).play_sound{path="Close-Inventory-Sound"}
   end
   
   --Destroy GUI
   if game.get_player(pindex).gui.screen["spider-rename"] ~= nil then
      game.get_player(pindex).gui.screen["spider-rename"].destroy()
   end
   if game.get_player(pindex).opened ~= nil then
      game.get_player(pindex).opened = nil
   end
end

function spider_menu_up(pindex, spider)
   players[pindex].spider_menu.index = players[pindex].spider_menu.index - 1
   if players[pindex].spider_menu.index < 0 then
      players[pindex].spider_menu.index = 0
      game.get_player(pindex).play_sound{path = "inventory-edge"}
   else
      --Play sound
      game.get_player(pindex).play_sound{path = "Inventory-Move"}
   end
   --Load menu
   spider_menu(players[pindex].spider_menu.index, pindex, spider, false)
end

function spider_menu_down(pindex, spider)
   players[pindex].spider_menu.index = players[pindex].spider_menu.index + 1
   if players[pindex].spider_menu.index > SPIDER_MENU_LENGTH then
      players[pindex].spider_menu.index = SPIDER_MENU_LENGTH
      game.get_player(pindex).play_sound{path = "inventory-edge"}
   else
      --Play sound
      game.get_player(pindex).play_sound{path = "Inventory-Move"}
   end
   --Load menu

   spider_menu(players[pindex].spider_menu.index, pindex, spider, false)
end
