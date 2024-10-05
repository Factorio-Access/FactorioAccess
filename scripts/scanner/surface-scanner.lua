local GlobalManager = require("scripts.global-manager")
local Memosort = require("scripts.memosort")
local ResourcePatchesBackend = require("scripts.scanner.backends.resource-patches")
local ScannerConsts = require("scripts.scanner.scanner-consts")
local SimpleBackend = require("scripts.scanner.backends.simple")
-- This is typed around 100 times and only used for the LUT, so we will shorten
-- it.
local SEB = require("scripts.scanner.backends.single-entity")
local SparseBitset = require("scripts.ds.sparse-bitset")
local TH = require("scripts.table-helpers")
local TreeBackend = require("scripts.scanner.backends.trees")
local WaterBackend = require("scripts.scanner.backends.water")
local WorkQueue = require("scripts.work-queue")

local mod = {}

local CHUNK_SIZE = 32

--[[
List all prototypes the scanner should care about. Any prototype not in this
table will not be processed by the scanner.

We keep these in alphabetical order. To do so in a blind friendly manner, wrap
all keys in `[""]` even if they don't contain -, then select the contents of
this table and ask VSCode to "sort lines ascending".  That's important: it lets
us see if a prototype is listed yet.

Rocks are a special case; the next table is where you can drop name overrides
for things like that.
]]
---@type table<string, fa.scanner.ScannerBackend>
local BACKEND_LUT = {
   ["accumulator"] = SEB.Logistics,
   ["ammo-turret"] = SEB.Military,
   ["arithmetic-combinator"] = SEB.Logistics,
   ["artillery-flare"] = SEB.Military,
   ["artillery-turret"] = SEB.Military,
   ["artillery-wagon"] = SEB.TrainsNamed,
   ["assembling-machine"] = SEB.CraftingMachine,
   ["beacon"] = SEB.Production,
   ["boiler"] = SEB.Logistics,
   ["burner-generator"] = SEB.Logistics,
   ["car"] = SEB.Vehicle,
   ["cargo-wagon"] = SEB.TrainsNamed,
   ["character-corpse"] = SEB.Other,
   ["character"] = SEB.Character,
   ["cliff"] = SEB.Other,
   ["combat-robot"] = SEB.Military,
   ["constant-combinator"] = SEB.Logistics,
   ["construction-robot"] = SEB.Logistics,
   ["container"] = SEB.Containers,
   ["corpse"] = SEB.Corpses,
   ["curved-rail"] = SEB.TrainsSimple,
   ["decider-combinator"] = SEB.Logistics,
   ["electric-energy-interface"] = SEB.Logistics,
   ["electric-pole"] = SEB.Logistics,
   ["electric-turret"] = SEB.Military,
   ["entity-ghost"] = SEB.Ghosts,
   ["fire"] = SEB.Other,
   ["fish"] = SEB.Other,
   ["flame-thrower-explosion"] = SEB.Other,
   ["fluid-turret"] = SEB.Military,
   ["fluid-wagon"] = SEB.TrainsNamed,
   ["furnace"] = SEB.Furnace,
   ["gate"] = SEB.Military,
   ["generator"] = SEB.Logistics,
   ["heat-interface"] = SEB.Logistics,
   ["heat-pipe"] = SEB.Logistics,
   ["infinity-container"] = SEB.Containers,
   ["infinity-pipe"] = SEB.Production,
   ["inserter"] = SEB.Logistics,
   ["item-entity"] = SEB.Other,
   ["lab"] = SEB.Production,
   ["lamp"] = SEB.Logistics,
   ["land-mine"] = SEB.Military,
   ["linked-belt"] = SEB.Logistics,
   ["linked-container"] = SEB.Logistics,
   ["loader-1x1"] = SEB.Logistics,
   ["loader"] = SEB.Logistics,
   ["locomotive"] = SEB.TrainsNamed,
   ["logistic-container"] = SEB.Containers,
   ["logistic-robot"] = SEB.Logistics,
   ["market"] = SEB.Logistics,
   ["mining-drill"] = SEB.Production,
   ["offshore-pump"] = SEB.Production,
   ["pipe-to-ground"] = SEB.Logistics,
   ["pipe"] = SEB.Logistics,
   ["player-port"] = SEB.Other,
   ["power-switch"] = SEB.Logistics,
   ["programmable-speaker"] = SEB.Logistics,
   ["projectile"] = SEB.Other,
   ["pump"] = SEB.Logistics,
   ["radar"] = SEB.Military,
   ["rail-chain-signal"] = SEB.TrainsSimple,
   ["rail-remmnants"] = SEB.Remnants,
   ["rail-signal"] = SEB.TrainsSimple,
   ["reactor"] = SEB.Logistics,
   ["resource"] = ResourcePatchesBackend.ResourcePatchesBackend,
   ["roboport"] = SEB.Logistics,
   ["rocket-silo-rocket-shadow"] = SEB.Other,
   ["rocket-silo-rocket"] = SEB.Other,
   ["rocket-silo"] = SEB.Production,
   ["simple-entity-with-force"] = SEB.Other,
   ["simple-entity-with-owner"] = SEB.Other,
   ["simple-entity"] = SEB.Other,
   ["solar-panel"] = SEB.Logistics,
   ["spider-vehicle"] = SEB.Vehicle,
   ["splitter"] = SEB.Logistics,
   ["storage-tank"] = SEB.Logistics,
   ["straight-rail"] = SEB.TrainsSimple,
   ["tile-ghost"] = SEB.Ghosts,
   ["train-stop"] = SEB.TrainsSimple,
   ["transport-belt"] = SEB.Logistics,
   ["tree"] = TreeBackend.TreeBackend,
   ["turret"] = SEB.Unit,
   ["underground-belt"] = SEB.Logistics,
   ["unit-spawner"] = SEB.Unit,
   ["unit"] = SEB.Unit,
   ["wall"] = SEB.Military,
}

