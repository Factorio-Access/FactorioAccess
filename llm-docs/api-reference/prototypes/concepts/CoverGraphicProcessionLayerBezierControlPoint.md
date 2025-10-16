# CoverGraphicProcessionLayerBezierControlPoint

One frame in time for a Bezier interpolation.

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### timestamp

Mandatory if `opacity` or `rotation` or `effect_scale_min` or `effect_scale_max` is defined.

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

### rotation

`rotation` and `rotation_t` interpolate a double smoothly over time.

**Type:** `double`

**Optional:** Yes

### rotation_t

Bidirectional tangent at the given timestamp.

**Type:** `double`

**Optional:** Yes

### effect_scale_min

`effect_scale_min` and `effect_scale_min_t` interpolate a double smoothly over time.

**Type:** `double`

**Optional:** Yes

### effect_scale_min_t

Bidirectional tangent at the given timestamp.

**Type:** `double`

**Optional:** Yes

### effect_scale_max

`effect_scale_max` and `effect_scale_max_t` interpolate a double smoothly over time.

**Type:** `double`

**Optional:** Yes

### effect_scale_max_t

Bidirectional tangent at the given timestamp.

**Type:** `double`

**Optional:** Yes

### alt_effect_scale_min

`alt_effect_scale_min` and `alt_effect_scale_min_t` interpolate a double smoothly over time.

**Type:** `double`

**Optional:** Yes

### alt_effect_scale_min_t

Bidirectional tangent at the given timestamp.

**Type:** `double`

**Optional:** Yes

### alt_effect_scale_max

`alt_effect_scale_max` and `alt_effect_scale_max_t` interpolate a double smoothly over time.

**Type:** `double`

**Optional:** Yes

### alt_effect_scale_max_t

Bidirectional tangent at the given timestamp.

**Type:** `double`

**Optional:** Yes

### effect_shift

`effect_shift` and `effect_shift_t` interpolate a vector smoothly over time using `effect_shift_rate` and `effect_shift_rate_t` for a 0-1 rate curve.

Vector value.

**Type:** `Vector`

**Optional:** Yes

### effect_shift_t

Vector tangent.

**Type:** `Vector`

**Optional:** Yes

### effect_shift_rate

Rate 0-1 value.

**Type:** `double`

**Optional:** Yes

### effect_shift_rate_t

Rate tangent.

**Type:** `double`

**Optional:** Yes

### alt_effect_shift

`alt_effect_shift` and `alt_effect_shift_t` interpolate a vector smoothly over time using `alt_effect_shift_rate` and `alt_effect_shift_rate_t` for a 0-1 rate curve.

Vector value.

**Type:** `Vector`

**Optional:** Yes

### alt_effect_shift_t

Vector tangent.

**Type:** `Vector`

**Optional:** Yes

### alt_effect_shift_rate

Rate 0-1 value.

**Type:** `double`

**Optional:** Yes

### alt_effect_shift_rate_t

Rate tangent.

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

