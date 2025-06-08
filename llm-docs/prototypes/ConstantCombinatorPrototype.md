# ConstantCombinatorPrototype

A [constant combinator](https://wiki.factorio.com/Constant_combinator).

**Parent:** `EntityWithOwnerPrototype`

## Properties

### Mandatory Properties

#### activity_led_light_offsets

**Type:** `[]`



#### circuit_wire_connection_points

**Type:** `[]`



### Optional Properties

#### activity_led_light

**Type:** `LightDefinition`



#### activity_led_sprites

**Type:** `Sprite4Way`



#### circuit_wire_max_distance

**Type:** `double`

The maximum circuit wire distance for this entity.

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### draw_circuit_wires

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### draw_copper_wires

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### pulse_duration

**Type:** `uint32`

When not zero, toggle entity will enable constant combinator for that amount of ticks and then turn it off.

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### sprites

**Type:** `Sprite4Way`



