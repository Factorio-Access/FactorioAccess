--Here: functions relating to combat, repair packs
--Does not include event handlers, guns and equipment maanagement

local util = require("util")
local EntitySelection = require("scripts.entity-selection")
local Equipment = require("scripts.equipment")
local FaUtils = require("scripts.fa-utils")
local HealthBar = require("scripts.sonifiers.health-bar")
local Localising = require("scripts.localising")
local PlayerWeapon = require("scripts.combat.player-weapon")
local SoundModel = require("scripts.sound-model")
local Speech = require("scripts.speech")
local MessageBuilder = Speech.MessageBuilder
local StorageManager = require("scripts.storage-manager")
local Viewpoint = require("scripts.viewpoint")
local AimAssist = require("scripts.combat.aim-assist")

local mod = {}

---@class fa.Combat.State
---@field combat_mode boolean Whether combat mode is active
---@field last_warning_tick table<string, integer> Map of warning key to last tick it was spoken
---@field last_gun_index integer? The last selected gun index for change detection

---@type table<integer, fa.Combat.State>
local combat_storage = StorageManager.declare_storage_module("combat", {
   combat_mode = false,
   last_warning_tick = {},
   last_gun_index = nil,
}, {
   ephemeral_state_version = 3,
})

---Check if combat mode is active for a player
---@param pindex integer
---@return boolean
function mod.is_combat_mode(pindex)
   return combat_storage[pindex].combat_mode
end

---@class fa.Combat.HealthShields
---@field health number Health ratio (0 to 1)
---@field shields number? Shield ratio (0 to 1), nil if no shields

---Get the effective health and shields for a player (character or vehicle)
---@param pindex integer
---@return fa.Combat.HealthShields? result nil if no valid entity
function mod.get_effective_health_shields(pindex)
   local player = game.get_player(pindex)
   if not player or not player.valid then return nil end

   -- If in a vehicle, use vehicle stats
   if player.driving and player.vehicle and player.vehicle.valid then
      local vehicle = player.vehicle
      local health = vehicle.get_health_ratio()
      local shields = nil

      local grid = vehicle.grid
      if grid and grid.valid and grid.max_shield > 0 then shields = grid.shield / grid.max_shield end

      return { health = health, shields = shields }
   end

   -- Otherwise use character stats
   local char = player.character
   if not char or not char.valid then return nil end

   local health = char.get_health_ratio()
   local shields = nil

   local armor_inv = player.get_inventory(defines.inventory.character_armor)
   if
      armor_inv[1]
      and armor_inv[1].valid_for_read
      and armor_inv[1].valid
      and armor_inv[1].grid
      and armor_inv[1].grid.valid
   then
      local grid = armor_inv[1].grid
      if grid.max_shield > 0 then shields = grid.shield / grid.max_shield end
   end

   return { health = health, shields = shields }
end

---Notify a player of their current health/shields via sonification and optionally build speech
---@param pindex integer
---@param mb fa.MessageBuilder? If provided, append health/shield info to it instead of just playing sound
---@return fa.Combat.HealthShields? result nil if no valid entity
function mod.notify_health_shields(pindex, mb)
   local player = game.get_player(pindex)
   if not player or not player.valid then return nil end

   local stats = mod.get_effective_health_shields(pindex)
   if not stats then return nil end

   -- Always play the health bar sound
   HealthBar.play_status(pindex, stats.health, stats.shields)

   -- If a MessageBuilder was provided, append the status to it
   if mb then
      local health_pct = math.floor(stats.health * 100 + 0.5)

      if player.driving and player.vehicle and player.vehicle.valid then
         -- Vehicle health status
         local vehicle = player.vehicle
         mb:fragment(Localising.get_localised_name_with_fallback(vehicle))
         mb:fragment({ "fa.vehicle-health-percent", health_pct })
         if stats.shields then
            local shield_pct = math.floor(stats.shields * 100 + 0.5)
            mb:fragment({ "fa.vehicle-shield-percent", shield_pct })
         end
         -- Add equipment bonuses if vehicle has a grid
         local grid = vehicle.grid
         if grid and grid.valid and grid.count() > 0 then Equipment.add_equipment_bonuses_to_message(mb, grid) end
      else
         -- Character health status
         mb:fragment({ "fa.character-health-percent", health_pct })
         if stats.shields then
            local shield_pct = math.floor(stats.shields * 100 + 0.5)
            mb:fragment({ "fa.character-shield-percent", shield_pct })
         end
      end
   end

   return stats
end

---Enter combat mode for a player
---@param pindex integer
local function enter_combat_mode(pindex)
   local state = combat_storage[pindex]
   state.combat_mode = true
   state.last_warning_tick = {}

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
   state.last_warning_tick = {}

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

-- Minimum ticks between warnings
local WARNING_COOLDOWN = 120

-- Buffer distance added to soft min range in safe mode (same as in aim-assist)
local SOFT_MIN_EPSILON = 1.5

