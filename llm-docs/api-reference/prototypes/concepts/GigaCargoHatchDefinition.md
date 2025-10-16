# GigaCargoHatchDefinition

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### hatch_graphics_back

**Type:** `Animation`

**Optional:** Yes

### hatch_graphics_front

**Type:** `Animation`

**Optional:** Yes

### hatch_render_layer_back

**Type:** `RenderLayer`

**Optional:** Yes

**Default:** "higher-object-under"

### hatch_render_layer_front

**Type:** `RenderLayer`

**Optional:** Yes

**Default:** "higher-object-above"

### covered_hatches

**Type:** Array[`uint32`]

**Required:** Yes

### opening_sound

Cannot use `fade_ticks`.

**Type:** `InterruptibleSound`

**Optional:** Yes

### closing_sound

Cannot use `fade_ticks`.

**Type:** `InterruptibleSound`

**Optional:** Yes

