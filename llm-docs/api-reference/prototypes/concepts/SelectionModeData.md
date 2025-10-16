# SelectionModeData

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### border_color

**Type:** `Color`

**Required:** Yes

### count_button_color

**Type:** `Color`

**Optional:** Yes

**Default:** "Value of border_color"

### chart_color

**Type:** `Color`

**Optional:** Yes

**Default:** "Value of border_color"

### cursor_box_type

**Type:** `CursorBoxType`

**Required:** Yes

### mode

**Type:** `SelectionModeFlags`

**Required:** Yes

### entity_filters

**Type:** Array[`EntityID`]

**Optional:** Yes

### entity_type_filters

**Type:** Array[`string`]

**Optional:** Yes

### tile_filters

**Type:** Array[`TileID`]

**Optional:** Yes

### started_sound

**Type:** `Sound`

**Optional:** Yes

### ended_sound

**Type:** `Sound`

**Optional:** Yes

### play_ended_sound_when_nothing_selected

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### entity_filter_mode

**Type:** `"whitelist"` | `"blacklist"`

**Optional:** Yes

**Default:** "whitelist"

### tile_filter_mode

**Type:** `"whitelist"` | `"blacklist"`

**Optional:** Yes

**Default:** "whitelist"

