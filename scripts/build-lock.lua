--[[
Build Lock System

Automatically places entities as the player moves (walking or cursor movement).
Uses a backend architecture where different entity types have specialized placement logic.

Key Features:
- Dual-state tracking: Separate state for walking vs cursor movement
- Backend system: Pluggable functions for different entity types
- Entity history: Tracks last 5 placed entities for corner turning, etc.
- Auto-disable: On cursor stack changes, bumps, teleports, etc.
- Extensible: Easy to add new entity-specific behaviors
]]

local StorageManager = require("scripts.storage-manager")
local MovementHistory = require("scripts.movement-history")
local BuildingTools = require("scripts.building-tools")
local Speech = require("scripts.speech")
local Sounds = require("scripts.ui.sounds")
local Logging = require("scripts.logging")
local FaUtils = require("scripts.fa-utils")
local RingBuffer = require("ds.fixed-ringbuffer")
local Viewpoint = require("scripts.viewpoint")

local logger = Logging.Logger("build-lock")

---@class BuildLock
local BuildLock = {}

-- Prototype cache for O(1) lookups
---@type table<string, {can_handle: function, backend: fa.BuildLock.Backend?}>
local prototype_cache = {}

---@class fa.BuildLock.PlacedEntity
---@field entity LuaEntity The placed entity (may become invalid)
---@field position MapPosition Position where it was placed
---@field direction defines.direction Direction it was placed
---@field name string Entity name

---@class fa.BuildLock.BuildState
---@field entity_history fa.ds.FixedRingBuffer of fa.BuildLock.PlacedEntity
---@field placed_entity_units table<number, true> Set of all placed entity unit_numbers for O(1) collision checks
---@field backend_state table? Backend-specific state
---@field last_floored_position {x: number, y: number}? Last tile position checked (for walking)
---@field pending_tiles {x: number, y: number}[] Queue of tiles to build on (for walking)

-- Constructor for build state
local function create_build_state()
   return {
      entity_history = RingBuffer.new(5),
      placed_entity_units = {},
      backend_state = nil,
      last_floored_position = nil,
      pending_tiles = {},
   }
end

---@class fa.BuildLock.State
---@field enabled boolean
---@field walking_state fa.BuildLock.BuildState
---@field cursor_state fa.BuildLock.BuildState
---@field last_cursor_stack_name string?
---@field last_cursor_stack_count number?
---@field last_cursor_stack_quality string?
---@field last_movement_generation number?

---@type table<number, fa.BuildLock.State>
local build_lock_storage = StorageManager.declare_storage_module("build_lock", function()
   return {
      enabled = false,
      walking_state = create_build_state(),
      cursor_state = create_build_state(),
      last_cursor_stack_name = nil,
      last_cursor_stack_count = nil,
      last_cursor_stack_quality = nil,
      last_movement_generation = nil,
   }
end)

-- Backend registry
local backends = {}

---@class fa.BuildLock.Backend
---@field name string
---@field can_handle fun(item_prototype: LuaItemPrototype): boolean
---@field select_tile_to_build? fun(pending_tiles: table, max_count: number, context: fa.BuildLock.BuildContext, helpers: fa.BuildLock.BuildHelpers): {action: string, tile_index: number}? Optional: select which tile from queue to build at (if not provided, uses default forward scan)
---@field build fun(context: fa.BuildLock.BuildContext, helpers: fa.BuildLock.BuildHelpers): string Returns BuildAction constant

---@class fa.BuildLock.BuildContext
---@field pindex number
---@field player LuaPlayer
---@field item_prototype LuaItemPrototype
---@field item_quality LuaQualityPrototype?
---@field entity_prototype LuaEntityPrototype
---@field current_position MapPosition
---@field movement_direction defines.direction
---@field building_direction defines.direction
---@field entity_history fa.ds.FixedRingBuffer of fa.BuildLock.PlacedEntity
---@field backend_state table?

