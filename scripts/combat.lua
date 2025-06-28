--Here: functions relating to combat, repair packs
--Does not include event handlers, guns and equipment maanagement

local util = require("util")
local Equipment = require("scripts.equipment")
local FaUtils = require("scripts.fa-utils")
local Graphics = require("scripts.graphics")
local Localising = require("scripts.localising")
local MessageBuilder = require("scripts.message-builder")
local Mouse = require("scripts.mouse")
local UiRouter = require("scripts.ui.router")
local Viewpoint = require("scripts.viewpoint")

local mod = {}

--One-click repair pack usage.
function mod.repair_pack_used(ent, pindex)
   local p = game.get_player(pindex)
   local stack = p.cursor_stack
   --Repair the entity found
   if
      ent
      and ent.valid
      and ent.is_entity_with_health
      and ent.get_health_ratio() < 1
      and ent.type ~= "resource"
      and not ent.force.is_enemy(p.force)
      and ent.name ~= "character"
   then
      p.play_sound({ path = "utility/default_manual_repair" })
      local health_diff = ent.max_health - ent.health
      local dura = stack.durability or 0
      if health_diff < 10 then --free repair for tiny damages
         ent.health = ent.max_health
         local msg = MessageBuilder.new()
         msg:fragment({ "fa.combat-fully-repaired" })
         msg:fragment(Localising.get_localised_name_with_fallback(ent))
         printout(msg:build(), pindex)
      elseif health_diff < dura then
         ent.health = ent.max_health
         stack.drain_durability(health_diff)
         local msg = MessageBuilder.new()
         msg:fragment({ "fa.combat-fully-repaired" })
         msg:fragment(Localising.get_localised_name_with_fallback(ent))
         printout(msg:build(), pindex)
      else --if health_diff >= dura then
         stack.drain_durability(dura)
         ent.health = ent.health + dura
         local msg = MessageBuilder.new()
         msg:fragment({ "fa.combat-partially-repaired" })
         msg:fragment(Localising.get_localised_name_with_fallback(ent))
         msg:fragment({ "fa.combat-consumed-repair-pack" })
         printout(msg:build(), pindex)
         --Note: This automatically subtracts correctly and decerements the pack in hand.
      end
   end
end

--Tries to repair all relevant entities within a certain distance from the player
function mod.repair_area(radius_in, pindex)
   local p = game.get_player(pindex)
   local stack = p.cursor_stack
   local repaired_count = 0
   local packs_used = 0
   local radius = math.min(radius_in, 25)
   if stack.count < 2 then
      --If you are low on repair packs, stop
      printout({ "fa.combat-need-repair-packs" }, pindex)
      return
   end
   local ents = p.surface.find_entities_filtered({ position = p.position, radius = radius })
   for i, ent in ipairs(ents) do
      --Repair the entity found
      if
         ent
         and ent.valid
         and ent.is_entity_with_health
         and ent.get_health_ratio() < 1
         and ent.type ~= "resource"
         and not ent.force.is_enemy(p.force)
         and ent.name ~= "character"
      then
         p.play_sound({ path = "utility/default_manual_repair" })
         local health_diff = ent.max_health - ent.health
         local dura = stack.durability or 0
         if health_diff < 10 then --free repair for tiny damages
            ent.health = ent.max_health
            repaired_count = repaired_count + 1
         elseif health_diff < dura then
            ent.health = ent.max_health
            stack.drain_durability(health_diff)
            repaired_count = repaired_count + 1
         elseif stack.count < 2 then
            --If you are low on repair packs, stop
            printout(
               "Repaired "
                  .. repaired_count
                  .. " structures using "
                  .. packs_used
                  .. " repair packs, stopped because you are low on repair packs.",
               pindex
            )
            return
         else
            --Finish the current repair pack
            stack.drain_durability(dura)
            packs_used = packs_used + 1
            ent.health = ent.health + dura

            --Repeat unhtil fully repaired or out of packs
            while ent.get_health_ratio() < 1 do
               health_diff = ent.max_health - ent.health
               dura = stack.durability or 0
               if health_diff < 10 then --free repair for tiny damages
                  ent.health = ent.max_health
                  repaired_count = repaired_count + 1
               elseif health_diff < dura then
                  ent.health = ent.max_health
                  stack.drain_durability(health_diff)
                  repaired_count = repaired_count + 1
               elseif stack.count < 2 then
                  --If you are low on repair packs, stop
                  printout(
                     "Repaired "
                        .. repaired_count
                        .. " structures using "
                        .. packs_used
                        .. " repair packs, stopped because you are low on repair packs.",
                     pindex
                  )
                  return
               else
                  --Finish the current repair pack
                  stack.drain_durability(dura)
                  packs_used = packs_used + 1
                  ent.health = ent.health + dura
               end
            end
         end
      end
   end
   if repaired_count == 0 then
      printout({ "fa.combat-nothing-to-repair", radius }, pindex)
      return
   end
   printout(
      "Repaired all "
         .. repaired_count
         .. " structures within "
         .. radius
         .. " tiles of you, using "
         .. packs_used
         .. " repair packs.",
      pindex
   )
