--Here: functions relating to combat, repair packs
--Does not include event handlers, guns and equipment maanagement

local util = require("util")
local FaUtils = require("scripts.fa-utils")
local Localising = require("scripts.localising")
local SoundModel = require("scripts.sound-model")
local Speech = require("scripts.speech")
local MessageBuilder = Speech.MessageBuilder
local StorageManager = require("scripts.storage-manager")
local Viewpoint = require("scripts.viewpoint")
local AimAssist = require("scripts.combat.aim-assist")

local mod = {}

---@class fa.Combat.State
---@field combat_mode boolean Whether combat mode is active
---@field last_too_close_warning integer? Tick of last too-close warning to avoid spam

---@type table<integer, fa.Combat.State>
local combat_storage = StorageManager.declare_storage_module("combat", {
   combat_mode = false,
   last_too_close_warning = nil,
})

---Check if combat mode is active for a player
---@param pindex integer
---@return boolean
function mod.is_combat_mode(pindex)
   return combat_storage[pindex].combat_mode
end

---Enter combat mode for a player
---@param pindex integer
local function enter_combat_mode(pindex)
   local state = combat_storage[pindex]
   state.combat_mode = true
   state.last_too_close_warning = nil

   -- Close any open GUI
   local player = game.get_player(pindex)
   if player and player.valid then
      -- Close opened GUI
      if player.opened then player.opened = nil end
      -- Clear selected entity
      player.selected = nil
   end

   SoundModel.set_reference_point(pindex, SoundModel.ReferencePoint.CHARACTER)
   Speech.speak(pindex, { "fa.combat-mode-enabled" })
end

---Exit combat mode for a player
---@param pindex integer
local function exit_combat_mode(pindex)
   local state = combat_storage[pindex]
   state.combat_mode = false
   state.last_too_close_warning = nil

   -- Stop any ongoing shooting when exiting combat mode
   local player = game.get_player(pindex)
   if player and player.valid and player.character then
      player.shooting_state = {
         state = defines.shooting.not_shooting,
         position = player.position,
      }
   end

   SoundModel.set_reference_point(pindex, SoundModel.ReferencePoint.CURSOR)
   Speech.speak(pindex, { "fa.combat-mode-disabled" })
end

---Toggle combat mode for a player
---@param pindex integer
function mod.toggle_combat_mode(pindex)
   local state = combat_storage[pindex]
   if state.combat_mode then
      exit_combat_mode(pindex)
   else
      enter_combat_mode(pindex)
   end
end

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
         Speech.speak(pindex, { "fa.combat-fully-repaired-entity", Localising.get_localised_name_with_fallback(ent) })
      elseif health_diff < dura then
         ent.health = ent.max_health
         stack.drain_durability(health_diff)
         Speech.speak(pindex, { "fa.combat-fully-repaired-entity", Localising.get_localised_name_with_fallback(ent) })
      else --if health_diff >= dura then
         stack.drain_durability(dura)
         ent.health = ent.health + dura
         local msg = MessageBuilder.new()
         msg:fragment({ "fa.combat-partially-repaired" })
         msg:fragment(Localising.get_localised_name_with_fallback(ent))
         msg:fragment({ "fa.combat-consumed-repair-pack" })
         Speech.speak(pindex, msg:build())
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
      Speech.speak(pindex, { "fa.combat-need-repair-packs" })
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
            Speech.speak(pindex, {
               "fa.combat-repaired-stopped-low-packs",
               tostring(repaired_count),
               tostring(packs_used),
            })
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
                  Speech.speak(pindex, {
                     "fa.combat-repaired-stopped-low-packs",
                     tostring(repaired_count),
                     tostring(packs_used),
                  })
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
      Speech.speak(pindex, { "fa.combat-nothing-to-repair", radius })
      return
   end
   Speech.speak(pindex, {
      "fa.combat-repaired-all",
      tostring(repaired_count),
      tostring(radius),
      tostring(packs_used),
   })
end

---Get the throw range for a capsule or grenade.
---Returns 0 for anything but a throwable attack, otherwise returns the range from attack parameters.
---@param stack LuaItemStack
---@return number min_range
---@return number max_range
function mod.get_grenade_or_capsule_range(stack)
   if stack == nil or not stack.valid_for_read then return 0, 0 end

   local capsule_action = stack.prototype.capsule_action
   if not capsule_action then return 0, 0 end

   if capsule_action.type ~= "throw" then return 0, 0 end

   local attack_params = capsule_action.attack_parameters
   if not attack_params then return 0, 0 end

   return attack_params.min_range or 0, attack_params.range or 0
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

-- Minimum ticks between "too close" warnings
local TOO_CLOSE_WARNING_COOLDOWN = 120

---Process shooting for a player in combat mode
---Called every tick for players in combat mode who are firing
---@param pindex integer
function mod.tick_shooting(pindex)
   local state = combat_storage[pindex]
   if not state.combat_mode then return end

   local player = game.get_player(pindex)
   if not player or not player.valid then return end

   local character = player.character
   if not character then return end

   -- Check if player is currently firing
   local shooting_state = player.shooting_state
   if shooting_state.state == defines.shooting.not_shooting then return end

   -- Player is firing, redirect to best target
   local target, reason = AimAssist.get_best_target(pindex)

   if target and target.valid then
      -- Aim at the target
      player.shooting_state = {
         -- SHOOTING_ENEMIES USES POSITION AS A GUIDE, SHOOTING_SELECTED REQUIRES ACTUALLY SELECTING.
         state = defines.shooting.shooting_enemies,
         position = target.position,
      }
   else
      -- No valid target, stop shooting and warn player
      player.shooting_state = {
         state = defines.shooting.not_shooting,
         position = player.position,
      }

      -- Warn player about why they can't shoot
      local now = game.tick
      local last_warning = state.last_too_close_warning
      if not last_warning or (now - last_warning) >= TOO_CLOSE_WARNING_COOLDOWN then
         state.last_too_close_warning = now

         local R = AimAssist.NoTargetReason
         if reason == R.ALL_TOO_CLOSE_SAFE then
            Speech.speak(pindex, { "fa.aim-all-too-close-safe" })
         elseif reason == R.ALL_TOO_CLOSE then
            Speech.speak(pindex, { "fa.aim-all-too-close" })
         elseif reason == R.NO_WEAPON then
            Speech.speak(pindex, { "fa.aim-no-weapon" })
         elseif reason == R.NO_ENEMIES or reason == R.NO_ENEMIES_IN_RANGE then
            Speech.speak(pindex, { "fa.aim-no-enemies" })
         end
      end
   end
end

return mod
