# PodMovementProcessionBezierControlPoint

One frame in time for a Bezier interpolation.

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### timestamp

Mandatory if `tilt` is defined.

**Type:** `MapTick`

**Optional:** Yes

### tilt

`tilt` and `tilt_t` interpolate a double smoothly over time.

**Type:** `double`

**Optional:** Yes

### tilt_t

Bidirectional tangent at the given timestamp.

**Type:** `double`

**Optional:** Yes

### offset

`offset` and `offset_t` interpolate a vector smoothly over time using `offset_rate` and `offset_rate_t` for a 0-1 rate curve.

Vector value.

**Type:** `Vector`

**Optional:** Yes

### offset_t

Vector tangent.

**Type:** `Vector`

**Optional:** Yes

### offset_rate

Rate 0-1 value.

**Type:** `double`

**Optional:** Yes

### offset_rate_t

Rate tangent.

**Type:** `double`

**Optional:** Yes

