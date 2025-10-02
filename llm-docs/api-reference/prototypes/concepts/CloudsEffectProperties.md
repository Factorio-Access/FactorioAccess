# CloudsEffectProperties

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### shape_noise_texture

**Type:** `EffectTexture`

**Required:** Yes

### detail_noise_texture

**Type:** `EffectTexture`

**Required:** Yes

### warp_sample_1

**Type:** `CloudsTextureCoordinateTransformation`

**Required:** Yes

### warp_sample_2

**Type:** `CloudsTextureCoordinateTransformation`

**Required:** Yes

### warped_shape_sample

**Type:** `CloudsTextureCoordinateTransformation`

**Required:** Yes

### additional_density_sample

**Type:** `CloudsTextureCoordinateTransformation`

**Required:** Yes

### detail_sample_1

**Type:** `CloudsTextureCoordinateTransformation`

**Required:** Yes

### detail_sample_2

**Type:** `CloudsTextureCoordinateTransformation`

**Required:** Yes

### scale

**Type:** `float`

**Optional:** Yes

**Default:** 1

### movement_speed_multiplier

**Type:** `float`

**Optional:** Yes

**Default:** 0.75

### shape_warp_strength

**Type:** `float`

**Optional:** Yes

**Default:** 0.06

### shape_warp_weight

**Type:** `float`

**Optional:** Yes

**Default:** 0.4

### opacity

**Type:** `float`

**Optional:** Yes

**Default:** 0.25

### opacity_at_night

**Type:** `float`

**Optional:** Yes

**Default:** 0

### density

**Type:** `float`

**Optional:** Yes

**Default:** 0

### density_at_night

**Type:** `float`

**Optional:** Yes

**Default:** "Value of `density`"

### detail_factor

**Type:** `float`

**Optional:** Yes

**Default:** 1.5

### detail_factor_at_night

**Type:** `float`

**Optional:** Yes

**Default:** "Value of `detail_factor`"

### shape_factor

**Type:** `float`

**Optional:** Yes

**Default:** -1

### detail_exponent

**Type:** `float`

**Optional:** Yes

**Default:** 0.1

### detail_sample_morph_duration

When set to 0, detail textures are not being "morphed" to each other, but lerped with ratio 0.5 instead.

**Type:** `uint32`

**Optional:** Yes

**Default:** 256

