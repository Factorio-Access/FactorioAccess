--[[
Pipe-to-ground backend for build lock.

Moving in a straight line lays chained pairs. The run's first tile gets an entrance once the second tile says which
way the line goes. When the line passes the pair's reach, the exit goes as far along as it can and the next entrance
on the tile after it, so the pairs connect above ground. Both tiles must be free: when they are not, the exit steps
back. A pair cannot turn and a corner needs a plain pipe, so turning ends build lock. Stopping leaves the last entrance
open; the player places its exit.

Tiles arrive one at a time and each is used up at once (the queue keeps only 10, shorter than a reach); the run in
build_state.backend_state remembers the entrance, and the exit is chosen from the entrance's position alone.

Any pipe-to-ground prototype with one underground connection and a normal connection opposite it is handled: the reach
and which side of the entity goes underground come from the prototype, so mods that change them work. Others (several
underground connections, a bend) fall through to the simple backend.
]]

local BuildLock = require("scripts.build-lock")
local FaUtils = require("scripts.fa-utils")

local BuildAction = BuildLock.BuildAction
local mod = {}

mod.name = "pipe-to-ground"

---@class fa.BuildLock.PipeToGroundSpec
---@field reach integer The farthest an exit can be from its entrance, in tiles
---@field fluidbox integer The fluidbox holding the underground connection
---@field underground_turn integer What to add to the entity's direction to get the side that goes underground

---@type table<string, fa.BuildLock.PipeToGroundSpec|false>
local specs = {}

---@param proto LuaEntityPrototype
---@return fa.BuildLock.PipeToGroundSpec?
local function read_spec(proto)
   if proto.type ~= "pipe-to-ground" then return nil end
   ---@type { fluidbox: integer, connection: PipeConnectionDefinition }[]
   local underground = {}
   ---@type table<defines.direction, true>
   local normal = {}
   for i, fluidbox in ipairs(proto.fluidbox_prototypes) do
      for _, c in ipairs(fluidbox.pipe_connections) do
         if c.connection_type == "underground" then
            table.insert(underground, { fluidbox = i, connection = c })
         elseif c.connection_type == "normal" then
            normal[c.direction] = true
         end
      end
   end
   local u = underground[1]
   if #underground ~= 1 or not normal[FaUtils.rotate_180(u.connection.direction)] then return nil end
   ---@type fa.BuildLock.PipeToGroundSpec
   local spec = {
      reach = u.connection.max_underground_distance or assert(proto.max_underground_distance),
      fluidbox = u.fluidbox,
      underground_turn = (u.connection.direction - defines.direction.north) --[[@as integer]],
   }
   return spec
end

---@param proto LuaEntityPrototype
---@return fa.BuildLock.PipeToGroundSpec?
local function spec_of(proto)
   local spec = specs[proto.name]
   if spec == nil then
      spec = read_spec(proto) or false
      specs[proto.name] = spec
   end
   if spec then return spec end
   return nil
end

---@param item_prototype LuaItemPrototype
---@return boolean
function mod.can_handle(item_prototype)
   local place = item_prototype.place_result
   return place ~= nil and spec_of(place) ~= nil
end

-- One tile in each cardinal direction
---@type table<defines.direction, { x: integer, y: integer }>
local STEP = {
   [defines.direction.north] = { x = 0, y = -1 },
   [defines.direction.east] = { x = 1, y = 0 },
   [defines.direction.south] = { x = 0, y = 1 },
   [defines.direction.west] = { x = -1, y = 0 },
}

---The entity direction whose underground side faces `side`.
---@param spec fa.BuildLock.PipeToGroundSpec
---@param side defines.direction
---@return defines.direction
local function facing_underground(spec, side)
   return ((side - spec.underground_turn) % 16) --[[@as defines.direction]]
end

---@class fa.BuildLock.PipeToGroundRun
---@field x integer The entrance's tile, or before it is placed the tile it will go on
---@field y integer
---@field direction defines.direction? The way the line goes; nil until the entrance is placed
---@field entrance LuaEntity?

---@param x integer
---@param y integer
---@return fa.Point
local function centre(x, y)
   return { x = x + 0.5, y = y + 0.5 }
end

---@param context fa.BuildLock.BuildContext
---@param x integer
---@param y integer
---@param direction defines.direction
---@return boolean
local function can_build(context, x, y, direction)
   return context.player.can_build_from_cursor({ position = centre(x, y), direction = direction })
end

