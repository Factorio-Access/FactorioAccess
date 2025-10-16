--[[
Simple Backend for Build Lock

Handles basic entities that don't need special placement logic.
Places the entity at each position with the player's current building direction.
]]

local BuildLock = require("scripts.build-lock")

local BuildAction = BuildLock.BuildAction
local mod = {}

mod.name = "simple"

---Check if this backend can handle the item
---@param item_prototype LuaItemPrototype
---@return boolean
function mod.can_handle(item_prototype)
   if not item_prototype.place_result then return false end

   local entity_type = item_prototype.place_result.type

   -- Don't handle transport belts or electric poles (they have specialized backends)
   if entity_type == "transport-belt" then return false end
   if entity_type == "electric-pole" then return false end

   -- Handle most other placeable entities
   return true
end

---Build a simple entity
---@param context fa.BuildLock.BuildContext
---@param helpers fa.BuildLock.BuildHelpers
---@return string action BuildAction constant (PLACED, SKIP, or RETRY)
function mod.build(context, helpers)
   -- For simple entities, just place at current position with current building direction
   local placed_entity = helpers:build_entity(context.current_position, context.building_direction)
   return placed_entity and BuildAction.PLACED or BuildAction.RETRY
end

return mod
