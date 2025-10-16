# on_player_joined_game

Called after a player joins the game. This is not called when loading a save file in singleplayer, as the player doesn't actually leave the game, and the save is just on pause until they rejoin.

## Event Data

### name

**Type:** `defines.events`

Identifier of the event

### player_index

**Type:** `uint32`

### tick

**Type:** `uint32`

Tick the event was generated.

