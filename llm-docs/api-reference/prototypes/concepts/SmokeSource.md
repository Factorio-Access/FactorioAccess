# SmokeSource

Definition of the smoke of an entity.

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### name

**Type:** `TrivialSmokeID`

**Required:** Yes

### frequency

Number of smokes generated per entity animation cycle (or per tick for some entities). Can't be negative or infinite.

**Type:** `float`

**Required:** Yes

### offset

Offsets animation cycle, to move at which points of the cycle the smoke gets emitted.

**Type:** `float`

**Optional:** Yes

**Default:** 0

### position

Positional offset of smoke source relative to owner entity position. The vector is rotated by orientation of the entity.

If any of `north_position`, `north_east_position`, `east_position`, `south_east_position`, `south_position`, `south_west_position`, `west_position`, `north_west_position` is defined, `position` is used only as default value for directional positions. Orientation of the owner entity will be rounded to 4 or 8 directions and one of the directional positions will be used as the offset instead of `position`.

**Type:** `Vector`

**Optional:** Yes

### has_8_directions

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### north_position

**Type:** `Vector`

**Optional:** Yes

**Default:** "Value of `position`"

### north_east_position

Only loaded if `has_8_directions` is `true`.

**Type:** `Vector`

**Optional:** Yes

**Default:** "Value of `position` rotated north-east"

### east_position

**Type:** `Vector`

**Optional:** Yes

**Default:** "Value of `position` rotated east"

### south_east_position

Only loaded if `has_8_directions` is `true`.

**Type:** `Vector`

**Optional:** Yes

**Default:** "Value of `position` rotated south-east"

### south_position

**Type:** `Vector`

**Optional:** Yes

**Default:** "Value of `position` rotated south"

### south_west_position

Only loaded if `has_8_directions` is `true`.

**Type:** `Vector`

**Optional:** Yes

**Default:** "Value of `position` rotated south-west"

### west_position

**Type:** `Vector`

**Optional:** Yes

**Default:** "Value of `position` rotated west"

### north_west_position

Only loaded if `has_8_directions` is `true`.

**Type:** `Vector`

**Optional:** Yes

**Default:** "Value of `position` rotated north-west"

### deviation

**Type:** `Vector`

**Optional:** Yes

### starting_frame

**Type:** `uint16`

**Optional:** Yes

**Default:** 0

### starting_frame_deviation

**Type:** `uint16`

**Optional:** Yes

**Default:** 0

### height

**Type:** `float`

**Optional:** Yes

**Default:** 0

### height_deviation

**Type:** `float`

**Optional:** Yes

**Default:** 0

### starting_vertical_speed

**Type:** `float`

**Optional:** Yes

**Default:** 0

### starting_vertical_speed_deviation

**Type:** `float`

**Optional:** Yes

**Default:** 0

### vertical_speed_slowdown

A value between `0` and `1`.

**Type:** `float`

**Optional:** Yes

**Default:** 0.965

