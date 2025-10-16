# AsteroidChunkPrototype

**Parent:** [Prototype](Prototype.md)
**Type name:** `asteroid-chunk`

## Properties

### minable

**Type:** `MinableProperties`

**Optional:** Yes

### dying_trigger_effect

**Type:** `TriggerEffect`

**Optional:** Yes

### graphics_set

**Type:** `AsteroidGraphicsSet`

**Optional:** Yes

### icons

Can't be an empty array.

**Type:** Array[`IconData`]

**Optional:** Yes

### icon

Path to the icon file.

Only loaded, and mandatory if `icons` is not defined.

**Type:** `FileName`

**Optional:** Yes

### icon_size

The size of the square icon, in pixels. E.g. `32` for a 32px by 32px icon. Must be larger than `0`.

Only loaded if `icons` is not defined.

**Type:** `SpriteSizeType`

**Optional:** Yes

**Default:** 64

### hide_from_signal_gui

**Type:** `boolean`

**Optional:** Yes

**Default:** "unset"

