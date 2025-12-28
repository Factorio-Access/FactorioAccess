--[[
Aim assist system for combat mode.

Handles automatic targeting of enemies based on player preferences:
- Preferred aiming direction (north, south, east, west)
- Spawner priority (spawners first vs all enemies)
- Health sorting (healthiest first vs weakest first)
- Safe mode (uses soft min range instead of hard min range)

The aim assist computes a sorted list of targets based on these preferences,
which is then used by the shooting tick handler to aim the player's weapon.
]]

local util = require("util")
local Consts = require("scripts.consts")
local FaUtils = require("scripts.fa-utils")
local PlayerWeapon = require("scripts.combat.player-weapon")
local Speech = require("scripts.speech")
local StorageManager = require("scripts.storage-manager")
local Zoom = require("scripts.zoom")

local mod = {}

-- Buffer distance added to soft min range in safe mode
local SOFT_MIN_EPSILON = 1.5

---Reasons why no target is available
---@enum fa.combat.NoTargetReason
mod.NoTargetReason = {
   --- No weapon equipped or weapon has no range
   NO_WEAPON = "no-weapon",
   --- No enemies found in the search area
   NO_ENEMIES = "no-enemies",
   --- Enemies exist but none are within weapon range
   NO_ENEMIES_IN_RANGE = "no-enemies-in-range",
   --- All enemies are too close (within hard min range)
   ALL_TOO_CLOSE = "all-too-close",
   --- All enemies are too close for safe mode (within soft min range)
   ALL_TOO_CLOSE_SAFE = "all-too-close-safe",
}

---@class fa.combat.AimAssist.State
---@field direction defines.direction Preferred aiming direction
---@field spawners_first boolean Whether to prioritize spawners
---@field healthiest_first boolean Whether to target healthiest enemies first (vs closest)
---@field safe_mode boolean Whether to use soft min range (safe mode)

---@return fa.combat.AimAssist.State
local function make_default_state()
   return {
      direction = defines.direction.north,
      spawners_first = true,
      healthiest_first = false,
      safe_mode = true,
   }
end

---@type table<integer, fa.combat.AimAssist.State>
local aim_storage = StorageManager.declare_storage_module("aim_assist", make_default_state)

---Get the aim assist state for a player
---@param pindex integer
---@return fa.combat.AimAssist.State
function mod.get_state(pindex)
   return aim_storage[pindex]
end

---Set the aiming direction
---@param pindex integer
---@param direction defines.direction
function mod.set_direction(pindex, direction)
   aim_storage[pindex].direction = direction
   Speech.speak(pindex, { "fa.aim-direction-set", { "fa.direction", direction } })
end

---Toggle spawners first preference
---@param pindex integer
function mod.toggle_spawners_first(pindex)
   local state = aim_storage[pindex]
   state.spawners_first = not state.spawners_first

   if state.spawners_first then
      Speech.speak(pindex, { "fa.aim-spawners-first-on" })
   else
      Speech.speak(pindex, { "fa.aim-spawners-first-off" })
   end
end

---Toggle healthiest first preference (vs closest)
---@param pindex integer
function mod.toggle_healthiest_first(pindex)
   local state = aim_storage[pindex]
   state.healthiest_first = not state.healthiest_first

   if state.healthiest_first then
      Speech.speak(pindex, { "fa.aim-strongest-first" })
   else
      Speech.speak(pindex, { "fa.aim-closest-first" })
   end
end

---Toggle safe mode
---@param pindex integer
function mod.toggle_safe_mode(pindex)
   local state = aim_storage[pindex]
   state.safe_mode = not state.safe_mode

   if state.safe_mode then
      Speech.speak(pindex, { "fa.aim-safe-mode-on" })
   else
      Speech.speak(pindex, { "fa.aim-safe-mode-off" })
   end
end

---Check if an entity is a spawner type
---@param entity LuaEntity
---@return boolean
local function is_spawner(entity)
   return entity.type == "unit-spawner"
end

---Compute the dot product of enemy position relative to player with the aim direction
---@param enemy_pos MapPosition
---@param player_pos MapPosition
---@param direction defines.direction
---@return number dot_product Higher values mean more aligned with aim direction
local function compute_direction_score(enemy_pos, player_pos, direction)
   local vec = Consts.DIRECTION_VECTORS[direction]
   local dx = enemy_pos.x - player_pos.x
   local dy = enemy_pos.y - player_pos.y

   -- Normalize the direction vector
   local dist = math.sqrt(dx * dx + dy * dy)
   if dist < 0.001 then return 0 end

   local nx = dx / dist
   local ny = dy / dist

   -- Dot product with aim direction
   return nx * vec.x + ny * vec.y
end

---@class fa.combat.Target
---@field entity LuaEntity
---@field distance number
---@field direction_score number
---@field in_preferred_direction boolean Whether dot product >= preferred_direction_amount
---@field is_spawner boolean
---@field health number Current health

