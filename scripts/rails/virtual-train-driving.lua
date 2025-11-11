---Virtual Train Driving
---
---Turtle graphics-style rail building where player "drives" a virtual train that lays tracks

local Consts = require("scripts.consts")
local StorageManager = require("scripts.storage-manager")
local Speech = require("scripts.speech")
local Viewpoint = require("scripts.viewpoint")
local Traverser = require("railutils.traverser")
local Queries = require("railutils.queries")
local FaUtils = require("scripts.fa-utils")

local MessageBuilder = Speech.MessageBuilder

local mod = {}

---@class vtd.Move
---@field position MapPosition Position of the rail piece
---@field end_direction defines.direction Direction of the rail end we're facing
---@field rail_type railutils.RailType Type of rail (STRAIGHT, HALF_DIAGONAL, CURVE_A, CURVE_B)
---@field placement_direction defines.direction Direction the rail was placed
---@field entity LuaEntity|nil The placed rail entity (nil if already existed)
---@field is_bookmark boolean Whether this move is a bookmark

---@class vtd.State
---@field locked boolean Whether the player is locked to rails
---@field moves vtd.Move[] Stack of moves representing the path
---@field speculating boolean Whether we're in speculative mode
---@field speculation_start integer|nil Index where speculation started

---Initialize state for a player
---@return vtd.State
local function init_state()
   return {
      locked = false,
      moves = {},
      speculating = false,
      speculation_start = nil,
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
   -- Create traverser with rail type, position, and placement direction
   local trav = Traverser.new(move.rail_type, move.position, move.end_direction)

   -- The traverser starts at end_dirs[1], but we need it at move.end_direction
   -- If they don't match, flip ends
   if trav:get_direction() ~= move.end_direction then trav:flip_ends() end

   return trav
end

---Check if a rail already exists at position matching prototype and direction
---@param surface LuaSurface
---@param position MapPosition
---@param prototype_name string
---@param direction defines.direction
---@return LuaEntity|nil
local function find_matching_rail(surface, position, prototype_name, direction)
   local floor_x = math.floor(position.x)
   local floor_y = math.floor(position.y)
   local search_area = {
      { x = floor_x + 0.001, y = floor_y + 0.001 },
      { x = floor_x + 0.999, y = floor_y + 0.999 },
   }

   local entities = surface.find_entities_filtered({
      area = search_area,
      name = prototype_name,
   })

   for _, entity in ipairs(entities) do
      if entity.direction == direction then return entity end
   end

   return nil
end

---Build a rail at the specified position
---@param pindex integer
---@param surface LuaSurface
---@param position MapPosition
---@param rail_type railutils.RailType
---@param placement_direction defines.direction
---@return LuaEntity|nil entity The created entity, or nil if rail already exists
local function try_build_rail(pindex, surface, position, rail_type, placement_direction)
   local player = game.get_player(pindex)
   if not player then return nil end

   local prototype_name = Queries.rail_type_to_prototype_type(rail_type)

   -- Check if matching rail already exists
   local existing = find_matching_rail(surface, position, prototype_name, placement_direction)
   if existing then
      -- Rail already exists, don't build or play sound
      return nil
   end

   -- Build the rail
   local entity = surface.create_entity({
      name = prototype_name,
      position = position,
      direction = placement_direction,
      force = player.force,
      raise_built = false,
   })

   if entity then
      -- Play build sound
      surface.play_sound({ path = "utility/build_medium", position = position })
   end

   return entity
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
   table.insert(state.moves, {
      position = { x = position.x, y = position.y },
      end_direction = end_direction,
      rail_type = rail_type,
      placement_direction = placement_direction,
      entity = entity,
      is_bookmark = is_bookmark or false,
   })
end

---Pop a move from the stack
---@param pindex integer
---@return vtd.Move|nil The popped move, or nil if stack empty
local function pop_move(pindex)
   local state = vtd_storage[pindex]
   if #state.moves == 0 then return nil end

   local move = table.remove(state.moves)

   -- Destroy entity if it exists
   if move.entity and move.entity.valid then move.entity.destroy() end

   return move
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
   mb:fragment("virtual train facing"):fragment({ "fa.direction", current.end_direction })

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
   local trav = Traverser.new(rail_type, position, end_direction)
   move_fn(trav)

   -- Get expected next rail
   local expected_pos = trav:get_position()
   local expected_direction = trav:get_placement_direction()
   local expected_type = Queries.rail_type_to_prototype_type(trav:get_rail_kind())

   -- Floor positions for comparison
   local expected_floor_x = math.floor(expected_pos.x)
   local expected_floor_y = math.floor(expected_pos.y)

   local search_area = {
      { x = expected_floor_x + 0.001, y = expected_floor_y + 0.001 },
      { x = expected_floor_x + 0.999, y = expected_floor_y + 0.999 },
   }

   -- Find rails at next position
   local rails_at_pos = rail_entity.surface.find_entities_filtered({
      area = search_area,
      type = Consts.RAIL_TYPES,
   })

   -- Check if any rail matches what we expect
   for _, connected_rail in ipairs(rails_at_pos) do
      local rail_floor_x = math.floor(connected_rail.position.x)
      local rail_floor_y = math.floor(connected_rail.position.y)
      local pos_match = rail_floor_x == expected_floor_x and rail_floor_y == expected_floor_y
      local type_match = connected_rail.name == expected_type
      local direction_match = connected_rail.direction == expected_direction

      if pos_match and type_match and direction_match then return true end
   end

   return false
end

---Count total connections (forward, left, right) for a rail end
---@param rail_entity LuaEntity
---@param end_direction defines.direction
---@return integer count Number of connections (0-3)
local function count_connections(rail_entity, end_direction)
   local rail_type = Queries.prototype_type_to_rail_type(rail_entity.name)
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
   local rail_type = Queries.prototype_type_to_rail_type(rail_entity.name)
   if not rail_type then error(string.format("%s not a rail!", rail_entity.name)) end

   local end_dirs = Queries.get_end_directions(rail_type, rail_entity.direction)
   if #end_dirs ~= 2 then error("Rail data corrupt!") end

   -- Count connections at each end
   local end1_connections = count_connections(rail_entity, end_dirs[1])
   local end2_connections = count_connections(rail_entity, end_dirs[2])

   -- Prefer the end with no connections.
   if end1_connections == 0 then
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
function mod.lock_on_to_rail(pindex, rail_entity)
   local player = game.get_player(pindex)
   if not player then return end

   -- Check if player has rail planner
   if not has_rail_planner(player) then
      Speech.speak(pindex, { "fa.virtual-train-need-planner" })
      return
   end

   -- Get rail entity (use provided one or player.selected)
   local rail = rail_entity or player.selected

   -- Check if rail is valid (check entity type)
   if not rail or not rail.valid or not Consts.RAIL_TYPES_SET[rail.type] then
      Speech.speak(pindex, { "fa.virtual-train-no-rail" })
      return
   end

   -- Convert entity name to rail type
   local rail_type = Queries.prototype_type_to_rail_type(rail.name)
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

   -- Add initial rail to moves (entity = rail, not nil, but we won't destroy it on undo)
   -- Actually, use nil since it already exists and we shouldn't destroy it
   push_move(pindex, rail.position, chosen_end_direction, rail_type, rail.direction, nil, false)

   -- Set cursor position
   local vp = Viewpoint.get_viewpoint(pindex)
   vp:set_cursor_pos(rail.position)

   -- Announce lock-on with end direction
   local mb = MessageBuilder.new()
   mb:fragment({ "fa.virtual-train-locked" }):fragment("facing"):fragment({ "fa.direction", chosen_end_direction })
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
local function move_in_direction(pindex, move_func, direction_name)
   local player = game.get_player(pindex)
   if not player then return end

   local current = get_current_move(pindex)
   if not current then return end

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
      -- In speculation mode, update the speculation_start state (which is what we'll restore to)
      state.speculation_start.position = new_pos
      state.speculation_start.end_direction = new_end_dir
      state.speculation_start.rail_type = new_rail_type
      state.speculation_start.placement_direction = new_placement_dir

      -- Update cursor position (caller will read tile)
      local vp = Viewpoint.get_viewpoint(pindex)
      vp:set_cursor_pos(new_pos)
   else
      -- Build mode: try to build rail
      local entity = try_build_rail(pindex, player.surface, new_pos, new_rail_type, new_placement_dir)

      -- Add to moves
      push_move(pindex, new_pos, new_end_dir, new_rail_type, new_placement_dir, entity, false)

      -- Update cursor position (caller will read tile)
      local vp = Viewpoint.get_viewpoint(pindex)
      vp:set_cursor_pos(new_pos)
   end
end

---Extend forward
---@param pindex integer
function mod.extend_forward(pindex)
   move_in_direction(pindex, function(trav)
      trav:move_forward()
   end, "forward")
end

---Extend left
---@param pindex integer
function mod.extend_left(pindex)
   move_in_direction(pindex, function(trav)
      trav:move_left()
   end, "left")
end

---Extend right
---@param pindex integer
function mod.extend_right(pindex)
   move_in_direction(pindex, function(trav)
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
   mb:fragment({ "fa.virtual-train-flipped" }):fragment("now facing"):fragment({ "fa.direction", trav:get_direction() })
   Speech.speak(pindex, mb:build())
end

---Toggle speculation mode
---@param pindex integer
function mod.toggle_speculation(pindex)
   local state = vtd_storage[pindex]
   local current = get_current_move(pindex)
   if not current then return end

   if state.speculating then
      -- Exit speculation: restore state from speculation_start
      local saved = state.speculation_start
      push_move(pindex, saved.position, saved.end_direction, saved.rail_type, saved.placement_direction, nil, false)

      -- Update cursor position
      local vp = Viewpoint.get_viewpoint(pindex)
      vp:set_cursor_pos(saved.position)

      state.speculating = false
      state.speculation_start = nil

      Speech.speak(pindex, { "fa.virtual-train-speculation-exit" })
   else
      -- Enter speculation: save current state
      state.speculating = true
      state.speculation_start = {
         position = { x = current.position.x, y = current.position.y },
         end_direction = current.end_direction,
         rail_type = current.rail_type,
         placement_direction = current.placement_direction,
      }

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
function mod.return_to_bookmark(pindex)
   local state = vtd_storage[pindex]

   if state.speculating then
      Speech.speak(pindex, { "fa.virtual-train-cannot-use-bookmark-speculating" })
      return
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
      return
   end

   -- Remove all moves after bookmark
   local removed_count = 0
   while #state.moves > bookmark_index do
      pop_move(pindex)
      removed_count = removed_count + 1
   end

   -- Update cursor position
   local current = get_current_move(pindex)
   if current then
      local vp = Viewpoint.get_viewpoint(pindex)
      vp:set_cursor_pos(current.position)
   end

   Speech.speak(pindex, { "fa.virtual-train-returned-to-bookmark", removed_count })
end

---Backspace (undo last move)
---@param pindex integer
function mod.backspace(pindex)
   local state = vtd_storage[pindex]

   if state.speculating then
      Speech.speak(pindex, { "fa.virtual-train-cannot-undo-speculating" })
      return
   end

   pop_move(pindex)

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

---Place signal
---@param pindex integer
---@param side "left"|"right"
---@param is_chain boolean
function mod.place_signal(pindex, side, is_chain)
   local player = game.get_player(pindex)
   if not player then return end

   local current = get_current_move(pindex)
   if not current then return end

   local trav = create_traverser_from_move(current)

   local signal_side = side == "left" and Traverser.SignalSide.LEFT or Traverser.SignalSide.RIGHT
   local signal_pos = trav:get_signal_pos(signal_side)
   local signal_dir = trav:get_signal_direction(signal_side)

   local signal_name = is_chain and "rail-chain-signal" or "rail-signal"

   local entity = player.surface.create_entity({
      name = signal_name,
      position = signal_pos,
      direction = signal_dir,
      force = player.force,
      raise_built = false,
   })

   if entity then
      player.surface.play_sound({ path = "utility/build_small", position = signal_pos })
      Speech.speak(pindex, { "fa.virtual-train-signal-placed", signal_name, side })
   else
      Speech.speak(pindex, { "fa.virtual-train-signal-failed", side })
   end
end

---Main keyboard action handler
---@param event EventData
---@return boolean handled
function mod.on_kb_descriptive_action_name(event)
   local pindex = event.player_index
   local state = vtd_storage[pindex]

   if not state.locked then return false end

   local player = game.get_player(pindex)
   if not player or not has_rail_planner(player) then
      unlock_from_rails(pindex, true)
      return false
   end

   local action = event.input_name

   -- Movement
   if action == "fa-comma" then
      mod.extend_forward(pindex)
      return true
   elseif action == "fa-m" then
      mod.extend_left(pindex)
      return true
   elseif action == "fa-dot" then
      mod.extend_right(pindex)
      return true
   elseif action == "fa-a-comma" then
      mod.flip_end(pindex)
      return true
   end

   -- Speculation
   if action == "fa-slash" then
      mod.toggle_speculation(pindex)
      return true
   end

   -- Bookmarks
   if action == "fa-s-b" then
      mod.create_bookmark(pindex)
      return true
   elseif action == "fa-b" then
      mod.return_to_bookmark(pindex)
      return true
   end

   -- Signals
   if action == "fa-c-m" then
      mod.place_signal(pindex, "left", true)
      return true
   elseif action == "fa-c-dot" then
      mod.place_signal(pindex, "right", true)
      return true
   elseif action == "fa-s-m" then
      mod.place_signal(pindex, "left", false)
      return true
   elseif action == "fa-s-dot" then
      mod.place_signal(pindex, "right", false)
      return true
   end

   -- Status
   if action == "fa-k" then
      announce_rail(pindex)
      return true
   end

   -- Undo
   if action == "fa-backspace" then
      mod.backspace(pindex)
      return true
   end

   return false
end

return mod
