# AggregationSpecification

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### max_count

**Type:** `uint32`

**Required:** Yes

### progress_threshold

If `count_already_playing` is `true`, this will determine maximum progress when instance is counted toward playing sounds.

**Type:** `float`

**Optional:** Yes

**Default:** 1.0

### volume_reduction_rate

Has to be greater than or equal to 0.0.

**Type:** `float`

**Optional:** Yes

**Default:** 2.0

### remove

If `false`, the volume of sound instances above `max_count` is calculated according to the formula `volume = (x + 1) ^ (-volume_reduction_rate)`, where `x` is the order number of an instance above the threshold.

If `true`, sound instances above `max_count` are removed.

**Type:** `boolean`

**Required:** Yes

### count_already_playing

If `true`, already playing sounds are taken into account when checking `max_count`.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### priority

**Type:** `"closest"` | `"farthest"` | `"newest"` | `"oldest"`

**Optional:** Yes

**Default:** "closest"

