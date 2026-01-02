---Virtual Train Driving
---
---Turtle graphics-style rail building where player "drives" a virtual train that lays tracks

local Consts = require("scripts.consts")
local StorageManager = require("scripts.storage-manager")
local Speech = require("scripts.speech")
local Sounds = require("scripts.ui.sounds")
local Viewpoint = require("scripts.viewpoint")
local Traverser = require("railutils.traverser")
local Queries = require("railutils.queries")
local FaUtils = require("scripts.fa-utils")
local BlueprintSynthesizer = require("scripts.blueprint-synthesizer")
local HandMonitor = require("scripts.hand-monitor")
local InventoryUtils = require("scripts.inventory-utils")
local UiRouter = require("scripts.ui.router")
local SurfaceHelper = require("scripts.rails.surface-helper")
local SyntraxRunner = require("scripts.rails.syntrax-runner")

local MessageBuilder = Speech.MessageBuilder

---Get effective rail name from entity (handles ghosts)
---@param ent LuaEntity
---@return string The rail prototype name
local function get_effective_name(ent)
   if ent.type == "entity-ghost" then return ent.ghost_name end
   return ent.name
end

---Check if an entity is a rail (real or ghost)
---@param ent LuaEntity?
---@return boolean
local function is_rail_entity(ent)
   if not ent or not ent.valid then return false end
   if Consts.RAIL_TYPES_SET[ent.type] then return true end
   if ent.type == "entity-ghost" and Consts.RAIL_TYPES_SET[ent.ghost_type] then return true end
   return false
end

local mod = {}

---@class vtd.Inventories
---@field tmp_inv LuaInventory? Temporary inventory for hand swapping

---Initialize inventories for a player
---@return vtd.Inventories
local function init_inventories()
   return {}
end

local vtd_inventories = StorageManager.declare_storage_module("virtual_train_invs", init_inventories)

---@class vtd.Move
---@field position MapPosition Position of the rail piece
---@field end_direction defines.direction Direction of the rail end we're facing
---@field rail_type railutils.RailType Type of rail (STRAIGHT, HALF_DIAGONAL, CURVE_A, CURVE_B)
---@field placement_direction defines.direction Direction the rail was placed
---@field entities LuaEntity[] Entities placed with this move (rail, signals, etc)
---@field is_bookmark boolean Whether this move is a bookmark

---@class vtd.State
---@field locked boolean Whether the player is locked to rails
---@field moves vtd.Move[] Stack of moves representing the path
---@field speculating boolean Whether we're in speculative mode
---@field build_mode defines.build_mode Build mode for placing entities
---@field planner_description railutils.RailPlannerDescription? Rail planner captured at lock time

---Initialize state for a player
---@return vtd.State
local function init_state()
   return {
      locked = false,
      moves = {},
      speculating = false,
      build_mode = defines.build_mode.normal,
      planner_description = nil,
   }
end

local vtd_storage = StorageManager.declare_storage_module("virtual_train_driving", init_state)

---Check if player has a rail planner in hand
---@param player LuaPlayer
---@return boolean
local function has_rail_planner(player)
   if not player.cursor_stack or not player.cursor_stack.valid_for_read then return false end
   local prototype = player.cursor_stack.prototype
   return prototype.rails ~= nil
end

---Get or create a temporary inventory for storing the player's hand during builds
---@param pindex integer
---@return LuaInventory
local function get_or_create_tmp_inventory(pindex)
   local invs = vtd_inventories[pindex]

   -- Check if we have a valid inventory
   if invs.tmp_inv and invs.tmp_inv.valid then return invs.tmp_inv end

   -- Create a new inventory with 1 slot
   invs.tmp_inv = game.create_inventory(1)
   return invs.tmp_inv
end

---Find a ghost entity at a position matching the expected name and direction
---@param surface LuaSurface
---@param position MapPosition
---@param entity_name string
---@param direction defines.direction
---@return LuaEntity|nil
local function find_expected_ghost(surface, position, entity_name, direction)
   local ghosts = surface.find_entities_filtered({
      position = position,
      radius = 1,
      name = "entity-ghost",
      ghost_name = entity_name,
   })

   for _, ghost in ipairs(ghosts) do
      if ghost.direction == direction then return ghost end
   end

   return nil
end

