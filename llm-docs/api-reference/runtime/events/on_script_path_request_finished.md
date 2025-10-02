# on_script_path_request_finished

Called when a [LuaSurface::request_path](runtime:LuaSurface::request_path) call completes.

## Event Data

### id

**Type:** `uint`

Handle to associate the callback with a particular call to [LuaSurface::request_path](runtime:LuaSurface::request_path).

### name

**Type:** `defines.events`

Identifier of the event

### path

**Type:** Array[`PathfinderWaypoint`] *(optional)*

The actual path that the pathfinder has determined. `nil` if pathfinding failed.

### tick

**Type:** `uint`

Tick the event was generated.

### try_again_later

**Type:** `boolean`

Indicates that the pathfinder failed because it is too busy, and that you can retry later.

