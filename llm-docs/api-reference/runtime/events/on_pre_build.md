# on_pre_build

Called when players uses an item to build something. Called before [on_built_entity](runtime:on_built_entity).

## Event Data

### build_mode

**Type:** `defines.build_mode`

Build mode the item was placed with.

### created_by_moving

**Type:** `boolean`

Whether the item was placed while moving.

### direction

**Type:** `defines.direction`

The direction the item was facing when placed.

### flip_horizontal

**Type:** `boolean`

Whether the blueprint was flipped horizontally. `nil` if not built by a blueprint.

### flip_vertical

**Type:** `boolean`

Whether the blueprint was flipped vertically. `nil` if not built by a blueprint.

### mirror

**Type:** `boolean`

If the item is mirrored (only crafting machines support this)

### name

**Type:** `defines.events`

Identifier of the event

### player_index

**Type:** `uint32`

The player who did the placing.

### position

**Type:** `MapPosition`

Where the item was placed.

### tick

**Type:** `uint32`

Tick the event was generated.

