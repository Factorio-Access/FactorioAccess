# CreateParticleTriggerEffectItem

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### type

**Type:** `"create-particle"`

**Required:** Yes

### particle_name

**Type:** `ParticleID`

**Required:** Yes

### initial_height

**Type:** `float`

**Required:** Yes

### offset_deviation

**Type:** `SimpleBoundingBox`

**Optional:** Yes

### show_in_tooltip

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### tile_collision_mask

**Type:** `CollisionMaskConnector`

**Optional:** Yes

### offsets

**Type:** Array[`Vector`]

**Optional:** Yes

### initial_height_deviation

**Type:** `float`

**Optional:** Yes

**Default:** 0

### initial_vertical_speed

**Type:** `float`

**Optional:** Yes

**Default:** 0

### initial_vertical_speed_deviation

**Type:** `float`

**Optional:** Yes

**Default:** 0

### speed_from_center

**Type:** `float`

**Optional:** Yes

**Default:** 0

### speed_from_center_deviation

**Type:** `float`

**Optional:** Yes

**Default:** 0

### frame_speed

**Type:** `float`

**Optional:** Yes

**Default:** 1

### frame_speed_deviation

**Type:** `float`

**Optional:** Yes

**Default:** 0

### movement_multiplier

**Type:** `float`

**Optional:** Yes

**Default:** 0

### tail_length

Silently capped to a maximum of 100.

**Type:** `uint8`

**Optional:** Yes

**Default:** 0

### tail_length_deviation

Silently capped to a maximum of 100.

**Type:** `uint8`

**Optional:** Yes

**Default:** 0

### tail_width

**Type:** `float`

**Optional:** Yes

**Default:** 1

### rotate_offsets

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### only_when_visible

Create the particle only when they are within a 200 tile range of any connected player.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### apply_tile_tint

**Type:** `"primary"` | `"secondary"`

**Optional:** Yes

### tint

Only loaded if `apply_tile_tint` is not defined.

**Type:** `Color`

**Optional:** Yes

**Default:** "`{1, 1, 1, 1} (white)`"

