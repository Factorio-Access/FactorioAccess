# GuiAnchor

**Type:** Table

## Parameters

### ghost_mode

Defaults to `"only_real"`.

**Type:** `"both"` | `"only_ghosts"` | `"only_real"`

**Optional:** Yes

### gui

**Type:** `defines.relative_gui_type`

**Required:** Yes

### name

If provided, only anchors the GUI element when the opened thing matches the name. `name` takes precedence over `names`.

**Type:** `string`

**Optional:** Yes

### names

If provided, only anchors the GUI element when the opened thing matches one of the names. When reading an anchor, `names` is always populated.

**Type:** Array[`string`]

**Optional:** Yes

### position

**Type:** `defines.relative_gui_position`

**Required:** Yes

### type

If provided, only anchors the GUI element when the opened things type matches the type.

**Type:** `string`

**Optional:** Yes

