--- Basic rail operations using LuaRailEnd API
-- Provides core functions for rail traversal and analysis

local mod = {}

-- Get the exit directions from both ends of a rail entity
---@param entity LuaEntity - The rail entity
---@param planner_name string - The rail planner item name (usually "rail")
---@return defines.direction[] - Array with up to 2 elements: [front_direction, back_direction]
function mod.get_rail_end_directions(entity, planner_name)
   local front_end = entity.get_rail_end(defines.rail_direction.front)
   local back_end = entity.get_rail_end(defines.rail_direction.back)

   local ret = {}
   if front_end then table.insert(ret, front_end.location.direction) end
   if back_end then table.insert(ret, back_end.location.direction) end

   return ret
end

-- Get directions from rail ends that have no connections
---@param entity LuaEntity - The rail entity
---@param planner_name string - The rail planner item name (usually "rail")
---@return defines.direction[] - Array with up to 2 elements containing directions of unconnected ends
function mod.get_empty_directions(entity, planner_name)
   local empty_directions = {}

   -- Check front end
   local front_end = entity.get_rail_end(defines.rail_direction.front)
   assert(front_end)
   local front_dir = front_end.location.direction
   if not front_end.move_natural() then table.insert(empty_directions, front_dir) end

   local back_end = entity.get_rail_end(defines.rail_direction.back)
   assert(back_end)
   local back_end_dir = back_end.location.direction
   if not back_end.move_natural() then table.insert(empty_directions, back_end_dir) end

   return empty_directions
end

return mod
