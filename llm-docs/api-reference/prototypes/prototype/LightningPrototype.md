# LightningPrototype

**Parent:** [EntityPrototype](EntityPrototype.md)
**Type name:** `lightning`
**Visibility:** space_age

## Properties

### graphics_set

**Type:** `LightningGraphicsSet`

**Optional:** Yes

### sound

**Type:** `Sound`

**Optional:** Yes

### attracted_volume_modifier

**Type:** `float`

**Optional:** Yes

**Default:** 1.0

### strike_effect

**Type:** `Trigger`

**Optional:** Yes

### source_offset

**Type:** `Vector`

**Optional:** Yes

### source_variance

**Type:** `Vector`

**Optional:** Yes

### damage

**Type:** `double`

**Optional:** Yes

**Default:** 100

### energy

**Type:** `Energy`

**Optional:** Yes

**Default:** "Max double"

### time_to_damage

Must be less than or equal to `effect_duration`.

**Type:** `uint16`

**Optional:** Yes

**Default:** 0

### effect_duration

**Type:** `uint16`

**Required:** Yes

