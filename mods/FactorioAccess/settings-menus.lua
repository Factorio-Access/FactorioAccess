--Here: Functions relating to mod settings menus
--Does not include event handlers directly, but can have functions called by them.

function fa_settings_top_menu_open(pindex)
   --Load menu data
   local main_menu_data = players[pindex].fa_settings_top_menu
   if main_menu_data == nil then
      main_menu_data = {
      index = 0
      }
      players[pindex].fa_settings_top_menu = main_menu_data
   end

   --Set the player menu tracker to this menu
   players[pindex].menu = "fa_settings_top_menu"
   players[pindex].in_menu = true
   players[pindex].move_queue = {}
   
   --Reset the menu line index to 0
   players[pindex].fa_settings_top_menu.index = 0
   
   --Play sound
   game.get_player(pindex).play_sound{path = "Open-Inventory-Sound"}
   
   --Load menu 
   fa_settings_top_menu(pindex, players[pindex].fa_settings_top_menu.index, false)
end

--[[
   Settings top menu
   0. About this menu and instructions
   1. Mod controls list (read only) [All controls are listed directly in game]
   2. Mod preferences [Mod settings that affect presentation but have minimal gameplay changes, e.g. chest row length]
   3. Vanilla preferences [API-accessible preferences that match those found in the vanilla menus, if any ]
   4. Advanced settings [Settings that can significantly impact gameplay]
   5. About
]]
function fa_settings_top_menu(pindex, menu_index, clicked)--****WIP
   local index = menu_index
   
   if index == 0 then
      --About this menu and instructions
      printout("Mod settings menu ".. get_network_name(port)
      .. ", Press 'W' and 'S' to navigate options, press 'LEFT BRACKET' to select an option or press 'E' to exit this menu.", pindex)
   elseif index == 1 then
      --Mod controls list (read only) [All controls are listed directly in game]
      if not clicked then
         printout("Mod controls menu (read only)", pindex)
      else
         --***
      end
   elseif index == 2 then
      -- Mod preferences [Mod settings that affect presentation but have minimal gameplay changes, e.g. chest row length]
      if not clicked then
         printout("Mod preferences", pindex)
      else
         --***
      end
   end
end
SETTINGS_TOP_MENU_LENGTH = 2

function fa_mod_controls_menu_open(pindex)
   --Load menu data
   local menu_data = players[pindex].fa_mod_controls_menu
   if menu_data == nil then
      menu_data = {
      index = 0,
      load_mod_controls_list(pindex)
      }
      players[pindex].fa_mod_controls_menu = menu_data
   end

   --Set the player menu tracker to this menu
   players[pindex].menu = "fa_mod_controls_menu"
   players[pindex].in_menu = true
   
   --Reset the menu line index to 0
   players[pindex].fa_mod_controls_menu.index = 0
   
   --Play sound
   game.get_player(pindex).play_sound{path = "Open-Inventory-Sound"}
   
   --Load menu 
   fa_mod_controls_menu(pindex, players[pindex].fa_mod_controls_menu.index, false)
end

function load_mod_controls_list(pindex)--****todo, like loading tutorial strings for the help system

end

--[[
   Mod controls menu
   0. About this menu and instructions
   X. Controls, grouped by chapters
]]
function fa_mod_controls_menu(pindex, menu_index, clicked, pg_up, pg_down)
   local index = menu_index
   
   if index == 0 then
      --About this menu and instructions
      printout("Mod controls menu, with a read-only list of mod controls ".. get_network_name(port)
      .. ", Press 'W' and 'S' to navigate options, press 'LEFT BRACKET' to select an option or press 'E' to exit this menu.", pindex)
   elseif index == 1 then
      --...
      if not clicked then
         printout("Setting 1", pindex)
      else
         --***
      end
   elseif index == 2 then
      --...
      if not clicked then
         printout("Setting 2", pindex)
      else
         --***
      end
   end
end
MOD_CONTROLS_MENU_LENGTH = 2

function fa_mod_preferences_menu_open(pindex)
   --Load menu data
   local menu_data = players[pindex].fa_mod_preferences_menu
   if menu_data == nil then
      menu_data = {
      index = 0
      }
      players[pindex].fa_mod_preferences_menu = menu_data
   end

   --Set the player menu tracker to this menu
   players[pindex].menu = "fa_mod_preferences_menu"
   players[pindex].in_menu = true
   
   --Reset the menu line index to 0
   players[pindex].fa_mod_preferences_menu.index = 0
   
   --Play sound
   game.get_player(pindex).play_sound{path = "Open-Inventory-Sound"}
   
   --Load menu 
   fa_mod_preferences_menu(pindex, players[pindex].fa_mod_preferences_menu.index, false)
end

--[[
   Mod preferences menu
   0. About this menu and instructions
   1. Pref 1
   2. Pref 2
]]
function fa_mod_preferences_menu(pindex, menu_index, clicked, pg_up, pg_down)
   local index = menu_index
   
   if index == 0 then
      --About this menu and instructions
      printout("Mod preferences menu, with settings that affect interface but have minimal gameplay changes ".. get_network_name(port)
      .. ", Press 'W' and 'S' to navigate options, press 'LEFT BRACKET' to select an option or press 'E' to exit this menu.", pindex)
   elseif index == 1 then
      --...
      if not clicked then
         printout("Setting 1", pindex)
      else
         --***
      end
   elseif index == 2 then
      --...
      if not clicked then
         printout("Setting 2", pindex)
      else
         --***
      end
   end
end
MOD_PREFERENCES_MENU_LENGTH = 2

