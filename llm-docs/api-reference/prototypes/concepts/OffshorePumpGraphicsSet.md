# OffshorePumpGraphicsSet

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### animation

Rendered in "object" layer, with secondary draw order 0.

**Type:** `Animation4Way`

**Optional:** Yes

### base_render_layer

**Type:** `RenderLayer`

**Optional:** Yes

**Default:** "ground-patch"

### underwater_layer_offset

**Type:** `int8`

**Optional:** Yes

**Default:** 1

### fluid_animation

Rendered in "object" layer, with secondary draw order 20.

**Type:** `Animation4Way`

**Optional:** Yes

### glass_pictures

Rendered in "object" layer, with secondary draw order 40.

**Type:** `Sprite4Way`

**Optional:** Yes

### base_pictures

Rendered in layer specified by `base_render_layer`, with secondary draw order 0.

**Type:** `Sprite4Way`

**Optional:** Yes

### underwater_pictures

Drawn by tile renderer when water animation is enabled.

**Type:** `Sprite4Way`

**Optional:** Yes

