--[[
Movement history tracking.

We have a number of modules which wish to do things based off whether or not a character moves: build lock (build behind
a running char) and bump detection (detect collisions, even though the game doesn't give us that infrastructure) among
them.

We used to do this by carefully hooking the event system, but that is fragile for a variety of reasons, the biggest
among them being that if you do so too slowly, the char can move more than one tile.  So for example, with enough armor
equipment, you'd get gaps in belts.  Also, driving is the same as walking but faster from the perspective of these
modules. Just, not from the perspective of the Factorio API.

This module is a ringbuffer containing the last second of movement history per character: where that char was, and what
kind of movement (if any) it was doing.  History is represented by a tick number: 0 is "this tikck", 1 is a tick ago,
etc.

For some idea how to use this, belt building walks the tiles between last tick and this tick, and bump detection checks
the prediction versus where we ended up.
]]
local RingBuffer = require("ds.fixed-ringbuffer")

local StorageManager = require("scripts.storage-manager")
local Uid = require("scripts.uid")
local Logging = require("scripts.logging")

local logger = Logging.Logger("movement-history")
local mod = {}

---@class fa.MovementHistory.State
---@field entries fa.ds.FixedRingBuffer of fa.MovementHistory.Entry
---@field generation number incremented when we "break" the history e.g. by teleporting.
---@field last_tick number last tick we updated this player

---@enum fa.MovementHistory.Kind (keys)
mod.MOVEMENT_KINDS = {
   NONE = 0,
   WALKING = 1,
   DRIVING = 2,
}

---@class fa.MovementHistory.Entry
---@field position MapPosition
---@field direction defines.direction
---@field kind fa.MovementHistory.Kind
---@field velocity number

mod.MOVEMENT_HISTORY_LENGTH = 60

local function init_movement_history()
   return {
      entries = RingBuffer.new(mod.MOVEMENT_HISTORY_LENGTH),
      generation = Uid.uid(),
      last_tick = -1,
   }
end

---@type table<number, fa.MovementHistory.State>
local movement_history_storage = StorageManager.declare_storage_module("movement_history", init_movement_history)

---@class fa.MovementHistory.Reader
---@field pindex number
local MovementHistoryReader = {}
local MovementHistoryReader_meta = { __index = MovementHistoryReader }

local movement_history_cache = {}

---@return fa.MovementHistory.Reader
function mod.get_movement_history_reader(pindex)
   local cached = movement_history_cache[pindex]
   if cached then return cached end
   movement_history_cache[pindex] = setmetatable({ pindex = pindex }, MovementHistoryReader_meta)
   return movement_history_cache[pindex]
end

--[[
Deals with the fact that we do not have the ability to know whether ticks happen before or after events.

We call this in on_tick and also when using the history reader, and it makes sure that the player's history is brought
up to this tick.
]]
local function update_player_if_needed(pindex)
   local current_tick = game.tick
   local state = movement_history_storage[pindex]

   if state.last_tick >= current_tick then return end
   state.last_tick = current_tick

   local player = game.get_player(pindex)
   if not player then return end

   local character = player.character
   if not character or not character.valid then
      state.entries:push(nil)
      return
   end

   local entry = {}
   entry.position = character.position

   if player.driving then
      local vehicle = player.vehicle
      if vehicle and vehicle.valid then
         entry.kind = mod.MOVEMENT_KINDS.DRIVING
         entry.velocity = vehicle.speed

         if vehicle.speed > 0.001 or vehicle.speed < -0.001 then
            local orientation = vehicle.orientation
            entry.direction = math.floor(orientation * 8 + 0.5) % 8
         else
            entry.direction = defines.direction.north
         end
      else
         entry.kind = mod.MOVEMENT_KINDS.NONE
         entry.direction = defines.direction.north
         entry.velocity = 0
      end
   else
      local walking_state = player.walking_state
      if walking_state and walking_state.walking then
         entry.kind = mod.MOVEMENT_KINDS.WALKING
         entry.direction = walking_state.direction or defines.direction.north
         entry.velocity = player.character_running_speed
         logger:debug(
            string.format(
               "WALKING: pos=(%.2f,%.2f), dir=%d, vel=%.3f",
               entry.position.x,
               entry.position.y,
               entry.direction,
               entry.velocity
            )
         )
      else
         entry.kind = mod.MOVEMENT_KINDS.NONE
         entry.direction = defines.direction.north
         entry.velocity = 0
      end
   end

   state.entries:push(entry)
end

function MovementHistoryReader:get(when)
   update_player_if_needed(self.pindex)
   local state = movement_history_storage[self.pindex]
   return state.entries:get(when)
end

function MovementHistoryReader:get_generation()
   local state = movement_history_storage[self.pindex]
   return state.generation
end

function mod.reset_and_increment_generation(pindex)
   movement_history_storage[pindex] = init_movement_history()
end

function mod.update_player(pindex)
   update_player_if_needed(pindex)
end

function mod.update_all_players()
   for pindex, _ in pairs(storage.players) do
      update_player_if_needed(pindex)
   end
end

return mod
