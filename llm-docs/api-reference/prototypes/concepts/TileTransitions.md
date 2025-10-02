# TileTransitions

Used for [TilePrototype](prototype:TilePrototype) graphics.

Use `layout` with `spritesheet` to define all the tile layers inside the `layout` property. The `*_enabled`, `*_layout` and `*_spritesheet` properties can be used to override specific layers of a reused layout.

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### layout

**Type:** `TileTransitionSpritesheetLayout`

**Optional:** Yes

### spritesheet

Default spritesheet for all TileSpriteLayouts.

**Type:** `FileName`

**Optional:** Yes

### overlay_enabled

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### mask_enabled

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### background_enabled

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### background_mask_enabled

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### effect_map_enabled

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### lightmap_enabled

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### auxiliary_effect_mask_enabled

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### overlay_layout

Overrides the `overlay` definition inside `layout`.

**Type:** `TileTransitionVariantLayout`

**Optional:** Yes

### mask_layout

Overrides the `mask` definition inside `layout`.

**Type:** `TileTransitionVariantLayout`

**Optional:** Yes

### background_layout

Overrides the `background` definition inside `layout`.

**Type:** `TileTransitionVariantLayout`

**Optional:** Yes

### background_mask_layout

Overrides the `background_mask` definition inside `layout`.

**Type:** `TileTransitionVariantLayout`

**Optional:** Yes

### effect_map_layout

Overrides the `effect_map` definition inside `layout`.

**Type:** `TileTransitionVariantLayout`

**Optional:** Yes

### lightmap_layout

Overrides the `lightmap` definition inside `layout`.

**Type:** `TileTransitionVariantLayout`

**Optional:** Yes

### auxiliary_effect_mask_layout

Overrides the `auxiliary_effect_mask` definition inside `layout`.

**Type:** `TileTransitionVariantLayout`

**Optional:** Yes

### mask_spritesheet

Only loaded if `layout` or `mask_layout` is defined.

Default spritesheet for `mask_layout` and `layout.mask`.

**Type:** `FileName`

**Optional:** Yes

**Default:** "Value of `spritesheet`"

### background_spritesheet

Only loaded if `layout` or `background_layout` is defined.

Default spritesheet for `background_layout` and `layout.background`.

**Type:** `FileName`

**Optional:** Yes

**Default:** "Value of `spritesheet`"

### background_mask_spritesheet

Only loaded if `layout` or `background_mask_layout` is defined.

Default spritesheet for `background_mask_layout` and `layout.background_mask`.

**Type:** `FileName`

**Optional:** Yes

**Default:** "Value of `spritesheet`"

### effect_map_spritesheet

Only loaded if `layout` or `effect_map_layout` is defined.

Default spritesheet for `effect_map_layout` and `layout.effect_map`.

**Type:** `FileName`

**Optional:** Yes

**Default:** "Value of `spritesheet`"

### lightmap_spritesheet

Only loaded if `layout` or `lightmap_layout` is defined.

Default spritesheet for `lightmap_layout` and `layout.lightmap`.

**Type:** `FileName`

**Optional:** Yes

**Default:** "Value of `spritesheet`"

### auxiliary_effect_mask_spritesheet

Only loaded if `layout` or `auxiliary_effect_mask_layout` is defined.

Default spritesheet for `auxiliary_effect_mask_layout` and `layout.auxiliary_effect_mask`.

**Type:** `FileName`

**Optional:** Yes

**Default:** "Value of `spritesheet`"

### water_patch

**Type:** `Sprite`

**Optional:** Yes

### overlay_layer_group

**Type:** `TileRenderLayer`

**Optional:** Yes

### background_layer_group

**Type:** `TileRenderLayer`

**Optional:** Yes

### waving_effect_time_scale

**Type:** `float`

**Optional:** Yes

**Default:** 0.15

### overlay_layer_offset

**Type:** `int8`

**Optional:** Yes

### masked_overlay_layer_offset

**Type:** `int8`

**Optional:** Yes

**Default:** 0

### background_layer_offset

**Type:** `int8`

**Optional:** Yes

**Default:** 0

### masked_background_layer_offset

**Type:** `int8`

**Optional:** Yes

**Default:** "Value of `background_layer_offset`"

### draw_background_layer_under_tiles

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### background_layer_occludes_light

If drawing under water which is supposed to yield water mask, set this to `false` to not mess up the water mask.

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### apply_effect_color_to_overlay

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### apply_waving_effect_on_masks

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### apply_waving_effect_on_background_mask

**Type:** `boolean`

**Optional:** Yes

**Default:** "Value of `apply_waving_effect_on_masks`"

### draw_simple_outer_corner_over_diagonal

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### offset_background_layer_by_tile_layer

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### inner_corner_weights

**Type:** Array[`float`]

**Optional:** Yes

### outer_corner_weights

**Type:** Array[`float`]

**Optional:** Yes

### side_weights

**Type:** Array[`float`]

**Optional:** Yes

### side_variations_in_group

**Type:** `uint8`

**Optional:** Yes

### double_side_weights

**Type:** Array[`float`]

**Optional:** Yes

### double_side_variations_in_group

**Type:** `uint8`

**Optional:** Yes

### u_transition_weights

**Type:** Array[`float`]

**Optional:** Yes

