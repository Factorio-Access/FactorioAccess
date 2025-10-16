# SoundPrototype

Specifies a sound that can be used with [SoundPath](runtime:SoundPath) at runtime.

**Type name:** `sound`

## Properties

### type

**Type:** `"sound"`

**Required:** Yes

### name

Name of the sound. Can be used as a [SoundPath](runtime:SoundPath) at runtime.

**Type:** `string`

**Required:** Yes

### category

**Type:** `SoundType`

**Optional:** Yes

**Default:** "game-effect"

### priority

Sounds with higher priority will replace a sound with lower priority if the maximum sounds limit is reached.

0 is the highest priority, 255 is the lowest priority.

**Type:** `uint8`

**Optional:** Yes

**Default:** 127

### aggregation

**Type:** `AggregationSpecification`

**Optional:** Yes

### allow_random_repeat

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### audible_distance_modifier

Modifies how far a sound can be heard. Must be between `0` and `1` inclusive.

**Type:** `double`

**Optional:** Yes

**Default:** 1.0

### game_controller_vibration_data

**Type:** `GameControllerVibrationData`

**Optional:** Yes

### advanced_volume_control

**Type:** `AdvancedVolumeControl`

**Optional:** Yes

### speed_smoothing_window_size

**Type:** `uint32`

**Optional:** Yes

**Default:** 0

### variations

**Type:** `SoundDefinition` | Array[`SoundDefinition`]

**Optional:** Yes

### filename

Supported sound file formats are `.ogg` (Vorbis and Opus) and `.wav`.

Only loaded, and mandatory if `variations` is not defined.

**Type:** `FileName`

**Optional:** Yes

### volume

Only loaded if `variations` is not defined.

This sets both min and max volumes.

Must be `>= 0`.

**Type:** `float`

**Optional:** Yes

**Default:** 1.0

### min_volume

Only loaded if `variations` and `volume` are not defined.

Must be `>= 0`.

**Type:** `float`

**Optional:** Yes

**Default:** 1.0

### max_volume

Only loaded if `variations` is not defined.

Only loaded if `min_volume` is defined.

Must be `>= min_volume`.

**Type:** `float`

**Optional:** Yes

**Default:** 1.0

### preload

Only loaded if `variations` is not defined.

**Type:** `boolean`

**Optional:** Yes

### speed

Speed must be `>= 1 / 64`. This sets both min and max speeds.

Only loaded if `variations` is not defined.

**Type:** `float`

**Optional:** Yes

**Default:** 1.0

### min_speed

Must be `>= 1 / 64`.

Only loaded if both `variations` and `speed` are not defined.

**Type:** `float`

**Optional:** Yes

**Default:** 1.0

### max_speed

Must be `>= min_speed`.

Only loaded if `variations` is not defined. Only loaded, and mandatory if `min_speed` is defined.

**Type:** `float`

**Optional:** Yes

**Default:** 1.0

### modifiers

Only loaded if `variations` is not defined.

**Type:** `SoundModifier` | Array[`SoundModifier`]

**Optional:** Yes

