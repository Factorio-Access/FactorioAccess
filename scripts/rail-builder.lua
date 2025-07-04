--Here: Functions about building rail systems, including the rail appender and everything called by the rail buidler menu
--Does not include event handlers, rail analysis
---@diagnostic disable: assign-type-mismatch

local util = require("util")
local FaUtils = require("scripts.fa-utils")
local PlayerMiningTools = require("scripts.player-mining-tools")
local Rails = require("scripts.rails")
local EntitySelection = require("scripts.entity-selection")
local dirs = defines.direction
local UiRouter = require("scripts.ui.router")

local mod = {}

--Appends a new straight or diagonal rail to a rail end found near the input position. The cursor needs to be holding rails.
function mod.append_rail(pos, pindex)
   local surf = game.get_player(pindex).surface
   local stack = game.get_player(pindex).cursor_stack
   local is_end_rail = false
   local end_found = nil
   local end_dir = nil
   local end_dir_1 = nil
   local end_dir_2 = nil
   local rail_api_dir = nil
   local is_end_rail = nil
   local end_rail_dir = nil
   local comment = ""

   --0 Check if there is at least 1 rail in hand, else return
   if not (stack.valid and stack.valid_for_read and stack.name == "rail" and stack.count > 0) then
      game.get_player(pindex).play_sound({ path = "utility/cannot_build" })
      printout({ "fa.rail-need-at-least-one" }, pindex)
      return
   end

   --1 Check the cursor entity. If it is an end rail, use this instead of scanning to extend the rail you want.
   local ent = EntitySelection.get_tile_cache(pindex).ents[1]
   is_end_rail, end_rail_dir, comment = Rails.check_end_rail(ent, pindex)
   if is_end_rail then
      end_found = ent
      end_rail_1, end_dir_1 = ent.get_rail_segment_end(defines.rail_direction.front)
      end_rail_2, end_dir_2 = ent.get_rail_segment_end(defines.rail_direction.back)
      if ent.unit_number == end_rail_1.unit_number then
         end_dir = end_dir_1
      elseif ent.unit_number == end_rail_2.unit_number then
         end_dir = end_dir_2
      end
   else
      --2 Scan the area around within a X tile radius of pos
      local ents = surf.find_entities_filtered({ position = pos, radius = 3, name = "straight-rail" })
      if #ents == 0 then
         ents = surf.find_entities_filtered({ position = pos, radius = 3, name = "curved-rail" })
         if #ents == 0 then
            game.get_player(pindex).play_sound({ path = "utility/cannot_build" })
            if storage.players[pindex].build_lock == false then
               printout({ "fa.rail-no-rails-nearby" }, pindex)
               return
            end
         end
      end

      --3 For the first rail found, check if it is at the end of its segment and if the rail is not within X tiles of pos, try the other end
      for i, rail in ipairs(ents) do
         end_rail_1, end_dir_1 = rail.get_rail_segment_end(defines.rail_direction.front)
         end_rail_2, end_dir_2 = rail.get_rail_segment_end(defines.rail_direction.back)
         if util.distance(pos, end_rail_1.position) < 3 then --is within range
            end_found = end_rail_1
            end_dir = end_dir_1
         elseif util.distance(pos, end_rail_2.position) < 3 then --is within range
            end_found = end_rail_2
            end_dir = end_dir_2
         end
      end
      if end_found == nil then
         game.get_player(pindex).play_sound({ path = "utility/cannot_build" })
         if storage.players[pindex].build_lock == false then printout("No end rails found nearby", pindex) end
         return
      end

      --4 Check if the found segment end is an end rail
      is_end_rail, end_rail_dir, comment = Rails.check_end_rail(end_found, pindex)
      if not is_end_rail then
         game.get_player(pindex).play_sound({ path = "utility/cannot_build" })
         --printout(comment, pindex)
         printout({ "fa.rail-no-end-rails-nearby" }, pindex)
         return
      end
   end

   --5 Confirmed as an end rail. Get its position and find the correct position and direction for the appended rail.
   end_rail_pos = end_found.position
   end_rail_dir = end_found.direction
   append_rail_dir = -1
   append_rail_pos = nil
   rail_api_dir = end_found.direction

   --printout(" Rail end found at " .. end_found.position.x .. " , " .. end_found.position.y .. " , facing " .. end_found.direction, pindex)--Checks

   if end_found.name == "straight-rail" then
      if end_rail_dir == dirs.north or end_rail_dir == dirs.south then
         append_rail_dir = dirs.north
         if end_dir == defines.rail_direction.front then
            append_rail_pos = { end_rail_pos.x + 0, end_rail_pos.y - 2 }
         else
            append_rail_pos = { end_rail_pos.x + 0, end_rail_pos.y + 2 }
         end
      elseif end_rail_dir == dirs.east or end_rail_dir == dirs.west then
         append_rail_dir = dirs.east
         if end_dir == defines.rail_direction.front then
            append_rail_pos = { end_rail_pos.x + 2, end_rail_pos.y + 0 }
         else
            append_rail_pos = { end_rail_pos.x - 2, end_rail_pos.y - 0 }
         end
      elseif end_rail_dir == dirs.northeast then
         append_rail_dir = dirs.southwest
         if end_dir == defines.rail_direction.front then
            append_rail_pos = { end_rail_pos.x + 0, end_rail_pos.y - 2 }
         else
            append_rail_pos = { end_rail_pos.x + 2, end_rail_pos.y + 0 }
         end
      elseif end_rail_dir == dirs.southwest then
         append_rail_dir = dirs.northeast
         if end_dir == defines.rail_direction.front then
            append_rail_pos = { end_rail_pos.x + 0, end_rail_pos.y + 2 }
         else
            append_rail_pos = { end_rail_pos.x - 2, end_rail_pos.y + 0 }
         end
      elseif end_rail_dir == dirs.southeast then
         append_rail_dir = dirs.northwest
         if end_dir == defines.rail_direction.front then
            append_rail_pos = { end_rail_pos.x + 2, end_rail_pos.y + 0 }
         else
            append_rail_pos = { end_rail_pos.x + 0, end_rail_pos.y + 2 }
         end
      elseif end_rail_dir == dirs.northwest then
         append_rail_dir = dirs.southeast
         if end_dir == defines.rail_direction.front then
            append_rail_pos = { end_rail_pos.x - 2, end_rail_pos.y + 0 }
         else
            append_rail_pos = { end_rail_pos.x + 0, end_rail_pos.y - 2 }
         end
      end
   elseif end_found.name == "curved-rail" then
      --Make sure to use the reported end direction for curved rails
      is_end_rail, end_rail_dir, comment = Rails.check_end_rail(ent, pindex)
      if end_rail_dir == dirs.north then
         if rail_api_dir == dirs.south then
            append_rail_pos = { end_rail_pos.x - 2, end_rail_pos.y - 6 }
            append_rail_dir = dirs.north
         elseif rail_api_dir == dirs.southwest then
            append_rail_pos = { end_rail_pos.x - 0, end_rail_pos.y - 6 }
            append_rail_dir = dirs.north
         end
      elseif end_rail_dir == dirs.northeast then
         if rail_api_dir == dirs.northeast then
            append_rail_pos = { end_rail_pos.x + 2, end_rail_pos.y - 4 }
            append_rail_dir = dirs.northwest
         elseif rail_api_dir == dirs.east then
            append_rail_pos = { end_rail_pos.x + 2, end_rail_pos.y - 4 }
            append_rail_dir = dirs.southeast
         end
      elseif end_rail_dir == dirs.east then
         if rail_api_dir == dirs.west then
            append_rail_pos = { end_rail_pos.x + 4, end_rail_pos.y - 2 }
            append_rail_dir = dirs.east
         elseif rail_api_dir == dirs.northwest then
            append_rail_pos = { end_rail_pos.x + 4, end_rail_pos.y - 0 }
            append_rail_dir = dirs.east
         end
      elseif end_rail_dir == dirs.southeast then
         if rail_api_dir == dirs.southeast then
            append_rail_pos = { end_rail_pos.x + 2, end_rail_pos.y + 2 }
            append_rail_dir = dirs.northeast
         elseif rail_api_dir == dirs.south then
            append_rail_pos = { end_rail_pos.x + 2, end_rail_pos.y + 2 }
            append_rail_dir = dirs.southwest
         end
      elseif end_rail_dir == dirs.south then
         if rail_api_dir == dirs.north then
            append_rail_pos = { end_rail_pos.x - 0, end_rail_pos.y + 4 }
            append_rail_dir = dirs.north
         elseif rail_api_dir == dirs.northeast then
            append_rail_pos = { end_rail_pos.x - 2, end_rail_pos.y + 4 }
            append_rail_dir = dirs.north
         end
      elseif end_rail_dir == dirs.southwest then
         if rail_api_dir == dirs.southwest then
            append_rail_pos = { end_rail_pos.x - 4, end_rail_pos.y + 2 }
            append_rail_dir = dirs.southeast
         elseif rail_api_dir == dirs.west then
            append_rail_pos = { end_rail_pos.x - 4, end_rail_pos.y + 2 }
            append_rail_dir = dirs.northwest
         end
      elseif end_rail_dir == dirs.west then
         if rail_api_dir == dirs.east then
            append_rail_pos = { end_rail_pos.x - 6, end_rail_pos.y - 0 }
            append_rail_dir = dirs.east
         elseif rail_api_dir == dirs.southeast then
            append_rail_pos = { end_rail_pos.x - 6, end_rail_pos.y - 2 }
            append_rail_dir = dirs.east
         end
      elseif end_rail_dir == dirs.northwest then
         if rail_api_dir == dirs.north then
            append_rail_pos = { end_rail_pos.x - 4, end_rail_pos.y - 4 }
            append_rail_dir = dirs.northeast
         elseif rail_api_dir == dirs.northwest then
            append_rail_pos = { end_rail_pos.x - 4, end_rail_pos.y - 4 }
            append_rail_dir = dirs.southwest
         end
      end
   end

   --6. Clear trees and rocks nearby and check if the selected 2x2 space is free for building, else return
   if append_rail_pos == nil then
      game.get_player(pindex).play_sound({ path = "utility/cannot_build" })
      printout(
         { "", tostring(end_rail_dir), " and ", tostring(rail_api_dir), ", rail appending direction error." },
         pindex
      )
      return
   end
   temp1, build_comment = PlayerMiningTools.clear_obstacles_in_circle(append_rail_pos, 4, pindex)
   if
      not surf.can_place_entity({ name = "straight-rail", position = append_rail_pos, direction = append_rail_dir })
   then
      --Check if you can build from cursor or if you have other rails here already
      -- local other_rails_present = false
      -- local ents = surf.find_entities_filtered{position = append_rail_pos}
      -- for i,ent in ipairs(ents) do
      -- if ent.name == "straight-rail" or ent.name == "curved-rail" then
      -- other_rails_present = true
      -- end
      -- end
      -- if game.get_player(pindex).can_build_from_cursor({name = "straight-rail", position = append_rail_pos, direction = append_rail_dir}) then--**maybe thisll work
      -- game.get_player(pindex).print("Can build from hand",{volume_modifier = 0})
      -- end
      -- if other_rails_present == true then
      -- game.get_player(pindex).print("Other rails present",{volume_modifier = 0})
      -- end
      --Patch a bug with South and West dirs in certain conditions such as after a train stop, where it is detected as North/East
      if end_rail_dir == dirs.east then
         append_rail_pos = { end_rail_pos.x - 2, end_rail_pos.y - 0 }
      elseif end_rail_dir == dirs.north then
         append_rail_pos = { end_rail_pos.x - 0, end_rail_pos.y + 2 }
      end
      if
         not surf.can_place_entity({ name = "straight-rail", position = append_rail_pos, direction = append_rail_dir })
      then
         printout({ "fa.rail-cannot-place-extend" }, pindex)
         game.get_player(pindex).play_sound({ path = "utility/cannot_build" })
         rendering.draw_circle({
            color = { 1, 0, 0 },
            radius = 0.5,
            width = 5,
            target = append_rail_pos,
            surface = surf,
            time_to_live = 120,
         })
         return
      end
   end

   --7. Create the appended rail and subtract 1 rail from the hand.
   created_rail = surf.create_entity({
      name = "straight-rail",
      position = append_rail_pos,
      direction = append_rail_dir,
      force = game.forces.player,
   })

   if not (created_rail ~= nil and created_rail.valid) then
      created_rail = game
         .get_player(pindex)
         .build_from_cursor({ name = "straight-rail", position = append_rail_pos, direction = append_rail_dir })
      if not (created_rail ~= nil and created_rail.valid) then
         game.get_player(pindex).play_sound({ path = "utility/cannot_build" })
         printout({ "fa.rail-error-invalid-appended" }, pindex)
         rendering.draw_circle({
            color = { 1, 0, 0 },
            radius = 0.5,
            width = 5,
            target = append_rail_pos,
            surface = surf,
            time_to_live = 120,
         })
         return
      end
   end

   local player = game.get_player(pindex)
   player.cursor_stack.count = player.cursor_stack.count - 1
   player.play_sound({ path = "entity-build/straight-rail" })

   --8. Check if the appended rail is with 4 tiles of a parallel rail. If so, delete it.
   if created_rail.valid and Rails.has_parallel_neighbor(created_rail, pindex) then
      player.mine_entity(created_rail, true)
      player.play_sound({ path = "utility/cannot_build" })
      printout({ "fa.rail-parallel-spacing" }, pindex)
   end

   --9. Check if the appended rail has created an intersection. If so, notify the player.
   if created_rail.valid and Rails.is_intersection_rail(created_rail, pindex) then
      printout({ "fa.rail-intersection-created" }, pindex)
   end
end

--Allows free placement of a rail signal. Note that signals can only be placed on the right hand side with respect to the direction of travel.
--If callled with preview_only, then the function returns the direction of the signal that can be placed there.
function mod.free_place_rail_signal_in_hand(pindex, preview_only)
   local p = game.get_player(pindex)
   local stack = p.cursor_stack
   --Verify that a rail or chain signal is in hand
   if
      stack == nil
      or stack.valid_for_read == false
      or (stack.name ~= "rail-signal" and stack.name ~= "rail-chain-signal")
   then
      return
   end
   local surf = p.surface
   local pos = storage.players[pindex].cursor_pos
   local build_comment = ""
   --Check if the building area is occupied
   if surf.can_place_entity({ position = pos, name = stack.name, force = p.force }) == false then
      if not preview_only then p.play_sound({ path = "utility/cannot_build" }) end
      build_comment = "Tile occupied."
      printout(build_comment, pindex)
      return
   end
   --Check if too close to existing signals
   local nearby_signals =
      surf.find_entities_filtered({ position = pos, radius = 1.5, name = { "rail-signal", "rail-chain-signal" } })
   if #nearby_signals > 0 then
      if not preview_only then p.play_sound({ path = "utility/cannot_build" }) end
      build_comment = "Too close to existing signals."
      printout(build_comment, pindex)
      return
   end
   --Scan for straight rails nearby
   local rails = surf.find_entities_filtered({ position = pos, radius = 2.5, name = "straight-rail" })
   if #rails == 0 then
      if not preview_only then p.play_sound({ path = "utility/cannot_build" }) end
      build_comment = "Must be placed next to a straight rail."
      printout(build_comment, pindex)
      return
   end
   for i, rail in ipairs(rails) do
      --Check if the placement area is valid
      local rail_dir = rail.direction
      local rail_at = FaUtils.get_direction_precise(rail.position, pos)
      local created = nil
      --Check if the rail is correctly oriented
      if rail_at == dirs.north and (rail_dir == dirs.east or rail_dir == dirs.west) then
         --Place at south, heading east
         if preview_only then return dirs.east end
         created = surf.create_entity({ position = pos, name = stack.name, force = p.force, direction = dirs.west })
      elseif rail_at == dirs.south and (rail_dir == dirs.east or rail_dir == dirs.west) then
         --Place at north, heading west
         if preview_only then return dirs.west end
         created = surf.create_entity({ position = pos, name = stack.name, force = p.force, direction = dirs.east })
      elseif rail_at == dirs.east and (rail_dir == dirs.north or rail_dir == dirs.south) then
         --Place at west, heading south
         if preview_only then return dirs.south end
         created = surf.create_entity({ position = pos, name = stack.name, force = p.force, direction = dirs.north })
      elseif rail_at == dirs.west and (rail_dir == dirs.north or rail_dir == dirs.south) then
         --Place at east, heading north
         if preview_only then return dirs.north end
         created = surf.create_entity({ position = pos, name = stack.name, force = p.force, direction = dirs.south })
      elseif rail_at == dirs.northeast and (rail_dir == dirs.northeast or rail_dir == dirs.southwest) then
         --Place at southwest, heading southeast
         if preview_only then return dirs.southeast end
         created =
            surf.create_entity({ position = pos, name = stack.name, force = p.force, direction = dirs.northwest })
      elseif rail_at == dirs.southwest and (rail_dir == dirs.northeast or rail_dir == dirs.southwest) then
         --Place at northeast, heading northwest
         if preview_only then return dirs.northwest end
         created =
            surf.create_entity({ position = pos, name = stack.name, force = p.force, direction = dirs.southeast })
      elseif rail_at == dirs.southeast and (rail_dir == dirs.southeast or rail_dir == dirs.northwest) then
         --Place at northwest, heading southwest
         if preview_only then return dirs.southwest end
         created =
            surf.create_entity({ position = pos, name = stack.name, force = p.force, direction = dirs.northeast })
      elseif rail_at == dirs.northwest and (rail_dir == dirs.southeast or rail_dir == dirs.northwest) then
         --Place at southeast, heading northeast
         if preview_only then return dirs.northeast end
         created =
            surf.create_entity({ position = pos, name = stack.name, force = p.force, direction = dirs.southwest })
      end
      --Check if successful
      if created ~= nil then
         p.play_sound({ path = "entity-build/straight-rail" })
         p.cursor_stack.count = p.cursor_stack.count - 1
         build_comment = "Signal placed heading " .. FaUtils.direction_lookup(FaUtils.rotate_180(created.direction))
         if created.status == defines.entity_status.not_connected_to_rail then
            build_comment = "Error: Signal not connected to rail, placed too far."
         end
         printout(build_comment, pindex)
         return FaUtils.rotate_180(created.direction)
      end
   end
   return nil
end

