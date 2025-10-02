# on_player_used_capsule

Called when a player uses a capsule that results in some game action.

## Event Data

### item

**Type:** `LuaItemPrototype`

The capsule item used.

### name

**Type:** `defines.events`

Identifier of the event

### player_index

**Type:** `uint`

The player.

### position

**Type:** `MapPosition`

The position the capsule was used.

### quality

**Type:** `LuaQualityPrototype`

The quality of the capsule item used.

### tick

**Type:** `uint`

Tick the event was generated.

