# ReactorPrototype

A [reactor](https://wiki.factorio.com/Reactor).

**Parent:** `EntityWithOwnerPrototype`

## Properties

### Mandatory Properties

#### consumption

**Type:** `Energy`

How much energy this reactor can consume (from the input energy source) and then output as heat.

#### energy_source

**Type:** `EnergySource`

May not be a heat energy source.

The input energy source, in vanilla it is a burner energy source.

#### heat_buffer

**Type:** `HeatBuffer`

The energy output as heat.

### Optional Properties

#### circuit_connector

**Type:** `CircuitConnectorDefinition`



#### circuit_wire_max_distance

**Type:** `double`

The maximum circuit wire distance for this entity.

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### connection_patches_connected

**Type:** `SpriteVariations`

If defined, number of variations must be at least equal to count of [connections](prototype:HeatBuffer::connections) defined in `heat_buffer`. Each variation represents connected heat buffer connection of corresponding index.

#### connection_patches_disconnected

**Type:** `SpriteVariations`

If defined, number of variations must be at least equal to count of [connections](prototype:HeatBuffer::connections) defined in `heat_buffer`. Each variation represents unconnected heat buffer connection of corresponding index.

#### default_fuel_glow_color

**Type:** `Color`

When `use_fuel_glow_color` is true, this is the color used as `working_light_picture` tint for fuels that don't have glow color defined.

**Default:** ``{1, 1, 1, 1} (white)``

#### default_temperature_signal

**Type:** `SignalIDConnector`



#### draw_circuit_wires

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### draw_copper_wires

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### heat_connection_patches_connected

**Type:** `SpriteVariations`

If defined, number of variations must be at least equal to count of [connections](prototype:HeatBuffer::connections) defined in `heat_buffer`. When reactor is heated, corresponding variations are drawn over `connection_patches_connected`.

#### heat_connection_patches_disconnected

**Type:** `SpriteVariations`

If defined, number of variations must be at least equal to count of [connections](prototype:HeatBuffer::connections) defined in `heat_buffer`. When reactor is heated, corresponding variations are drawn over `connection_patches_disconnected`.

#### heat_lower_layer_picture

**Type:** `Sprite`



#### heating_radius

**Type:** `double`

Must be >= 0.

**Default:** `{'complex_type': 'literal', 'value': 1}`

#### light

**Type:** `LightDefinition`



#### lower_layer_picture

**Type:** `Sprite`



#### meltdown_action

**Type:** `Trigger`

The action is triggered when the reactor dies (is destroyed) at over 90% of max temperature.

#### neighbour_bonus

**Type:** `double`



**Default:** `{'complex_type': 'literal', 'value': 1}`

#### picture

**Type:** `Sprite`



#### scale_energy_usage

**Type:** `boolean`

When this is true, the reactor will stop consuming fuel/energy when the temperature has reached the maximum.

**Default:** `{'complex_type': 'literal', 'value': False}`

#### use_fuel_glow_color

**Type:** `boolean`

Whether the reactor should use [fuel_glow_color](prototype:ItemPrototype::fuel_glow_color) from the fuel item prototype as light color and tint for `working_light_picture`. [Forum post.](https://forums.factorio.com/71121)

**Default:** `{'complex_type': 'literal', 'value': False}`

#### working_light_picture

**Type:** `Animation`



