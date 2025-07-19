--Here: Spidertron remote menu
local Graphics = require("scripts.graphics")
local Speech = require("scripts.speech")
local UiRouter = require("scripts.ui.router")
local Viewpoint = require("scripts.viewpoint")

local mod = {}

--This menu is opened via a spidertron remote.
function mod.run_spider_menu(index, pindex, spiderin, clicked, other_input)
   local vp = Viewpoint.get_viewpoint(pindex)
   local cursor = vp:get_cursor_pos()
   local spider
   local p = game.get_player(pindex)
   local remote = p.cursor_stack
   local other = other_input or -1
   local cursortarget = p.selected
   local spidertrons = p.spidertron_remote_selection
   if spiderin ~= nil then spider = spiderin end
   if index == 0 then
      --Give basic info about this spider, such as its name and ID.
      local message = Speech.new()
      if spidertrons ~= nil and #spidertrons > 0 then
         if #spidertrons == 1 then
            if spidertrons[1].entity_label ~= nil then
               message:fragment({ "fa.spidertron-connected-named", spidertrons[1].entity_label })
            else
               message:fragment({ "fa.spidertron-connected-unnamed" })
            end
         else
            message:fragment({ "fa.spidertrons-connected", #spidertrons })
         end
      else
         message:fragment({ "fa.spidertron-not-connected" })
      end
      message:fragment({ "fa.spidertron-menu-instructions" })
      Speech.speak(pindex, message:build())
   elseif index == 1 then
      -- spidertron linking (add only) from the remote
      if not clicked then
         local message = Speech.new()
         if spidertrons ~= nil and #spidertrons > 0 then
            message:fragment({ "fa.spidertrons-connected", #spidertrons })
            message:fragment({ "fa.spidertron-press-to-link-more" }) -- e.g., "Press [key] to add another."
         else
            message:fragment({ "fa.spidertron-remote-not-connected" })
            message:fragment({ "fa.spidertron-press-to-link" })
         end
         Speech.speak(pindex, message:build())
      else
         -- Only add if focus is on a spidertron
         if cursortarget and cursortarget.type == "spider-vehicle" then
            -- Make sure selection array exists
            spidertrons = p.spidertron_remote_selection or {}
            -- Prevent duplicates
            local already_linked = false
            for _, s in ipairs(spidertrons) do
               if s == cursortarget then
                  already_linked = true
                  break
               end
            end
            if already_linked then
               Speech.speak(pindex, { "fa.spidertron-already-linked" })
            else
               table.insert(spidertrons, cursortarget)
               p.spidertron_remote_selection = spidertrons
               local message = Speech.new()
               if cursortarget.entity_label and cursortarget.entity_label ~= "" then
                  message:fragment({ "fa.spidertron-remote-linked-added-named", cursortarget.entity_label }) -- "Spidertron Alice added."
               else
                  message:fragment({ "fa.spidertron-remote-linked-added-unnamed" }) -- "Unlabeled spidertron added."
               end
               message:fragment({ "fa.spidertrons-connected", #p.spidertron_remote_selection })
               Speech.speak(pindex, message:build())
            end
         else
            Speech.speak(pindex, { "fa.spidertron-invalid-link-target" })
         end
      end
   elseif index == 2 then
      -- Clear all spidertrons
      if not clicked then
         local message = Speech.new()
         if spidertrons ~= nil and #spidertrons > 0 then
            message:fragment({ "fa.spidertron-clear-all-instructions" }) -- "Press [key] to remove all linked spidertrons."
         else
            message:fragment({ "fa.spidertron-clear-all-none" }) -- "No spidertrons are currently linked."
         end
         Speech.speak(pindex, message:build())
      else
         if spidertrons ~= nil and #spidertrons > 0 then
            -- Clear the list
            p.spidertron_remote_selection = {}
            Speech.speak(pindex, { "fa.spidertron-clear-all-confirm" }) -- "All spidertrons unlinked."
         else
            Speech.speak(pindex, { "fa.spidertron-clear-all-none" }) -- "No spidertrons to remove."
         end
      end
   elseif index == 3 then
      --Set the cursor position as the spidertron autopilot target
      if not clicked then
         Speech.speak(pindex, { "fa.spidertron-set-target" })
      else
         if p.spidertron_remote_selection == nil then
            Speech.speak(pindex, { "fa.spidertron-link-first-move" })
         else
            for _, s in ipairs(p.spidertron_remote_selection) do
               s.autopilot_destination = cursor
            end
            Speech.speak(pindex, {
               "fa.spidertrons-sent-to-coords",
               #p.spidertron_remote_selection,
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
         if p.spidertron_remote_selection == nil then
            Speech.speak(pindex, { "fa.spidertron-link-first-move" })
         else
            for _, s in ipairs(p.spidertron_remote_selection) do
               s.add_autopilot_destination(cursor)
            end
            Speech.speak(pindex, {
               "fa.spidertrons-added-coords",
               tostring(math.floor(cursor.x)),
               tostring(math.floor(cursor.y)),
               #p.spidertron_remote_selection,
            })
         end
      end
   elseif index == 5 then
      --Set the spidertron autopilot to follow the selected entity
      if not clicked then
         Speech.speak(pindex, { "fa.spidertron-follow-entity" })
      else
         if p.spidertron_remote_selection ~= nil then
            for _, s in ipairs(p.spidertron_remote_selection) do
               s.follow_target = cursortarget
            end
            Speech.speak(pindex, { "fa.spidertron-started-following", #p.spidertron_remote_selection })
         else
            Speech.speak(pindex, { "fa.spidertron-link-required" })
         end
      end
   end
end
local SPIDER_MENU_LENGTH = 5

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
