--[[
Health Bar Sonifier - Audio feedback for player health and shield levels.

Plays damage sounds with pan position indicating current health/shield level.
Right = full, left = empty. Uses tick-based polling to debounce rapid small damage
events. Also called on-demand via the G key.
]]

local LauncherAudio = require("scripts.launcher-audio")
local StorageManager = require("scripts.storage-manager")

local mod = {}

-- Audio files (relative to audio/ directory)
local HEALTH_SOUND_FILE =
   "player-damaged-character-zapsplat-modified_multimedia_beep_harsh_synth_single_high_pitched_87498.wav"
local SHIELD_SOUND_FILE =
   "player-damaged-shield-zapsplat_multimedia_game_sound_sci_fi_futuristic_beep_action_tone_001_64989.wav"

-- Volume constants for tuning
local HEALTH_VOLUME = 0.4
local SHIELD_VOLUME = 0.4

-- Pan range: full right at 100%, full left at 0%
-- Narrowed to avoid extreme positions sounding awkward
local PAN_MIN = -0.6 -- Empty (0%)
local PAN_MAX = 0.6 -- Full (100%)

-- Tick interval for checking health changes
local CHECK_INTERVAL = 10

---@class fa.HealthBar.TrackedState
---@field unit_number uint32? Unit number of the tracked entity
---@field health_pct number? Last health percentage (0-100, integer)
---@field shield_pct number? Last shield percentage (0-100, integer), nil if no shield

---@type table<integer, fa.HealthBar.TrackedState>
local health_storage = StorageManager.declare_storage_module("health_bar_sonifier", {
   unit_number = nil,
   health_pct = nil,
   shield_pct = nil,
}, {
   ephemeral_state_version = 1,
})

---Map a ratio (0-1) to pan position
---@param ratio number Health or shield ratio (0 to 1)
---@return number pan Pan value (PAN_MIN to PAN_MAX)
local function ratio_to_pan(ratio)
   return PAN_MIN + (PAN_MAX - PAN_MIN) * ratio
end

---Play the health damage sound with pan based on current health
---@param pindex integer
---@param health_ratio number Current health ratio (0 to 1)
function mod.play_health(pindex, health_ratio)
   local pan = ratio_to_pan(health_ratio)
   LauncherAudio.patch():file(HEALTH_SOUND_FILE):volume(HEALTH_VOLUME):pan(pan):send(pindex)
end

---Play the shield damage sound with pan based on current shield
---@param pindex integer
---@param shield_ratio number Current shield ratio (0 to 1)
function mod.play_shield(pindex, shield_ratio)
   local pan = ratio_to_pan(shield_ratio)
   LauncherAudio.patch():file(SHIELD_SOUND_FILE):volume(SHIELD_VOLUME):pan(pan):send(pindex)
end

---Play both health and shield sounds (for on-demand status check)
---@param pindex integer
---@param health_ratio number Current health ratio (0 to 1)
---@param shield_ratio number? Current shield ratio (0 to 1), nil if no shield
function mod.play_status(pindex, health_ratio, shield_ratio)
   local compound = LauncherAudio.compound()

   -- Always play health
   local health_pan = ratio_to_pan(health_ratio)
   compound:add(LauncherAudio.patch():file(HEALTH_SOUND_FILE):volume(HEALTH_VOLUME):pan(health_pan))

   -- Play shield if present
   if shield_ratio then
      local shield_pan = ratio_to_pan(shield_ratio)
      compound:add(LauncherAudio.patch():file(SHIELD_SOUND_FILE):volume(SHIELD_VOLUME):pan(shield_pan))
   end

   compound:send(pindex)
end

---Get the entity and health/shield state for a player's entity of interest
---@param pindex integer
---@return LuaEntity? entity The entity being tracked (vehicle or character)
---@return number? health_pct Integer health percentage (0-100)
---@return number? shield_pct Integer shield percentage (0-100), nil if no shields
local function get_current_state(pindex)
   local player = game.get_player(pindex)
   if not player or not player.valid then return nil, nil, nil end

   -- Prefer vehicle if driving
   if player.driving and player.vehicle and player.vehicle.valid then
      local vehicle = player.vehicle
      local health_pct = math.floor(vehicle.get_health_ratio() * 100 + 0.5)
      local shield_pct = nil

      local grid = vehicle.grid
      if grid and grid.valid and grid.max_shield > 0 then
         shield_pct = math.floor((grid.shield / grid.max_shield) * 100 + 0.5)
      end

      return vehicle, health_pct, shield_pct
   end

   -- Otherwise use character
   local char = player.character
   if not char or not char.valid then return nil, nil, nil end

   local health_pct = math.floor(char.get_health_ratio() * 100 + 0.5)
   local shield_pct = nil

   local armor_inv = player.get_inventory(defines.inventory.character_armor)
   if armor_inv[1] and armor_inv[1].valid_for_read and armor_inv[1].grid then
      local grid = armor_inv[1].grid
      if grid.valid and grid.max_shield > 0 then
         shield_pct = math.floor((grid.shield / grid.max_shield) * 100 + 0.5)
      end
   end

   return char, health_pct, shield_pct
end

---Tick handler for health bar sonification
---Polls health/shield percentages and plays sounds when they change
---@param pindex integer
function mod.on_tick(pindex)
   local tick = game.tick
   if tick % CHECK_INTERVAL ~= 0 then return end

   local state = health_storage[pindex]
   local entity, health_pct, shield_pct = get_current_state(pindex)

   -- Determine the unit number (nil if no entity)
   local unit_number = entity and entity.unit_number or nil

   -- If entity changed, just snapshot and don't play sounds
   if unit_number ~= state.unit_number then
      state.unit_number = unit_number
      state.health_pct = health_pct
      state.shield_pct = shield_pct
      return
   end

   -- No entity to track
   if not entity then return end

   -- Check for decreases and play sounds (only on damage, not healing/regen)
   local health_decreased = state.health_pct and health_pct < state.health_pct
   local shield_decreased = state.shield_pct and shield_pct and shield_pct < state.shield_pct

   if health_decreased then mod.play_health(pindex, health_pct / 100) end
   if shield_decreased then mod.play_shield(pindex, shield_pct / 100) end

   -- Always update stored state
   state.health_pct = health_pct
   state.shield_pct = shield_pct
end

return mod
