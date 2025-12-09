--[[
Sound Model - Directional audio model for spatial sound.

Maps relative position to audio parameters:
- Pan: sine of angle off forward axis (normalized x component)
- LPF: enabled when target is behind the listener (positive y in Factorio)
]]

local mod = {}

-- Default LPF cutoff for "behind player" filtering
local DEFAULT_LPF_CUTOFF = 800

---@class fa.SoundModel.DirectionalParams
---@field pan number Pan value (-1 to 1)
---@field lpf boolean Whether low-pass filter should be enabled (target is behind listener)
---@field gain number? Distance-based attenuation (0 to 1), nil if no ref_distance provided

---Map a relative position to directional audio parameters.
---@param dx number X offset from listener to target (positive = east/right)
---@param dy number Y offset from listener to target (positive = south/behind in Factorio)
---@param ref_distance number? Reference distance for attenuation (gain = 0.5 at this distance)
---@return fa.SoundModel.DirectionalParams
function mod.map_relative_position(dx, dy, ref_distance)
   local dist = math.sqrt(dx * dx + dy * dy)

   local pan
   if dist < 0.8 then
      pan = 0
   else
      -- sin(angle off forward) = dx / distance
      pan = dx / dist
   end
   pan = math.max(-1, math.min(1, pan))

   -- In Factorio, positive y is south (behind the player facing north)
   --
   -- Often things line up perfectly with the player, so allow a small grace window.
   local lpf = dy > -0.1

   -- Distance attenuation: inverse distance falloff
   local gain = 1.0
   if ref_distance then
      gain = ref_distance / (ref_distance + dist)
   end

   return {
      pan = pan,
      lpf = lpf,
      gain = gain,
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
   builder:filter_gain(params.lpf and 0.5 or 0.0)
   return builder
end

return mod
