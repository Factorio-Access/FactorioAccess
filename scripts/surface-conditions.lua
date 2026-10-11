--[[
Surface conditions: whether a recipe can be crafted, or an entity built, on a surface.

A prototype's surface_conditions are ranges for surface properties (pressure, gravity, magnetic field...). The
engine refuses hand crafting and building when one fails, but lets a machine be given such a recipe and craft it,
so recipe selection checks it itself.
]]

local Localising = require("scripts.localising")

local mod = {}

---The first of the prototype's surface conditions that the surface fails, or nil when they all hold.
---@param prototype LuaRecipePrototype|LuaEntityPrototype
---@param surface LuaSurface
---@return SurfaceCondition?
function mod.failed_condition(prototype, surface)
   local conditions = prototype.surface_conditions
   if not conditions or surface.ignore_surface_conditions then return nil end
   for _, condition in ipairs(conditions) do
      local value = surface.get_property(condition.property)
      if value < condition.min or value > condition.max then return condition end
   end
   return nil
end

---The game's sentence for a failed condition: "The Pressure is too low."
---@param condition SurfaceCondition
---@param surface LuaSurface
---@return LocalisedString
function mod.failure_reason(condition, surface)
   local property_name = Localising.get_localised_name_with_fallback(prototypes.surface_property[condition.property])
   if surface.get_property(condition.property) < condition.min then
      return { "surface-condition-too-low", property_name }
   end
   return { "surface-condition-too-high", property_name }
end

return mod