---Registers a build lock backend
---@param backend fa.BuildLock.Backend
function BuildLock.register_backend(backend)
   assert(backend.name, "Backend must have a name")
   assert(backend.can_handle, "Backend must have can_handle function")
   assert(backend.build, "Backend must have build function")
   table.insert(backends, backend)
   logger:debug("Registered backend: " .. backend.name)
end

---Finds the appropriate backend for an item prototype (with caching)
---@param item_prototype LuaItemPrototype
---@return fa.BuildLock.Backend?
local function find_backend(item_prototype)
   local cached = prototype_cache[item_prototype.name]
   if cached then return cached.backend end

   for _, backend in ipairs(backends) do
      if backend.can_handle(item_prototype) then
         logger:debug("Found backend: " .. backend.name .. " for item: " .. item_prototype.name)
         prototype_cache[item_prototype.name] = { backend = backend }
         return backend
      end
   end

   -- Cache negative result
   prototype_cache[item_prototype.name] = { backend = nil }
   return nil
end

---Checks if build lock should be disabled due to cursor stack changes
---@param pindex number
---@return boolean should_disable
---@return string? reason Locale key for the reason
local function check_cursor_stack_changes(pindex)
   local player = game.get_player(pindex)
   if not player then return true, "no player" end

   local stack = player.cursor_stack
   local state = build_lock_storage[pindex]

   -- Check if stack is valid
   if not stack or not stack.valid_for_read then
      if state.last_cursor_stack_name then return true, "fa.build-lock-reason-cursor-empty" end
      return false
   end

   -- Check if item changed
   if state.last_cursor_stack_name and state.last_cursor_stack_name ~= stack.name then
      return true, "fa.build-lock-reason-cursor-changed"
   end

   -- Check if quality changed (Factorio 2.0)
   local quality_name = stack.quality and stack.quality.name or "normal"
   if state.last_cursor_stack_quality and state.last_cursor_stack_quality ~= quality_name then
      return true, "fa.build-lock-reason-quality-changed"
   end

   -- Check if count reached zero
   if stack.count == 0 then return true, "fa.build-lock-reason-count-zero" end

   -- Update tracking
   state.last_cursor_stack_name = stack.name
   state.last_cursor_stack_count = stack.count
   state.last_cursor_stack_quality = quality_name

   return false
end

---Checks if build lock should be disabled due to movement discontinuity
---@param pindex number
---@return boolean should_disable
---@return string? reason Locale key for the reason
local function check_movement_discontinuity(pindex)
   local reader = MovementHistory.get_movement_history_reader(pindex)
   local state = build_lock_storage[pindex]

   local current_generation = reader:get_generation()

   if state.last_movement_generation and state.last_movement_generation ~= current_generation then
      return true, "fa.build-lock-reason-teleport"
   end

   state.last_movement_generation = current_generation
   return false
end

---Checks if the item in hand is buildable with build lock
---@param pindex number
---@return boolean is_buildable
---@return string? error_message
local function check_item_buildable(pindex)
   local player = game.get_player(pindex)
   if not player then return false, "no player" end

   local stack = player.cursor_stack
   if not stack or not stack.valid_for_read then return false, "no item in hand" end

   -- Blueprints are not supported
   if stack.is_blueprint or stack.is_blueprint_book or stack.is_upgrade_item or stack.is_deconstruction_item then
      return false, "blueprints and deconstruction tools not supported"
   end

   -- Must have a place result (entity or tile)
   if not stack.prototype.place_result and not stack.prototype.place_as_tile_result then
      return false, "item not placeable"
   end

   return true
end

