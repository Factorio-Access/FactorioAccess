# ProjectileTriggerDelivery

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### type

**Type:** `"projectile"`

**Required:** Yes

### projectile

Name of a [ProjectilePrototype](prototype:ProjectilePrototype).

**Type:** `EntityID`

**Required:** Yes

### starting_speed

Starting speed in tiles per tick.

**Type:** `float`

**Required:** Yes

### starting_speed_deviation

**Type:** `float`

**Optional:** Yes

**Default:** 0

### direction_deviation

Maximum deviation of the projectile from source orientation, in +/- (`x radians / 2`). Example: `3.14 radians -> +/- (180° / 2)`, meaning up to 90° deviation in either direction of rotation.

**Type:** `float`

**Optional:** Yes

**Default:** 0

### range_deviation

The maximum deviation of the projectile maximum range from `max_range` is `max_range × range_deviation ÷ 2`. This means a deviation of `0.5` will appear as a maximum of `0.25` (25%) deviation of an initial range goal. Post-deviation range may exceed `max_range` or be less than `min_range`.

**Type:** `float`

**Optional:** Yes

**Default:** 0

### max_range

**Type:** `double`

**Optional:** Yes

**Default:** 1000

### min_range

**Type:** `double`

**Optional:** Yes

**Default:** 0

