# PlaySoundTriggerEffectItem

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### type

**Type:** `"play-sound"`

**Required:** Yes

### sound

**Type:** `Sound`

**Required:** Yes

### min_distance

Negative values are silently clamped to 0.

**Type:** `float`

**Optional:** Yes

**Default:** 0

### max_distance

Negative values are silently clamped to 0.

**Type:** `float`

**Optional:** Yes

**Default:** "1e21"

### play_on_target_position

**Type:** `boolean`

**Optional:** Yes

**Default:** False

