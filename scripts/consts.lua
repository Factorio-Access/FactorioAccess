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

return mod
