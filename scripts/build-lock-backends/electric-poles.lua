--[[
Electric Pole Backend for Build Lock

Handles electric poles with smart spacing based on the last placed pole.
Uses wire reach to determine optimal placement distance.
]]

local FaUtils = require("scripts.fa-utils")
local Logging = require("scripts.logging")
local BuildLock = require("scripts.build-lock")

local BuildAction = BuildLock.BuildAction
local logger = Logging.Logger("build-lock:electric-poles")
local mod = {}

mod.name = "electric-poles"

---Check if this backend can handle the item
---@param item_prototype LuaItemPrototype
---@return boolean
function mod.can_handle(item_prototype)
   if not item_prototype.place_result then return false end
   return item_prototype.place_result.type == "electric-pole"
end

---Get maximum wire reach for a pole, accounting for quality
---@param entity_prototype LuaEntityPrototype
---@param quality LuaQualityPrototype?
---@return number
local function get_max_wire_distance(entity_prototype, quality)
   -- In Factorio 2.0, this is a method on the prototype
   return entity_prototype.get_max_wire_distance(quality or prototypes.quality["normal"])
end

---Select which tile from queue to place pole at
---Uses wire reach to find the furthest tile that would still connect to last pole
---@param pending_tiles table Array of pending tiles
---@param max_count number Consider tiles 1..max_count
---@param context fa.BuildLock.BuildContext
---@param helpers fa.BuildLock.BuildHelpers
---@return {action: string, tile_index: number}? Returns nil if no tile should be placed yet
function mod.select_tile_to_build(pending_tiles, max_count, context, helpers)
   local entity_proto = context.entity_prototype
   local quality = context.item_quality

   -- Get the last placed pole from history
   ---@type fa.BuildLock.PlacedEntity?
   local last_pole = context.entity_history:get(0)

   -- No previous pole? Select the first tile (don't skip current position)
   if not last_pole or not last_pole.entity or not last_pole.entity.valid then
      logger:debug("No last pole, selecting first tile")
      -- Select first tile in queue - if character is blocking, build() will return RETRY
      if #pending_tiles > 0 then
         return { action = BuildAction.PLACED, tile_index = 1 }
      else
         return nil
      end
   end

   -- Find first tile that's out of wire reach by temporarily placing poles
   local first_invalid = nil
   for i = 1, max_count do
      if i > #pending_tiles then break end
      local tile = pending_tiles[i]
      local tile_pos = { x = tile.x + 0.5, y = tile.y + 0.5 }

      -- Temporarily place a pole to test wire reach
      local temp_pole = context.player.surface.create_entity({
         name = entity_proto.name,
         position = tile_pos,
         force = context.player.force,
         quality = quality,
         create_build_effect_smoke = false,
         auto_connect = false,
      })

      if temp_pole and temp_pole.valid then
         -- Check if wires can reach from last pole to this temporary pole
         local can_reach = last_pole.entity.can_wires_reach(temp_pole)
         temp_pole.destroy()

         if not can_reach then
            first_invalid = i
            logger:debug(string.format("First invalid tile at index %d", i))
            break
         end
      else
         -- Can't place here (blocked), skip this tile
         first_invalid = i
         break
      end
   end

   -- All tiles in reach? Don't place yet, wait for player to move further
   if not first_invalid then
      logger:debug("All tiles in reach, waiting for player to move further")
      return nil
   end

   -- Walk backward from first_invalid-1 to find last valid tile
   for i = first_invalid - 1, 1, -1 do
      local tile = pending_tiles[i]
      local tile_pos = { x = tile.x + 0.5, y = tile.y + 0.5 }

      -- Temporarily place a pole to test wire reach
      local temp_pole = context.player.surface.create_entity({
         name = entity_proto.name,
         position = tile_pos,
         force = context.player.force,
         quality = quality,
         create_build_effect_smoke = false,
         auto_connect = false,
      })

      if temp_pole and temp_pole.valid then
         local can_reach = last_pole.entity.can_wires_reach(temp_pole)
         temp_pole.destroy()

         if can_reach then
            logger:debug(string.format("Selected tile at index %d (last valid before out of reach)", i))
            return { action = BuildAction.PLACED, tile_index = i }
         end
      end
   end

   -- No valid tile found (all tiles too close or invalid)
   logger:debug("No valid tile found in queue")
   return nil
end

---Build an electric pole at selected position
---@param context fa.BuildLock.BuildContext
---@param helpers fa.BuildLock.BuildHelpers
---@return string action BuildAction constant (PLACED or RETRY)
function mod.build(context, helpers)
   logger:debug(string.format("Building pole at (%.1f, %.1f)", context.current_position.x, context.current_position.y))

   -- Build the pole
   local placed_entity = helpers:build_entity(context.current_position, context.building_direction)
   return placed_entity and BuildAction.PLACED or BuildAction.RETRY
end

return mod
