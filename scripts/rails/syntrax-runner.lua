---Syntrax runner - executes syntrax code and places rails in game
---
---Uses build-helpers to place rails as ghosts, then revives them.
---On failure, all placed ghosts are destroyed.

local BuildHelpers = require("scripts.rails.build-helpers")
local Syntrax = require("syntrax")

local mod = {}

---Execute syntrax code and place rails
---@param pindex integer
---@param source string Syntrax source code
---@param initial_position MapPosition Starting position
---@param initial_direction defines.direction Starting direction (0-15)
---@return LuaEntity[]|nil entities The placed rails, or nil on failure
---@return string|nil error Error message if failed
function mod.execute(pindex, source, initial_position, initial_direction)
   -- Parse and execute syntrax
   local rails, err = Syntrax.execute(source, initial_position, initial_direction)
   if err then return nil, err.message end

   -- Handle empty result
   if not rails or #rails == 0 then return {}, nil end

   -- Convert syntrax output to placement format
   -- Syntrax rail_type is already the prototype name ("straight-rail", etc.)
   local placements = {}
   for _, rail in ipairs(rails) do
      table.insert(placements, {
         name = rail.rail_type,
         position = rail.position,
         direction = rail.placement_direction,
      })
   end

   -- Place all as ghosts
   local ghosts = BuildHelpers.place_ghosts(pindex, placements)
   if not ghosts then return nil, "Failed to place rails" end

   -- Revive all ghosts (rails are free for now)
   local entities = BuildHelpers.revive_ghosts(ghosts)
   return entities, nil
end

return mod
