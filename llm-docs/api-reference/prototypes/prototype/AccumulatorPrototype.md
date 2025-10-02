# AccumulatorPrototype

Entity with energy source with specialised animation for charging/discharging. Used for the [accumulator](https://wiki.factorio.com/Accumulator) entity.

**Parent:** [EntityWithOwnerPrototype](EntityWithOwnerPrototype.md)
**Type name:** `accumulator`

## Examples

```
{
  type = "accumulator",
  name = "accumulator",
  icon = "__base__/graphics/icons/accumulator.png",
  flags = {"placeable-neutral", "player-creation"},
  minable = {mining_time = 0.1, result = "accumulator"},
  fast_replaceable_group = "accumulator",
  max_health = 150,
  corpse = "accumulator-remnants",
  collision_box = {{-0.9, -0.9}, {0.9, 0.9}},
  selection_box = {{-1, -1}, {1, 1}},
  energy_source =
  {
    type = "electric",
    buffer_capacity = "5MJ",
    usage_priority = "tertiary",
    input_flow_limit = "300kW",
    output_flow_limit = "300kW"
  },
  chargable_graphics =
  {
    picture = accumulator_picture(),
    charge_animation = accumulator_charge(),
    charge_cooldown = 30,
    discharge_animation = accumulator_discharge(),
    discharge_cooldown = 60
  },
  water_reflection = accumulator_reflection(),
  working_sound =
  {
    main_sounds =
    {
      {
        sound = {filename = "__base__/sound/accumulator-working.ogg", volume = 0.4, modifiers = volume_multiplier("main-menu", 1.44)},
        match_volume_to_activity = true,
        activity_to_volume_modifiers = {offset = 2, inverted = true},
        fade_in_ticks = 4,
        fade_out_ticks = 20
      },
      {
        sound = {filename = "__base__/sound/accumulator-discharging.ogg", volume = 0.4, modifiers = volume_multiplier("main-menu", 1.44)},
        match_volume_to_activity = true,
        activity_to_volume_modifiers = {offset = 1},
        fade_in_ticks = 4,
        fade_out_ticks = 20
      }
    },
    idle_sound = {filename = "__base__/sound/accumulator-idle.ogg", volume = 0.35},
    max_sounds_per_prototype = 3,
    audible_distance_modifier = 0.5
  },

  circuit_connector = circuit_connector_definitions["accumulator"],
  circuit_wire_max_distance = default_circuit_wire_max_distance,

  default_output_signal = {type = "virtual", name = "signal-A"}
}
```

## Properties

### energy_source

The capacity of the energy source buffer specifies the capacity of the accumulator.

**Type:** `ElectricEnergySource`

**Required:** Yes

### chargable_graphics

**Type:** `ChargableGraphics`

**Optional:** Yes

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

### default_output_signal

The name of the signal that is the default for when an accumulator is connected to the circuit network.

**Type:** `SignalIDConnector`

**Optional:** Yes

