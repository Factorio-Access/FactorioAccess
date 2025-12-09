--[[
Launcher Audio - Builder for audio commands sent to fa_launcher_audio.

The launcher understands the command format: acmd pindex <json>

This module provides a fluent builder API for constructing audio commands
and sending them to the launcher.

Usage:
```lua
local LauncherAudio = require("scripts.launcher-audio")

-- Play a sound file
LauncherAudio.patch()
   :file("sounds/alert.flac")
   :volume(0.8)
   :send(pindex)

-- Play a tone
LauncherAudio.patch()
   :sine(440)
   :duration(0.5)
   :send(pindex)

-- Stop a sound by ID
LauncherAudio.stop(sound_id):send(pindex)

-- Play with low-pass filter (muffled sound)
LauncherAudio.patch()
   :file("sounds/ambient.flac")
   :lpf(500)  -- 500 Hz cutoff
   :filter_gain(1.0)  -- fully filtered
   :send(pindex)

-- Crossfade from filtered to unfiltered over time
LauncherAudio.patch()
   :file("sounds/reveal.flac")
   :lpf(800)
   :filter_gain(LauncherAudio.envelope():linear(0, 1.0):linear(2, 0.0):build())
   :send(pindex)

-- Batch multiple commands
LauncherAudio.compound()
   :add(LauncherAudio.patch():file("a.flac"))
   :add(LauncherAudio.stop(old_id))
   :send(pindex)
```

For full command documentation, see https://github.com/factorio-access/launcher-audio
This module builds those, and it is ultimately handled by that package.
]]

local Uid = require("scripts.uid")

local mod = {}

---@alias fa.LauncherAudio.Interpolation "linear"|"jump"

---@class fa.LauncherAudio.EnvelopePoint
---@field time number
---@field value number
---@field interpolation_from_prev fa.LauncherAudio.Interpolation

---@alias fa.LauncherAudio.Parameter number|fa.LauncherAudio.EnvelopePoint[]

---@alias fa.LauncherAudio.Waveform "sine"|"square"|"triangle"|"saw"

---@class fa.LauncherAudio.EncodedBytesSource
---@field kind "encoded_bytes"
---@field name string

---@class fa.LauncherAudio.WaveformSource
---@field kind "waveform"
---@field waveform fa.LauncherAudio.Waveform
---@field frequency number
---@field non_looping_duration number?
---@field fade_out number?

---@alias fa.LauncherAudio.Source fa.LauncherAudio.EncodedBytesSource|fa.LauncherAudio.WaveformSource

---@class fa.LauncherAudio.LpfConfig
---@field cutoff number Frequency threshold in Hz (immutable after creation)
---@field enabled boolean Whether LPF is active

---@class fa.LauncherAudio.PatchCommand
---@field command "patch"
---@field id string
---@field source fa.LauncherAudio.Source?
---@field volume fa.LauncherAudio.Parameter?
---@field pan fa.LauncherAudio.Parameter?
---@field looping boolean?
---@field playback_rate number?
---@field start_time number?
---@field lpf fa.LauncherAudio.LpfConfig?
---@field filter_gain fa.LauncherAudio.Parameter?

---@class fa.LauncherAudio.StopCommand
---@field command "stop"
---@field id string

---@class fa.LauncherAudio.CompoundCommand
---@field command "compound"
---@field commands fa.LauncherAudio.Command[]

---@alias fa.LauncherAudio.Command fa.LauncherAudio.PatchCommand|fa.LauncherAudio.StopCommand|fa.LauncherAudio.CompoundCommand

-- Forward declarations
local PatchBuilder, StopBuilder, CompoundBuilder, EnvelopeBuilder

--------------------------------------------------------------------------------
-- Envelope Builder
--------------------------------------------------------------------------------

---@class fa.LauncherAudio.EnvelopeBuilder
---@field _points fa.LauncherAudio.EnvelopePoint[]
EnvelopeBuilder = {}
local EnvelopeBuilder_meta = { __index = EnvelopeBuilder }

---Create a new envelope builder
---@return fa.LauncherAudio.EnvelopeBuilder
function mod.envelope()
   return setmetatable({
      _points = {},
   }, EnvelopeBuilder_meta)
end

---Add a point with linear interpolation from the previous point
---@param time number
---@param value number
---@return fa.LauncherAudio.EnvelopeBuilder
function EnvelopeBuilder:linear(time, value)
   table.insert(self._points, {
      time = time,
      value = value,
      interpolation_from_prev = "linear",
   })
   return self
