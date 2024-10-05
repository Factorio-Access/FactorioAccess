--Here: Fast travel, structure travel, etc.
local fa_utils = require("scripts.fa-utils")
local fa_graphics = require("scripts.graphics")
local fa_mouse = require("scripts.mouse")
local fa_teleport = require("scripts.teleport")

local mod = {}

function mod.fast_travel_menu_open(pindex)
   local p = game.get_player(pindex)
   if p.ticks_to_respawn ~= nil then return end
   if players[pindex].in_menu == false and game.get_player(pindex).opened == nil then
      game.get_player(pindex).selected = nil

      players[pindex].menu = "travel"
      players[pindex].in_menu = true
      players[pindex].move_queue = {}
      players[pindex].travel.index = { x = 1, y = 0 }
      players[pindex].travel.creating = false
      players[pindex].travel.renaming = false
      players[pindex].travel.describing = false
      printout(
         "Fast travel, Navigate up and down with W and S to select a fast travel location, and jump to it with LEFT BRACKET.  Alternatively, select an option by navigating left and right with A and D.",
         pindex
      )
      local screen = game.get_player(pindex).gui.screen
      local frame = screen.add({ type = "frame", name = "travel" })
      frame.bring_to_front()
      frame.force_auto_center()
      frame.focus()
      game.get_player(pindex).opened = frame
      game.get_player(pindex).selected = nil
   elseif players[pindex].in_menu or game.get_player(pindex).opened ~= nil then
      printout("Another menu is open.", pindex)
   end
end

--Reads the selected fast travel menu slot
function mod.read_fast_travel_slot(pindex)
   if #players[pindex].travel == 0 then
      printout("Move towards the right and select Create to get started.", pindex)
   else
      local entry = players[pindex].travel[players[pindex].travel.index.y]
      printout(
         entry.name
            .. " at "
            .. math.floor(entry.position.x)
            .. ", "
            .. math.floor(entry.position.y)
            .. ", cursor moved.",
         pindex
      )
      players[pindex].cursor_pos = fa_utils.center_of_tile(entry.position)
      fa_graphics.draw_cursor_highlight(pindex, nil, "train-visualization")
   end
end

