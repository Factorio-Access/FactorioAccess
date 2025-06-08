--Here: Movement of the mouse pointer on screen. This is needed for graphics sync and gun aiming support.
--Note: Does not include the mod cursor functions!

--TODO: Automate the calculations of these 3 mults by figuring out the correct rules for them.
-- The final pixel position depends on player screen resolution, player zoom level, possibly player display scale, and these mults.
local tile_zoom_screen_mult = 32
local screen_edge_mult_1 = 18
local screen_edge_mult_2 = 1.6

local fa_utils = require("scripts.fa-utils")
local Viewpoint = require("scripts.viewpoint")
local mod = {}

--Moves the mouse pointer to the correct pixel on the screen for an input map position. If the position is off screen, then the pointer is centered on the player character instead. Does not run in vanilla mode or if the mouse is released from synchronizing.
function mod.move_mouse_pointer(position, pindex)
   local player = players[pindex]
   local pos = position
   local screen = game.players[pindex].display_resolution
   local screen_center = fa_utils.mult_position({ x = screen.width, y = screen.height }, 0.5)
   local pixels = screen_center
   local offset = { x = 0, y = 0 }
   local vp = Viewpoint.get_viewpoint(pindex)
   if players[pindex].vanilla_mode or game.get_player(pindex).game_view_settings.update_entity_selection == true then
      return
   elseif player.remote_view == true then
      --If in remote view, take the cursor position as the center point
      offset = fa_utils.mult_position(fa_utils.sub_position(pos, vp:get_cursor_pos()), tile_zoom_screen_mult * player.zoom)
   elseif mod.cursor_position_is_on_screen_with_player_centered(pindex) == false then
      --If the cursor is distant, center the pointer on the player
      pos = players[pindex].position
      offset = fa_utils.mult_position(fa_utils.sub_position(pos, player.position), tile_zoom_screen_mult * player.zoom)
   else
      offset = fa_utils.mult_position(fa_utils.sub_position(pos, player.position), tile_zoom_screen_mult * player.zoom)
   end
   pixels = fa_utils.add_position(pixels, offset)
   mod.move_pointer_to_pixels(pixels.x, pixels.y, pindex)
   --game.get_player(pindex).print("moved to " ..  math.floor(pixels.x) .. " , " ..  math.floor(pixels.y), {volume_modifier=0})--
end

--Moves the mouse pointer to specified pixels on the screen.
function mod.move_pointer_to_pixels(x, y, pindex)
   if
      x >= 0
      and y >= 0
      and x < game.players[pindex].display_resolution.width
      and y < game.players[pindex].display_resolution.height
   then
      --print("setCursor " .. pindex .. " " .. math.ceil(x) .. "," .. math.ceil(y))
   end
end

--Checks if the map position of the mod cursor falls on screen when the camera is locked on the player character.
function mod.cursor_position_is_on_screen_with_player_centered(pindex)
   local range_y = math.floor(screen_edge_mult_1 / players[pindex].zoom)
   local range_x = range_y * game.get_player(pindex).display_scale * screen_edge_mult_2
   local vp = Viewpoint.get_viewpoint(pindex)
   local cursor_pos = vp:get_cursor_pos()
   return (
      math.abs(cursor_pos.y - players[pindex].position.y) <= range_y
      and math.abs(cursor_pos.x - players[pindex].position.x) <= range_x
   )
end

--Reports if the cursor tile is uncharted/blurred and also if it is distant (off screen)
function mod.cursor_visibility_info(pindex)
   local p = game.get_player(pindex)
   local result = ""
   local vp = Viewpoint.get_viewpoint(pindex)
   local pos = vp:get_cursor_pos()
   local chunk_pos = { x = math.floor(pos.x / 32), y = math.floor(pos.y / 32) }
   if p.force.is_chunk_charted(p.surface, chunk_pos) == false then
      result = result .. " uncharted "
   elseif p.force.is_chunk_visible(p.surface, chunk_pos) == false then
      result = result .. " blurred "
   end
   if mod.cursor_position_is_on_screen_with_player_centered(pindex) == false then result = result .. " distant " end
   return result
end

return mod