---@class fa.combat.AimAssist.Options
---@field preferred_direction_amount number? Minimum dot product to consider "in preferred direction" (default 0)
---@field allow_preferred_direction_only boolean? If true, only return targets in the preferred direction (default false)
---@field direction defines.direction? Override the aim direction (default uses player's stored aim direction)

---Find and sort all valid targets for the player
---@param pindex integer
---@param options fa.combat.AimAssist.Options?
---@return fa.combat.Target[]? targets Sorted list of targets or nil if none
---@return string? no_target_reason Reason if no targets available
function mod.get_sorted_targets(pindex, options)
   options = options or {}
   local preferred_direction_amount = options.preferred_direction_amount or 0
   local allow_preferred_direction_only = options.allow_preferred_direction_only or false

   local player = game.get_player(pindex)
   if not player or not player.valid then return nil, nil end

   local character = player.character
   if not character then return nil, nil end

   local state = aim_storage[pindex]
   local aim_direction = options.direction or state.direction
   local player_pos = character.position
   local surface = player.surface

   -- Get weapon ranges
   local hard_min = PlayerWeapon.get_hard_min_range(pindex) or 0
   local soft_min = PlayerWeapon.get_soft_min_range(pindex)
   local max_range = PlayerWeapon.get_max_range(pindex)

   if not max_range then return nil, mod.NoTargetReason.NO_WEAPON end

   -- Determine effective min range based on safe mode
   local effective_min = hard_min
   if state.safe_mode and soft_min then effective_min = math.max(hard_min, soft_min + SOFT_MIN_EPSILON) end

   -- Get zoom area for finding spawners/turrets
   local area = Zoom.get_search_area(pindex)

   -- Find all enemy units in the area
   local enemies = surface.find_enemy_units(player_pos, max_range, player.force)

   -- Also find spawners and worms
   local spawners = surface.find_entities_filtered({
      area = { { area.left, area.top }, { area.right, area.bottom } },
      type = "unit-spawner",
      force = "enemy",
   })

   local turrets = surface.find_entities_filtered({
      area = { { area.left, area.top }, { area.right, area.bottom } },
      type = "turret",
      force = "enemy",
   })

   -- Combine all enemies
   local all_enemies = {}
   for _, e in ipairs(enemies) do
      all_enemies[#all_enemies + 1] = e
   end
   for _, e in ipairs(spawners) do
      all_enemies[#all_enemies + 1] = e
   end
   for _, e in ipairs(turrets) do
      all_enemies[#all_enemies + 1] = e
   end

   if #all_enemies == 0 then return nil, mod.NoTargetReason.NO_ENEMIES end

   -- Filter and score targets
   ---@type fa.combat.Target[]
   local targets = {}
   local too_close_hard_count = 0 -- Within hard min range (weapon can't fire)
   local too_close_safe_count = 0 -- Within safe mode buffer (would hurt self)

   for _, enemy in ipairs(all_enemies) do
      if enemy.valid then
         local enemy_pos = enemy.position
         local dist = util.distance(player_pos, enemy_pos)

         -- Check range constraints
         if dist >= effective_min and dist <= max_range then
            local dir_score = compute_direction_score(enemy_pos, player_pos, aim_direction)
            local in_preferred = dir_score >= preferred_direction_amount

            -- Skip targets not in preferred direction if allow_preferred_direction_only is set
            if not allow_preferred_direction_only or in_preferred then
               table.insert(targets, {
                  entity = enemy,
                  distance = dist,
                  direction_score = dir_score,
                  in_preferred_direction = in_preferred,
                  is_spawner = is_spawner(enemy),
                  health = enemy.max_health or 0,
               })
            end
         elseif dist < hard_min then
            too_close_hard_count = too_close_hard_count + 1
         elseif dist < effective_min then
            too_close_safe_count = too_close_safe_count + 1
         end
      end
   end

   if #targets == 0 then
      if too_close_safe_count > 0 then
         return nil, mod.NoTargetReason.ALL_TOO_CLOSE_SAFE
      elseif too_close_hard_count > 0 then
         return nil, mod.NoTargetReason.ALL_TOO_CLOSE
      else
         return nil, mod.NoTargetReason.NO_ENEMIES_IN_RANGE
      end
   end

   -- Sort targets based on preferences
   -- Priority: spawners (if enabled) > preferred direction > healthiest/closest
   table.sort(targets, function(a, b)
      -- First: spawners first if enabled
      if state.spawners_first then
         if a.is_spawner and not b.is_spawner then return true end
         if b.is_spawner and not a.is_spawner then return false end
      end

      -- Second: prefer targets in the aimed direction
      if a.in_preferred_direction and not b.in_preferred_direction then return true end
      if b.in_preferred_direction and not a.in_preferred_direction then return false end

      -- Third: healthiest first or closest first
      if state.healthiest_first then
         return a.health > b.health
      else
         return a.distance < b.distance
      end
   end)

   return targets, nil
end

---Get the best target for the player to shoot at
---@param pindex integer
---@param options fa.combat.AimAssist.Options?
---@return LuaEntity? target The best target entity
---@return string? no_target_reason Reason if no target available
function mod.get_best_target(pindex, options)
   local targets, reason = mod.get_sorted_targets(pindex, options)
   if not targets or #targets == 0 then return nil, reason end
   return targets[1].entity, nil
end

return mod
