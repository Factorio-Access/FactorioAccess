# TreePrototype

A [tree](https://wiki.factorio.com/Tree).

**Parent:** [EntityWithHealthPrototype](EntityWithHealthPrototype.md)
**Type name:** `tree`

## Properties

### variation_weights

**Type:** Array[`float`]

**Optional:** Yes

### darkness_of_burnt_tree

**Type:** `float`

**Optional:** Yes

**Default:** 0.5

### pictures

Mandatory if `variations` is not defined.

**Type:** `SpriteVariations`

**Optional:** Yes

### variations

If defined, it can't be empty.

**Type:** Array[`TreeVariation`]

**Optional:** Yes

### colors

Mandatory if `variations` is defined.

**Type:** Array[`Color`]

**Optional:** Yes

### stateless_visualisation_variations

**Type:** Array[`StatelessVisualisations`]

**Optional:** Yes

### healing_per_tick

The amount of health automatically regenerated. Trees will regenerate every 60 ticks with `healing_per_tick × 60`.

**Type:** `float`

**Optional:** Yes

**Default:** 0.001666

**Overrides parent:** Yes

**Examples:**

```
healing_per_tick = 0.01
```

