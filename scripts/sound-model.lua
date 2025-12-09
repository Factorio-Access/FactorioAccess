--[[
Sound Model - Maps positions to audio parameters for spatial audio.

Two models are available:

1. UV Pitch/Pan Model (map_uv_to_pitch_pan):
   Maps normalized -1 to 1 space to audio parameters:
   - X axis: pan (-1 = left, 1 = right)
   - Y axis: pitch (higher = north/top, lower = south/bottom)

2. Directional Model (map_relative_position):
   Maps relative world position to audio parameters:
   - Pan: sine of angle off forward axis (normalized x component)
   - LPF: enabled when target is behind the listener (positive y in Factorio)
]]

local LauncherAudio = require("scripts.launcher-audio")

local mod = {}

-- Frequency constants (in Hz)
mod.C4 = 261.63

-- Default pitch configuration
local DEFAULT_CENTER_FREQUENCY = mod.C4
local DEFAULT_OCTAVE_RANGE = 1 -- ±1 octave from center (C3 to C5)

---Map UV coordinates to pan and pitch.
---@param u number X coordinate in -1 to 1 space (left to right)
---@param v number Y coordinate in -1 to 1 space (north/top to south/bottom)
---@param optional_center_frequency number? Center frequency, defaults to C4
---@return number pan Pan value (-1 to 1)
---@return number pitch Frequency in Hz
function mod.map_uv_to_pitch_pan(u, v, optional_center_frequency)
   local center = optional_center_frequency or DEFAULT_CENTER_FREQUENCY

   -- Pan maps directly from u
   local pan = math.max(-1, math.min(1, u))

   -- Calculate frequency range from center ± octave_range
   local multiplier = 2 ^ DEFAULT_OCTAVE_RANGE
   local high_freq = center * multiplier
   local low_freq = center / multiplier

   -- v = -1 (north/top) -> high pitch, v = 1 (south/bottom) -> low pitch
   local t = (v + 1) / 2 -- Map -1..1 to 0..1
   local pitch = high_freq * (1 - t) + low_freq * t

   return pan, pitch
end

--------------------------------------------------------------------------------
-- Directional Model
--------------------------------------------------------------------------------

-- Default LPF cutoff for "behind player" filtering
local DEFAULT_LPF_CUTOFF = 800

---@class fa.SoundModel.DirectionalParams
---@field pan number Pan value (-1 to 1)
---@field lpf boolean Whether low-pass filter should be enabled (target is behind listener)

---Map a relative position to directional audio parameters.
---@param dx number X offset from listener to target (positive = east/right)
---@param dy number Y offset from listener to target (positive = south/behind in Factorio)
---@return fa.SoundModel.DirectionalParams
function mod.map_relative_position(dx, dy)
   local dist = math.sqrt(dx * dx + dy * dy)

   local pan
   if dist < 0.001 then
      pan = 0
   else
      -- sin(angle off forward) = dx / distance
      pan = dx / dist
   end
   pan = math.max(-1, math.min(1, pan))

   -- In Factorio, positive y is south (behind the player facing north)
   local lpf = dy > 0

   return {
      pan = pan,
      lpf = lpf,
   }
end

---Apply standard LPF settings to a patch builder based on directional params.
---@param builder fa.LauncherAudio.PatchBuilder
---@param params fa.SoundModel.DirectionalParams
---@param cutoff number? Optional cutoff frequency, defaults to 800 Hz
---@return fa.LauncherAudio.PatchBuilder
function mod.apply_lpf(builder, params, cutoff)
   cutoff = cutoff or DEFAULT_LPF_CUTOFF
   builder:lpf(cutoff)
   builder:filter_gain(params.lpf and 1.0 or 0.0)
   return builder
end

return mod
