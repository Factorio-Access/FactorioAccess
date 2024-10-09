local mod = {}

---@enum fa.scanner.Category
mod.CATEGORIES = {
   ALL = "all",
   RESOURCES = "resources",
   ENEMIES = "enemies",
   LOGISTICS = "logistics",
   PRODUCTION = "production",
   VEHICLES = "vehicles",
   TRAINS = "trains",
   GHOSTS = "ghosts",
   PLAYERS = "players", -- actually character.
   OTHER = "other",
   MILITARY = "military",
   REMNANTS = "remnants",
   CONTAINERS = "containers",
   CORPSES = "corpses",
}

-- The desired order of categories when moving through the scanner.
mod.CATEGORY_ORDER = {
   mod.CATEGORIES.ALL,
   mod.CATEGORIES.RESOURCES,
   mod.CATEGORIES.ENEMIES,
   mod.CATEGORIES.REMNANTS,
   mod.CATEGORIES.PRODUCTION,
   mod.CATEGORIES.LOGISTICS,
   mod.CATEGORIES.CONTAINERS,
   mod.CATEGORIES.MILITARY,
   mod.CATEGORIES.VEHICLES,
   mod.CATEGORIES.TRAINS,
   mod.CATEGORIES.GHOSTS,
   mod.CATEGORIES.PLAYERS,
   mod.CATEGORIES.CORPSES,
   mod.CATEGORIES.OTHER,
}

-- How far can the scanner see, in tiles?
--
-- Old scanner did a 5000x5000 square. This is a radius of a circle, so 2500 is
-- a (rough) equivalent.
mod.SCANNER_DISTANCE = 2500

-- How far apart may trees be to count as a forest? Note that changing this
-- value has a very outsized effect and can cause the clusterer to cluster
-- thousands of wood into one forest.  Also, this is effectively a radius.
mod.FOREST_TREE_DIST = 4

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

-- How far apart must tiles be to be in the same body of water?  2.1 is chosen
-- because it allows for tiny bits of land not to get in the way, causes
-- diagonal tiles to connect, and leaves a bit of room for floating point error.
mod.WATER_TILE_DISTANCE = 10

-- Modded water is mostly not a thing. If it is we can extend the list.
mod.WATER_PROTOS =
   { "water", "deepwater", "water-green", "deepwater-green", "water-shallow", "water-mud", "water-wube" }

return mod