--Builds a 45 degree rail turn to the right from a horizontal or vertical end rail that is the anchor rail.
function mod.build_rail_turn_right_45_degrees(anchor_rail, pindex)
   local build_comment = ""
   local surf = game.get_player(pindex).surface
   local stack = game.get_player(pindex).cursor_stack
   local stack2 = nil
   local pos = nil
   local dir = -1
   local build_area = nil
   local can_place_all = true
   local is_end_rail
   local anchor_dir = anchor_rail.direction

   --1. Firstly, check if the player has enough rails to place this (3 units)
   if not (stack.valid and stack.valid_for_read and stack.name == "rail" and stack.count >= 3) then
      --Check if the inventory has enough
      if storage.players[pindex].inventory.lua_inventory.get_item_count("rail") < 3 then
         game.get_player(pindex).play_sound({ path = "utility/cannot_build" })
         printout({ "fa.rail-need-three-for-turn" }, pindex)
         return
      else
         --Take from the inventory.
         stack2 = storage.players[pindex].inventory.lua_inventory.find_item_stack("rail")
         game.get_player(pindex).cursor_stack.swap_stack(stack2)
         stack = game.get_player(pindex).cursor_stack
         storage.players[pindex].inventory.max = #storage.players[pindex].inventory.lua_inventory
      end
   end

   --2. Secondly, verify the end rail and find its direction
   is_end_rail, dir, build_comment = Rails.check_end_rail(anchor_rail, pindex)
   if not is_end_rail then
      game.get_player(pindex).play_sound({ path = "utility/cannot_build" })
      printout(build_comment, pindex)
      game.get_player(pindex).clear_cursor()
      return
   end
   pos = anchor_rail.position

   --3. Clear trees and rocks in the build area, can be tuned later...
   -- if dir == dirs.north or dir == dirs.northeast then
   -- build_area = {{pos.x-9, pos.y+9},{pos.x+16,pos.y-16}}
   -- elseif dir == dirs.east or dir == dirs.southeast then
   -- build_area = {{pos.x-9, pos.y-9},{pos.x+16,pos.y+16}}
   -- elseif dir == dirs.south or dir == dirs.southwest then
   -- build_area = {{pos.x+9, pos.y-9},{pos.x-16,pos.y+16}}
   -- elseif dir == dirs.west or dir == dirs.northwest then
   -- build_area = {{pos.x+9, pos.y+9},{pos.x-16,pos.y-16}}
   -- end
   temp1, build_comment = PlayerMiningTools.clear_obstacles_in_circle(pos, 12, pindex)

   --4. Check if every object can be placed
   if dir == dirs.north then
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "curved-rail",
            position = { pos.x + 2, pos.y - 4 },
            direction = dirs.northeast,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x + 4, pos.y - 8 },
            direction = dirs.northwest,
            force = game.forces.player,
         })
   elseif dir == dirs.east then
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "curved-rail",
            position = { pos.x + 6, pos.y + 2 },
            direction = dirs.southeast,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x + 8, pos.y + 4 },
            direction = dirs.northeast,
            force = game.forces.player,
         })
   elseif dir == dirs.south then
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "curved-rail",
            position = { pos.x + 0, pos.y + 6 },
            direction = dirs.southwest,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x - 4, pos.y + 8 },
            direction = dirs.southeast,
            force = game.forces.player,
         })
   elseif dir == dirs.west then
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "curved-rail",
            position = { pos.x - 4, pos.y + 0 },
            direction = dirs.northwest,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x - 8, pos.y - 4 },
            direction = dirs.southwest,
            force = game.forces.player,
         })
   elseif dir == dirs.northeast then
      if anchor_dir == dirs.northwest then
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "curved-rail",
               position = { pos.x + 4, pos.y - 2 },
               direction = dirs.west,
               force = game.forces.player,
            })
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "straight-rail",
               position = { pos.x + 8, pos.y - 4 },
               direction = dirs.east,
               force = game.forces.player,
            })
      elseif anchor_dir == dirs.southeast then
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "straight-rail",
               position = { pos.x + 2, pos.y - 0 },
               direction = dirs.northwest,
               force = game.forces.player,
            })
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "curved-rail",
               position = { pos.x + 6, pos.y - 2 },
               direction = dirs.west,
               force = game.forces.player,
            })
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "straight-rail",
               position = { pos.x + 10, pos.y - 4 },
               direction = dirs.east,
               force = game.forces.player,
            })
      end
   elseif dir == dirs.southwest then
      if anchor_dir == dirs.southeast then --2
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "curved-rail",
               position = { pos.x - 2, pos.y + 4 },
               direction = dirs.east,
               force = game.forces.player,
            })
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "straight-rail",
               position = { pos.x - 8, pos.y + 4 },
               direction = dirs.east,
               force = game.forces.player,
            })
      elseif anchor_dir == dirs.northwest then --3
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "straight-rail",
               position = { pos.x - 2, pos.y + 0 },
               direction = dirs.southeast,
               force = game.forces.player,
            })
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "curved-rail",
               position = { pos.x - 4, pos.y + 4 },
               direction = dirs.east,
               force = game.forces.player,
            })
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "straight-rail",
               position = { pos.x - 10, pos.y + 4 },
               direction = dirs.east,
               force = game.forces.player,
            })
      end
   elseif dir == dirs.southeast then
      if anchor_dir == dirs.northeast then --2
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "curved-rail",
               position = { pos.x + 4, pos.y + 4 },
               direction = dirs.north,
               force = game.forces.player,
            })
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "straight-rail",
               position = { pos.x + 4, pos.y + 8 },
               direction = dirs.north,
               force = game.forces.player,
            })
      elseif anchor_dir == dirs.southwest then --3
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "straight-rail",
               position = { pos.x - 0, pos.y + 2 },
               direction = dirs.northeast,
               force = game.forces.player,
            })
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "curved-rail",
               position = { pos.x + 4, pos.y + 6 },
               direction = dirs.north,
               force = game.forces.player,
            })
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "straight-rail",
               position = { pos.x + 4, pos.y + 10 },
               direction = dirs.north,
               force = game.forces.player,
            })
      end
   elseif dir == dirs.northwest then
      if anchor_dir == dirs.southwest then --2
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "curved-rail",
               position = { pos.x - 2, pos.y - 2 },
               direction = dirs.south,
               force = game.forces.player,
            })
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "straight-rail",
               position = { pos.x - 4, pos.y - 8 },
               direction = dirs.north,
               force = game.forces.player,
            })
      elseif anchor_dir == dirs.northeast then --3
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "straight-rail",
               position = { pos.x - 0, pos.y - 2 },
               direction = dirs.southwest,
               force = game.forces.player,
            })
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "curved-rail",
               position = { pos.x - 2, pos.y - 4 },
               direction = dirs.south,
               force = game.forces.player,
            })
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "straight-rail",
               position = { pos.x - 4, pos.y - 10 },
               direction = dirs.north,
               force = game.forces.player,
            })
      end
   end

   if not can_place_all then
      game.get_player(pindex).play_sound({ path = "utility/cannot_build" })
      printout({ "fa.rail-building-area-occupied" }, pindex)
      game.get_player(pindex).clear_cursor()
      return
   end

   --5. Build the rail entities to create the turn
   if dir == dirs.north then
      surf.create_entity({
         name = "curved-rail",
         position = { pos.x + 2, pos.y - 4 },
         direction = dirs.northeast,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x + 4, pos.y - 8 },
         direction = dirs.northwest,
         force = game.forces.player,
      })
   elseif dir == dirs.east then
      surf.create_entity({
         name = "curved-rail",
         position = { pos.x + 6, pos.y + 2 },
         direction = dirs.southeast,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x + 8, pos.y + 4 },
         direction = dirs.northeast,
         force = game.forces.player,
      })
   elseif dir == dirs.south then
      surf.create_entity({
         name = "curved-rail",
         position = { pos.x + 0, pos.y + 6 },
         direction = dirs.southwest,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x - 4, pos.y + 8 },
         direction = dirs.southeast,
         force = game.forces.player,
      })
   elseif dir == dirs.west then
      surf.create_entity({
         name = "curved-rail",
         position = { pos.x - 4, pos.y + 0 },
         direction = dirs.northwest,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x - 8, pos.y - 4 },
         direction = dirs.southwest,
         force = game.forces.player,
      })
   elseif dir == dirs.northeast then
      if anchor_dir == dirs.northwest then
         surf.create_entity({
            name = "curved-rail",
            position = { pos.x + 4, pos.y - 2 },
            direction = dirs.west,
            force = game.forces.player,
         })
         surf.create_entity({
            name = "straight-rail",
            position = { pos.x + 8, pos.y - 4 },
            direction = dirs.east,
            force = game.forces.player,
         })
      elseif anchor_dir == dirs.southeast then
         surf.create_entity({
            name = "straight-rail",
            position = { pos.x + 2, pos.y - 0 },
            direction = dirs.northwest,
            force = game.forces.player,
         })
         surf.create_entity({
            name = "curved-rail",
            position = { pos.x + 6, pos.y - 2 },
            direction = dirs.west,
            force = game.forces.player,
         })
         surf.create_entity({
            name = "straight-rail",
            position = { pos.x + 10, pos.y - 4 },
            direction = dirs.east,
            force = game.forces.player,
         })
      end
   elseif dir == dirs.southwest then
      if anchor_dir == dirs.southeast then --2
         surf.create_entity({
            name = "curved-rail",
            position = { pos.x - 2, pos.y + 4 },
            direction = dirs.east,
            force = game.forces.player,
         })
         surf.create_entity({
            name = "straight-rail",
            position = { pos.x - 8, pos.y + 4 },
            direction = dirs.east,
            force = game.forces.player,
         })
      elseif anchor_dir == dirs.northwest then --3
         surf.create_entity({
            name = "straight-rail",
            position = { pos.x - 2, pos.y + 0 },
            direction = dirs.southeast,
            force = game.forces.player,
         })
         surf.create_entity({
            name = "curved-rail",
            position = { pos.x - 4, pos.y + 4 },
            direction = dirs.east,
            force = game.forces.player,
         })
         surf.create_entity({
            name = "straight-rail",
            position = { pos.x - 10, pos.y + 4 },
            direction = dirs.east,
            force = game.forces.player,
         })
      end
   elseif dir == dirs.southeast then
      if anchor_dir == dirs.northeast then --2
         surf.create_entity({
            name = "curved-rail",
            position = { pos.x + 4, pos.y + 4 },
            direction = dirs.north,
            force = game.forces.player,
         })
         surf.create_entity({
            name = "straight-rail",
            position = { pos.x + 4, pos.y + 8 },
            direction = dirs.north,
            force = game.forces.player,
         })
      elseif anchor_dir == dirs.southwest then --3
         surf.create_entity({
            name = "straight-rail",
            position = { pos.x - 0, pos.y + 2 },
            direction = dirs.northeast,
            force = game.forces.player,
         })
         surf.create_entity({
            name = "curved-rail",
            position = { pos.x + 4, pos.y + 6 },
            direction = dirs.north,
            force = game.forces.player,
         })
         surf.create_entity({
            name = "straight-rail",
            position = { pos.x + 4, pos.y + 10 },
            direction = dirs.north,
            force = game.forces.player,
         })
      end
   elseif dir == dirs.northwest then
      if anchor_dir == dirs.southwest then --2
         surf.create_entity({
            name = "curved-rail",
            position = { pos.x - 2, pos.y - 2 },
            direction = dirs.south,
            force = game.forces.player,
         })
         surf.create_entity({
            name = "straight-rail",
            position = { pos.x - 4, pos.y - 8 },
            direction = dirs.north,
            force = game.forces.player,
         })
      elseif anchor_dir == dirs.northeast then --3
         surf.create_entity({
            name = "straight-rail",
            position = { pos.x - 0, pos.y - 2 },
            direction = dirs.southwest,
            force = game.forces.player,
         })
         surf.create_entity({
            name = "curved-rail",
            position = { pos.x - 2, pos.y - 4 },
            direction = dirs.south,
            force = game.forces.player,
         })
         surf.create_entity({
            name = "straight-rail",
            position = { pos.x - 4, pos.y - 10 },
            direction = dirs.north,
            force = game.forces.player,
         })
      end
   end

   --6 Remove rail units from the player's hand
   game.get_player(pindex).cursor_stack.count = game.get_player(pindex).cursor_stack.count - 2
   if
      (dir == dirs.northeast and anchor_dir == dirs.southeast)
      or (dir == dirs.southwest and anchor_dir == dirs.northwest)
      or (dir == dirs.southeast and anchor_dir == dirs.southwest)
      or (dir == dirs.northwest and anchor_dir == dirs.northeast)
   then
      game.get_player(pindex).cursor_stack.count = game.get_player(pindex).cursor_stack.count - 1
   end
   game.get_player(pindex).clear_cursor()

   --7. Sounds and results
   game.get_player(pindex).play_sound({ path = "entity-build/straight-rail" })
   game.get_player(pindex).play_sound({ path = "entity-build/curved-rail" })
   printout({ "", "Rail turn built 45 degrees right, ", build_comment }, pindex)
   return
end

--Builds a 90 degree rail turn to the right from a horizontal or vertical end rail that is the anchor rail.
function mod.build_rail_turn_right_90_degrees(anchor_rail, pindex)
   local build_comment = ""
   local surf = game.get_player(pindex).surface
   local stack = game.get_player(pindex).cursor_stack
   local stack2 = nil
   local pos = nil
   local dir = -1
   local build_area = nil
   local can_place_all = true
   local is_end_rail

   --1. Firstly, check if the player has enough rails to place this (10 units)
   if not (stack.valid and stack.valid_for_read and stack.name == "rail" and stack.count >= 10) then
      --Check if the inventory has enough
      if storage.players[pindex].inventory.lua_inventory.get_item_count("rail") < 10 then
         game.get_player(pindex).play_sound({ path = "utility/cannot_build" })
         printout({ "fa.rail-need-ten-for-turn" }, pindex)
         return
      else
         --Take from the inventory.
         stack2 = storage.players[pindex].inventory.lua_inventory.find_item_stack("rail")
         game.get_player(pindex).cursor_stack.swap_stack(stack2)
         stack = game.get_player(pindex).cursor_stack
         storage.players[pindex].inventory.max = #storage.players[pindex].inventory.lua_inventory
      end
   end

   --2. Secondly, verify the end rail and find its direction
   is_end_rail, dir, build_comment = Rails.check_end_rail(anchor_rail, pindex)
   if not is_end_rail then
      game.get_player(pindex).play_sound({ path = "utility/cannot_build" })
      printout(build_comment, pindex)
      game.get_player(pindex).clear_cursor()
      return
   end
   pos = anchor_rail.position
   if dir == dirs.northeast or dir == dirs.southeast or dir == dirs.southwest or dir == dirs.northwest then
      game.get_player(pindex).play_sound({ path = "utility/cannot_build" })
      printout({ "fa.rail-horizontal-vertical-only" }, pindex)
      game.get_player(pindex).clear_cursor()
      return
   end

   --3. Clear trees and rocks in the build area
   -- if dir == dirs.north then
   -- build_area = {{pos.x-2, pos.y+2},{pos.x+16,pos.y-16}}
   -- elseif dir == dirs.east then
   -- build_area = {{pos.x-2, pos.y-2},{pos.x+16,pos.y+16}}
   -- elseif dir == dirs.south then
   -- build_area = {{pos.x+2, pos.y-2},{pos.x-16,pos.y+16}}
   -- elseif dir == dirs.west then
   -- build_area = {{pos.x+2, pos.y+2},{pos.x-16,pos.y-16}}
   -- end
   temp1, build_comment = PlayerMiningTools.clear_obstacles_in_circle(pos, 18, pindex)

   --4. Check if every object can be placed
   if dir == dirs.north then
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "curved-rail",
            position = { pos.x + 2, pos.y - 4 },
            direction = dirs.northeast,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x + 4, pos.y - 8 },
            direction = dirs.northwest,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "curved-rail",
            position = { pos.x + 8, pos.y - 10 },
            direction = dirs.west,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x + 12, pos.y - 12 },
            direction = dirs.east,
            force = game.forces.player,
         })
   elseif dir == dirs.east then
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "curved-rail",
            position = { pos.x + 6, pos.y + 2 },
            direction = dirs.southeast,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x + 8, pos.y + 4 },
            direction = dirs.northeast,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "curved-rail",
            position = { pos.x + 12, pos.y + 8 },
            direction = dirs.north,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x + 12, pos.y + 12 },
            direction = dirs.south,
            force = game.forces.player,
         })
   elseif dir == dirs.south then
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "curved-rail",
            position = { pos.x + 0, pos.y + 6 },
            direction = dirs.southwest,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x - 4, pos.y + 8 },
            direction = dirs.southeast,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "curved-rail",
            position = { pos.x - 6, pos.y + 12 },
            direction = dirs.east,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x - 12, pos.y + 12 },
            direction = dirs.west,
            force = game.forces.player,
         })
   elseif dir == dirs.west then
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "curved-rail",
            position = { pos.x - 4, pos.y + 0 },
            direction = dirs.northwest,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x - 8, pos.y - 4 },
            direction = dirs.southwest,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "curved-rail",
            position = { pos.x - 10, pos.y - 6 },
            direction = dirs.south,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x - 12, pos.y - 12 },
            direction = dirs.north,
            force = game.forces.player,
         })
   end

   if not can_place_all then
      game.get_player(pindex).play_sound({ path = "utility/cannot_build" })
      printout({ "fa.rail-building-area-occupied" }, pindex)
      game.get_player(pindex).clear_cursor()
      return
   end

   --5. Build the five rail entities to create the turn
   if dir == dirs.north then
      surf.create_entity({
         name = "curved-rail",
         position = { pos.x + 2, pos.y - 4 },
         direction = dirs.northeast,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x + 4, pos.y - 8 },
         direction = dirs.northwest,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "curved-rail",
         position = { pos.x + 8, pos.y - 10 },
         direction = dirs.west,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x + 12, pos.y - 12 },
         direction = dirs.east,
         force = game.forces.player,
      })
   elseif dir == dirs.east then
      surf.create_entity({
         name = "curved-rail",
         position = { pos.x + 6, pos.y + 2 },
         direction = dirs.southeast,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x + 8, pos.y + 4 },
         direction = dirs.northeast,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "curved-rail",
         position = { pos.x + 12, pos.y + 8 },
         direction = dirs.north,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x + 12, pos.y + 12 },
         direction = dirs.south,
         force = game.forces.player,
      })
   elseif dir == dirs.south then
      surf.create_entity({
         name = "curved-rail",
         position = { pos.x + 0, pos.y + 6 },
         direction = dirs.southwest,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x - 4, pos.y + 8 },
         direction = dirs.southeast,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "curved-rail",
         position = { pos.x - 6, pos.y + 12 },
         direction = dirs.east,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x - 12, pos.y + 12 },
         direction = dirs.west,
         force = game.forces.player,
      })
   elseif dir == dirs.west then
      surf.create_entity({
         name = "curved-rail",
         position = { pos.x - 4, pos.y + 0 },
         direction = dirs.northwest,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x - 8, pos.y - 4 },
         direction = dirs.southwest,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "curved-rail",
         position = { pos.x - 10, pos.y - 6 },
         direction = dirs.south,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x - 12, pos.y - 12 },
         direction = dirs.north,
         force = game.forces.player,
      })
   end

   --6 Remove 10 rail units from the player's hand
   game.get_player(pindex).cursor_stack.count = game.get_player(pindex).cursor_stack.count - 10
   game.get_player(pindex).clear_cursor()

   --7. Sounds and results
   game.get_player(pindex).play_sound({ path = "entity-build/straight-rail" })
   game.get_player(pindex).play_sound({ path = "entity-build/curved-rail" })
   printout({ "", "Rail turn built 90 degrees right, ", build_comment }, pindex)
   return
end

