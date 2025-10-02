# ResourceEntityPrototype

A mineable/gatherable entity.

**Parent:** [EntityPrototype](EntityPrototype.md)
**Type name:** `resource`

## Examples

```
{
  type = "resource",
  name = "crude-oil",
  icon = "__base__/graphics/icons/crude-oil.png",
  icon_size = 32,
  flags = {"placeable-neutral"},
  category = "basic-fluid",
  order="a-b-a",
  infinite = true,
  highlight = true,
  minimum = 60000,
  normal = 300000,
  infinite_depletion_amount = 10,
  resource_patch_search_radius = 12,
  tree_removal_probability = 0.7,
  tree_removal_max_distance = 32 * 32,
  minable =
  {
    mining_time = 1,
    results =
    {
      {
        type = "fluid",
        name = "crude-oil",
        amount_min = 10,
        amount_max = 10,
        probability = 1
      }
    }
  },
  collision_box = {{ -1.4, -1.4}, {1.4, 1.4}},
  selection_box = {{ -0.5, -0.5}, {0.5, 0.5}},
  autoplace = resource_autoplace.resource_autoplace_settings{
    name = "crude-oil",
    order = "c", -- Other resources are "b"; oil won't get placed if something else is already there.
    base_density = 8.2,
    base_spots_per_km2 = 1.8,
    random_probability = 1/48,
    random_spot_size_minimum = 1,
    random_spot_size_maximum = 1, -- don't randomize spot size
    additional_richness = 220000, -- this increases the total everywhere, so base_density needs to be decreased to compensate
    has_starting_area_placement = false,
    resource_index = resource_autoplace.resource_indexes["crude-oil"],
    regular_rq_factor_multiplier = 1
  },
  stage_counts = {0},
  stages =
  {
    sheet =
    {
      filename = "__base__/graphics/entity/crude-oil/crude-oil.png",
      priority = "extra-high",
      width = 75,
      height = 61,
      frame_count = 4,
      variation_count = 1
    }
  },
  map_color = {r=0.78, g=0.2, b=0.77},
  map_grid = false
}
```

## Properties

### stages

Entity's graphics, using a graphic sheet, with variation and depletion. At least one stage must be defined.

When using [AnimationVariations::sheet](prototype:AnimationVariations::sheet), `frame_count` is the amount of frames per row in the spritesheet. `variation_count` is the amount of rows in the spritesheet. Each row in the spritesheet is one stage of the animation.

**Type:** `AnimationVariations`

**Optional:** Yes

### stage_counts

Number of stages the animation has.

**Type:** Array[`uint32`]

**Required:** Yes

### infinite

If the ore is infinitely minable, or if it will eventually run out of resource.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### highlight

If the resource should be highlighted when holding a mining drill that can mine it (holding a pumpjack highlights crude-oil in the base game).

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### randomize_visual_position

Whether there should be a slight offset to graphics of the resource. Used to make patches a little less uniform in appearance.

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### map_grid

Whether the resource should have a grid pattern on the map instead of a solid map color.

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### draw_stateless_visualisation_under_building

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### minimum

Must be not 0 when `infinite = true`.

**Type:** `uint32`

**Optional:** Yes

**Default:** 0

### normal

Must be not 0 when `infinite = true`.

**Type:** `uint32`

**Optional:** Yes

**Default:** 1

### infinite_depletion_amount

Every time an infinite-type resource "ticks" lower it's lowered by that amount.

**Type:** `uint32`

**Optional:** Yes

**Default:** 1

### resource_patch_search_radius

When hovering over this resource in the map view: How far to search for other resource patches of this type to display as one (summing amount, white outline).

**Type:** `uint32`

**Optional:** Yes

**Default:** 3

### category

The category for the resource. Available categories in vanilla can be found [here](https://wiki.factorio.com/Data.raw#resource-category).

**Type:** `ResourceCategoryID`

**Optional:** Yes

**Default:** "basic-solid"

### walking_sound

Sound played when the player walks over this resource.

**Type:** `Sound`

**Optional:** Yes

### driving_sound

Sound played when a [CarPrototype](prototype:CarPrototype) drives over this resource.

**Type:** `InterruptibleSound`

**Optional:** Yes

### stages_effect

An effect that can be overlaid above the normal ore graphics. Used in the base game to make [uranium ore](https://wiki.factorio.com/Uranium_ore) glow.

**Type:** `AnimationVariations`

**Optional:** Yes

### effect_animation_period

How long it takes `stages_effect` to go from `min_effect_alpha` to `max_effect_alpha`.

**Type:** `float`

**Optional:** Yes

**Default:** 0.0

### effect_animation_period_deviation

How much `effect_animation_period` can deviate from its original value. Used to make the stages effect alpha change look less uniform.

**Type:** `float`

**Optional:** Yes

**Default:** 0.0

### effect_darkness_multiplier

How much the surface darkness should affect the alpha of `stages_effect`.

**Type:** `float`

**Optional:** Yes

**Default:** 1.0

### min_effect_alpha

Minimal alpha value of `stages_effect`.

**Type:** `float`

**Optional:** Yes

**Default:** 0.0

### max_effect_alpha

Maximal alpha value of `stages_effect`.

**Type:** `float`

**Optional:** Yes

**Default:** 1.0

### tree_removal_probability

Must be greater than or equal to `0`.

**Type:** `double`

**Optional:** Yes

**Default:** 0

### cliff_removal_probability

Must be greater than or equal to `0`.

**Type:** `double`

**Optional:** Yes

**Default:** 1.0

### tree_removal_max_distance

Must be positive when `tree_removal_probability` is set.

**Type:** `double`

**Optional:** Yes

**Default:** 0

### mining_visualisation_tint

Defaults to the resources map color if left unset and map color is set, otherwise defaults to white if left unset.

**Type:** `Color`

**Optional:** Yes

