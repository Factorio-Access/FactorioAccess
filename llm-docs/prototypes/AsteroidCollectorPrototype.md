# AsteroidCollectorPrototype



**Parent:** `EntityWithOwnerPrototype`

## Properties

### Mandatory Properties

#### arm_energy_usage

**Type:** `Energy`



#### arm_slow_energy_usage

**Type:** `Energy`

If `arm_energy_usage` is not met, attempts to move slower at the cost of `arm_slow_energy_usage`.

#### collection_radius

**Type:** `double`

Must be positive.

#### energy_source

**Type:** 



#### graphics_set

**Type:** `AsteroidCollectorGraphicsSet`



#### passive_energy_usage

**Type:** `Energy`



### Optional Properties

#### arm_angular_speed_cap_base

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 0.1}`

#### arm_angular_speed_cap_quality_scaling

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 0.1}`

#### arm_color_gradient

**Type:** ``Color`[]`



**Default:** `{{1, 1, 1}}`

#### arm_count_base

**Type:** `uint32`



**Default:** `{'complex_type': 'literal', 'value': 3}`

#### arm_count_quality_scaling

**Type:** `uint32`



**Default:** `{'complex_type': 'literal', 'value': 1}`

#### arm_extend_sound

**Type:** `Sound`



#### arm_inventory_size

**Type:** `ItemStackIndex`



**Default:** `{'complex_type': 'literal', 'value': 5}`

#### arm_inventory_size_quality_increase

**Type:** `ItemStackIndex`



**Default:** `{'complex_type': 'literal', 'value': 0}`

#### arm_retract_sound

**Type:** `Sound`



#### arm_speed_base

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 0.1}`

#### arm_speed_quality_scaling

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 0.1}`

#### circuit_connector

**Type:** `[]`



#### circuit_wire_max_distance

**Type:** `double`

The maximum circuit wire distance for this entity.

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### collection_box_offset

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 0.0}`

#### deposit_radius

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 1.5}`

#### deposit_sound

**Type:** `Sound`



#### draw_circuit_wires

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### draw_copper_wires

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### energy_usage_quality_scaling

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 0.1}`

#### head_collection_radius

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 0.6}`

#### held_items_display_count

**Type:** `uint8`



**Default:** `{'complex_type': 'literal', 'value': 5}`

#### held_items_offset

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 0.1}`

#### held_items_spread

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 0.15}`

#### inventory_size

**Type:** `ItemStackIndex`



**Default:** `{'complex_type': 'literal', 'value': 39}`

#### inventory_size_quality_increase

**Type:** `ItemStackIndex`



**Default:** `{'complex_type': 'literal', 'value': 5}`

#### minimal_arm_swing_segment_retraction

**Type:** `uint32`



**Default:** `{'complex_type': 'literal', 'value': 6}`

#### munch_sound

**Type:** `Sound`



#### radius_visualisation_picture

**Type:** `Sprite`



#### tether_size

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 0.4}`

#### unpowered_arm_speed_scale

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 0.3}`

