# Accessible Settings For Other Mods' Entities

Last reviewed: 2026-08-02

## The Problem

We cannot read another mod's GUI. We never see it, and there is no engine mechanism that exposes arbitrary per-entity
configuration. So when a mod puts settings on one of its entities, a blind player has no way to reach them, and there is
nothing we can do about it from our side alone.

Mod authors have no way to expose those settings to us on their own either, so the settings simply stay unreachable.

## The Solution

A mod describes its settings to us as data, and we render them as a normal tab in the entity UI. The mod keeps the
settings wherever it likes; we only ask for a description, read values, and write them back.

Discovery is a pull. We scan `remote.interfaces` for any interface implementing all four protocol functions. Nothing is
registered with us, so there is no load ordering to get wrong, nothing to migrate across a save, and neither mod needs a
dependency on the other. When we are not installed, the interface simply goes uncalled.

## The Protocol

Register an interface, under any name, implementing all four of:

```lua
remote.add_interface("my-mod", {
   fa_settings_entities = function() ... end,
   fa_settings_schema = function(request) ... end,
   fa_settings_get = function(request) ... end,
   fa_settings_set = function(request) ... end,
})
```

Every `request` is a table carrying `entity` (LuaEntity), `entity_name`, and `player_index`; get and set also carry
`field`, and set carries `value`. Passing a table means we can add keys later without breaking anyone.

### fa_settings_entities

Returns the array of entity names you configure. Called once per session.

### fa_settings_schema

Returns `{ fields = { ... } }`, or nil to decline this particular entity.

**This is called on every render, so the fields may vary with game state.** That is the point: offer a belt tier only
once the force has researched it, drop a field that a different setting has made irrelevant, and the menu follows along
without the player ever meeting a dead option.

A field is:

| Key | Meaning |
| --- | --- |
| `kind` | `boolean` or `choice` |
| `name` | Unique in the schema, handed back to you on get and set |
| `label` | LocalisedString, from your own locale |
| `choices` | `choice` only: array of `{value =, label =, default =}`; values must be scalars, as they are compared by equality |

A toggle and a list of choices cover what mods have wanted so far, and a kind nobody asks for is a rendering path
nobody exercises, so those two are all we offer. Ask if you need another one; a number field with a range used to
exist and can come back.

### fa_settings_get and fa_settings_set

Read and write one field. Both are called often; keep them cheap.

Setters need not announce anything, because the control speaks the new value itself. To refuse a value, leave it out of
the schema rather than rejecting it on write.

## Notes

- Schemas come from another mod, so we validate them at the boundary. A malformed field raises an error naming the
  offending interface rather than failing somewhere inside the form builder.
- An entity with a provider gets the settings tab first, ahead of every other configuration tab, and is routed to the
  generic entity UI ahead of the type special cases in `entity-ui.lua`. Its own settings take precedence over whatever
  UI its base entity type would otherwise have shown.
- The tab carries our own title, so a schema is just its fields.

## Worked Example

The Belt Planner Commands mod uses this for its path markers, in `control.lua` under "Accessible settings". Its route
field folds "which planner" and "which belt tier" into one choice list built from what the force can build.