function mod.fast_travel_menu_click(pindex)
   local p = game.get_player(pindex)
   if players[pindex].travel.input_box then players[pindex].travel.input_box.destroy() end
   if #global.players[pindex].travel == 0 and players[pindex].travel.index.x < TRAVEL_MENU_LENGTH then
      printout("Move towards the right and select Create New to get started.", pindex)
   elseif players[pindex].travel.index.y == 0 and players[pindex].travel.index.x < TRAVEL_MENU_LENGTH then
      printout(
         "Navigate up and down to select a fast travel point, then press LEFT BRACKET to get there quickly.",
         pindex
      )
   elseif players[pindex].travel.index.x == 1 then --Travel
      if p.vehicle then
         printout("Cannot teleport from inside a vehicle", pindex)
         return
      end
      local success = fa_teleport.teleport_to_closest(
         pindex,
         global.players[pindex].travel[players[pindex].travel.index.y].position,
         false,
         false
      )
      if success and players[pindex].cursor then
         players[pindex].cursor_pos =
            table.deepcopy(global.players[pindex].travel[players[pindex].travel.index.y].position)
      else
         players[pindex].cursor_pos =
            fa_utils.offset_position(players[pindex].position, players[pindex].player_direction, 1)
      end
      fa_graphics.sync_build_cursor_graphics(pindex)
      game.get_player(pindex).opened = nil

      if not refresh_player_tile(pindex) then
         printout("Tile out of range", pindex)
         return
      end

      --Update cursor highlight
      local ent = game.get_player(pindex).selected
      if ent and ent.valid then
         fa_graphics.draw_cursor_highlight(pindex, ent, nil)
      else
         fa_graphics.draw_cursor_highlight(pindex, nil, nil)
      end
   elseif players[pindex].travel.index.x == 2 then --Read description
      local desc = players[pindex].travel[players[pindex].travel.index.y].description
      if desc == nil or desc == "" then
         desc = "No description"
         players[pindex].travel[players[pindex].travel.index.y].description = desc
      end
      printout(desc, pindex)
   elseif players[pindex].travel.index.x == 3 then --Rename
      printout(
         "Type in a new name for this fast travel point, then press 'ENTER' to confirm, or press 'ESC' to cancel.",
         pindex
      )
      players[pindex].travel.renaming = true
      local frame = game.get_player(pindex).gui.screen["travel"]
      players[pindex].travel.input_box = frame.add({ type = "textfield", name = "input" })
      local input = players[pindex].travel.input_box
      input.focus()
      input.select(1, 0)
   elseif players[pindex].travel.index.x == 4 then --Rewrite description
      local desc = players[pindex].travel[players[pindex].travel.index.y].description
      if desc == nil then
         desc = ""
         players[pindex].travel[players[pindex].travel.index.y].description = desc
      end
      printout("Type in the new description text, then press 'ENTER' to confirm, or press 'ESC' to cancel.", pindex)
      players[pindex].travel.describing = true
      local frame = game.get_player(pindex).gui.screen["travel"]
      players[pindex].travel.input_box = frame.add({ type = "textfield", name = "input" })
      local input = players[pindex].travel.input_box
      input.focus()
      input.select(1, 0)
   elseif players[pindex].travel.index.x == 5 then --Relocate to current character position
      players[pindex].travel[players[pindex].travel.index.y].position =
         fa_utils.center_of_tile(players[pindex].position)
      printout(
         "Relocated point "
            .. players[pindex].travel[players[pindex].travel.index.y].name
            .. " to "
            .. math.floor(players[pindex].position.x)
            .. ", "
            .. math.floor(players[pindex].position.y),
         pindex
      )
      players[pindex].cursor_pos = players[pindex].position
      fa_graphics.draw_cursor_highlight(pindex)
   elseif players[pindex].travel.index.x == 6 then --Broadcast
      --Prevent duplicating by checking if this point was last broadcasted
      local this_point = players[pindex].travel[players[pindex].travel.index.y]
      if
         this_point.name == players[pindex].travel.last_broadcasted_name
         and this_point.description == players[pindex].travel.last_broadcasted_description
         and this_point.position == players[pindex].travel.last_broadcasted_position
      then
         printout("Error: Cancelled repeated broadcast. ", pindex)
         return
      end
      --Broadcast it by adding a copy of it to all players in the same force (except for repeating this player)
      local players = global.players
      for other_pindex, player in pairs(players) do
         if
            game.get_player(pindex).force.name == game.get_player(other_pindex).force.name and pindex ~= other_pindex
         then
            table.insert(players[other_pindex].travel, {
               name = this_point.name,
               position = this_point.position,
               description = this_point.description,
            })
            table.sort(players[other_pindex].travel, function(k1, k2)
               return k1.name < k2.name
            end)
         end
      end
      --Report the action and note the last broadcasted point
      printout("Broadcasted point " .. this_point.name, pindex)
      players[pindex].travel.last_broadcasted_name = this_point.name
      players[pindex].travel.last_broadcasted_description = this_point.description
      players[pindex].travel.last_broadcasted_position = this_point.position
   elseif players[pindex].travel.index.x == 7 then --Delete
      printout("Deleted " .. global.players[pindex].travel[players[pindex].travel.index.y].name, pindex)
      table.remove(global.players[pindex].travel, players[pindex].travel.index.y)
      players[pindex].travel.x = 1
      players[pindex].travel.index.y = players[pindex].travel.index.y - 1
   elseif players[pindex].travel.index.x == 8 then --Create new
      printout(
         "Type in a name for this fast travel point, then press 'ENTER' to confirm, or press 'ESC' to cancel.",
         pindex
      )
      players[pindex].travel.creating = true
      local frame = game.get_player(pindex).gui.screen["travel"]
      players[pindex].travel.input_box = frame.add({ type = "textfield", name = "input" })
      local input = players[pindex].travel.input_box
      input.focus()
      input.select(1, 0)
   end
