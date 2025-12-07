--[[
Sound Model - Maps UV coordinates to pan and pitch for spatial audio.

Maps positions in normalized -1 to 1 space to audio parameters:
- X axis: pan (-1 = left, 1 = right)
- Y axis: pitch (higher = north/top, lower = south/bottom)
]]

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

return mod