--Builds a 45 degree rail turn to the left from a horizontal or vertical end rail that is the anchor rail.
function mod.build_rail_turn_left_45_degrees(anchor_rail, pindex)
   local build_comment = ""
   local surf = game.get_player(pindex).surface
   local stack = game.get_player(pindex).cursor_stack
   local stack2 = nil
   local pos = nil
   local dir = -1
   local build_area = nil
   local can_place_all = true
   local is_end_rail
   local anchor_dir = anchor_rail.direction

   --1. Firstly, check if the player has enough rails to place this (3 units)
   if not (stack.valid and stack.valid_for_read and stack.name == "rail" and stack.count >= 3) then
      --Check if the inventory has enough
      if storage.players[pindex].inventory.lua_inventory.get_item_count("rail") < 3 then
         game.get_player(pindex).play_sound({ path = "utility/cannot_build" })
         printout({ "fa.rail-need-three-for-turn" }, pindex)
         return
      else
         --Take from the inventory.
         stack2 = storage.players[pindex].inventory.lua_inventory.find_item_stack("rail")
         game.get_player(pindex).cursor_stack.swap_stack(stack2)
         stack = game.get_player(pindex).cursor_stack
         storage.players[pindex].inventory.max = #storage.players[pindex].inventory.lua_inventory
      end
   end

   --2. Secondly, verify the end rail and find its direction
   is_end_rail, dir, build_comment = Rails.check_end_rail(anchor_rail, pindex)
   if not is_end_rail then
      game.get_player(pindex).play_sound({ path = "utility/cannot_build" })
      printout(build_comment, pindex)
      game.get_player(pindex).clear_cursor()
      return
   end
   pos = anchor_rail.position

   --3. Clear trees and rocks in the build area, can be tuned later...
   -- if dir == dirs.north or dir == dirs.northeast then
   -- build_area = {{pos.x+9, pos.y+9},{pos.x-16,pos.y-16}}
   -- elseif dir == dirs.east or dir == dirs.southeast then
   -- build_area = {{pos.x-9, pos.y+9},{pos.x+16,pos.y-16}}
   -- elseif dir == dirs.south or dir == dirs.southwest then
   -- build_area = {{pos.x-9, pos.y-9},{pos.x+16,pos.y+16}}
   -- elseif dir == dirs.west or dir == dirs.northwest then
   -- build_area = {{pos.x+9, pos.y-9},{pos.x-16,pos.y+16}}
   -- end
   temp1, build_comment = PlayerMiningTools.clear_obstacles_in_circle(pos, 12, pindex)

   --4. Check if every object can be placed
   if dir == dirs.north then
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "curved-rail",
            position = { pos.x + 0, pos.y - 4 },
            direction = dirs.north,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x - 4, pos.y - 8 },
            direction = dirs.northeast,
            force = game.forces.player,
         })
   elseif dir == dirs.east then
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "curved-rail",
            position = { pos.x + 6, pos.y + 0 },
            direction = dirs.east,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x + 8, pos.y - 4 },
            direction = dirs.southeast,
            force = game.forces.player,
         })
   elseif dir == dirs.south then
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "curved-rail",
            position = { pos.x + 2, pos.y + 6 },
            direction = dirs.south,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x + 4, pos.y + 8 },
            direction = dirs.southwest,
            force = game.forces.player,
         })
   elseif dir == dirs.west then
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "curved-rail",
            position = { pos.x - 4, pos.y + 2 },
            direction = dirs.west,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x - 8, pos.y + 4 },
            direction = dirs.northwest,
            force = game.forces.player,
         })
   elseif dir == dirs.northeast then
      if anchor_dir == dirs.southeast then --2
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "curved-rail",
               position = { pos.x + 4, pos.y - 2 },
               direction = dirs.southwest,
               force = game.forces.player,
            })
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "straight-rail",
               position = { pos.x + 4, pos.y - 8 },
               direction = dirs.north,
               force = game.forces.player,
            })
      elseif anchor_dir == dirs.northwest then --3
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "straight-rail",
               position = { pos.x + 0, pos.y - 2 },
               direction = dirs.southeast,
               force = game.forces.player,
            })
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "curved-rail",
               position = { pos.x + 4, pos.y - 4 },
               direction = dirs.southwest,
               force = game.forces.player,
            })
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "straight-rail",
               position = { pos.x + 4, pos.y - 10 },
               direction = dirs.north,
               force = game.forces.player,
            })
      end
   elseif dir == dirs.southwest then
      if anchor_dir == dirs.northwest then --2
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "curved-rail",
               position = { pos.x - 2, pos.y + 4 },
               direction = dirs.northeast,
               force = game.forces.player,
            })
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "straight-rail",
               position = { pos.x - 4, pos.y + 8 },
               direction = dirs.north,
               force = game.forces.player,
            })
      elseif anchor_dir == dirs.southeast then --3
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "straight-rail",
               position = { pos.x - 0, pos.y + 2 },
               direction = dirs.northwest,
               force = game.forces.player,
            })
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "curved-rail",
               position = { pos.x - 2, pos.y + 6 },
               direction = dirs.northeast,
               force = game.forces.player,
            })
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "straight-rail",
               position = { pos.x - 4, pos.y + 10 },
               direction = dirs.north,
               force = game.forces.player,
            })
      end
   elseif dir == dirs.southeast then
      if anchor_dir == dirs.southwest then --2
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "curved-rail",
               position = { pos.x + 4, pos.y + 4 },
               direction = dirs.northwest,
               force = game.forces.player,
            })
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "straight-rail",
               position = { pos.x + 8, pos.y + 4 },
               direction = dirs.east,
               force = game.forces.player,
            })
      elseif anchor_dir == dirs.northeast then --3
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "straight-rail",
               position = { pos.x + 2, pos.y + 0 },
               direction = dirs.southwest,
               force = game.forces.player,
            })
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "curved-rail",
               position = { pos.x + 6, pos.y + 4 },
               direction = dirs.northwest,
               force = game.forces.player,
            })
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "straight-rail",
               position = { pos.x + 10, pos.y + 4 },
               direction = dirs.east,
               force = game.forces.player,
            })
      end
   elseif dir == dirs.northwest then
      if anchor_dir == dirs.northeast then --2
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "curved-rail",
               position = { pos.x - 2, pos.y - 2 },
               direction = dirs.southeast,
               force = game.forces.player,
            })
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "straight-rail",
               position = { pos.x - 8, pos.y - 4 },
               direction = dirs.east,
               force = game.forces.player,
            })
      elseif anchor_dir == dirs.southwest then --3
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "straight-rail",
               position = { pos.x - 2, pos.y - 0 },
               direction = dirs.northeast,
               force = game.forces.player,
            })
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "curved-rail",
               position = { pos.x - 4, pos.y - 2 },
               direction = dirs.southeast,
               force = game.forces.player,
            })
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "straight-rail",
               position = { pos.x - 10, pos.y - 4 },
               direction = dirs.east,
               force = game.forces.player,
            })
      end
   end

   if not can_place_all then
      game.get_player(pindex).play_sound({ path = "utility/cannot_build" })
      printout({ "fa.rail-building-area-occupied" }, pindex)
      game.get_player(pindex).clear_cursor()
      return
   end

   --5. Build the rail entities to create the turn
   if dir == dirs.north then
      surf.create_entity({
         name = "curved-rail",
         position = { pos.x + 0, pos.y - 4 },
         direction = dirs.north,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x - 4, pos.y - 8 },
         direction = dirs.northeast,
         force = game.forces.player,
      })
   elseif dir == dirs.east then
      surf.create_entity({
         name = "curved-rail",
         position = { pos.x + 6, pos.y + 0 },
         direction = dirs.east,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x + 8, pos.y - 4 },
         direction = dirs.southeast,
         force = game.forces.player,
      })
   elseif dir == dirs.south then
      surf.create_entity({
         name = "curved-rail",
         position = { pos.x + 2, pos.y + 6 },
         direction = dirs.south,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x + 4, pos.y + 8 },
         direction = dirs.southwest,
         force = game.forces.player,
      })
   elseif dir == dirs.west then
      surf.create_entity({
         name = "curved-rail",
         position = { pos.x - 4, pos.y + 2 },
         direction = dirs.west,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x - 8, pos.y + 4 },
         direction = dirs.northwest,
         force = game.forces.player,
      })
   elseif dir == dirs.northeast then
      if anchor_dir == dirs.southeast then --2
         surf.create_entity({
            name = "curved-rail",
            position = { pos.x + 4, pos.y - 2 },
            direction = dirs.southwest,
            force = game.forces.player,
         })
         surf.create_entity({
            name = "straight-rail",
            position = { pos.x + 4, pos.y - 8 },
            direction = dirs.north,
            force = game.forces.player,
         })
      elseif anchor_dir == dirs.northwest then --3
         surf.create_entity({
            name = "straight-rail",
            position = { pos.x + 0, pos.y - 2 },
            direction = dirs.southeast,
            force = game.forces.player,
         })
         surf.create_entity({
            name = "curved-rail",
            position = { pos.x + 4, pos.y - 4 },
            direction = dirs.southwest,
            force = game.forces.player,
         })
         surf.create_entity({
            name = "straight-rail",
            position = { pos.x + 4, pos.y - 10 },
            direction = dirs.north,
            force = game.forces.player,
         })
      end
   elseif dir == dirs.southwest then
      if anchor_dir == dirs.northwest then --2
         surf.create_entity({
            name = "curved-rail",
            position = { pos.x - 2, pos.y + 4 },
            direction = dirs.northeast,
            force = game.forces.player,
         })
         surf.create_entity({
            name = "straight-rail",
            position = { pos.x - 4, pos.y + 8 },
            direction = dirs.north,
            force = game.forces.player,
         })
      elseif anchor_dir == dirs.southeast then --3
         surf.create_entity({
            name = "straight-rail",
            position = { pos.x - 0, pos.y + 2 },
            direction = dirs.northwest,
            force = game.forces.player,
         })
         surf.create_entity({
            name = "curved-rail",
            position = { pos.x - 2, pos.y + 6 },
            direction = dirs.northeast,
            force = game.forces.player,
         })
         surf.create_entity({
            name = "straight-rail",
            position = { pos.x - 4, pos.y + 10 },
            direction = dirs.north,
            force = game.forces.player,
         })
      end
   elseif dir == dirs.southeast then
      if anchor_dir == dirs.southwest then --2
         surf.create_entity({
            name = "curved-rail",
            position = { pos.x + 4, pos.y + 4 },
            direction = dirs.northwest,
            force = game.forces.player,
         })
         surf.create_entity({
            name = "straight-rail",
            position = { pos.x + 8, pos.y + 4 },
            direction = dirs.east,
            force = game.forces.player,
         })
      elseif anchor_dir == dirs.northeast then --3
         surf.create_entity({
            name = "straight-rail",
            position = { pos.x + 2, pos.y + 0 },
            direction = dirs.southwest,
            force = game.forces.player,
         })
         surf.create_entity({
            name = "curved-rail",
            position = { pos.x + 6, pos.y + 4 },
            direction = dirs.northwest,
            force = game.forces.player,
         })
         surf.create_entity({
            name = "straight-rail",
            position = { pos.x + 10, pos.y + 4 },
            direction = dirs.east,
            force = game.forces.player,
         })
      end
   elseif dir == dirs.northwest then
      if anchor_dir == dirs.northeast then --2
         surf.create_entity({
            name = "curved-rail",
            position = { pos.x - 2, pos.y - 2 },
            direction = dirs.southeast,
            force = game.forces.player,
         })
         surf.create_entity({
            name = "straight-rail",
            position = { pos.x - 8, pos.y - 4 },
            direction = dirs.east,
            force = game.forces.player,
         })
      elseif anchor_dir == dirs.southwest then --3
         surf.create_entity({
            name = "straight-rail",
            position = { pos.x - 2, pos.y - 0 },
            direction = dirs.northeast,
            force = game.forces.player,
         })
         surf.create_entity({
            name = "curved-rail",
            position = { pos.x - 4, pos.y - 2 },
            direction = dirs.southeast,
            force = game.forces.player,
         })
         surf.create_entity({
            name = "straight-rail",
            position = { pos.x - 10, pos.y - 4 },
            direction = dirs.east,
            force = game.forces.player,
         })
      end
   end

   --6 Remove rail units from the player's hand
   game.get_player(pindex).cursor_stack.count = game.get_player(pindex).cursor_stack.count - 2
   if
      (dir == dirs.northeast and anchor_dir == dirs.northwest)
      or (dir == dirs.southwest and anchor_dir == dirs.southeast)
      or (dir == dirs.southeast and anchor_dir == dirs.northeast)
      or (dir == dirs.northwest and anchor_dir == dirs.southwest)
   then
      game.get_player(pindex).cursor_stack.count = game.get_player(pindex).cursor_stack.count - 1
   end
   game.get_player(pindex).clear_cursor()

   --7. Sounds and results
   game.get_player(pindex).play_sound({ path = "entity-build/straight-rail" })
   game.get_player(pindex).play_sound({ path = "entity-build/curved-rail" })
   printout({ "", "Rail turn built 45 degrees left, ", build_comment }, pindex)
   return
end

--Builds a 90 degree rail turn to the left from a horizontal or vertical end rail that is the anchor rail.
function mod.build_rail_turn_left_90_degrees(anchor_rail, pindex)
   local build_comment = ""
   local surf = game.get_player(pindex).surface
   local stack = game.get_player(pindex).cursor_stack
   local stack2 = nil
   local pos = nil
   local dir = -1
   local build_area = nil
   local can_place_all = true
   local is_end_rail

   --1. Firstly, check if the player has enough rails to place this (10 units)
   if not (stack.valid and stack.valid_for_read and stack.name == "rail" and stack.count > 10) then
      --Check if the inventory has enough
      if storage.players[pindex].inventory.lua_inventory.get_item_count("rail") < 10 then
         game.get_player(pindex).play_sound({ path = "utility/cannot_build" })
         printout({ "fa.rail-need-ten-for-turn" }, pindex)
         return
      else
         --Take from the inventory.
         stack2 = storage.players[pindex].inventory.lua_inventory.find_item_stack("rail")
         game.get_player(pindex).cursor_stack.swap_stack(stack2)
         stack = game.get_player(pindex).cursor_stack
         storage.players[pindex].inventory.max = #storage.players[pindex].inventory.lua_inventory
      end
   end

   --2. Secondly, verify the end rail and find its direction
   is_end_rail, dir, build_comment = Rails.check_end_rail(anchor_rail, pindex)
   if not is_end_rail then
      game.get_player(pindex).play_sound({ path = "utility/cannot_build" })
      printout(build_comment, pindex)
      game.get_player(pindex).clear_cursor()
      return
   end
   pos = anchor_rail.position
   if dir == dirs.northeast or dir == dirs.southeast or dir == dirs.southwest or dir == dirs.northwest then
      game.get_player(pindex).play_sound({ path = "utility/cannot_build" })
      printout({ "fa.rail-horizontal-vertical-only" }, pindex)
      game.get_player(pindex).clear_cursor()
      return
   end

   --3. Clear trees and rocks in the build area
   -- if dir == dirs.north then
   -- build_area = {{pos.x+2, pos.y+2},{pos.x-16,pos.y-16}}
   -- elseif dir == dirs.east then
   -- build_area = {{pos.x+2, pos.y+2},{pos.x+16,pos.y-16}}
   -- elseif dir == dirs.south then
   -- build_area = {{pos.x+2, pos.y+2},{pos.x+16,pos.y+16}}
   -- elseif dir == dirs.west then
   -- build_area = {{pos.x+2, pos.y+2},{pos.x-16,pos.y+16}}
   -- end
   temp1, build_comment = PlayerMiningTools.clear_obstacles_in_circle(pos, 18, pindex)

   --4. Check if every object can be placed
   if dir == dirs.north then
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "curved-rail",
            position = { pos.x + 0, pos.y - 4 },
            direction = dirs.north,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x - 4, pos.y - 8 },
            direction = dirs.northeast,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "curved-rail",
            position = { pos.x - 6, pos.y - 10 },
            direction = dirs.southeast,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x - 12, pos.y - 12 },
            direction = dirs.east,
            force = game.forces.player,
         })
   elseif dir == dirs.east then
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "curved-rail",
            position = { pos.x + 6, pos.y + 0 },
            direction = dirs.east,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x + 8, pos.y - 4 },
            direction = dirs.southeast,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "curved-rail",
            position = { pos.x + 12, pos.y - 6 },
            direction = dirs.southwest,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x + 12, pos.y - 12 },
            direction = dirs.south,
            force = game.forces.player,
         })
   elseif dir == dirs.south then
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "curved-rail",
            position = { pos.x + 2, pos.y + 6 },
            direction = dirs.south,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x + 4, pos.y + 8 },
            direction = dirs.southwest,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "curved-rail",
            position = { pos.x + 8, pos.y + 12 },
            direction = dirs.northwest,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x + 12, pos.y + 12 },
            direction = dirs.west,
            force = game.forces.player,
         })
   elseif dir == dirs.west then
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "curved-rail",
            position = { pos.x - 4, pos.y + 2 },
            direction = dirs.west,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x - 8, pos.y + 4 },
            direction = dirs.northwest,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "curved-rail",
            position = { pos.x - 10, pos.y + 8 },
            direction = dirs.northeast,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x - 12, pos.y + 12 },
            direction = dirs.north,
            force = game.forces.player,
         })
   end

   if not can_place_all then
      game.get_player(pindex).play_sound({ path = "utility/cannot_build" })
      printout({ "fa.rail-building-area-occupied" }, pindex)
      game.get_player(pindex).clear_cursor()
      return
   end

   --5. Build the five rail entities to create the turn
   if dir == dirs.north then
      surf.create_entity({
         name = "curved-rail",
         position = { pos.x + 0, pos.y - 4 },
         direction = dirs.north,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x - 4, pos.y - 8 },
         direction = dirs.northeast,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "curved-rail",
         position = { pos.x - 6, pos.y - 10 },
         direction = dirs.southeast,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x - 12, pos.y - 12 },
         direction = dirs.east,
         force = game.forces.player,
      })
   elseif dir == dirs.east then
      surf.create_entity({
         name = "curved-rail",
         position = { pos.x + 6, pos.y + 0 },
         direction = dirs.east,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x + 8, pos.y - 4 },
         direction = dirs.southeast,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "curved-rail",
         position = { pos.x + 12, pos.y - 6 },
         direction = dirs.southwest,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x + 12, pos.y - 12 },
         direction = dirs.south,
         force = game.forces.player,
      })
   elseif dir == dirs.south then
      surf.create_entity({
         name = "curved-rail",
         position = { pos.x + 2, pos.y + 6 },
         direction = dirs.south,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x + 4, pos.y + 8 },
         direction = dirs.southwest,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "curved-rail",
         position = { pos.x + 8, pos.y + 12 },
         direction = dirs.northwest,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x + 12, pos.y + 12 },
         direction = dirs.west,
         force = game.forces.player,
      })
   elseif dir == dirs.west then
      surf.create_entity({
         name = "curved-rail",
         position = { pos.x - 4, pos.y + 2 },
         direction = dirs.west,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x - 8, pos.y + 4 },
         direction = dirs.northwest,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "curved-rail",
         position = { pos.x - 10, pos.y + 8 },
         direction = dirs.northeast,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x - 12, pos.y + 12 },
         direction = dirs.north,
         force = game.forces.player,
      })
   end

   --6 Remove 10 rail units from the player's hand
   game.get_player(pindex).cursor_stack.count = game.get_player(pindex).cursor_stack.count - 10
   game.get_player(pindex).clear_cursor()

   --7. Sounds and results
   game.get_player(pindex).play_sound({ path = "entity-build/straight-rail" })
   game.get_player(pindex).play_sound({ path = "entity-build/curved-rail" })
   printout({ "", "Rail turn built 90 degrees left, ", build_comment }, pindex)
   return
end

