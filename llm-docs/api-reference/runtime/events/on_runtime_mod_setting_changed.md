# on_runtime_mod_setting_changed

Called when a runtime mod setting is changed by a player.

## Event Data

### name

**Type:** `defines.events`

Identifier of the event

### player_index

**Type:** `uint` *(optional)*

If the `setting_type` is `"global"` and it was changed through the mod settings GUI, this is the index of the player that changed the global setting. If the `setting_type` is `"runtime-per-user"` and it changed a current setting of the player, this is the index of the player whose setting was changed. In all other cases, this is `nil`.

### setting

**Type:** `string`

The prototype name of the setting that was changed.

### setting_type

**Type:** `"runtime-global"` | `"runtime-per-user"`

### tick

**Type:** `uint`

Tick the event was generated.

