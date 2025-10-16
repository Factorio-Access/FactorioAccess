# RailPictureSet

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### north

**Type:** `RailPieceLayers`

**Required:** Yes

### northeast

**Type:** `RailPieceLayers`

**Required:** Yes

### east

**Type:** `RailPieceLayers`

**Required:** Yes

### southeast

**Type:** `RailPieceLayers`

**Required:** Yes

### south

**Type:** `RailPieceLayers`

**Required:** Yes

### southwest

**Type:** `RailPieceLayers`

**Required:** Yes

### west

**Type:** `RailPieceLayers`

**Required:** Yes

### northwest

**Type:** `RailPieceLayers`

**Required:** Yes

### front_rail_endings

**Type:** `Sprite16Way`

**Optional:** Yes

**Default:** "Value of `rail_endings`"

### back_rail_endings

**Type:** `Sprite16Way`

**Optional:** Yes

**Default:** "Value of `rail_endings`"

### rail_endings

Can be used to load rail endings instead of the front and back variants.

Only loaded if `front_rail_endings` or `back_rail_endings` are not defined.

**Type:** `Sprite16Way`

**Optional:** Yes

### segment_visualisation_endings

Must contain exactly 16 directions and 6 frames.

**Type:** `RotatedAnimation`

**Optional:** Yes

### render_layers

**Type:** `RailRenderLayers`

**Required:** Yes

### secondary_render_layers

**Type:** `RailRenderLayers`

**Optional:** Yes

**Default:** "Value of `render_layers`"

### slice_origin

**Type:** `RailsSliceOffsets`

**Optional:** Yes

### fog_mask

**Type:** `RailsFogMaskDefinitions`

**Optional:** Yes

