# WaterTileEffectParameters

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### specular_lightness

Affects specular lightness for `"water"` `shader_variation`. Affects panning/warping vector for all other `shader_variation`s.

Any alpha value set here is ignored and will always be `1` in the shader.

**Type:** `Color`

**Required:** Yes

### foam_color

Affects foam color for `"water"` `shader_variation`. Affects panning/warping vector for all other `shader_variation`s.

Any alpha value set here is ignored and will always be `1` in the shader.

**Type:** `Color`

**Required:** Yes

### foam_color_multiplier

Multiplies the rgb values of `foam_color` before they are passed to the shader.

**Type:** `float`

**Required:** Yes

### tick_scale

Affects distortion speed for `"water"` `shader_variation`. Affects panning/warping speed for all other `shader_variation`s.

**Type:** `float`

**Required:** Yes

### animation_speed

Affects distortion speed for `"water"` `shader_variation`. Affects panning/warping speed for all other `shader_variation`s.

**Type:** `float`

**Required:** Yes

### animation_scale

Affects animation scale for `"water"` `shader_variation`. Affects warp effect intensity for `"lava"` `shader_variation`. Affects depth contrast for `"wetland-water"` `shader_variation`. Affects thin film effect intensity for `"oil"` `shader_variation`.

**Type:** `float` | (`float`, `float`)

**Required:** Yes

### dark_threshold

Affects dark threshold for `"water"` `shader_variation`. Affects brightness of the shoreline lava for `"lava"` `shader_variation`. Affects water depth for `"wetland-water"` `shader_variation`. Affects thin film effect noise scale for `"oil"` `shader_variation`.

**Type:** `float` | (`float`, `float`)

**Required:** Yes

### reflection_threshold

Affects reflection threshold for `"water"` `shader_variation`. Affects distortion scale for `"lava"` `shader_variation`. Affects distortion tiling for `"wetland-water"` `shader_variation`. Affects distortion map scale for `"oil"` `shader_variation`.

**Type:** `float` | (`float`, `float`)

**Required:** Yes

### specular_threshold

Affects specular threshold for `"water"` and `"wetland-water"` `shader_variation`s. Affects shoreline lava for `"lava"` `shader_variation`. Affects nothing for `"oil"` `shader_variation`.

**Type:** `float` | (`float`, `float`)

**Required:** Yes

### textures

Texture size must be 512x512. Shader variant `"water"` must have 1 texture, `"lava"` and `"wetland-water"` must have 2 textures and `"oil"` must have 4 textures.

**Type:** Array[`EffectTexture`]

**Required:** Yes

### near_zoom

If they are set to a tuple, the properties `animation_scale`, `dark_threshold`, `reflection_threshold` and `specular_threshold` are linearly interpolated between each of their two values based on the current zoom level expressed as a ratio between `near_zoom` and `far_zoom`. E.g. if current zoom level is equal to `near_zoom`, the first tuple value is picked.

**Type:** `float`

**Optional:** Yes

**Default:** 2.0

### far_zoom

If they are set to a tuple, the properties `animation_scale`, `dark_threshold`, `reflection_threshold` and `specular_threshold` are linearly interpolated between each of their two values based on the current zoom level expressed as a ratio between `near_zoom` and `far_zoom`. E.g. if current zoom level is equal to `far_zoom`, the second tuple value is picked.

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

