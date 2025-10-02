# TurretSpecialEffect

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### type

**Type:** `"mask-by-circle"`

**Required:** Yes

### center

**Type:** `TurretSpecialEffectCenter`

**Optional:** Yes

### min_radius

Only loaded if `type` is `"mask-by-circle"`.

**Type:** `float`

**Optional:** Yes

**Default:** 0

### max_radius

Only loaded, and mandatory if `type` is `"mask-by-circle"`.

**Type:** `float`

**Optional:** Yes

### falloff

Only loaded if `type` is `"mask-by-circle"`.

**Type:** `float`

**Optional:** Yes

**Default:** 0

### attacking_min_radius

Only loaded if `type` is `"mask-by-circle"`.

**Type:** `float`

**Optional:** Yes

### attacking_max_radius

Only loaded if `type` is `"mask-by-circle"`.

**Type:** `float`

**Optional:** Yes

### attacking_falloff

Only loaded if `type` is `"mask-by-circle"`.

**Type:** `float`

**Optional:** Yes