---Enables or disables build lock for a player
---@param pindex number
---@param enabled boolean
---@param silent boolean? Don't play sound or speak
---@param reason string? Optional locale key for disabling reason (only used when enabled=false and silent=false)
function BuildLock.set_enabled(pindex, enabled, silent, reason)
   local state = build_lock_storage[pindex]
   local player = game.get_player(pindex)
   if not player then return end

   if enabled then
      -- Check if item is buildable
      local buildable, error_msg = check_item_buildable(pindex)
      if not buildable then
         if not silent then Speech.speak(pindex, { "fa.build-lock-cannot-enable", error_msg or "unknown error" }) end
         return
      end

      -- Reset state using constructor
      state.enabled = true
      state.walking_state = create_build_state()
      state.cursor_state = create_build_state()

      -- Initialize walking state with current position
      -- Add current tile to queue so first pole places where build lock was enabled
      if player.character then
         local current_tile = {
            x = math.floor(player.character.position.x),
            y = math.floor(player.character.position.y),
         }
         state.walking_state.last_floored_position = current_tile
         -- Add current tile as first tile in queue with no direction (will be determined on placement)
         table.insert(state.walking_state.pending_tiles, {
            x = current_tile.x,
            y = current_tile.y,
            direction = defines.direction.north, -- Placeholder, backend will handle
         })
      end

      state.last_cursor_stack_name = player.cursor_stack and player.cursor_stack.name or nil
      state.last_cursor_stack_count = player.cursor_stack and player.cursor_stack.count or nil
      state.last_cursor_stack_quality = (
         player.cursor_stack and player.cursor_stack.quality and player.cursor_stack.quality.name or "normal"
      )
      state.last_movement_generation = MovementHistory.get_movement_history_reader(pindex):get_generation()

      if not silent then Speech.speak(pindex, { "fa.build-lock-enabled" }) end
   else
      state.enabled = false
      if not silent then
         -- Play error sound when disabling due to an error condition
         if reason then
            Sounds.play_cannot_build(pindex)
            Speech.speak(pindex, { "fa.build-lock-disabled-reason", { reason } })
         else
            Speech.speak(pindex, { "fa.build-lock-disabled" })
         end
      end
   end
end

---Toggles build lock for a player
---@param pindex number
function BuildLock.toggle(pindex)
   local state = build_lock_storage[pindex]
   BuildLock.set_enabled(pindex, not state.enabled, false)
end

---Checks if build lock is enabled for a player
---@param pindex number
---@return boolean
function BuildLock.is_enabled(pindex)
   return build_lock_storage[pindex].enabled
end

---Get the last placed entity from history (most recent)
---@param entity_history fa.ds.FixedRingBuffer
---@return fa.BuildLock.PlacedEntity?
local function get_last_placed_entity(entity_history)
   return entity_history:get(0)
end

---Calculate direction from one tile to another (4-way: N/S/E/W)
---@param from {x: number, y: number}
---@param to {x: number, y: number}
---@return defines.direction
local function direction_between_tiles(from, to)
   local dx = to.x - from.x
   local dy = to.y - from.y

   -- Prioritize the axis with larger movement
   if math.abs(dx) > math.abs(dy) then
      return dx > 0 and defines.direction.east or defines.direction.west
   else
      return dy > 0 and defines.direction.south or defines.direction.north
   end
end

---Generate L-shaped path between two tile positions (floors both positions)
---Each tile includes the direction to reach it from the previous tile
---Includes 'to' but excludes 'from' (path of tiles traversed FROM from TO to)
---@param from {x: number, y: number}
---@param to {x: number, y: number}
---@return {x: number, y: number, direction: defines.direction}[] tiles Ordered list of tiles with directions
local function generate_tile_path(from, to)
   local from_x = math.floor(from.x)
   local from_y = math.floor(from.y)
   local to_x = math.floor(to.x)
   local to_y = math.floor(to.y)

   -- If same tile, no path needed
   if from_x == to_x and from_y == to_y then return {} end

   local path = {}
   local prev_tile = { x = from_x, y = from_y }

   -- Move horizontally first
   local step_x = from_x < to_x and 1 or -1
   for x = from_x + step_x, to_x, step_x do
      local tile = { x = x, y = from_y }
      tile.direction = direction_between_tiles(prev_tile, tile)
      table.insert(path, tile)
      prev_tile = tile
   end

   -- Then move vertically
   local step_y = from_y < to_y and 1 or -1
   for y = from_y + step_y, to_y, step_y do
      local tile = { x = to_x, y = y }
      tile.direction = direction_between_tiles(prev_tile, tile)
      table.insert(path, tile)
      prev_tile = tile
   end

   return path
