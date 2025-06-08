# AirbornePollutantPrototype

A type of pollution that can spread throughout the chunks of a map.

**Parent:** `Prototype`

## Properties

### Mandatory Properties

#### affects_evolution

**Type:** `boolean`



#### affects_water_tint

**Type:** `boolean`

If true, large amounts of this pollution will cause water tiles to turn a sickly green.

#### chart_color

**Type:** `Color`



#### icon

**Type:** `Sprite`



### Optional Properties

#### damages_trees

**Type:** `boolean`

If true, trees will occasionally take damage from this pollutant type. When they do, some amount of pollution is removed from the chunk equal to the map's `pollution_restored_per_tree_damage` setting.

**Default:** `{'complex_type': 'literal', 'value': True}`

#### localised_name_with_amount

**Type:** `string`

The translated plural string key to use when displaying this pollution's name with an amount. See [Tutorial:Localisation](https://wiki.factorio.com/Tutorial:Localisation).

**Default:** `{'complex_type': 'literal', 'value': 'airborne-pollutant-name-with-amount.<name>'}`

