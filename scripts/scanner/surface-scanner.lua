local AsteroidChunksBackend = require("scripts.scanner.backends.asteroid-chunks")
local Functools = require("scripts.functools")
local Memosort = require("scripts.memosort")
local ResourcePatchesBackend = require("scripts.scanner.backends.resource-patches")
local StorageManager = require("scripts.storage-manager")
-- This is typed around 100 times and only used for the LUT, so we will shorten
-- it.
local SparseBitset = require("ds.sparse-bitset")
local SEB = require("scripts.scanner.backends.single-entity")
local TreeBackend = require("scripts.scanner.backends.trees")
local TH = require("scripts.table-helpers")
local TileBodiesBackend = require("scripts.scanner.backends.tile-bodies")
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
---@type table<string, fa.scanner.ScannerBackendFactory>
local BACKEND_LUT = {
   ["accumulator"] = SEB.LogisticsAndPower,
   ["agricultural-tower"] = SEB.Production,
   ["ammo-turret"] = SEB.Military,
   ["arithmetic-combinator"] = SEB.LogisticsAndPower,
   ["artillery-flare"] = SEB.Military,
   ["artillery-turret"] = SEB.Military,
   ["artillery-wagon"] = SEB.TrainsNamed,
   ["asteroid"] = SEB.Asteroid,
   ["assembling-machine"] = SEB.CraftingMachine,
   ["asteroid-collector"] = SEB.Production,
   ["beacon"] = SEB.Production,
   ["boiler"] = SEB.LogisticsAndPower,
   ["burner-generator"] = SEB.LogisticsAndPower,
   ["capture-robot"] = SEB.Military,
   ["car"] = SEB.Vehicle,
   ["cargo-bay"] = SEB.LogisticsAndPower,
   ["cargo-landing-pad"] = SEB.LogisticsAndPower,
   ["cargo-pod"] = SEB.Other,
   ["cargo-wagon"] = SEB.TrainsNamed,
   ["character-corpse"] = SEB.Other,
   ["character"] = SEB.Character,
   ["cliff"] = SEB.Terrain,
   ["combat-robot"] = SEB.Military,
   ["constant-combinator"] = SEB.LogisticsAndPower,
   ["construction-robot"] = SEB.LogisticsAndPower,
   ["container"] = SEB.Containers,
   ["corpse"] = SEB.Corpses,
   ["curved-rail-a"] = SEB.TrainsSimple,
   ["curved-rail-b"] = SEB.TrainsSimple,
   ["decider-combinator"] = SEB.LogisticsAndPower,
   ["display-panel"] = SEB.LogisticsAndPower,
   ["electric-energy-interface"] = SEB.LogisticsAndPower,
   ["electric-pole"] = SEB.LogisticsAndPower,
   ["electric-turret"] = SEB.Military,
   ["elevated-curved-rail-a"] = SEB.TrainsSimple,
   ["elevated-curved-rail-b"] = SEB.TrainsSimple,
   ["elevated-half-diagonal-rail"] = SEB.TrainsSimple,
   ["elevated-straight-rail"] = SEB.TrainsSimple,
   ["entity-ghost"] = SEB.Ghosts,
   ["fire"] = SEB.Other,
   ["fish"] = SEB.Other,
   ["flame-thrower-explosion"] = SEB.Other,
   ["fluid-turret"] = SEB.Military,
   ["fluid-wagon"] = SEB.TrainsNamed,
   ["furnace"] = SEB.Furnace,
   ["fusion-generator"] = SEB.LogisticsAndPower,
   ["fusion-reactor"] = SEB.LogisticsAndPower,
   ["gate"] = SEB.Military,
   ["generator"] = SEB.LogisticsAndPower,
   ["half-diagonal-rail"] = SEB.TrainsSimple,
   ["heat-interface"] = SEB.LogisticsAndPower,
   ["heat-pipe"] = SEB.LogisticsAndPower,
   ["infinity-cargo-wagon"] = SEB.TrainsNamed,
   ["infinity-container"] = SEB.Containers,
   ["infinity-pipe"] = SEB.LogisticsWithFluid,
   ["inserter"] = SEB.LogisticsAndPower,
   ["item-entity"] = SEB.Other,
   ["lab"] = SEB.Production,
   ["lamp"] = SEB.LogisticsAndPower,
   ["lane-splitter"] = SEB.LogisticsAndPower,
   ["legacy-curved-rail"] = SEB.TrainsSimple,
   ["legacy-straight-rail"] = SEB.TrainsSimple,
   ["land-mine"] = SEB.Military,
   ["linked-belt"] = SEB.LogisticsAndPower,
   ["lightning-attractor"] = SEB.LogisticsAndPower,
   ["linked-container"] = SEB.LogisticsAndPower,
   ["loader-1x1"] = SEB.LogisticsAndPower,
   ["loader"] = SEB.LogisticsAndPower,
   ["locomotive"] = SEB.TrainsNamed,
   ["logistic-container"] = SEB.Containers,
   ["logistic-robot"] = SEB.LogisticsAndPower,
   ["market"] = SEB.LogisticsAndPower,
   ["mining-drill"] = SEB.MiningDrill,
   ["offshore-pump"] = SEB.Production,
   ["pipe-to-ground"] = SEB.LogisticsWithFluid,
   ["pipe"] = SEB.Pipe,
   ["plant"] = TreeBackend.TreeBackend,
   ["player-port"] = SEB.Other,
   ["power-switch"] = SEB.LogisticsAndPower,
   ["programmable-speaker"] = SEB.LogisticsAndPower,
   ["projectile"] = SEB.Other,
   ["proxy-container"] = SEB.LogisticsAndPower,
   ["pump"] = SEB.LogisticsAndPower,
   ["radar"] = SEB.Military,
   ["rail-chain-signal"] = SEB.TrainsSimple,
   ["rail-ramp"] = SEB.TrainsSimple,
   ["rail-remnants"] = SEB.Remnants,
   ["rail-signal"] = SEB.TrainsSimple,
   ["rail-support"] = SEB.TrainsSimple,
   ["reactor"] = SEB.LogisticsAndPower,
   ["resource"] = ResourcePatchesBackend.ResourcePatchesBackend,
   ["roboport"] = SEB.Roboport,
   ["rocket-silo-rocket-shadow"] = SEB.Other,
   ["rocket-silo-rocket"] = SEB.Other,
   ["rocket-silo"] = SEB.Production,
   ["selector-combinator"] = SEB.LogisticsAndPower,
   ["simple-entity-with-force"] = SEB.Other,
   ["simple-entity-with-owner"] = SEB.Other,
   ["simple-entity"] = SEB.Other,
   ["solar-panel"] = SEB.LogisticsAndPower,
   ["space-platform-hub"] = SEB.LogisticsAndPower,
   ["spider-vehicle"] = SEB.Spidertron,
   ["splitter"] = SEB.LogisticsAndPower,
   ["storage-tank"] = SEB.LogisticsWithFluid,
   ["straight-rail"] = SEB.TrainsSimple,
   ["temporary-container"] = SEB.Containers,
   ["thruster"] = SEB.LogisticsAndPower,
   ["tile-ghost"] = SEB.Ghosts,
   ["train-stop"] = SEB.TrainsSimple,
   ["transport-belt"] = SEB.LogisticsAndPower,
   ["tree"] = TreeBackend.TreeBackend,
   ["turret"] = SEB.Unit,
   ["underground-belt"] = SEB.LogisticsAndPower,
   ["unit-spawner"] = SEB.Spawner,
   ["unit"] = SEB.Unit,
   ["valve"] = SEB.LogisticsWithFluid,
   ["wall"] = SEB.Military,
}

