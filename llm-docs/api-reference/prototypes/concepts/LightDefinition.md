# LightDefinition

Specifies a light source. This is loaded either as a single light source or as an array of light sources.

**Type:** `Struct` (see below for attributes) | Array[`Struct` (see below for attributes)]

## Properties

*These properties apply when the value is a struct/table.*

### type

**Type:** `"basic"` | `"oriented"`

**Optional:** Yes

**Default:** "basic"

### picture

Only loaded, and mandatory if `type` is `"oriented"`.

**Type:** `Sprite`

**Optional:** Yes

### rotation_shift

Only loaded if `type` is `"oriented"`.

**Type:** `RealOrientation`

**Optional:** Yes

**Default:** 0

### intensity

Brightness of the light in the range `[0, 1]`, where `0` is no light and `1` is the maximum light.

**Type:** `float`

**Required:** Yes

### size

The radius of the light in tiles. Note that the light gets darker near the edges, so the effective size of the light will appear to be smaller.

**Type:** `float`

**Required:** Yes

### source_orientation_offset

**Type:** `RealOrientation`

**Optional:** Yes

**Default:** 0

### add_perspective

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### flicker_interval

**Type:** `uint8`

**Optional:** Yes

**Default:** 0

### flicker_min_modifier

**Type:** `float`

**Optional:** Yes

**Default:** 1.0

### flicker_max_modifier

**Type:** `float`

**Optional:** Yes

**Default:** "Value of `flicker_min_modifier`"

### offset_flicker

Offsets tick used to calculate flicker by position hash. Useful to desynchronize flickering of multiple stationary lights.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### shift

**Type:** `Vector`

**Optional:** Yes

### color

Color of the light.

**Type:** `Color`

**Optional:** Yes

**Default:** "`{r=1, g=1, b=1}`"

### minimum_darkness

**Type:** `float`

**Optional:** Yes

**Default:** 0

## Examples

```
```
-- The light of the orange state of the rail signal
orange_light = {intensity = 0.2, size = 4, color={r=1, g=0.5}}
```
```

```
```
-- The front lights of the car
light =
{
  {
    type = "oriented",
    minimum_darkness = 0.3,
    picture =
    {
      filename = "__core__/graphics/light-cone.png",
      priority = "extra-high",
      flags = { "light" },
      scale = 2,
      width = 200,
      height = 200
    },
    shift = {-0.6, -14},
    size = 2,
    intensity = 0.6,
    color = {r = 0.92, g = 0.77, b = 0.3}
  },
  {
    type = "oriented",
    minimum_darkness = 0.3,
    picture =
    {
      filename = "__core__/graphics/light-cone.png",
      priority = "extra-high",
      flags = { "light" },
      scale = 2,
      width = 200,
      height = 200
    },
    shift = {0.6, -14},
    size = 2,
    intensity = 0.6,
    color = {r = 0.92, g = 0.77, b = 0.3}
  }
}
```
```

