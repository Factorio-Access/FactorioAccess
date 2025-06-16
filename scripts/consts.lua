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

-- The unit vectors of the directions in order north going clockwise.  If
-- indexed by defines.direction, this gives back the unit vector pointing in
-- that direction.
---@type fa.Point[]
mod.DIRECTION_VECTORS = {
   { x = 0.0, y = -1.0 },
   { x = 0.3826834323650898, y = -0.9238795325112867 },
   { x = 0.7071067811865476, y = -0.7071067811865476 },
   { x = 0.9238795325112867, y = -0.38268343236508984 },
   { x = 1.0, y = 0.0 },
   { x = 0.9238795325112867, y = 0.3826834323650897 },
   { x = 0.7071067811865476, y = 0.7071067811865475 },
   { x = 0.3826834323650899, y = 0.9238795325112867 },
   { x = 0.0, y = 1.0 },
   { x = -0.38268343236508967, y = 0.9238795325112868 },
   { x = -0.7071067811865475, y = 0.7071067811865477 },
   { x = -0.9238795325112865, y = 0.38268343236509034 },
   { x = -1.0, y = 0.0 },
   { x = -0.9238795325112866, y = -0.38268343236509 },
   { x = -0.7071067811865477, y = -0.7071067811865474 },
   { x = -0.3826834323650904, y = -0.9238795325112865 },
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

return mod
