--[[
Accessible settings for entities belonging to other mods.

Other mods cannot be read by us: we never see their GUIs, and there is no
engine mechanism that exposes arbitrary per-entity configuration.  This module
lets a mod hand us a description of its settings instead, which we render as a
normal tab in the entity UI.

Discovery is a pull: we scan `remote.interfaces` for any interface implementing
all four protocol functions.  Nothing has to be registered with us, so there is
no load ordering to get wrong and nothing to migrate across a save, and neither
mod needs to depend on the other.

See devdocs/mod-entity-settings.md for the protocol as mod authors see it.
]]

local mod = {}

---Protocol functions an interface must implement to be a provider.
local REQUIRED_FUNCTIONS = {
   "fa_settings_entities",
   "fa_settings_schema",
   "fa_settings_get",
   "fa_settings_set",
}

--A toggle and a list of choices are what mods have actually needed so far, so
--they are all we offer; a kind nobody asks for is a rendering path nobody
--exercises.  More can be added when a mod wants one.
---@enum fa.ModEntitySettings.FieldKind
mod.FIELD_KIND = {
   BOOLEAN = "boolean",
   CHOICE = "choice",
}

---@class fa.ModEntitySettings.Choice
---@field value any
---@field label LocalisedString
---@field default boolean?

---@class fa.ModEntitySettings.Field
---@field kind fa.ModEntitySettings.FieldKind
---@field name string Unique within the schema; passed back on get and set.
---@field label LocalisedString
---@field choices fa.ModEntitySettings.Choice[]? Choice fields only.

--The tab carries a fixed title of our own, so a schema is just its fields.
---@class fa.ModEntitySettings.Schema
---@field fields fa.ModEntitySettings.Field[]

---Maps entity name to the interface serving it.  Remote interfaces are fixed
---once control.lua has loaded, so this is computed once per session and never
---goes stale.
---@type table<string, string>?
local providers = nil

---@param funcs table<string, true> The interface's functions, as remote lists them.
---@return boolean
local function implements_protocol(funcs)
   for _, required in ipairs(REQUIRED_FUNCTIONS) do
      if not funcs[required] then return false end
   end
   return true
end

---@return table<string, string>
local function discover()
   if providers then return providers end

   providers = {}
   -- Reading `remote.interfaces` rebuilds the whole nested table, so it is read
   -- once and the functions come from the loop rather than a second lookup.
   for interface_name, funcs in pairs(remote.interfaces) do
      if implements_protocol(funcs) then
         local entity_names = remote.call(interface_name, "fa_settings_entities")
         for _, entity_name in ipairs(entity_names) do
            -- Two mods claiming one entity name cannot happen, since entity
            -- names are unique across the game and a mod can only sensibly
            -- claim its own.
            providers[entity_name] = interface_name
         end
      end
   end

   return providers
end

---@param entity LuaEntity
---@return string? interface_name
local function provider_for(entity)
   return discover()[entity.name]
end

---Whether some mod offers settings for this entity.
---@param entity LuaEntity
---@return boolean
function mod.has_settings(entity)
   return provider_for(entity) ~= nil
end

---A field arrives from another mod, so it is checked before it reaches the
---form builder: a bad schema should name the offending mod rather than crash
---somewhere deep in the UI.
---@param interface_name string
---@param index number
---@param field fa.ModEntitySettings.Field
local function validate_field(interface_name, index, field)
   local function check(condition, problem)
      if not condition then
         error(
            string.format(
               "mod entity settings from interface '%s': field %s (%s) %s",
               interface_name,
               tostring(field.name or index),
               tostring(field.kind),
               problem
            )
         )
      end
   end

   check(type(field.name) == "string", "must have a string name")
   check(field.label ~= nil, "must have a label")

   if field.kind == mod.FIELD_KIND.CHOICE then
      check(type(field.choices) == "table" and #field.choices > 0, "must have at least one choice")
      for _, choice in ipairs(field.choices) do
         check(choice.value ~= nil, "has a choice with no value")
         check(choice.label ~= nil, "has a choice with no label")
      end
   else
      check(field.kind == mod.FIELD_KIND.BOOLEAN, "has an unknown kind")
   end
end

---Check a whole schema, raising on the first field that is not usable.  Public
---so the boundary can be exercised on its own, without a mod on the other end
---of the interface.
---@param interface_name string Named in the error, so the mod at fault is known.
---@param schema fa.ModEntitySettings.Schema
function mod.validate_schema(interface_name, schema)
   for i, field in ipairs(schema.fields) do
      validate_field(interface_name, i, field)
   end
end

---Fetch the schema for an entity.  Called on every render so that providers can
---vary the fields with game state, for example offering only researched items.
---@param entity LuaEntity
---@param pindex number
---@return fa.ModEntitySettings.Schema?
function mod.get_schema(entity, pindex)
   local interface_name = provider_for(entity)
   if not interface_name then return nil end

   local schema = remote.call(interface_name, "fa_settings_schema", {
      entity = entity,
      entity_name = entity.name,
      player_index = pindex,
   })

   -- A provider may decline an individual entity, for example one belonging to
   -- another force.
   if not schema then return nil end

   mod.validate_schema(interface_name, schema)

   return schema
end

---@param entity LuaEntity
---@param pindex number
---@param field_name string
---@return any
function mod.get_value(entity, pindex, field_name)
   return remote.call(provider_for(entity), "fa_settings_get", {
      entity = entity,
      entity_name = entity.name,
      player_index = pindex,
      field = field_name,
   })
end

---Write a value back.  The form announces the new value itself, so providers
---need not say anything; a provider that wants to refuse a value should leave
---it out of the schema instead.
---@param entity LuaEntity
---@param pindex number
---@param field_name string
---@param value any
function mod.set_value(entity, pindex, field_name, value)
   remote.call(provider_for(entity), "fa_settings_set", {
      entity = entity,
      entity_name = entity.name,
      player_index = pindex,
      field = field_name,
      value = value,
   })
end

return mod
