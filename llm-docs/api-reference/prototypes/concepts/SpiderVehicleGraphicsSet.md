# SpiderVehicleGraphicsSet

Used to specify the graphics for [SpiderVehiclePrototype](prototype:SpiderVehiclePrototype).

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### autopilot_destination_visualisation_render_layer

**Type:** `RenderLayer`

**Optional:** Yes

**Default:** "object"

### light

**Type:** `LightDefinition`

**Optional:** Yes

### eye_light

Placed in multiple positions, as determined by `light_positions`.

**Type:** `LightDefinition`

**Optional:** Yes

### autopilot_destination_on_map_visualisation

**Type:** `Animation`

**Optional:** Yes

### autopilot_destination_queue_on_map_visualisation

**Type:** `Animation`

**Optional:** Yes

### autopilot_destination_visualisation

**Type:** `Animation`

**Optional:** Yes

### autopilot_destination_queue_visualisation

**Type:** `Animation`

**Optional:** Yes

### autopilot_path_visualisation_line_width

**Type:** `float`

**Optional:** Yes

**Default:** 0.125

### autopilot_path_visualisation_on_map_line_width

**Type:** `float`

**Optional:** Yes

**Default:** 2.0

### light_positions

Defines where each `eye_light` is placed. One array per eye and each of those arrays should contain one position per body direction.

**Type:** Array[Array[`Vector`]]

**Optional:** Yes

### default_color

The default mask color for the spider vehicle. Defaults to orange.

**Type:** `float`

**Optional:** Yes