--Builds a fork at the end rail with up to three exits: 45 degrees left, and 45 degrees right, or forward.
function mod.build_fork_at_end_rail(anchor_rail, pindex, include_forward, include_left, include_right)
   local build_comment = ""
   local surf = game.get_player(pindex).surface
   local stack = game.get_player(pindex).cursor_stack
   local stack2 = nil
   local pos = nil
   local dir = -1
   local build_area = nil
   local can_place_all = true
   local is_end_rail
   local anchor_dir = anchor_rail.direction
   include_forward = include_forward or false
   include_left = include_left or false
   include_right = include_right or false

   --1. Firstly, check if the player has enough rails to place this (5 units)
   if not (stack.valid and stack.valid_for_read and stack.name == "rail" and stack.count >= 5) then
      --Check if the inventory has enough
      if storage.players[pindex].inventory.lua_inventory.get_item_count("rail") < 5 then
         game.get_player(pindex).play_sound({ path = "utility/cannot_build" })
         printout({ "fa.rail-need-five-for-turn" }, pindex)
         return
      else
         --Take from the inventory.
         stack2 = storage.players[pindex].inventory.lua_inventory.find_item_stack("rail")
         game.get_player(pindex).cursor_stack.swap_stack(stack2)
         stack = game.get_player(pindex).cursor_stack
         storage.players[pindex].inventory.max = #storage.players[pindex].inventory.lua_inventory
      end
   end

   --2. Secondly, verify the end rail and find its direction
   is_end_rail, dir, build_comment = Rails.check_end_rail(anchor_rail, pindex)
   if not is_end_rail then
      game.get_player(pindex).play_sound({ path = "utility/cannot_build" })
      printout(build_comment, pindex)
      game.get_player(pindex).clear_cursor()
      return
   end
   pos = anchor_rail.position

   --3. Clear trees and rocks in the build area, can be tuned later...
   -- if dir == dirs.north or dir == dirs.northeast then
   -- build_area = {{pos.x+9, pos.y+9},{pos.x-16,pos.y-16}}
   -- elseif dir == dirs.east or dir == dirs.southeast then
   -- build_area = {{pos.x-9, pos.y+9},{pos.x+16,pos.y-16}}
   -- elseif dir == dirs.south or dir == dirs.southwest then
   -- build_area = {{pos.x-9, pos.y-9},{pos.x+16,pos.y+16}}
   -- elseif dir == dirs.west or dir == dirs.northwest then
   -- build_area = {{pos.x+9, pos.y-9},{pos.x-16,pos.y+16}}
   -- end
   temp1, build_comment = PlayerMiningTools.clear_obstacles_in_circle(pos, 14, pindex)

   --4A. Check if every object can be placed (LEFT)
   if include_left then
      if dir == dirs.north then
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "curved-rail",
               position = { pos.x + 0, pos.y - 4 },
               direction = dirs.north,
               force = game.forces.player,
            })
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "straight-rail",
               position = { pos.x - 4, pos.y - 8 },
               direction = dirs.northeast,
               force = game.forces.player,
            })
      elseif dir == dirs.east then
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "curved-rail",
               position = { pos.x + 6, pos.y + 0 },
               direction = dirs.east,
               force = game.forces.player,
            })
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "straight-rail",
               position = { pos.x + 8, pos.y - 4 },
               direction = dirs.southeast,
               force = game.forces.player,
            })
      elseif dir == dirs.south then
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "curved-rail",
               position = { pos.x + 2, pos.y + 6 },
               direction = dirs.south,
               force = game.forces.player,
            })
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "straight-rail",
               position = { pos.x + 4, pos.y + 8 },
               direction = dirs.southwest,
               force = game.forces.player,
            })
      elseif dir == dirs.west then
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "curved-rail",
               position = { pos.x - 4, pos.y + 2 },
               direction = dirs.west,
               force = game.forces.player,
            })
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "straight-rail",
               position = { pos.x - 8, pos.y + 4 },
               direction = dirs.northwest,
               force = game.forces.player,
            })
      elseif dir == dirs.northeast then
         if anchor_dir == dirs.southeast then --2
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "curved-rail",
                  position = { pos.x + 4, pos.y - 2 },
                  direction = dirs.southwest,
                  force = game.forces.player,
               })
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x + 4, pos.y - 8 },
                  direction = dirs.north,
                  force = game.forces.player,
               })
         elseif anchor_dir == dirs.northwest then --3
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x + 0, pos.y - 2 },
                  direction = dirs.southeast,
                  force = game.forces.player,
               })
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "curved-rail",
                  position = { pos.x + 4, pos.y - 4 },
                  direction = dirs.southwest,
                  force = game.forces.player,
               })
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x + 4, pos.y - 10 },
                  direction = dirs.north,
                  force = game.forces.player,
               })
         end
      elseif dir == dirs.southwest then
         if anchor_dir == dirs.northwest then --2
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "curved-rail",
                  position = { pos.x - 2, pos.y + 4 },
                  direction = dirs.northeast,
                  force = game.forces.player,
               })
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x - 4, pos.y + 8 },
                  direction = dirs.north,
                  force = game.forces.player,
               })
         elseif anchor_dir == dirs.southeast then --3
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x - 0, pos.y + 2 },
                  direction = dirs.northwest,
                  force = game.forces.player,
               })
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "curved-rail",
                  position = { pos.x - 2, pos.y + 6 },
                  direction = dirs.northeast,
                  force = game.forces.player,
               })
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x - 4, pos.y + 10 },
                  direction = dirs.north,
                  force = game.forces.player,
               })
         end
      elseif dir == dirs.southeast then
         if anchor_dir == dirs.southwest then --2
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "curved-rail",
                  position = { pos.x + 4, pos.y + 4 },
                  direction = dirs.northwest,
                  force = game.forces.player,
               })
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x + 8, pos.y + 4 },
                  direction = dirs.east,
                  force = game.forces.player,
               })
         elseif anchor_dir == dirs.northeast then --3
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x + 2, pos.y + 0 },
                  direction = dirs.southwest,
                  force = game.forces.player,
               })
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "curved-rail",
                  position = { pos.x + 6, pos.y + 4 },
                  direction = dirs.northwest,
                  force = game.forces.player,
               })
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x + 10, pos.y + 4 },
                  direction = dirs.east,
                  force = game.forces.player,
               })
         end
      elseif dir == dirs.northwest then
         if anchor_dir == dirs.northeast then --2
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "curved-rail",
                  position = { pos.x - 2, pos.y - 2 },
                  direction = dirs.southeast,
                  force = game.forces.player,
               })
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x - 8, pos.y - 4 },
                  direction = dirs.east,
                  force = game.forces.player,
               })
         elseif anchor_dir == dirs.southwest then --3
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x - 2, pos.y - 0 },
                  direction = dirs.northeast,
                  force = game.forces.player,
               })
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "curved-rail",
                  position = { pos.x - 4, pos.y - 2 },
                  direction = dirs.southeast,
                  force = game.forces.player,
               })
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x - 10, pos.y - 4 },
                  direction = dirs.east,
                  force = game.forces.player,
               })
         end
      end
   end

   --4B. Check if every object can be placed (RIGHT)
   if include_right then
      if dir == dirs.north then
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "curved-rail",
               position = { pos.x + 2, pos.y - 4 },
               direction = dirs.northeast,
               force = game.forces.player,
            })
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "straight-rail",
               position = { pos.x + 4, pos.y - 8 },
               direction = dirs.northwest,
               force = game.forces.player,
            })
      elseif dir == dirs.east then
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "curved-rail",
               position = { pos.x + 6, pos.y + 2 },
               direction = dirs.southeast,
               force = game.forces.player,
            })
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "straight-rail",
               position = { pos.x + 8, pos.y + 4 },
               direction = dirs.northeast,
               force = game.forces.player,
            })
      elseif dir == dirs.south then
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "curved-rail",
               position = { pos.x + 0, pos.y + 6 },
               direction = dirs.southwest,
               force = game.forces.player,
            })
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "straight-rail",
               position = { pos.x - 4, pos.y + 8 },
               direction = dirs.southeast,
               force = game.forces.player,
            })
      elseif dir == dirs.west then
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "curved-rail",
               position = { pos.x - 4, pos.y + 0 },
               direction = dirs.northwest,
               force = game.forces.player,
            })
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "straight-rail",
               position = { pos.x - 8, pos.y - 4 },
               direction = dirs.southwest,
               force = game.forces.player,
            })
      elseif dir == dirs.northeast then
         if anchor_dir == dirs.northwest then
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "curved-rail",
                  position = { pos.x + 4, pos.y - 2 },
                  direction = dirs.west,
                  force = game.forces.player,
               })
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x + 8, pos.y - 4 },
                  direction = dirs.east,
                  force = game.forces.player,
               })
         elseif anchor_dir == dirs.southeast then
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x + 2, pos.y - 0 },
                  direction = dirs.northwest,
                  force = game.forces.player,
               })
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "curved-rail",
                  position = { pos.x + 6, pos.y - 2 },
                  direction = dirs.west,
                  force = game.forces.player,
               })
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x + 10, pos.y - 4 },
                  direction = dirs.east,
                  force = game.forces.player,
               })
         end
      elseif dir == dirs.southwest then
         if anchor_dir == dirs.southeast then --2
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "curved-rail",
                  position = { pos.x - 2, pos.y + 4 },
                  direction = dirs.east,
                  force = game.forces.player,
               })
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x - 8, pos.y + 4 },
                  direction = dirs.east,
                  force = game.forces.player,
               })
         elseif anchor_dir == dirs.northwest then --3
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x - 2, pos.y + 0 },
                  direction = dirs.southeast,
                  force = game.forces.player,
               })
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "curved-rail",
                  position = { pos.x - 4, pos.y + 4 },
                  direction = dirs.east,
                  force = game.forces.player,
               })
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x - 10, pos.y + 4 },
                  direction = dirs.east,
                  force = game.forces.player,
               })
         end
      elseif dir == dirs.southeast then
         if anchor_dir == dirs.northeast then --2
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "curved-rail",
                  position = { pos.x + 4, pos.y + 4 },
                  direction = dirs.north,
                  force = game.forces.player,
               })
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x + 4, pos.y + 8 },
                  direction = dirs.north,
                  force = game.forces.player,
               })
         elseif anchor_dir == dirs.southwest then --3
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x - 0, pos.y + 2 },
                  direction = dirs.northeast,
                  force = game.forces.player,
               })
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "curved-rail",
                  position = { pos.x + 4, pos.y + 6 },
                  direction = dirs.north,
                  force = game.forces.player,
               })
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x + 4, pos.y + 10 },
                  direction = dirs.north,
                  force = game.forces.player,
               })
         end
      elseif dir == dirs.northwest then
         if anchor_dir == dirs.southwest then --2
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "curved-rail",
                  position = { pos.x - 2, pos.y - 2 },
                  direction = dirs.south,
                  force = game.forces.player,
               })
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x - 4, pos.y - 8 },
                  direction = dirs.north,
                  force = game.forces.player,
               })
         elseif anchor_dir == dirs.northeast then --3
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x - 0, pos.y - 2 },
                  direction = dirs.southwest,
                  force = game.forces.player,
               })
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "curved-rail",
                  position = { pos.x - 2, pos.y - 4 },
                  direction = dirs.south,
                  force = game.forces.player,
               })
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x - 4, pos.y - 10 },
                  direction = dirs.north,
                  force = game.forces.player,
               })
         end
      end
   end

   --4C. Check if can append forward
   if include_forward then
      if dir == dirs.north then
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "straight-rail",
               position = { pos.x - 0, pos.y - 2 },
               direction = dir,
               force = game.forces.player,
            })
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "straight-rail",
               position = { pos.x - 0, pos.y - 4 },
               direction = dir,
               force = game.forces.player,
            })
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "straight-rail",
               position = { pos.x - 0, pos.y - 6 },
               direction = dir,
               force = game.forces.player,
            })
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "straight-rail",
               position = { pos.x - 0, pos.y - 8 },
               direction = dir,
               force = game.forces.player,
            })
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "straight-rail",
               position = { pos.x - 0, pos.y - 10 },
               direction = dir,
               force = game.forces.player,
            })
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "straight-rail",
               position = { pos.x - 0, pos.y - 12 },
               direction = dir,
               force = game.forces.player,
            })
      elseif dir == dirs.east then
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "straight-rail",
               position = { pos.x + 2, pos.y - 0 },
               direction = dir,
               force = game.forces.player,
            })
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "straight-rail",
               position = { pos.x + 4, pos.y - 0 },
               direction = dir,
               force = game.forces.player,
            })
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "straight-rail",
               position = { pos.x + 6, pos.y - 0 },
               direction = dir,
               force = game.forces.player,
            })
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "straight-rail",
               position = { pos.x + 8, pos.y - 0 },
               direction = dir,
               force = game.forces.player,
            })
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "straight-rail",
               position = { pos.x + 10, pos.y - 0 },
               direction = dir,
               force = game.forces.player,
            })
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "straight-rail",
               position = { pos.x + 12, pos.y - 0 },
               direction = dir,
               force = game.forces.player,
            })
      elseif dir == dirs.south then
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "straight-rail",
               position = { pos.x - 0, pos.y + 2 },
               direction = dir,
               force = game.forces.player,
            })
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "straight-rail",
               position = { pos.x - 0, pos.y + 4 },
               direction = dir,
               force = game.forces.player,
            })
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "straight-rail",
               position = { pos.x - 0, pos.y + 6 },
               direction = dir,
               force = game.forces.player,
            })
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "straight-rail",
               position = { pos.x - 0, pos.y + 8 },
               direction = dir,
               force = game.forces.player,
            })
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "straight-rail",
               position = { pos.x - 0, pos.y + 10 },
               direction = dir,
               force = game.forces.player,
            })
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "straight-rail",
               position = { pos.x - 0, pos.y + 12 },
               direction = dir,
               force = game.forces.player,
            })
      elseif dir == dirs.west then
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "straight-rail",
               position = { pos.x - 2, pos.y - 0 },
               direction = dir,
               force = game.forces.player,
            })
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "straight-rail",
               position = { pos.x - 4, pos.y - 0 },
               direction = dir,
               force = game.forces.player,
            })
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "straight-rail",
               position = { pos.x - 6, pos.y - 0 },
               direction = dir,
               force = game.forces.player,
            })
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "straight-rail",
               position = { pos.x - 8, pos.y - 0 },
               direction = dir,
               force = game.forces.player,
            })
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "straight-rail",
               position = { pos.x - 10, pos.y - 0 },
               direction = dir,
               force = game.forces.player,
            })
         can_place_all = can_place_all
            and surf.can_place_entity({
               name = "straight-rail",
               position = { pos.x - 12, pos.y - 0 },
               direction = dir,
               force = game.forces.player,
            })
      elseif dir == dirs.northeast then
         if anchor_dir == dirs.southeast then --2
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x + 2, pos.y - 0 },
                  direction = dirs.northwest,
                  force = game.forces.player,
               })
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x + 2, pos.y - 2 },
                  direction = dirs.southeast,
                  force = game.forces.player,
               })
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x + 4, pos.y - 2 },
                  direction = dirs.northwest,
                  force = game.forces.player,
               })
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x + 4, pos.y - 4 },
                  direction = dirs.southeast,
                  force = game.forces.player,
               })
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x + 6, pos.y - 4 },
                  direction = dirs.northwest,
                  force = game.forces.player,
               })
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x + 6, pos.y - 6 },
                  direction = dirs.southeast,
                  force = game.forces.player,
               })
         elseif anchor_dir == dirs.northwest then --3
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x + 0, pos.y - 2 },
                  direction = dirs.southeast,
                  force = game.forces.player,
               })
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x + 2, pos.y - 2 },
                  direction = dirs.northwest,
                  force = game.forces.player,
               })
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x + 2, pos.y - 4 },
                  direction = dirs.southeast,
                  force = game.forces.player,
               })
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x + 4, pos.y - 4 },
                  direction = dirs.northwest,
                  force = game.forces.player,
               })
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x + 4, pos.y - 6 },
                  direction = dirs.southeast,
                  force = game.forces.player,
               })
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x + 6, pos.y - 6 },
                  direction = dirs.northwest,
                  force = game.forces.player,
               })
         end
      elseif dir == dirs.southeast then
         if anchor_dir == dirs.southwest then
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x + 0, pos.y + 2 },
                  direction = dirs.northeast,
                  force = game.forces.player,
               })
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x + 2, pos.y + 2 },
                  direction = dirs.southwest,
                  force = game.forces.player,
               })
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x + 2, pos.y + 4 },
                  direction = dirs.northeast,
                  force = game.forces.player,
               })
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x + 4, pos.y + 4 },
                  direction = dirs.southwest,
                  force = game.forces.player,
               })
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x + 4, pos.y + 6 },
                  direction = dirs.northeast,
                  force = game.forces.player,
               })
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x + 6, pos.y + 6 },
                  direction = dirs.southwest,
                  force = game.forces.player,
               })
         elseif anchor_dir == dirs.northeast then
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x + 2, pos.y + 0 },
                  direction = dirs.southwest,
                  force = game.forces.player,
               })
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x + 2, pos.y + 2 },
                  direction = dirs.northeast,
                  force = game.forces.player,
               })
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x + 4, pos.y + 2 },
                  direction = dirs.southwest,
                  force = game.forces.player,
               })
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x + 4, pos.y + 4 },
                  direction = dirs.northeast,
                  force = game.forces.player,
               })
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x + 6, pos.y + 4 },
                  direction = dirs.southwest,
                  force = game.forces.player,
               })
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x + 6, pos.y + 6 },
                  direction = dirs.northeast,
                  force = game.forces.player,
               })
         end
      elseif dir == dirs.southwest then
         if anchor_dir == dirs.southeast then --2
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x + 0, pos.y + 2 },
                  direction = dirs.northwest,
                  force = game.forces.player,
               })
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x - 2, pos.y + 2 },
                  direction = dirs.southeast,
                  force = game.forces.player,
               })
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x - 2, pos.y + 4 },
                  direction = dirs.northwest,
                  force = game.forces.player,
               })
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x - 4, pos.y + 4 },
                  direction = dirs.southeast,
                  force = game.forces.player,
               })
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x - 4, pos.y + 6 },
                  direction = dirs.northwest,
                  force = game.forces.player,
               })
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x - 6, pos.y + 6 },
                  direction = dirs.southeast,
                  force = game.forces.player,
               })
         elseif anchor_dir == dirs.northwest then --3
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x - 2, pos.y + 0 },
                  direction = dirs.southeast,
                  force = game.forces.player,
               })
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x - 2, pos.y + 2 },
                  direction = dirs.northwest,
                  force = game.forces.player,
               })
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x - 4, pos.y + 2 },
                  direction = dirs.southeast,
                  force = game.forces.player,
               })
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x - 4, pos.y + 4 },
                  direction = dirs.northwest,
                  force = game.forces.player,
               })
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x - 6, pos.y + 4 },
                  direction = dirs.southeast,
                  force = game.forces.player,
               })
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x - 6, pos.y + 6 },
                  direction = dirs.northwest,
                  force = game.forces.player,
               })
         end
      elseif dir == dirs.northwest then
         if anchor_dir == dirs.southwest then
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x - 2, pos.y - 0 },
                  direction = dirs.northeast,
                  force = game.forces.player,
               })
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x - 2, pos.y - 2 },
                  direction = dirs.southwest,
                  force = game.forces.player,
               })
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x - 4, pos.y - 2 },
                  direction = dirs.northeast,
                  force = game.forces.player,
               })
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x - 4, pos.y - 4 },
                  direction = dirs.southwest,
                  force = game.forces.player,
               })
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x - 6, pos.y - 4 },
                  direction = dirs.northeast,
                  force = game.forces.player,
               })
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x - 6, pos.y - 6 },
                  direction = dirs.southwest,
                  force = game.forces.player,
               })
         elseif anchor_dir == dirs.northeast then
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x - 0, pos.y - 2 },
                  direction = dirs.southwest,
                  force = game.forces.player,
               })
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x - 2, pos.y - 2 },
                  direction = dirs.northeast,
                  force = game.forces.player,
               })
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x - 2, pos.y - 4 },
                  direction = dirs.southwest,
                  force = game.forces.player,
               })
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x - 4, pos.y - 4 },
                  direction = dirs.northeast,
                  force = game.forces.player,
               })
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x - 4, pos.y - 6 },
                  direction = dirs.southwest,
                  force = game.forces.player,
               })
            can_place_all = can_place_all
               and surf.can_place_entity({
                  name = "straight-rail",
                  position = { pos.x - 6, pos.y - 6 },
                  direction = dirs.northeast,
                  force = game.forces.player,
               })
         end
      else
         game.get_player(pindex).play_sound({ path = "utility/cannot_build" })
         printout({ "fa.rail-error-placement-not-defined" }, pindex)
         game.get_player(pindex).clear_cursor()
         return
      end
   end

   --4D. Process check results
   if not can_place_all then
      game.get_player(pindex).play_sound({ path = "utility/cannot_build" })
      printout({ "fa.rail-building-area-occupied" }, pindex)
      game.get_player(pindex).clear_cursor()
      return
   end

   --5A. Build the rail entities to create the turn (LEFT)
   if include_left then
      if dir == dirs.north then
         surf.create_entity({
            name = "curved-rail",
            position = { pos.x + 0, pos.y - 4 },
            direction = dirs.north,
            force = game.forces.player,
         })
         surf.create_entity({
            name = "straight-rail",
            position = { pos.x - 4, pos.y - 8 },
            direction = dirs.northeast,
            force = game.forces.player,
         })
      elseif dir == dirs.east then
         surf.create_entity({
            name = "curved-rail",
            position = { pos.x + 6, pos.y + 0 },
            direction = dirs.east,
            force = game.forces.player,
         })
         surf.create_entity({
            name = "straight-rail",
            position = { pos.x + 8, pos.y - 4 },
            direction = dirs.southeast,
            force = game.forces.player,
         })
      elseif dir == dirs.south then
         surf.create_entity({
            name = "curved-rail",
            position = { pos.x + 2, pos.y + 6 },
            direction = dirs.south,
            force = game.forces.player,
         })
         surf.create_entity({
            name = "straight-rail",
            position = { pos.x + 4, pos.y + 8 },
            direction = dirs.southwest,
            force = game.forces.player,
         })
      elseif dir == dirs.west then
         surf.create_entity({
            name = "curved-rail",
            position = { pos.x - 4, pos.y + 2 },
            direction = dirs.west,
            force = game.forces.player,
         })
         surf.create_entity({
            name = "straight-rail",
            position = { pos.x - 8, pos.y + 4 },
            direction = dirs.northwest,
            force = game.forces.player,
         })
      elseif dir == dirs.northeast then
         if anchor_dir == dirs.southeast then --2
            surf.create_entity({
               name = "curved-rail",
               position = { pos.x + 4, pos.y - 2 },
               direction = dirs.southwest,
               force = game.forces.player,
            })
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x + 4, pos.y - 8 },
               direction = dirs.north,
               force = game.forces.player,
            })
         elseif anchor_dir == dirs.northwest then --3
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x + 0, pos.y - 2 },
               direction = dirs.southeast,
               force = game.forces.player,
            })
            surf.create_entity({
               name = "curved-rail",
               position = { pos.x + 4, pos.y - 4 },
               direction = dirs.southwest,
               force = game.forces.player,
            })
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x + 4, pos.y - 10 },
               direction = dirs.north,
               force = game.forces.player,
            })
         end
      elseif dir == dirs.southwest then
         if anchor_dir == dirs.northwest then --2
            surf.create_entity({
               name = "curved-rail",
               position = { pos.x - 2, pos.y + 4 },
               direction = dirs.northeast,
               force = game.forces.player,
            })
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x - 4, pos.y + 8 },
               direction = dirs.north,
               force = game.forces.player,
            })
         elseif anchor_dir == dirs.southeast then --3
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x - 0, pos.y + 2 },
               direction = dirs.northwest,
               force = game.forces.player,
            })
            surf.create_entity({
               name = "curved-rail",
               position = { pos.x - 2, pos.y + 6 },
               direction = dirs.northeast,
               force = game.forces.player,
            })
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x - 4, pos.y + 10 },
               direction = dirs.north,
               force = game.forces.player,
            })
         end
      elseif dir == dirs.southeast then
         if anchor_dir == dirs.southwest then --2
            surf.create_entity({
               name = "curved-rail",
               position = { pos.x + 4, pos.y + 4 },
               direction = dirs.northwest,
               force = game.forces.player,
            })
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x + 8, pos.y + 4 },
               direction = dirs.east,
               force = game.forces.player,
            })
         elseif anchor_dir == dirs.northeast then --3
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x + 2, pos.y + 0 },
               direction = dirs.southwest,
               force = game.forces.player,
            })
            surf.create_entity({
               name = "curved-rail",
               position = { pos.x + 6, pos.y + 4 },
               direction = dirs.northwest,
               force = game.forces.player,
            })
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x + 10, pos.y + 4 },
               direction = dirs.east,
               force = game.forces.player,
            })
         end
      elseif dir == dirs.northwest then
         if anchor_dir == dirs.northeast then --2
            surf.create_entity({
               name = "curved-rail",
               position = { pos.x - 2, pos.y - 2 },
               direction = dirs.southeast,
               force = game.forces.player,
            })
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x - 8, pos.y - 4 },
               direction = dirs.east,
               force = game.forces.player,
            })
         elseif anchor_dir == dirs.southwest then --3
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x - 2, pos.y - 0 },
               direction = dirs.northeast,
               force = game.forces.player,
            })
            surf.create_entity({
               name = "curved-rail",
               position = { pos.x - 4, pos.y - 2 },
               direction = dirs.southeast,
               force = game.forces.player,
            })
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x - 10, pos.y - 4 },
               direction = dirs.east,
               force = game.forces.player,
            })
         end
      end
   end

   --5B. Build the rail entities to create the turn (RIGHT)
   if include_right then
      if dir == dirs.north then
         surf.create_entity({
            name = "curved-rail",
            position = { pos.x + 2, pos.y - 4 },
            direction = dirs.northeast,
            force = game.forces.player,
         })
         surf.create_entity({
            name = "straight-rail",
            position = { pos.x + 4, pos.y - 8 },
            direction = dirs.northwest,
            force = game.forces.player,
         })
      elseif dir == dirs.east then
         surf.create_entity({
            name = "curved-rail",
            position = { pos.x + 6, pos.y + 2 },
            direction = dirs.southeast,
            force = game.forces.player,
         })
         surf.create_entity({
            name = "straight-rail",
            position = { pos.x + 8, pos.y + 4 },
            direction = dirs.northeast,
            force = game.forces.player,
         })
      elseif dir == dirs.south then
         surf.create_entity({
            name = "curved-rail",
            position = { pos.x + 0, pos.y + 6 },
            direction = dirs.southwest,
            force = game.forces.player,
         })
         surf.create_entity({
            name = "straight-rail",
            position = { pos.x - 4, pos.y + 8 },
            direction = dirs.southeast,
            force = game.forces.player,
         })
      elseif dir == dirs.west then
         surf.create_entity({
            name = "curved-rail",
            position = { pos.x - 4, pos.y + 0 },
            direction = dirs.northwest,
            force = game.forces.player,
         })
         surf.create_entity({
            name = "straight-rail",
            position = { pos.x - 8, pos.y - 4 },
            direction = dirs.southwest,
            force = game.forces.player,
         })
      elseif dir == dirs.northeast then
         if anchor_dir == dirs.northwest then
            surf.create_entity({
               name = "curved-rail",
               position = { pos.x + 4, pos.y - 2 },
               direction = dirs.west,
               force = game.forces.player,
            })
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x + 8, pos.y - 4 },
               direction = dirs.east,
               force = game.forces.player,
            })
         elseif anchor_dir == dirs.southeast then
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x + 2, pos.y - 0 },
               direction = dirs.northwest,
               force = game.forces.player,
            })
            surf.create_entity({
               name = "curved-rail",
               position = { pos.x + 6, pos.y - 2 },
               direction = dirs.west,
               force = game.forces.player,
            })
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x + 10, pos.y - 4 },
               direction = dirs.east,
               force = game.forces.player,
            })
         end
      elseif dir == dirs.southwest then
         if anchor_dir == dirs.southeast then --2
            surf.create_entity({
               name = "curved-rail",
               position = { pos.x - 2, pos.y + 4 },
               direction = dirs.east,
               force = game.forces.player,
            })
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x - 8, pos.y + 4 },
               direction = dirs.east,
               force = game.forces.player,
            })
         elseif anchor_dir == dirs.northwest then --3
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x - 2, pos.y + 0 },
               direction = dirs.southeast,
               force = game.forces.player,
            })
            surf.create_entity({
               name = "curved-rail",
               position = { pos.x - 4, pos.y + 4 },
               direction = dirs.east,
               force = game.forces.player,
            })
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x - 10, pos.y + 4 },
               direction = dirs.east,
               force = game.forces.player,
            })
         end
      elseif dir == dirs.southeast then
         if anchor_dir == dirs.northeast then --2
            surf.create_entity({
               name = "curved-rail",
               position = { pos.x + 4, pos.y + 4 },
               direction = dirs.north,
               force = game.forces.player,
            })
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x + 4, pos.y + 8 },
               direction = dirs.north,
               force = game.forces.player,
            })
         elseif anchor_dir == dirs.southwest then --3
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x - 0, pos.y + 2 },
               direction = dirs.northeast,
               force = game.forces.player,
            })
            surf.create_entity({
               name = "curved-rail",
               position = { pos.x + 4, pos.y + 6 },
               direction = dirs.north,
               force = game.forces.player,
            })
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x + 4, pos.y + 10 },
               direction = dirs.north,
               force = game.forces.player,
            })
         end
      elseif dir == dirs.northwest then
         if anchor_dir == dirs.southwest then --2
            surf.create_entity({
               name = "curved-rail",
               position = { pos.x - 2, pos.y - 2 },
               direction = dirs.south,
               force = game.forces.player,
            })
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x - 4, pos.y - 8 },
               direction = dirs.north,
               force = game.forces.player,
            })
         elseif anchor_dir == dirs.northeast then --3
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x - 0, pos.y - 2 },
               direction = dirs.southwest,
               force = game.forces.player,
            })
            surf.create_entity({
               name = "curved-rail",
               position = { pos.x - 2, pos.y - 4 },
               direction = dirs.south,
               force = game.forces.player,
            })
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x - 4, pos.y - 10 },
               direction = dirs.north,
               force = game.forces.player,
            })
         end
      end
   end

   --5C. Add Forward section
   if include_forward then
      if dir == dirs.north then
         surf.create_entity({
            name = "straight-rail",
            position = { pos.x - 0, pos.y - 2 },
            direction = dir,
            force = game.forces.player,
         })
         surf.create_entity({
            name = "straight-rail",
            position = { pos.x - 0, pos.y - 4 },
            direction = dir,
            force = game.forces.player,
         })
         surf.create_entity({
            name = "straight-rail",
            position = { pos.x - 0, pos.y - 6 },
            direction = dir,
            force = game.forces.player,
         })
         surf.create_entity({
            name = "straight-rail",
            position = { pos.x - 0, pos.y - 8 },
            direction = dir,
            force = game.forces.player,
         })
         surf.create_entity({
            name = "straight-rail",
            position = { pos.x - 0, pos.y - 10 },
            direction = dir,
            force = game.forces.player,
         })
         surf.create_entity({
            name = "straight-rail",
            position = { pos.x - 0, pos.y - 12 },
            direction = dir,
            force = game.forces.player,
         })
      elseif dir == dirs.east then
         surf.create_entity({
            name = "straight-rail",
            position = { pos.x + 2, pos.y - 0 },
            direction = dir,
            force = game.forces.player,
         })
         surf.create_entity({
            name = "straight-rail",
            position = { pos.x + 4, pos.y - 0 },
            direction = dir,
            force = game.forces.player,
         })
         surf.create_entity({
            name = "straight-rail",
            position = { pos.x + 6, pos.y - 0 },
            direction = dir,
            force = game.forces.player,
         })
         surf.create_entity({
            name = "straight-rail",
            position = { pos.x + 8, pos.y - 0 },
            direction = dir,
            force = game.forces.player,
         })
         surf.create_entity({
            name = "straight-rail",
            position = { pos.x + 10, pos.y - 0 },
            direction = dir,
            force = game.forces.player,
         })
         surf.create_entity({
            name = "straight-rail",
            position = { pos.x + 12, pos.y - 0 },
            direction = dir,
            force = game.forces.player,
         })
      elseif dir == dirs.south then
         surf.create_entity({
            name = "straight-rail",
            position = { pos.x - 0, pos.y + 2 },
            direction = dir,
            force = game.forces.player,
         })
         surf.create_entity({
            name = "straight-rail",
            position = { pos.x - 0, pos.y + 4 },
            direction = dir,
            force = game.forces.player,
         })
         surf.create_entity({
            name = "straight-rail",
            position = { pos.x - 0, pos.y + 6 },
            direction = dir,
            force = game.forces.player,
         })
         surf.create_entity({
            name = "straight-rail",
            position = { pos.x - 0, pos.y + 8 },
            direction = dir,
            force = game.forces.player,
         })
         surf.create_entity({
            name = "straight-rail",
            position = { pos.x - 0, pos.y + 10 },
            direction = dir,
            force = game.forces.player,
         })
         surf.create_entity({
            name = "straight-rail",
            position = { pos.x - 0, pos.y + 12 },
            direction = dir,
            force = game.forces.player,
         })
      elseif dir == dirs.west then
         surf.create_entity({
            name = "straight-rail",
            position = { pos.x - 2, pos.y - 0 },
            direction = dir,
            force = game.forces.player,
         })
         surf.create_entity({
            name = "straight-rail",
            position = { pos.x - 4, pos.y - 0 },
            direction = dir,
            force = game.forces.player,
         })
         surf.create_entity({
            name = "straight-rail",
            position = { pos.x - 6, pos.y - 0 },
            direction = dir,
            force = game.forces.player,
         })
         surf.create_entity({
            name = "straight-rail",
            position = { pos.x - 8, pos.y - 0 },
            direction = dir,
            force = game.forces.player,
         })
         surf.create_entity({
            name = "straight-rail",
            position = { pos.x - 10, pos.y - 0 },
            direction = dir,
            force = game.forces.player,
         })
         surf.create_entity({
            name = "straight-rail",
            position = { pos.x - 12, pos.y - 0 },
            direction = dir,
            force = game.forces.player,
         })
      elseif dir == dirs.northeast then
         if anchor_dir == dirs.southeast then --2
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x + 2, pos.y - 0 },
               direction = dirs.northwest,
               force = game.forces.player,
            })
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x + 2, pos.y - 2 },
               direction = dirs.southeast,
               force = game.forces.player,
            })
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x + 4, pos.y - 2 },
               direction = dirs.northwest,
               force = game.forces.player,
            })
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x + 4, pos.y - 4 },
               direction = dirs.southeast,
               force = game.forces.player,
            })
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x + 6, pos.y - 4 },
               direction = dirs.northwest,
               force = game.forces.player,
            })
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x + 6, pos.y - 6 },
               direction = dirs.southeast,
               force = game.forces.player,
            })
         elseif anchor_dir == dirs.northwest then --3
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x + 0, pos.y - 2 },
               direction = dirs.southeast,
               force = game.forces.player,
            })
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x + 2, pos.y - 2 },
               direction = dirs.northwest,
               force = game.forces.player,
            })
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x + 2, pos.y - 4 },
               direction = dirs.southeast,
               force = game.forces.player,
            })
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x + 4, pos.y - 4 },
               direction = dirs.northwest,
               force = game.forces.player,
            })
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x + 4, pos.y - 6 },
               direction = dirs.southeast,
               force = game.forces.player,
            })
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x + 6, pos.y - 6 },
               direction = dirs.northwest,
               force = game.forces.player,
            })
         end
      elseif dir == dirs.southeast then
         if anchor_dir == dirs.southwest then
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x + 0, pos.y + 2 },
               direction = dirs.northeast,
               force = game.forces.player,
            })
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x + 2, pos.y + 2 },
               direction = dirs.southwest,
               force = game.forces.player,
            })
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x + 2, pos.y + 4 },
               direction = dirs.northeast,
               force = game.forces.player,
            })
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x + 4, pos.y + 4 },
               direction = dirs.southwest,
               force = game.forces.player,
            })
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x + 4, pos.y + 6 },
               direction = dirs.northeast,
               force = game.forces.player,
            })
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x + 6, pos.y + 6 },
               direction = dirs.southwest,
               force = game.forces.player,
            })
         elseif anchor_dir == dirs.northeast then
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x + 2, pos.y + 0 },
               direction = dirs.southwest,
               force = game.forces.player,
            })
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x + 2, pos.y + 2 },
               direction = dirs.northeast,
               force = game.forces.player,
            })
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x + 4, pos.y + 2 },
               direction = dirs.southwest,
               force = game.forces.player,
            })
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x + 4, pos.y + 4 },
               direction = dirs.northeast,
               force = game.forces.player,
            })
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x + 6, pos.y + 4 },
               direction = dirs.southwest,
               force = game.forces.player,
            })
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x + 6, pos.y + 6 },
               direction = dirs.northeast,
               force = game.forces.player,
            })
         end
      elseif dir == dirs.southwest then
         if anchor_dir == dirs.southeast then --2
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x - 0, pos.y + 2 },
               direction = dirs.northwest,
               force = game.forces.player,
            })
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x - 2, pos.y + 2 },
               direction = dirs.southeast,
               force = game.forces.player,
            })
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x - 2, pos.y + 4 },
               direction = dirs.northwest,
               force = game.forces.player,
            })
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x - 4, pos.y + 4 },
               direction = dirs.southeast,
               force = game.forces.player,
            })
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x - 4, pos.y + 6 },
               direction = dirs.northwest,
               force = game.forces.player,
            })
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x - 6, pos.y + 6 },
               direction = dirs.southeast,
               force = game.forces.player,
            })
         elseif anchor_dir == dirs.northwest then --3
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x - 2, pos.y + 0 },
               direction = dirs.southeast,
               force = game.forces.player,
            })
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x - 2, pos.y + 2 },
               direction = dirs.northwest,
               force = game.forces.player,
            })
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x - 4, pos.y + 2 },
               direction = dirs.southeast,
               force = game.forces.player,
            })
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x - 4, pos.y + 4 },
               direction = dirs.northwest,
               force = game.forces.player,
            })
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x - 6, pos.y + 4 },
               direction = dirs.southeast,
               force = game.forces.player,
            })
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x - 6, pos.y + 6 },
               direction = dirs.northwest,
               force = game.forces.player,
            })
         end
      elseif dir == dirs.northwest then
         if anchor_dir == dirs.southwest then
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x - 2, pos.y - 0 },
               direction = dirs.northeast,
               force = game.forces.player,
            })
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x - 2, pos.y - 2 },
               direction = dirs.southwest,
               force = game.forces.player,
            })
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x - 4, pos.y - 2 },
               direction = dirs.northeast,
               force = game.forces.player,
            })
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x - 4, pos.y - 4 },
               direction = dirs.southwest,
               force = game.forces.player,
            })
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x - 6, pos.y - 4 },
               direction = dirs.northeast,
               force = game.forces.player,
            })
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x - 6, pos.y - 6 },
               direction = dirs.southwest,
               force = game.forces.player,
            })
         elseif anchor_dir == dirs.northeast then
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x - 0, pos.y - 2 },
               direction = dirs.southwest,
               force = game.forces.player,
            })
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x - 2, pos.y - 2 },
               direction = dirs.northeast,
               force = game.forces.player,
            })
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x - 2, pos.y - 4 },
               direction = dirs.southwest,
               force = game.forces.player,
            })
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x - 4, pos.y - 4 },
               direction = dirs.northeast,
               force = game.forces.player,
            })
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x - 4, pos.y - 6 },
               direction = dirs.southwest,
               force = game.forces.player,
            })
            surf.create_entity({
               name = "straight-rail",
               position = { pos.x - 6, pos.y - 6 },
               direction = dirs.northeast,
               force = game.forces.player,
            })
         end
      else
         game.get_player(pindex).play_sound({ path = "utility/cannot_build" })
         printout({ "fa.rail-error-placement-not-defined" }, pindex)
         game.get_player(pindex).clear_cursor()
         return
      end
   end

   --6 Remove rail units from the player's hand
   game.get_player(pindex).cursor_stack.count = game.get_player(pindex).cursor_stack.count - 5
   game.get_player(pindex).clear_cursor()

   --7. Sounds and results
   game.get_player(pindex).play_sound({ path = "entity-build/straight-rail" })
   game.get_player(pindex).play_sound({ path = "entity-build/curved-rail" })
   local result = "Rail fork built with exits at "
   if include_left then result = result .. "left, " end
   if include_right then result = result .. "right, " end
   if include_forward then result = result .. "forward, " end
   result = result .. build_comment
   printout(result, pindex)
   return
