local Consts = require("scripts.consts")
local Functools = require("scripts.functools")
local TH = require("scripts.table-helpers")

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

---@class fa.scanner.TileBodyKind
---@field key string Also the subcategory
---@field tiles string[]
---@field name LocalisedString
---@field category fa.scanner.Category
---@field track_interior boolean
---@field area_scan boolean Counted when the cursor reads an area
---@field space_age boolean?

-- Bodies of tiles the scanner clusters and reads as "name w by h". A kind may list tiles the loaded mods don't have;
-- tile_body_kinds drops those. Foundations are left out on purpose: the scanner never sees tiles placed after a
-- chunk was first scanned.
---@type fa.scanner.TileBodyKind[]
local TILE_BODY_KINDS = {
   {
      key = "water",
      -- Plus Consts.WATER_TILE_NAMES, added below.
      tiles = { "gleba-deep-lake" },
      name = { "tile-name.water" },
      category = mod.CATEGORIES.RESOURCES,
      track_interior = false,
      area_scan = true,
   },
   {
      key = "lava",
      tiles = { "lava", "lava-hot" },
      name = { "tile-name.lava" },
      category = mod.CATEGORIES.RESOURCES,
      track_interior = false,
      area_scan = true,
      space_age = true,
   },
   {
      key = "oil-ocean",
      tiles = { "oil-ocean-shallow", "oil-ocean-shallow-2", "oil-ocean-deep", "oil-ocean-deep-2" },
      name = { "tile-name.oil-ocean-shallow" },
      category = mod.CATEGORIES.RESOURCES,
      track_interior = false,
      area_scan = true,
      space_age = true,
   },
   {
      -- Brash ice blocks walking and building just like the ocean under it.
      key = "ammoniacal-ocean",
      tiles = { "ammoniacal-ocean", "ammoniacal-ocean-2", "brash-ice" },
      name = { "tile-name.ammoniacal-ocean" },
      category = mod.CATEGORIES.RESOURCES,
      track_interior = false,
      area_scan = true,
      space_age = true,
   },
   {
      -- Gleba's shallow water: walkable, but nothing can be built on it without landfill.
      key = "marsh",
      tiles = {
         "wetland-light-green-slime",
         "wetland-green-slime",
         "wetland-light-dead-skin",
         "wetland-dead-skin",
         "wetland-pink-tentacle",
         "wetland-red-tentacle",
         "wetland-blue-slime",
      },
      name = { "fa.scanner-tile-marsh" },
      category = mod.CATEGORIES.TERRAIN,
      track_interior = false,
      area_scan = true,
      space_age = true,
   },
   -- The wetlands artificial soil goes on, and the natural soils plants grow on.
   {
      key = "wetland-yumako",
      tiles = { "wetland-yumako" },
      name = { "tile-name.wetland-yumako" },
      category = mod.CATEGORIES.TERRAIN,
      track_interior = false,
      area_scan = true,
      space_age = true,
   },
   {
      key = "wetland-jellynut",
      tiles = { "wetland-jellynut" },
      name = { "tile-name.wetland-jellynut" },
      category = mod.CATEGORIES.TERRAIN,
      track_interior = false,
      area_scan = true,
      space_age = true,
   },
   {
      key = "natural-yumako-soil",
      tiles = { "natural-yumako-soil" },
      name = { "tile-name.natural-yumako-soil" },
      category = mod.CATEGORIES.TERRAIN,
      track_interior = false,
      area_scan = true,
      space_age = true,
   },
   {
      key = "natural-jellynut-soil",
      tiles = { "natural-jellynut-soil" },
      name = { "tile-name.natural-jellynut-soil" },
      category = mod.CATEGORIES.TERRAIN,
      track_interior = false,
      area_scan = true,
      space_age = true,
   },
   {
      -- Aquilo's land: the islands in the ammoniacal ocean.
      key = "iceberg",
      tiles = { "ice-rough", "ice-smooth", "snow-crests", "snow-flat", "snow-lumpy", "snow-patchy", "ice-platform" },
      name = { "fa.scanner-tile-iceberg" },
      category = mod.CATEGORIES.TERRAIN,
      track_interior = true,
      area_scan = false,
      space_age = true,
   },
}

TH.concat_arrays(TILE_BODY_KINDS[1].tiles, Consts.WATER_TILE_NAMES)

---@class fa.scanner.TileBodyKinds
---@field kinds fa.scanner.TileBodyKind[]
---@field by_key table<string, fa.scanner.TileBodyKind>
---@field by_tile table<string, fa.scanner.TileBodyKind>
---@field all_tiles string[]

-- The tile body kinds that exist in this game, each with only the tiles that exist.
---@type fun(): fa.scanner.TileBodyKinds
mod.tile_body_kinds = Functools.cached(function()
   ---@type fa.scanner.TileBodyKinds
   local ret = { kinds = {}, by_key = {}, by_tile = {}, all_tiles = {} }
   for _, kind in ipairs(TILE_BODY_KINDS) do
      if not kind.space_age or script.feature_flags.space_travel then
         local k = TH.shallow_copy(kind) --[[@as fa.scanner.TileBodyKind]]
         k.tiles = {}
         for _, t in ipairs(kind.tiles) do
            -- Absent when the mod that adds it isn't loaded
            local proto = prototypes.tile[t] --[[@as LuaTilePrototype?]]
            if proto then
               table.insert(k.tiles, t)
               table.insert(ret.all_tiles, t)
               ret.by_tile[t] = k
            end
         end
         if next(k.tiles) then
            table.insert(ret.kinds, k)
            ret.by_key[k.key] = k
         end
      end
   end
   return ret
end)

return mod
