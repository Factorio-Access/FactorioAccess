# BurnerGeneratorPrototype

An entity that produces power from a burner energy source.

**Parent:** [EntityWithOwnerPrototype](EntityWithOwnerPrototype.md)
**Type name:** `burner-generator`

## Properties

### energy_source

The output energy source of the generator. Any emissions specified on this energy source are ignored, they must be specified on `burner`.

**Type:** `ElectricEnergySource`

**Required:** Yes

### burner

The input energy source of the generator.

**Type:** `BurnerEnergySource`

**Required:** Yes

### animation

Plays when the generator is active. `idle_animation` must have the same frame count as animation.

**Type:** `Animation4Way`

**Optional:** Yes

### max_power_output

How much energy this generator can produce.

**Type:** `Energy`

**Required:** Yes

### idle_animation

Plays when the generator is inactive. Idle animation must have the same frame count as `animation`.

**Type:** `Animation4Way`

**Optional:** Yes

### always_draw_idle_animation

Whether the `idle_animation` should also play when the generator is active.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### perceived_performance

Affects animation speed and working sound.

**Type:** `PerceivedPerformance`

**Optional:** Yes

