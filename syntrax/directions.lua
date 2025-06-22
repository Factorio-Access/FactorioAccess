--[[
Direction constants matching Factorio's defines.direction.

In Factorio, directions are represented as numbers 0-15, where:
- 0 = North
- 4 = East
- 8 = South
- 12 = West

Each unit represents 1/16th of a full rotation (22.5 degrees).
]]

local mod = {}

-- Direction constants matching Factorio's defines.direction
mod.NORTH = 0
mod.NORTH_NORTHEAST = 1
mod.NORTHEAST = 2
mod.EAST_NORTHEAST = 3
mod.EAST = 4
mod.EAST_SOUTHEAST = 5
mod.SOUTHEAST = 6
mod.SOUTH_SOUTHEAST = 7
mod.SOUTH = 8
mod.SOUTH_SOUTHWEST = 9
mod.SOUTHWEST = 10
mod.WEST_SOUTHWEST = 11
mod.WEST = 12
mod.WEST_NORTHWEST = 13
mod.NORTHWEST = 14
mod.NORTH_NORTHWEST = 15

-- Short names for display
mod.NAMES = {
   [mod.NORTH] = "N",
   [mod.NORTH_NORTHEAST] = "NNE",
   [mod.NORTHEAST] = "NE",
   [mod.EAST_NORTHEAST] = "ENE",
   [mod.EAST] = "E",
   [mod.EAST_SOUTHEAST] = "ESE",
   [mod.SOUTHEAST] = "SE",
   [mod.SOUTH_SOUTHEAST] = "SSE",
   [mod.SOUTH] = "S",
   [mod.SOUTH_SOUTHWEST] = "SSW",
   [mod.SOUTHWEST] = "SW",
   [mod.WEST_SOUTHWEST] = "WSW",
   [mod.WEST] = "W",
   [mod.WEST_NORTHWEST] = "WNW",
   [mod.NORTHWEST] = "NW",
   [mod.NORTH_NORTHWEST] = "NNW",
}

-- Convert a numeric direction to its short name
function mod.to_name(direction)
   return mod.NAMES[direction] or tostring(direction)
end

-- Rotate a direction by a given amount
-- Positive amounts rotate clockwise, negative counterclockwise
function mod.rotate(direction, amount)
   return (direction + amount) % 16
end

-- Get the opposite direction
function mod.opposite(direction)
   return (direction + 8) % 16
end

return mod
