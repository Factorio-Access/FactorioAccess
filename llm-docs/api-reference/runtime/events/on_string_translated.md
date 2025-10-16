# on_string_translated

Called when a translation request generated through [LuaPlayer::request_translation](runtime:LuaPlayer::request_translation) or [LuaPlayer::request_translations](runtime:LuaPlayer::request_translations) has been completed.

## Event Data

### id

**Type:** `uint32`

The unique id for this translation request.

### localised_string

**Type:** `LocalisedString`

The localised string being translated.

### name

**Type:** `defines.events`

Identifier of the event

### player_index

**Type:** `uint32`

The player whose locale was used for the translation.

### result

**Type:** `string`

The translated `localised_string`.

### tick

**Type:** `uint32`

Tick the event was generated.

### translated

**Type:** `boolean`

Whether the requested localised string was valid and could be translated.

