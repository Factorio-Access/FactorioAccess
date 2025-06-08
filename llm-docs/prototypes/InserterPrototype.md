# InserterPrototype

An [inserter](https://wiki.factorio.com/Inserter).

**Parent:** `EntityWithOwnerPrototype`

## Properties

### Mandatory Properties

#### energy_source

**Type:** `EnergySource`

Defines how this inserter gets energy. The emissions set on the energy source are ignored so inserters cannot produce pollution.

#### extension_speed

**Type:** `double`



#### insert_position

**Type:** `Vector`



#### pickup_position

**Type:** `Vector`



#### rotation_speed

**Type:** `double`



### Optional Properties

#### allow_burner_leech

**Type:** `boolean`

Whether this burner inserter can fuel itself from the fuel inventory of the entity it is picking up items from.

**Default:** `{'complex_type': 'literal', 'value': False}`

#### allow_custom_vectors

**Type:** `boolean`

Whether pickup and insert position can be set run-time.

**Default:** `{'complex_type': 'literal', 'value': False}`

#### bulk

**Type:** `boolean`

Whether this inserter is considered a bulk inserter. Relevant for determining how [inserter capacity bonus (research)](https://wiki.factorio.com/Inserter_capacity_bonus_(research)) applies to the inserter.

**Default:** `{'complex_type': 'literal', 'value': False}`

#### chases_belt_items

**Type:** `boolean`

Whether the inserter hand should move to the items it picks up from belts, leading to item chasing behaviour. If this is off, the inserter hand will stay in the center of the belt and any items picked up from the edges of the belt "teleport" to the inserter hand.

**Default:** `{'complex_type': 'literal', 'value': True}`

#### circuit_connector

**Type:** `[]`



#### circuit_wire_max_distance

**Type:** `double`

The maximum circuit wire distance for this entity.

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### default_stack_control_input_signal

**Type:** `SignalIDConnector`



#### draw_circuit_wires

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### draw_copper_wires

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### draw_held_item

**Type:** `boolean`

Whether the item that the inserter is holding should be drawn.

**Default:** `{'complex_type': 'literal', 'value': True}`

#### draw_inserter_arrow

**Type:** `boolean`

Whether the yellow arrow that indicates the drop point of the inserter and the line that indicates the pickup position should be drawn.

**Default:** `{'complex_type': 'literal', 'value': True}`

#### energy_per_movement

**Type:** `Energy`



**Default:** `{'complex_type': 'literal', 'value': 0}`

#### energy_per_rotation

**Type:** `Energy`



**Default:** `{'complex_type': 'literal', 'value': 0}`

#### enter_drop_mode_if_held_stack_spoiled

**Type:** `boolean`

If inserter waits for full hand it could become stuck when item in hand changed because of spoiling. If this flag is set then inserter will start dropping held stack even if it was waiting for full hand.

**Default:** `{'complex_type': 'literal', 'value': False}`

#### filter_count

**Type:** `uint8`

How many filters this inserter has. Maximum count of filtered items in inserter is 5.

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### grab_less_to_match_belt_stack

**Type:** `boolean`

If drop target is belt, inserter may grab less so that it does not drop partial stacks unless it is forced to drop partial.

**Default:** `{'complex_type': 'literal', 'value': False}`

#### hand_base_frozen

**Type:** `Sprite`



#### hand_base_picture

**Type:** `Sprite`



#### hand_base_shadow

**Type:** `Sprite`



#### hand_closed_frozen

**Type:** `Sprite`



#### hand_closed_picture

**Type:** `Sprite`



#### hand_closed_shadow

**Type:** `Sprite`



#### hand_open_frozen

**Type:** `Sprite`



#### hand_open_picture

**Type:** `Sprite`



#### hand_open_shadow

**Type:** `Sprite`



#### hand_size

**Type:** `double`

Used to determine how long the arm of the inserter is when drawing it. Does not affect gameplay. The lower the value, the straighter the arm. Increasing the value will give the inserter a bigger bend due to its longer parts.

**Default:** `{'complex_type': 'literal', 'value': 0.75}`

#### max_belt_stack_size

**Type:** `uint8`

This inserter will not create stacks on belt with more than this amount of items. Must be >= 1.

**Default:** `{'complex_type': 'literal', 'value': 1}`

#### platform_frozen

**Type:** `Sprite4Way`



#### platform_picture

**Type:** `Sprite4Way`



#### stack_size_bonus

**Type:** `uint8`

Stack size bonus that is inherent to the prototype without having to be researched.

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### starting_distance

**Type:** `double`



**Default:** `{'complex_type': 'literal', 'value': 0.7}`

#### use_easter_egg

**Type:** `boolean`

Whether the inserter should be able to fish [fish](https://wiki.factorio.com/Raw_fish).

**Default:** `{'complex_type': 'literal', 'value': True}`

#### wait_for_full_hand

**Type:** `boolean`

Inserter will wait until its hand is full.

**Default:** `{'complex_type': 'literal', 'value': False}`

