# on_cutscene_waypoint_reached

Called when a cutscene is playing, each time it reaches a waypoint in that cutscene.

This refers to an index in the table previously passed to set_controller which started the cutscene.

## Event Data

### name

**Type:** `defines.events`

Identifier of the event

### player_index

**Type:** `uint32`

The player index of the player viewing the cutscene.

### tick

**Type:** `uint32`

Tick the event was generated.

### waypoint_index

**Type:** `uint32`

The index of the waypoint we just completed.

