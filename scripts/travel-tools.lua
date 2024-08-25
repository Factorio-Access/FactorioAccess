--Here: Fast travel, structure travel, etc.
local fa_utils = require("scripts.fa-utils")
local fa_graphics = require("scripts.graphics")
local fa_mouse = require("scripts.mouse")
local fa_scanner = require("scripts.scanner")
local fa_teleport = require("scripts.teleport")

local mod = {}

--Structure travel: Moves the player cursor in the input direction.
function mod.move_cursor_structure(pindex, dir)
   local direction = players[pindex].structure_travel.direction
   local adjusted = {}
   adjusted[0] = "north"
   adjusted[2] = "east"
   adjusted[4] = "south"
   adjusted[6] = "west"

   local network = players[pindex].structure_travel.network
   local current = players[pindex].structure_travel.current
   local index = players[pindex].structure_travel.index
   if direction == "none" then
      if #network[current][adjusted[(0 + dir) % 8]] > 0 then
         players[pindex].structure_travel.direction = adjusted[(0 + dir) % 8]
         players[pindex].structure_travel.index = 1
         local index = players[pindex].structure_travel.index
         local dx = network[current][adjusted[(0 + dir) % 8]][index].dx
         local dy = network[current][adjusted[(0 + dir) % 8]][index].dy
         local description = ""
         if math.floor(math.abs(dx) + 0.5) ~= 0 then
            if dx < 0 then
               description = description .. math.floor(math.abs(dx) + 0.5) .. " " .. "tiles west, "
            elseif dx > 0 then
               description = description .. math.floor(math.abs(dx) + 0.5) .. " " .. "tiles east, "
            end
         end
         if math.floor(math.abs(dy) + 0.5) ~= 0 then
            if dy < 0 then
               description = description .. math.floor(math.abs(dy) + 0.5) .. " " .. "tiles north, "
            elseif dy > 0 then
               description = description .. math.floor(math.abs(dy) + 0.5) .. " " .. "tiles south, "
            end
         end
         local ent = network[network[current][adjusted[(0 + dir) % 8]][index].num]
         if ent.ent.valid then
            fa_graphics.draw_cursor_highlight(pindex, ent.ent, nil)
            fa_mouse.move_mouse_pointer(ent.ent.position, pindex)
            players[pindex].cursor_pos = ent.ent.position
            --Case 1: Proposing a new structure
            printout(
               "To "
                  .. ent.name
                  .. " "
                  .. fa_scanner.ent_extra_list_info(ent.ent, pindex, true)
                  .. ", "
                  .. description
                  .. ", "
                  .. index
                  .. " of "
                  .. #network[current][adjusted[(0 + dir) % 8]],
               pindex
            )
         else
            printout("Missing " .. ent.name .. " " .. description, pindex)
         end
      else
         printout("There are no buildings directly " .. adjusted[(0 + dir) % 8] .. " of this one.", pindex)
      end
   elseif direction == adjusted[(4 + dir) % 8] then
      players[pindex].structure_travel.direction = "none"
      local description = ""
      if #network[current].north > 0 then
         description = description .. ", " .. #network[current].north .. " connections north,"
      end
      if #network[current].east > 0 then
         description = description .. ", " .. #network[current].east .. " connections east,"
      end
      if #network[current].south > 0 then
         description = description .. ", " .. #network[current].south .. " connections south,"
      end
      if #network[current].west > 0 then
         description = description .. ", " .. #network[current].west .. " connections west,"
      end
      if description == "" then description = "No nearby buildings." end
      local ent = network[current]
      if ent.ent.valid then
         fa_graphics.draw_cursor_highlight(pindex, ent.ent, nil)
         fa_mouse.move_mouse_pointer(ent.ent.position, pindex)
         players[pindex].cursor_pos = ent.ent.position
         --Case 2: Returning to the current structure
         printout(
            "Back at "
               .. ent.name
               .. " "
               .. fa_scanner.ent_extra_list_info(ent.ent, pindex, true)
               .. ", "
               .. description,
            pindex
         )
      else
         printout("Missing " .. ent.name .. " " .. description, pindex)
      end
   elseif direction == adjusted[(0 + dir) % 8] then
      players[pindex].structure_travel.direction = "none"
      players[pindex].structure_travel.current = network[current][adjusted[(0 + dir) % 8]][index].num
      local current = players[pindex].structure_travel.current

      local description = ""
      if #network[current].north > 0 then
         description = description .. ", " .. #network[current].north .. " connections north,"
      end
      if #network[current].east > 0 then
         description = description .. ", " .. #network[current].east .. " connections east,"
      end
      if #network[current].south > 0 then
         description = description .. ", " .. #network[current].south .. " connections south,"
      end
      if #network[current].west > 0 then
         description = description .. ", " .. #network[current].west .. " connections west,"
      end
      if description == "" then description = "No nearby buildings." end
      local ent = network[current]
      if ent.ent.valid then
         fa_graphics.draw_cursor_highlight(pindex, ent.ent, nil)
         fa_mouse.move_mouse_pointer(ent.ent.position, pindex)
         players[pindex].cursor_pos = ent.ent.position
         --Case 3: Moved to the new structure
         printout(
            "Now at " .. ent.name .. " " .. fa_scanner.ent_extra_list_info(ent.ent, pindex, true) .. ", " .. description,
            pindex
         )
      else
         printout("Missing " .. ent.name .. " " .. description, pindex)
      end
   elseif direction == adjusted[(2 + dir) % 8] or direction == adjusted[(6 + dir) % 8] then
      if (dir == 0 or dir == 6) and index > 1 then
         game.get_player(pindex).play_sound({ path = "Inventory-Move" })
         players[pindex].structure_travel.index = index - 1
      elseif (dir == 2 or dir == 4) and index < #network[current][direction] then
         game.get_player(pindex).play_sound({ path = "Inventory-Move" })
         players[pindex].structure_travel.index = index + 1
      end
      local index = players[pindex].structure_travel.index
      local dx = network[current][direction][index].dx
      local dy = network[current][direction][index].dy
      local description = ""
      if math.floor(math.abs(dx) + 0.5) ~= 0 then
         if dx < 0 then
            description = description .. math.floor(math.abs(dx) + 0.5) .. " " .. "tiles west, "
         elseif dx > 0 then
            description = description .. math.floor(math.abs(dx) + 0.5) .. " " .. "tiles east, "
         end
      end
      if math.floor(math.abs(dy) + 0.5) ~= 0 then
         if dy < 0 then
            description = description .. math.floor(math.abs(dy) + 0.5) .. " " .. "tiles north, "
         elseif dy > 0 then
            description = description .. math.floor(math.abs(dy) + 0.5) .. " " .. "tiles south, "
         end
      end
      local ent = network[network[current][direction][index].num]
      if ent.ent.valid then
         fa_graphics.draw_cursor_highlight(pindex, ent.ent, nil)
         fa_mouse.move_mouse_pointer(ent.ent.position, pindex)
         players[pindex].cursor_pos = ent.ent.position
         --Case 4: Propose a new structure within the same direction
         printout(
            "To "
               .. ent.name
               .. " "
               .. fa_scanner.ent_extra_list_info(ent.ent, pindex, true)
               .. ", "
               .. description
               .. ", "
               .. index
               .. " of "
               .. #network[current][direction],
            pindex
         )
      else
         printout("Missing " .. ent.name .. " " .. description, pindex)
      end
   end
