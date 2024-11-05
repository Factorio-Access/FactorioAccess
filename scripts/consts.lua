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
---@type fa.Point
mod.DIRECTION_VECTORS = {
   { x = 0.0, y = 1.0 },
   { x = 0.3826834323650898, y = 0.9238795325112867 },
   { x = 0.7071067811865476, y = 0.7071067811865476 },
   { x = 0.9238795325112867, y = 0.38268343236508984 },
   { x = 1.0, y = 6.123233995736766e-17 },
   { x = 0.9238795325112867, y = -0.3826834323650897 },
   { x = 0.7071067811865476, y = -0.7071067811865475 },
   { x = 0.3826834323650899, y = -0.9238795325112867 },
   { x = 1.2246467991473532e-16, y = -1.0 },
   { x = -0.38268343236508967, y = -0.9238795325112868 },
   { x = -0.7071067811865475, y = -0.7071067811865477 },
   { x = -0.9238795325112865, y = -0.38268343236509034 },
   { x = -1.0, y = -1.8369701987210297e-16 },
   { x = -0.9238795325112866, y = 0.38268343236509 },
   { x = -0.7071067811865477, y = 0.7071067811865474 },
   { x = -0.3826834323650904, y = 0.9238795325112865 },
}

-- Cosine of 22.5.  This is useful because we can quickly check whether or not
-- the angle between two vectors is 22.5 by taking the absolute value of their
-- dot product after normalization.
mod.COS22_5 = math.cos(22.5 * math.pi / 180)

return mod
