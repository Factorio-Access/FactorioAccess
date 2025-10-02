# ValvePrototype

A passive device that provides limited control of fluid flow between pipelines.

**Parent:** [EntityWithOwnerPrototype](EntityWithOwnerPrototype.md)
**Type name:** `valve`

## Properties

### mode

**Type:** `ValveMode`

**Required:** Yes

### threshold

Ignored if [ValvePrototype::mode](prototype:ValvePrototype::mode) is `"one-way"`. Must be between `0` and `1` inclusive.

**Type:** `float`

**Optional:** Yes

**Default:** 0

### fluid_box

Must have at least one `"output"` [FluidFlowDirection](prototype:FluidFlowDirection) and at least one `"input-output"` [FluidFlowDirection](prototype:FluidFlowDirection).

**Type:** `FluidBox`

**Required:** Yes

### flow_rate

The max flow rate through the valve per tick.

**Type:** `FluidAmount`

**Required:** Yes

### animations

**Type:** `Animation4Way`

**Optional:** Yes

### frozen_patch

**Type:** `Sprite4Way`

**Optional:** Yes

