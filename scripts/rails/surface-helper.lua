---Surface Helper for Rails
---
---Provides convenient access to GameSurface with rail planner descriptions

local GameSurface = require("railutils.surface-impls.game-surface")

local mod = {}

---Extract rail planner description from a rail planner item prototype
---@param rail_planner_prototype LuaItemPrototype
---@return railutils.RailPlannerDescription|nil
function mod.get_planner_description(rail_planner_prototype)
   if not rail_planner_prototype.rails then return nil end

   local rails = rail_planner_prototype.rails

   -- Map rail prototypes to the description structure
   -- Rails array contains LuaEntityPrototype objects for each rail type
   local description = {
      straight_rail_name = nil,
      curved_rail_a_name = nil,
      curved_rail_b_name = nil,
      half_diagonal_rail_name = nil,
   }

   for _, rail_proto in ipairs(rails) do
      local name = rail_proto.name
      if name:match("straight%-rail") then
         description.straight_rail_name = name
      elseif name:match("curved%-rail%-a") then
         description.curved_rail_a_name = name
      elseif name:match("curved%-rail%-b") then
         description.curved_rail_b_name = name
      elseif name:match("half%-diagonal%-rail") then
         description.half_diagonal_rail_name = name
      end
   end

   -- Validate we got all rail types
   if
      not description.straight_rail_name
      or not description.curved_rail_a_name
      or not description.curved_rail_b_name
      or not description.half_diagonal_rail_name
   then
      return nil
   end

   return description
end

---Wrap a surface for rail queries using the player's current rail planner
---@param surface LuaSurface
---@param player LuaPlayer
---@return railutils.GameSurface|nil
function mod.wrap_surface_for_player(surface, player)
   if not player.cursor_stack or not player.cursor_stack.valid_for_read then return nil end

   local prototype = player.cursor_stack.prototype
   if not prototype.rails then return nil end

   local planner_description = mod.get_planner_description(prototype)
   if not planner_description then return nil end

   return GameSurface.wrap_surface(surface, {
      planner_description = planner_description,
   })
end

---Wrap a surface for rail queries using vanilla rail names
---@param surface LuaSurface
---@return railutils.GameSurface
function mod.wrap_surface_vanilla(surface)
   local planner_description = {
      straight_rail_name = "straight-rail",
      curved_rail_a_name = "curved-rail-a",
      curved_rail_b_name = "curved-rail-b",
      half_diagonal_rail_name = "half-diagonal-rail",
   }

   return GameSurface.wrap_surface(surface, {
      planner_description = planner_description,
   })
end

return mod
