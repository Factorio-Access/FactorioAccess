# AnimationElement

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### render_layer

**Type:** `RenderLayer`

**Optional:** Yes

**Default:** "object"

### secondary_draw_order

Used to determine render order for sprites with the same `render_layer` in the same position. Sprites with a higher `secondary_draw_order` are drawn on top.

**Type:** `int8`

**Optional:** Yes

### apply_tint

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### always_draw

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### animation

**Type:** `Animation`

**Optional:** Yes

