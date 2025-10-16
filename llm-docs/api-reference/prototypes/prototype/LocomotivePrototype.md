# LocomotivePrototype

A [locomotive](https://wiki.factorio.com/Locomotive).

**Parent:** [RollingStockPrototype](RollingStockPrototype.md)
**Type name:** `locomotive`

## Properties

### max_power

**Type:** `Energy`

**Required:** Yes

### reversing_power_modifier

**Type:** `double`

**Required:** Yes

### energy_source

**Type:** `BurnerEnergySource` | `VoidEnergySource`

**Required:** Yes

### front_light

**Type:** `LightDefinition`

**Optional:** Yes

### front_light_pictures

**Type:** `RollingStockRotatedSlopedGraphics`

**Optional:** Yes

### darkness_to_render_light_animation

**Type:** `float`

**Optional:** Yes

**Default:** 0.3

### max_snap_to_train_stop_distance

In tiles. A locomotive will snap to a nearby train stop when the player places it within this distance to the stop.

**Type:** `float`

**Optional:** Yes

**Default:** 3.0

