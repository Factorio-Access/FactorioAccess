# CombatRobotPrototype

A combat robot. Can attack enemies.

**Parent:** `FlyingRobotPrototype`

## Properties

### Mandatory Properties

#### attack_parameters

**Type:** `AttackParameters`



#### time_to_live

**Type:** `uint32`



### Optional Properties

#### destroy_action

**Type:** `Trigger`

Applied when the combat robot expires (runs out of `time_to_live`).

#### follows_player

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': False}`

#### friction

**Type:** `double`



**Default:** `{'complex_type': 'literal', 'value': 0}`

#### idle

**Type:** `RotatedAnimation`



#### in_motion

**Type:** `RotatedAnimation`



#### light

**Type:** `LightDefinition`



#### range_from_player

**Type:** `double`



**Default:** `{'complex_type': 'literal', 'value': 0}`

#### shadow_idle

**Type:** `RotatedAnimation`



#### shadow_in_motion

**Type:** `RotatedAnimation`



