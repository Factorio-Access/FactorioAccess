# CombinatorPrototype

Abstract base type for decider and arithmetic combinators.

**Parent:** `EntityWithOwnerPrototype`

## Properties

### Mandatory Properties

#### active_energy_usage

**Type:** `Energy`



#### activity_led_light_offsets

**Type:** `[]`



#### energy_source

**Type:** 

Defines how this combinator gets energy. The emissions set on the energy source are ignored so combinators cannot produce pollution.

#### input_connection_bounding_box

**Type:** `BoundingBox`



#### input_connection_points

**Type:** `[]`



#### output_connection_bounding_box

**Type:** `BoundingBox`



#### output_connection_points

**Type:** `[]`



#### screen_light_offsets

**Type:** `[]`



### Optional Properties

#### activity_led_hold_time

**Type:** `uint8`



**Default:** `{'complex_type': 'literal', 'value': 5}`

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

#### emissions_per_second

**Type:** `dictionary<`AirbornePollutantID`, `double`>`

Emissions cannot be larger than zero, combinators cannot produce pollution.

#### frozen_patch

**Type:** `Sprite4Way`



#### screen_light

**Type:** `LightDefinition`



#### sprites

**Type:** `Sprite4Way`



