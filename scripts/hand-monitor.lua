--- Hand monitoring suppression
---
--- Allows temporarily suppressing hand change events for a player.
--- Used when swapping the hand out and back within the same tick (e.g., rail building).

local mod = {}

-- Players with suppressed hand monitoring this tick
-- Cleared at end of each tick via on_tick
---@type table<integer, boolean>
local suppressed_this_tick = {}

---Check if hand monitoring is enabled for a player
---@param pindex integer
---@return boolean
function mod.is_enabled(pindex)
   return not suppressed_this_tick[pindex]
end

---Disable hand monitoring for a player for the remainder of this tick
---@param pindex integer
function mod.suppress_this_tick(pindex)
   suppressed_this_tick[pindex] = true
end

---Clear all suppression flags (call at end of each tick)
function mod.on_tick()
   suppressed_this_tick = {}
end

return mod
