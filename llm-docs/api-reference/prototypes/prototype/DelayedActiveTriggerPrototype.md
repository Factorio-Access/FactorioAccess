# DelayedActiveTriggerPrototype

Delays the delivery of triggered effect by some number of ticks.

**Parent:** [ActiveTriggerPrototype](ActiveTriggerPrototype.md)
**Type name:** `delayed-active-trigger`

## Properties

### action

The trigger to apply after `delay` has elapsed.

**Type:** `Trigger`

**Required:** Yes

### delay

The number of ticks to delay the delivery of the triggered effect. Must be greater than 0.

**Type:** `uint32`

**Required:** Yes

### repeat_count

The number of times to repeat the delayed trigger.

**Type:** `uint32`

**Optional:** Yes

**Default:** 0

### repeat_delay

The number of ticks between repeat deliveries of the triggered effect. Must be greater than 0.

**Type:** `uint32`

**Optional:** Yes

**Default:** "Value of `delay`"

### cancel_when_source_is_destroyed

If true, the delayed trigger is cancelled if the source entity is destroyed.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