end

---Build action constants for backend return values
---@class fa.BuildLock.BuildAction
BuildLock.BuildAction = {
   ---Successfully placed entity, advance queue normally
   PLACED = "placed",
   ---Failed to place but should advance queue (e.g., out of range for poles)
   SKIP = "skip",
   ---Failed to place, keep tile in queue for retry (e.g., blocked temporarily)
   RETRY = "retry",
   ---Failed permanently, disable build lock entirely
   FAIL = "fail",
}
local BuildAction = BuildLock.BuildAction

---@class fa.BuildLock.BuildHelpers
---@field pindex number
---@field build_state fa.BuildLock.BuildState
---@field player LuaPlayer
---@field stack LuaItemStack
---@field entity_prototype LuaEntityPrototype
---@field fail_reason string? Locale key for why build lock should fail
local BuildHelpers = {}
local BuildHelpers_meta = { __index = BuildHelpers }

---Check if build failure should suppress error sound
---Returns true if blocked by our own placed entity or by the player character
---@param position MapPosition
---@param entity_prototype LuaEntityPrototype
---@param direction defines.direction
---@return boolean should_suppress_error
function BuildHelpers:is_blocked_by_own_entity(position, entity_prototype, direction)
   -- Calculate bounding box for the attempted build
   local footprint = FaUtils.calculate_building_footprint({
      entity_prototype = entity_prototype,
      position = position,
      building_direction = direction,
      player_direction = direction,
      is_rail_vehicle = false,
   })

   -- Find all entities in the build area
   local entities = self.player.surface.find_entities_filtered({
      area = { footprint.left_top, footprint.right_bottom },
   })

   -- Check each blocking entity
   for _, entity in ipairs(entities) do
      if entity.valid then
         -- Check if it's the player character
         if entity.type == "character" and entity == self.player.character then return true end

         -- Check if it's any entity we've placed (O(1) lookup)
         if entity.unit_number and self.build_state.placed_entity_units[entity.unit_number] then return true end
      end
   end

   return false
end

---Set the failure reason for build lock (causes FAIL action to disable build lock)
---@param reason string Locale key for the failure reason
function BuildHelpers:set_fail_reason(reason)
   self.fail_reason = reason
end

---Build an entity at the specified position and direction
---@param position MapPosition
---@param direction defines.direction
---@return LuaEntity? placed_entity The placed entity, or nil if placement failed
function BuildHelpers:build_entity(position, direction)
   local pindex = self.pindex
   local build_state = self.build_state
   local player = self.player
   local stack = self.stack
   local entity_prototype = self.entity_prototype
   logger:debug(string.format("Building at (%.1f,%.1f) with dir=%d", position.x, position.y, direction))

   -- Temporarily update cursor to build position
   local vp = Viewpoint.get_viewpoint(pindex)
   local old_cursor_pos = vp:get_cursor_pos()
   vp:set_cursor_pos({ x = position.x, y = position.y })

   -- Use BuildingTools to place the entity with explicit direction
   -- Disable player teleport and let build lock handle error sounds
   local old_item_count = stack.count
   BuildingTools.build_item_in_hand_with_params({
      pindex = pindex,
      building_direction = direction,
      teleport_player = false,
      play_error_sound = false,
      speak_errors = false,
   })
   local new_item_count = stack.valid_for_read and stack.count or 0

   -- Restore cursor position
   vp:set_cursor_pos(old_cursor_pos)

   -- Check if entity was actually placed
   local placed = new_item_count < old_item_count
   if not placed then
      -- Check if blocked by our own entity before playing error sound
      if not self:is_blocked_by_own_entity(position, entity_prototype, direction) then
         player.play_sound({ path = "utility/cannot_build" })
      end
      return nil
   end

   logger:debug("Entity placed successfully")
   -- Find the placed entity
   local placed_entity = player.surface.find_entity(entity_prototype.name, FaUtils.center_of_tile(position))

   if placed_entity and placed_entity.valid then
      logger:debug(string.format("Found placed entity: %s at dir=%d", placed_entity.name, placed_entity.direction))
      -- Record in history - use the ACTUAL direction from the placed entity
      build_state.entity_history:push({
         entity = placed_entity,
         position = position,
         direction = placed_entity.direction,
         name = entity_prototype.name,
      })
      -- Add to collision check set
      if placed_entity.unit_number then build_state.placed_entity_units[placed_entity.unit_number] = true end
      logger:debug(string.format("Added to history at index 0: dir=%d", placed_entity.direction))
      return placed_entity
   else
      logger:warn("Could not find placed entity")
      return nil
   end
