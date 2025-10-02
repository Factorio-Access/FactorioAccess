# ReactorPrototype

A [reactor](https://wiki.factorio.com/Reactor).

**Parent:** [EntityWithOwnerPrototype](EntityWithOwnerPrototype.md)
**Type name:** `reactor`

## Properties

### working_light_picture

**Type:** `Animation`

**Optional:** Yes

### heat_buffer

The energy output as heat.

**Type:** `HeatBuffer`

**Required:** Yes

### heating_radius

Must be >= 0.

**Type:** `double`

**Optional:** Yes

**Default:** 1

### energy_source

May not be a heat energy source.

The input energy source, in vanilla it is a burner energy source.

**Type:** `EnergySource`

**Required:** Yes

### consumption

How much energy this reactor can consume (from the input energy source) and then output as heat.

**Type:** `Energy`

**Required:** Yes

### connection_patches_connected

If defined, number of variations must be at least equal to count of [connections](prototype:HeatBuffer::connections) defined in `heat_buffer`. Each variation represents connected heat buffer connection of corresponding index.

**Type:** `SpriteVariations`

**Optional:** Yes

### connection_patches_disconnected

If defined, number of variations must be at least equal to count of [connections](prototype:HeatBuffer::connections) defined in `heat_buffer`. Each variation represents unconnected heat buffer connection of corresponding index.

**Type:** `SpriteVariations`

**Optional:** Yes

### heat_connection_patches_connected

If defined, number of variations must be at least equal to count of [connections](prototype:HeatBuffer::connections) defined in `heat_buffer`. When reactor is heated, corresponding variations are drawn over `connection_patches_connected`.

**Type:** `SpriteVariations`

**Optional:** Yes

### heat_connection_patches_disconnected

If defined, number of variations must be at least equal to count of [connections](prototype:HeatBuffer::connections) defined in `heat_buffer`. When reactor is heated, corresponding variations are drawn over `connection_patches_disconnected`.

**Type:** `SpriteVariations`

**Optional:** Yes

### lower_layer_picture

**Type:** `Sprite`

**Optional:** Yes

### heat_lower_layer_picture

**Type:** `Sprite`

**Optional:** Yes

### picture

**Type:** `Sprite`

**Optional:** Yes

### light

**Type:** `LightDefinition`

**Optional:** Yes

### meltdown_action

The action is triggered when the reactor dies (is destroyed) at over 90% of max temperature.

**Type:** `Trigger`

**Optional:** Yes

### neighbour_bonus

**Type:** `double`

**Optional:** Yes

**Default:** 1

### scale_energy_usage

When this is true, the reactor will stop consuming fuel/energy when the temperature has reached the maximum.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### use_fuel_glow_color

Whether the reactor should use [fuel_glow_color](prototype:ItemPrototype::fuel_glow_color) from the fuel item prototype as light color and tint for `working_light_picture`. [Forum post.](https://forums.factorio.com/71121)

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### default_fuel_glow_color

When `use_fuel_glow_color` is true, this is the color used as `working_light_picture` tint for fuels that don't have glow color defined.

**Type:** `Color`

**Optional:** Yes

**Default:** "`{1, 1, 1, 1} (white)`"

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

### circuit_connector

**Type:** `CircuitConnectorDefinition`

**Optional:** Yes

### default_temperature_signal

**Type:** `SignalIDConnector`

**Optional:** Yes

