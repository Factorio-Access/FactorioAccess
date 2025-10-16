# PodDistanceTraveledProcessionBezierControlPoint

One frame in time for a Bezier interpolation.

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### timestamp

Mandatory if `distance` is defined.

**Type:** `MapTick`

**Optional:** Yes

### distance

`distance` and `distance_t` interpolate a double smoothly over time.

**Type:** `double`

**Optional:** Yes

### distance_t

Bidirectional tangent at the given timestamp.

**Type:** `double`

**Optional:** Yes

