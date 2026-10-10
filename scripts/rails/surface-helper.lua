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

   -- Rails array contains LuaEntityPrototype objects for each rail type
   ---@type table<string, string?>
   local name_by_type = {}
   for _, rail_proto in ipairs(rails) do
      name_by_type[rail_proto.type] = rail_proto.name
   end

   local straight = name_by_type["straight-rail"]
   local curved_a = name_by_type["curved-rail-a"]
   local curved_b = name_by_type["curved-rail-b"]
   local half_diagonal = name_by_type["half-diagonal-rail"]

   -- Validate we got all rail types
   if not straight or not curved_a or not curved_b or not half_diagonal then return nil end

   return {
      straight_rail_name = straight,
      curved_rail_a_name = curved_a,
      curved_rail_b_name = curved_b,
      half_diagonal_rail_name = half_diagonal,
   }
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

---Wrap a surface for ghost rail queries using vanilla rail names
---@param surface LuaSurface
---@return railutils.GameSurface
function mod.wrap_surface_vanilla_ghosts(surface)
   local planner_description = {
      straight_rail_name = "straight-rail",
      curved_rail_a_name = "curved-rail-a",
      curved_rail_b_name = "curved-rail-b",
      half_diagonal_rail_name = "half-diagonal-rail",
   }

   return GameSurface.wrap_surface(surface, {
      planner_description = planner_description,
      ghosts_only = true,
   })
end

return mod
