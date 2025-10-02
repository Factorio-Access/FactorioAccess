# on_player_left_game

Called after a player leaves the game. This is not called when closing a save file in singleplayer, as the player doesn't actually leave the game, and the save is just on pause until they rejoin.

## Event Data

### name

**Type:** `defines.events`

Identifier of the event

### player_index

**Type:** `uint`

### reason

**Type:** `defines.disconnect_reason`

### tick

**Type:** `uint`

Tick the event was generated.

