--Here: Fast travel, structure travel, etc.
local FaUtils = require("scripts.fa-utils")
local Graphics = require("scripts.graphics")
local Mouse = require("scripts.mouse")
local Teleport = require("scripts.teleport")
local UiRouter = require("scripts.ui.router")
local Viewpoint = require("scripts.viewpoint")

local mod = {}
local TRAVEL_MENU_LENGTH = 8

function mod.fast_travel_menu_open(pindex)
   local router = UiRouter.get_router(pindex)

   local p = game.get_player(pindex)
   if p.ticks_to_respawn ~= nil then return end
   if not router:is_ui_open() and game.get_player(pindex).opened == nil then
      game.get_player(pindex).selected = nil

      router:open_ui(UiRouter.UI_NAMES.TRAVEL)
      storage.players[pindex].move_queue = {}
      storage.players[pindex].travel.index = { x = 1, y = 0 }
      storage.players[pindex].travel.creating = false
      storage.players[pindex].travel.renaming = false
      storage.players[pindex].travel.describing = false
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
   elseif router:is_ui_open() or game.get_player(pindex).opened ~= nil then
      printout({ "fa.travel-another-menu-open" }, pindex)
   end
end

--Reads the selected fast travel menu slot
function mod.read_fast_travel_slot(pindex)
   if #storage.players[pindex].travel == 0 then
      printout({ "fa.travel-move-right-create" }, pindex)
   else
      local vp = Viewpoint.get_viewpoint(pindex)
      local entry = storage.players[pindex].travel[storage.players[pindex].travel.index.y]
      printout(
         entry.name
            .. " at "
            .. math.floor(entry.position.x)
            .. ", "
            .. math.floor(entry.position.y)
            .. ", cursor moved.",
         pindex
      )
      vp:set_cursor_pos(FaUtils.center_of_tile(entry.position))
      Graphics.draw_cursor_highlight(pindex, nil, "train-visualization")
   end
end

