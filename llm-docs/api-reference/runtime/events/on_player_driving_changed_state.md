# on_player_driving_changed_state

Called when the player's driving state has changed, meaning a player has either entered or left a vehicle.

This event is not raised when the player is ejected from a vehicle due to it being destroyed.

## Event Data

### entity

**Type:** `LuaEntity` *(optional)*

The vehicle if any.

### name

**Type:** `defines.events`

Identifier of the event

### player_index

**Type:** `uint32`

### tick

**Type:** `uint32`

Tick the event was generated.

