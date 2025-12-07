--[[
Grid Sonifier Constants - Enumerations for grid-based sonification.
]]

local mod = {}

---Grid types for categorizing sonification events
---@enum fa.GridSonifier.Grid
mod.GRIDS = {
   CRAFTING_STRUCTURES = "crafting_structures",
}

-- Grid configuration
mod.GRID_SIZE = 4 -- 4x4 grid = 16 cells

-- Maximum events per cell before switching to deduplication mode
mod.EVENTS_PER_CELL_LIMIT = 3

-- Tick interval for sonifier updates (0.1 seconds at 60 ticks/second)
-- TODO: restore to 6 after testing
mod.TICK_INTERVAL = 1

return mod
