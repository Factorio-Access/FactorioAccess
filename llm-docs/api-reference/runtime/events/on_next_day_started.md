# on_next_day_started

Called when value of [LuaSurface::daytime](runtime:LuaSurface::daytime) wraps around to be in `[0, 1)` range.

## Event Data

### name

**Type:** `defines.events`

Identifier of the event.

### surface

**Type:** `LuaSurface`

### tick

**Type:** `MapTick`

Tick the event was generated.

