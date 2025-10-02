# script_raised_teleported

A static event mods can use to tell other mods they teleported something by script. This event is only raised if a mod does so with [LuaBootstrap::raise_event](runtime:LuaBootstrap::raise_event) or [LuaBootstrap::raise_script_teleported](runtime:LuaBootstrap::raise_script_teleported), or when `raise_teleported` is passed to [LuaControl::teleport](runtime:LuaControl::teleport).

## Event Data

### entity

**Type:** `LuaEntity`

The entity that was teleported.

### name

**Type:** `defines.events`

Identifier of the event

### old_position

**Type:** `MapPosition`

The entity's position before the teleportation.

### old_surface_index

**Type:** `uint8`

The entity's surface before the teleportation.

### tick

**Type:** `uint`

Tick the event was generated.

