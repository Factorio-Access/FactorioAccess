--[[
Vehicle Sounds - Audio feedback for vehicle movement using the launcher audio system.

Plays a tone when the vehicle has moved a certain distance (capacitor model) or
turned significantly. The tone's pan and pitch are derived from the vehicle's
travel direction mapped to the unit circle.

Works for trains, cars, and tanks.
]]

local LauncherAudio = require("scripts.launcher-audio")
local StorageManager = require("scripts.storage-manager")

local mod = {}

-- Configuration
local TONE_DURATION_S = 0.2
local TONE_FADE_OUT_S = 0.02
local TONE_VOLUME = 0.1
local TONE_PAN_WIDTH = 0.7 -- 0 = mono, 1 = full stereo
local ORIENTATION_THRESHOLD = 10 / 360
local BASE_FREQUENCY = 440
local PITCH_MULTIPLIER_MIN = 0.9
local PITCH_MULTIPLIER_MAX = 1.1

local DISTANCE_THRESHOLD = 50

-- Fixed sound ID for rate limiting
local SOUND_ID = "fa_vehicle_sound"

---@class fa.VehicleSounds.State
---@field tracking boolean Whether we're currently tracking this player
---@field x number Last x position
---@field y number Last y position
---@field orientation number Last travel orientation
---@field distance number Accumulated distance since last sound

---@type table<number, fa.VehicleSounds.State>
local vehicle_sounds_storage = StorageManager.declare_storage_module("vehicle_sounds", function()
   return {
      tracking = false,
      x = 0,
      y = 0,
      orientation = 0,
      distance = 0,
   }
end, { ephemeral_state_version = 1 })

---Get the actual travel direction accounting for reverse
---@param vehicle LuaEntity
---@return number orientation 0-1 adjusted for travel direction
local function get_travel_orientation(vehicle)
   local orientation = vehicle.orientation
   -- When speed is negative, vehicle is reversing - flip 180 degrees
   if vehicle.speed < 0 then
      orientation = orientation + 0.5
      if orientation >= 1 then orientation = orientation - 1 end
   end
   return orientation
end

---Convert orientation to unit circle coordinates
---@param orientation number 0-1
---@return number x, number y
local function orientation_to_unit_circle(orientation)
   local angle = orientation * 2 * math.pi
   return math.sin(angle), math.cos(angle)
end

---Calculate the shortest angular distance between two orientations
---@param o1 number
---@param o2 number
---@return number
local function orientation_distance(o1, o2)
   local diff = math.abs(o1 - o2)
   if diff > 0.5 then diff = 1 - diff end
   return diff
end

---Play the vehicle sound for a player
---@param pindex integer
---@param orientation number
---@param reversing boolean
local function play_sound(pindex, orientation, reversing)
   local pan, pitch_y = orientation_to_unit_circle(orientation)
   local pitch_multiplier = PITCH_MULTIPLIER_MIN + (pitch_y + 1) / 2 * (PITCH_MULTIPLIER_MAX - PITCH_MULTIPLIER_MIN)
   local frequency = BASE_FREQUENCY * pitch_multiplier

   local patch = LauncherAudio.patch(SOUND_ID)
   if reversing then
      patch:triangle(frequency)
   else
      patch:sine(frequency)
   end
   patch:duration(TONE_DURATION_S):fade_out(TONE_FADE_OUT_S):pan(pan * TONE_PAN_WIDTH):volume(TONE_VOLUME):send(pindex)
end

---Check if a vehicle should be tracked for sounds
---@param vehicle LuaEntity
---@return boolean
local function is_trackable_vehicle(vehicle)
   if vehicle.train then
      return vehicle.train.speed ~= 0
   elseif vehicle.type == "car" then
      return vehicle.speed ~= 0
   end
   return false
end

---On tick handler
function mod.on_tick()
   for pindex, _ in pairs(game.players) do
      local player = game.get_player(pindex)
      local state = vehicle_sounds_storage[pindex]

      if not player or not player.valid or not player.driving then
         state.tracking = false
         state.distance = 0
         goto continue
      end

      local vehicle = player.vehicle
      if not is_trackable_vehicle(vehicle) then
         state.tracking = false
         state.distance = 0
         goto continue
      end

      local pos = vehicle.position
      local orientation = get_travel_orientation(vehicle)

      if not state.tracking then
         state.tracking = true
         state.x = pos.x
         state.y = pos.y
         state.orientation = orientation
         state.distance = 0
         goto continue
      end

      -- Accumulate distance
      local dx = pos.x - state.x
      local dy = pos.y - state.y
      state.distance = state.distance + math.sqrt(dx * dx + dy * dy)
      state.x = pos.x
      state.y = pos.y

      -- Check triggers
      local dominated_distance = state.distance >= DISTANCE_THRESHOLD
      local turned = orientation_distance(orientation, state.orientation) >= ORIENTATION_THRESHOLD

      if dominated_distance or turned then
         local reversing = not vehicle.train and vehicle.speed < 0
         play_sound(pindex, orientation, reversing)
         if dominated_distance then state.distance = state.distance - DISTANCE_THRESHOLD end
         if turned then state.orientation = orientation end
      end

      ::continue::
   end
end

return mod