---Find a real entity at a position matching the expected name and direction
---@param surface LuaSurface
---@param position MapPosition
---@param entity_name string
---@param direction defines.direction
---@return LuaEntity|nil
local function find_expected_entity(surface, position, entity_name, direction)
   local entities = surface.find_entities_filtered({
      position = position,
      radius = 1,
      name = entity_name,
   })

   for _, entity in ipairs(entities) do
      if entity.direction == direction then return entity end
   end

   return nil
end

---Build an entity using build_from_cursor with proper hand swapping
---@param pindex integer
---@param entity_name string
---@param position MapPosition
---@param direction defines.direction
---@param build_mode defines.build_mode
---@return LuaEntity|nil entity The built entity, or nil if already existed or ghost placed
---@return boolean success True if built, already existed, or ghost placed in forced mode
local function try_build_entity(pindex, entity_name, position, direction, build_mode)
   local player = game.get_player(pindex)
   if not player then return nil, false end

   local surface = player.surface

   -- Check if entity already exists at this position
   local existing = find_expected_entity(surface, position, entity_name, direction)
   if existing then
      return nil, true -- Already exists, success (no cost)
   end

   -- In normal mode, check cost upfront; forced/superforced place ghosts for bots (no cost)
   local deductor = nil
   if build_mode == defines.build_mode.normal then
      deductor = InventoryUtils.deductor_to_place(pindex, entity_name)
      if not deductor then return nil, false end
   end

   -- Suppress hand change events for this tick since we're swapping the hand out and back
   HandMonitor.suppress_this_tick(pindex)

   -- Get temporary inventory and swap hand into it
   local tmp_inv = get_or_create_tmp_inventory(pindex)
   local cursor = player.cursor_stack

   -- Swap player's hand to temp inventory
   local swap_success = cursor.swap_stack(tmp_inv[1])
   if not swap_success then
      Sounds.play_cannot_build(pindex)
      Speech.speak(pindex, { "fa.cannot-build" })
      return nil, false
   end

   -- Create blueprint in cursor
   cursor.set_stack({ name = "blueprint" })
   local bp_string = BlueprintSynthesizer.synthesize_simple_blueprint(entity_name, direction)
   local import_result = cursor.import_stack(bp_string)
   if import_result ~= 0 then
      -- Import failed, restore hand
      cursor.swap_stack(tmp_inv[1])
      Sounds.play_cannot_build(pindex)
      Speech.speak(pindex, { "fa.cannot-build" })
      return nil, false
   end

   -- Try to build from cursor (direction is already in the blueprint entity)
   local can_build = player.can_build_from_cursor({
      position = position,
      build_mode = build_mode,
   })

   if can_build then player.build_from_cursor({
      position = position,
      build_mode = build_mode,
   }) end

   -- Clear blueprint and restore hand
   cursor.clear()
   cursor.swap_stack(tmp_inv[1])

   -- Check if ghost was placed (blueprint always places ghosts)
   local ghost = find_expected_ghost(surface, position, entity_name, direction)

   if not ghost then
      if not can_build then
         Sounds.play_cannot_build(pindex)
         Speech.speak(pindex, { "fa.cannot-build" })
      end
      return nil, false
   end

   if build_mode == defines.build_mode.normal then
      -- Normal mode: revive the ghost to place the actual entity
      local _, revived_entity = ghost.silent_revive()
      if revived_entity then
         deductor:commit()
         return revived_entity, true
      else
         ghost.destroy()
         Sounds.play_cannot_build(pindex)
         Speech.speak(pindex, { "fa.cannot-build" })
         return nil, false
      end
   else
      -- Forced/superforced mode: ghost placement is success (bots or player pay later)
      return nil, true
   end
end

---Check if virtual train is locked for a player
---@param pindex integer
---@return boolean
function mod.is_locked(pindex)
   return vtd_storage[pindex].locked
end

---Unlock from rails and reset state
---@param pindex integer
---@param announce boolean
local function unlock_from_rails(pindex, announce)
   if announce then Speech.speak(pindex, { "fa.virtual-train-unlocked" }) end
   vtd_storage[pindex] = init_state()
end

