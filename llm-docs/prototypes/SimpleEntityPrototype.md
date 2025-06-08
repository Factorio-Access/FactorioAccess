# SimpleEntityPrototype

An extremely basic entity with no special functionality. Used for minable rocks. Cannot be rotated.

**Parent:** `EntityWithHealthPrototype`

## Properties

### Optional Properties

#### animations

**Type:** `AnimationVariations`



#### count_as_rock_for_filtered_deconstruction

**Type:** `boolean`

Whether this entity should be treated as a rock for the purpose of deconstruction and for [CarPrototype::immune_to_rock_impacts](prototype:CarPrototype::immune_to_rock_impacts).

**Default:** `{'complex_type': 'literal', 'value': False}`

#### lower_pictures

**Type:** `SpriteVariations`



#### lower_render_layer

**Type:** `RenderLayer`



**Default:** `{'complex_type': 'literal', 'value': 'lower-object'}`

#### picture

**Type:** `Sprite4Way`

Takes priority over `animations`. Only the `north` sprite is used because this entity cannot be rotated.

#### pictures

**Type:** `SpriteVariations`

Takes priority over `picture` and `animations`.

#### random_animation_offset

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': False}`

#### random_variation_on_create

**Type:** `boolean`

Whether a random graphics variation is chosen when placing the entity/creating it via script/creating it via map generation. If this is `false`, the entity will use the first variation instead of a random one.

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

Loaded and drawn with all `pictures`, `picture` and `animations`. If graphics variation is larger than number of `lower_pictures` variations this layer is not drawn.

