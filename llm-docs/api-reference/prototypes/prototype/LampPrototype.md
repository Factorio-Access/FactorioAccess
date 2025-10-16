# LampPrototype

A [lamp](https://wiki.factorio.com/Lamp) to provide light, using energy.

**Parent:** [EntityWithOwnerPrototype](EntityWithOwnerPrototype.md)
**Type name:** `lamp`

## Examples

```
{
  type = "lamp",
  name = "small-lamp",
  icon = "__base__/graphics/icons/small-lamp.png",
  flags = {"placeable-neutral", "player-creation"},
  fast_replaceable_group = "lamp",
  minable = {mining_time = 0.1, result = "small-lamp"},
  max_health = 100,
  corpse = "lamp-remnants",
  dying_explosion = "lamp-explosion",
  collision_box = {{-0.15, -0.15}, {0.15, 0.15}},
  selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
  damaged_trigger_effect = hit_effects.entity(),
  impact_category = "glass",
  open_sound = {filename = "__base__/sound/open-close/electric-small-open.ogg", volume = 0.7},
  close_sound = {filename = "__base__/sound/open-close/electric-small-close.ogg", volume = 0.7},
  energy_source =
  {
    type = "electric",
    usage_priority = "lamp"
  },
  energy_usage_per_tick = "5kW",
  darkness_for_all_lamps_on = 0.5,
  darkness_for_all_lamps_off = 0.3,
  light = {intensity = 0.9, size = 40, color = {1, 1, 0.75}},
  light_when_colored = {intensity = 0, size = 6, color = {1, 1, 0.75}},
  glow_size = 6,
  glow_color_intensity = 1,
  glow_render_mode = "multiplicative",
  picture_off =
  {
    layers =
    {
      {
        filename = "__base__/graphics/entity/small-lamp/lamp.png",
        priority = "high",
        width = 83,
        height = 70,
        shift = util.by_pixel(0.25,3),
        scale = 0.5
      },
      {
        filename = "__base__/graphics/entity/small-lamp/lamp-shadow.png",
        priority = "high",
        width = 76,
        height = 47,
        shift = util.by_pixel(4, 4.75),
        draw_as_shadow = true,
        scale = 0.5
      }
    }
  },
  picture_on =
  {
    filename = "__base__/graphics/entity/small-lamp/lamp-light.png",
    priority = "high",
    width = 90,
    height = 78,
    shift = util.by_pixel(0, -7),
    scale = 0.5
  },
  signal_to_color_mapping =
  {
    {type = "virtual", name = "signal-red",    color = {1, 0, 0}},
    {type = "virtual", name = "signal-green",  color = {0, 1, 0}},
    {type = "virtual", name = "signal-blue",   color = {0, 0, 1}},
    {type = "virtual", name = "signal-yellow", color = {1, 1, 0}},
    {type = "virtual", name = "signal-pink",   color = {1, 0, 1}},
    {type = "virtual", name = "signal-cyan",   color = {0, 1, 1}},
    {type = "virtual", name = "signal-white",  color = {1, 1, 1}},
    {type = "virtual", name = "signal-grey",   color = {0.5, 0.5, 0.5}},
    {type = "virtual", name = "signal-black",  color = {0, 0, 0}}
  },
  default_red_signal = { type = "virtual", name = "signal-red" },
  default_green_signal = { type = "virtual", name = "signal-green" },
  default_blue_signal = { type = "virtual", name = "signal-blue" },
  default_rgb_signal = { type = "virtual", name = "signal-white" },

  circuit_connector = circuit_connector_definitions["lamp"],
  circuit_wire_max_distance = default_circuit_wire_max_distance
}
```

## Properties

### picture_on

The lamps graphics when it's on.

**Type:** `Sprite`

**Optional:** Yes

### picture_off

The lamps graphics when it's off.

**Type:** `Sprite`

**Optional:** Yes

### energy_usage_per_tick

The amount of energy the lamp uses. Must be greater than > 0.

**Type:** `Energy`

**Required:** Yes

### energy_source

The emissions set on the energy source are ignored so lamps cannot produce pollution.

**Type:** `ElectricEnergySource` | `VoidEnergySource`

**Required:** Yes

### light

What color the lamp will be when it is on, and receiving power.

**Type:** `LightDefinition`

**Optional:** Yes

### light_when_colored

This refers to when the light is in a circuit network, and is lit a certain color based on a signal value.

**Type:** `LightDefinition`

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

### glow_size

**Type:** `float`

**Optional:** Yes

**Default:** 0

### glow_color_intensity

**Type:** `float`

**Optional:** Yes

**Default:** 0

### darkness_for_all_lamps_on

darkness_for_all_lamps_on must be > darkness_for_all_lamps_off. Values must be between 0 and 1.

**Type:** `float`

**Optional:** Yes

**Default:** 0.5

### darkness_for_all_lamps_off

darkness_for_all_lamps_on must be > darkness_for_all_lamps_off. Values must be between 0 and 1.

**Type:** `float`

**Optional:** Yes

**Default:** 0.3

### always_on

Whether the lamp should always be on.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### signal_to_color_mapping

**Type:** Array[`SignalColorMapping`]

**Optional:** Yes

### glow_render_mode

**Type:** `"additive"` | `"multiplicative"`

**Optional:** Yes

**Default:** "additive"

### default_red_signal

**Type:** `SignalIDConnector`

**Optional:** Yes

### default_green_signal

**Type:** `SignalIDConnector`

**Optional:** Yes

### default_blue_signal

**Type:** `SignalIDConnector`

**Optional:** Yes

### default_rgb_signal

**Type:** `SignalIDConnector`

**Optional:** Yes