end

---Add a point with instant jump from the previous point
---@param time number
---@param value number
---@return fa.LauncherAudio.EnvelopeBuilder
function EnvelopeBuilder:jump(time, value)
   table.insert(self._points, {
      time = time,
      value = value,
      interpolation_from_prev = "jump",
   })
   return self
end

---Build the envelope points array
---@return fa.LauncherAudio.EnvelopePoint[]
function EnvelopeBuilder:build()
   return self._points
end

--------------------------------------------------------------------------------
-- Patch Builder
--------------------------------------------------------------------------------

---@class fa.LauncherAudio.PatchBuilder
---@field _id string
---@field _source fa.LauncherAudio.Source?
---@field _volume fa.LauncherAudio.Parameter?
---@field _pan fa.LauncherAudio.Parameter?
---@field _looping boolean?
---@field _playback_rate number?
---@field _start_time number?
---@field _lpf fa.LauncherAudio.LpfConfig?
---@field _filter_gain fa.LauncherAudio.Parameter?
PatchBuilder = {}
local PatchBuilder_meta = { __index = PatchBuilder }

---Create a new patch command builder
---@param id string? Optional ID, generates one if not provided
---@return fa.LauncherAudio.PatchBuilder
function mod.patch(id)
   return setmetatable({
      _id = id or tostring(Uid.uid()),
   }, PatchBuilder_meta)
end

---Set the sound ID
---@param id string
---@return fa.LauncherAudio.PatchBuilder
function PatchBuilder:id(id)
   self._id = id
   return self
end

---Get the sound ID
---@return string
function PatchBuilder:get_id()
   return self._id
end

---Set source to an encoded audio file
---@param filename string
---@return fa.LauncherAudio.PatchBuilder
function PatchBuilder:file(filename)
   self._source = {
      kind = "encoded_bytes",
      name = filename,
   }
   return self
end

---Set source to a sine wave
---@param frequency number
---@return fa.LauncherAudio.PatchBuilder
function PatchBuilder:sine(frequency)
   self._source = {
      kind = "waveform",
      waveform = "sine",
      frequency = frequency,
   }
   return self
end

---Set source to a square wave
---@param frequency number
---@return fa.LauncherAudio.PatchBuilder
function PatchBuilder:square(frequency)
   self._source = {
      kind = "waveform",
      waveform = "square",
      frequency = frequency,
   }
   return self
end

---Set source to a triangle wave
---@param frequency number
---@return fa.LauncherAudio.PatchBuilder
function PatchBuilder:triangle(frequency)
   self._source = {
      kind = "waveform",
      waveform = "triangle",
      frequency = frequency,
   }
   return self
end

---Set source to a sawtooth wave
---@param frequency number
---@return fa.LauncherAudio.PatchBuilder
function PatchBuilder:saw(frequency)
   self._source = {
      kind = "waveform",
      waveform = "saw",
      frequency = frequency,
   }
   return self
end

---Set duration for non-looping waveforms
---@param seconds number
---@return fa.LauncherAudio.PatchBuilder
function PatchBuilder:duration(seconds)
   if self._source and self._source.kind == "waveform" then self._source.non_looping_duration = seconds end
   return self
end

---Set fade out duration for waveforms
---@param seconds number
---@return fa.LauncherAudio.PatchBuilder
function PatchBuilder:fade_out(seconds)
   if self._source and self._source.kind == "waveform" then self._source.fade_out = seconds end
   return self
end

---Set volume (static value or envelope)
---@param value number|fa.LauncherAudio.EnvelopeBuilder|fa.LauncherAudio.EnvelopePoint[]
---@return fa.LauncherAudio.PatchBuilder
function PatchBuilder:volume(value)
   if type(value) == "table" and value.build then
      self._volume = value:build()
   else
      self._volume = value
   end
   return self
end

---Set pan (static value or envelope, -1 = left, 1 = right)
---@param value number|fa.LauncherAudio.EnvelopeBuilder|fa.LauncherAudio.EnvelopePoint[]
---@return fa.LauncherAudio.PatchBuilder
function PatchBuilder:pan(value)
   if type(value) == "table" and value.build then
      self._pan = value:build()
   else
      self._pan = value
   end
   return self
end

---Set looping
---@param looping boolean
---@return fa.LauncherAudio.PatchBuilder
function PatchBuilder:looping(looping)
   self._looping = looping
   return self
