# MainSound

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### sound

Cannot be empty.

**Type:** `Sound`

**Optional:** Yes

### probability

Modifies how often the sound is played.

Silently clamped to the [0.0, 1.0] range.

Unused when [WorkingSound::persistent](prototype:WorkingSound::persistent) is `true`.

**Type:** `double`

**Optional:** Yes

**Default:** 1

### fade_in_ticks

Can't be used when `match_progress_to_activity` is `true`.

**Type:** `uint32`

**Optional:** Yes

**Default:** 0

### fade_out_ticks

Can't be used when `match_progress_to_activity` is `true`.

**Type:** `uint32`

**Optional:** Yes

**Default:** 0

### activity_to_volume_modifiers

**Type:** `ActivityMatchingModifiers`

**Optional:** Yes

### activity_to_speed_modifiers

**Type:** `ActivityMatchingModifiers`

**Optional:** Yes

### match_progress_to_activity

Unused when [WorkingSound::persistent](prototype:WorkingSound::persistent) is `true`.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### match_volume_to_activity

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### match_speed_to_activity

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### play_for_working_visualisations

Array of [WorkingVisualisation::name](prototype:WorkingVisualisation::name)s, individual names cannot be empty.

The `sound` is played when at least one of the specified working visualisations is drawn.

Unused when [WorkingSound::persistent](prototype:WorkingSound::persistent) is `true`.

**Type:** Array[`string`]

**Optional:** Yes

### volume_smoothing_window_size

Only used if [WorkingSound::persistent](prototype:WorkingSound::persistent) is `true`.

**Type:** `uint32`

**Optional:** Yes

**Default:** 0

