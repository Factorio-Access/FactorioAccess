# SingleGraphicProcessionLayer

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### type

**Type:** `"single-graphic"`

**Required:** Yes

### graphic

**Type:** `ProcessionGraphic`

**Required:** Yes

### render_layer

**Type:** `RenderLayer`

**Optional:** Yes

**Default:** "object"

### secondary_draw_order

**Type:** `int8`

**Optional:** Yes

**Default:** 0

### relative_to

Where the sprite is centered.

**Type:** `EffectRelativeTo`

**Optional:** Yes

**Default:** "pod"

### compensated_pivot

Swaps the order of sprite shift and rotation.

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### rotates_with_pod

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### shift_rotates_with_pod

Only applied when the `relative_to` is `pod`.

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### is_passenger_only

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### clip_with_hatches

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### animation_driven_by_curve

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### frames

**Type:** Array[`SingleGraphicLayerProcessionBezierControlPoint`]

**Required:** Yes

