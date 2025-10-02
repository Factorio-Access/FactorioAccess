# SingleGraphicLayerProcessionBezierControlPoint

One frame in time for a Bezier interpolation.

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### timestamp

Mandatory if `opacity` or `tint` is defined.

**Type:** `MapTick`

**Optional:** Yes

### opacity

`opacity` and `opacity_t` interpolate a double smoothly over time.

**Type:** `double`

**Optional:** Yes

**Default:** 1.0

### opacity_t

Bidirectional tangent at the given timestamp.

**Type:** `double`

**Optional:** Yes

### tint

`tint` and `tint_t` interpolate a color smoothly over time.

**Type:** `Color`

**Optional:** Yes

**Default:** "{1.0, 1.0, 1.0, 1.0}"

### tint_t

Bidirectional tangent at the given timestamp.

**Type:** `Color`

**Optional:** Yes

### rotation

`rotation` and `rotation_t` interpolate a double smoothly over time.

**Type:** `double`

**Optional:** Yes

**Default:** 0.0

### rotation_t

Bidirectional tangent at the given timestamp.

**Type:** `double`

**Optional:** Yes

### scale

`scale` and `scale_t` interpolate a double smoothly over time.

**Type:** `double`

**Optional:** Yes

**Default:** 1.0

### scale_t

Bidirectional tangent at the given timestamp.

**Type:** `double`

**Optional:** Yes

### shift

`shift` and `shift_t` interpolate a vector smoothly over time using `shift_rate` and `shift_rate_t` for a 0-1 rate curve.

Vector value.

**Type:** `Vector`

**Optional:** Yes

**Default:** "{0.0, 0.0}"

### shift_t

Vector tangent.

**Type:** `Vector`

**Optional:** Yes

### shift_rate

Rate 0-1 value.

**Type:** `double`

**Optional:** Yes

### shift_rate_t

Rate tangent.

**Type:** `double`

**Optional:** Yes

### frame

the frame of the pod animation played. Used only when 'animation_driven_by_curve' is enabled.

**Type:** `float`

**Optional:** Yes

**Default:** 0.0

