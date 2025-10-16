# PrototypeStrafeSettings

Used by [UnitPrototype](prototype:UnitPrototype).

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### max_distance

Must be >= `0`.

**Type:** `double`

**Optional:** Yes

**Default:** 20

### ideal_distance

Must be between 0 and max_distance inclusive.

**Type:** `double`

**Optional:** Yes

**Default:** 10

### ideal_distance_tolerance

Must be >= `0`.

**Type:** `double`

**Optional:** Yes

**Default:** 0.5

### ideal_distance_variance

Must be >= `0`.

**Type:** `double`

**Optional:** Yes

**Default:** 1

### ideal_distance_importance

Must be between between 0 and 1 inclusive.

**Type:** `float`

**Optional:** Yes

**Default:** 0.5

### ideal_distance_importance_variance

Must be between 0 and ideal_distance_importance inclusive.

**Type:** `float`

**Optional:** Yes

**Default:** 0.1

### clockwise_chance

Must be between 0 and 1 inclusive.

**Type:** `float`

**Optional:** Yes

**Default:** 0.5

### face_target

**Type:** `boolean`

**Optional:** Yes

**Default:** False

