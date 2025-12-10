--[[
Weapon and ammo utilities for determining weapon properties at runtime.

Provides functions to query weapon range, aiming type, and danger zones
for the player's currently equipped weapons and ammo.
]]

local WeaponAmmoData = require("scripts.combat.weapon-ammo-data")

local mod = {}

-- Re-export the AimingType enum for convenience
mod.AimingType = WeaponAmmoData.AimingType

---Get the player's character entity, handling vehicles
---@param pindex integer
---@return LuaEntity? character
local function get_character(pindex)
   local player = game.get_player(pindex)
   if not player then return nil end
   return player.character
end

---Get the currently selected gun prototype name for a player
---@param pindex integer
---@return string? gun_name
---@return LuaItemPrototype? gun_proto
function mod.get_selected_gun(pindex)
   local character = get_character(pindex)
   if not character then return nil, nil end

   local gun_inv = character.get_inventory(defines.inventory.character_guns)
   if not gun_inv then return nil, nil end

   local selected_idx = character.selected_gun_index
   if not selected_idx then return nil, nil end

   local gun_stack = gun_inv[selected_idx]
   if not gun_stack or not gun_stack.valid_for_read then return nil, nil end

   return gun_stack.name, prototypes.item[gun_stack.name]
end

---Get the ammo currently loaded for the selected gun
---@param pindex integer
---@return string? ammo_name
---@return LuaItemPrototype? ammo_proto
function mod.get_selected_ammo(pindex)
   local character = get_character(pindex)
   if not character then return nil, nil end

   local ammo_inv = character.get_inventory(defines.inventory.character_ammo)
   if not ammo_inv then return nil, nil end

   local selected_idx = character.selected_gun_index
   if not selected_idx then return nil, nil end

   local ammo_stack = ammo_inv[selected_idx]
   if not ammo_stack or not ammo_stack.valid_for_read then return nil, nil end

   return ammo_stack.name, prototypes.item[ammo_stack.name]
end

---Check if the player is holding a weapon-like capsule in their cursor
---@param pindex integer
---@return boolean is_capsule
---@return string? capsule_name
function mod.is_holding_weapon_capsule(pindex)
   local player = game.get_player(pindex)
   if not player then return false, nil end

   local cursor = player.cursor_stack
   if not cursor or not cursor.valid_for_read then return false, nil end

   local proto = prototypes.item[cursor.name]
   if not proto then return false, nil end

   -- Check if it's a capsule type item
   if proto.type ~= "capsule" then return false, nil end

   -- Get capsule data to check if it's weapon-like
   local capsule_data = WeaponAmmoData.get_capsule_data(cursor.name)
   if not capsule_data then return false, nil end

   -- Consider it weapon-like if it can deal damage or spawns combat entities
   local is_weapon_like = capsule_data.can_damage_self
      or capsule_data.has_area_damage
      or capsule_data.spawns_entity ~= nil
      or capsule_data.action_type == "throw"

   return is_weapon_like, cursor.name
end

---Get the hard minimum range for the currently selected gun+ammo combo
---This is the range at which the weapon won't fire at all
---@param pindex integer
---@return number? min_range nil if no weapon equipped or no minimum
function mod.get_hard_min_range(pindex)
   local gun_name = mod.get_selected_gun(pindex)
   local ammo_name = mod.get_selected_ammo(pindex)

   if not gun_name then return nil end

   local gun_data = WeaponAmmoData.get_gun_data(gun_name)
   local ammo_data = ammo_name and WeaponAmmoData.get_ammo_data(ammo_name)

   -- Hard min range comes from gun's attack_parameters.min_range
   -- or from ammo's min_range
   local gun_min = gun_data and gun_data.min_range
   local ammo_min = ammo_data and ammo_data.min_range

   -- Return the larger of the two if both exist
   if gun_min and ammo_min then
      return math.max(gun_min, ammo_min)
   elseif gun_min then
      return gun_min
   else
      return ammo_min
   end
end

---Get the hard minimum range from a gun prototype name
---@param gun_name string
---@return number? min_range
function mod.get_hard_min_range_from_prototype(gun_name)
   local gun_data = WeaponAmmoData.get_gun_data(gun_name)
   return gun_data and gun_data.min_range
end

---Get the soft minimum range for the currently selected gun+ammo combo
---This is the range at which firing would damage the player
---@param pindex integer
---@return number? soft_min_range nil if no weapon equipped or no area damage
function mod.get_soft_min_range(pindex)
   local ammo_name = mod.get_selected_ammo(pindex)
   if not ammo_name then return nil end

   local ammo_data = WeaponAmmoData.get_ammo_data(ammo_name)
   if not ammo_data then return nil end

   return ammo_data.soft_min_range
end

---Get the soft minimum range from an ammo prototype name
---@param ammo_name string
---@return number? soft_min_range
function mod.get_soft_min_range_from_prototype(ammo_name)
   local ammo_data = WeaponAmmoData.get_ammo_data(ammo_name)
   return ammo_data and ammo_data.soft_min_range
end

---Get the soft minimum range from a capsule prototype name
---@param capsule_name string
---@return number? soft_min_range
function mod.get_soft_min_range_from_capsule(capsule_name)
   local capsule_data = WeaponAmmoData.get_capsule_data(capsule_name)
   return capsule_data and capsule_data.soft_min_range
