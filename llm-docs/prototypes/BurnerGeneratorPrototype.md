# BurnerGeneratorPrototype

An entity that produces power from a burner energy source.

**Parent:** `EntityWithOwnerPrototype`

## Properties

### Mandatory Properties

#### burner

**Type:** `BurnerEnergySource`

The input energy source of the generator.

#### energy_source

**Type:** `ElectricEnergySource`

The output energy source of the generator. Any emissions specified on this energy source are ignored, they must be specified on `burner`.

#### max_power_output

**Type:** `Energy`

How much energy this generator can produce.

### Optional Properties

#### always_draw_idle_animation

**Type:** `boolean`

Whether the `idle_animation` should also play when the generator is active.

**Default:** `{'complex_type': 'literal', 'value': False}`

#### animation

**Type:** `Animation4Way`

Plays when the generator is active. `idle_animation` must have the same frame count as animation.

#### idle_animation

**Type:** `Animation4Way`

Plays when the generator is inactive. Idle animation must have the same frame count as `animation`.

#### perceived_performance

**Type:** `PerceivedPerformance`

Affects animation speed and working sound.

