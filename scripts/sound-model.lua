--[[
Sound Model - Directional audio model for spatial sound.

Maps relative position to audio parameters:
- Pan: sine of angle off forward axis (normalized x component)
- LPF: enabled when target is behind the listener (positive y in Factorio)

Also manages the sound reference point (cursor vs character) for different contexts.
]]

local StorageManager = require("scripts.storage-manager")
local Viewpoint = require("scripts.viewpoint")

local mod = {}

---@enum fa.SoundModel.ReferencePoint
mod.ReferencePoint = {
   CURSOR = "cursor",
   CHARACTER = "character",
}

---@class fa.SoundModel.State
---@field reference_point fa.SoundModel.ReferencePoint

---@type table<integer, fa.SoundModel.State>
local sound_model_storage = StorageManager.declare_storage_module("sound_model", {
   reference_point = mod.ReferencePoint.CURSOR,
})

-- Default LPF cutoff for "behind player" filtering
local DEFAULT_LPF_CUTOFF = 800

---Set the sound reference point for a player
---@param pindex integer
---@param reference_point fa.SoundModel.ReferencePoint
function mod.set_reference_point(pindex, reference_point)
   sound_model_storage[pindex].reference_point = reference_point
end

---Get the current sound reference point setting for a player
---@param pindex integer
---@return fa.SoundModel.ReferencePoint
function mod.get_reference_point_setting(pindex)
   return sound_model_storage[pindex].reference_point
end

---Get the current reference position for spatial audio calculations.
---Returns the cursor position or character position depending on the current setting.
---@param pindex integer
---@return fa.Point
function mod.get_reference_position(pindex)
   local state = sound_model_storage[pindex]
   local player = game.get_player(pindex)

   if state.reference_point == mod.ReferencePoint.CHARACTER then
      if player and player.character and player.character.valid then
         local pos = player.character.position
         return { x = pos.x, y = pos.y }
      end
   end

   -- Default to cursor position
   local viewpoint = Viewpoint.get_viewpoint(pindex)
   return viewpoint:get_cursor_pos()
end

---@class fa.SoundModel.DirectionalParams
---@field pan number Pan value (-1 to 1)
---@field lpf boolean Whether low-pass filter should be enabled (target is behind listener)
---@field gain number? Distance-based attenuation (0 to 1), nil if no ref_distance provided

---Map a relative position to directional audio parameters.
---@param dx number X offset from listener to target (positive = east/right)
---@param dy number Y offset from listener to target (positive = south/behind in Factorio)
---@param pan_range number Radius for panning (pan = dx / pan_range, clamped to -1..1)
---@param ref_distance number? Reference distance for attenuation (gain = 0.5 at this distance)
---@return fa.SoundModel.DirectionalParams
function mod.map_relative_position(dx, dy, pan_range, ref_distance)
   local dist = math.sqrt(dx * dx + dy * dy)

   -- Percentage-based panning: position relative to pan_range
   local pan = dx / pan_range
   pan = math.max(-1, math.min(1, pan))

   -- In Factorio, positive y is south (behind the player facing north)
   --
   -- Often things line up perfectly with the player, so allow a small grace window.
   local lpf = dy > -0.1

   -- Distance attenuation: inverse distance falloff
   local gain = 1.0
   if ref_distance then gain = ref_distance / (ref_distance + dist) end

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
   builder:filter_gain(params.lpf and 1.0 or 0.0)
   return builder
end

return mod