end

--Structure travel: Creates the building network that is traveled during structure travel.
function mod.compile_building_network(ent, radius_in, pindex)
   local radius = radius_in
   local ents = ent.surface.find_entities_filtered({ position = ent.position, radius = radius })
   game.get_player(pindex).print(#ents .. " ents at first pass")
   if #ents < 100 then
      radius = radius_in * 2
      ents = ent.surface.find_entities_filtered({ position = ent.position, radius = radius })
   elseif #ents > 2000 then
      radius = math.floor(radius_in / 4)
      ents = ent.surface.find_entities_filtered({ position = ent.position, radius = radius })
   elseif #ents > 1000 then
      radius = math.floor(radius_in / 2)
      ents = ent.surface.find_entities_filtered({ position = ent.position, radius = radius })
   end
   rendering.draw_circle({
      color = { 1, 1, 1 },
      radius = radius,
      width = 20,
      target = ent.position,
      surface = ent.surface,
      draw_on_ground = true,
      time_to_live = 300,
   })
   --game.get_player(pindex).print(#ents .. " ents at start")
   local adj = { hor = {}, vert = {} }
   local PQ = {}
   local result = {}
   --game.get_player(pindex).print("checkpoint 0")
   table.insert(ents, 1, ent)
   for i = #ents, 1, -1 do
      local row = ents[i]
      if row.unit_number ~= nil and (row.prototype.is_building or row.unit_number == ent.unit_number) then
         adj.hor[row.unit_number] = {}
         adj.vert[row.unit_number] = {}
         result[row.unit_number] = {
            ent = row,
            name = row.name,
            position = table.deepcopy(row.position),
            north = {},
            east = {},
            south = {},
            west = {},
         }
      else
         table.remove(ents, i)
      end
   end

   game.get_player(pindex).print(#ents .. " buildings found") --**keep here intentionally
   --game.get_player(pindex).print("checkpoint 1")

   for i, row in pairs(ents) do
      for i1, col in pairs(ents) do
         if adj.hor[row.unit_number][col.unit_number] == nil then
            if row.unit_number == col.unit_number then
               adj.hor[row.unit_number][col.unit_number] = true
               adj.vert[row.unit_number][col.unit_number] = true
            else
               adj.hor[row.unit_number][col.unit_number] = false
               adj.vert[row.unit_number][col.unit_number] = false
               adj.hor[col.unit_number][row.unit_number] = false
               adj.vert[col.unit_number][row.unit_number] = false

               table.insert(PQ, {
                  source = row,
                  dest = col,
                  dx = col.position.x - row.position.x,
                  dy = col.position.y - row.position.y,
                  man = math.abs(col.position.x - row.position.x) + math.abs(col.position.y - row.position.y),
               })
            end
         end
      end
   end
   --game.get_player(pindex).print("checkpoint 2")
   table.sort(PQ, function(k1, k2)
      return k1.man > k2.man
   end)
   --game.get_player(pindex).print("checkpoint 3, #PQ = " .. #PQ)--

   local entry = table.remove(PQ)
   local loop_count = 0
   while entry ~= nil and loop_count < #PQ * 2 do
      loop_count = loop_count + 1
      if math.abs(entry.dy) >= math.abs(entry.dx) then
         if not adj.vert[entry.source.unit_number][entry.dest.unit_number] then
            for i, explored in pairs(adj.vert[entry.source.unit_number]) do
               adj.vert[entry.source.unit_number][i] = (explored or adj.vert[entry.dest.unit_number][i])
            end
            for i, row in pairs(adj.vert) do
               if adj.vert[entry.source.unit_number][i] then adj.vert[i] = adj.vert[entry.source.unit_number] end
            end
            if entry.dy > 0 then
               table.insert(result[entry.source.unit_number].south, {
                  num = entry.dest.unit_number,
                  dx = entry.dx,
                  dy = entry.dy,
               })
               table.insert(result[entry.dest.unit_number].north, {
                  num = entry.source.unit_number,
                  dx = entry.dx * -1,
                  dy = entry.dy * -1,
               })
            else
               table.insert(result[entry.source.unit_number].north, {
                  num = entry.dest.unit_number,
                  dx = entry.dx,
                  dy = entry.dy,
               })
               table.insert(result[entry.dest.unit_number].south, {
                  num = entry.source.unit_number,
                  dx = entry.dx * -1,
                  dy = entry.dy * -1,
               })
            end
         end
      end
      if math.abs(entry.dx) >= math.abs(entry.dy) then
         if not adj.hor[entry.source.unit_number][entry.dest.unit_number] then
            for i, explored in pairs(adj.hor[entry.source.unit_number]) do
               adj.hor[entry.source.unit_number][i] = explored or adj.hor[entry.dest.unit_number][i]
            end
            for i, row in pairs(adj.hor) do
               if adj.hor[entry.source.unit_number][i] then adj.hor[i] = adj.hor[entry.source.unit_number] end
            end
            if entry.dx > 0 then
               table.insert(result[entry.source.unit_number].east, {
                  num = entry.dest.unit_number,
                  dx = entry.dx,
                  dy = entry.dy,
               })
               table.insert(result[entry.dest.unit_number].west, {
                  num = entry.source.unit_number,
                  dx = entry.dx * -1,
                  dy = entry.dy * -1,
               })
            else
               table.insert(result[entry.source.unit_number].west, {
                  num = entry.dest.unit_number,
                  dx = entry.dx,
                  dy = entry.dy,
               })
               table.insert(result[entry.dest.unit_number].east, {
                  num = entry.source.unit_number,
                  dx = entry.dx * -1,
                  dy = entry.dy * -1,
               })
            end
         end
      end
      entry = table.remove(PQ)
   end
   --game.get_player(pindex).print("checkpoint 4, loop count: " .. loop_count )
   return result
end

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

function mod.structure_travel_menu_close(pindex)
   if game.get_player(pindex).gui.screen["structure-travel"] then
      game.get_player(pindex).gui.screen["structure-travel"].destroy()
   end
   players[pindex].menu = "none"
   players[pindex].in_menu = false
end

return mod
