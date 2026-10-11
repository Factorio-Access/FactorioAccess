--[[
Asteroid chunks drifting past a space platform. They aren't entities, so nothing tells us they exist: each refresh
asks the platform for all of them and makes a snapshot. They move constantly, so an entry remembers the chunk's
movement and, when announced, looks for a chunk of the same kind where that movement would have taken it.
]]
local SC = require("scripts.scanner.scanner-consts")

local mod = {}

-- How far from the predicted position a chunk may be and still count as the one the entry was made for.
local MATCH_RADIUS = 2

---@class fa.scanner.backends.AsteroidChunkData
---@field name string
---@field position MapPosition.struct Where the chunk was at tick
---@field movement fa.VectorArray Tiles per tick
---@field tick integer

---@class fa.scanner.AsteroidChunksBackend: fa.scanner.ScannerBackend
---@field surface LuaSurface
local AsteroidChunksBackend = {}
mod.AsteroidChunksBackend = AsteroidChunksBackend
local AsteroidChunksBackend_meta = { __index = AsteroidChunksBackend }
script.register_metatable("fa.scanner.AsteroidChunksBackend", AsteroidChunksBackend_meta)

---@param surface LuaSurface
function AsteroidChunksBackend.new(surface)
   return setmetatable({ surface = surface }, AsteroidChunksBackend_meta)
end

---@param e LuaEntity
function AsteroidChunksBackend:on_new_entity(e) end

---@param event EventData.on_object_destroyed
function AsteroidChunksBackend:on_entity_destroyed(event) end

-- The chunk an entry was made for, or nil if it was collected, destroyed, or drifted off course.
---@param e fa.scanner.ScanEntry
---@return AsteroidChunk?
function AsteroidChunksBackend:find_chunk(e)
   local platform = assert(self.surface.platform)

   ---@type fa.scanner.backends.AsteroidChunkData
   local data = e.backend_data
   local elapsed = game.tick - data.tick
   local x = data.position.x + data.movement[1] * elapsed
   local y = data.position.y + data.movement[2] * elapsed

   local found = platform.find_asteroid_chunks_filtered({
      area = { { x - MATCH_RADIUS, y - MATCH_RADIUS }, { x + MATCH_RADIUS, y + MATCH_RADIUS } },
      name = data.name,
   })
   local best, best_dist = nil, math.huge
   for _, chunk in ipairs(found) do
      local pos = chunk.position --[[@as MapPosition.struct]]
      local dist = (pos.x - x) ^ 2 + (pos.y - y) ^ 2
      if dist < best_dist then
         best, best_dist = chunk, dist
      end
   end
   return best
end

---@param player LuaPlayer
---@param e fa.scanner.ScanEntry
function AsteroidChunksBackend:validate_entry(player, e)
   return player.surface_index == self.surface.index and self:find_chunk(e) ~= nil
end

---@param player LuaPlayer
---@param e fa.scanner.ScanEntry
function AsteroidChunksBackend:update_entry(player, e)
   local chunk = assert(self:find_chunk(e))
   local pos = chunk.position --[[@as MapPosition.struct]]
   e.position = { x = pos.x, y = pos.y }
   e.backend_data = { name = chunk.name, position = pos, movement = chunk.movement, tick = game.tick }
end

function AsteroidChunksBackend:readout_entry(player, e)
   return prototypes.asteroid_chunk[e.backend_data.name].localised_name
end

---@param player LuaPlayer
---@param callback fun(fa.scanner.ScanEntry)
function AsteroidChunksBackend:dump_entries_to_callback(player, callback)
   if not script.feature_flags.space_travel then return end
   local platform = self.surface.platform
   if not platform then return end

   local tick = game.tick
   for _, chunk in ipairs(platform.find_asteroid_chunks_filtered({})) do
      local pos = chunk.position --[[@as MapPosition.struct]]
      callback({
         position = { x = pos.x, y = pos.y },
         backend = self,
         backend_data = { name = chunk.name, position = pos, movement = chunk.movement, tick = tick },
         category = SC.CATEGORIES.RESOURCES,
         subcategory = chunk.name,
      })
   end
end

function AsteroidChunksBackend:get_aabb(e)
   local p = e.position
   return p.x, p.y, p.x, p.y
end

function AsteroidChunksBackend:is_huge(e)
   return false
end

return mod
