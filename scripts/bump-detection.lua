--[[
Bump Detection System
Provides audio feedback when the player collides with obstacles while walking.
Uses movement history to detect deviations in movement patterns.
]]

local StorageManager = require("scripts.storage-manager")
local MovementHistory = require("scripts.movement-history")
local sounds = require("scripts.ui.sounds")

local mod = {}

---@class fa.BumpDetection.BumpState
---@field last_bump_tick number
---@field last_stuck_tick number

---@type table<number, fa.BumpDetection.BumpState>
local bump_storage = StorageManager.declare_storage_module("bump_detection", {
   last_bump_tick = 0,
   last_stuck_tick = 0,
})

---Resets bump detection statistics for a player
---@param pindex number
function mod.reset_bump_stats(pindex)
   bump_storage[pindex] = {
      last_bump_tick = 0,
      last_stuck_tick = 0,
   }
end

---Calculate angle between two vectors in radians
---@param v1 {x: number, y: number}
---@param v2 {x: number, y: number}
---@return number angle in radians (0 to pi)
local function angle_between_vectors(v1, v2)
   local dot = v1.x * v2.x + v1.y * v2.y
   local len1 = math.sqrt(v1.x * v1.x + v1.y * v1.y)
   local len2 = math.sqrt(v2.x * v2.x + v2.y * v2.y)

   if len1 < 0.001 or len2 < 0.001 then return 0 end

   local cos_angle = dot / (len1 * len2)
   cos_angle = math.max(-1, math.min(1, cos_angle))
   return math.acos(cos_angle)
end

---Checks and plays bump alert sounds when collision is detected
---@param pindex number
---@param this_tick number
function mod.check_and_play_bump_alert_sound(pindex, this_tick)
   local bump = bump_storage[pindex]

   -- Check cooldown
   if this_tick - bump.last_bump_tick < 15 then return end

   -- Get movement history
   local reader = MovementHistory.get_movement_history_reader(pindex)

   -- Collect recent walking entries
   local entries = {}
   local positions = {}
   local last_direction = nil

   for i = 0, 4 do
      local entry = reader:get(i)
      if entry and entry.kind == MovementHistory.MOVEMENT_KINDS.WALKING then
         table.insert(entries, entry)
         table.insert(positions, entry.position)
         last_direction = last_direction or entry.direction
      end
   end

   -- Need at least 3 walking entries to detect bump
   if #entries < 3 then return end

   -- Check if all entries have same intended direction
   local consistent_direction = true
   for _, entry in ipairs(entries) do
      if entry.direction ~= last_direction then
         consistent_direction = false
         break
      end
   end

   -- Only detect bumps when trying to maintain direction
   if not consistent_direction then return end

   -- Calculate movement vectors
   local v1 = {
      x = positions[1].x - positions[2].x,
      y = positions[1].y - positions[2].y,
   }
   local v2 = {
      x = positions[2].x - positions[3].x,
      y = positions[2].y - positions[3].y,
   }

   -- Calculate angle deviation
   local angle = angle_between_vectors(v1, v2)
   local angle_degrees = angle * 180 / math.pi

   -- Detect bump based on angle threshold
   if angle_degrees > 10 then
      bump.last_bump_tick = this_tick

      -- Select sound based on angle
      if angle_degrees < 40 then
         -- Sliding collision
         sounds.play_player_bump_slide(pindex)
      else
         -- Direct collision
         sounds.play_player_bump_trip(pindex)
      end
   end
end

---If walking but position unchanged, play stuck alert
---@param pindex number
---@param this_tick number
function mod.check_and_play_stuck_alert_sound(pindex, this_tick)
   local bump = bump_storage[pindex]

   -- Check cooldown
   if this_tick - bump.last_stuck_tick < 30 then return end

   -- Get movement history
   local reader = MovementHistory.get_movement_history_reader(pindex)

   -- Check last 3 entries
   local stuck = true
   local first_pos = nil
   local walking_count = 0

   for i = 0, 2 do
      local entry = reader:get(i)
      if entry and entry.kind == MovementHistory.MOVEMENT_KINDS.WALKING then
         walking_count = walking_count + 1
         if not first_pos then
            first_pos = entry.position
         elseif first_pos.x ~= entry.position.x or first_pos.y ~= entry.position.y then
            stuck = false
            break
         end
      end
   end

   -- Need at least 3 walking entries all at same position
   if stuck and walking_count >= 3 then
      bump.last_stuck_tick = this_tick
      sounds.play_player_bump_stuck(pindex)
   end
end

return mod