local BACKEND_NAME_OVERRIDES = {}

-- All our kinds of rocks.
TH.merge_mappings(BACKEND_NAME_OVERRIDES, {
   ["rock-big"] = SEB.Rock,
   ["rock-huge"] = SEB.Rock,
   ["rock-medium"] = SEB.Rock,
   ["rock-small"] = SEB.Rock,
   ["rock-tiny"] = SEB.Rock,
   ["sand-rock-big"] = SEB.Rock,
   ["sand-rock-medium"] = SEB.Rock,
   ["sand-rock-small"] = SEB.Rock,
})

---@class fa.scanner.SurfaceBackends
---@field lut table<string, fa.scanner.ScannerBackend>
---@field name_lut table<string, fa.scanner.ScannerBackend>
---@field water_backend fa.scanner.WaterBackend

-- Instantiate a set of backends, later wired up to a surface, by iterating over
-- the LUT and making backends for each thing.
---@param surface LuaSurface
---@return fa.scanner.SurfaceBackends
local function instantiate_backends(surface)
   local instantiated = {}
   local lut = {}
   local name_lut = {}

   for proto, backend in pairs(BACKEND_LUT) do
      local b = instantiated[backend] or backend.new(surface)
      instantiated[backend] = b
      lut[proto] = b
   end

   for name, backend in pairs(BACKEND_NAME_OVERRIDES) do
      local b = instantiated[backend] or backend.new(surface)
      instantiated[backend] = b
      name_lut[name] = b
   end

   return {
      lut = lut,
      name_lut = name_lut,
      water_backend = WaterBackend.WaterBackend.new(surface),
   }
end

---@class fa.scanner.GlobalSurfaceState
---@field backends fa.scanner.SurfaceBackends
---@field seen_entities fa.ds.SparseBitset
---@field seen_chunks table<number, table<number, true>>

---@return fa.scanner.GlobalSurfaceState
local function new_empty_surface(key)
   local surf = game.get_surface(key)
   assert(surf)

   ---@type fa.scanner.GlobalSurfaceState
   local ret = {
      backends = instantiate_backends(surf),
      seen_entities = SparseBitset.SparseBitset.new(),
      seen_chunks = TH.defaulting_table(),
   }

   return ret
end

---@type table<number, fa.scanner.GlobalSurfaceState>
local surface_state = GlobalManager.declare_global_module("scanner", new_empty_surface, { root_field = "surfaces" })

-- Given a backend setup and an array of entities, dispatch the entities to the
-- backends.  Assumes the entities are valid.
---@param backends fa.scanner.SurfaceBackends
---@param ents LuaEntity[]
local function dispatch_entities(backends, ents)
   for i = 1, #ents do
      local e = ents[i]

      if backends.name_lut[e.name] then
         backends.name_lut[e.name]:on_new_entity(e)
      elseif backends.lut[e.type] then
         backends.lut[e.type]:on_new_entity(e)
      end
   end
end

---@class fa.scanner.SurfaceScannerChunkScan
---@field surface LuaSurface
---@field surface_state fa.scanner.GlobalSurfaceState
---@field chunk ChunkPositionAndArea