end

--Plays enemy proximity alert sounds. Frequency is determined by distance andmode, and intensity is determined by the threat level.
function mod.check_and_play_enemy_alert_sound(mode_in)
   for pindex, player in pairs(players) do
      local mode = mode_in or 1
      local p = game.get_player(pindex)
      if p ~= nil and p.valid then
         local nearest_enemy =
            p.surface.find_nearest_enemy({ position = p.position, max_distance = 100, force = p.force })
         local dist = -1
         if nearest_enemy ~= nil and nearest_enemy.valid then
            dist = math.floor(util.distance(nearest_enemy.position, p.position))
         else
            return
         end
         --Attempt to detect if west or east
         local diffx = nearest_enemy.position.x - p.position.x
         local diffy = nearest_enemy.position.y - p.position.y
         local x_offset = 0
         if math.abs(diffx) > 2 * math.abs(diffy) then
            --Counts as east or west
            if diffx > 0 then
               x_offset = 7
            elseif diffx < 0 then
               x_offset = -7
            end
         end
         local pos = { x = p.position.x + x_offset, y = p.position.y }

         --Play sounds according tomode
         if mode == 1 then -- Nearest enemy is far (lowest freq)
            if dist < 100 then p.play_sound({ path = "alert-enemy-presence-low", position = pos }) end
            --Additional alert if there are more than 5 enemies nearby
            local enemies = p.surface.find_enemy_units(p.position, 25, p.force)
            if #enemies > 5 then
               p.play_sound({ path = "alert-enemy-presence-high", position = pos })
            else
               for i, enemy in ipairs(enemies) do
                  --Also check for strong enemies: big/huge biters, huge spitters, medium or larger worms, not spawners
                  if enemy.max_health > 360 then
                     p.play_sound({ path = "alert-enemy-presence-high", position = pos })
                     return
                  end
               end
            end
         elseif mode == 2 then -- Nearest enemy is closer (medium freq)
            if dist < 50 then p.play_sound({ path = "alert-enemy-presence-low", position = pos }) end
            --Additional alert if there are more than 10 enemies nearby
            local enemies = p.surface.find_enemy_units(p.position, 25, p.force)
            if #enemies > 10 then p.play_sound({ path = "alert-enemy-presence-high", position = pos }) end
         elseif mode == 3 then -- Nearest enemy is too close (highest freq)
            if dist < 25 then p.play_sound({ path = "alert-enemy-presence-low", position = pos }) end
         end
      end
   end
end

