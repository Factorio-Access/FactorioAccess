# on_player_removed

Called when a player is removed (deleted) from the game. This is markedly different from a player temporarily [leaving](runtime:on_player_left_game) the game, and instead behaves like the player never existed in the save file.

## Event Data

### name

**Type:** `defines.events`

Identifier of the event

### player_index

**Type:** `uint32`

The index of the removed player.

### tick

**Type:** `uint32`

Tick the event was generated.

