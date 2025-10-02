# script_raised_revive

A static event mods can use to tell other mods they revived something by script. This event is only raised if a mod does so with [LuaBootstrap::raise_event](runtime:LuaBootstrap::raise_event) or [LuaBootstrap::raise_script_revive](runtime:LuaBootstrap::raise_script_revive), or when `raise_revive` is passed to [LuaEntity::revive](runtime:LuaEntity::revive).

## Event Data

### entity

**Type:** `LuaEntity`

The entity that was revived.

### name

**Type:** `defines.events`

Identifier of the event

### tags

**Type:** `Tags` *(optional)*

The tags associated with this entity, if any.

### tick

**Type:** `uint`

Tick the event was generated.