--Locks the cursor to the nearest enemy within 50 tiles. Also plays a sound if the enemy is within range of the gun in hand.
function mod.aim_gun_at_nearest_enemy(pindex, enemy_in)
   local router = UiRouter.get_router(pindex)

   local p = game.get_player(pindex)
   if p == nil or p.character == nil or p.character.valid == false then return end
   local vp = Viewpoint.get_viewpoint(pindex)
   local cursor_pos = vp:get_cursor_pos()
   local gun_index = p.character.selected_gun_index
   local guns_inv = p.get_inventory(defines.inventory.character_guns)
   local ammo_inv = game.get_player(pindex).get_inventory(defines.inventory.character_ammo)
   local gun_stack = guns_inv[gun_index]
   local ammo_stack = ammo_inv[gun_index]
   local enemy = enemy_in
   --Return if missing a gun or ammo
   if gun_stack == nil or not gun_stack.valid_for_read or not gun_stack.valid then return false end
   if ammo_stack == nil or not ammo_stack.valid_for_read or not ammo_stack.valid then return false end
   --Return if in Cursormode
   if vp:get_cursor_enabled() then return false end
   --Return if in a menu
   if router:is_ui_open() then return false end
   --Check for nearby enemies
   if enemy_in == nil or not enemy_in.valid then
      enemy = p.surface.find_nearest_enemy({ position = p.position, max_distance = 50, force = p.force })
   end
   if enemy == nil or not enemy.valid then return false end
   --Play a sound when the enemy is within range of the gun
   local range = gun_stack.prototype.attack_parameters.range
   local dist = util.distance(p.position, enemy.position)
   if dist < range and p.character.can_shoot(enemy, enemy.position) then
      p.play_sound({ path = "player-aim-locked", volume_modifier = 0.5 })
   end
   --Return if there is a gun and ammo combination that already aims by itself
   if gun_stack.name == "pistol" or gun_stack.name == "submachine-gun" and dist < 10 then --or ammo_stack.name == "rocket" or ammo_stack.name == "explosive-rocket" then
      --**Note: normal/explosive rockets only fire when they lock on a target anyway. Meanwhile the SMG auto-aims only when close enough
      return true
   end
   --If in range, move the cursor onto the enemy to aim the gun
   if dist < range then
      vp:set_cursor_pos({ x = enemy.position.x, y = enemy.position.y })
      Mouse.move_mouse_pointer(enemy.position, pindex)
      Graphics.draw_cursor_highlight(pindex, nil, nil, true)
   end
   return true
end

--Max ranges are determined by the game GUI, min ranges represent the minimum distance where you will not get damaged.
function mod.get_grenade_or_capsule_range(stack)
   local max_range = 20
   local min_range = 0
   if stack == nil or stack.valid_for_read == false then
      return min_range, max_range
   elseif stack.name == "grenade" then
      max_range = 15
      min_range = 7
   elseif stack.name == "cluster-grenade" then
      max_range = 20
      min_range = 12
   elseif stack.name == "poison-capsule" then
      max_range = 25
      min_range = 12
   elseif stack.name == "slowdown-capsule" then
      max_range = 25
      min_range = 0
   elseif stack.name == "cliff-explosives" then
      max_range = 10
      min_range = 0
   elseif stack.name == "defender-capsule" then
      max_range = 20
      min_range = 0
   elseif stack.name == "distractor-capsule" then
      max_range = 25
      min_range = 0
   elseif stack.name == "destroyer-capsule" then
      max_range = 20
      min_range = 0
   end
   return min_range, max_range
end

