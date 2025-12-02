---Game Surface Implementation
---
---Wraps a real Factorio LuaSurface to provide the railutils.RailsSurface interface

require("polyfill")

local RailInfo = require("railutils.rail-info")

local mod = {}

---Description of rail entity names to use for queries
---@class railutils.RailPlannerDescription
---@field straight_rail_name string Entity name for straight rails
---@field curved_rail_a_name string Entity name for curved-rail-a
---@field curved_rail_b_name string Entity name for curved-rail-b
---@field half_diagonal_rail_name string Entity name for half-diagonal rails

---Options for wrapping a surface
---@class railutils.SurfaceWrapperOpts
---@field planner_description railutils.RailPlannerDescription Rail entity names to query
---@field ghosts_only boolean? If true, only query ghost rails; if false/nil, only query real rails

---Wrapped surface implementing railutils.RailsSurface
---@class railutils.GameSurface : railutils.RailsSurface
---@field _surface LuaSurface The underlying Factorio surface
---@field _planner railutils.RailPlannerDescription Rail entity names
---@field _ghosts_only boolean Whether to query ghosts only
local GameSurface = {}
local GameSurface_meta = { __index = GameSurface }

---Wrap a Factorio surface for use with railutils
---@param surface LuaSurface The Factorio surface to wrap
---@param opts railutils.SurfaceWrapperOpts Configuration options
---@return railutils.GameSurface
function mod.wrap_surface(surface, opts)
   return setmetatable({
      _surface = surface,
      _planner = opts.planner_description,
      _ghosts_only = opts.ghosts_only or false,
   }, GameSurface_meta)
end

---Map entity name to RailType
---@param entity_name string
---@param planner railutils.RailPlannerDescription
---@return railutils.RailType|nil
local function entity_name_to_rail_type(entity_name, planner)
   if entity_name == planner.straight_rail_name then
      return RailInfo.RailType.STRAIGHT
   elseif entity_name == planner.curved_rail_a_name then
      return RailInfo.RailType.CURVE_A
   elseif entity_name == planner.curved_rail_b_name then
      return RailInfo.RailType.CURVE_B
   elseif entity_name == planner.half_diagonal_rail_name then
      return RailInfo.RailType.HALF_DIAGONAL
   end
   return nil
end

---Get rails at a specific tile position
---@param point fa.Point Tile coordinates (1x1 grid)
---@return railutils.RailInfo[]
function GameSurface:get_rails_at_point(point)
   local floor_x = math.floor(point.x)
   local floor_y = math.floor(point.y)

   -- Use same pattern as entity-selection.lua for tile queries
   local search_area = {
      { x = floor_x + 0.001, y = floor_y + 0.001 },
      { x = floor_x + 0.999, y = floor_y + 0.999 },
   }

   -- Query for all rail types
   local rail_names = {
      self._planner.straight_rail_name,
      self._planner.curved_rail_a_name,
      self._planner.curved_rail_b_name,
      self._planner.half_diagonal_rail_name,
   }

   local rails = {}

   for _, rail_name in ipairs(rail_names) do
      local filter = { area = search_area }
      if self._ghosts_only then
         filter.ghost_name = rail_name
      else
         filter.name = rail_name
      end

      local entities = self._surface.find_entities_filtered(filter)

      for _, entity in ipairs(entities) do
         -- For ghosts, use ghost_name; for real entities, use name
         local entity_name = self._ghosts_only and entity.ghost_name or entity.name
         local rail_type = entity_name_to_rail_type(entity_name, self._planner)
         if rail_type then
            table.insert(rails, {
               prototype_position = {
                  x = entity.position.x,
                  y = entity.position.y,
               },
               rail_type = rail_type,
               direction = entity.direction,
               unit_number = entity.unit_number,
            })
         end
      end
   end

   return rails
end

return mod