---@param cmd fa.scanner.SurfaceScannerChunkScan
local function scan_chunk(cmd)
   if not cmd.surface.valid then return end

   local surf = cmd.surface
   local state = cmd.surface_state
   local chunk = cmd.chunk
   local cx, cy = chunk.x, chunk.y

   local ents = surf.find_entities(chunk.area)

   -- We just got these from the surface with no gap, so do everything assuming
   -- it's valid.
   TH.retain_unordered(ents, function(item)
      local dest_req = script.register_on_entity_destroyed(item)
      if state.seen_entities:test(dest_req) then return false end

      -- The entity may not have the center in this chunk.
      if not math.floor(item.position.x / CHUNK_SIZE) == cx and math.floor(item.position.y / CHUNK_SIZE) == cy then
         return false
      end

      state.seen_entities:set(dest_req)
      return true
   end)

   -- Sorting from a corner with manhattan distance causes the scan to proceed
   -- in an ark from the corner outward.  This doesn't matter for anything but
   -- resources, but for resources it helps the clustering algo extend clusters
   -- rather than having to create many small ones to merge later.
   local ref_x, ref_y = cx * CHUNK_SIZE, cy * CHUNK_SIZE
   Memosort.memosort(ents, function(e)
      local p = e.position
      return (p.x - ref_x) + (p.y - ref_y)
   end)

   dispatch_entities(state.backends, ents)

   if not state.seen_chunks[cx][cy] then
      state.seen_chunks[cx][cy] = true
      state.backends.water_backend:on_new_chunk(chunk)
   end
end

---@param queue fa.WorkQueueHandle
local function redispatch(queue)
   -- For each surface, for each chunk in that surface, dispatch a task.
   local tasks = {}

   for _, s in pairs(game.surfaces) do
      local state = surface_state[s.index]
      for c in s.get_chunks() do
         local task = {
            surface = s,
            surface_state = state,
            chunk = c,
         }
         table.insert(tasks, task)
      end
   end

   -- Take that and sort it by the distance to any player, so that chunks near
   -- players are scanned first on initial scans of large saves.
   local players = {}
   for _, p in pairs(game.players) do
      table.insert(players, p)
   end

   Memosort.memosort(tasks, function(t)
      if not next(players) then return 0 end

      local cx, cy = t.chunk.x * CHUNK_SIZE, t.chunk.y * CHUNK_SIZE

      local best = math.huge
      for _, p in pairs(players) do
         local dist = math.sqrt((cx - p.position.x) ^ 2 + (cy - p.position.y) ^ 2)
         if dist < best then best = dist end
      end
      return best
   end)

   for _, t in pairs(tasks) do
      queue:enqueue(t)
   end
end

-- This work queue will get a chunk per task.
local work_queue = WorkQueue.declare_work_queue({
   name = "fa.scanner.surface-scanner",
   per_tick = 2,
   worker_function = scan_chunk,
   idle_function = redispatch,
})

---@param event EventData.on_entity_destroyed
function mod.on_entity_destroyed(event)
   for _, s in pairs(surface_state) do
      if s.seen_entities:remove(event.registration_number) then
         local b = s.backends

         for _, b in pairs(b.lut) do
            b:on_entity_destroyed(event)
         end

         for _, b in pairs(b.name_lut) do
            b:on_entity_destroyed(event)
         end
      end
   end
end

---@param ent LuaEntity
function mod.on_new_entity(surface_index, ent)
   if not ent.valid then return end

   local state = surface_state[surface_index]
   local dest_req = script.register_on_entity_destroyed(ent)

   if state.seen_entities:test(dest_req) then return end
   state.seen_entities:set(dest_req)

   dispatch_entities(state.backends, { ent })
end

---@param surface_index number
---@param player LuaPlayer
---@param callback fun(fa.scanner.ScanEntry)
---@returns table<fa.scanner.ScanEntry, true>
function mod.get_entries_snapshot(surface_index, player, callback)
   local state = surface_state[surface_index]

   -- Important to only ask backends once each.
   local checked_backends = {}

   local backends = state.backends

   for proto, backend in pairs(backends.lut) do
      if not checked_backends[backend] then
         checked_backends[backend] = true
         backend:dump_entries_to_callback(player, callback)
      end
   end

   for proto, backend in pairs(backends.name_lut) do
      if not checked_backends[backend] then
         checked_backends[backend] = true
         backend:dump_entries_to_callback(player, callback)
      end
   end

   state.backends.water_backend:dump_entries_to_callback(player, callback)
end

function mod.on_new_surface(index)
   surface_state[index] = new_empty_surface(index)
end

function mod.on_surface_delete(index)
   surface_state[index] = nil
end

return mod
