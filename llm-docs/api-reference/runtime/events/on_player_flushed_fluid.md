# on_player_flushed_fluid

Called after player flushed fluid

## Event Data

### amount

**Type:** `double`

Amount of fluid that was removed

### entity

**Type:** `LuaEntity`

Entity from which flush was performed

### fluid

**Type:** `string`

Name of a fluid that was flushed

### name

**Type:** `defines.events`

Identifier of the event

### only_this_entity

**Type:** `boolean`

True if flush was requested only on this entity

### player_index

**Type:** `uint32`

Index of the player

### tick

**Type:** `uint32`

Tick the event was generated.