--[[
   Grenade aiming rules
   - First label and sort all potential_targets by distance
   - If running or driving forward or backward, do not throw at anything directly ahead of you.
   1. Target enemy spawners or worms found within min and max range, nearest first
   2. If none, then target enemy units or characters found within min and max range, nearest first
   3. If none, then target the cursor position if within min and max range
   4. If not, and if running and if any enemies are close behind you, then target them
   5. If not, do not throw.
]]
function mod.smart_aim_grenades_and_capsules(pindex, draw_circles_in)
   local draw_circles = draw_circles_in or false
   local p = game.get_player(pindex)
   local vp = Viewpoint.get_viewpoint(pindex)
   local cursor_pos = vp:get_cursor_pos()
   local hand = p.cursor_stack
   if hand == nil or hand.valid_for_read == false then return end
   local running_dir = nil
   local player_pos = p.position
   --Get running direction
   if p.walking_state.walking then running_dir = p.walking_state.direction end
   if p.vehicle and p.vehicle.valid and p.vehicle.speed > 0 then running_dir = FaUtils.get_heading_value(p.vehicle) end
   if p.vehicle and p.vehicle.valid and p.vehicle.speed < 0 then
      running_dir = FaUtils.rotate_180(FaUtils.get_heading_value(p.vehicle))
   end
   if p.vehicle and p.vehicle.valid and p.vehicle.type == "spider-vehicle" then running_dir = nil end
   --Determine max and min throwing ranges based on capsule type
   local min_range, max_range = mod.get_grenade_or_capsule_range(hand)
   --Draw the ranges
   if draw_circles then
      rendering.draw_circle({
         surface = p.surface,
         target = player_pos,
         radius = min_range,
         width = 4,
         color = { 1, 0, 0 },
         draw_on_ground = true,
         time_to_live = 60,
      })
      rendering.draw_circle({
         surface = p.surface,
         target = player_pos,
         radius = max_range,
         width = 8,
         color = { 1, 0, 0 },
         draw_on_ground = true,
         time_to_live = 60,
      })
   end
   --Scan for targets within range
   local potential_targets = p.surface.find_entities_filtered({
      surface = p.surface,
      position = player_pos,
      radius = max_range,
      force = { p.force.name, "neutral" },
      invert = true,
   })
   --Sort potential targets by distance from the player
   potential_targets = FaUtils.sort_ents_by_distance_from_pos(player_pos, potential_targets)
   --Label potential targets
   for i, t in ipairs(potential_targets) do
      if t.valid and draw_circles then
         rendering.draw_circle({
            surface = p.surface,
            target = t.position,
            radius = 1,
            width = 4,
            color = { 1, 0, 0 },
            draw_on_ground = true,
            time_to_live = 60,
         })
      end
   end
   --1. Target enemy spawners and worms
   for i, t in ipairs(potential_targets) do
      if t.valid and t.type == "unit-spawner" or t.type == "turret" then
         local dist = util.distance(player_pos, t.position)
         local dir = FaUtils.get_direction_precise(t.position, player_pos)
         if dist > min_range and dist < max_range and dir ~= running_dir then
            return t.position
         elseif draw_circles then
            --Relabel it as skipped
            rendering.draw_circle({
               surface = p.surface,
               target = t.position,
               radius = 1,
               width = 8,
               color = { 0, 0, 1 },
               draw_on_ground = true,
               time_to_live = 60,
            })
         end
      end
   end
   --2a. Target enemy units or characters
   for i, t in ipairs(potential_targets) do
      if t.valid and t.type == "unit" or t.type == "character" then
         local dist = util.distance(player_pos, t.position)
         local dir = FaUtils.get_direction_precise(t.position, player_pos)
         if dist > min_range and dist < max_range and dir ~= running_dir then
            return t.position
         elseif draw_circles then
            --Relabel it as skipped
            rendering.draw_circle({
               surface = p.surface,
               target = t.position,
               radius = 1,
               width = 8,
               color = { 0, 0, 1 },
               draw_on_ground = true,
               time_to_live = 60,
            })
         end
      end
   end
   --2b. Target other entities (not "anything" because that includes random stuff too)
   for i, t in ipairs(potential_targets) do
      if t.valid and (t.prototype.is_building or t.prototype.is_military_target) then
         local dist = util.distance(player_pos, t.position)
         local dir = FaUtils.get_direction_precise(t.position, player_pos)
         if dist > min_range and dist < max_range and dir ~= running_dir then
            return t.position
         elseif draw_circles then
            --Relabel it as skipped
            rendering.draw_circle({
               surface = p.surface,
               target = t.position,
               radius = 1,
               width = 8,
               color = { 0, 0, 1 },
               draw_on_ground = true,
               time_to_live = 60,
            })
         end
      end
   end
   --3. Target the cursor position unless running at it
   local cursor_dist = util.distance(player_pos, cursor_pos)
   local cursor_dir = FaUtils.get_direction_precise(cursor_pos, player_pos)
   if cursor_dist > min_range and cursor_dist < max_range and cursor_dir ~= running_dir then return cursor_pos end
   --4. If running and if any enemies are close behind you, then target them
   --The player runs at least 8.9 tiles per second and the throw takes around half a second
   --so a displacement of 4 tiles is a safe bet. Also assume a max range penalty because it is behind you
   if running_dir ~= nil and #potential_targets > 0 then
      local back_dir = FaUtils.rotate_180(running_dir)
      for i, t in ipairs(potential_targets) do
         if t.valid and (t.prototype.is_building or t.prototype.is_military_target) then
            local dist = util.distance(player_pos, t.position)
            local dir = FaUtils.get_direction_precise(t.position, player_pos)
            if dist > min_range - 4 and dist < max_range - 8 and dir == back_dir then return t.position end
         end
      end
   end

   p.play_sound({ path = "utility/cannot_build" })
   return nil
