# WaterTileEffectParameters

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### specular_lightness

**Type:** `Color`

**Required:** Yes

### foam_color

**Type:** `Color`

**Required:** Yes

### foam_color_multiplier

**Type:** `float`

**Required:** Yes

### tick_scale

**Type:** `float`

**Required:** Yes

### animation_speed

**Type:** `float`

**Required:** Yes

### animation_scale

**Type:** `float` | (`float`, `float`)

**Required:** Yes

### dark_threshold

**Type:** `float` | (`float`, `float`)

**Required:** Yes

### reflection_threshold

**Type:** `float` | (`float`, `float`)

**Required:** Yes

### specular_threshold

**Type:** `float` | (`float`, `float`)

**Required:** Yes

### textures

Texture size must be 512x512. Shader variant `"water"` must have 1 texture, `"lava"` and `"wetland-water"` must have 2 textures and `"oil"` must have 4 textures.

**Type:** Array[`EffectTexture`]

**Required:** Yes

### near_zoom

**Type:** `float`

**Optional:** Yes

**Default:** 2.0

### far_zoom

**Type:** `float`

**Optional:** Yes

**Default:** 0.5

### lightmap_alpha

Value 0 makes water appear as water in water mask, but does not occlude lights, and doesn't overwrite lightmap alpha drawn to pixel previously (by background layer of tile transition, or underwater sprite). Light emitted by water-like-tile (for example lava) will blend additively with previously rendered light. Value 1 makes water occlude lights, but won't be recognized as water in water mask used for masking decals by water.

**Type:** `float`

**Optional:** Yes

**Default:** 1

### shader_variation

**Type:** `EffectVariation`

**Optional:** Yes

**Default:** "water"

### texture_variations_rows

**Type:** `uint8`

**Optional:** Yes

**Default:** 1

### texture_variations_columns

**Type:** `uint8`

**Optional:** Yes

**Default:** 1

### secondary_texture_variations_rows

**Type:** `uint8`

**Optional:** Yes

**Default:** 1

### secondary_texture_variations_columns

**Type:** `uint8`

**Optional:** Yes

**Default:** 1

