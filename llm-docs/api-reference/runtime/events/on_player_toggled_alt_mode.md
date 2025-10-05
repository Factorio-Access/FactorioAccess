# on_player_toggled_alt_mode

Called when a player toggles alt mode, also known as "show entity info".

## Event Data

### alt_mode

**Type:** `boolean`

The new alt mode value. This value is a shortcut for accessing [GameViewSettings::show_entity_info](runtime:GameViewSettings::show_entity_info) on the player.

### name

**Type:** `defines.events`

Identifier of the event

### player_index

**Type:** `uint32`

### tick

**Type:** `uint32`

Tick the event was generated.