function mod.fast_travel_menu_click(pindex)
   local p = game.get_player(pindex)
   local vp = Viewpoint.get_viewpoint(pindex)
   if storage.players[pindex].travel.input_box then storage.players[pindex].travel.input_box.destroy() end
   if #storage.players[pindex].travel == 0 and storage.players[pindex].travel.index.x < TRAVEL_MENU_LENGTH then
      printout({ "fa.travel-move-right-create-new" }, pindex)
   elseif
      storage.players[pindex].travel.index.y == 0 and storage.players[pindex].travel.index.x < TRAVEL_MENU_LENGTH
   then
      printout(
         "Navigate up and down to select a fast travel point, then press LEFT BRACKET to get there quickly.",
         pindex
      )
   elseif storage.players[pindex].travel.index.x == 1 then --Travel
      if p.vehicle then
         printout({ "fa.travel-cannot-teleport-vehicle" }, pindex)
         return
      end
      local success = Teleport.teleport_to_closest(
         pindex,
         storage.players[pindex].travel[storage.players[pindex].travel.index.y].position,
         false,
         false
      )
      if success and vp:get_cursor_enabled() then
         vp:set_cursor_pos(
            table.deepcopy(storage.players[pindex].travel[storage.players[pindex].travel.index.y].position)
         )
      else
         vp:set_cursor_pos(
            FaUtils.offset_position_legacy(
               storage.players[pindex].position,
               storage.players[pindex].player_direction,
               1
            )
         )
      end
      Graphics.sync_build_cursor_graphics(pindex)
      game.get_player(pindex).opened = nil

      if not refresh_player_tile(pindex) then
         printout({ "fa.travel-tile-out-of-range" }, pindex)
         return
      end

      --Update cursor highlight
      local ent = game.get_player(pindex).selected
      if ent and ent.valid then
         Graphics.draw_cursor_highlight(pindex, ent, nil)
      else
         Graphics.draw_cursor_highlight(pindex, nil, nil)
      end
   elseif storage.players[pindex].travel.index.x == 2 then --Read description
      local desc = storage.players[pindex].travel[storage.players[pindex].travel.index.y].description
      if desc == nil or desc == "" then
         desc = "No description"
         storage.players[pindex].travel[storage.players[pindex].travel.index.y].description = desc
      end
      printout(desc, pindex)
   elseif storage.players[pindex].travel.index.x == 3 then --Rename
      printout(
         "Type in a new name for this fast travel point, then press 'ENTER' to confirm, or press 'ESC' to cancel.",
         pindex
      )
      storage.players[pindex].travel.renaming = true
      local frame = game.get_player(pindex).gui.screen["travel"]
      storage.players[pindex].travel.input_box = frame.add({ type = "textfield", name = "input" })
      local input = storage.players[pindex].travel.input_box
      input.focus()
      input.select(1, 0)
   elseif storage.players[pindex].travel.index.x == 4 then --Rewrite description
      local desc = storage.players[pindex].travel[storage.players[pindex].travel.index.y].description
      if desc == nil then
         desc = ""
         storage.players[pindex].travel[storage.players[pindex].travel.index.y].description = desc
      end
      printout({ "fa.travel-type-new-description" }, pindex)
      storage.players[pindex].travel.describing = true
      local frame = game.get_player(pindex).gui.screen["travel"]
      storage.players[pindex].travel.input_box = frame.add({ type = "textfield", name = "input" })
      local input = storage.players[pindex].travel.input_box
      input.focus()
      input.select(1, 0)
   elseif storage.players[pindex].travel.index.x == 5 then --Relocate to current character position
      storage.players[pindex].travel[storage.players[pindex].travel.index.y].position =
         FaUtils.center_of_tile(storage.players[pindex].position)
      printout({
         "fa.travel-relocated-point",
         storage.players[pindex].travel[storage.players[pindex].travel.index.y].name,
         tostring(math.floor(storage.players[pindex].position.x)),
         tostring(math.floor(storage.players[pindex].position.y)),
      }, pindex)
      local position = storage.players[pindex].position
      vp:set_cursor_pos({ x = position.x, y = position.y })
      Graphics.draw_cursor_highlight(pindex)
   elseif storage.players[pindex].travel.index.x == 6 then --Broadcast
      --Prevent duplicating by checking if this point was last broadcasted
      local this_point = storage.players[pindex].travel[storage.players[pindex].travel.index.y]
      if
         this_point.name == storage.players[pindex].travel.last_broadcasted_name
         and this_point.description == storage.players[pindex].travel.last_broadcasted_description
         and this_point.position == storage.players[pindex].travel.last_broadcasted_position
      then
         printout({ "fa.travel-error-cancelled-broadcast" }, pindex)
         return
      end
      --Broadcast it by adding a copy of it to all players in the same force (except for repeating this player)
      local players = storage.players
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
      printout({ "fa.travel-broadcasted-point", this_point.name }, pindex)
      storage.players[pindex].travel.last_broadcasted_name = this_point.name
      storage.players[pindex].travel.last_broadcasted_description = this_point.description
      storage.players[pindex].travel.last_broadcasted_position = this_point.position
   elseif storage.players[pindex].travel.index.x == 7 then --Delete
      printout(
         { "fa.travel-deleted-point", storage.players[pindex].travel[storage.players[pindex].travel.index.y].name },
         pindex
      )
      table.remove(storage.players[pindex].travel, storage.players[pindex].travel.index.y)
      storage.players[pindex].travel.x = 1
      storage.players[pindex].travel.index.y = storage.players[pindex].travel.index.y - 1
   elseif storage.players[pindex].travel.index.x == 8 then --Create new
      printout(
         "Type in a name for this fast travel point, then press 'ENTER' to confirm, or press 'ESC' to cancel.",
         pindex
      )
      storage.players[pindex].travel.creating = true
      local frame = game.get_player(pindex).gui.screen["travel"]
      storage.players[pindex].travel.input_box = frame.add({ type = "textfield", name = "input" })
      local input = storage.players[pindex].travel.input_box
      input.focus()
      input.select(1, 0)
   end
end

