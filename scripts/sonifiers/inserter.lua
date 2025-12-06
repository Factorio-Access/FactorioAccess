--[[
Inserter Sonifier - Audio feedback for inserter hand movement.

Plays a tone when an inserter's hand reaches its pickup or dropoff position,
allowing blind players to monitor inserter activity by hovering their cursor
over an inserter.
]]

local LauncherAudio = require("scripts.launcher-audio")
local RingBuffer = require("ds.fixed-ringbuffer")
local StorageManager = require("scripts.storage-manager")

local mod = {}

-- Configuration
local THRESHOLD = 0.2 -- Distance threshold for detecting arrival at endpoint
local VOLUME = 0.2
local DURATION = 0.15
local FADE_OUT = 0.1

-- Sound IDs
local PICKUP_SOUND_ID = "fa_inserter_pickup"
local DROPOFF_SOUND_ID = "fa_inserter_dropoff"

-- Note frequencies (C4 = 261.63 Hz, E4 = 329.63 Hz)
local PICKUP_FREQUENCY = 329.63 -- E4
local DROPOFF_FREQUENCY = 261.63 -- C4

---@class fa.InserterSonifier.State
---@field unit_number integer? Unit number of tracked inserter
---@field pickup_dist number? Previous distance to pickup
---@field dropoff_dist number? Previous distance to dropoff
---@field pickup_edge_armed boolean True when crossed into pickup threshold
---@field dropoff_edge_armed boolean True when crossed into dropoff threshold

---@type table<integer, fa.InserterSonifier.State>
local inserter_storage = StorageManager.declare_storage_module("inserter_sonifier", function()
   return {
      unit_number = nil,
      pickup_dist = nil,
      dropoff_dist = nil,
      pickup_edge_armed = false,
      dropoff_edge_armed = false,
   }
end)

---Calculate distance between two positions
---@param pos1 MapPosition
---@param pos2 MapPosition
---@return number
local function distance(pos1, pos2)
   local dx = pos1.x - pos2.x
   local dy = pos1.y - pos2.y
   return math.sqrt(dx * dx + dy * dy)
end

---Play the pickup sound
---@param pindex integer
local function play_pickup_sound(pindex)
   LauncherAudio.patch(PICKUP_SOUND_ID)
      :sine(PICKUP_FREQUENCY)
      :duration(DURATION)
      :fade_out(FADE_OUT)
      :volume(VOLUME)
      :send(pindex)
end

---Play the dropoff sound
---@param pindex integer
local function play_dropoff_sound(pindex)
   LauncherAudio.patch(DROPOFF_SOUND_ID)
      :sine(DROPOFF_FREQUENCY)
      :duration(DURATION)
      :fade_out(FADE_OUT)
      :volume(VOLUME)
      :send(pindex)
end

---Reset state for a player
---@param state fa.InserterSonifier.State
local function reset_state(state)
   state.unit_number = nil
   state.pickup_dist = nil
   state.dropoff_dist = nil
   state.pickup_edge_armed = false
   state.dropoff_edge_armed = false
end

---On tick handler
function mod.on_tick()
   for pindex, _ in pairs(game.players) do
      local player = game.get_player(pindex)
      local state = inserter_storage[pindex]

      if not player or not player.valid then
         reset_state(state)
         goto continue
      end

      if not settings.get_player_settings(pindex)["fa-inserter-sonification"].value then
         reset_state(state)
         goto continue
      end

      local selected = player.selected
      if not selected or not selected.valid or selected.type ~= "inserter" then
         reset_state(state)
         goto continue
      end

      -- Check if we switched to a different inserter
      if state.unit_number ~= selected.unit_number then
         reset_state(state)
         state.unit_number = selected.unit_number
         goto continue
      end

      -- Calculate current distances
      local hand_pos = selected.held_stack_position
      local pickup_dist = distance(hand_pos, selected.pickup_position)
      local dropoff_dist = distance(hand_pos, selected.drop_position)

      -- Get previous distances
      local prev_pickup = state.pickup_dist
      local prev_dropoff = state.dropoff_dist

      -- If hand hasn't moved, do nothing
      if prev_pickup and prev_dropoff and pickup_dist == prev_pickup and dropoff_dist == prev_dropoff then
         goto continue
      end

      -- Store current distances
      state.pickup_dist = pickup_dist
      state.dropoff_dist = dropoff_dist

      -- Need previous values for edge detection
      if not prev_pickup or not prev_dropoff then goto continue end

      -- Edge detection for pickup
      local pickup_fired = false
      if prev_pickup > THRESHOLD and pickup_dist <= THRESHOLD then
         -- Crossed into threshold - arm and fire
         if not state.pickup_edge_armed then
            state.pickup_edge_armed = true
            pickup_fired = true
         end
      end
      if pickup_dist > prev_pickup then
         -- Moving away - disarm
         state.pickup_edge_armed = false
      end

      -- Edge detection for dropoff
      local dropoff_fired = false
      if prev_dropoff > THRESHOLD and dropoff_dist <= THRESHOLD then
         -- Crossed into threshold - arm and fire
         if not state.dropoff_edge_armed then
            state.dropoff_edge_armed = true
            dropoff_fired = true
         end
      end
      if dropoff_dist > prev_dropoff then
         -- Moving away - disarm
         state.dropoff_edge_armed = false
      end

      -- Play sounds (pickup takes priority)
      if pickup_fired then
         play_pickup_sound(pindex)
      elseif dropoff_fired then
         play_dropoff_sound(pindex)
      end

      ::continue::
   end
end

return mod
