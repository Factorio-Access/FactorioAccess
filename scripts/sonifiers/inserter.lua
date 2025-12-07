--[[
Inserter Sonifier - Audio feedback for inserter hand movement.

Plays a tone when an inserter's hand reaches its pickup or dropoff position,
allowing blind players to monitor inserter activity by hovering their cursor
over an inserter.
]]

local FaUtils = require("scripts.fa-utils")
local LauncherAudio = require("scripts.launcher-audio")
local StorageManager = require("scripts.storage-manager")

local mod = {}

-- Configuration
local THRESHOLD = 0.2 -- Distance threshold for detecting arrival at endpoint
local PICKUP_VOLUME = 0.1
local DROPOFF_VOLUME = 0.2

-- Sound IDs
local PICKUP_SOUND_ID = "fa_inserter_pickup"
local DROPOFF_SOUND_ID = "fa_inserter_dropoff"

-- Audio files
local PICKUP_FILE = "sonifiers/inserter/hand_up.ogg"
local DROPOFF_FILE = "sonifiers/inserter/hand_down.ogg"

---@class fa.InserterSonifier.EdgeState
---@field dist number? Previous distance
---@field armed boolean Edge armed state

---@class fa.InserterSonifier.State
---@field unit_number integer? Unit number of tracked inserter
---@field pickup fa.InserterSonifier.EdgeState
---@field dropoff fa.InserterSonifier.EdgeState

---@return fa.InserterSonifier.State
local function make_default_state()
   return {
      unit_number = nil,
      pickup = { dist = nil, armed = false },
      dropoff = { dist = nil, armed = false },
   }
end

---@type table<integer, fa.InserterSonifier.State>
local inserter_storage = StorageManager.declare_storage_module("inserter_sonifier", make_default_state, {
   ephemeral_state_version = 1,
})

---Play the pickup sound
---@param pindex integer
local function play_pickup_sound(pindex)
   LauncherAudio.patch(PICKUP_SOUND_ID):file(PICKUP_FILE):volume(PICKUP_VOLUME):send(pindex)
end

---Play the dropoff sound
---@param pindex integer
local function play_dropoff_sound(pindex)
   LauncherAudio.patch(DROPOFF_SOUND_ID):file(DROPOFF_FILE):volume(DROPOFF_VOLUME):send(pindex)
end

---Reset state for a player
---@param state fa.InserterSonifier.State
local function reset_state(state)
   state.unit_number = nil
   state.pickup.dist = nil
   state.pickup.armed = false
   state.dropoff.dist = nil
   state.dropoff.armed = false
end

---Process edge detection for one endpoint
---@param edge fa.InserterSonifier.EdgeState
---@param current_dist number
---@return boolean fired True if sound should play
local function process_edge(edge, current_dist)
   local prev_dist = edge.dist
   edge.dist = current_dist

   if not prev_dist then return false end

   local fired = false
   if prev_dist > THRESHOLD and current_dist <= THRESHOLD then
      if not edge.armed then
         edge.armed = true
         fired = true
      end
   end
   if current_dist > prev_dist then edge.armed = false end

   return fired
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
      local pickup_dist = FaUtils.distance(hand_pos, selected.pickup_position)
      local dropoff_dist = FaUtils.distance(hand_pos, selected.drop_position)

      -- Skip if hand hasn't moved
      if state.pickup.dist and pickup_dist == state.pickup.dist and dropoff_dist == state.dropoff.dist then
         goto continue
      end

      -- Process edge detection
      local pickup_fired = process_edge(state.pickup, pickup_dist)
      local dropoff_fired = process_edge(state.dropoff, dropoff_dist)

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