end

---Default tile selection: forward scan to find first non-current tile
---@param pending_tiles table Array of pending tiles with x, y, direction fields
---@param max_count number Consider tiles 1..max_count
---@param current_tile_pos {x: number, y: number} Current tile position (floored)
---@return {action: string, tile_index: number}? Returns nil if no tile can be selected
function BuildHelpers:select_tile_to_build_default(pending_tiles, max_count, current_tile_pos)
   -- Forward scan: return first tile that's not current position
   for i = 1, max_count do
      if i > #pending_tiles then break end
      local tile = pending_tiles[i]
      if tile.x ~= current_tile_pos.x or tile.y ~= current_tile_pos.y then
         return { action = BuildAction.PLACED, tile_index = i }
      end
   end
   return nil
end

---Attempts to build from a queue of pending tiles using two-phase approach
---Phase 1: Select which tile to attempt (backend or default)
---Phase 2: Build at selected tile (backend)
---@param pindex number
---@param build_state fa.BuildLock.BuildState
---@param pending_tiles table Array of pending tiles
---@param max_count number Maximum number of tiles to consider
---@param current_tile_pos {x: number, y: number} Current tile position (floored)
---@return {action: string, tile_index: number}? Returns nil if nothing can be built, otherwise action and which tile was used
local function attempt_build_from_queue(pindex, build_state, pending_tiles, max_count, current_tile_pos)
   local player = game.get_player(pindex)
   if not player then return nil end

   local stack = player.cursor_stack
   if not stack or not stack.valid_for_read then return nil end

   local item_prototype = stack.prototype
   if not item_prototype.place_result and not item_prototype.place_as_tile_result then return nil end

   -- For tiles, entity_prototype will be nil (they use place_as_tile_result instead)
   local entity_prototype = item_prototype.place_result
   local item_quality = stack.quality

   -- Find appropriate backend
   local backend = find_backend(item_prototype)
   if not backend then
      logger:debug("No backend found for item: " .. item_prototype.name)
      return nil
   end

   -- Build base context (without position yet)
   local vp = Viewpoint.get_viewpoint(pindex)
   local context = {
      pindex = pindex,
      player = player,
      item_prototype = item_prototype,
      item_quality = item_quality,
      entity_prototype = entity_prototype, -- nil for tiles
      current_position = nil, -- Will be set after tile selection
      movement_direction = nil, -- Will be set after tile selection
      building_direction = vp:get_hand_direction(),
      entity_history = build_state.entity_history,
      backend_state = build_state.backend_state,
   }

   -- Create helpers instance
   local helpers = setmetatable({
      pindex = pindex,
      build_state = build_state,
      player = player,
      stack = stack,
      entity_prototype = entity_prototype, -- nil for tiles
      fail_reason = nil,
   }, BuildHelpers_meta)

   -- Phase 1: Select which tile to build at
   local selection
   if backend.select_tile_to_build then
      selection = backend.select_tile_to_build(pending_tiles, max_count, context, helpers)
   else
      selection = helpers:select_tile_to_build_default(pending_tiles, max_count, current_tile_pos)
   end

   -- If no tile selected, can't build
   if not selection then return nil end

   local tile_index = selection.tile_index
   local selected_tile = pending_tiles[tile_index]

   -- Update context with selected tile's position and direction
   context.current_position = { x = selected_tile.x + 0.5, y = selected_tile.y + 0.5 }
   context.movement_direction = selected_tile.direction

   logger:debug(
      string.format(
         "Backend: %s, selected tile %d at pos=(%.1f,%.1f), move_dir=%d, build_dir=%d",
         backend.name,
         tile_index,
         context.current_position.x,
         context.current_position.y,
         context.movement_direction,
         context.building_direction
      )
   )

   -- Phase 2: Build at selected position
   local action = backend.build(context, helpers)
   action = action or BuildAction.RETRY

   -- Handle FAIL action: disable build lock and stop processing
   if action == BuildAction.FAIL then
      BuildLock.set_enabled(pindex, false, false, helpers.fail_reason)
      return nil
   end

   return { action = action, tile_index = tile_index }
