# CargoHatchDefinition

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### hatch_graphics

**Type:** `Animation`

**Optional:** Yes

### hatch_render_layer

render layer for the hatch itself.

**Type:** `RenderLayer`

**Optional:** Yes

**Default:** "cargo-hatch"

### entering_render_layer

render layer for objects entering the hatch.

**Type:** `RenderLayer`

**Optional:** Yes

**Default:** "cargo-hatch"

### offset

**Type:** `Vector`

**Optional:** Yes

**Default:** "`{0, 0}`"

### pod_shadow_offset

**Type:** `Vector`

**Optional:** Yes

**Default:** "`{0, 0}`"

### sky_slice_height

y height relative to hatch position where the pod art gets clipped from sky to regular sorting layer.

**Type:** `float`

**Optional:** Yes

**Default:** -1.0

### slice_height

y height relative to hatch position where the pod art gets cut off.

**Type:** `float`

**Optional:** Yes

**Default:** 1.0

### travel_height

y height relative to hatch position where the pod travels to during preparing and parking.

**Type:** `float`

**Optional:** Yes

**Default:** 1.0

### busy_timeout_ticks

**Type:** `uint32`

**Optional:** Yes

**Default:** 120

### hatch_opening_ticks

**Type:** `uint32`

**Optional:** Yes

**Default:** 80

### opening_sound

Cannot use `fade_ticks`.

**Type:** `InterruptibleSound`

**Optional:** Yes

### closing_sound

Cannot use `fade_ticks`.

**Type:** `InterruptibleSound`

**Optional:** Yes

### cargo_unit_entity_to_spawn

**Type:** `EntityID`

**Optional:** Yes

### illumination_graphic_index

[ProcessionGraphic](prototype:ProcessionGraphic) index pointing to the [ProcessionGraphicCatalogue](prototype:ProcessionGraphicCatalogue) inside the current [SpaceLocationPrototype](prototype:SpaceLocationPrototype).

**Type:** `uint32`

**Optional:** Yes

**Default:** "MAX_UINT32"

### receiving_cargo_units

**Type:** Array[`EntityID`]

**Optional:** Yes

