--Here: Fast travel, structure travel, etc.
local FaUtils = require("scripts.fa-utils")
local Graphics = require("scripts.graphics")
local Mouse = require("scripts.mouse")
local Teleport = require("scripts.teleport")
local UiRouter = require("scripts.ui.router")
local Viewpoint = require("scripts.viewpoint")
local EntitySelection = require("scripts.entity-selection")
local Speech = require("scripts.speech")

local mod = {}
local TRAVEL_MENU_LENGTH = 8

function mod.fast_travel_menu_open(pindex)
   local router = UiRouter.get_router(pindex)

   local p = game.get_player(pindex)
   if p.ticks_to_respawn ~= nil then return end
   -- [UI CHECKS REMOVED] Menu mutex check removed - travel menu handled by new UI system
   game.get_player(pindex).selected = nil

   router:open_ui(UiRouter.UI_NAMES.TRAVEL)
   storage.players[pindex].move_queue = {}
   storage.players[pindex].travel.index = { x = 1, y = 0 }
   Speech.speak(
      pindex,
      "Fast travel, Navigate up and down with W and S to select a fast travel location, and jump to it with LEFT BRACKET.  Alternatively, select an option by navigating left and right with A and D."
   )
   local screen = game.get_player(pindex).gui.screen
   local frame = screen.add({ type = "frame", name = "travel" })
   frame.bring_to_front()
   frame.force_auto_center()
   frame.focus()
   game.get_player(pindex).opened = frame
   game.get_player(pindex).selected = nil
end

--Reads the selected fast travel menu slot
function mod.read_fast_travel_slot(pindex)
   if #storage.players[pindex].travel == 0 then
      Speech.speak(pindex, { "fa.travel-move-right-create" })
   else
      local vp = Viewpoint.get_viewpoint(pindex)
      local entry = storage.players[pindex].travel[storage.players[pindex].travel.index.y]
      Speech.speak(
         pindex,
         entry.name
            .. " at "
            .. math.floor(entry.position.x)
            .. ", "
            .. math.floor(entry.position.y)
            .. ", cursor moved."
      )
      vp:set_cursor_pos(FaUtils.center_of_tile(entry.position))
      Graphics.draw_cursor_highlight(pindex, nil, "train-visualization")
   end
end

function mod.fast_travel_menu_click(pindex)
   local p = game.get_player(pindex)
   local vp = Viewpoint.get_viewpoint(pindex)
   if #storage.players[pindex].travel == 0 and storage.players[pindex].travel.index.x < TRAVEL_MENU_LENGTH then
      Speech.speak(pindex, { "fa.travel-move-right-create-new" })
   elseif
      storage.players[pindex].travel.index.y == 0 and storage.players[pindex].travel.index.x < TRAVEL_MENU_LENGTH
   then
      Speech.speak(
         pindex,
         "Navigate up and down to select a fast travel point, then press LEFT BRACKET to get there quickly."
      )
   elseif storage.players[pindex].travel.index.x == 1 then --Travel
      if p.vehicle then
         Speech.speak(pindex, { "fa.travel-cannot-teleport-vehicle" })
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

      if not EntitySelection.refresh_player_tile(pindex) then
         Speech.speak(pindex, { "fa.travel-tile-out-of-range" })
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
      Speech.speak(pindex, desc)
   elseif storage.players[pindex].travel.index.x == 3 then --Rename
      Speech.speak(
         pindex,
         "Travel point renaming is temporarily unavailable while the text input system is being redesigned."
      )
   elseif storage.players[pindex].travel.index.x == 4 then --Rewrite description
      Speech.speak(
         pindex,
         "Travel point description editing is temporarily unavailable while the text input system is being redesigned."
      )
   elseif storage.players[pindex].travel.index.x == 5 then --Relocate to current character position
      storage.players[pindex].travel[storage.players[pindex].travel.index.y].position =
         FaUtils.center_of_tile(storage.players[pindex].position)
      Speech.speak(pindex, {
         "fa.travel-relocated-point",
         storage.players[pindex].travel[storage.players[pindex].travel.index.y].name,
         tostring(math.floor(storage.players[pindex].position.x)),
         tostring(math.floor(storage.players[pindex].position.y)),
      })
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
         Speech.speak(pindex, { "fa.travel-error-cancelled-broadcast" })
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
      Speech.speak(pindex, { "fa.travel-broadcasted-point", this_point.name })
      storage.players[pindex].travel.last_broadcasted_name = this_point.name
      storage.players[pindex].travel.last_broadcasted_description = this_point.description
      storage.players[pindex].travel.last_broadcasted_position = this_point.position
   elseif storage.players[pindex].travel.index.x == 7 then --Delete
      Speech.speak(
         pindex,
         { "fa.travel-deleted-point", storage.players[pindex].travel[storage.players[pindex].travel.index.y].name }
      )
      table.remove(storage.players[pindex].travel, storage.players[pindex].travel.index.y)
      storage.players[pindex].travel.x = 1
      storage.players[pindex].travel.index.y = storage.players[pindex].travel.index.y - 1
   elseif storage.players[pindex].travel.index.x == 8 then --Create new
      Speech.speak(
         pindex,
         "Creating new travel points is temporarily unavailable while the text input system is being redesigned."
      )
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
      Speech.speak(pindex, { "fa.travel-menu-travel" })
   elseif storage.players[pindex].travel.index.x == 2 then
      Speech.speak(pindex, { "fa.travel-menu-read-description" })
   elseif storage.players[pindex].travel.index.x == 3 then
      Speech.speak(pindex, { "fa.travel-menu-rename" })
   elseif storage.players[pindex].travel.index.x == 4 then
      Speech.speak(pindex, { "fa.travel-menu-rewrite-description" })
   elseif storage.players[pindex].travel.index.x == 5 then
      Speech.speak(pindex, { "fa.travel-menu-relocate" })
   elseif storage.players[pindex].travel.index.x == 6 then
      Speech.speak(pindex, { "fa.travel-menu-broadcast" })
   elseif storage.players[pindex].travel.index.x == 7 then
      Speech.speak(pindex, { "fa.travel-menu-delete" })
   elseif storage.players[pindex].travel.index.x == 8 then
      Speech.speak(pindex, { "fa.travel-menu-create-new" })
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
      Speech.speak(pindex, { "fa.travel-menu-travel" })
   elseif storage.players[pindex].travel.index.x == 2 then
      Speech.speak(pindex, { "fa.travel-menu-read-description" })
   elseif storage.players[pindex].travel.index.x == 3 then
      Speech.speak(pindex, { "fa.travel-menu-rename" })
   elseif storage.players[pindex].travel.index.x == 4 then
      Speech.speak(pindex, { "fa.travel-menu-rewrite-description" })
   elseif storage.players[pindex].travel.index.x == 5 then
      Speech.speak(pindex, { "fa.travel-menu-relocate" })
   elseif storage.players[pindex].travel.index.x == 6 then
      Speech.speak(pindex, { "fa.travel-menu-broadcast" })
   elseif storage.players[pindex].travel.index.x == 7 then
      Speech.speak(pindex, { "fa.travel-menu-delete" })
   elseif storage.players[pindex].travel.index.x == 8 then
      Speech.speak(pindex, { "fa.travel-menu-create-new" })
   end
end

function mod.fast_travel_menu_close(pindex)
   local router = UiRouter.get_router(pindex)

   if game.get_player(pindex).gui.screen["travel"] then game.get_player(pindex).gui.screen["travel"].destroy() end
   router:close_ui()
end

return mod
