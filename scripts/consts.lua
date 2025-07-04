--[[
Constants for our mod.  Must load in the data stage as well as runtime.
]]

local mod = {}

-- We inject a trigger into all entities which allows us to subscribe to their
-- creation.  This trigger is identified by id defined by us, and delivered in
-- one event along with possible triggers for other mods.  This isn't well
-- documented, you could start at
-- https://lua-api.factorio.com/latest/types/ScriptTriggerEffectItem.html#effect_id
mod.NEW_ENTITY_SUBSCRIBER_TRIGGER_ID = "fa.subscribe-to-new-entities"

mod.RESOURCE_SEARCH_RADIUSES_MAP_NAME = "resource-search-radiuses"

mod.ENT_NAMES_CLEARED_AS_OBSTACLES = {
   "tree-01-stump",
   "tree-02-stump",
   "tree-03-stump",
   "tree-04-stump",
   "tree-05-stump",
   "tree-06-stump",
   "tree-07-stump",
   "tree-08-stump",
   "tree-09-stump",
   "small-scorchmark",
   "small-scorchmark-tintable",
   "medium-scorchmark",
   "medium-scorchmark-tintable",
   "big-scorchmark",
   "big-scorchmark-tintable",
   "huge-scorchmark",
   "huge-scorchmark-tintable",
   "big-rock",
   "huge-rock",
   "big-sand-rock",
}

-- Holds a mapping of names. See data-updates.lua.
mod.RESEARCH_CRAFT_ITEMS_MAP_OUTER = "craft-item-map-names"
mod.RESEARCH_CRAFT_ITEM_TRIGGER_MAPNAME_SUFFIX = "craft-item-counts"

-- The unit vectors of the directions in order north going clockwise.  If indexed by defines.direction, this gives back
-- the unit vector pointing in that direction.  Note that this is a 0-indexed table, 0 is north, directions go
-- clockwise, 15 is northnorthwest.
---@type table<defines.direction, fa.Point>
mod.DIRECTION_VECTORS = {
   [defines.direction.north] = { x = 0.0, y = -1.0 },
   [defines.direction.northnortheast] = { x = 0.3826834323650898, y = -0.9238795325112867 },
   [defines.direction.northeast] = { x = 0.7071067811865476, y = -0.7071067811865476 },
   [defines.direction.eastnortheast] = { x = 0.9238795325112867, y = -0.38268343236508984 },
   [defines.direction.east] = { x = 1.0, y = 0.0 },
   [defines.direction.eastsoutheast] = { x = 0.9238795325112867, y = 0.3826834323650897 },
   [defines.direction.southeast] = { x = 0.7071067811865476, y = 0.7071067811865475 },
   [defines.direction.southsoutheast] = { x = 0.3826834323650899, y = 0.9238795325112867 },
   [defines.direction.south] = { x = 0.0, y = 1.0 },
   [defines.direction.southsouthwest] = { x = -0.38268343236508967, y = 0.9238795325112868 },
   [defines.direction.southwest] = { x = -0.7071067811865475, y = 0.7071067811865477 },
   [defines.direction.westsouthwest] = { x = -0.9238795325112865, y = 0.38268343236509034 },
   [defines.direction.west] = { x = -1.0, y = 0.0 },
   [defines.direction.westnorthwest] = { x = -0.9238795325112866, y = -0.38268343236509 },
   [defines.direction.northwest] = { x = -0.7071067811865477, y = -0.7071067811865474 },
   [defines.direction.northnorthwest] = { x = -0.3826834323650904, y = -0.9238795325112865 },
}

---@type table<string, true>
mod.CRAFTING_MACHINES = {
   ["assembling-machine"] = true,
   ["furnace"] = true,
   ["rocket-silo"] = true,
}

---@type string[]
mod.WATER_TILE_NAMES = {
   "water",
   "deepwater",
   "water-green",
   "deepwater-green",
   "water-shallow",
   "water-mud",
   "water-wube",
}

-- Entity types that players can walk over without collision
mod.ENT_TYPES_YOU_CAN_WALK_OVER = {
   "resource",
   "transport-belt",
   "underground-belt",
   "splitter",
   "item-entity",
   "entity-ghost",
   "heat-pipe",
   "pipe",
   "pipe-to-ground",
   "character",
   "rail-signal",
   "highlight-box",
   "combat-robot",
   "logistic-robot",
   "construction-robot",
   "rocket-silo-rocket-shadow",
}

-- Entity types that can be built over (replaced)
mod.ENT_TYPES_YOU_CAN_BUILD_OVER = {
   "resource",
   "entity-ghost",
   "highlight-box",
   "combat-robot",
   "logistic-robot",
   "construction-robot",
   "rocket-silo-rocket-shadow",
}

-- Entity names to exclude from various operations
mod.EXCLUDED_ENT_NAMES = { "highlight-box" }

return mod
