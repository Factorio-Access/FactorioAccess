# SpaceTileEffectParameters

Nebulae are rendered only behind tiles with the effect, but stars are rendered behind entire terrain. For that reason using two or more tile types with different space effect on one surface is not supported. The game will allow this to happen, but rendering will chose one star configuration for entire screen.

Zoom is recalculated using formula `max(1/1024, pow(max(0, zoom * base_factor + base_offset), exponent) * factor + offset)`.

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### scroll_factor

**Type:** `float`

**Optional:** Yes

**Default:** 0.25

### zoom_base_factor

**Type:** `float`

**Optional:** Yes

**Default:** 0.25

### zoom_base_offset

**Type:** `float`

**Optional:** Yes

**Default:** 0.75

### zoom_exponent

**Type:** `float`

**Optional:** Yes

**Default:** 1

### zoom_factor

**Type:** `float`

**Optional:** Yes

**Default:** 1

### zoom_offset

**Type:** `float`

**Optional:** Yes

**Default:** 0

### nebula_scale

**Type:** `float`

**Optional:** Yes

**Default:** 0.9

### nebula_brightness

**Type:** `float`

**Optional:** Yes

**Default:** 0.5

### nebula_saturation

**Type:** `float`

**Optional:** Yes

**Default:** 0.9

### star_density

**Type:** `float`

**Optional:** Yes

**Default:** 0.01

### star_scale

**Type:** `float`

**Optional:** Yes

**Default:** 100

### star_parallax

**Type:** `float`

**Optional:** Yes

**Default:** 0.06

### star_shape

**Type:** `float`

**Optional:** Yes

**Default:** 1.666

### star_brightness

**Type:** `float`

**Optional:** Yes

**Default:** 1

### star_saturations

**Type:** `float`

**Optional:** Yes

**Default:** 0.5