end

---Set playback rate
---@param rate number
---@return fa.LauncherAudio.PatchBuilder
function PatchBuilder:playback_rate(rate)
   self._playback_rate = rate
   return self
end

---Set start time offset
---@param seconds number
---@return fa.LauncherAudio.PatchBuilder
function PatchBuilder:start_time(seconds)
   self._start_time = seconds
   return self
end

---Configure low-pass filter (immutable after sound creation)
---@param cutoff number Frequency threshold in Hz
---@param enabled boolean? Whether LPF is active, defaults to true
---@return fa.LauncherAudio.PatchBuilder
function PatchBuilder:lpf(cutoff, enabled)
   self._lpf = {
      cutoff = cutoff,
      enabled = enabled ~= false,
   }
   return self
end

---Set filter gain for crossfading between filtered/unfiltered (0.0 = unfiltered, 1.0 = fully filtered)
---@param value number|fa.LauncherAudio.EnvelopeBuilder|fa.LauncherAudio.EnvelopePoint[]
---@return fa.LauncherAudio.PatchBuilder
function PatchBuilder:filter_gain(value)
   if type(value) == "table" and value.build then
      self._filter_gain = value:build()
   else
      self._filter_gain = value
   end
   return self
end

---Build the command structure
---@return fa.LauncherAudio.PatchCommand
function PatchBuilder:build()
   ---@type fa.LauncherAudio.PatchCommand
   local cmd = {
      command = "patch",
      id = self._id,
   }

   if self._source then cmd.source = self._source end
   if self._volume then cmd.volume = self._volume end
   if self._pan then cmd.pan = self._pan end
   if self._looping ~= nil then cmd.looping = self._looping end
   if self._playback_rate then cmd.playback_rate = self._playback_rate end
   if self._start_time then cmd.start_time = self._start_time end
   if self._lpf then cmd.lpf = self._lpf end
   if self._filter_gain then cmd.filter_gain = self._filter_gain end

   return cmd
end

---Build and send the command to the launcher
---@param pindex integer
---@return string id The sound ID for later reference
function PatchBuilder:send(pindex)
   mod.send(pindex, self:build())
   return self._id
end

--------------------------------------------------------------------------------
-- Stop Builder
--------------------------------------------------------------------------------

---@class fa.LauncherAudio.StopBuilder
---@field _id string
StopBuilder = {}
local StopBuilder_meta = { __index = StopBuilder }

---Create a stop command builder
---@param id string The sound ID to stop
---@return fa.LauncherAudio.StopBuilder
function mod.stop(id)
   return setmetatable({
      _id = id,
   }, StopBuilder_meta)
end

---Build the command structure
---@return fa.LauncherAudio.StopCommand
function StopBuilder:build()
   return {
      command = "stop",
      id = self._id,
   }
end

---Build and send the command to the launcher
---@param pindex integer
function StopBuilder:send(pindex)
   mod.send(pindex, self:build())
end

--------------------------------------------------------------------------------
-- Compound Builder
--------------------------------------------------------------------------------

---@class fa.LauncherAudio.CompoundBuilder
---@field _commands fa.LauncherAudio.Command[]
CompoundBuilder = {}
local CompoundBuilder_meta = { __index = CompoundBuilder }

---Create a compound command builder for batching
---@return fa.LauncherAudio.CompoundBuilder
function mod.compound()
   return setmetatable({
      _commands = {},
   }, CompoundBuilder_meta)
end

---Add a command to the batch
---@param builder fa.LauncherAudio.PatchBuilder|fa.LauncherAudio.StopBuilder|fa.LauncherAudio.CompoundBuilder
---@return fa.LauncherAudio.CompoundBuilder
function CompoundBuilder:add(builder)
   table.insert(self._commands, builder:build())
   return self
end

---Build the command structure
---@return fa.LauncherAudio.CompoundCommand
function CompoundBuilder:build()
   return {
      command = "compound",
      commands = self._commands,
   }
end

---Build and send the command to the launcher
---@param pindex integer
function CompoundBuilder:send(pindex)
   mod.send(pindex, self:build())
end

--------------------------------------------------------------------------------
-- Send Function
--------------------------------------------------------------------------------

---Send a command to the launcher
---@param pindex integer
---@param command fa.LauncherAudio.Command
function mod.send(pindex, command)
   local json = helpers.table_to_json(command)
   print("acmd " .. pindex .. " " .. json)
end

return mod
