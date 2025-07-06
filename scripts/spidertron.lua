--Here: Spidertron remote menu
local Graphics = require("scripts.graphics")
local Speech = require("scripts.speech")
local UiRouter = require("scripts.ui.router")
local Viewpoint = require("scripts.viewpoint")

local mod = {}

--This menu is opened via a spidertron remote.
function mod.run_spider_menu(menu_index, pindex, spiderin, clicked, other_input)
   local index = menu_index
   local vp = Viewpoint.get_viewpoint(pindex)
   local cursor = vp:get_cursor_pos()
   local spider
   local remote = game.get_player(pindex).cursor_stack
   local other = other_input or -1
   local cursortarget = game.get_player(pindex).selected
   local spidertron = game.get_player(pindex).cursor_stack.connected_entity
   if spiderin ~= nil then spider = spiderin end
   if index == 0 then
      --Give basic info about this spider, such as its name and ID.
      local message = Speech.new()
      if remote.connected_entity ~= nil then
         if spidertron.entity_label ~= nil then
            message:fragment({ "fa.spidertron-connected-named", spidertron.entity_label })
         else
            message:fragment({ "fa.spidertron-connected-unnamed" })
         end
      else
         message:fragment({ "fa.spidertron-not-connected" })
      end
      message:fragment({ "fa.spidertron-menu-instructions" })
      Speech.speak(pindex, message:build())
   elseif index == 1 then
      --spidertron linking and unlinking from the remote
      if not clicked then
         local message = Speech.new()
         if remote.connected_entity ~= nil then
            message:fragment({ "fa.spidertron-remote-connected-to" })
            if game.get_player(pindex).cursor_stack.connected_entity.entity_label ~= nil then
               message:fragment(game.get_player(pindex).cursor_stack.connected_entity.entity_label)
            else
               message:fragment({ "fa.spidertron-unnamed" })
            end
            message:fragment({ "fa.spidertron-press-to-unlink" })
         else
            message:fragment({ "fa.spidertron-remote-not-connected" })
            message:fragment({ "fa.spidertron-press-to-link" })
         end
         Speech.speak(pindex, message:build())
      else
         if remote.connected_entity ~= nil then
            remote.connected_entity = nil
            Speech.speak(pindex, { "fa.spidertron-link-severed" })
         else
            if cursortarget == nil or (cursortarget.type ~= "spider-vehicle" and cursortarget.type ~= "spider-leg") then
               Speech.speak(pindex, { "fa.spidertron-invalid-link-target" })
            else
               if cursortarget.type == "spider-vehicle" then
                  remote.connected_entity = cursortarget
               else
                  local spiders = cursortarget.surface.find_entities_filtered({
                     position = cursortarget.position,
                     radius = 5,
                     type = "spider-vehicle",
                  })
                  if spiders[1] and spiders[1].valid then remote.connected_entity = spiders[1] end
               end
               local message = Speech.new()
               message:fragment({ "fa.spidertron-remote-linked-to" })
               if game.get_player(pindex).cursor_stack.connected_entity.entity_label ~= nil then
                  message:fragment(game.get_player(pindex).cursor_stack.connected_entity.entity_label)
               else
                  message:fragment({ "fa.spidertron-unnamed" })
               end
               Speech.speak(pindex, message:build())
            end
         end
      end
   elseif index == 2 then
      --Rename the connected spidertron
      if not clicked then
         Speech.speak(pindex, { "fa.spidertron-rename-prompt" })
      else
         if remote.connected_entity == nil then
            Speech.speak(pindex, { "fa.spidertron-link-first-rename" })
         else
            Speech.speak(pindex, { "fa.spidertron-enter-new-name" })
            storage.players[pindex].spider_menu.renaming = true
            local frame = Graphics.create_text_field_frame(pindex, "spider-rename")
            game.get_player(pindex).opened = frame
         end
      end
   elseif index == 3 then
      --Set the cursor position as the spidertron autopilot target
      if not clicked then
         Speech.speak(pindex, { "fa.spidertron-set-target" })
      else
         if remote.connected_entity == nil then
            Speech.speak(pindex, { "fa.spidertron-link-first-move" })
         else
            game.get_player(pindex).cursor_stack.connected_entity.autopilot_destination = cursor
            Speech.speak(pindex, {
               "fa.spidertron-sent-to-coords",
               tostring(math.floor(cursor.x)),
               tostring(math.floor(cursor.y)),
            })
         end
      end
   elseif index == 4 then
      --Add the cursor position to the spidertron autopilot queue
      if not clicked then
         Speech.speak(pindex, { "fa.spidertron-add-to-queue" })
      else
         if remote.connected_entity == nil then
            Speech.speak(pindex, { "fa.spidertron-link-first-move" })
         else
            game.get_player(pindex).cursor_stack.connected_entity.add_autopilot_destination(cursor)
            Speech.speak(
               pindex,
               "Coordinates "
                  .. math.floor(cursor.x)
                  .. ", "
                  .. math.floor(cursor.y)
                  .. "added to this spidertron's autopilot queue."
            )
         end
      end
   elseif index == 5 then
      --Toggle automatically targetting enemies when the spidertron is working by itself
      if remote.connected_entity == nil then
         Speech.speak(pindex, { "fa.spidertron-no-linked" })
      else
         if not clicked then
            local targetstate
            if
               game.get_player(pindex).cursor_stack.connected_entity.vehicle_automatic_targeting_parameters.auto_target_without_gunner
               == true
            then
               targetstate = "enabled"
            else
               targetstate = "disabled"
            end
            Speech.speak(pindex, { "fa.spidertron-auto-target-status", targetstate })
         else
            local switch = {
               auto_target_without_gunner = not game.get_player(pindex).cursor_stack.connected_entity.vehicle_automatic_targeting_parameters.auto_target_without_gunner,
               auto_target_with_gunner = game.get_player(pindex).cursor_stack.connected_entity.vehicle_automatic_targeting_parameters.auto_target_with_gunner,
            }
            game.get_player(pindex).cursor_stack.connected_entity.vehicle_automatic_targeting_parameters = switch
            local targetstate
            if
               game.get_player(pindex).cursor_stack.connected_entity.vehicle_automatic_targeting_parameters.auto_target_without_gunner
               == true
            then
               targetstate = "enabled"
            else
               targetstate = "disabled"
            end
            Speech.speak(pindex, { "fa.spidertron-auto-target-without-gunner", targetstate })
         end
      end
   elseif index == 6 then
      --Toggle automatically targetting enemies when there is a gunner insider
      if remote.connected_entity == nil then
         Speech.speak(pindex, { "fa.spidertron-no-linked" })
      else
         if not clicked then
            local targetstate
            if
               game.get_player(pindex).cursor_stack.connected_entity.vehicle_automatic_targeting_parameters.auto_target_with_gunner
               == true
            then
               targetstate = "enabled"
            else
               targetstate = "disabled"
            end
            Speech.speak(pindex, { "fa.spidertron-auto-target-with-gunner-current", targetstate })
         else
            local switch = {
               auto_target_without_gunner = game.get_player(pindex).cursor_stack.connected_entity.vehicle_automatic_targeting_parameters.auto_target_without_gunner,
               auto_target_with_gunner = not game.get_player(pindex).cursor_stack.connected_entity.vehicle_automatic_targeting_parameters.auto_target_with_gunner,
            }
            game.get_player(pindex).cursor_stack.connected_entity.vehicle_automatic_targeting_parameters = switch
            local targetstate
            if
               game.get_player(pindex).cursor_stack.connected_entity.vehicle_automatic_targeting_parameters.auto_target_with_gunner
               == true
            then
               targetstate = "enabled"
            else
               targetstate = "disabled"
            end
            Speech.speak(pindex, { "fa.spidertron-auto-target-with-gunner-set", targetstate })
         end
      end
   elseif index == 7 then
      --Set the spidertron autopilot to follow the selected entity
      if not clicked then
         Speech.speak(pindex, { "fa.spidertron-follow-entity" })
      else
         if remote.connected_entity ~= nil then
            game.get_player(pindex).cursor_stack.connected_entity.follow_target = cursortarget
            Speech.speak(pindex, { "fa.spidertron-started-following" })
         else
            Speech.speak(pindex, { "fa.spidertron-link-required" })
         end
      end
   end
