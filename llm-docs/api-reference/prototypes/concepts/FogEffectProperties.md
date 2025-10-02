# FogEffectProperties

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### fog_type

`gleba` type is rendered per chunk and opacity of fog depends on count of tiles with [lowland_fog](prototype:TilePrototype::lowland_fog) set to `true` on the chunk.

**Type:** `"vulcanus"` | `"gleba"`

**Optional:** Yes

**Default:** "vulcanus"

### shape_noise_texture

**Type:** `EffectTexture`

**Required:** Yes

### detail_noise_texture

**Type:** `EffectTexture`

**Required:** Yes

### color1

**Type:** `Color`

**Optional:** Yes

**Default:** "{1, 1, 1, 1}"

### color2

**Type:** `Color`

**Optional:** Yes

**Default:** "{1, 1, 1, 1}"

### tick_factor

**Type:** `float`

**Optional:** Yes

**Default:** 5e-06