---@type fun(): table<string, fa.scanner.ScannerBackendFactory>
local BACKEND_NAME_OVERRIDES = Functools.cached(function()
   local bno = {}

   -- All our kinds of rocks, and the other natural things mined for what they drop: Space Age's chimneys,
   -- stromatolites, fulgorite, lithium ice and Fulgoran ruins (the attractor among them).
   TH.merge_mappings(bno, {
      ["big-fulgora-rock"] = SEB.Rock,
      ["big-rock"] = SEB.Rock,
      ["big-sand-rock"] = SEB.Rock,
      ["big-volcanic-rock-hot"] = SEB.Rock,
      ["big-volcanic-rock"] = SEB.Rock,
      ["copper-stromatolite"] = SEB.Rock,
      ["fulgora-sunk-ruin-big"] = SEB.Rock,
      ["fulgora-sunk-ruin-medium-tall"] = SEB.Rock,
      ["fulgoran-ruin-attractor"] = SEB.Rock,
      ["fulgoran-ruin-big"] = SEB.Rock,
      ["fulgoran-ruin-colossal"] = SEB.Rock,
      ["fulgoran-ruin-huge"] = SEB.Rock,
      ["fulgoran-ruin-medium"] = SEB.Rock,
      ["fulgoran-ruin-small"] = SEB.Rock,
      ["fulgoran-ruin-stonehenge"] = SEB.Rock,
      ["fulgoran-ruin-vault"] = SEB.Rock,
      ["fulgurite-small"] = SEB.Rock,
      ["fulgurite"] = SEB.Rock,
      ["huge-rock"] = SEB.Rock,
      ["huge-volcanic-rock-hot"] = SEB.Rock,
      ["huge-volcanic-rock"] = SEB.Rock,
      ["iron-stromatolite"] = SEB.Rock,
      ["lithium-iceberg-big"] = SEB.Rock,
      ["lithium-iceberg-huge"] = SEB.Rock,
      ["medium-rock"] = SEB.Rock,
      ["medium-sand-rock"] = SEB.Rock,
      ["small-rock"] = SEB.Rock,
      ["small-sand-rock"] = SEB.Rock,
      ["tiny-rock"] = SEB.Rock,
      ["vulcanus-chimney-cold"] = SEB.Rock,
      ["vulcanus-chimney-faded"] = SEB.Rock,
      ["vulcanus-chimney-short"] = SEB.Rock,
      ["vulcanus-chimney-truncated"] = SEB.Rock,
      ["vulcanus-chimney"] = SEB.Rock,
   })

   -- remnants
   for proto in pairs(prototypes.entity) do
      if proto:match("-remnants$") then bno[proto] = SEB.Remnants end
   end

   return bno
end)
---@class fa.scanner.SurfaceBackends
---@field lut table<string, fa.scanner.ScannerBackend?> By prototype type
---@field name_lut table<string, fa.scanner.ScannerBackend?> By prototype name, checked first
---@field entity_backends fa.scanner.ScannerBackend[] Each backend of lut and name_lut once
---@field tile_bodies_backend fa.scanner.TileBodiesBackend
---@field tree_backend fa.scanner.backends.TreeBackend Also in lut, for trees and plants
---@field asteroid_chunks_backend fa.scanner.AsteroidChunksBackend

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

   for name, backend in pairs(BACKEND_NAME_OVERRIDES()) do
      local b = instantiated[backend] or backend.new(surface)
      instantiated[backend] = b
      name_lut[name] = b
   end

   local entity_backends = {}
   for _, b in pairs(instantiated) do
      table.insert(entity_backends, b)
   end

   return {
      lut = lut,
      name_lut = name_lut,
      entity_backends = entity_backends,
      tile_bodies_backend = TileBodiesBackend.TileBodiesBackend.new(surface),
      tree_backend = lut["tree"] --[[@as fa.scanner.backends.TreeBackend]],
      asteroid_chunks_backend = AsteroidChunksBackend.AsteroidChunksBackend.new(surface),
   }
