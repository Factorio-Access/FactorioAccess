# PodOpacityProcessionBezierControlPoint

One frame in time for a Bezier interpolation.

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### timestamp

Mandatory if `cutscene_opacity` or `outside_opacity` is defined.

**Type:** `MapTick`

**Optional:** Yes

### cutscene_opacity

`cutscene_opacity` and `cutscene_opacity_t` interpolate a double smoothly over time.

**Type:** `double`

**Optional:** Yes

### cutscene_opacity_t

Bidirectional tangent at the given timestamp.

**Type:** `double`

**Optional:** Yes

### outside_opacity

`outside_opacity` and `outside_opacity_t` interpolate a double smoothly over time.

**Type:** `double`

**Optional:** Yes

### outside_opacity_t

Bidirectional tangent at the given timestamp.

**Type:** `double`

**Optional:** Yes

### lut_blend

`lut_blend` and `lut_blend_t` interpolate a double smoothly over time.

LUT won't be overridden however, until the pod is drawn above the game via `draw_switch_tick`.

**Type:** `double`

**Optional:** Yes

### lut_blend_t

Bidirectional tangent at the given timestamp.

**Type:** `double`

**Optional:** Yes

