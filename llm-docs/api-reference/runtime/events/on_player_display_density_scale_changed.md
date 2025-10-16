# on_player_display_density_scale_changed

Called when the display density scale changes for a given player. The display density scale is the scale value automatically applied based on the player's display DPI. This is only relevant on platforms that support high-density displays.

## Event Data

### name

**Type:** `defines.events`

Identifier of the event

### old_scale

**Type:** `double`

The old display scale

### player_index

**Type:** `uint32`

The player

### tick

**Type:** `uint32`

Tick the event was generated.

