# ValvePrototype

A passive device that provides limited control of fluid flow between pipelines.

**Parent:** `EntityWithOwnerPrototype`

## Properties

### Mandatory Properties

#### flow_rate

**Type:** `FluidAmount`

The max flow rate through the valve per tick.

#### fluid_box

**Type:** `FluidBox`

Must have at least one `"output"` [FluidFlowDirection](prototype:FluidFlowDirection) and at least one `input-output` [FluidFlowDirection](prototype:FluidFlowDirection).

#### mode

**Type:** `ValveMode`



### Optional Properties

#### animations

**Type:** `Animation4Way`



#### frozen_patch

**Type:** `Sprite4Way`



#### threshold

**Type:** `float`

Ignored if [ValvePrototype::mode](prototype:ValvePrototype::mode) is `"one-way"`. Must be between `0` and `1` inclusive.

**Default:** `{'complex_type': 'literal', 'value': 0}`

