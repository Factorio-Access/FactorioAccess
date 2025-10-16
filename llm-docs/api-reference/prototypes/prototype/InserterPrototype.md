# InserterPrototype

An [inserter](https://wiki.factorio.com/Inserter).

**Parent:** [EntityWithOwnerPrototype](EntityWithOwnerPrototype.md)
**Type name:** `inserter`

## Properties

### extension_speed

**Type:** `double`

**Required:** Yes

### rotation_speed

**Type:** `double`

**Required:** Yes

### starting_distance

**Type:** `double`

**Optional:** Yes

**Default:** 0.7

### insert_position

**Type:** `Vector`

**Required:** Yes

### pickup_position

**Type:** `Vector`

**Required:** Yes

### platform_picture

**Type:** `Sprite4Way`

**Optional:** Yes

### platform_frozen

**Type:** `Sprite4Way`

**Optional:** Yes

### hand_base_picture

**Type:** `Sprite`

**Optional:** Yes

### hand_open_picture

**Type:** `Sprite`

**Optional:** Yes

### hand_closed_picture

**Type:** `Sprite`

**Optional:** Yes

### hand_base_frozen

**Type:** `Sprite`

**Optional:** Yes

### hand_open_frozen

**Type:** `Sprite`

**Optional:** Yes

### hand_closed_frozen

**Type:** `Sprite`

**Optional:** Yes

### hand_base_shadow

**Type:** `Sprite`

**Optional:** Yes

### hand_open_shadow

**Type:** `Sprite`

**Optional:** Yes

### hand_closed_shadow

**Type:** `Sprite`

**Optional:** Yes

### energy_source

Defines how this inserter gets energy. The emissions set on the energy source are ignored so inserters cannot produce pollution.

**Type:** `EnergySource`

**Required:** Yes

### energy_per_movement

**Type:** `Energy`

**Optional:** Yes

**Default:** 0

### energy_per_rotation

**Type:** `Energy`

**Optional:** Yes

**Default:** 0

### bulk

Whether this inserter is considered a bulk inserter. Relevant for determining how [inserter capacity bonus (research)](https://wiki.factorio.com/Inserter_capacity_bonus_(research)) applies to the inserter.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### uses_inserter_stack_size_bonus

When set to false, then relevant value of inserter stack size bonus ([LuaForce::inserter_stack_size_bonus](runtime:LuaForce::inserter_stack_size_bonus) or [LuaForce::bulk_inserter_capacity_bonus](runtime:LuaForce::bulk_inserter_capacity_bonus)) will not affect inserter stack size.

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### allow_custom_vectors

Whether pickup and insert position can be set run-time.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### allow_burner_leech

Whether this burner inserter can fuel itself from the fuel inventory of the entity it is picking up items from.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### draw_held_item

Whether the item that the inserter is holding should be drawn.

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### use_easter_egg

Whether the inserter should be able to fish [fish](https://wiki.factorio.com/Raw_fish).

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### grab_less_to_match_belt_stack

If drop target is belt, inserter may grab less so that it does not drop partial stacks unless it is forced to drop partial.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### wait_for_full_hand

Inserter will wait until its hand is full.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### enter_drop_mode_if_held_stack_spoiled

If inserter waits for full hand it could become stuck when item in hand changed because of spoiling. If this flag is set then inserter will start dropping held stack even if it was waiting for full hand.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### max_belt_stack_size

This inserter will not create stacks on belt with more than this amount of items. Must be >= 1.

**Type:** `uint8`

**Optional:** Yes

**Default:** 1

### filter_count

How many filters this inserter has. Maximum count of filtered items in inserter is 5.

**Type:** `uint8`

**Optional:** Yes

**Default:** 0

### hand_size

Used to determine how long the arm of the inserter is when drawing it. Does not affect gameplay. The lower the value, the straighter the arm. Increasing the value will give the inserter a bigger bend due to its longer parts.

**Type:** `double`

**Optional:** Yes

**Default:** 0.75

### circuit_wire_max_distance

The maximum circuit wire distance for this entity.

**Type:** `double`

**Optional:** Yes

**Default:** 0

### draw_copper_wires

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### draw_circuit_wires

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### default_stack_control_input_signal

**Type:** `SignalIDConnector`

**Optional:** Yes

### draw_inserter_arrow

Whether the yellow arrow that indicates the drop point of the inserter and the line that indicates the pickup position should be drawn.

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### chases_belt_items

Whether the inserter hand should move to the items it picks up from belts, leading to item chasing behaviour. If this is off, the inserter hand will stay in the center of the belt and any items picked up from the edges of the belt "teleport" to the inserter hand.

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### stack_size_bonus

Stack size bonus that is inherent to the prototype without having to be researched.

**Type:** `uint8`

**Optional:** Yes

**Default:** 0

### circuit_connector

**Type:** (`CircuitConnectorDefinition`, `CircuitConnectorDefinition`, `CircuitConnectorDefinition`, `CircuitConnectorDefinition`)

**Optional:** Yes

