--[[
Train Sounds - Audio feedback for train movement using the launcher audio system.

Plays a tone when the train has moved a certain distance (capacitor model) or
turned significantly. The tone's pan and pitch are derived from the train's
travel direction mapped to the unit circle.
]]

local LauncherAudio = require("scripts.launcher-audio")
local StorageManager = require("scripts.storage-manager")

local mod = {}

-- Configuration
local TONE_DURATION_S = 0.2
local TONE_FADE_OUT_S = 0.02
local TONE_VOLUME = 0.1
local TONE_PAN_WIDTH = 0.7 -- 0 = mono, 1 = full stereo
local DISTANCE_THRESHOLD = 50
local ORIENTATION_THRESHOLD = 10 / 360
local BASE_FREQUENCY = 440
local PITCH_MULTIPLIER_MIN = 0.9
local PITCH_MULTIPLIER_MAX = 1.1

-- Fixed sound ID for rate limiting
local SOUND_ID = "fa_train_sound"

---@class fa.TrainSounds.State
---@field tracking boolean Whether we're currently tracking this player
---@field x number Last x position
---@field y number Last y position
---@field orientation number Last travel orientation
---@field distance number Accumulated distance since last sound

---@type table<number, fa.TrainSounds.State>
local train_sounds_storage = StorageManager.declare_storage_module("train_sounds", function()
   return {
      tracking = false,
      x = 0,
      y = 0,
      orientation = 0,
      distance = 0,
   }
end)

---Get the actual travel direction accounting for reverse
---@param vehicle LuaEntity
---@return number orientation 0-1 adjusted for travel direction
local function get_travel_orientation(vehicle)
   local orientation = vehicle.orientation
   -- When speed is negative, train is reversing - flip 180 degrees
   if vehicle.speed < 0 then
      orientation = orientation + 0.5
      if orientation >= 1 then orientation = orientation - 1 end
   end
   return orientation
end

---Convert train orientation to unit circle coordinates
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

---Play the train sound for a player
---@param pindex integer
---@param orientation number
local function play_sound(pindex, orientation)
   local pan, pitch_y = orientation_to_unit_circle(orientation)
   local pitch_multiplier = PITCH_MULTIPLIER_MIN + (pitch_y + 1) / 2 * (PITCH_MULTIPLIER_MAX - PITCH_MULTIPLIER_MIN)
   local frequency = BASE_FREQUENCY * pitch_multiplier

   LauncherAudio.patch(SOUND_ID)
      :sine(frequency)
      :duration(TONE_DURATION_S)
      :fade_out(TONE_FADE_OUT_S)
      :pan(pan * TONE_PAN_WIDTH)
      :volume(TONE_VOLUME)
      :send(pindex)
end

---On tick handler
function mod.on_tick()
   for pindex, _ in pairs(game.players) do
      local player = game.get_player(pindex)
      local state = train_sounds_storage[pindex]

      if not player or not player.valid or not player.driving then
         state.tracking = false
         state.distance = 0
         goto continue
      end

      local vehicle = player.vehicle
      local train = vehicle.train
      if not train or train.speed == 0 then
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
         play_sound(pindex, orientation)
         if dominated_distance then state.distance = state.distance - DISTANCE_THRESHOLD end
         if turned then state.orientation = orientation end
      end

      ::continue::
   end
end

return mod
