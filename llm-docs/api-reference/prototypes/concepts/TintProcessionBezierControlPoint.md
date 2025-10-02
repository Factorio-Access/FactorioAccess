# TintProcessionBezierControlPoint

One frame in time for a Bezier interpolation.

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### timestamp

Mandatory if `opacity` or `tint_upper` or `tint_lower` is defined.

**Type:** `MapTick`

**Optional:** Yes

### opacity

`opacity` and `opacity_t` interpolate a double smoothly over time.

**Type:** `double`

**Optional:** Yes

### opacity_t

Bidirectional tangent at the given timestamp.

**Type:** `double`

**Optional:** Yes

### tint_upper

`tint_upper` and `tint_upper_t` interpolate a color smoothly over time.

**Type:** `Color`

**Optional:** Yes

### tint_upper_t

Bidirectional tangent at the given timestamp.

**Type:** `Color`

**Optional:** Yes

### tint_lower

`tint_lower` and `tint_lower_t` interpolate a color smoothly over time.

**Type:** `Color`

**Optional:** Yes

### tint_lower_t

Bidirectional tangent at the given timestamp.

**Type:** `Color`

**Optional:** Yes