---Speak a warning with rate limiting
---@param pindex integer
---@param key string Unique identifier for this warning type
---@param message LocalisedString
local function warn_with_cooldown(pindex, key, message)
   local state = combat_storage[pindex]
   local now = game.tick
   local last = state.last_warning_tick[key]
   if not last or (now - last) >= WARNING_COOLDOWN then
      state.last_warning_tick[key] = now
      Speech.speak(pindex, message)
   end
end

---Stop shooting and return the player to not_shooting state
---@param player LuaPlayer
local function stop_shooting(player)
   player.shooting_state = {
      state = defines.shooting.not_shooting,
      position = player.position,
   }
end

---Shoot enemies at a position (fallback when no specific entity selected)
---@param player LuaPlayer
---@param position MapPosition
local function shoot_at_position(player, position)
   player.shooting_state = {
      state = defines.shooting.shooting_enemies,
      position = position,
   }
end

---Shoot at a specific selected entity (avoids friendly fire)
---@param player LuaPlayer
---@param target LuaEntity
local function shoot_at_selected(player, target)
   player.selected = target
   player.shooting_state = {
      state = defines.shooting.shooting_selected,
      position = target.position,
   }
end

---Handle shooting in combat mode (aim assist)
---@param pindex integer
---@param player LuaPlayer
local function tick_combat_mode(pindex, player)
   local shooting_state = player.shooting_state
   if shooting_state.state == defines.shooting.not_shooting then return end

   -- Reject shooting_selected in combat mode - player isn't controlling selection
   if shooting_state.state == defines.shooting.shooting_selected then
      stop_shooting(player)
      warn_with_cooldown(pindex, "shooting-selected", { "fa.shooting-selected-not-in-combat-mode" })
      return
   end

   -- Intercept shooting_enemies and redirect to best target via aim assist
   local target, reason = AimAssist.get_best_target(pindex)

   if target and target.valid then
      -- Use shooting_selected to avoid friendly fire
      shoot_at_selected(player, target)
   else
      stop_shooting(player)
      player.selected = nil

      -- Warn about why there's no target
      local R = AimAssist.NoTargetReason
      if reason == R.ALL_TOO_CLOSE_SAFE then
         warn_with_cooldown(pindex, "too-close-safe", { "fa.aim-all-too-close-safe" })
      elseif reason == R.ALL_TOO_CLOSE then
         warn_with_cooldown(pindex, "too-close", { "fa.aim-all-too-close" })
      elseif reason == R.NO_WEAPON then
         warn_with_cooldown(pindex, "no-weapon", { "fa.aim-no-weapon" })
      elseif reason == R.NO_ENEMIES or reason == R.NO_ENEMIES_IN_RANGE then
         warn_with_cooldown(pindex, "no-enemies", { "fa.aim-no-enemies" })
      end
   end
end

---Handle shooting_selected outside combat mode
---@param pindex integer
---@param player LuaPlayer
---@param character LuaEntity
local function tick_non_combat_mode(pindex, player, character)
   local shooting_state = player.shooting_state
   if shooting_state.state ~= defines.shooting.shooting_selected then return end

   local vp = Viewpoint.get_viewpoint(pindex)
   local cursor_pos = vp:get_cursor_pos()

   -- Check safe mode constraints against cursor position first
   local aim_state = AimAssist.get_state(pindex)
   if aim_state.safe_mode then
      local soft_min = PlayerWeapon.get_soft_min_range(pindex)
      if soft_min and soft_min > 0 then
         local hard_min = PlayerWeapon.get_hard_min_range(pindex) or 0
         local effective_min = math.max(hard_min, soft_min + SOFT_MIN_EPSILON)
         local dist = util.distance(character.position, cursor_pos)

         if dist < effective_min then
            stop_shooting(player)
            warn_with_cooldown(pindex, "cursor-too-close-safe", { "fa.cursor-too-close-safe" })
            return
         end
      end
   end

   -- Try to find and select an entity at cursor
   player.selected = nil
   local target = EntitySelection.get_first_ent_at_tile(pindex)
   if target then player.selected = target end

   -- If no entity or not selectable, shoot at cursor position
   if not player.selected then shoot_at_position(player, cursor_pos) end
end

---Check for gun index changes and announce
---@param pindex integer
---@param character LuaEntity
local function tick_gun_change(pindex, character)
   local state = combat_storage[pindex]
   local current_gun_index = character.selected_gun_index
   if state.last_gun_index == nil then state.last_gun_index = current_gun_index end
   if current_gun_index == state.last_gun_index then return end

   state.last_gun_index = current_gun_index
   if not current_gun_index then return end

   local gun_inv = character.get_inventory(defines.inventory.character_guns)
   local gun_stack = gun_inv[current_gun_index]
   if not gun_stack.valid_for_read then return end

   Speech.speak(pindex, Localising.get_localised_name_with_fallback(gun_stack))
end

---Process shooting for a player each tick
---@param pindex integer
function mod.on_tick(pindex)
   local player = game.get_player(pindex)
   if not player or not player.valid then return end

   local character = player.character
   if not character then return end

   tick_gun_change(pindex, character)

   if combat_storage[pindex].combat_mode then
      tick_combat_mode(pindex, player)
   else
      tick_non_combat_mode(pindex, player, character)
   end
end

return mod
