--[[
Force Ghost Enabler - Ensures destroyed entities leave ghosts for all player forces.

Checks once per second that all forces with players have create_ghost_on_entity_death enabled, and silently enables it
if not.  The effect is that early game before construction bots, players get the ability to see ghosts instead of
remnants, which provides a better experience and allows one to find destroyed entities with the scanner.

We do this as a periodic check because it picks up new forces transparently and handles older saves as well.
]]

local mod = {}

-- Check interval: once per second (60 ticks)
local CHECK_INTERVAL = 60

---On tick handler - ensures ghost creation is enabled for all player forces
function mod.on_tick()
   if game.tick % CHECK_INTERVAL ~= 0 then return end

   for _, force in pairs(game.forces) do
      -- Skip forces with no players
      if #force.players == 0 then goto continue end

      -- Enable ghost creation if not already enabled
      if not force.create_ghost_on_entity_death then force.create_ghost_on_entity_death = true end

      ::continue::
   end
end

return mod
