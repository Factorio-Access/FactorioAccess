--[[
Capsule usage system for combat mode.

Handles throwing grenades, deploying combat robots, and using other capsules
with aim assist integration. Supports:
- Using healing/self-targeted capsules on the player
- Throwing combat capsules with aim assist (grenades, poison capsules)
- Deploying combat robots in a direction
- Force-fire mode to bypass safe mode restrictions
]]

local AimAssist = require("scripts.combat.aim-assist")
local CombatData = require("scripts.combat.combat-data")
local Consts = require("scripts.consts")
local Speech = require("scripts.speech")
local Viewpoint = require("scripts.viewpoint")

local mod = {}

-- Minimum dot product for "in direction" (cos of 80 degrees = ~0.17)
-- 160 degree cone = 80 degrees each side
local CAPSULE_DIRECTION_THRESHOLD = 0.17

-- Buffer distance for soft min range in safe mode
local SOFT_MIN_EPSILON = 1.5

-- Default max range if capsule data doesn't specify one
local DEFAULT_MAX_RANGE = 15

---@enum fa.combat.CapsuleCategory
mod.CapsuleCategory = {
   SELF = "self", -- Used on the player (healing items)
   AREA_DAMAGE = "area-damage", -- Deals area damage (grenades, poison)
   SPAWNER = "spawner", -- Spawns entities (combat robots)
   REMOTE = "remote", -- Remote control items (artillery, equipment)
   CLIFF = "cliff", -- Cliff explosives
   OTHER = "other", -- Unknown/other
}

---@class fa.combat.HeldCapsuleInfo
---@field name string Capsule item name
---@field category fa.combat.CapsuleCategory
---@field data fa.CapsuleData

---Categorize a capsule by its behavior
---@param data fa.CapsuleData
---@return fa.combat.CapsuleCategory
local function categorize_capsule(data)
   local action_type = data.action_type

   if action_type == "use-on-self" then
      return mod.CapsuleCategory.SELF
   elseif action_type == "equipment-remote" or action_type == "artillery-remote" then
      return mod.CapsuleCategory.REMOTE
   elseif action_type == "destroy-cliffs" then
      return mod.CapsuleCategory.CLIFF
   elseif action_type == "throw" then
      if data.has_area_damage and data.can_damage_self then
         return mod.CapsuleCategory.AREA_DAMAGE
      elseif data.spawns_entity then
         return mod.CapsuleCategory.SPAWNER
      else
         -- Throwable without self-damage or spawned entity (e.g. poison capsule)
         return mod.CapsuleCategory.AREA_DAMAGE
      end
   end

   return mod.CapsuleCategory.OTHER
end

---Get info about the capsule the player is holding
---@param pindex integer
---@return fa.combat.HeldCapsuleInfo?
function mod.get_held_capsule_data(pindex)
   local player = game.get_player(pindex)
   if not player then return nil end

   local cursor = player.cursor_stack
   if not cursor or not cursor.valid_for_read then return nil end

   local proto = prototypes.item[cursor.name]
   if not proto or proto.type ~= "capsule" then return nil end

   local data = CombatData.get_capsule_data(cursor.name)
   if not data then return nil end

   return {
      name = cursor.name,
      category = categorize_capsule(data),
      data = data,
   }
end

---Compute the effective max range, ensuring it's at least past the soft min danger zone
---@param data fa.CapsuleData
---@return number
local function get_effective_max_range(data)
   local max_range = data.max_range or DEFAULT_MAX_RANGE
   local soft_min = data.soft_min_range or 0
   return math.max(max_range, soft_min + SOFT_MIN_EPSILON)
end

---Compute target position for a capsule thrown in a direction
---@param player LuaPlayer
---@param direction defines.direction
---@param max_range number
---@return MapPosition
local function compute_max_range_position(player, direction, max_range)
   local pos = player.position
   local vec = Consts.DIRECTION_VECTORS[direction]
   return {
      x = pos.x + vec.x * max_range,
      y = pos.y + vec.y * max_range,
   }
end

---Find enemies in a direction for capsule targeting
---@param pindex integer
---@param direction defines.direction
---@param max_range number
---@param min_range number
---@return fa.combat.Target[]?
local function find_capsule_targets(pindex, direction, max_range, min_range)
   local targets = AimAssist.get_sorted_targets(pindex, {
      preferred_direction_amount = CAPSULE_DIRECTION_THRESHOLD,
      allow_preferred_direction_only = true,
      direction = direction,
   })

   if not targets or #targets == 0 then return nil end

   -- Filter by capsule range constraints
   local filtered = {}
   for _, target in ipairs(targets) do
      if target.distance >= min_range and target.distance <= max_range then table.insert(filtered, target) end
   end

   if #filtered == 0 then return nil end
   return filtered