end

--Checks if the conditions are valid for shooting an atomic bomb
--laterdo review
function mod.run_atomic_bomb_checks(pindex)
   local p = game.get_player(pindex)
   if p.character == nil then return end
   local vp = Viewpoint.get_viewpoint(pindex)
   local cursor_pos = vp:get_cursor_pos()
   --local main_inv = p.get_inventory(defines.inventory.character_main)
   --local ammos_count = #ammo_inv - ammo_inv.count_empty_stacks()
   local ammo_inv = p.get_inventory(defines.inventory.character_ammo)
   local selected_ammo = ammo_inv[p.character.selected_gun_index]
   local target_pos = p.shooting_state.position
   local abort_missle = false
   local abort_message = ""

   if not selected_ammo or not selected_ammo.valid_for_read then return end

   --Stop checking if atomic bombs are not equipped
   if selected_ammo.name ~= "atomic-bomb" then return end

   --Stop checking if vanilla mode
   if players[pindex].vanilla_mode == true then return end

   --If the target position is shown as the center of the screen where the player stands, it means the cursor is not on screen
   if target_pos == nil or util.distance(p.position, target_pos) < 1.5 then
      target_pos = cursor_pos
      p.shooting_state.position = cursor_pos
      if selected_ammo.name == "atomic-bomb" then
         abort_missle = true
         abort_message = "Aiming alert, scroll mouse wheel to zoom out."
      end
   end

   --If the target position is shown as the center of the screen where the player stands, it means the cursor is not on screen
   local aim_dist_1 = util.distance(p.position, target_pos)
   local aim_dist_2 = util.distance(p.position, cursor_pos)
   if aim_dist_1 < 1.5 then
      abort_missle = true
      abort_message = "Aiming alert, scroll mouse wheel to zoom out."
   elseif util.distance(target_pos, cursor_pos) > 2 then
      abort_missle = true
      abort_message = "Aiming alert, move cursor to sync mouse."
   end
   if aim_dist_1 < 35 or aim_dist_2 < 35 then
      abort_missle = true
      abort_message = "Range alert, target too close, hold to fire anyway."
   end
   --p.print("abort check")

   --Take actions to abort the firing
   if abort_missle then
      --Remove all atomic bombs
      Equipment.delete_equipped_atomic_bombs(pindex)

      --Warn the player
      p.play_sound({ path = "utility/cannot_build" })
      printout(abort_message, pindex)

      --Schedule to restore the items on a later tick
      schedule(310, "call_to_restore_equipped_atomic_bombs", pindex)
   else
      --Suppress alerts for 10 seconds?
   end
end

return mod
