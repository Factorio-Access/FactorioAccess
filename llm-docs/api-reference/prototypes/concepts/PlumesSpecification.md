# PlumesSpecification

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### render_box

If given, the plumes will only render if this area is on screen (relative to the thruster)

**Type:** `BoundingBox`

**Optional:** Yes

### min_probability

**Type:** `float`

**Optional:** Yes

**Default:** 0

### max_probability

**Type:** `float`

**Optional:** Yes

**Default:** 1

### min_y_offset

**Type:** `float`

**Optional:** Yes

**Default:** 0

### max_y_offset

**Type:** `float`

**Optional:** Yes

**Default:** 0

### stateless_visualisations

Array may not be empty and may at most have 255 elements.

Non-zero `period` needs to be provided. May not have `positions` or `particle_tick_offset`.

**Type:** `PlumeEffect` | Array[`PlumeEffect`]

**Optional:** Yes