---Whether the exit's underground connection reaches its own entrance and not another pipe in the line.
---@param spec fa.BuildLock.PipeToGroundSpec
---@param exit LuaEntity
---@param entrance LuaEntity
---@return boolean
local function joined(spec, exit, entrance)
   for _, c in ipairs(assert(exit.get_fluid_box_pipe_connections(spec.fluidbox))) do
      if c.connection_type == "underground" and c.target == entrance then return true end
   end
   return false
end

---Close the run: the exit as far along as both it and the next entrance fit, then the next entrance.
---@param spec fa.BuildLock.PipeToGroundSpec
---@param run fa.BuildLock.PipeToGroundRun
---@param context fa.BuildLock.BuildContext
---@param helpers fa.BuildLock.BuildHelpers
---@return string? action Nil when the run moved on to the new entrance
local function close_run(spec, run, context, helpers)
   local dir = assert(run.direction)
   local step = STEP[dir]
   local exit_dir = facing_underground(spec, FaUtils.rotate_180(dir))
   local entrance_dir = facing_underground(spec, dir)
   for e = spec.reach, 1, -1 do
      local ex, ey = run.x + step.x * e, run.y + step.y * e
      local nx, ny = ex + step.x, ey + step.y
      if can_build(context, ex, ey, exit_dir) then
         if not can_build(context, nx, ny, entrance_dir) then
            -- The character on the next entrance's tile moves on; anything else, try a shorter pair
            if helpers:is_blocked_by_own_entity(centre(nx, ny), helpers.entity_prototype, entrance_dir) then
               return BuildAction.RETRY
            end
         else
            local exit = helpers:build_entity(centre(ex, ey), exit_dir)
            if not exit then return BuildAction.RETRY end
            if not joined(spec, exit, assert(run.entrance)) then
               helpers:set_fail_reason("fa.build-lock-reason-pipe-to-ground-not-joined")
               return BuildAction.FAIL
            end
            local entrance = helpers:build_entity(centre(nx, ny), entrance_dir)
            if not entrance then
               helpers:set_fail_reason("fa.build-lock-reason-pipe-to-ground-no-room")
               return BuildAction.FAIL
            end
            run.x, run.y, run.entrance = nx, ny, entrance
            return nil
         end
      end
   end
   helpers:set_fail_reason("fa.build-lock-reason-pipe-to-ground-no-room")
   return BuildAction.FAIL
end

---Every tile in turn, the one under the cursor or character too: nothing goes on it but a next entrance, which waits
---for the character to move off.
---@param pending_tiles table
---@return {action: string, tile_index: number}?
function mod.select_tile_to_build(pending_tiles)
   if #pending_tiles == 0 then return nil end
   return { action = BuildAction.PLACED, tile_index = 1 }
end

---@param context fa.BuildLock.BuildContext
---@param helpers fa.BuildLock.BuildHelpers
---@return string action
function mod.build(context, helpers)
   local spec = assert(spec_of(assert(context.entity_prototype)))
   local build_state = helpers.build_state
   local x, y = math.floor(context.current_position.x), math.floor(context.current_position.y)
   local dir = context.movement_direction

   local run = build_state.backend_state --[[@as fa.BuildLock.PipeToGroundRun?]]
   if not run or (run.entrance and not run.entrance.valid) then
      -- The run starts here; the next tile says which way it goes
      build_state.backend_state = { x = x, y = y }
      return BuildAction.SKIP
   end

   local step = STEP[dir]
   if not run.entrance then
      if x ~= run.x + step.x or y ~= run.y + step.y then
         run.x, run.y = x, y
         return BuildAction.SKIP
      end
      local entrance_dir = facing_underground(spec, dir)
      local entrance = helpers:build_entity(centre(run.x, run.y), entrance_dir)
      if not entrance then
         if helpers:is_blocked_by_own_entity(centre(run.x, run.y), helpers.entity_prototype, entrance_dir) then
            return BuildAction.RETRY
         end
         -- Blocked for good: the run starts further on
         run.x, run.y = x, y
         return BuildAction.SKIP
      end
      run.entrance, run.direction = entrance, dir
      return BuildAction.PLACED
   end

   -- A turn, or a step back: a pair cannot follow
   local run_step = STEP[run.direction]
   local along = (x - run.x) * run_step.x + (y - run.y) * run_step.y
   local across = (x - run.x) * run_step.y - (y - run.y) * run_step.x
   if dir ~= run.direction or across ~= 0 or along < 1 then
      helpers:set_fail_reason("fa.build-lock-reason-pipe-to-ground-turn")
      return BuildAction.FAIL
   end

   while along > spec.reach do
      local action = close_run(spec, run, context, helpers)
      if action then return action end
      along = (x - run.x) * run_step.x + (y - run.y) * run_step.y
   end
   return BuildAction.PLACED
end

return mod
