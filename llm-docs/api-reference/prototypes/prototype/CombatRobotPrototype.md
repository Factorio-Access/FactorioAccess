# CombatRobotPrototype

A combat robot. Can attack enemies.

**Parent:** [FlyingRobotPrototype](FlyingRobotPrototype.md)
**Type name:** `combat-robot`

## Properties

### time_to_live

**Type:** `uint32`

**Required:** Yes

### attack_parameters

**Type:** `AttackParameters`

**Required:** Yes

### idle

**Type:** `RotatedAnimation`

**Optional:** Yes

### shadow_idle

**Type:** `RotatedAnimation`

**Optional:** Yes

### in_motion

**Type:** `RotatedAnimation`

**Optional:** Yes

### shadow_in_motion

**Type:** `RotatedAnimation`

**Optional:** Yes

### range_from_player

**Type:** `double`

**Optional:** Yes

**Default:** 0

### friction

**Type:** `double`

**Optional:** Yes

**Default:** 0

### destroy_action

Applied when the combat robot expires (runs out of `time_to_live`).

**Type:** `Trigger`

**Optional:** Yes

### follows_player

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### light

**Type:** `LightDefinition`

**Optional:** Yes

