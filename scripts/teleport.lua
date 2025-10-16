--Here: teleporting
local FaUtils = require("scripts.fa-utils")
local Graphics = require("scripts.graphics")
local Mouse = require("scripts.mouse")
local Viewpoint = require("scripts.viewpoint")
local Speech = require("scripts.speech")
local MessageBuilder = Speech.MessageBuilder
local BumpDetection = require("scripts.bump-detection")
local MovementHistory = require("scripts.movement-history")

local mod = {}

--Teleports the player character to the cursor position.
function mod.teleport_to_cursor(pindex, muted, ignore_enemies, return_cursor)
   local vp = Viewpoint.get_viewpoint(pindex)
   local result = mod.teleport_to_closest(pindex, vp:get_cursor_pos(), muted, ignore_enemies)
   if return_cursor then
      local position = storage.players[pindex].position
      vp:set_cursor_pos({ x = position.x, y = position.y })
   end
   return result
end

--Makes the player teleport to the closest valid position to a target position. Uses game's teleport function. Muted makes silent and effectless teleporting
function mod.teleport_to_closest(pindex, pos, muted, ignore_enemies)
   pos = table.deepcopy(pos)
   pos.x = math.floor(pos.x) + 0.5
   pos.y = math.floor(pos.y) + 0.5
   muted = muted or false
   local char = game.get_player(pindex).character
   if not char then return false end

   local surf = char.surface
   local radius = 0.5
   --Find a non-colliding position
   local new_pos = surf.find_non_colliding_position("character", pos, radius, 0.1, true)
   while new_pos == nil do
      radius = radius + 1
      new_pos = surf.find_non_colliding_position("character", pos, radius, 0.1, true)
   end
   --Do not teleport if in a vehicle, in a menu, or already at the destination
   if char.vehicle ~= nil and char.vehicle.valid then
      Speech.speak(pindex, { "fa.teleport-cannot-in-vehicle" })
      return false
   elseif util.distance(game.get_player(pindex).position, pos) < 0.6 then
      Speech.speak(pindex, { "fa.teleport-already-at-target" })
      return false
   end
   --Do not teleport near enemies unless instructed to ignore them
   if not ignore_enemies then
      local enemy = char.surface.find_nearest_enemy({ position = new_pos, max_distance = 30, force = char.force })
      if enemy and enemy.valid then
         Speech.speak(pindex, { "fa.teleport-enemies-warning" })
         return false
      end
   end
   --Attempt teleport
   local can_port = char.surface.can_place_entity({ name = "character", position = new_pos })
   if can_port then
      local old_pos = table.deepcopy(char.position)
      local vp = Viewpoint.get_viewpoint(pindex)
      if not muted then
         --Draw teleporting visuals at origin
         rendering.draw_circle({
            color = { 0.8, 0.2, 0.0 },
            radius = 0.5,
            width = 15,
            target = old_pos,
            surface = char.surface,
            draw_on_ground = true,
            time_to_live = 60,
         })
         rendering.draw_circle({
            color = { 0.6, 0.1, 0.1 },
            radius = 0.3,
            width = 20,
            target = old_pos,
            surface = char.surface,
            draw_on_ground = true,
            time_to_live = 60,
         })
         local smoke_spot_ghosts =
            char.surface.find_entities_filtered({ position = char.position, type = "entity-ghost" })
         if smoke_spot_ghosts == nil or #smoke_spot_ghosts == 0 then
            local smoke_effect = char.surface.create_entity({
               name = "iron-chest",
               position = char.position,
               raise_built = false,
               force = char.force,
            })
            smoke_effect.destroy({})
         end
         --Teleport sound at origin
         game.get_player(pindex).play_sound({ path = "player-teleported", volume_modifier = 0.2, position = old_pos })
         game
            .get_player(pindex)
            .play_sound({ path = "utility/scenario_message", volume_modifier = 0.8, position = old_pos })
      end
      local teleported = false
      MovementHistory.reset_and_increment_generation(pindex)
      if muted then
         teleported = char.teleport(new_pos)
      else
         teleported = char.teleport(new_pos)
      end
      if teleported then
         char.force.chart(char.surface, { { new_pos.x - 15, new_pos.y - 15 }, { new_pos.x + 15, new_pos.y + 15 } })
         storage.players[pindex].position = table.deepcopy(new_pos)
         BumpDetection.reset_bump_stats(pindex)
         if not muted then
            --Draw teleporting visuals at target
            rendering.draw_circle({
               color = { 0.3, 0.3, 0.9 },
               radius = 0.5,
               width = 15,
               target = new_pos,
               surface = char.surface,
               draw_on_ground = true,
               time_to_live = 60,
            })
            rendering.draw_circle({
               color = { 0.0, 0.0, 0.9 },
               radius = 0.3,
               width = 20,
               target = new_pos,
               surface = char.surface,
               draw_on_ground = true,
               time_to_live = 60,
            })
            local smoke_spot_ghosts =
               char.surface.find_entities_filtered({ position = char.position, type = "entity-ghost" })
            if smoke_spot_ghosts == nil or #smoke_spot_ghosts == 0 then
               local smoke_effect = char.surface.create_entity({
                  name = "iron-chest",
                  position = char.position,
                  raise_built = false,
                  force = char.force,
               })
               smoke_effect.destroy({})
            end
            --Teleport sound at target
            game
               .get_player(pindex)
               .play_sound({ path = "player-teleported", volume_modifier = 0.2, position = new_pos })
            game
               .get_player(pindex)
               .play_sound({ path = "utility/scenario_message", volume_modifier = 0.8, position = new_pos })
         end
         if math.floor(new_pos.x) ~= math.floor(pos.x) or math.floor(new_pos.y) ~= math.floor(pos.y) then
            if not muted then
               local message = MessageBuilder.new()
               message:fragment({
                  "fa.teleport-distance",
                  -- This is a bit weird. We can either be too high or too low. But if off by one tile we want to be too
                  -- low, because southwest for example is actually sqrt(2) tiles. So we want floor.  Really we probably
                  -- want manhattan distance or something but this is good enough.
                  tostring(math.floor(FaUtils.distance(pos, char.position))),
                  FaUtils.direction(pos, char.position),
               })
               Speech.speak(pindex, message:build())
            end
         end
         --Update cursor after teleport
         vp:set_cursor_pos({ x = new_pos.x, y = new_pos.y })
         Mouse.move_mouse_pointer(FaUtils.center_of_tile(vp:get_cursor_pos()), pindex)
         Graphics.draw_cursor_highlight(pindex, nil, nil)
      else
         Speech.speak(pindex, { "fa.teleport-failed" })
         return false
      end
   else
      Speech.speak(pindex, { "fa.teleport-cannot" }) --this is unlikely to be reached because we find the first non-colliding position
      return false
   end

   -- --Adjust camera
   -- game.get_player(pindex).close_map()

   return true
end

return mod
