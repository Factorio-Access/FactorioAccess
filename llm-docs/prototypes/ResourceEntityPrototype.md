# ResourceEntityPrototype

A mineable/gatherable entity.

**Parent:** `EntityPrototype`

## Properties

### Mandatory Properties

#### stage_counts

**Type:** ``uint32`[]`

Number of stages the animation has.

### Optional Properties

#### category

**Type:** `ResourceCategoryID`

The category for the resource. Available categories in vanilla can be found [here](https://wiki.factorio.com/Data.raw#resource-category).

**Default:** `{'complex_type': 'literal', 'value': 'basic-solid'}`

#### cliff_removal_probability

**Type:** `double`

Must be greater than or equal to `0`.

**Default:** `{'complex_type': 'literal', 'value': 1.0}`

#### draw_stateless_visualisation_under_building

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### driving_sound

**Type:** `InterruptibleSound`

Sound played when a [CarPrototype](prototype:CarPrototype) drives over this resource.

#### effect_animation_period

**Type:** `float`

How long it takes `stages_effect` to go from `min_effect_alpha` to `max_effect_alpha`.

**Default:** `{'complex_type': 'literal', 'value': 0.0}`

#### effect_animation_period_deviation

**Type:** `float`

How much `effect_animation_period` can deviate from its original value. Used to make the stages effect alpha change look less uniform.

**Default:** `{'complex_type': 'literal', 'value': 0.0}`

#### effect_darkness_multiplier

**Type:** `float`

How much the surface darkness should affect the alpha of `stages_effect`.

**Default:** `{'complex_type': 'literal', 'value': 1.0}`

#### highlight

**Type:** `boolean`

If the resource should be highlighted when holding a mining drill that can mine it (holding a pumpjack highlights crude-oil in the base game).

**Default:** `{'complex_type': 'literal', 'value': False}`

#### infinite

**Type:** `boolean`

If the ore is infinitely minable, or if it will eventually run out of resource.

**Default:** `{'complex_type': 'literal', 'value': False}`

#### infinite_depletion_amount

**Type:** `uint32`

Every time an infinite-type resource "ticks" lower it's lowered by that amount.

**Default:** `{'complex_type': 'literal', 'value': 1}`

#### map_grid

**Type:** `boolean`

Whether the resource should have a grid pattern on the map instead of a solid map color.

**Default:** `{'complex_type': 'literal', 'value': True}`

#### max_effect_alpha

**Type:** `float`

Maximal alpha value of `stages_effect`.

**Default:** `{'complex_type': 'literal', 'value': 1.0}`

#### min_effect_alpha

**Type:** `float`

Minimal alpha value of `stages_effect`.

**Default:** `{'complex_type': 'literal', 'value': 0.0}`

#### minimum

**Type:** `uint32`

Must be not 0 when `infinite = true`.

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### mining_visualisation_tint

**Type:** `Color`

Defaults to the resources map color if left unset and map color is set, otherwise defaults to white if left unset.

#### normal

**Type:** `uint32`

Must be not 0 when `infinite = true`.

**Default:** `{'complex_type': 'literal', 'value': 1}`

#### randomize_visual_position

**Type:** `boolean`

Whether there should be a slight offset to graphics of the resource. Used to make patches a little less uniform in appearance.

**Default:** `{'complex_type': 'literal', 'value': True}`

#### resource_patch_search_radius

**Type:** `uint32`

When hovering over this resource in the map view: How far to search for other resource patches of this type to display as one (summing amount, white outline).

**Default:** `{'complex_type': 'literal', 'value': 3}`

#### stages

**Type:** `AnimationVariations`

Entity's graphics, using a graphic sheet, with variation and depletion. At least one stage must be defined.

When using [AnimationVariations::sheet](prototype:AnimationVariations::sheet), `frame_count` is the amount of frames per row in the spritesheet. `variation_count` is the amount of rows in the spritesheet. Each row in the spritesheet is one stage of the animation.

#### stages_effect

**Type:** `AnimationVariations`

An effect that can be overlaid above the normal ore graphics. Used in the base game to make [uranium ore](https://wiki.factorio.com/Uranium_ore) glow.

#### tree_removal_max_distance

**Type:** `double`

Must be positive when `tree_removal_probability` is set.

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### tree_removal_probability

**Type:** `double`

Must be greater than or equal to `0`.

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### walking_sound

**Type:** `Sound`

Sound played when the player walks over this resource.

