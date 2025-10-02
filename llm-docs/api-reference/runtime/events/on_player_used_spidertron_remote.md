# on_player_used_spidertron_remote

Called when a player uses spidertron remote to send all selected units to a given position

## Event Data

### name

**Type:** `defines.events`

Identifier of the event

### player_index

**Type:** `uint`

The player that used the remote.

### position

**Type:** `MapPosition`

Goal position to which spidertron was sent to.

### tick

**Type:** `uint`

Tick the event was generated.

