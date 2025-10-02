# script_raised_set_tiles

A static event mods can use to tell other mods they changed tiles on a surface by script. This event is only raised if a mod does so with [LuaBootstrap::raise_event](runtime:LuaBootstrap::raise_event) or [LuaBootstrap::raise_script_set_tiles](runtime:LuaBootstrap::raise_script_set_tiles), or when `raise_event` is passed to [LuaSurface::set_tiles](runtime:LuaSurface::set_tiles).

## Event Data

### name

**Type:** `defines.events`

Identifier of the event

### surface_index

**Type:** `uint`

The surface whose tiles were changed.

### tick

**Type:** `uint`

Tick the event was generated.

### tiles

**Type:** Array[`Tile`]

The tiles that were changed.

