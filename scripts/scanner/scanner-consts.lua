local Consts = require("scripts.consts")

local mod = {}

---@enum fa.scanner.Category
mod.CATEGORIES = {
   ALL = "all",
   RESOURCES = "resources",
   ENEMIES = "enemies",
   LOGISTICSAndPower = "logistics_and_power",
   PRODUCTION = "production",
   VEHICLES = "vehicles",
   SPIDERTRONS = "spidertrons",
   TRAINS = "trains",
   GHOSTS = "ghosts",
   PLAYERS = "players", -- actually character.
   OTHER = "other",
   MILITARY = "military",
   REMNANTS = "remnants",
   CONTAINERS = "containers",
   CORPSES = "corpses",
   TERRAIN = "terrain",
}

-- The desired order of categories when moving through the scanner.
---@type fa.scanner.Category[]
mod.CATEGORY_ORDER = {
   mod.CATEGORIES.ALL,
   mod.CATEGORIES.RESOURCES,
   mod.CATEGORIES.ENEMIES,
   mod.CATEGORIES.REMNANTS,
   mod.CATEGORIES.PRODUCTION,
   mod.CATEGORIES.LOGISTICSAndPower,
   mod.CATEGORIES.CONTAINERS,
   mod.CATEGORIES.MILITARY,
   mod.CATEGORIES.VEHICLES,
   mod.CATEGORIES.SPIDERTRONS,
   mod.CATEGORIES.TRAINS,
   mod.CATEGORIES.GHOSTS,
   mod.CATEGORIES.PLAYERS,
   mod.CATEGORIES.CORPSES,
   mod.CATEGORIES.OTHER,
   mod.CATEGORIES.TERRAIN,
}

-- How far can the scanner see, in tiles?
--
-- Old scanner did a 5000x5000 square. This is a radius of a circle, so 2500 is
-- a (rough) equivalent.
mod.SCANNER_DISTANCE = 2500

-- When this close to a forest, make an entry for the trees the player is near.
mod.FOREST_ZOOM_DISTANCE = 25

-- The size of chunks when handling a forest.  This tunes an algorithm in the
-- tree backend.
--
-- IMPORTANT: changes to this value do not take effect in the current save,
-- because changing it screws up the already computed information.
mod.FOREST_CHUNK_SIZE = 8

-- When this close to an infinite resource, instead of dumping the aggregate,
-- dump the individual resources instead.
mod.INFINITE_RESOURCE_ZOOM_DISTANCE = 50

-- Modded water is mostly not a thing. If it is we can extend the list.
mod.WATER_PROTOS = Consts.WATER_TILE_NAMES

-- No clue if modded icebergs is a thing. If it is we can extend the list.
mod.ICEBERG_PROTOS =
   { "brash-ice", "ice-rough", "ice-smooth", "snow-crests", "snow-flat", "snow-lumpy", "snow-patchy", "ice-platform" }

return mod
