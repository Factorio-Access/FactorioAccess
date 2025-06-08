# SimpleEntityWithOwnerPrototype

Has a force, but unlike [SimpleEntityWithForcePrototype](prototype:SimpleEntityWithForcePrototype) it is only attacked if the biters get stuck on it (or if [EntityWithOwnerPrototype::is_military_target](prototype:EntityWithOwnerPrototype::is_military_target) set to true to make the two entity types equivalent).

Can be rotated in 4 directions. `picture` can be used to specify different graphics per direction.

**Parent:** `EntityWithOwnerPrototype`

## Properties

### Optional Properties

#### animations

**Type:** `AnimationVariations`



#### force_visibility

**Type:** `ForceCondition`

If the entity is not visible to a player, the player cannot select it.

**Default:** `{'complex_type': 'literal', 'value': 'all'}`

#### lower_pictures

**Type:** `SpriteVariations`

Loaded and drawn with all `pictures`, `picture` and `animations`. If graphics variation is larger than number of `lower_pictures` variations this layer is not drawn.

#### lower_render_layer

**Type:** `RenderLayer`



**Default:** `{'complex_type': 'literal', 'value': 'lower-object'}`

#### picture

**Type:** `Sprite4Way`

Takes priority over `animations`.

#### pictures

**Type:** `SpriteVariations`

Takes priority over `picture` and `animations`.

#### random_animation_offset

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': False}`

#### random_variation_on_create

**Type:** `boolean`

Whether a random graphics variation is chosen when placing the entity/creating it via script/creating it via map generation. If this is false, the entity will use the first variation instead of a random one.

**Default:** `{'complex_type': 'literal', 'value': True}`

#### render_layer

**Type:** `RenderLayer`



**Default:** `{'complex_type': 'literal', 'value': 'object'}`

#### secondary_draw_order

**Type:** `int8`

Used to determine render order for entities with the same `render_layer` in the same position. Entities with a higher `secondary_draw_order` are drawn on top.

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### stateless_visualisation_variations

**Type:** ``StatelessVisualisations`[]`