end

---@class fa.scanner.GlobalSurfaceState
---@field backends fa.scanner.SurfaceBackends
---@field seen_entities fa.ds.SparseBitset
---@field seen_chunks table<number, table<number, true>>
---@field resource_counts table<number, table<number, integer>> Resources in each chunk at its last read

---@return fa.scanner.GlobalSurfaceState
local function new_empty_surface(key)
   local surf = game.get_surface(key)
   assert(surf)

   ---@type fa.scanner.GlobalSurfaceState
   local ret = {
      backends = instantiate_backends(surf),
      seen_entities = SparseBitset.SparseBitset.new(),
      seen_chunks = TH.defaulting_table(),
      resource_counts = TH.defaulting_table(),
   }

   return ret
end

---@type table<number, fa.scanner.GlobalSurfaceState>
local surface_state = StorageManager.declare_storage_module(
   "scanner",
   new_empty_surface,
   { root_field = "surfaces", ephemeral_state_version = 19 }
)

-- Code outside the scanner told of each new entity of some types, by type. See add_new_entity_listener.
---@type table<string, fun(entity: LuaEntity)[]?>
local new_entity_listeners = {}

---Call `listener` with each entity of these types the scanner finds, once per entity: when it is built, or when its
---chunk is first scanned. Entities already found before a listener existed are not passed to it. Call at file top
---level.
---@param types string[]
---@param listener fun(entity: LuaEntity)
function mod.add_new_entity_listener(types, listener)
   for _, t in ipairs(types) do
      new_entity_listeners[t] = new_entity_listeners[t] or {}
      table.insert(new_entity_listeners[t], listener)
   end
end

