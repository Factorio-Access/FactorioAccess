# AmmoType

**Type:** Table

## Parameters

### action

**Type:** Array[`TriggerItem`]

**Optional:** Yes

### clamp_position

When `true`, the gun will be able to shoot even when the target is out of range. Only applies when `target_type` is `position`. The gun will fire at the maximum range in the direction of the target position. Defaults to `false`.

**Type:** `boolean`

**Optional:** Yes

### consumption_modifier

**Type:** `float`

**Optional:** Yes

### cooldown_modifier

**Type:** `double`

**Optional:** Yes

### energy_consumption

Energy consumption of a single shot, if applicable. Defaults to `0`.

**Type:** `double`

**Optional:** Yes

### range_modifier

**Type:** `double`

**Optional:** Yes

### target_filter

The entity prototype filter names.

**Type:** Array[`string`]

**Optional:** Yes

### target_type

**Type:** `TargetType`

**Required:** Yes

