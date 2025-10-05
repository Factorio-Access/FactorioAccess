# CutsceneWaypoint

**Type:** Table

## Parameters

### position

Position to pan the camera to.

**Type:** `MapPosition`

**Optional:** Yes

### target

Entity or unit group to pan the camera to.

**Type:** `LuaEntity` | `LuaCommandable`

**Optional:** Yes

### time_to_wait

Time in ticks to wait before moving to the next waypoint.

**Type:** `uint32`

**Required:** Yes

### transition_time

How many ticks it will take to reach this waypoint from the previous one.

**Type:** `uint32`

**Required:** Yes

### zoom

Zoom level to be set when the waypoint is reached. When not specified, the previous waypoint's zoom is used.

**Type:** `double`

**Optional:** Yes