-- Given a backend setup and an array of entities, dispatch the entities to the
-- backends.  Assumes the entities are valid.
---@param backends fa.scanner.SurfaceBackends
---@param ents LuaEntity[]
local function dispatch_entities(backends, ents)
   for i = 1, #ents do
      local e = ents[i]

      local t = e.type
      local listeners = new_entity_listeners[t]
      if listeners then
         for _, listener in ipairs(listeners) do
            listener(e)
         end
      end

      if backends.name_lut[e.name] then
         backends.name_lut[e.name]:on_new_entity(e)
      elseif backends.lut[t] then
         backends.lut[t]:on_new_entity(e)
      end
   end
end

-- The entity types worth finding when scanning a chunk: every type a backend wants, and the types of the
-- prototypes named in the name overrides. Trees and plants are counted by the tree backend instead, and resources
-- are read on a chunk's first scan and again only when their count goes up.
---@type fun(): string[]
local scanned_types = Functools.cached(function()
   local wanted = {}
   for t in pairs(BACKEND_LUT) do
      wanted[t] = true
   end
   for name in pairs(BACKEND_NAME_OVERRIDES()) do
      -- Absent when the mod that adds it is not loaded.
      local proto = prototypes.entity[name] --[[@as LuaEntityPrototype?]]
      if proto then wanted[proto.type] = true end
   end
   wanted["tree"], wanted["plant"], wanted["resource"] = nil, nil, nil

   -- Only types this game has: an unknown type name in a filter is an error.
   local exists = {}
   for _, proto in pairs(prototypes.entity) do
      exists[proto.type] = true
   end
   local out = {}
   for t in pairs(wanted) do
      if exists[t] then table.insert(out, t) end
   end
   table.sort(out)
   return out
end)

