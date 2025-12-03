---Syntrax runner - executes syntrax code and places rails in game
---
---Uses build-helpers to place rails as ghosts, then revives them.
---On failure, all placed ghosts are destroyed.

local BuildHelpers = require("scripts.rails.build-helpers")
local Syntrax = require("syntrax")

local mod = {}

---Map generic rail type to actual prototype name using rail planner
---@param generic_type string Generic rail type like "straight-rail"
---@param planner_description railutils.RailPlannerDescription
---@return string The actual prototype name from the player's rail planner
local function map_rail_type(generic_type, planner_description)
   if generic_type == "straight-rail" then
      return planner_description.straight_rail_name
   elseif generic_type == "curved-rail-a" then
      return planner_description.curved_rail_a_name
   elseif generic_type == "curved-rail-b" then
      return planner_description.curved_rail_b_name
   elseif generic_type == "half-diagonal-rail" then
      return planner_description.half_diagonal_rail_name
   else
      error("Unknown rail type: " .. tostring(generic_type))
   end
end

---Execute syntrax code and place rails
---@param pindex integer
---@param source string Syntrax source code
---@param initial_position MapPosition Starting position
---@param initial_direction defines.direction Starting direction (0-15)
---@param planner_description railutils.RailPlannerDescription Rail planner to use for prototype names
---@param build_mode defines.build_mode Build mode for placement
---@return LuaEntity[]|nil entities The placed rails/ghosts, or nil on failure
---@return string|nil error Error message if failed
function mod.execute(pindex, source, initial_position, initial_direction, planner_description, build_mode)
   -- Parse and execute syntrax
   local rails, err = Syntrax.execute(source, initial_position, initial_direction)
   if err then return nil, err.message end

   -- Handle empty result
   if not rails or #rails == 0 then return {}, nil end

   -- Convert syntrax output to placement format using rail planner prototypes
   local placements = {}
   for _, rail in ipairs(rails) do
      table.insert(placements, {
         name = map_rail_type(rail.rail_type, planner_description),
         position = rail.position,
         direction = rail.placement_direction,
      })
   end

   -- Place all as ghosts
   local ghosts = BuildHelpers.place_ghosts(pindex, placements, build_mode)
   if not ghosts then return nil, "Failed to place rails" end

   -- In normal mode, revive ghosts (rails are free for now)
   -- In forced/superforced mode, leave as ghosts for bots
   if build_mode == defines.build_mode.normal then
      local entities = BuildHelpers.revive_ghosts(ghosts)
      return entities, nil
   else
      return ghosts, nil
   end
end

return mod
