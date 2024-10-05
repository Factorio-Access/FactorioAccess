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

mod.RESOURCE_SEARCH_RADIUSES_ITEM = "fa-resource-radiuses-proto"

return mod
