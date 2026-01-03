--[[
Player Crafting Sonifier - Audio feedback for active player crafting.

Plays a sound at a configurable interval while a player has items in their
crafting queue. Uses in-game audio via the GUI mixer.
]]

local StorageManager = require("scripts.storage-manager")

local mod = {}

-- Configuration constants
local INTERVAL = 60 -- Ticks between sound plays
local VOLUME = 1 -- Volume modifier (0 to 1)

---@class fa.PlayerCraftingSonifier.State
---@field last_played_tick integer? Last tick when sound was played

---@return fa.PlayerCraftingSonifier.State
local function make_default_state()
   return {
      last_played_tick = nil,
   }
end

---@type table<integer, fa.PlayerCraftingSonifier.State>
local crafting_storage = StorageManager.declare_storage_module("player_crafting_sonifier", make_default_state, {
   ephemeral_state_version = 1,
})

---Per-player tick handler
---@param pindex integer
function mod.on_tick_per_player(pindex)
   local tick = game.tick
   local player = game.get_player(pindex)
   if not player or not player.valid then return end

   local state = crafting_storage[pindex]

   -- Check if player has a non-empty crafting queue
   -- Apparently this throws if the player does not have a character
   if not player.character or player.crafting_queue_size == 0 then
      state.last_played_tick = nil
      return
   end

   -- Check if enough time has passed since last sound
   if state.last_played_tick and (tick - state.last_played_tick) < INTERVAL then return end

   -- Play the crafting sound
   player.play_sound({ path = "player-crafting", volume_modifier = VOLUME })
   state.last_played_tick = tick
end

return mod