end

--Builds a rail bypass junction with 2 rails
function mod.build_rail_bypass_junction(anchor_rail, pindex)
   local build_comment = ""
   local surf = game.get_player(pindex).surface
   local stack = game.get_player(pindex).cursor_stack
   local stack2 = nil
   local pos = nil
   local dir = -1
   local build_area = nil
   local can_place_all = true
   local is_end_rail
   local anchor_dir = anchor_rail.direction

   --1A. Firstly, check if the player has enough rails to place this (20 units)
   if not (stack.valid and stack.valid_for_read and stack.name == "rail" and stack.count >= 20) then
      --Check if the inventory has enough
      if storage.players[pindex].inventory.lua_inventory.get_item_count("rail") < 20 then
         game.get_player(pindex).play_sound({ path = "utility/cannot_build" })
         printout({ "fa.rail-need-twenty-rails" }, pindex)
         return
      else
         --Take from the inventory.
         stack2 = storage.players[pindex].inventory.lua_inventory.find_item_stack("rail")
         game.get_player(pindex).cursor_stack.swap_stack(stack2)
         stack = game.get_player(pindex).cursor_stack
         storage.players[pindex].inventory.max = #storage.players[pindex].inventory.lua_inventory
      end
   end

   --1B. Check if the player has enough rail signals to place this (4 units)
   if not (stack.valid and stack.valid_for_read and stack.name == "rail-chain-signal" and stack.count >= 4) then
      --Check if the inventory has enough
      if storage.players[pindex].inventory.lua_inventory.get_item_count("rail-chain-signal") < 4 then
         game.get_player(pindex).play_sound({ path = "utility/cannot_build" })
         game.get_player(pindex).clear_cursor()
         printout({ "fa.rail-need-four-chain-signals" }, pindex)
         return
      else
         --Good to go.
      end
   end

   --2. Secondly, verify the end rail and find its direction
   is_end_rail, dir, build_comment = Rails.check_end_rail(anchor_rail, pindex)
   if not is_end_rail then
      game.get_player(pindex).play_sound({ path = "utility/cannot_build" })
      printout(build_comment, pindex)
      game.get_player(pindex).clear_cursor()
      return
   end
   pos = anchor_rail.position

   --3. Clear trees and rocks in the build area, can be tuned later...
   temp1, build_comment = PlayerMiningTools.clear_obstacles_in_circle(pos, 21, pindex)

   --4A. Check if every object can be placed (LEFT)
   if dir == dirs.north then
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "curved-rail",
            position = { pos.x - 00, pos.y - 04 },
            direction = dirs.north,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x - 04, pos.y - 08 },
            direction = dirs.northeast,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x - 04, pos.y - 10 },
            direction = dirs.southwest,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "curved-rail",
            position = { pos.x - 06, pos.y - 12 },
            direction = dirs.south,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x - 08, pos.y - 18 },
            direction = dirs.north,
            force = game.forces.player,
         })
   elseif dir == dirs.east then
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "curved-rail",
            position = { pos.x + 06, pos.y - 00 },
            direction = dirs.east,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x + 08, pos.y - 04 },
            direction = dirs.southeast,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x + 10, pos.y - 04 },
            direction = dirs.northwest,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "curved-rail",
            position = { pos.x + 14, pos.y - 06 },
            direction = dirs.west,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x + 18, pos.y - 08 },
            direction = dirs.east,
            force = game.forces.player,
         })
   elseif dir == dirs.south then
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "curved-rail",
            position = { pos.x + 02, pos.y + 06 },
            direction = dirs.south,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x + 04, pos.y + 08 },
            direction = dirs.southwest,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x + 04, pos.y + 10 },
            direction = dirs.northeast,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "curved-rail",
            position = { pos.x + 08, pos.y + 14 },
            direction = dirs.north,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x + 08, pos.y + 18 },
            direction = dirs.north,
            force = game.forces.player,
         })
   elseif dir == dirs.west then
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "curved-rail",
            position = { pos.x - 04, pos.y + 02 },
            direction = dirs.west,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x - 08, pos.y + 04 },
            direction = dirs.northwest,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x - 10, pos.y + 04 },
            direction = dirs.southeast,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "curved-rail",
            position = { pos.x - 12, pos.y + 08 },
            direction = dirs.east,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x - 18, pos.y + 08 },
            direction = dirs.west,
            force = game.forces.player,
         })
   end

   --4B. Check if every object can be placed (RIGHT)
   if dir == dirs.north then
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "curved-rail",
            position = { pos.x + 02, pos.y - 04 },
            direction = dirs.northeast,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x + 04, pos.y - 08 },
            direction = dirs.northwest,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x + 04, pos.y - 10 },
            direction = dirs.southeast,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "curved-rail",
            position = { pos.x + 08, pos.y - 12 },
            direction = dirs.southwest,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x + 08, pos.y - 18 },
            direction = dirs.north,
            force = game.forces.player,
         })
   elseif dir == dirs.east then
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "curved-rail",
            position = { pos.x + 06, pos.y + 02 },
            direction = dirs.southeast,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x + 08, pos.y + 04 },
            direction = dirs.northeast,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x + 10, pos.y + 04 },
            direction = dirs.southwest,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "curved-rail",
            position = { pos.x + 14, pos.y + 08 },
            direction = dirs.northwest,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x + 18, pos.y + 08 },
            direction = dirs.east,
            force = game.forces.player,
         })
   elseif dir == dirs.south then
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "curved-rail",
            position = { pos.x - 00, pos.y + 06 },
            direction = dirs.southwest,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x - 04, pos.y + 08 },
            direction = dirs.southeast,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x - 04, pos.y + 10 },
            direction = dirs.northwest,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "curved-rail",
            position = { pos.x - 06, pos.y + 14 },
            direction = dirs.northeast,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x - 08, pos.y + 18 },
            direction = dirs.south,
            force = game.forces.player,
         })
   elseif dir == dirs.west then
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "curved-rail",
            position = { pos.x - 04, pos.y - 00 },
            direction = dirs.northwest,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x - 08, pos.y - 04 },
            direction = dirs.southwest,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x - 10, pos.y - 04 },
            direction = dirs.northeast,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "curved-rail",
            position = { pos.x - 12, pos.y - 06 },
            direction = dirs.southeast,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x - 18, pos.y - 08 },
            direction = dirs.west,
            force = game.forces.player,
         })
   end

   --4C. Check if every object can be placed (SIGNALS)
   if dir == dirs.north then
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "rail-chain-signal",
            position = { pos.x + 01, pos.y - 00 },
            direction = dirs.south,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "rail-chain-signal",
            position = { pos.x - 02, pos.y - 00 },
            direction = dirs.north,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "rail-signal",
            position = { pos.x + 03, pos.y - 07 },
            direction = dirs.southwest,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "rail-chain-signal",
            position = { pos.x - 04, pos.y - 07 },
            direction = dirs.northwest,
            force = game.forces.player,
         })
   elseif dir == dirs.east then
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "rail-chain-signal",
            position = { pos.x - 01, pos.y + 01 },
            direction = dirs.west,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "rail-chain-signal",
            position = { pos.x - 01, pos.y - 02 },
            direction = dirs.east,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "rail-signal",
            position = { pos.x + 06, pos.y + 03 },
            direction = dirs.northwest,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "rail-chain-signal",
            position = { pos.x + 06, pos.y - 04 },
            direction = dirs.northeast,
            force = game.forces.player,
         })
   elseif dir == dirs.south then
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "rail-chain-signal",
            position = { pos.x - 02, pos.y - 00 },
            direction = dirs.north,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "rail-chain-signal",
            position = { pos.x + 01, pos.y - 00 },
            direction = dirs.south,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "rail-signal",
            position = { pos.x - 04, pos.y + 06 },
            direction = dirs.northeast,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "rail-chain-signal",
            position = { pos.x + 03, pos.y + 06 },
            direction = dirs.southeast,
            force = game.forces.player,
         })
   elseif dir == dirs.west then
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "rail-chain-signal",
            position = { pos.x - 00, pos.y - 02 },
            direction = dirs.east,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "rail-chain-signal",
            position = { pos.x - 00, pos.y + 01 },
            direction = dirs.west,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "rail-signal",
            position = { pos.x - 07, pos.y - 04 },
            direction = dirs.southeast,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "rail-chain-signal",
            position = { pos.x - 07, pos.y + 03 },
            direction = dirs.southwest,
            force = game.forces.player,
         })
   end

   if dir == dirs.northeast or dir == dirs.northwest or dir == dirs.southeast or dir == dirs.southwest then
      can_place_all = false
   end

   if not can_place_all then
      game.get_player(pindex).play_sound({ path = "utility/cannot_build" })
      printout({ "fa.rail-building-area-occupied" }, pindex)
      game.get_player(pindex).clear_cursor()
      return
   end

   --5A. Build the rail entities to create the turn (LEFT)
   if dir == dirs.north then
      surf.create_entity({
         name = "curved-rail",
         position = { pos.x - 00, pos.y - 04 },
         direction = dirs.north,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x - 04, pos.y - 08 },
         direction = dirs.northeast,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x - 04, pos.y - 10 },
         direction = dirs.southwest,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "curved-rail",
         position = { pos.x - 06, pos.y - 12 },
         direction = dirs.south,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x - 08, pos.y - 18 },
         direction = dirs.north,
         force = game.forces.player,
      })
   elseif dir == dirs.east then
      surf.create_entity({
         name = "curved-rail",
         position = { pos.x + 06, pos.y - 00 },
         direction = dirs.east,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x + 08, pos.y - 04 },
         direction = dirs.southeast,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x + 10, pos.y - 04 },
         direction = dirs.northwest,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "curved-rail",
         position = { pos.x + 14, pos.y - 06 },
         direction = dirs.west,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x + 18, pos.y - 08 },
         direction = dirs.east,
         force = game.forces.player,
      })
   elseif dir == dirs.south then
      surf.create_entity({
         name = "curved-rail",
         position = { pos.x + 02, pos.y + 06 },
         direction = dirs.south,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x + 04, pos.y + 08 },
         direction = dirs.southwest,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x + 04, pos.y + 10 },
         direction = dirs.northeast,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "curved-rail",
         position = { pos.x + 08, pos.y + 14 },
         direction = dirs.north,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x + 08, pos.y + 18 },
         direction = dirs.north,
         force = game.forces.player,
      })
   elseif dir == dirs.west then
      surf.create_entity({
         name = "curved-rail",
         position = { pos.x - 04, pos.y + 02 },
         direction = dirs.west,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x - 08, pos.y + 04 },
         direction = dirs.northwest,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x - 10, pos.y + 04 },
         direction = dirs.southeast,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "curved-rail",
         position = { pos.x - 12, pos.y + 08 },
         direction = dirs.east,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x - 18, pos.y + 08 },
         direction = dirs.west,
         force = game.forces.player,
      })
   end

   --5B. Build the rail entities to create the turn (RIGHT)
   if dir == dirs.north then
      surf.create_entity({
         name = "curved-rail",
         position = { pos.x + 02, pos.y - 04 },
         direction = dirs.northeast,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x + 04, pos.y - 08 },
         direction = dirs.northwest,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x + 04, pos.y - 10 },
         direction = dirs.southeast,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "curved-rail",
         position = { pos.x + 08, pos.y - 12 },
         direction = dirs.southwest,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x + 08, pos.y - 18 },
         direction = dirs.north,
         force = game.forces.player,
      })
   elseif dir == dirs.east then
      surf.create_entity({
         name = "curved-rail",
         position = { pos.x + 06, pos.y + 02 },
         direction = dirs.southeast,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x + 08, pos.y + 04 },
         direction = dirs.northeast,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x + 10, pos.y + 04 },
         direction = dirs.southwest,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "curved-rail",
         position = { pos.x + 14, pos.y + 08 },
         direction = dirs.northwest,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x + 18, pos.y + 08 },
         direction = dirs.east,
         force = game.forces.player,
      })
   elseif dir == dirs.south then
      surf.create_entity({
         name = "curved-rail",
         position = { pos.x - 00, pos.y + 06 },
         direction = dirs.southwest,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x - 04, pos.y + 08 },
         direction = dirs.southeast,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x - 04, pos.y + 10 },
         direction = dirs.northwest,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "curved-rail",
         position = { pos.x - 06, pos.y + 14 },
         direction = dirs.northeast,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x - 08, pos.y + 18 },
         direction = dirs.south,
         force = game.forces.player,
      })
   elseif dir == dirs.west then
      surf.create_entity({
         name = "curved-rail",
         position = { pos.x - 04, pos.y - 00 },
         direction = dirs.northwest,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x - 08, pos.y - 04 },
         direction = dirs.southwest,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x - 10, pos.y - 04 },
         direction = dirs.northeast,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "curved-rail",
         position = { pos.x - 12, pos.y - 06 },
         direction = dirs.southeast,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x - 18, pos.y - 08 },
         direction = dirs.west,
         force = game.forces.player,
      })
   end

   --5C. Place rail signals (4)
   if dir == dirs.north then
      surf.create_entity({
         name = "rail-chain-signal",
         position = { pos.x + 01, pos.y - 00 },
         direction = dirs.south,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "rail-chain-signal",
         position = { pos.x - 02, pos.y - 00 },
         direction = dirs.north,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "rail-signal",
         position = { pos.x + 03, pos.y - 07 },
         direction = dirs.southwest,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "rail-chain-signal",
         position = { pos.x - 04, pos.y - 07 },
         direction = dirs.northwest,
         force = game.forces.player,
      })
   elseif dir == dirs.east then
      surf.create_entity({
         name = "rail-chain-signal",
         position = { pos.x - 01, pos.y + 01 },
         direction = dirs.west,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "rail-chain-signal",
         position = { pos.x - 01, pos.y - 02 },
         direction = dirs.east,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "rail-signal",
         position = { pos.x + 06, pos.y + 03 },
         direction = dirs.northwest,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "rail-chain-signal",
         position = { pos.x + 06, pos.y - 04 },
         direction = dirs.northeast,
         force = game.forces.player,
      })
   elseif dir == dirs.south then
      surf.create_entity({
         name = "rail-chain-signal",
         position = { pos.x - 02, pos.y - 00 },
         direction = dirs.north,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "rail-chain-signal",
         position = { pos.x + 01, pos.y - 00 },
         direction = dirs.south,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "rail-signal",
         position = { pos.x - 04, pos.y + 06 },
         direction = dirs.northeast,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "rail-chain-signal",
         position = { pos.x + 03, pos.y + 06 },
         direction = dirs.southeast,
         force = game.forces.player,
      })
   elseif dir == dirs.west then
      surf.create_entity({
         name = "rail-chain-signal",
         position = { pos.x - 00, pos.y - 02 },
         direction = dirs.east,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "rail-chain-signal",
         position = { pos.x - 00, pos.y + 01 },
         direction = dirs.west,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "rail-signal",
         position = { pos.x - 07, pos.y - 04 },
         direction = dirs.southeast,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "rail-chain-signal",
         position = { pos.x - 07, pos.y + 03 },
         direction = dirs.southwest,
         force = game.forces.player,
      })
   end

   --6 Remove rail units from the player's hand
   game.get_player(pindex).cursor_stack.count = game.get_player(pindex).cursor_stack.count - 20
   game.get_player(pindex).clear_cursor()
   game.get_player(pindex).get_main_inventory().remove({ name = "rail-chain-signal", count = 4 })

   --7. Sounds and results
   game.get_player(pindex).play_sound({ path = "entity-build/straight-rail" })
   game.get_player(pindex).play_sound({ path = "entity-build/curved-rail" })
   game.get_player(pindex).play_sound({ path = "entity-build/straight-rail" })
   game.get_player(pindex).play_sound({ path = "entity-build/curved-rail" })
   local result = "Rail bypass junction built, " .. build_comment
   printout(result, pindex)
   return
