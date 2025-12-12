--[[
Grid Sonifier - Framework for grid-based audio events.

This module manages entities within the player's visible area (determined by zoom)
and coordinates backends that emit audio events for various entity activities.

Events are mapped to a grid for deduplication, allowing graceful degradation
at large scales while maintaining precision at close zoom levels.
]]

local GridConsts = require("scripts.sonifiers.grid-consts")
local LauncherAudio = require("scripts.launcher-audio")
local SoundModel = require("scripts.sound-model")
local StorageManager = require("scripts.storage-manager")
local TH = require("scripts.table-helpers")
local Zoom = require("scripts.zoom")

local mod = {}

---@class fa.GridSonifier.Event
---@field x number World X coordinate
---@field y number World Y coordinate
---@field sound_builder fun(id: string, params: fa.SoundModel.DirectionalParams): fa.LauncherAudio.PatchBuilder
---@field deduplication_key string
---@field grid fa.GridSonifier.Grid
---@field unit_number integer

---@class fa.GridSonifier.Backend
---@field on_visible fun(self: fa.GridSonifier.Backend, entity: LuaEntity)
---@field on_vanished fun(self: fa.GridSonifier.Backend, unit_number: integer)
---@field tick fun(self: fa.GridSonifier.Backend, callback: fun(event: fa.GridSonifier.Event))

---@class fa.GridSonifier.State
---@field surface_index integer?
---@field visible_entities table<integer, LuaEntity> Unit number -> entity
---@field backends table<string, fa.GridSonifier.Backend>

---@return fa.GridSonifier.State
local function make_default_state(pindex)
   return {
      surface_index = nil,
      visible_entities = {},
      backends = {},
   }
end

---@type table<integer, fa.GridSonifier.State>
local sonifier_storage = StorageManager.declare_storage_module("grid_sonifier", make_default_state, {
   ephemeral_state_version = 1,
})

---Register a backend for a player
---@param pindex integer
---@param name string
---@param backend fa.GridSonifier.Backend
function mod.register_backend(pindex, name, backend)
   local state = sonifier_storage[pindex]
   state.backends[name] = backend
end

---@class fa.GridSonifier.BackendRegistration
---@field factory fun(): fa.GridSonifier.Backend
---@field entity_types table<string, true>

---Registered backend factories (name -> registration)
---@type table<string, fa.GridSonifier.BackendRegistration>
local backend_registrations = {}

---Combined set of all entity types from all backends
---@type table<string, true>
local all_entity_types = {}

---Array form of all_entity_types for queries
---@type string[]
local entity_types_array = {}

---Register a backend factory that will be used for all players
---@param name string
---@param factory fun(): fa.GridSonifier.Backend
---@param entity_types table<string, true>
function mod.register_backend_factory(name, factory, entity_types)
   backend_registrations[name] = {
      factory = factory,
      entity_types = entity_types,
   }

   -- Rebuild combined entity types
   all_entity_types = {}
   for _, reg in pairs(backend_registrations) do
      for etype, _ in pairs(reg.entity_types) do
         all_entity_types[etype] = true
      end
   end

   -- Rebuild array form
   entity_types_array = {}
   for etype, _ in pairs(all_entity_types) do
      table.insert(entity_types_array, etype)
   end
end

---Ensure all registered backends are initialized for a player
---@param pindex integer
local function ensure_backends_initialized(pindex)
   local state = sonifier_storage[pindex]
   for name, reg in pairs(backend_registrations) do
      if not state.backends[name] then state.backends[name] = reg.factory() end
   end
end

---Map world coordinates to UV coordinates (-1 to 1)
---@param world_x number
---@param world_y number
---@param left number
---@param top number
---@param right number
---@param bottom number
---@return number u
---@return number v
local function world_to_uv(world_x, world_y, left, top, right, bottom)
   local u = 2 * (world_x - left) / (right - left) - 1
   local v = 2 * (world_y - top) / (bottom - top) - 1
   return u, v
end

---Map UV coordinates to grid cell
---@param u number
---@param v number
---@return integer cell_x
---@return integer cell_y
local function uv_to_grid_cell(u, v)
   local grid_size = GridConsts.GRID_SIZE

   -- Clamp to -1..1 and map to 0..grid_size-1
   local clamped_u = math.max(-1, math.min(1, u))
   local clamped_v = math.max(-1, math.min(1, v))

   local cell_x = math.floor((clamped_u + 1) / 2 * grid_size)
   local cell_y = math.floor((clamped_v + 1) / 2 * grid_size)

   -- Clamp to valid range
   cell_x = math.min(cell_x, grid_size - 1)
   cell_y = math.min(cell_y, grid_size - 1)

   return cell_x, cell_y
end

---Build a deduplicated sound ID
---@param cell_x integer
---@param cell_y integer
---@param dedup_key string
---@param index integer
---@param unit_number integer
---@param use_unit_number boolean
---@return string
local function build_sound_id(cell_x, cell_y, dedup_key, index, unit_number, use_unit_number)
   if use_unit_number then
      return string.format("gs-%d-%d-%s-%d", cell_x, cell_y, dedup_key, unit_number)
   else
      return string.format("gs-%d-%d-%s-%d", cell_x, cell_y, dedup_key, index)
   end