end
TRAVEL_MENU_LENGTH = 8

function mod.fast_travel_menu_up(pindex)
   if players[pindex].travel.index.y > 1 then
      game.get_player(pindex).play_sound({ path = "Inventory-Move" })
      players[pindex].travel.index.y = players[pindex].travel.index.y - 1
   else
      players[pindex].travel.index.y = 1
      game.get_player(pindex).play_sound({ path = "inventory-edge" })
   end
   players[pindex].travel.index.x = 1
   mod.read_fast_travel_slot(pindex)
end

function mod.fast_travel_menu_down(pindex)
   if players[pindex].travel.index.y < #players[pindex].travel then
      game.get_player(pindex).play_sound({ path = "Inventory-Move" })
      players[pindex].travel.index.y = players[pindex].travel.index.y + 1
   else
      players[pindex].travel.index.y = #players[pindex].travel
      game.get_player(pindex).play_sound({ path = "inventory-edge" })
   end
   players[pindex].travel.index.x = 1
   mod.read_fast_travel_slot(pindex)
end

function mod.fast_travel_menu_right(pindex)
   if players[pindex].travel.index.x < TRAVEL_MENU_LENGTH then
      game.get_player(pindex).play_sound({ path = "Inventory-Move" })
      players[pindex].travel.index.x = players[pindex].travel.index.x + 1
   else
      game.get_player(pindex).play_sound({ path = "inventory-edge" })
   end
   if players[pindex].travel.index.x == 1 then
      printout("Travel", pindex)
   elseif players[pindex].travel.index.x == 2 then
      printout("Read description", pindex)
   elseif players[pindex].travel.index.x == 3 then
      printout("Rename", pindex)
   elseif players[pindex].travel.index.x == 4 then
      printout("Rewrite description", pindex)
   elseif players[pindex].travel.index.x == 5 then
      printout("Relocate to current character position", pindex)
   elseif players[pindex].travel.index.x == 6 then
      printout("Broadcast to team players", pindex)
   elseif players[pindex].travel.index.x == 7 then
      printout("Delete", pindex)
   elseif players[pindex].travel.index.x == 8 then
      printout("Create New", pindex)
   end
end

function mod.fast_travel_menu_left(pindex)
   if players[pindex].travel.index.x > 1 then
      game.get_player(pindex).play_sound({ path = "Inventory-Move" })
      players[pindex].travel.index.x = players[pindex].travel.index.x - 1
   else
      game.get_player(pindex).play_sound({ path = "inventory-edge" })
   end
   if players[pindex].travel.index.x == 1 then
      printout("Travel", pindex)
   elseif players[pindex].travel.index.x == 2 then
      printout("Read description", pindex)
   elseif players[pindex].travel.index.x == 3 then
      printout("Rename", pindex)
   elseif players[pindex].travel.index.x == 4 then
      printout("Rewrite description", pindex)
   elseif players[pindex].travel.index.x == 5 then
      printout("Relocate to current character position", pindex)
   elseif players[pindex].travel.index.x == 6 then
      printout("Broadcast to team players", pindex)
   elseif players[pindex].travel.index.x == 7 then
      printout("Delete", pindex)
   elseif players[pindex].travel.index.x == 8 then
      printout("Create New", pindex)
   end
end

function mod.fast_travel_menu_close(pindex)
   if game.get_player(pindex).gui.screen["travel"] then game.get_player(pindex).gui.screen["travel"].destroy() end
   players[pindex].menu = "none"
   players[pindex].in_menu = false
end

return mod