end

--WIP #91: Builds a rail bypass junction with 3 rails
function mod.build_rail_bypass_junction_triple(anchor_rail, pindex)
   local build_comment = ""
   local surf = game.get_player(pindex).surface
   local stack = game.get_player(pindex).cursor_stack
   local stack2 = nil
   local pos = nil
   local dir = -1
   local build_area = nil
   local can_place_all = true
   local is_end_rail
   local anchor_dir = anchor_rail.direction

   --1A. Firstly, check if the player has enough rails to place this (25 units)
   if not (stack.valid and stack.valid_for_read and stack.name == "rail" and stack.count >= 25) then
      --Check if the inventory has enough
      if storage.players[pindex].inventory.lua_inventory.get_item_count("rail") < 25 then
         game.get_player(pindex).play_sound({ path = "utility/cannot_build" })
         printout({ "fa.rail-need-twenty-five-rails" }, pindex)
         return
      else
         --Take from the inventory.
         stack2 = storage.players[pindex].inventory.lua_inventory.find_item_stack("rail")
         game.get_player(pindex).cursor_stack.swap_stack(stack2)
         stack = game.get_player(pindex).cursor_stack
         storage.players[pindex].inventory.max = #storage.players[pindex].inventory.lua_inventory
      end
   end

   --1B. Check if the player has enough rail signals to place this (6 units)
   if not (stack.valid and stack.valid_for_read and stack.name == "rail-chain-signal" and stack.count >= 6) then
      --Check if the inventory has enough
      if storage.players[pindex].inventory.lua_inventory.get_item_count("rail-chain-signal") < 6 then
         game.get_player(pindex).play_sound({ path = "utility/cannot_build" })
         printout({ "fa.rail-need-six-chain-signals" }, pindex)
         return
      else
         --Good to go.
      end
   end

   --2. Secondly, verify the end rail and find its direction
   is_end_rail, dir, build_comment = Rails.check_end_rail(anchor_rail, pindex)
   if not is_end_rail then
      game.get_player(pindex).play_sound({ path = "utility/cannot_build" })
      printout(build_comment, pindex)
      game.get_player(pindex).clear_cursor()
      return
   end
   pos = anchor_rail.position

   --3. Clear trees and rocks in the build area, can be tuned later...
   temp1, build_comment = PlayerMiningTools.clear_obstacles_in_circle(pos, 21, pindex)

   --4A. Check if every object can be placed (LEFT)
   if dir == dirs.north then
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "curved-rail",
            position = { pos.x - 00, pos.y - 04 },
            direction = dirs.north,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x - 04, pos.y - 08 },
            direction = dirs.northeast,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x - 04, pos.y - 10 },
            direction = dirs.southwest,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "curved-rail",
            position = { pos.x - 06, pos.y - 12 },
            direction = dirs.south,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x - 08, pos.y - 18 },
            direction = dirs.north,
            force = game.forces.player,
         })
   elseif dir == dirs.east then
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "curved-rail",
            position = { pos.x + 06, pos.y - 00 },
            direction = dirs.east,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x + 08, pos.y - 04 },
            direction = dirs.southeast,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x + 10, pos.y - 04 },
            direction = dirs.northwest,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "curved-rail",
            position = { pos.x + 14, pos.y - 06 },
            direction = dirs.west,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x + 18, pos.y - 08 },
            direction = dirs.east,
            force = game.forces.player,
         })
   elseif dir == dirs.south then
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "curved-rail",
            position = { pos.x + 02, pos.y + 06 },
            direction = dirs.south,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x + 04, pos.y + 08 },
            direction = dirs.southwest,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x + 04, pos.y + 10 },
            direction = dirs.northeast,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "curved-rail",
            position = { pos.x + 08, pos.y + 14 },
            direction = dirs.north,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x + 08, pos.y + 18 },
            direction = dirs.north,
            force = game.forces.player,
         })
   elseif dir == dirs.west then
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "curved-rail",
            position = { pos.x - 04, pos.y + 02 },
            direction = dirs.west,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x - 08, pos.y + 04 },
            direction = dirs.northwest,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x - 10, pos.y + 04 },
            direction = dirs.southeast,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "curved-rail",
            position = { pos.x - 12, pos.y + 08 },
            direction = dirs.east,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x - 18, pos.y + 08 },
            direction = dirs.west,
            force = game.forces.player,
         })
   end

   --4B. Check if every object can be placed (RIGHT)
   if dir == dirs.north then
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "curved-rail",
            position = { pos.x + 02, pos.y - 04 },
            direction = dirs.northeast,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x + 04, pos.y - 08 },
            direction = dirs.northwest,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x + 04, pos.y - 10 },
            direction = dirs.southeast,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "curved-rail",
            position = { pos.x + 08, pos.y - 12 },
            direction = dirs.southwest,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x + 08, pos.y - 18 },
            direction = dirs.north,
            force = game.forces.player,
         })
   elseif dir == dirs.east then
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "curved-rail",
            position = { pos.x + 06, pos.y + 02 },
            direction = dirs.southeast,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x + 08, pos.y + 04 },
            direction = dirs.northeast,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x + 10, pos.y + 04 },
            direction = dirs.southwest,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "curved-rail",
            position = { pos.x + 14, pos.y + 08 },
            direction = dirs.northwest,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x + 18, pos.y + 08 },
            direction = dirs.east,
            force = game.forces.player,
         })
   elseif dir == dirs.south then
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "curved-rail",
            position = { pos.x - 00, pos.y + 06 },
            direction = dirs.southwest,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x - 04, pos.y + 08 },
            direction = dirs.southeast,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x - 04, pos.y + 10 },
            direction = dirs.northwest,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "curved-rail",
            position = { pos.x - 06, pos.y + 14 },
            direction = dirs.northeast,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x - 08, pos.y + 18 },
            direction = dirs.south,
            force = game.forces.player,
         })
   elseif dir == dirs.west then
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "curved-rail",
            position = { pos.x - 04, pos.y - 00 },
            direction = dirs.northwest,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x - 08, pos.y - 04 },
            direction = dirs.southwest,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x - 10, pos.y - 04 },
            direction = dirs.northeast,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "curved-rail",
            position = { pos.x - 12, pos.y - 06 },
            direction = dirs.southeast,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "straight-rail",
            position = { pos.x - 18, pos.y - 08 },
            direction = dirs.west,
            force = game.forces.player,
         })
   end

   --4C. Check if every object can be placed (MIDDLE) WIP *** also needs to be okay with there already being straight rails here
   if dir == dirs.north then
      can_place_all = can_place_all
         and (
            surf.can_place_entity({
               name = "straight-rail",
               position = { pos.x + 08, pos.y - 18 },
               direction = dirs.north,
               force = game.forces.player,
            }) or true
         )
   elseif dir == dirs.east then
      can_place_all = can_place_all
         and (
            surf.can_place_entity({
               name = "straight-rail",
               position = { pos.x + 18, pos.y + 08 },
               direction = dirs.east,
               force = game.forces.player,
            }) or true
         )
   elseif dir == dirs.south then
      can_place_all = can_place_all
         and (
            surf.can_place_entity({
               name = "straight-rail",
               position = { pos.x - 08, pos.y + 18 },
               direction = dirs.south,
               force = game.forces.player,
            }) or true
         )
   elseif dir == dirs.west then
      can_place_all = can_place_all
         and (
            surf.can_place_entity({
               name = "straight-rail",
               position = { pos.x - 18, pos.y - 08 },
               direction = dirs.west,
               force = game.forces.player,
            }) or true
         )
   end

   --4D. Check if every object can be placed (SIGNALS) WIP ***
   if dir == dirs.north then
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "rail-chain-signal",
            position = { pos.x + 01, pos.y - 00 },
            direction = dirs.south,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "rail-chain-signal",
            position = { pos.x - 02, pos.y - 00 },
            direction = dirs.north,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "rail-signal",
            position = { pos.x + 03, pos.y - 07 },
            direction = dirs.southwest,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "rail-chain-signal",
            position = { pos.x - 04, pos.y - 07 },
            direction = dirs.northwest,
            force = game.forces.player,
         })
   elseif dir == dirs.east then
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "rail-chain-signal",
            position = { pos.x - 01, pos.y + 01 },
            direction = dirs.west,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "rail-chain-signal",
            position = { pos.x - 01, pos.y - 02 },
            direction = dirs.east,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "rail-signal",
            position = { pos.x + 06, pos.y + 03 },
            direction = dirs.northwest,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "rail-chain-signal",
            position = { pos.x + 06, pos.y - 04 },
            direction = dirs.northeast,
            force = game.forces.player,
         })
   elseif dir == dirs.south then
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "rail-chain-signal",
            position = { pos.x - 02, pos.y - 00 },
            direction = dirs.north,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "rail-chain-signal",
            position = { pos.x + 01, pos.y - 00 },
            direction = dirs.south,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "rail-signal",
            position = { pos.x - 04, pos.y + 06 },
            direction = dirs.northeast,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "rail-chain-signal",
            position = { pos.x + 03, pos.y + 06 },
            direction = dirs.southeast,
            force = game.forces.player,
         })
   elseif dir == dirs.west then
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "rail-chain-signal",
            position = { pos.x - 00, pos.y - 02 },
            direction = dirs.east,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "rail-chain-signal",
            position = { pos.x - 00, pos.y + 01 },
            direction = dirs.west,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "rail-signal",
            position = { pos.x - 07, pos.y - 04 },
            direction = dirs.southeast,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "rail-chain-signal",
            position = { pos.x - 07, pos.y + 03 },
            direction = dirs.southwest,
            force = game.forces.player,
         })
   end

   if dir == dirs.northeast or dir == dirs.northwest or dir == dirs.southeast or dir == dirs.southwest then
      can_place_all = false
   end

   if not can_place_all then
      game.get_player(pindex).play_sound({ path = "utility/cannot_build" })
      printout({ "fa.rail-building-area-occupied" }, pindex)
      game.get_player(pindex).clear_cursor()
      return
   end

   --5A. Build the rail entities to create the turn (LEFT)
   if dir == dirs.north then
      surf.create_entity({
         name = "curved-rail",
         position = { pos.x - 00, pos.y - 04 },
         direction = dirs.north,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x - 04, pos.y - 08 },
         direction = dirs.northeast,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x - 04, pos.y - 10 },
         direction = dirs.southwest,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "curved-rail",
         position = { pos.x - 06, pos.y - 12 },
         direction = dirs.south,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x - 08, pos.y - 18 },
         direction = dirs.north,
         force = game.forces.player,
      })
   elseif dir == dirs.east then
      surf.create_entity({
         name = "curved-rail",
         position = { pos.x + 06, pos.y - 00 },
         direction = dirs.east,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x + 08, pos.y - 04 },
         direction = dirs.southeast,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x + 10, pos.y - 04 },
         direction = dirs.northwest,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "curved-rail",
         position = { pos.x + 14, pos.y - 06 },
         direction = dirs.west,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x + 18, pos.y - 08 },
         direction = dirs.east,
         force = game.forces.player,
      })
   elseif dir == dirs.south then
      surf.create_entity({
         name = "curved-rail",
         position = { pos.x + 02, pos.y + 06 },
         direction = dirs.south,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x + 04, pos.y + 08 },
         direction = dirs.southwest,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x + 04, pos.y + 10 },
         direction = dirs.northeast,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "curved-rail",
         position = { pos.x + 08, pos.y + 14 },
         direction = dirs.north,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x + 08, pos.y + 18 },
         direction = dirs.north,
         force = game.forces.player,
      })
   elseif dir == dirs.west then
      surf.create_entity({
         name = "curved-rail",
         position = { pos.x - 04, pos.y + 02 },
         direction = dirs.west,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x - 08, pos.y + 04 },
         direction = dirs.northwest,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x - 10, pos.y + 04 },
         direction = dirs.southeast,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "curved-rail",
         position = { pos.x - 12, pos.y + 08 },
         direction = dirs.east,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x - 18, pos.y + 08 },
         direction = dirs.west,
         force = game.forces.player,
      })
   end

   --5B. Build the rail entities to create the turn (RIGHT)
   if dir == dirs.north then
      surf.create_entity({
         name = "curved-rail",
         position = { pos.x + 02, pos.y - 04 },
         direction = dirs.northeast,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x + 04, pos.y - 08 },
         direction = dirs.northwest,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x + 04, pos.y - 10 },
         direction = dirs.southeast,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "curved-rail",
         position = { pos.x + 08, pos.y - 12 },
         direction = dirs.southwest,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x + 08, pos.y - 18 },
         direction = dirs.north,
         force = game.forces.player,
      })
   elseif dir == dirs.east then
      surf.create_entity({
         name = "curved-rail",
         position = { pos.x + 06, pos.y + 02 },
         direction = dirs.southeast,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x + 08, pos.y + 04 },
         direction = dirs.northeast,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x + 10, pos.y + 04 },
         direction = dirs.southwest,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "curved-rail",
         position = { pos.x + 14, pos.y + 08 },
         direction = dirs.northwest,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x + 18, pos.y + 08 },
         direction = dirs.east,
         force = game.forces.player,
      })
   elseif dir == dirs.south then
      surf.create_entity({
         name = "curved-rail",
         position = { pos.x - 00, pos.y + 06 },
         direction = dirs.southwest,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x - 04, pos.y + 08 },
         direction = dirs.southeast,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x - 04, pos.y + 10 },
         direction = dirs.northwest,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "curved-rail",
         position = { pos.x - 06, pos.y + 14 },
         direction = dirs.northeast,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x - 08, pos.y + 18 },
         direction = dirs.south,
         force = game.forces.player,
      })
   elseif dir == dirs.west then
      surf.create_entity({
         name = "curved-rail",
         position = { pos.x - 04, pos.y - 00 },
         direction = dirs.northwest,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x - 08, pos.y - 04 },
         direction = dirs.southwest,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x - 10, pos.y - 04 },
         direction = dirs.northeast,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "curved-rail",
         position = { pos.x - 12, pos.y - 06 },
         direction = dirs.southeast,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x - 18, pos.y - 08 },
         direction = dirs.west,
         force = game.forces.player,
      })
   end
   --5C. Build the rail entities to create the exit (MIDDLE) WIP ***
   if dir == dirs.north then
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x + 08, pos.y - 18 },
         direction = dirs.north,
         force = game.forces.player,
      })
   elseif dir == dirs.east then
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x + 18, pos.y + 08 },
         direction = dirs.east,
         force = game.forces.player,
      })
   elseif dir == dirs.south then
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x - 08, pos.y + 18 },
         direction = dirs.south,
         force = game.forces.player,
      })
   elseif dir == dirs.west then
      surf.create_entity({
         name = "straight-rail",
         position = { pos.x - 18, pos.y - 08 },
         direction = dirs.west,
         force = game.forces.player,
      })
   end

   --5D. Place rail signals (6) WIP ***
   if dir == dirs.north then
      surf.create_entity({
         name = "rail-chain-signal",
         position = { pos.x + 01, pos.y - 00 },
         direction = dirs.south,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "rail-chain-signal",
         position = { pos.x - 02, pos.y - 00 },
         direction = dirs.north,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "rail-signal",
         position = { pos.x + 03, pos.y - 07 },
         direction = dirs.southwest,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "rail-chain-signal",
         position = { pos.x - 04, pos.y - 07 },
         direction = dirs.northwest,
         force = game.forces.player,
      })
   elseif dir == dirs.east then
      surf.create_entity({
         name = "rail-chain-signal",
         position = { pos.x - 01, pos.y + 01 },
         direction = dirs.west,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "rail-chain-signal",
         position = { pos.x - 01, pos.y - 02 },
         direction = dirs.east,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "rail-signal",
         position = { pos.x + 06, pos.y + 03 },
         direction = dirs.northwest,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "rail-chain-signal",
         position = { pos.x + 06, pos.y - 04 },
         direction = dirs.northeast,
         force = game.forces.player,
      })
   elseif dir == dirs.south then
      surf.create_entity({
         name = "rail-chain-signal",
         position = { pos.x - 02, pos.y - 00 },
         direction = dirs.north,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "rail-chain-signal",
         position = { pos.x + 01, pos.y - 00 },
         direction = dirs.south,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "rail-signal",
         position = { pos.x - 04, pos.y + 06 },
         direction = dirs.northeast,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "rail-chain-signal",
         position = { pos.x + 03, pos.y + 06 },
         direction = dirs.southeast,
         force = game.forces.player,
      })
   elseif dir == dirs.west then
      surf.create_entity({
         name = "rail-chain-signal",
         position = { pos.x - 00, pos.y - 02 },
         direction = dirs.east,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "rail-chain-signal",
         position = { pos.x - 00, pos.y + 01 },
         direction = dirs.west,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "rail-signal",
         position = { pos.x - 07, pos.y - 04 },
         direction = dirs.southeast,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "rail-chain-signal",
         position = { pos.x - 07, pos.y + 03 },
         direction = dirs.southwest,
         force = game.forces.player,
      })
   end

   --6 Remove rail units from the player's hand
   game.get_player(pindex).cursor_stack.count = game.get_player(pindex).cursor_stack.count - 25
   game.get_player(pindex).clear_cursor()
   game.get_player(pindex).get_main_inventory().remove({ name = "rail-chain-signal", count = 6 })

   --7. Sounds and results
   game.get_player(pindex).play_sound({ path = "entity-build/straight-rail" })
   game.get_player(pindex).play_sound({ path = "entity-build/curved-rail" })
   game.get_player(pindex).play_sound({ path = "entity-build/straight-rail" })
   game.get_player(pindex).play_sound({ path = "entity-build/curved-rail" })
   local result = "Rail bypass junction built with 3 branches, " .. build_comment
   printout(result, pindex)
   return