-- Register entities and dispatch the ones not seen before. Assumes they are valid.
---@param state fa.scanner.GlobalSurfaceState
---@param ents LuaEntity[]
---@param cx integer
---@param cy integer
local function dispatch_unseen(state, ents, cx, cy)
   TH.retain_unordered(ents, function(item)
      local dest_req = script.register_on_object_destroyed(item)
      if state.seen_entities:test(dest_req) then return false end
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
end

---@param surf LuaSurface
---@param cx integer
---@param cy integer
local function scan_chunk(surf, cx, cy)
   local state = surface_state[surf.index]
   local area = {
      left_top = { x = cx * CHUNK_SIZE, y = cy * CHUNK_SIZE },
      right_bottom = { x = (cx + 1) * CHUNK_SIZE, y = (cy + 1) * CHUNK_SIZE },
   }
   local chunk = { x = cx, y = cy, area = area }
   local first = not state.seen_chunks[cx][cy]

   dispatch_unseen(state, surf.find_entities_filtered({ area = area, type = scanned_types() }), cx, cy)

   -- Resources: all of them the first time, then only when more appeared (a script placing ore). Fewer is just
   -- mining, which the destroyed events already cover.
   local known = state.resource_counts[cx][cy] or 0
   local resource_count = first and 0 or surf.count_entities_filtered({ area = area, type = "resource" })
   if first or resource_count > known then
      local resources = surf.find_entities_filtered({ area = area, type = "resource" })
      resource_count = #resources
      dispatch_unseen(state, resources, cx, cy)
   end
   state.resource_counts[cx][cy] = resource_count

   if first then
      state.seen_chunks[cx][cy] = true
      state.backends.tile_bodies_backend:on_new_chunk(chunk)
   else
      state.backends.tile_bodies_backend:on_chunk_rescanned(chunk)
   end
   state.backends.tree_backend:on_chunk_scanned(chunk)
end

---@class fa.scanner.NewChunkScan
---@field s integer Surface index
---@field x integer
---@field y integer

-- Chunks never scanned, 4 a tick, so a new game or a newly loaded save fills in quickly.
---@param item fa.scanner.NewChunkScan
local function scan_new_chunk(item)
   local surf = game.get_surface(item.s)
   if surf then scan_chunk(surf, item.x, item.y) end
end

local new_chunk_queue = WorkQueue.declare_work_queue({
   name = "fa.scanner.new-chunks",
   per_tick = 4,
   worker_function = scan_new_chunk,
})

---@class fa.scanner.RescanPass
---@field s integer Surface index
---@field coords integer[] Chunk x, y pairs, nearest the players first
---@field i integer Index of the next pair's x

-- Chunks per tick in the background rescan.
local RESCAN_PER_TICK = 2

---@type fa.WorkQueueHandle
local rescan_queue

-- The background rescan: entities that mods create without raising an event are only found this way (ones they
-- destroy raise on_object_destroyed). One pass item per surface, taking turns a tick at a time.
---@param item fa.scanner.RescanPass
local function rescan_step(item)
   local surf = game.get_surface(item.s)
   if not surf then return end
   local coords = item.coords
   local stop = math.min(item.i + 2 * RESCAN_PER_TICK, #coords + 1)
   for i = item.i, stop - 1, 2 do
      scan_chunk(surf, coords[i], coords[i + 1])
   end
   item.i = stop
   if stop <= #coords then rescan_queue:enqueue(item) end
end

---@param list integer[][] Chunk positions as { x, y }
---@param players { x: number, y: number }[]
local function sort_by_distance(list, players)
   if not next(players) then return end
   Memosort.memosort(list, function(c)
      local x, y = c[1] * CHUNK_SIZE, c[2] * CHUNK_SIZE
      local best = math.huge
      for _, p in ipairs(players) do
         local d = (x - p.x) ^ 2 + (y - p.y) ^ 2
         if d < best then best = d end
      end
      return best
   end)
end

-- Start a new pass: chunks never scanned go to the new-chunk queue, the rest become one pass item per surface.
-- Both are sorted by distance to the nearest connected player on the surface.
---@param queue fa.WorkQueueHandle
local function redispatch(queue)
   -- The queue before this one stored a table per chunk; drop what a save still holds of it.
   storage.work_queues["fa.scanner.surface-scanner"] = nil

   for _, s in pairs(game.surfaces) do
      local state = surface_state[s.index]
      local players = {}
      for _, p in pairs(game.connected_players) do
         if p.surface_index == s.index then
            local pos = p.position
            table.insert(players, { x = pos.x, y = pos.y })
         end
      end

      local fresh, seen = {}, {}
      for c in s.get_chunks() do
         table.insert(state.seen_chunks[c.x][c.y] and seen or fresh, { c.x, c.y })
      end
      sort_by_distance(fresh, players)
      sort_by_distance(seen, players)

      for _, c in ipairs(fresh) do
         new_chunk_queue:enqueue({ s = s.index, x = c[1], y = c[2] })
      end
      if next(seen) then
         local coords = {}
         for _, c in ipairs(seen) do
            coords[#coords + 1] = c[1]
            coords[#coords + 1] = c[2]
         end
         queue:enqueue({ s = s.index, coords = coords, i = 1 })
      end
   end
end

rescan_queue = WorkQueue.declare_work_queue({
   name = "fa.scanner.rescan",
   per_tick = 1,
   worker_function = rescan_step,
   idle_function = redispatch,
})

---@param surface_index integer
---@param position ChunkPosition
function mod.on_chunk_generated(surface_index, position)
   new_chunk_queue:enqueue({ s = surface_index, x = position.x, y = position.y })
end

---@param event EventData.on_object_destroyed
function mod.on_entity_destroyed(event)
   for _, s in pairs(surface_state) do
      if s.seen_entities:remove(event.registration_number) then
         for _, b in ipairs(s.backends.entity_backends) do
            b:on_entity_destroyed(event)
         end
      end
   end
end

---@param ent LuaEntity
function mod.on_new_entity(surface_index, ent)
   if not ent.valid then return end

   local state = surface_state[surface_index]
   local dest_req = script.register_on_object_destroyed(ent)

   if state.seen_entities:test(dest_req) then return end
   state.seen_entities:set(dest_req)

   dispatch_entities(state.backends, { ent })
end

-- Tiles changed on a surface (built, mined, or set by a script that said so).
---@param surface_index integer
---@param positions MapPosition[]
function mod.on_tiles_changed(surface_index, positions)
   surface_state[surface_index].backends.tile_bodies_backend:on_tiles_changed(positions)
end

---@param surface_index integer
---@param player LuaPlayer
---@param callback fun(entry: fa.scanner.ScanEntry)
---@param wanted (fun(x: number, y: number): boolean)? See fa.scanner.ScannerBackend.dump_entries_to_callback
function mod.get_entries_snapshot(surface_index, player, callback, wanted)
   local state = surface_state[surface_index]

   for _, backend in ipairs(state.backends.entity_backends) do
      backend:dump_entries_to_callback(player, callback, wanted)
   end

   state.backends.tile_bodies_backend:dump_entries_to_callback(player, callback)
   state.backends.asteroid_chunks_backend:dump_entries_to_callback(player, callback)
end

function mod.on_new_surface(index)
   surface_state[index] = new_empty_surface(index)
end

function mod.on_surface_delete(index)
   surface_state[index] = nil
end

return mod