end
local SPIDER_MENU_LENGTH = 7

function mod.spider_menu_open(pindex, stack)
   local router = UiRouter.get_router(pindex)

   if storage.players[pindex].vanilla_mode then return end
   router:open_ui(UiRouter.UI_NAMES.SPIDERTRON)
   storage.players[pindex].move_queue = {}
   local spider = stack
   --Set the menu line counter to 0
   storage.players[pindex].spider_menu.index = 0

   --Play sound
   game.get_player(pindex).play_sound({ path = "Open-Inventory-Sound" })

   --Load menu
   mod.run_spider_menu(storage.players[pindex].spider_menu.index, pindex, spider, false)
end

function mod.spider_menu_close(pindex, mute_in)
   local router = UiRouter.get_router(pindex)

   local mute = mute_in
   --Set the player menu tracker to none
   router:close_ui()

   --Set the menu line counter to 0
   storage.players[pindex].spider_menu.index = 0

   --play sound
   if not mute then game.get_player(pindex).play_sound({ path = "Close-Inventory-Sound" }) end

   --Destroy GUI
   if game.get_player(pindex).gui.screen["spider-rename"] ~= nil then
      game.get_player(pindex).gui.screen["spider-rename"].destroy()
   end
   if game.get_player(pindex).opened ~= nil then game.get_player(pindex).opened = nil end
end

function mod.spider_menu_up(pindex, spider)
   storage.players[pindex].spider_menu.index = storage.players[pindex].spider_menu.index - 1
   if storage.players[pindex].spider_menu.index < 0 then
      storage.players[pindex].spider_menu.index = 0
      game.get_player(pindex).play_sound({ path = "inventory-edge" })
   else
      --Play sound
      game.get_player(pindex).play_sound({ path = "Inventory-Move" })
   end
   --Load menu
   mod.run_spider_menu(storage.players[pindex].spider_menu.index, pindex, spider, false)
end

function mod.spider_menu_down(pindex, spider)
   storage.players[pindex].spider_menu.index = storage.players[pindex].spider_menu.index + 1
   if storage.players[pindex].spider_menu.index > SPIDER_MENU_LENGTH then
      storage.players[pindex].spider_menu.index = SPIDER_MENU_LENGTH
      game.get_player(pindex).play_sound({ path = "inventory-edge" })
   else
      --Play sound
      game.get_player(pindex).play_sound({ path = "Inventory-Move" })
   end
   --Load menu

   mod.run_spider_menu(storage.players[pindex].spider_menu.index, pindex, spider, false)
end

return mod
