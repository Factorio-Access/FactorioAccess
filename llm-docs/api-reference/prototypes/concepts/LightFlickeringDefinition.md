# LightFlickeringDefinition

Specifies the light flicker. Note that this defaults to "showing a white light" instead of the usually expected "showing nothing".

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### minimum_intensity

Brightness of the light in the range `[0, 1]` where `0` is no light and `1` is the maximum light.

**Type:** `float`

**Optional:** Yes

**Default:** 0.2

### maximum_intensity

Brightness of the light in the range `[0, 1]` where `0` is no light and `1` is the maximum light.

**Type:** `float`

**Optional:** Yes

**Default:** 0.8

### derivation_change_frequency

**Type:** `float`

**Optional:** Yes

**Default:** 0.3

### derivation_change_deviation

**Type:** `float`

**Optional:** Yes

**Default:** 0.06

### border_fix_speed

**Type:** `float`

**Optional:** Yes

**Default:** 0.02

### minimum_light_size

The radius of the light in tiles. Note, that the light gets darker near the edges, so the effective size of the light seems to be smaller.

**Type:** `float`

**Optional:** Yes

**Default:** 0.5

### light_intensity_to_size_coefficient

**Type:** `float`

**Optional:** Yes

**Default:** 0.5

### color

Color of the light.

**Type:** `Color`

**Optional:** Yes

**Default:** "{r=1, g=1, b=1} (White)"

