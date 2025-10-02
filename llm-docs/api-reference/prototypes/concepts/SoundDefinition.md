# SoundDefinition

**Type:** `Struct` (see below for attributes) | `FileName`

## Properties

*These properties apply when the value is a struct/table.*

### filename

Supported sound file formats are `.ogg` (Vorbis and Opus) and `.wav`.

**Type:** `FileName`

**Required:** Yes

### volume

This sets both min and max volumes.

Must be `>= 0`.

**Type:** `float`

**Optional:** Yes

**Default:** 1.0

### min_volume

Only loaded if `volume` is not defined.

Must be `>= 0`.

**Type:** `float`

**Optional:** Yes

**Default:** 1.0

### max_volume

Only loaded if `min_volume` is defined.

Must be `>= min_volume`.

**Type:** `float`

**Optional:** Yes

**Default:** 1.0

### preload

**Type:** `boolean`

**Optional:** Yes

### speed

Speed must be `>= 1 / 64`. This sets both min and max speeds.

**Type:** `float`

**Optional:** Yes

**Default:** 1.0

### min_speed

Only loaded if `speed` is not defined.

Must be `>= 1 / 64`.

**Type:** `float`

**Optional:** Yes

**Default:** 1.0

### max_speed

Only loaded, and mandatory, if `min_speed` is defined.

Must be `>= min_speed`.

**Type:** `float`

**Optional:** Yes

**Default:** 1.0

### modifiers

**Type:** `SoundModifier` | Array[`SoundModifier`]

**Optional:** Yes