end

---@class fa.combat.CapsuleUseResult
---@field success boolean Whether the capsule was used
---@field message LocalisedString? Message to speak to the player

---Use a capsule on the player position
---@param pindex integer
---@return boolean success
function mod.use_on_player(pindex)
   local player = game.get_player(pindex)
   if not player then return false end
   if not mod.get_held_capsule_data(pindex) then return false end

   player.use_from_cursor(player.position)
   return true
end

---Use a combat capsule (grenade, poison) in a direction with aim assist
---@param pindex integer
---@param direction defines.direction
---@param info fa.combat.HeldCapsuleInfo
---@param force_fire boolean Bypass safe mode
---@return fa.combat.CapsuleUseResult
local function use_area_capsule(pindex, direction, info, force_fire)
   local player = game.get_player(pindex)
   if not player then return { success = false } end

   local data = info.data
   local max_range = get_effective_max_range(data)
   local min_range = data.min_range or 0
   local soft_min = data.soft_min_range

   local aim_state = AimAssist.get_state(pindex)
   local effective_min = min_range
   if aim_state.safe_mode and soft_min then effective_min = math.max(min_range, soft_min + SOFT_MIN_EPSILON) end

   local targets = find_capsule_targets(pindex, direction, max_range, effective_min)

   if targets and #targets > 0 then
      local target = targets[1]
      if aim_state.safe_mode and soft_min and target.distance < soft_min + SOFT_MIN_EPSILON then
         return {
            success = false,
            message = { "fa.capsule-too-close-safe" },
         }
      end
      player.use_from_cursor(target.entity.position)
      return { success = true }
   elseif force_fire then
      -- No targets but force fire enabled, throw at max range
      local target_pos = compute_max_range_position(player, direction, max_range)
      player.use_from_cursor(target_pos)
      return { success = true, message = { "fa.capsule-no-targets" } }
   else
      -- No targets, block firing
      return { success = false, message = { "fa.capsule-no-targets" } }
   end
end

---Use a spawner capsule (combat robots) in a direction
---@param pindex integer
---@param direction defines.direction
---@param info fa.combat.HeldCapsuleInfo
---@return fa.combat.CapsuleUseResult
local function use_spawner_capsule(pindex, direction, info)
   local player = game.get_player(pindex)
   if not player then return { success = false } end

   local max_range = get_effective_max_range(info.data)
   local target_pos = compute_max_range_position(player, direction, max_range)
   player.use_from_cursor(target_pos)
   return { success = true }
end

---Use the held capsule in a direction
---@param pindex integer
---@param direction defines.direction
---@param force_fire boolean Bypass safe mode restrictions
---@return boolean handled
function mod.use_capsule_in_direction(pindex, direction, force_fire)
   local info = mod.get_held_capsule_data(pindex)
   if not info then return false end

   local category = info.category

   -- Non-combat capsules always use on player
   if category == mod.CapsuleCategory.SELF or category == mod.CapsuleCategory.REMOTE then
      return mod.use_on_player(pindex)
   end

   -- Cliff explosives use at cursor position
   if category == mod.CapsuleCategory.CLIFF then
      local player = game.get_player(pindex)
      if player then
         local vp = Viewpoint.get_viewpoint(pindex)
         player.use_from_cursor(vp:get_cursor_pos())
      end
      return true
   end

   local result
   if category == mod.CapsuleCategory.AREA_DAMAGE then
      result = use_area_capsule(pindex, direction, info, force_fire)
   elseif category == mod.CapsuleCategory.SPAWNER then
      result = use_spawner_capsule(pindex, direction, info)
   else
      -- Unknown type, throw at max range
      local player = game.get_player(pindex)
      if player then
         local max_range = get_effective_max_range(info.data)
         local target_pos = compute_max_range_position(player, direction, max_range)
         player.use_from_cursor(target_pos)
      end
      return true
   end

   if result.message then Speech.speak(pindex, result.message) end
   return true
end

---Use the held capsule without a direction (left bracket in combat mode)
---@param pindex integer
---@return boolean handled
function mod.use_capsule_undirected(pindex)
   return mod.use_on_player(pindex)
end

return mod
