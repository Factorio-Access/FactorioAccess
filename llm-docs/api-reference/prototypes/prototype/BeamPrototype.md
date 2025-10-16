# BeamPrototype

Used as a laser beam.

**Parent:** [EntityPrototype](EntityPrototype.md)
**Type name:** `beam`

## Properties

### action

**Type:** `Trigger`

**Optional:** Yes

### width

**Type:** `float`

**Required:** Yes

### damage_interval

Damage interval can't be 0. A value of 1 will cause the attack to be applied each tick.

**Type:** `uint32`

**Required:** Yes

### target_offset

**Type:** `Vector`

**Optional:** Yes

### random_target_offset

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### action_triggered_automatically

Whether this beams should trigger its action every `damage_interval`. If false, the action is instead triggered when its owner triggers shooting.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### graphics_set

**Type:** `BeamGraphicsSet`

**Required:** Yes

