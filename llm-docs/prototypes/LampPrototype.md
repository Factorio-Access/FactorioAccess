# LampPrototype

A [lamp](https://wiki.factorio.com/Lamp) to provide light, using energy.

**Parent:** `EntityWithOwnerPrototype`

## Properties

### Mandatory Properties

#### energy_source

**Type:** 

The emissions set on the energy source are ignored so lamps cannot produce pollution.

#### energy_usage_per_tick

**Type:** `Energy`

The amount of energy the lamp uses. Must be greater than > 0.

### Optional Properties

#### always_on

**Type:** `boolean`

Whether the lamp should always be on.

**Default:** `{'complex_type': 'literal', 'value': False}`

#### circuit_connector

**Type:** `CircuitConnectorDefinition`



#### circuit_wire_max_distance

**Type:** `double`

The maximum circuit wire distance for this entity.

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### darkness_for_all_lamps_off

**Type:** `float`

darkness_for_all_lamps_on must be > darkness_for_all_lamps_off. Values must be between 0 and 1.

**Default:** `{'complex_type': 'literal', 'value': 0.3}`

#### darkness_for_all_lamps_on

**Type:** `float`

darkness_for_all_lamps_on must be > darkness_for_all_lamps_off. Values must be between 0 and 1.

**Default:** `{'complex_type': 'literal', 'value': 0.5}`

#### default_blue_signal

**Type:** `SignalIDConnector`



#### default_green_signal

**Type:** `SignalIDConnector`



#### default_red_signal

**Type:** `SignalIDConnector`



#### default_rgb_signal

**Type:** `SignalIDConnector`



#### draw_circuit_wires

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### draw_copper_wires

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### glow_color_intensity

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 0}`

#### glow_render_mode

**Type:** 



**Default:** `{'complex_type': 'literal', 'value': 'additive'}`

#### glow_size

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 0}`

#### light

**Type:** `LightDefinition`

What color the lamp will be when it is on, and receiving power.

#### light_when_colored

**Type:** `LightDefinition`

This refers to when the light is in a circuit network, and is lit a certain color based on a signal value.

#### picture_off

**Type:** `Sprite`

The lamps graphics when it's off.

#### picture_on

**Type:** `Sprite`

The lamps graphics when it's on.

#### signal_to_color_mapping

**Type:** ``SignalColorMapping`[]`



