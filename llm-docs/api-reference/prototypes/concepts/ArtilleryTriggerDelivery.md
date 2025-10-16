# ArtilleryTriggerDelivery

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### type

**Type:** `"artillery"`

**Required:** Yes

### projectile

Name of a [ArtilleryProjectilePrototype](prototype:ArtilleryProjectilePrototype).

**Type:** `EntityID`

**Required:** Yes

### starting_speed

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

**Type:** `float`

**Optional:** Yes

**Default:** 0

### trigger_fired_artillery

**Type:** `boolean`

**Optional:** Yes

**Default:** False

