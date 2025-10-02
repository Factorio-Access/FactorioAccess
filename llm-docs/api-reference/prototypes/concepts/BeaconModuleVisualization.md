# BeaconModuleVisualization

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### has_empty_slot

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### secondary_draw_order

Used to determine render order for sprites with the same `render_layer` in the same position. Sprites with a higher `secondary_draw_order` are drawn on top.

**Type:** `int8`

**Optional:** Yes

**Default:** 0

### apply_module_tint

Which tint set in [ModulePrototype::beacon_tint](prototype:ModulePrototype::beacon_tint) should be applied to this, if any.

**Type:** `ModuleTint`

**Optional:** Yes

**Default:** "none"

### render_layer

**Type:** `RenderLayer`

**Optional:** Yes

**Default:** "object"

### pictures

**Type:** `SpriteVariations`

**Optional:** Yes

