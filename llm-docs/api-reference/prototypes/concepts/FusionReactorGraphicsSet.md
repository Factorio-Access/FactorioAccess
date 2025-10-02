# FusionReactorGraphicsSet

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### structure

**Type:** `Sprite4Way`

**Optional:** Yes

### render_layer

**Type:** `RenderLayer`

**Optional:** Yes

**Default:** "object"

### default_fuel_glow_color

**Type:** `Color`

**Optional:** Yes

**Default:** "`{1, 1, 1}`"

### light

**Type:** `LightDefinition`

**Optional:** Yes

### working_light_pictures

**Type:** `Sprite4Way`

**Optional:** Yes

### use_fuel_glow_color

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### fusion_effect_uv_map

**Type:** `Sprite`

**Optional:** Yes

### connections_graphics

**Type:** Array[`FusionReactorConnectionGraphics`]

**Optional:** Yes

### direction_to_connections_graphics

**Type:** Dictionary[`DirectionString`, Array[`uint8`]]

**Optional:** Yes

### plasma_category

Cannot be an empty string.

**Type:** `NeighbourConnectableConnectionCategory`

**Required:** Yes