end

--Places a chain signal pair around a rail depending on its direction. May fail if the spots are full.
function mod.place_chain_signal_pair(rail, pindex)
   local stack = game.get_player(pindex).cursor_stack
   local stack2 = nil
   local build_comment = "no comment"
   local successful = true
   local dir = rail.direction
   local pos = rail.position
   local surf = rail.surface
   local can_place_all = true

   --1. Check if signals can be placed, based on direction
   if dir == dirs.north or dir == dirs.south then
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "rail-chain-signal",
            position = { pos.x + 1, pos.y },
            direction = dirs.south,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "rail-chain-signal",
            position = { pos.x - 2, pos.y },
            direction = dirs.north,
            force = game.forces.player,
         })
   elseif dir == dirs.east or dir == dirs.west then
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "rail-chain-signal",
            position = { pos.x, pos.y - 2 },
            direction = dirs.east,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "rail-chain-signal",
            position = { pos.x, pos.y + 1 },
            direction = dirs.west,
            force = game.forces.player,
         })
   elseif dir == dirs.northeast then
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "rail-chain-signal",
            position = { pos.x - 1, pos.y - 0 },
            direction = dirs.northwest,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "rail-chain-signal",
            position = { pos.x + 1, pos.y - 2 },
            direction = dirs.southeast,
            force = game.forces.player,
         })
   elseif dir == dirs.southwest then
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "rail-chain-signal",
            position = { pos.x - 2, pos.y + 1 },
            direction = dirs.northwest,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "rail-chain-signal",
            position = { pos.x + 0, pos.y - 1 },
            direction = dirs.southeast,
            force = game.forces.player,
         })
   elseif dir == dirs.southeast then
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "rail-chain-signal",
            position = { pos.x - 1, pos.y - 1 },
            direction = dirs.northeast,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "rail-chain-signal",
            position = { pos.x + 1, pos.y + 1 },
            direction = dirs.southwest,
            force = game.forces.player,
         })
   elseif dir == dirs.northwest then
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "rail-chain-signal",
            position = { pos.x - 2, pos.y - 2 },
            direction = dirs.northeast,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "rail-chain-signal",
            position = { pos.x + 0, pos.y + 0 },
            direction = dirs.southwest,
            force = game.forces.player,
         })
   else
      successful = false
      game.get_player(pindex).play_sound({ path = "utility/cannot_build" })
      build_comment = "direction error"
      return successful, build_comment
   end

   if not can_place_all then
      successful = false
      game.get_player(pindex).play_sound({ path = "utility/cannot_build" })
      build_comment = "cannot place"
      return successful, build_comment
   end

   --2. Check if there are already chain signals or rail signals nearby. If yes, stop.
   local signals_found = 0
   local signals = surf.find_entities_filtered({ position = pos, radius = 3, name = "rail-chain-signal" })
   for i, signal in ipairs(signals) do
      signals_found = signals_found + 1
   end
   local signals = surf.find_entities_filtered({ position = pos, radius = 3, name = "rail-signal" })
   for i, signal in ipairs(signals) do
      signals_found = signals_found + 1
   end
   if signals_found > 0 then
      successful = false
      game.get_player(pindex).play_sound({ path = "utility/cannot_build" })
      build_comment = "Too close to existing signals."
      return successful, build_comment
   end

   --3. Check whether the player has enough rail chain signals.
   if not (stack.valid and stack.valid_for_read and stack.name == "rail-chain-signal" and stack.count >= 2) then
      --Check if the inventory has one instead
      if storage.players[pindex].inventory.lua_inventory.get_item_count("rail-chain-signal") < 2 then
         game.get_player(pindex).play_sound({ path = "utility/cannot_build" })
         build_comment = "You need to have at least 2 rail chain signals on you."
         successful = false
         game.get_player(pindex).play_sound({ path = "utility/cannot_build" })
         return successful, build_comment
      else
         --Take from the inventory.
         stack2 = storage.players[pindex].inventory.lua_inventory.find_item_stack("rail-chain-signal")
         game.get_player(pindex).cursor_stack.swap_stack(stack2)
         stack = game.get_player(pindex).cursor_stack
         storage.players[pindex].inventory.max = #storage.players[pindex].inventory.lua_inventory
      end
   end

   --4. Place the signals.
   if dir == dirs.north or dir == dirs.south then
      surf.create_entity({
         name = "rail-chain-signal",
         position = { pos.x + 1, pos.y },
         direction = dirs.south,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "rail-chain-signal",
         position = { pos.x - 2, pos.y },
         direction = dirs.north,
         force = game.forces.player,
      })
   elseif dir == dirs.east or dir == dirs.west then
      surf.create_entity({
         name = "rail-chain-signal",
         position = { pos.x, pos.y - 2 },
         direction = dirs.east,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "rail-chain-signal",
         position = { pos.x, pos.y + 1 },
         direction = dirs.west,
         force = game.forces.player,
      })
   elseif dir == dirs.northeast then
      surf.create_entity({
         name = "rail-chain-signal",
         position = { pos.x - 1, pos.y - 0 },
         direction = dirs.northwest,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "rail-chain-signal",
         position = { pos.x + 1, pos.y - 2 },
         direction = dirs.southeast,
         force = game.forces.player,
      })
   elseif dir == dirs.southwest then
      surf.create_entity({
         name = "rail-chain-signal",
         position = { pos.x - 2, pos.y + 1 },
         direction = dirs.northwest,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "rail-chain-signal",
         position = { pos.x + 0, pos.y - 1 },
         direction = dirs.southeast,
         force = game.forces.player,
      })
   elseif dir == dirs.southeast then
      surf.create_entity({
         name = "rail-chain-signal",
         position = { pos.x - 1, pos.y - 1 },
         direction = dirs.northeast,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "rail-chain-signal",
         position = { pos.x + 1, pos.y + 1 },
         direction = dirs.southwest,
         force = game.forces.player,
      })
   elseif dir == dirs.northwest then
      surf.create_entity({
         name = "rail-chain-signal",
         position = { pos.x - 2, pos.y - 2 },
         direction = dirs.northeast,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "rail-chain-signal",
         position = { pos.x + 0, pos.y + 0 },
         direction = dirs.southwest,
         force = game.forces.player,
      })
   else
      successful = false
      game.get_player(pindex).play_sound({ path = "utility/cannot_build" })
      build_comment = "direction error"
      return successful, build_comment
   end

   --Reduce the signal count and restore the cursor and wrap up
   game.get_player(pindex).cursor_stack.count = game.get_player(pindex).cursor_stack.count - 2
   game.get_player(pindex).clear_cursor()

   game.get_player(pindex).play_sound({ path = "entity-build/rail-chain-signal" })
   game.get_player(pindex).play_sound({ path = "entity-build/rail-chain-signal" })
   return successful, build_comment
end