end

---Get the maximum range for the currently selected gun+ammo combo
---@param pindex integer
---@return number? max_range nil if no weapon equipped
function mod.get_max_range(pindex)
   local gun_name = mod.get_selected_gun(pindex)
   local ammo_name = mod.get_selected_ammo(pindex)

   if not gun_name then return nil end

   local gun_data = WeaponAmmoData.get_gun_data(gun_name)
   if not gun_data then return nil end

   local base_range = gun_data.max_range

   -- Apply ammo range modifier if present
   if ammo_name then
      local ammo_data = WeaponAmmoData.get_ammo_data(ammo_name)
      if ammo_data and ammo_data.range_modifier then base_range = base_range * ammo_data.range_modifier end
   end

   return base_range
end

---Get the maximum range from a gun prototype name
---@param gun_name string
---@return number? max_range
function mod.get_max_range_from_prototype(gun_name)
   local gun_data = WeaponAmmoData.get_gun_data(gun_name)
   return gun_data and gun_data.max_range
end

---Get the maximum range from a capsule prototype name
---@param capsule_name string
---@return number? max_range
function mod.get_max_range_from_capsule(capsule_name)
   local capsule_data = WeaponAmmoData.get_capsule_data(capsule_name)
   return capsule_data and capsule_data.max_range
end

---Get the aiming type for the currently selected gun+ammo combo
---@param pindex integer
---@return fa.AimingType? aiming_type nil if no weapon equipped
function mod.get_aiming_type(pindex)
   local ammo_name = mod.get_selected_ammo(pindex)
   if not ammo_name then return nil end

   local ammo_data = WeaponAmmoData.get_ammo_data(ammo_name)
   if not ammo_data then return nil end

   return ammo_data.target_type
end

---Get the aiming type from an ammo prototype name
---@param ammo_name string
---@return fa.AimingType? aiming_type
function mod.get_aiming_type_from_prototype(ammo_name)
   local ammo_data = WeaponAmmoData.get_ammo_data(ammo_name)
   return ammo_data and ammo_data.target_type
end

---Check if the current weapon+ammo combo auto-aims at entities
---@param pindex integer
---@return boolean auto_aims
function mod.does_auto_aim(pindex)
   local aiming_type = mod.get_aiming_type(pindex)
   return aiming_type == "entity"
end

---Check if the current weapon+ammo combo can damage the player themselves
---@param pindex integer
---@return boolean can_damage
function mod.can_damage_self(pindex)
   local ammo_name = mod.get_selected_ammo(pindex)
   if not ammo_name then return false end

   local ammo_data = WeaponAmmoData.get_ammo_data(ammo_name)
   if not ammo_data then return false end

   return ammo_data.can_damage_self or false
end

---Check if the specified ammo can damage the player themselves
---@param ammo_name string
---@return boolean can_damage
function mod.can_damage_self_from_prototype(ammo_name)
   local ammo_data = WeaponAmmoData.get_ammo_data(ammo_name)
   return ammo_data and ammo_data.can_damage_self or false
end

---Check if the specified capsule can damage the player themselves
---@param capsule_name string
---@return boolean can_damage
function mod.can_damage_self_from_capsule(capsule_name)
   local capsule_data = WeaponAmmoData.get_capsule_data(capsule_name)
   return capsule_data and capsule_data.can_damage_self or false
end

---Get area damage radius for the current weapon+ammo combo
---@param pindex integer
---@return number? radius nil if no area damage
function mod.get_area_damage_radius(pindex)
   local ammo_name = mod.get_selected_ammo(pindex)
   if not ammo_name then return nil end

   local ammo_data = WeaponAmmoData.get_ammo_data(ammo_name)
   if not ammo_data or not ammo_data.has_area_damage then return nil end

   return ammo_data.area_radius
end

---Get area damage radius from an ammo prototype name
---@param ammo_name string
---@return number? radius
function mod.get_area_damage_radius_from_prototype(ammo_name)
   local ammo_data = WeaponAmmoData.get_ammo_data(ammo_name)
   return ammo_data and ammo_data.has_area_damage and ammo_data.area_radius or nil
end

---Get area damage radius from a capsule prototype name
---@param capsule_name string
---@return number? radius
function mod.get_area_damage_radius_from_capsule(capsule_name)
   local capsule_data = WeaponAmmoData.get_capsule_data(capsule_name)
   return capsule_data and capsule_data.has_area_damage and capsule_data.area_radius or nil
end

---Get capsule action type
---@param capsule_name string
---@return string? action_type "throw", "use-on-self", etc.
function mod.get_capsule_action_type(capsule_name)
   local capsule_data = WeaponAmmoData.get_capsule_data(capsule_name)
   return capsule_data and capsule_data.action_type
end

---Check if a capsule heals the player
---@param capsule_name string
---@return boolean heals
function mod.capsule_heals_player(capsule_name)
   local capsule_data = WeaponAmmoData.get_capsule_data(capsule_name)
   return capsule_data and capsule_data.heals_player or false
end

---Get what entity a capsule spawns (combat robots, etc.)
---@param capsule_name string
---@return string? entity_name
function mod.get_capsule_spawned_entity(capsule_name)
   local capsule_data = WeaponAmmoData.get_capsule_data(capsule_name)
   return capsule_data and capsule_data.spawns_entity
end

return mod
