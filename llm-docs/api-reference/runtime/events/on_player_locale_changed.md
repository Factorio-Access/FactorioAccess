# on_player_locale_changed

Called when a player's active locale changes. See [LuaPlayer::locale](runtime:LuaPlayer::locale).

## Event Data

### name

**Type:** `defines.events`

Identifier of the event

### old_locale

**Type:** `string`

The previously active locale.

### player_index

**Type:** `uint32`

The player whose locale was changed.

### tick

**Type:** `uint32`

Tick the event was generated.