--Places a rail signal pair around a rail depending on its direction. May fail if the spots are full. Copy of chain signal function
function mod.place_rail_signal_pair(rail, pindex)
   local stack = game.get_player(pindex).cursor_stack
   local stack2 = nil
   local build_comment = "no comment"
   local successful = true
   local dir = rail.direction
   local pos = rail.position
   local surf = rail.surface
   local can_place_all = true

   --1. Check if signals can be placed, based on direction
   if dir == dirs.north or dir == dirs.south then
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "rail-signal",
            position = { pos.x + 1, pos.y },
            direction = dirs.south,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "rail-signal",
            position = { pos.x - 2, pos.y },
            direction = dirs.north,
            force = game.forces.player,
         })
   elseif dir == dirs.east or dir == dirs.west then
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "rail-signal",
            position = { pos.x, pos.y - 2 },
            direction = dirs.east,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "rail-signal",
            position = { pos.x, pos.y + 1 },
            direction = dirs.west,
            force = game.forces.player,
         })
   elseif dir == dirs.northeast then
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "rail-signal",
            position = { pos.x - 1, pos.y - 0 },
            direction = dirs.northwest,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "rail-signal",
            position = { pos.x + 1, pos.y - 2 },
            direction = dirs.southeast,
            force = game.forces.player,
         })
   elseif dir == dirs.southwest then
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "rail-signal",
            position = { pos.x - 2, pos.y + 1 },
            direction = dirs.northwest,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "rail-signal",
            position = { pos.x + 0, pos.y - 1 },
            direction = dirs.southeast,
            force = game.forces.player,
         })
   elseif dir == dirs.southeast then
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "rail-signal",
            position = { pos.x - 1, pos.y - 1 },
            direction = dirs.northeast,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "rail-signal",
            position = { pos.x + 1, pos.y + 1 },
            direction = dirs.southwest,
            force = game.forces.player,
         })
   elseif dir == dirs.northwest then
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "rail-signal",
            position = { pos.x - 2, pos.y - 2 },
            direction = dirs.northeast,
            force = game.forces.player,
         })
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "rail-signal",
            position = { pos.x + 0, pos.y + 0 },
            direction = dirs.southwest,
            force = game.forces.player,
         })
   else
      successful = false
      game.get_player(pindex).play_sound({ path = "utility/cannot_build" })
      build_comment = "direction error"
      return successful, build_comment
   end

   if not can_place_all then
      successful = false
      game.get_player(pindex).play_sound({ path = "utility/cannot_build" })
      build_comment = "cannot place"
      return successful, build_comment
   end

   --2. Check if there are already chain signals or rail signals nearby. If yes, stop.
   local signals_found = 0
   local signals = surf.find_entities_filtered({ position = pos, radius = 3, name = "rail-chain-signal" })
   for i, signal in ipairs(signals) do
      signals_found = signals_found + 1
   end
   local signals = surf.find_entities_filtered({ position = pos, radius = 3, name = "rail-signal" })
   for i, signal in ipairs(signals) do
      signals_found = signals_found + 1
   end
   if signals_found > 0 then
      successful = false
      game.get_player(pindex).play_sound({ path = "utility/cannot_build" })
      build_comment = "Too close to existing signals."
      return successful, build_comment
   end

   --3. Check whether the player has enough rail chain signals.
   if not (stack.valid and stack.valid_for_read and stack.name == "rail-signal" and stack.count >= 2) then
      --Check if the inventory has one instead
      if storage.players[pindex].inventory.lua_inventory.get_item_count("rail-signal") < 2 then
         game.get_player(pindex).play_sound({ path = "utility/cannot_build" })
         build_comment = "You need to have at least 2 rail signals on you."
         successful = false
         game.get_player(pindex).play_sound({ path = "utility/cannot_build" })
         return successful, build_comment
      else
         --Take from the inventory.
         stack2 = storage.players[pindex].inventory.lua_inventory.find_item_stack("rail-signal")
         game.get_player(pindex).cursor_stack.swap_stack(stack2)
         stack = game.get_player(pindex).cursor_stack
         storage.players[pindex].inventory.max = #storage.players[pindex].inventory.lua_inventory
      end
   end

   --4. Place the signals.
   if dir == dirs.north or dir == dirs.south then
      surf.create_entity({
         name = "rail-signal",
         position = { pos.x + 1, pos.y },
         direction = dirs.south,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "rail-signal",
         position = { pos.x - 2, pos.y },
         direction = dirs.north,
         force = game.forces.player,
      })
   elseif dir == dirs.east or dir == dirs.west then
      surf.create_entity({
         name = "rail-signal",
         position = { pos.x, pos.y - 2 },
         direction = dirs.east,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "rail-signal",
         position = { pos.x, pos.y + 1 },
         direction = dirs.west,
         force = game.forces.player,
      })
   elseif dir == dirs.northeast then
      surf.create_entity({
         name = "rail-signal",
         position = { pos.x - 1, pos.y - 0 },
         direction = dirs.northwest,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "rail-signal",
         position = { pos.x + 1, pos.y - 2 },
         direction = dirs.southeast,
         force = game.forces.player,
      })
   elseif dir == dirs.southwest then
      surf.create_entity({
         name = "rail-signal",
         position = { pos.x - 2, pos.y + 1 },
         direction = dirs.northwest,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "rail-signal",
         position = { pos.x + 0, pos.y - 1 },
         direction = dirs.southeast,
         force = game.forces.player,
      })
   elseif dir == dirs.southeast then
      surf.create_entity({
         name = "rail-signal",
         position = { pos.x - 1, pos.y - 1 },
         direction = dirs.northeast,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "rail-signal",
         position = { pos.x + 1, pos.y + 1 },
         direction = dirs.southwest,
         force = game.forces.player,
      })
   elseif dir == dirs.northwest then
      surf.create_entity({
         name = "rail-signal",
         position = { pos.x - 2, pos.y - 2 },
         direction = dirs.northeast,
         force = game.forces.player,
      })
      surf.create_entity({
         name = "rail-signal",
         position = { pos.x + 0, pos.y + 0 },
         direction = dirs.southwest,
         force = game.forces.player,
      })
   else
      successful = false
      game.get_player(pindex).play_sound({ path = "utility/cannot_build" })
      build_comment = "direction error"
      return successful, build_comment
   end

   --Reduce the signal count and restore the cursor and wrap up
   game.get_player(pindex).cursor_stack.count = game.get_player(pindex).cursor_stack.count - 2
   game.get_player(pindex).clear_cursor()

   game.get_player(pindex).play_sound({ path = "entity-build/rail-signal" })
   game.get_player(pindex).play_sound({ path = "entity-build/rail-signal" })
   return successful, build_comment
end

--Deletes rail signals around a rail.
function mod.destroy_signals(rail)
   local chains =
      rail.surface.find_entities_filtered({ position = rail.position, radius = 2, name = "rail-chain-signal" })
   for i, chain in ipairs(chains) do
      chain.destroy()
   end
   local signals = rail.surface.find_entities_filtered({ position = rail.position, radius = 2, name = "rail-signal" })
   for i, signal in ipairs(signals) do
      signal.destroy()
   end
end

--Places a train stop facing the direction of the end rail.
function mod.build_train_stop(anchor_rail, pindex)
   local build_comment = ""
   local surf = game.get_player(pindex).surface
   local stack = game.get_player(pindex).cursor_stack
   local stack2 = nil
   local pos = nil
   local dir = -1
   local build_area = nil
   local can_place_all = true
   local is_end_rail

   --1. Firstly, check if the player has a train stop in hand
   if not (stack.valid and stack.valid_for_read and stack.name == "train-stop" and stack.count > 0) then
      --Check if the inventory has enough
      if storage.players[pindex].inventory.lua_inventory.get_item_count("train-stop") < 1 then
         game.get_player(pindex).play_sound({ path = "utility/cannot_build" })
         printout({ "fa.rail-need-one-train-stop" }, pindex)
         return
      else
         --Take from the inventory.
         stack2 = storage.players[pindex].inventory.lua_inventory.find_item_stack("train-stop")
         game.get_player(pindex).cursor_stack.swap_stack(stack2)
         stack = game.get_player(pindex).cursor_stack
         storage.players[pindex].inventory.max = #storage.players[pindex].inventory.lua_inventory
      end
   end

   --2. Secondly, find the direction based on end rail or player direction
   is_end_rail, end_rail_dir, build_comment = Rails.check_end_rail(anchor_rail, pindex)
   if is_end_rail then
      dir = end_rail_dir
   else
      --Choose the dir based on player direction
      turn_to_cursor_direction_cardinal(pindex)
      if anchor_rail.direction == dirs.north or anchor_rail.direction == dirs.south then
         if
            storage.players[pindex].player_direction == dirs.north
            or storage.players[pindex].player_direction == dirs.east
         then
            dir = dirs.north
         elseif
            storage.players[pindex].player_direction == dirs.south
            or storage.players[pindex].player_direction == dirs.west
         then
            dir = dirs.south
         end
      elseif anchor_rail.direction == dirs.east or anchor_rail.direction == dirs.west then
         if
            storage.players[pindex].player_direction == dirs.north
            or storage.players[pindex].player_direction == dirs.east
         then
            dir = dirs.east
         elseif
            storage.players[pindex].player_direction == dirs.south
            or storage.players[pindex].player_direction == dirs.west
         then
            dir = dirs.west
         end
      end
   end
   pos = anchor_rail.position
   if dir == dirs.northeast or dir == dirs.southeast or dir == dirs.southwest or dir == dirs.northwest then
      game.get_player(pindex).play_sound({ path = "utility/cannot_build" })
      printout({ "fa.rail-horizontal-vertical-only" }, pindex)
      game.get_player(pindex).clear_cursor()
      return
   end

   --3. Clear trees and rocks in the build area
   temp1, build_comment = PlayerMiningTools.clear_obstacles_in_circle(pos, 3, pindex)

   --4. Check if every object can be placed
   if dir == dirs.north then
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "train-stop",
            position = { pos.x + 2, pos.y + 0 },
            direction = dirs.north,
            force = game.forces.player,
         })
   elseif dir == dirs.east then
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "train-stop",
            position = { pos.x + 0, pos.y + 2 },
            direction = dirs.east,
            force = game.forces.player,
         })
   elseif dir == dirs.south then
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "train-stop",
            position = { pos.x - 2, pos.y + 0 },
            direction = dirs.south,
            force = game.forces.player,
         })
   elseif dir == dirs.west then
      can_place_all = can_place_all
         and surf.can_place_entity({
            name = "train-stop",
            position = { pos.x - 0, pos.y - 2 },
            direction = dirs.west,
            force = game.forces.player,
         })
   end

   if not can_place_all then
      game.get_player(pindex).play_sound({ path = "utility/cannot_build" })
      printout({ "fa.rail-building-area-occupied-cursor" }, pindex)
      game.get_player(pindex).clear_cursor()
      return
   end

   --5. Build the five rail entities to create the structure
   if dir == dirs.north then
      surf.create_entity({
         name = "train-stop",
         position = { pos.x + 2, pos.y + 0 },
         direction = dirs.north,
         force = game.forces.player,
      })
   elseif dir == dirs.east then
      surf.create_entity({
         name = "train-stop",
         position = { pos.x + 0, pos.y + 2 },
         direction = dirs.east,
         force = game.forces.player,
      })
   elseif dir == dirs.south then
      surf.create_entity({
         name = "train-stop",
         position = { pos.x - 2, pos.y + 0 },
         direction = dirs.south,
         force = game.forces.player,
      })
   elseif dir == dirs.west then
      surf.create_entity({
         name = "train-stop",
         position = { pos.x - 0, pos.y - 2 },
         direction = dirs.west,
         force = game.forces.player,
      })
   end

   --6 Remove 5 rail units from the player's hand
   game.get_player(pindex).cursor_stack.count = game.get_player(pindex).cursor_stack.count - 1
   game.get_player(pindex).clear_cursor()

   --7. Sounds and results
   game.get_player(pindex).play_sound({ path = "entity-build/train-stop" })
   printout({ "", "Train stop built facing", FaUtils.direction_lookup(dir), ", ", build_comment }, pindex)
   return
end

--Loads and opens the rail builder menu
function mod.open_menu(pindex, rail)
   local router = UiRouter.get_router(pindex)

   if storage.players[pindex].vanilla_mode then return end
   router:open_ui(UiRouter.UI_NAMES.RAIL_BUILDER)
   storage.players[pindex].move_queue = {}

   --Set the menu line counter to 0
   storage.players[pindex].rail_builder.index = 0

   --Determine rail type
   local is_end_rail, end_dir, comment = Rails.check_end_rail(rail, pindex)
   local dir = rail.direction
   if is_end_rail then
      if dir == dirs.north or dir == dirs.east or dir == dirs.south or dir == dirs.west then
         --Straight end rails
         storage.players[pindex].rail_builder.rail_type = 1
         storage.players[pindex].rail_builder.index_max = 10
      else
         --Diagonal end rails
         storage.players[pindex].rail_builder.rail_type = 2
         storage.players[pindex].rail_builder.index_max = 6
      end
   else
      if dir == dirs.north or dir == dirs.east or dir == dirs.south or dir == dirs.west then
         --Straight mid rails
         storage.players[pindex].rail_builder.rail_type = 3
         storage.players[pindex].rail_builder.index_max = 3
      else
         --Diagonal mid rails
         storage.players[pindex].rail_builder.rail_type = 4
         storage.players[pindex].rail_builder.index_max = 3
      end
   end

   --Play sound
   game.get_player(pindex).play_sound({ path = "Open-Inventory-Sound" })

   --Load menu
   storage.players[pindex].rail_builder.rail = rail
   mod.run_menu(pindex, false)
end

--Resets and closes the rail builder menu
function mod.close_menu(pindex, mute_in)
   local router = UiRouter.get_router(pindex)

   local mute = mute_in or false
   router:close_ui()

   --Set the menu line counter to 0
   storage.players[pindex].rail_builder.index = 0

   --play sound
   if not mute then game.get_player(pindex).play_sound({ path = "Close-Inventory-Sound" }) end
end

--Moves up the rail builder menu
function mod.menu_up(pindex)
   --Decrement the index
   storage.players[pindex].rail_builder.index = storage.players[pindex].rail_builder.index - 1

   --Check the index against the limit
   if storage.players[pindex].rail_builder.index < 0 then
      storage.players[pindex].rail_builder.index = 0
      game.get_player(pindex).play_sound({ path = "inventory-edge" })
   else
      --Play sound
      game.get_player(pindex).play_sound({ path = "Inventory-Move" })
   end

   --Load menu
   mod.run_menu(pindex, false)
end

--Moves down the rail buidler menu
function mod.menu_down(pindex)
   --Increment the index
   storage.players[pindex].rail_builder.index = storage.players[pindex].rail_builder.index + 1

   --Check the index against the limit
   if storage.players[pindex].rail_builder.index > storage.players[pindex].rail_builder.index_max then
      storage.players[pindex].rail_builder.index = storage.players[pindex].rail_builder.index_max
      game.get_player(pindex).play_sound({ path = "inventory-edge" })
   else
      --Play sound
      game.get_player(pindex).play_sound({ path = "Inventory-Move" })
   end

   --Load menu
   mod.run_menu(pindex, false)
end

--Builder menu to build rail structures
function mod.run_menu(pindex, clicked_in)
   local clicked = clicked_in
   local comment = ""
   local menu_line = storage.players[pindex].rail_builder.index
   local rail_type = storage.players[pindex].rail_builder.rail_type
   local rail = storage.players[pindex].rail_builder.rail

   if rail == nil then
      comment = " Rail nil error "
      printout(comment, pindex)
      mod.close_menu(pindex, false)
      return
   end

   if menu_line == 0 then
      comment = comment
         .. "Rail builder, select a structure to build by going up or down this menu, attempt to build it via LEFT BRACKET, "
      printout(comment, pindex)
      return
   end

   if rail_type == 1 then
      --Straight end rails
      if menu_line == 1 then
         if not clicked then
            comment = comment .. "Left turn 45 degrees"
            printout(comment, pindex)
         else
            --Build it here
            mod.build_rail_turn_left_45_degrees(rail, pindex)
         end
      elseif menu_line == 2 then
         if not clicked then
            comment = comment .. "Right turn 45 degrees"
            printout(comment, pindex)
         else
            --Build it here
            mod.build_rail_turn_right_45_degrees(rail, pindex)
         end
      elseif menu_line == 3 then
         if not clicked then
            comment = comment .. "Left turn 90 degrees"
            printout(comment, pindex)
         else
            --Build it here
            mod.build_rail_turn_left_90_degrees(rail, pindex)
         end
      elseif menu_line == 4 then
         if not clicked then
            comment = comment .. "Right turn 90 degrees"
            printout(comment, pindex)
         else
            --Build it here
            mod.build_rail_turn_right_90_degrees(rail, pindex)
         end
      elseif menu_line == 5 then
         if not clicked then
            comment = comment .. "Train stop facing end rail direction"
            printout(comment, pindex)
         else
            --Build it here
            mod.build_train_stop(rail, pindex)
         end
      elseif menu_line == 6 then
         if not clicked then
            comment = comment .. "Rail fork left and right and forward"
            printout(comment, pindex)
         else
            --Build it here
            mod.build_fork_at_end_rail(rail, pindex, true, true, true)
         end
      elseif menu_line == 7 then
         if not clicked then
            comment = comment .. "Rail fork only left and right"
            printout(comment, pindex)
         else
            --Build it here
            mod.build_fork_at_end_rail(rail, pindex, false, true, true)
         end
      elseif menu_line == 8 then
         if not clicked then
            comment = comment .. "Rail fork only left and forward"
            printout(comment, pindex)
         else
            --Build it here
            mod.build_fork_at_end_rail(rail, pindex, true, true, false)
         end
      elseif menu_line == 9 then
         if not clicked then
            comment = comment .. "Rail fork only right and forward"
            printout(comment, pindex)
         else
            --Build it here
            mod.build_fork_at_end_rail(rail, pindex, true, false, true)
         end
      elseif menu_line == 10 then
         if not clicked then
            comment = comment .. "Rail bypass junction"
            printout(comment, pindex)
         else
            --Build it here
            mod.build_rail_bypass_junction(rail, pindex)
         end
      end
   elseif rail_type == 2 then
      --Diagonal end rails
      if menu_line == 1 then
         if not clicked then
            comment = comment .. "Left turn 45 degrees"
            printout(comment, pindex)
         else
            --Build it here
            mod.build_rail_turn_left_45_degrees(rail, pindex)
         end
      elseif menu_line == 2 then
         if not clicked then
            comment = comment .. "Right turn 45 degrees"
            printout(comment, pindex)
         else
            --Build it here
            mod.build_rail_turn_right_45_degrees(rail, pindex)
         end
      elseif menu_line == 3 then
         if not clicked then
            comment = comment .. "Rail fork left and right and forward"
            printout(comment, pindex)
         else
            --Build it here
            mod.build_fork_at_end_rail(rail, pindex, true, true, true)
         end
      elseif menu_line == 4 then
         if not clicked then
            comment = comment .. "Rail fork only left and right"
            printout(comment, pindex)
         else
            --Build it here
            mod.build_fork_at_end_rail(rail, pindex, false, true, true)
         end
      elseif menu_line == 5 then
         if not clicked then
            comment = comment .. "Rail fork only left and forward"
            printout(comment, pindex)
         else
            --Build it here
            mod.build_fork_at_end_rail(rail, pindex, true, true, false)
         end
      elseif menu_line == 6 then
         if not clicked then
            comment = comment .. "Rail fork only right and forward"
            printout(comment, pindex)
         else
            --Build it here
            mod.build_fork_at_end_rail(rail, pindex, true, false, true)
         end
      end
   elseif rail_type == 3 then
      --Straight mid rails
      if menu_line == 1 then
         if not clicked then
            comment = comment .. "Pair of chain rail signals."
            printout(comment, pindex)
         else
            local success, build_comment = mod.place_chain_signal_pair(rail, pindex)
            if success then
               comment = "Chain signals placed."
            else
               comment = comment .. build_comment
            end
            printout(comment, pindex)
         end
      elseif menu_line == 2 then
         if not clicked then
            comment = comment
               .. "Pair of regular rail signals, warning: do not use regular rail signals unless you are sure about what you are doing because trains can easily get deadlocked at them"
            printout(comment, pindex)
         else
            local success, build_comment = mod.place_rail_signal_pair(rail, pindex)
            if success then
               comment =
                  "Rail signals placed, warning: do not use regular rail signals unless you are sure about what you are doing because trains can easily get deadlocked at them"
            else
               comment = comment .. build_comment
            end
            printout(comment, pindex)
         end
      elseif menu_line == 3 then
         if not clicked then
            comment = comment .. "Clear rail signals"
            printout(comment, pindex)
         else
            Rails.mine_signals(rail, pindex)
            printout({ "fa.rail-signals-cleared" }, pindex)
         end
      end
   elseif rail_type == 4 then
      --Diagonal mid rails
      if menu_line == 1 then
         if not clicked then
            comment = comment .. "Pair of chain rail signals."
            printout(comment, pindex)
         else
            local success, build_comment = mod.place_chain_signal_pair(rail, pindex)
            if success then
               comment = "Chain signals placed."
            else
               comment = comment .. build_comment
            end
            printout(comment, pindex)
         end
      elseif menu_line == 2 then
         if not clicked then
            comment = comment
               .. "Pair of regular rail signals, warning: do not use regular rail signals unless you are sure about what you are doing because trains can easily get deadlocked at them"
            printout(comment, pindex)
         else
            local success, build_comment = mod.place_rail_signal_pair(rail, pindex)
            if success then
               comment =
                  "Rail signals placed, warning: do not use regular rail signals unless you are sure about what you are doing because trains can easily get deadlocked at them"
            else
               comment = comment .. build_comment
            end
            printout(comment, pindex)
         end
      elseif menu_line == 3 then
         if not clicked then
            comment = comment .. "Clear rail signals"
            printout(comment, pindex)
         else
            Rails.mine_signals(rail, pindex)
            printout({ "fa.rail-signals-cleared" }, pindex)
         end
      end
   end
   return
end

return mod
