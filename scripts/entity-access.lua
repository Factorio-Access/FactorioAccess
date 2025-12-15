--[[
Entity access control for remote viewing and interaction

Implements vanilla-style access rules:
- Can open and READ anything that is charted (for remote entities)
- Can only WRITE (modify inventory, etc.) when within reach distance
- Player's own character always has full access
- Vehicles, spidertrons, and trains bypass the charting requirement
]]

local mod = {}

---@alias fa.EntityAccess.WriteCheckResult { allowed: boolean, reason: LocalisedString? }

---Entity types that bypass the charting requirement (always accessible if owned)
local CHARTING_BYPASS_TYPES = {
   ["car"] = true,
   ["spider-vehicle"] = true,
   ["locomotive"] = true,
   ["cargo-wagon"] = true,
   ["fluid-wagon"] = true,
   ["artillery-wagon"] = true,
}

---Check if an entity is the player's own character
---@param player LuaPlayer
---@param entity LuaEntity
---@return boolean
local function is_own_character(player, entity)
   local character = player.character
   if not character then return false end
   return character.unit_number == entity.unit_number
end

---Check if player can reach an entity for write operations
---@param player LuaPlayer
---@param entity LuaEntity
---@return boolean
local function can_reach_for_write(player, entity)
   -- Own character always has write access
   if is_own_character(player, entity) then return true end

   -- Check if player can physically reach the entity
   return player.can_reach_entity(entity)
end

---Check if a chunk is visible (charted and not fog-of-war)
---@param force LuaForce
---@param surface LuaSurface
---@param position MapPosition
---@return boolean
local function is_position_visible(force, surface, position)
   local chunk_pos = { x = math.floor(position.x / 32), y = math.floor(position.y / 32) }
   return force.is_chunk_visible(surface, chunk_pos)
end

---Check if a chunk is charted (explored, may be fog-of-war)
---@param force LuaForce
---@param surface LuaSurface
---@param position MapPosition
---@return boolean
local function is_position_charted(force, surface, position)
   local chunk_pos = { x = math.floor(position.x / 32), y = math.floor(position.y / 32) }
   return force.is_chunk_charted(surface, chunk_pos)
end

---Check if an entity bypasses charting requirements (vehicles, trains, etc.)
---@param entity LuaEntity
---@return boolean
local function bypasses_charting(entity)
   return CHARTING_BYPASS_TYPES[entity.type] == true
end

---Check if a player can open an entity for reading (viewing contents)
---Returns true if within reach OR if charted (for remote viewing)
---@param pindex integer
---@param entity LuaEntity
---@return boolean can_open
---@return LocalisedString? error_message
function mod.can_open_entity(pindex, entity)
   local player = game.get_player(pindex)

   -- Ghosts are always accessible
   if entity.type == "entity-ghost" then return true end

   -- If player can reach it, they can open it
   if player.can_reach_entity(entity) then return true end

   -- Special entities bypass charting check
   if bypasses_charting(entity) then return true end

   -- Otherwise, check if the chunk is charted (not necessarily visible)
   if is_position_charted(player.force, player.surface, entity.position) then return true end

   -- Cannot access
   return false, { "fa.entity-out-of-reach" }
end

---Check if a player can perform write operations on an entity's inventory
---@param pindex integer
---@param entity LuaEntity
---@return fa.EntityAccess.WriteCheckResult
function mod.can_write_to_entity(pindex, entity)
   local player = game.get_player(pindex)

   -- Own character always has write access
   if is_own_character(player, entity) then return { allowed = true } end

   -- Check if player can physically reach the entity
   if player.can_reach_entity(entity) then return { allowed = true } end

   -- Cannot write - out of reach
   return { allowed = false, reason = { "fa.entity-out-of-reach-for-write" } }
end

---Check if a player can transfer items from one entity to another (sibling transfer)
---Both source and destination must be accessible for writing
---@param pindex integer
---@param source_entity LuaEntity
---@param dest_entity LuaEntity
---@return fa.EntityAccess.WriteCheckResult
function mod.can_transfer_between(pindex, source_entity, dest_entity)
   -- Check source access
   local source_check = mod.can_write_to_entity(pindex, source_entity)
   if not source_check.allowed then return source_check end

   -- Check destination access
   local dest_check = mod.can_write_to_entity(pindex, dest_entity)
   if not dest_check.allowed then return dest_check end

   return { allowed = true }
end

return mod