end

---Process the pending tiles queue, attempting to build entities
---@param pindex number
---@param build_state fa.BuildLock.BuildState
---@param current_tile {x: number, y: number} Current tile position (floored)
local function process_pending_tiles_queue(pindex, build_state, current_tile)
   local player = game.get_player(pindex)
   if not player then return end

   local stack = player.cursor_stack
   if not stack or not stack.valid_for_read or stack.count == 0 then return end

   -- Keep processing until we can't place anything or run out of tiles
   while #build_state.pending_tiles > 0 do
      logger:debug(string.format("Processing queue, %d tiles pending", #build_state.pending_tiles))
      local result = attempt_build_from_queue(
         pindex,
         build_state,
         build_state.pending_tiles,
         math.min(#build_state.pending_tiles, 10),
         current_tile
      )

      -- If no tile selected or build failed, stop for this tick
      if not result then break end

      -- Handle action returned by backend
      if result.action == BuildAction.PLACED then
         -- Successfully placed - remove this tile and everything before it
         logger:debug(string.format("Placed successfully, removing %d tiles", result.tile_index))
         for j = 1, result.tile_index do
            table.remove(build_state.pending_tiles, 1)
         end
      elseif result.action == BuildAction.RETRY then
         -- Blocked temporarily (e.g., player in way), keep queue and stop for this tick
         logger:debug("Build returned RETRY, stopping for this tick")
         break
      elseif result.action == BuildAction.SKIP then
         -- Skip this tile permanently, remove it and continue
         logger:debug(string.format("Build returned SKIP, removing %d tiles", result.tile_index))
         for j = 1, result.tile_index do
            table.remove(build_state.pending_tiles, 1)
         end
      end

      -- Check if we ran out of items
      stack = player.cursor_stack
      if not stack or not stack.valid_for_read or stack.count == 0 then break end
   end

   -- If queue is too long, trim old tiles
   while #build_state.pending_tiles > 10 do
      table.remove(build_state.pending_tiles, 1)
   end
end

---Processes build lock for walking movement
---@param pindex number
function BuildLock.process_walking_movement(pindex)
   local state = build_lock_storage[pindex]
   if not state.enabled then return end

   -- Check for disable conditions
   local should_disable, reason = check_cursor_stack_changes(pindex)
   if should_disable then
      logger:debug("Disabling build lock: " .. (reason or "unknown"))
      BuildLock.set_enabled(pindex, false, false, reason)
      return
   end

   should_disable, reason = check_movement_discontinuity(pindex)
   if should_disable then
      logger:debug("Disabling build lock: " .. (reason or "unknown"))
      BuildLock.set_enabled(pindex, false, false, reason)
      return
   end

   -- Get player's actual position (not cursor!)
   local player = game.get_player(pindex)
   if not player or not player.character then return end

   -- Get walking state from movement history
   local reader = MovementHistory.get_movement_history_reader(pindex)
   local entry = reader:get(0)

   if not entry or entry.kind ~= MovementHistory.MOVEMENT_KINDS.WALKING then return end

   local walking_state = state.walking_state
   local current_position = player.character.position
   local current_tile = {
      x = math.floor(current_position.x),
      y = math.floor(current_position.y),
   }

   -- Check if we've moved to a new tile
   if walking_state.last_floored_position then
      local last_tile = walking_state.last_floored_position
      if current_tile.x ~= last_tile.x or current_tile.y ~= last_tile.y then
         -- Player has moved to a new tile, generate path and add to queue
         local path = generate_tile_path(last_tile, current_tile)
         for _, tile in ipairs(path) do
            table.insert(walking_state.pending_tiles, tile)
         end
         walking_state.last_floored_position = current_tile
      end
   end

   -- Process pending tiles queue
   process_pending_tiles_queue(pindex, walking_state, current_tile)
end

---Processes build lock for cursor movement
---@param pindex number
---@param new_position MapPosition
---@param movement_direction defines.direction
function BuildLock.process_cursor_movement(pindex, new_position, movement_direction)
   local state = build_lock_storage[pindex]
   if not state.enabled then return end

   -- Check for disable conditions
   local should_disable, reason = check_cursor_stack_changes(pindex)
   if should_disable then
      logger:debug("Disabling build lock: " .. (reason or "unknown"))
      BuildLock.set_enabled(pindex, false, false, reason)
      return
   end

   should_disable, reason = check_movement_discontinuity(pindex)
   if should_disable then
      logger:debug("Disabling build lock: " .. (reason or "unknown"))
      BuildLock.set_enabled(pindex, false, false, reason)
      return
   end

   local cursor_state = state.cursor_state
   local current_tile = {
      x = math.floor(new_position.x),
      y = math.floor(new_position.y),
   }

   -- Check if cursor moved to a new tile
   if cursor_state.last_floored_position then
      local last_tile = cursor_state.last_floored_position
      if current_tile.x ~= last_tile.x or current_tile.y ~= last_tile.y then
         -- Cursor has moved to a new tile, generate path and add to queue
         local path = generate_tile_path(last_tile, current_tile)
         for _, tile in ipairs(path) do
            table.insert(cursor_state.pending_tiles, tile)
         end
         cursor_state.last_floored_position = current_tile
      end
   else
      -- First cursor movement, initialize
      cursor_state.last_floored_position = current_tile
      table.insert(cursor_state.pending_tiles, {
         x = current_tile.x,
         y = current_tile.y,
         direction = movement_direction,
      })
   end

   -- Process pending tiles queue (same as walking)
   process_pending_tiles_queue(pindex, cursor_state, current_tile)
end

---Called when a bump is detected, disables build lock
---@param pindex number
function BuildLock.on_bump_detected(pindex)
   local state = build_lock_storage[pindex]
   if state.enabled then
      logger:debug("Build lock disabled due to bump")
      BuildLock.set_enabled(pindex, false, false, "fa.build-lock-reason-bump")
   end
end

-- Backends register themselves to avoid circular imports.

-- Register listener for continuous cursor movement
Viewpoint.register_listener("cursor_moved_continuous", function(pindex, data)
   if not data then return end
   BuildLock.process_cursor_movement(pindex, data.new_position, data.direction)
end)

-- Register callback for bump detection
local BumpDetection = require("scripts.bump-detection")
BumpDetection.register_bump_callback(function(pindex)
   BuildLock.on_bump_detected(pindex)
end)

return BuildLock
