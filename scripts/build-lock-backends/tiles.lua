--[[
Tiles Backend for Build Lock

Handles tile placement (stone paths, concrete, etc.).
Respects cursor size (Alt/Shift+I) for larger tile placement areas.
Directly calls Factorio API with terrain_building_size to place tiles.
]]

local BuildLock = require("scripts.build-lock")
local Viewpoint = require("scripts.viewpoint")
local FaUtils = require("scripts.fa-utils")

local BuildAction = BuildLock.BuildAction
local mod = {}

mod.name = "tiles"

---Check if this backend can handle the item
---@param item_prototype LuaItemPrototype
---@return boolean
function mod.can_handle(item_prototype)
   -- Handle items that place tiles
   return item_prototype.place_as_tile_result ~= nil
end

---Build tiles at the current position
---@param context fa.BuildLock.BuildContext
---@param helpers fa.BuildLock.BuildHelpers
---@return string action BuildAction constant (PLACED, SKIP, or FAIL)
function mod.build(context, helpers)
   local pindex = context.pindex
   local player = context.player
   local current_position = context.current_position
   local stack = player.cursor_stack

   if not stack or not stack.valid_for_read then return BuildAction.SKIP end

   -- Check if tile is out of reach - if so, disable build lock entirely
   if player.character then
      local distance = FaUtils.distance(player.character.position, current_position)
      if distance > player.build_distance then
         helpers:set_fail_reason("fa.build-lock-reason-out-of-reach")
         return BuildAction.FAIL
      end
   end

   -- Get cursor size for terrain_building_size calculation
   local vp = Viewpoint.get_viewpoint(pindex)
   local cursor_size = vp:get_cursor_size()
   local t_size = cursor_size * 2 + 1

   -- build_from_cursor with terrain_building_size already centers around the position
   -- No need to offset - just use current_position directly
   local build_pos = {
      x = math.floor(current_position.x),
      y = math.floor(current_position.y),
   }

   -- Try to place tiles
   local old_item_count = stack.count
   if player.can_build_from_cursor({ position = build_pos, terrain_building_size = t_size }) then
      player.build_from_cursor({ position = build_pos, terrain_building_size = t_size })
   else
      -- Can't build (likely overlapping or blocked) - just skip this tile
      return BuildAction.SKIP
   end

   local new_item_count = stack.valid_for_read and stack.count or 0

   -- Check if tiles were placed (item count decreased)
   local placed = new_item_count < old_item_count
   if not placed then return BuildAction.SKIP end

   return BuildAction.PLACED
end

return mod
