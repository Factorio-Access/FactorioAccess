# BeamPrototype

Used as a laser beam.

**Parent:** `EntityPrototype`

## Properties

### Mandatory Properties

#### damage_interval

**Type:** `uint32`

Damage interval can't be 0. A value of 1 will cause the attack to be applied each tick.

#### graphics_set

**Type:** `BeamGraphicsSet`



#### width

**Type:** `float`



### Optional Properties

#### action

**Type:** `Trigger`



#### action_triggered_automatically

**Type:** `boolean`

Whether this beams should trigger its action every `damage_interval`. If false, the action is instead triggered when its owner triggers shooting.

**Default:** `{'complex_type': 'literal', 'value': False}`

#### random_target_offset

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': False}`

#### target_offset

**Type:** `Vector`



