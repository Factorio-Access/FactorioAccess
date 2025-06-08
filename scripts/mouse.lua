--Here: Movement of the mouse pointer on screen. This is needed for graphics sync and gun aiming support.
--Note: Does not include the mod cursor functions!

-- The final pixel position depends on player screen resolution, player zoom level, this multiplier.
local base_pixels_per_tile = 32

local fa_utils = require("scripts.fa-utils")
local Viewpoint = require("scripts.viewpoint")
local mod = {}

---helper function with tripple return
---@param position MapPosition
---@param pindex int
---@return {x:float,y:float} pixel_pos The sceen pixel coordinates of the map position
---@return boolean on_sceen If that position is on sceen
---@return {x:float,y:float} screen_center The x and y pixels of the center of the screen
local function get_pixel_pos_onscreen_center(position, pindex)
   local player = game.get_player(pindex)
   local screen_size = player.display_resolution
   local screen_center = fa_utils.mult_position({ x = screen_size.width, y = screen_size.height }, 0.5)
   local tile_offest = fa_utils.sub_position(position, player.position)
   local scale = base_pixels_per_tile * player.zoom * player.display_density_scale
   local pixel_offset = fa_utils.mult_position(tile_offest, scale)
   local pixel_pos = fa_utils.add_position(screen_center, pixel_offset)
   local on_screen = pixel_pos.x > 0
      and pixel_pos.y > 0
      and pixel_pos.x < screen_size.width
      and pixel_pos.y < screen_size.height
   return pixel_pos, on_screen, screen_center
end

---Moves the mouse pointer to specified pixels on the screen of player
---@param pos {x:float,y:float} bounds must be prechecked
---@param pindex int
local function move_pointer_to_pixels(pos, pindex)
   local x = math.ceil(pos.x)
   local y = math.ceil(pos.y)
   local text_pos = " " .. x .. "," .. y
   print("setCursor " .. pindex .. text_pos)
   --game.get_player(pindex).print("moved to" .. text_pos, { volume_modifier = 0 })
end

---Moves the mouse pointer to the correct pixel on the screen for an input map position.
---If the position is off screen, then the pointer is centered instead.
---Does not run in vanilla mode or if the mouse is released from synchronizing.
---@param position MapPosition
---@param pindex int
function mod.move_mouse_pointer(position, pindex)
   if players[pindex].vanilla_mode or game.get_player(pindex).game_view_settings.update_entity_selection == true then
      return
   end
   local pixel_pos, on_screen, screen_center = get_pixel_pos_onscreen_center(position, pindex)
   if not on_screen then pixel_pos = screen_center end
   move_pointer_to_pixels(pixel_pos, pindex)
end

---Checks if the position is on the screen
---@param pos MapPosition
---@param pindex int
---@return boolean
function mod.is_on_screen(pos, pindex)
   local _, on_sceen, _ = get_pixel_pos_onscreen_center(pos, pindex)
   return on_sceen
end

--The rest of these functions should probably be moved elsewhere?
--Maybe into viewpoint? That would also remove the dependancy on viewpoint
--That way this module doens't care if we even have a cursor
--It only cares about the screen and mouse

--Checks if the map position of the mod cursor falls on screen when the camera is locked on the player character.
function mod.cursor_position_is_on_screen_with_player_centered(pindex)
   local vp = Viewpoint.get_viewpoint(pindex)
   local cursor_pos = vp:get_cursor_pos()
   return mod.is_on_screen(cursor_pos, pindex)
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
   if mod.is_on_screen(pos, pindex) == false then result = result .. " distant " end
   return result
end

return mod