end

---Process events and play sounds
---@param pindex integer
---@param events fa.GridSonifier.Event[]
---@param left number
---@param top number
---@param right number
---@param bottom number
local function process_events(pindex, events, left, top, right, bottom)
   -- Get reference position from sound model (cursor or character depending on mode)
   local ref_pos = SoundModel.get_reference_position(pindex)
   local center_x = ref_pos.x
   local center_y = ref_pos.y

   -- Reference distance for attenuation: 1/4 of zoom (half-tiles from center to edge)
   local half_width = (right - left) / 2
   local ref_distance = half_width / 4

   -- Group events by grid cell [cell_x][cell_y][dedup_key] -> event[]
   local cells = TH.defaulting_table()

   for _, event in ipairs(events) do
      local u, v = world_to_uv(event.x, event.y, left, top, right, bottom)
      local cell_x, cell_y = uv_to_grid_cell(u, v)
      local dedup_key = event.deduplication_key

      local by_y = TH.defaulting_table(cells[cell_x])
      cells[cell_x] = by_y
      local by_key = by_y[cell_y]
      if not by_key[dedup_key] then by_key[dedup_key] = {} end
      table.insert(by_key[dedup_key], event)
   end

   -- Process each cell
   local compound = LauncherAudio.compound()
   local has_sounds = false

   for cell_x, by_y in pairs(cells) do
      for cell_y, by_key in pairs(by_y) do
         for dedup_key, cell_events in pairs(by_key) do
            -- Sort by unit number descending (favor newer entities)
            table.sort(cell_events, function(a, b)
               return a.unit_number > b.unit_number
            end)

            local use_unit_number = #cell_events <= GridConsts.EVENTS_PER_CELL_LIMIT

            for i, event in ipairs(cell_events) do
               if not use_unit_number and i > GridConsts.EVENTS_PER_CELL_LIMIT then break end

               local sound_id = build_sound_id(cell_x, cell_y, dedup_key, i, event.unit_number, use_unit_number)

               -- Compute directional params from event position relative to cursor
               local dx = event.x - center_x
               local dy = event.y - center_y
               local params = SoundModel.map_relative_position(dx, dy, ref_distance)

               local builder = event.sound_builder(sound_id, params)
               compound:add(builder)
               has_sounds = true
            end
         end
      end
   end

   if has_sounds then compound:send(pindex) end
end

---Main tick handler - call every tick, internally throttled
---@param pindex integer
function mod.tick(pindex)
   -- Only run every TICK_INTERVAL ticks
   if game.tick % GridConsts.TICK_INTERVAL ~= 0 then return end

   local player = game.get_player(pindex)
   if not player or not player.valid then return end

   -- Ensure backends are initialized
   ensure_backends_initialized(pindex)

   local state = sonifier_storage[pindex]

   -- Check for surface change
   local current_surface_index = player.surface_index
   if state.surface_index ~= current_surface_index then
      -- Surface changed, reset state
      for _, backend in pairs(state.backends) do
         for unit_number, _ in pairs(state.visible_entities) do
            backend:on_vanished(unit_number)
         end
      end
      state.visible_entities = {}
      state.surface_index = current_surface_index
   end

   -- Get visible area
   local area = Zoom.get_search_area(pindex)
   local left, top, right, bottom = area.left, area.top, area.right, area.bottom

   -- Query entities in visible area (single query for all backend types)
   local surface = player.surface
   local current_entities = {}

   local entities = surface.find_entities_filtered({
      area = { { left, top }, { right, bottom } },
      type = entity_types_array,
   })
   for _, entity in ipairs(entities) do
      if entity.valid and entity.unit_number then current_entities[entity.unit_number] = entity end
   end

   -- Determine new and vanished entities
   local new_entities = {}
   local vanished_unit_numbers = {}

   for unit_number, entity in pairs(current_entities) do
      if not state.visible_entities[unit_number] then table.insert(new_entities, entity) end
   end

   for unit_number, _ in pairs(state.visible_entities) do
      if not current_entities[unit_number] then table.insert(vanished_unit_numbers, unit_number) end
   end

   -- Notify backends of visibility changes
   for _, backend in pairs(state.backends) do
      for _, entity in ipairs(new_entities) do
         backend:on_visible(entity)
      end
      for _, unit_number in ipairs(vanished_unit_numbers) do
         backend:on_vanished(unit_number)
      end
   end

   -- Update visible entities
   state.visible_entities = current_entities

   -- Collect events from backends
   ---@type fa.GridSonifier.Event[]
   local all_events = {}

   for _, backend in pairs(state.backends) do
      backend:tick(function(event)
         table.insert(all_events, event)
      end)
   end

   -- Process and play sounds
   if #all_events > 0 then process_events(pindex, all_events, left, top, right, bottom) end
end

---Reset state for a player (e.g., when disabling sonification)
---@param pindex integer
function mod.reset(pindex)
   local state = sonifier_storage[pindex]
   for _, backend in pairs(state.backends) do
      for unit_number, _ in pairs(state.visible_entities) do
         backend:on_vanished(unit_number)
      end
   end
   state.visible_entities = {}
   state.surface_index = nil
end

return mod
