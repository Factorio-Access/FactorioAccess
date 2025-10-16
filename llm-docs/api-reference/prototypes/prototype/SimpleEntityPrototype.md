# SimpleEntityPrototype

An extremely basic entity with no special functionality. Used for minable rocks. Cannot be rotated.

**Parent:** [EntityWithHealthPrototype](EntityWithHealthPrototype.md)
**Type name:** `simple-entity`

## Properties

### count_as_rock_for_filtered_deconstruction

Whether this entity should be treated as a rock for the purpose of deconstruction and for [CarPrototype::immune_to_rock_impacts](prototype:CarPrototype::immune_to_rock_impacts).

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### render_layer

**Type:** `RenderLayer`

**Optional:** Yes

**Default:** "object"

### secondary_draw_order

Used to determine render order for entities with the same `render_layer` in the same position. Entities with a higher `secondary_draw_order` are drawn on top.

**Type:** `int8`

**Optional:** Yes

**Default:** 0

### random_animation_offset

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### random_variation_on_create

Whether a random graphics variation is chosen when placing the entity/creating it via script/creating it via map generation. If this is `false`, the entity will use the first variation instead of a random one.

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### pictures

Takes priority over `picture` and `animations`.

**Type:** `SpriteVariations`

**Optional:** Yes

### picture

Takes priority over `animations`. Only the `north` sprite is used because this entity cannot be rotated.

**Type:** `Sprite4Way`

**Optional:** Yes

### animations

**Type:** `AnimationVariations`

**Optional:** Yes

### lower_render_layer

**Type:** `RenderLayer`

**Optional:** Yes

**Default:** "lower-object"

### lower_pictures

**Type:** `SpriteVariations`

**Optional:** Yes

### stateless_visualisation_variations

Loaded and drawn with all `pictures`, `picture` and `animations`. If graphics variation is larger than number of `lower_pictures` variations this layer is not drawn.

**Type:** Array[`StatelessVisualisation` | Array[`StatelessVisualisation`]]

**Optional:** Yes

