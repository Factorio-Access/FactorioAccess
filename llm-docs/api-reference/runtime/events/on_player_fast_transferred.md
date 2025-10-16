# on_player_fast_transferred

Called when a player fast-transfers something to or from an entity.

## Event Data

### entity

**Type:** `LuaEntity`

The entity transferred from or to.

### from_player

**Type:** `boolean`

Whether the transfer was from player to entity. If `false`, the transfer was from entity to player.

### is_split

**Type:** `boolean`

Whether the transfer was a split action (half stack).

### name

**Type:** `defines.events`

Identifier of the event

### player_index

**Type:** `uint32`

The player transferred from or to.

### tick

**Type:** `uint32`

Tick the event was generated.

