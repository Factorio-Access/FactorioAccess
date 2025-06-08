# SoundPrototype

Specifies a sound that can be used with [SoundPath](runtime:SoundPath) at runtime.

## Properties

### Mandatory Properties

#### name

**Type:** `string`

Name of the sound. Can be used as a [SoundPath](runtime:SoundPath) at runtime.

#### type

**Type:** `sound`



### Optional Properties

#### advanced_volume_control

**Type:** `AdvancedVolumeControl`



#### aggregation

**Type:** `AggregationSpecification`



#### allow_random_repeat

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': False}`

#### audible_distance_modifier

**Type:** `double`

Modifies how far a sound can be heard. Must be between `0` and `1` inclusive.

**Default:** `{'complex_type': 'literal', 'value': 1.0}`

#### category

**Type:** `SoundType`



**Default:** `{'complex_type': 'literal', 'value': 'game-effect'}`

#### filename

**Type:** `FileName`

Supported sound file formats are `.ogg` (Vorbis and Opus) and `.wav`.

Only loaded, and mandatory if `variations` is not defined.

#### game_controller_vibration_data

**Type:** `GameControllerVibrationData`



#### max_speed

**Type:** `float`

Must be `>= min_speed`.

Only loaded if `variations` is not defined. Only loaded, and mandatory if `min_speed` is defined.

**Default:** `{'complex_type': 'literal', 'value': 1.0}`

#### max_volume

**Type:** `float`

Only loaded if `variations` is not defined.

Only loaded if `min_volume` is defined.

Must be `>= min_volume`.

**Default:** `{'complex_type': 'literal', 'value': 1.0}`

#### min_speed

**Type:** `float`

Must be `>= 1 / 64`.

Only loaded if both `variations` and `speed` are not defined.

**Default:** `{'complex_type': 'literal', 'value': 1.0}`

#### min_volume

**Type:** `float`

Only loaded if `variations` and `volume` are not defined.

Must be `>= 0`.

**Default:** `{'complex_type': 'literal', 'value': 1.0}`

#### modifiers

**Type:** 

Only loaded if `variations` is not defined.

#### preload

**Type:** `boolean`

Only loaded if `variations` is not defined.

#### priority

**Type:** `uint8`

Sounds with higher priority will replace a sound with lower priority if the maximum sounds limit is reached.

0 is the highest priority, 255 is the lowest priority.

**Default:** `{'complex_type': 'literal', 'value': 127}`

#### speed

**Type:** `float`

Speed must be `>= 1 / 64`. This sets both min and max speeds.

Only loaded if `variations` is not defined.

**Default:** `{'complex_type': 'literal', 'value': 1.0}`

#### speed_smoothing_window_size

**Type:** `uint32`



**Default:** `{'complex_type': 'literal', 'value': 0}`

#### variations

**Type:** 



#### volume

**Type:** `float`

Only loaded if `variations` is not defined.

This sets both min and max volumes.

Must be `>= 0`.

**Default:** `{'complex_type': 'literal', 'value': 1.0}`

