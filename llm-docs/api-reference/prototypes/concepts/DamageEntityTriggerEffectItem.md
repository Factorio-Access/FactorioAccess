# DamageEntityTriggerEffectItem

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### type

**Type:** `"damage"`

**Required:** Yes

### damage

**Type:** `DamageParameters`

**Required:** Yes

### apply_damage_to_trees

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### vaporize

If `true`, no corpse for killed entities will be created.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### use_substitute

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### lower_distance_threshold

**Type:** `uint16`

**Optional:** Yes

**Default:** "MAX_UINT16"

### upper_distance_threshold

**Type:** `uint16`

**Optional:** Yes

**Default:** "MAX_UINT16"

### lower_damage_modifier

**Type:** `float`

**Optional:** Yes

**Default:** 1

### upper_damage_modifier

**Type:** `float`

**Optional:** Yes

**Default:** 1

