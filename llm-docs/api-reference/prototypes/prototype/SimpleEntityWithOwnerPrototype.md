# SimpleEntityWithOwnerPrototype

Has a force, but unlike [SimpleEntityWithForcePrototype](prototype:SimpleEntityWithForcePrototype) it is only attacked if the biters get stuck on it (or if [EntityWithOwnerPrototype::is_military_target](prototype:EntityWithOwnerPrototype::is_military_target) set to true to make the two entity types equivalent).

Can be rotated in 4 directions. `picture` can be used to specify different graphics per direction.

**Parent:** [EntityWithOwnerPrototype](EntityWithOwnerPrototype.md)
**Type name:** `simple-entity-with-owner`

## Properties

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

Whether a random graphics variation is chosen when placing the entity/creating it via script/creating it via map generation. If this is false, the entity will use the first variation instead of a random one.

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### pictures

Takes priority over `picture` and `animations`.

**Type:** `SpriteVariations`

**Optional:** Yes

### picture

Takes priority over `animations`.

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

Loaded and drawn with all `pictures`, `picture` and `animations`. If graphics variation is larger than number of `lower_pictures` variations this layer is not drawn.

**Type:** `SpriteVariations`

**Optional:** Yes

### stateless_visualisation_variations

**Type:** Array[`StatelessVisualisation` | Array[`StatelessVisualisation`]]

**Optional:** Yes

### force_visibility

If the entity is not visible to a player, the player cannot select it.

**Type:** `ForceCondition`

**Optional:** Yes

**Default:** "all"

