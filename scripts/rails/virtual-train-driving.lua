---Virtual Train Driving
---
---Turtle graphics-style rail building where player "drives" a virtual train that lays tracks

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

---Determine which end of a rail to start from
---@param rail_entity LuaEntity
---@return defines.rail_direction The LuaRailEnd direction (front or back)
local function determine_initial_end(rail_entity)
   -- Try both ends, pick the one with no forward connection
   local front = rail_entity.get_rail_end(defines.rail_direction.front)
   local back = rail_entity.get_rail_end(defines.rail_direction.back)

   -- Try to move naturally from each end (checks if rails are connected)
   local front_copy = front.make_copy()
   local front_can_move = front_copy.move_natural()

   local back_copy = back.make_copy()
   local back_can_move = back_copy.move_natural()

   -- If one end has no forward connection, use that
   if not front_can_move then
      return defines.rail_direction.front
   elseif not back_can_move then
      return defines.rail_direction.back
   end

   -- Both have connections, use front (lower direction number / most counterclockwise)
   return defines.rail_direction.front
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

   -- Check if rail is valid
   if not rail or not rail.valid or rail.type ~= "straight-rail" then
      Speech.speak(pindex, { "fa.virtual-train-no-rail" })
      return
   end

   -- Determine which end to use
   local lua_rail_direction = determine_initial_end(rail)

   -- Convert entity name to rail type
   local rail_type = Queries.prototype_type_to_rail_type(rail.name)
   if not rail_type then
      Speech.speak(pindex, { "fa.virtual-train-no-rail-info" })
      return
   end

   -- Get the end directions from our rail data
   local end_dirs = Queries.get_end_directions(rail_type, rail.direction)

   -- Map LuaRailEnd direction to our end direction
   -- front = lower index (end_dirs[1]), back = higher index (end_dirs[2])
   local chosen_end_direction = lua_rail_direction == defines.rail_direction.front and end_dirs[1] or end_dirs[2]

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

   local signal_pos
   if side == "left" then
      signal_pos = trav:get_signal_pos(Traverser.SignalSide.LEFT)
   else
      signal_pos = trav:get_signal_pos(Traverser.SignalSide.RIGHT)
   end

   local signal_name = is_chain and "rail-chain-signal" or "rail-signal"

   local entity = player.surface.create_entity({
      name = signal_name,
      position = signal_pos,
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
