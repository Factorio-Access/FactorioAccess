--[[
Transport Belt Backend for Build Lock

Handles transport belts with automatic corner formation:
- Each new belt is placed with the current movement direction
- After placing, we update the PREVIOUS belt to match the current belt's direction
- This automatically creates proper corners when turning

Example:
- Walking west, place belt facing west
- Turn south, place NEW belt facing south
- Update PREVIOUS (west) belt to face south -> forms corner!
]]

local FaUtils = require("scripts.fa-utils")
local Logging = require("scripts.logging")
local BuildLock = require("scripts.build-lock")

local BuildAction = BuildLock.BuildAction
local logger = Logging.Logger("build-lock:belts")
local mod = {}

mod.name = "transport-belts"

---Check if this backend can handle the item
---@param item_prototype LuaItemPrototype
---@return boolean
function mod.can_handle(item_prototype)
   if not item_prototype.place_result then return false end
   return item_prototype.place_result.type == "transport-belt"
end

---Build the transport belt
---@param context fa.BuildLock.BuildContext
---@param helpers fa.BuildLock.BuildHelpers
---@return string action BuildAction constant (PLACED, SKIP, or RETRY)
function mod.build(context, helpers)
   -- Always use the current movement direction
   -- This way if the player turns, the belt points in the new direction
   local build_direction = context.movement_direction

   logger:debug(string.format("Placing belt with movement direction: %d", build_direction))

   -- Build the entity
   local placed_entity = helpers:build_entity(context.current_position, build_direction)
   if not placed_entity then return BuildAction.RETRY end

   -- Now entity_history has been updated by build_entity, so:
   -- index 0 = entity we just placed
   -- index 1 = previous belt
   ---@type fa.BuildLock.PlacedEntity?
   local curr_placed = context.entity_history:get(0)
   ---@type fa.BuildLock.PlacedEntity?
   local prev_placed = context.entity_history:get(1)

   if prev_placed and prev_placed.entity and prev_placed.entity.valid and curr_placed then
      local prev_belt = prev_placed.entity
      local curr_dir = curr_placed.direction

      -- Update the previous belt to point in the same direction as the current one
      -- This forms corners automatically when direction changes
      if prev_belt.direction ~= curr_dir then
         logger:debug(
            string.format("Updating prev belt direction from %d to %d (forms corner)", prev_belt.direction, curr_dir)
         )
         prev_belt.direction = curr_dir
      else
         logger:debug("Prev belt already points same direction (straight line)")
      end
   end

   return BuildAction.PLACED
end

return mod
