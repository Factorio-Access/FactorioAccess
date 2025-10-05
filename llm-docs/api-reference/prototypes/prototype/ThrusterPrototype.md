# ThrusterPrototype

Consumes two fluids as fuel to produce thrust for a space platform.

**Parent:** [EntityWithOwnerPrototype](EntityWithOwnerPrototype.md)
**Type name:** `thruster`
**Visibility:** space_age

## Properties

### min_performance

**Type:** `ThrusterPerformancePoint`

**Required:** Yes

### max_performance

`max_performance.fluid_volume` must not be smaller than `min_performance.fluid_volume`.

**Type:** `ThrusterPerformancePoint`

**Required:** Yes

### fuel_fluid_box

If a [filter](prototype:FluidBox::filter) is set for this fluidbox it determines what the thruster considers the first fuel.

**Type:** `FluidBox`

**Required:** Yes

### oxidizer_fluid_box

If a [filter](prototype:FluidBox::filter) is set for this fluidbox it determines what the thruster considers the second fuel.

**Type:** `FluidBox`

**Required:** Yes

### graphics_set

**Type:** `ThrusterGraphicsSet`

**Optional:** Yes

### plumes

**Type:** `PlumesSpecification`

**Optional:** Yes

