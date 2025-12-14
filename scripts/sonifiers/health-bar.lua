--[[
Health Bar Sonifier - Audio feedback for player health and shield levels.

Plays damage sounds with pan position indicating current health/shield level.
Right = full, left = empty. Called both on damage events and on-demand (G key).
]]

local LauncherAudio = require("scripts.launcher-audio")

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

return mod