function mod.fast_travel_menu_up(pindex)
   if storage.players[pindex].travel.index.y > 1 then
      game.get_player(pindex).play_sound({ path = "Inventory-Move" })
      storage.players[pindex].travel.index.y = storage.players[pindex].travel.index.y - 1
   else
      storage.players[pindex].travel.index.y = 1
      game.get_player(pindex).play_sound({ path = "inventory-edge" })
   end
   storage.players[pindex].travel.index.x = 1
   mod.read_fast_travel_slot(pindex)
end

function mod.fast_travel_menu_down(pindex)
   if storage.players[pindex].travel.index.y < #storage.players[pindex].travel then
      game.get_player(pindex).play_sound({ path = "Inventory-Move" })
      storage.players[pindex].travel.index.y = storage.players[pindex].travel.index.y + 1
   else
      storage.players[pindex].travel.index.y = #storage.players[pindex].travel
      game.get_player(pindex).play_sound({ path = "inventory-edge" })
   end
   storage.players[pindex].travel.index.x = 1
   mod.read_fast_travel_slot(pindex)
end

function mod.fast_travel_menu_right(pindex)
   if storage.players[pindex].travel.index.x < TRAVEL_MENU_LENGTH then
      game.get_player(pindex).play_sound({ path = "Inventory-Move" })
      storage.players[pindex].travel.index.x = storage.players[pindex].travel.index.x + 1
   else
      game.get_player(pindex).play_sound({ path = "inventory-edge" })
   end
   if storage.players[pindex].travel.index.x == 1 then
      printout({ "fa.travel-menu-travel" }, pindex)
   elseif storage.players[pindex].travel.index.x == 2 then
      printout({ "fa.travel-menu-read-description" }, pindex)
   elseif storage.players[pindex].travel.index.x == 3 then
      printout({ "fa.travel-menu-rename" }, pindex)
   elseif storage.players[pindex].travel.index.x == 4 then
      printout({ "fa.travel-menu-rewrite-description" }, pindex)
   elseif storage.players[pindex].travel.index.x == 5 then
      printout({ "fa.travel-menu-relocate" }, pindex)
   elseif storage.players[pindex].travel.index.x == 6 then
      printout({ "fa.travel-menu-broadcast" }, pindex)
   elseif storage.players[pindex].travel.index.x == 7 then
      printout({ "fa.travel-menu-delete" }, pindex)
   elseif storage.players[pindex].travel.index.x == 8 then
      printout({ "fa.travel-menu-create-new" }, pindex)
   end
end

function mod.fast_travel_menu_left(pindex)
   if storage.players[pindex].travel.index.x > 1 then
      game.get_player(pindex).play_sound({ path = "Inventory-Move" })
      storage.players[pindex].travel.index.x = storage.players[pindex].travel.index.x - 1
   else
      game.get_player(pindex).play_sound({ path = "inventory-edge" })
   end
   if storage.players[pindex].travel.index.x == 1 then
      printout({ "fa.travel-menu-travel" }, pindex)
   elseif storage.players[pindex].travel.index.x == 2 then
      printout({ "fa.travel-menu-read-description" }, pindex)
   elseif storage.players[pindex].travel.index.x == 3 then
      printout({ "fa.travel-menu-rename" }, pindex)
   elseif storage.players[pindex].travel.index.x == 4 then
      printout({ "fa.travel-menu-rewrite-description" }, pindex)
   elseif storage.players[pindex].travel.index.x == 5 then
      printout({ "fa.travel-menu-relocate" }, pindex)
   elseif storage.players[pindex].travel.index.x == 6 then
      printout({ "fa.travel-menu-broadcast" }, pindex)
   elseif storage.players[pindex].travel.index.x == 7 then
      printout({ "fa.travel-menu-delete" }, pindex)
   elseif storage.players[pindex].travel.index.x == 8 then
      printout({ "fa.travel-menu-create-new" }, pindex)
   end
end

function mod.fast_travel_menu_close(pindex)
   local router = UiRouter.get_router(pindex)

   if game.get_player(pindex).gui.screen["travel"] then game.get_player(pindex).gui.screen["travel"].destroy() end
   router:close_ui()
end

return mod
