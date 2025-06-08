# TreePrototype

A [tree](https://wiki.factorio.com/Tree).

**Parent:** `EntityWithHealthPrototype`

## Properties

### Optional Properties

#### colors

**Type:** ``Color`[]`

Mandatory if `variations` is defined.

#### darkness_of_burnt_tree

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 0.5}`

#### healing_per_tick

**Type:** `float`

The amount of health automatically regenerated. Trees will regenerate every 60 ticks with `healing_per_tick × 60`.

**Default:** `{'complex_type': 'literal', 'value': 0.001666}`

#### pictures

**Type:** `SpriteVariations`

Mandatory if `variations` is not defined.

#### stateless_visualisation_variations

**Type:** ``StatelessVisualisations`[]`



#### variation_weights

**Type:** ``float`[]`



#### variations

**Type:** ``TreeVariation`[]`

If defined, it can't be empty.

