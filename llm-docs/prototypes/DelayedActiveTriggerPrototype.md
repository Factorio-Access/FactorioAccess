# DelayedActiveTriggerPrototype

Delays the delivery of triggered effect by some number of ticks.

**Parent:** `ActiveTriggerPrototype`

## Properties

### Mandatory Properties

#### action

**Type:** `Trigger`

The trigger to apply after `delay` has elapsed.

#### delay

**Type:** `uint32`

The number of ticks to delay the delivery of the triggered effect. Must be greater than 0.

### Optional Properties

#### cancel_when_source_is_destroyed

**Type:** `boolean`

If true, the delayed trigger is cancelled if the source entity is destroyed.

**Default:** `{'complex_type': 'literal', 'value': False}`

#### repeat_count

**Type:** `uint32`

The number of times to repeat the delayed trigger.

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### repeat_delay

**Type:** `uint32`

The number of ticks between repeat deliveries of the triggered effect. Must be greater than 0.

**Default:** `Value of `delay``