---Get current move (always the last move in the stack)
---@param pindex integer
---@return vtd.Move|nil
local function get_current_move(pindex)
   local state = vtd_storage[pindex]
   if #state.moves == 0 then return nil end
   return state.moves[#state.moves]
end

---Create traverser from a move record
---@param move vtd.Move
---@return railutils.Traverser
local function create_traverser_from_move(move)
   return Traverser.new(move.rail_type, move.position, move.placement_direction, move.end_direction)
end

---Get a bounding box for the tile containing a position
---@param position MapPosition
---@return BoundingBox
local function get_tile_search_area(position)
   local floor_x = math.floor(position.x)
   local floor_y = math.floor(position.y)
   return {
      { x = floor_x + 0.001, y = floor_y + 0.001 },
      { x = floor_x + 0.999, y = floor_y + 0.999 },
   }
end

---Check if a rail already exists at position matching prototype and direction
---@param surface LuaSurface
---@param position MapPosition
---@param prototype_name string
---@param direction defines.direction
---@return LuaEntity|nil
local function find_matching_rail(surface, position, prototype_name, direction)
   local entities = surface.find_entities_filtered({
      area = get_tile_search_area(position),
      name = prototype_name,
   })

   for _, entity in ipairs(entities) do
      if entity.direction == direction then return entity end
   end

   return nil
end

---Build a rail at the specified position using build_from_cursor
---@param pindex integer
---@param position MapPosition
---@param rail_type railutils.RailType
---@param placement_direction defines.direction
---@return LuaEntity|nil entity The created entity, or nil if already exists or ghost placed
---@return boolean success True if built, already existed, or ghost placed
local function try_build_rail(pindex, position, rail_type, placement_direction)
   local state = vtd_storage[pindex]
   local prototype_name = Queries.rail_type_to_prototype_type(rail_type)

   -- try_build_entity returns (entity, success) directly
   return try_build_entity(pindex, prototype_name, position, placement_direction, state.build_mode)
end

---Push a move onto the stack
---@param pindex integer
---@param position MapPosition
---@param end_direction defines.direction
---@param rail_type railutils.RailType
---@param placement_direction defines.direction
---@param entity LuaEntity|nil
---@param is_bookmark boolean
local function push_move(pindex, position, end_direction, rail_type, placement_direction, entity, is_bookmark)
   local state = vtd_storage[pindex]
   local entities = {}
   if entity then table.insert(entities, entity) end
   table.insert(state.moves, {
      position = { x = position.x, y = position.y },
      end_direction = end_direction,
      rail_type = rail_type,
      placement_direction = placement_direction,
      entities = entities,
      is_bookmark = is_bookmark or false,
   })
end

---Pop a move from the stack
---@param pindex integer
---@param destroy_entities boolean Whether to destroy the entities
---@return vtd.Move|nil move The popped move, or nil if stack empty
---@return boolean? success Whether the entities were successfully removed (nil if not attempted)
local function pop_move(pindex, destroy_entities)
   local state = vtd_storage[pindex]
   if #state.moves == 0 then return nil end

   local move = table.remove(state.moves)

   -- Remove entities if requested
   if destroy_entities and #move.entities > 0 then
      -- Check upfront if we have character/inventory for real entities
      local player = game.get_player(pindex)
      local main_inv = nil
      local has_real_entity = false

      for _, entity in ipairs(move.entities) do
         if entity.valid and entity.type ~= "entity-ghost" then
            has_real_entity = true
            break
         end
      end

      if has_real_entity then
         if not player or not player.character then
            table.insert(state.moves, move)
            return nil, false
         end
         main_inv = player.character.get_inventory(defines.inventory.character_main)
         if not main_inv then
            table.insert(state.moves, move)
            return nil, false
         end
      end

      -- Remove entities in reverse order (signals before rails)
      for i = #move.entities, 1, -1 do
         local entity = move.entities[i]
         if entity.valid then
            if entity.type == "entity-ghost" then
               entity.destroy()
            else
               local success = entity.mine({ inventory = main_inv })
               if not success then
                  -- Mining failed - put move back (some entities may be lost)
                  table.insert(state.moves, move)
                  return nil, false
               end
            end
         end
      end
   end

   return move, true
end

---Announce current rail position and state
---@param pindex integer
local function announce_rail(pindex)
   local current = get_current_move(pindex)
   if not current then return end

   local mb = MessageBuilder.new()

   -- Position
   mb:fragment(FaUtils.format_coordinates(current.position.x, current.position.y))

   -- Activity
   local state = vtd_storage[pindex]
   if state.speculating then
      mb:fragment("planning rails")
   else
      mb:fragment("building rails")
   end

   -- Direction
   mb:fragment({ "fa.facing-direction", { "fa.direction", current.end_direction } })

   if state.speculating then mb:fragment("speculating") end

   Speech.speak(pindex, mb:build())
end

---Check if a connection exists by trying a move function
---@param rail_entity LuaEntity
---@param rail_type railutils.RailType
---@param end_direction defines.direction
---@param move_fn fun(trav: railutils.Traverser)
---@return boolean
local function check_connection(rail_entity, rail_type, end_direction, move_fn)
   local position = { x = rail_entity.position.x, y = rail_entity.position.y }
   local trav = Traverser.new(rail_type, position, rail_entity.direction, end_direction)
   move_fn(trav)

   local expected_pos = trav:get_position()
   local expected_direction = trav:get_placement_direction()
   local expected_type = Queries.rail_type_to_prototype_type(trav:get_rail_kind())
   local expected_floor_x = math.floor(expected_pos.x)
   local expected_floor_y = math.floor(expected_pos.y)

   local rails_at_pos = rail_entity.surface.find_entities_filtered({
      area = get_tile_search_area(expected_pos),
      type = Consts.RAIL_TYPES,
   })

   for _, connected_rail in ipairs(rails_at_pos) do
      local rail_floor_x = math.floor(connected_rail.position.x)
      local rail_floor_y = math.floor(connected_rail.position.y)
      if
         rail_floor_x == expected_floor_x
         and rail_floor_y == expected_floor_y
         and connected_rail.name == expected_type
         and connected_rail.direction == expected_direction
      then
         return true
      end
   end

   return false
end

---Count total connections (forward, left, right) for a rail end
---@param rail_entity LuaEntity
---@param end_direction defines.direction
---@return integer count Number of connections (0-3)
local function count_connections(rail_entity, end_direction)
   local rail_type = Queries.prototype_type_to_rail_type(get_effective_name(rail_entity))
   if not rail_type then return 0 end

   local count = 0

   -- Check forward
   if check_connection(rail_entity, rail_type, end_direction, function(t)
      t:move_forward()
   end) then
      count = count + 1
   end

   -- Check left
   if check_connection(rail_entity, rail_type, end_direction, function(t)
      t:move_left()
   end) then
      count = count + 1
   end

   -- Check right
   if check_connection(rail_entity, rail_type, end_direction, function(t)
      t:move_right()
   end) then
      count = count + 1
   end

   return count
end

---Determine which end direction to use when locking onto a rail
---Prefers ends with fewer connections, otherwise chooses most counterclockwise
---@param rail_entity LuaEntity
---@return defines.direction The end direction to use
local function determine_initial_end(rail_entity)
   -- Get rail type and both end directions
   local rail_name = get_effective_name(rail_entity)
   local rail_type = Queries.prototype_type_to_rail_type(rail_name)
   if not rail_type then error(string.format("%s not a rail!", rail_name)) end

   local end_dirs = Queries.get_end_directions(rail_type, rail_entity.direction)
   if #end_dirs ~= 2 then error("Rail data corrupt!") end

   -- Count connections at each end
   local end1_connections = count_connections(rail_entity, end_dirs[1])
   local end2_connections = count_connections(rail_entity, end_dirs[2])

   -- Prefer the end with no connections.
   if end1_connections == 0 and end2_connections == 0 then
      return end_dirs[1] < end_dirs[2] and end_dirs[1] or end_dirs[2]
   elseif end1_connections == 0 then
      return end_dirs[1]
   elseif end2_connections == 0 then
      return end_dirs[2]
   end

   -- Equal connections: choose most counterclockwise (numerically least)
   if end_dirs[1] < end_dirs[2] then
      return end_dirs[1]
   else
      return end_dirs[2]
   end
end

---Lock onto a rail at the cursor position
---@param pindex integer
---@param rail_entity LuaEntity|nil Optional rail entity to lock onto (uses player.selected if nil)
---@param build_mode defines.build_mode|nil Build mode to use (defaults to normal)
function mod.lock_on_to_rail(pindex, rail_entity, build_mode)
   local player = game.get_player(pindex)
   if not player then return end

   -- Check if player has rail planner and get its description
   if not has_rail_planner(player) then
      Speech.speak(pindex, { "fa.virtual-train-need-planner" })
      return
   end

   local planner_description = SurfaceHelper.get_planner_description(player.cursor_stack.prototype)
   if not planner_description then
      Speech.speak(pindex, { "fa.virtual-train-need-planner" })
      return
   end

   -- Get rail entity (use provided one or player.selected)
   local rail = rail_entity or player.selected

   -- Check if rail is valid (check entity type)
   if not is_rail_entity(rail) then
      Speech.speak(pindex, { "fa.virtual-train-no-rail" })
      return
   end

   -- Convert entity name to rail type
   local rail_type = Queries.prototype_type_to_rail_type(get_effective_name(rail))
   if not rail_type then
      Speech.speak(pindex, { "fa.virtual-train-no-rail-info" })
      return
   end

   -- Determine which end direction to use
   local chosen_end_direction = determine_initial_end(rail)

   -- Initialize state
   local state = vtd_storage[pindex]
   state.locked = true
   state.moves = {}
   state.speculating = false
   state.build_mode = build_mode or defines.build_mode.normal
   state.planner_description = planner_description

   -- Add initial rail to moves (entity = rail, not nil, but we won't destroy it on undo)
   -- Actually, use nil since it already exists and we shouldn't destroy it
   push_move(pindex, rail.position, chosen_end_direction, rail_type, rail.direction, nil, false)

   -- Set cursor position
   local vp = Viewpoint.get_viewpoint(pindex)
   vp:set_cursor_pos(rail.position)

   -- Announce lock-on with build mode and end direction
   local mb = MessageBuilder.new()
   mb:fragment({ "fa.virtual-train-locked" })
   if state.build_mode == defines.build_mode.forced then
      mb:fragment({ "fa.virtual-train-mode-force" })
   elseif state.build_mode == defines.build_mode.superforced then
      mb:fragment({ "fa.virtual-train-mode-superforce" })
   end
   mb:fragment({ "fa.facing-direction", { "fa.direction", chosen_end_direction } })
   Speech.speak(pindex, mb:build())
end

---Handle cursor stack changed - check if player still has rail planner
---@param event EventData.on_player_cursor_stack_changed
function mod.on_cursor_stack_changed(event)
   local pindex = event.player_index
   local state = vtd_storage[pindex]

   if not state.locked then return end

   local player = game.get_player(pindex)
   if not player or not has_rail_planner(player) then unlock_from_rails(pindex, true) end
end

---Move in a direction
---@param pindex integer
---@param move_func function Function to call on traverser
---@param direction_name string Name for announcement
---@return boolean success True if move succeeded
local function move_in_direction(pindex, move_func, direction_name)
   local player = game.get_player(pindex)
   if not player then return false end

   local current = get_current_move(pindex)
   if not current then return false end

   -- Create traverser from current state and move
   local trav = create_traverser_from_move(current)
   move_func(trav) -- Let it crash if it fails

   -- Get new state from traverser
   local new_pos = trav:get_position()
   local new_end_dir = trav:get_direction()
   local new_rail_type = trav:get_rail_kind()
   local new_placement_dir = trav:get_placement_direction()

   local state = vtd_storage[pindex]
   if state.speculating then
      -- In speculation mode, just update cursor position without modifying stack
      local vp = Viewpoint.get_viewpoint(pindex)
      vp:set_cursor_pos(new_pos)
      return true
   else
      -- Build mode: try to build rail
      local entity, success = try_build_rail(pindex, new_pos, new_rail_type, new_placement_dir)

      -- If build failed, don't update position or add to moves
      if not success then return false end

      -- Add to moves
      push_move(pindex, new_pos, new_end_dir, new_rail_type, new_placement_dir, entity, false)

      -- Update cursor position (caller will read tile)
      local vp = Viewpoint.get_viewpoint(pindex)
      vp:set_cursor_pos(new_pos)
      return true
   end
end

---Extend forward
---@param pindex integer
---@return boolean success
function mod.extend_forward(pindex)
   return move_in_direction(pindex, function(trav)
      trav:move_forward()
   end, "forward")
end

---Extend left
---@param pindex integer
---@return boolean success
function mod.extend_left(pindex)
   return move_in_direction(pindex, function(trav)
      trav:move_left()
   end, "left")
end

---Extend right
---@param pindex integer
---@return boolean success
function mod.extend_right(pindex)
   return move_in_direction(pindex, function(trav)
      trav:move_right()
   end, "right")
end

---Flip to other end of current rail
---@param pindex integer
function mod.flip_end(pindex)
   local current = get_current_move(pindex)
   if not current then return end

   local trav = create_traverser_from_move(current)
   trav:flip_ends()

   -- Add new move with flipped end
   push_move(
      pindex,
      trav:get_position(),
      trav:get_direction(),
      trav:get_rail_kind(),
      trav:get_placement_direction(),
      nil, -- No entity built
      false
   )

   -- Update cursor position
   local vp = Viewpoint.get_viewpoint(pindex)
   vp:set_cursor_pos(trav:get_position())

   -- Announce flip with new direction
   local mb = MessageBuilder.new()
   mb:fragment({ "fa.virtual-train-flipped" })
      :fragment({ "fa.virtual-train-now-facing", { "fa.direction", trav:get_direction() } })
   Speech.speak(pindex, mb:build())
end

---Toggle speculation mode
---@param pindex integer
function mod.toggle_speculation(pindex)
   local state = vtd_storage[pindex]
   local current = get_current_move(pindex)
   if not current then return end

   if state.speculating then
      -- Exit speculation: restore cursor to current stack position
      -- (Stack was never modified during speculation)
      local vp = Viewpoint.get_viewpoint(pindex)
      vp:set_cursor_pos(current.position)

      state.speculating = false

      Speech.speak(pindex, { "fa.virtual-train-speculation-exit" })
   else
      -- Enter speculation mode
      state.speculating = true

      Speech.speak(pindex, { "fa.virtual-train-speculation-enter" })
   end
end

---Create bookmark at current position
---@param pindex integer
function mod.create_bookmark(pindex)
   local state = vtd_storage[pindex]

   if state.speculating then
      Speech.speak(pindex, { "fa.virtual-train-cannot-bookmark-speculating" })
      return
   end

   if #state.moves > 0 then
      state.moves[#state.moves].is_bookmark = true
      Speech.speak(pindex, { "fa.virtual-train-bookmark-created" })
   end
end

---Return to last bookmark
---@param pindex integer
---@return boolean success Whether a bookmark was found and returned to
function mod.return_to_bookmark(pindex)
   local state = vtd_storage[pindex]

   if state.speculating then
      Speech.speak(pindex, { "fa.virtual-train-cannot-use-bookmark-speculating" })
      return false
   end

   -- Find last bookmark
   local bookmark_index = nil
   for i = #state.moves, 1, -1 do
      if state.moves[i].is_bookmark then
         bookmark_index = i
         break
      end
   end

   if not bookmark_index then
      Speech.speak(pindex, { "fa.virtual-train-no-bookmarks" })
      return false
   end

   -- Remove all moves after bookmark (don't destroy rails)
   local removed_count = 0
   while #state.moves > bookmark_index do
      pop_move(pindex, false)
      removed_count = removed_count + 1
   end

   -- Clear bookmark flag so user can access earlier bookmarks
   state.moves[bookmark_index].is_bookmark = false

   -- Update cursor position
   local current = get_current_move(pindex)
   if current then
      local vp = Viewpoint.get_viewpoint(pindex)
      vp:set_cursor_pos(current.position)
   end

   Speech.speak(pindex, { "fa.virtual-train-returned-to-bookmark", removed_count })
   return true
end

---Backspace (undo last move)
---@param pindex integer
function mod.backspace(pindex)
   local state = vtd_storage[pindex]

   if state.speculating then
      Speech.speak(pindex, { "fa.virtual-train-cannot-undo-speculating" })
      return
   end

   local move, success = pop_move(pindex, true)
   if not move then
      if success == false then
         Sounds.play_cannot_build(pindex)
         Speech.speak(pindex, { "fa.virtual-train-cannot-backspace" })
      end
      return
   end

   if #state.moves == 0 then
      -- Removed last move, unlock
      unlock_from_rails(pindex, true)
      return
   end

   -- Update cursor position
   local current = get_current_move(pindex)
   if current then
      local vp = Viewpoint.get_viewpoint(pindex)
      vp:set_cursor_pos(current.position)
   end

   Speech.speak(pindex, { "fa.virtual-train-undid" })
end

---Place signal using build_from_cursor
---@param pindex integer
---@param side "left"|"right"
---@param is_chain boolean
---@return boolean success True if signal was placed or already existed
function mod.place_signal(pindex, side, is_chain)
   local current = get_current_move(pindex)
   if not current then return false end

   local state = vtd_storage[pindex]
   local trav = create_traverser_from_move(current)

   local signal_side = side == "left" and Traverser.SignalSide.LEFT or Traverser.SignalSide.RIGHT
   local signal_pos = trav:get_signal_pos(signal_side)
   local signal_dir = trav:get_signal_direction(signal_side)

   local signal_name = is_chain and "rail-chain-signal" or "rail-signal"

   local entity, already_existed = try_build_entity(pindex, signal_name, signal_pos, signal_dir, state.build_mode)

   if entity then
      -- Add signal to current move's entities for undo
      table.insert(current.entities, entity)

      local mb = MessageBuilder.new()
      mb:fragment({
         "fa.virtual-train-placed-" .. (is_chain and "chain-signal" or "signal"),
      }):fragment({ "fa.direction", signal_dir })
      Speech.speak(pindex, mb:build())
      return true
   elseif already_existed then
      -- Signal already exists, no error
      Speech.speak(pindex, { "fa.virtual-train-signal-exists", side })
      return true
   end
   -- If entity is nil and not already_existed, try_build_entity already spoke the error
   return false
end

---Main keyboard action handler
---@param event EventData
---@return boolean handled Whether this event was handled (prevents fallthrough)
---@return boolean should_read_tile Whether caller should read the tile
function mod.on_kb_descriptive_action_name(event)
   local pindex = event.player_index
   local state = vtd_storage[pindex]

   if not state.locked then return false, false end

   local player = game.get_player(pindex)
   if not player or not has_rail_planner(player) then
      unlock_from_rails(pindex, true)
      return false, false
   end

   local action = event.input_name

   -- Movement (success determines tile read)
   if action == "fa-comma" then
      local success = mod.extend_forward(pindex)
      return true, success
   elseif action == "fa-m" then
      local success = mod.extend_left(pindex)
      return true, success
   elseif action == "fa-dot" then
      local success = mod.extend_right(pindex)
      return true, success
   elseif action == "fa-a-comma" then
      mod.flip_end(pindex)
      return true, true
   end

   -- Speculation
   if action == "fa-slash" then
      mod.toggle_speculation(pindex)
      return true, false
   end

   -- Bookmarks
   if action == "fa-s-b" then
      mod.create_bookmark(pindex)
      return true, false
   end

   -- Signals (success determines tile read)
   if action == "fa-c-m" then
      local success = mod.place_signal(pindex, "left", true)
      return true, success
   elseif action == "fa-c-dot" then
      local success = mod.place_signal(pindex, "right", true)
      return true, success
   elseif action == "fa-s-m" then
      local success = mod.place_signal(pindex, "left", false)
      return true, success
   elseif action == "fa-s-dot" then
      local success = mod.place_signal(pindex, "right", false)
      return true, success
   end

   -- Status
   if action == "fa-k" then
      announce_rail(pindex)
      return true, false
   end

   -- Undo
   if action == "fa-backspace" then
      mod.backspace(pindex)
      return true, true
   end

   return false, false
end

---Open syntrax input UI if locked onto a rail
---@param pindex integer
---@return boolean opened True if UI was opened
function mod.open_syntrax_input(pindex)
   local state = vtd_storage[pindex]
   if not state.locked then return false end
   if not state.planner_description then return false end

   local current = get_current_move(pindex)
   if not current then return false end

   UiRouter.get_router(pindex):open_ui(UiRouter.UI_NAMES.SYNTRAX_INPUT, {
      position = current.position,
      direction = current.end_direction,
   })
   return true
end

---Execute syntrax code using stored VTD state
---@param pindex integer
---@param source string Syntrax source code
---@return LuaEntity[]|nil entities The placed rails/ghosts, or nil on failure
---@return string|nil error Error message if failed
function mod.execute_syntrax(pindex, source)
   local state = vtd_storage[pindex]
   if not state.locked then return nil, "Not locked to rails" end
   if not state.planner_description then return nil, "No rail planner" end

   local current = get_current_move(pindex)
   if not current then return nil, "No current position" end

   return SyntraxRunner.execute({
      pindex = pindex,
      source = source,
      position = current.position,
      direction = current.end_direction,
      rail_type = current.rail_type,
      placement_direction = current.placement_direction,
      planner_description = state.planner_description,
      build_mode = state.build_mode,
   })
end

return mod
