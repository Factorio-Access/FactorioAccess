# TintProcessionLayer

Fullscreen overlay which blends gradient from top to bottom edge of the screen using [pre-multiplied alpha blending](prototype:BlendMode::normal).

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### type

**Type:** `"tint"`

**Required:** Yes

### render_layer

**Type:** `RenderLayer`

**Optional:** Yes

**Default:** "object"

### frames

**Type:** Array[`TintProcessionBezierControlPoint`]

**Required:** Yes

