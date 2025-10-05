# RobotWithLogisticInterfacePrototype

The common properties of logistic and construction robots represented by an abstract prototype.

**Parent:** [FlyingRobotPrototype](FlyingRobotPrototype.md)
**Abstract:** Yes

## Properties

### max_payload_size

The robot's cargo carrying capacity. Can be increased by [worker robot cargo size research](prototype:WorkerRobotStorageModifier).

**Type:** `ItemCountType`

**Required:** Yes

### max_payload_size_after_bonus

The robot's maximum possible cargo carrying capacity, including bonuses. Useful to limit the impact of [worker robot cargo size research](prototype:WorkerRobotStorageModifier).

Must be >= max_payload_size.

**Type:** `ItemCountType`

**Optional:** Yes

**Default:** "max ItemCountType"

### idle

Only the first frame of the animation is drawn. This means that the graphics for the idle state cannot be animated.

**Type:** `RotatedAnimation`

**Optional:** Yes

### in_motion

Only the first frame of the animation is drawn. This means that the graphics for the in_motion state cannot be animated.

**Type:** `RotatedAnimation`

**Optional:** Yes

### shadow_idle

Only the first frame of the animation is drawn. This means that the graphics for the idle state cannot be animated.

**Type:** `RotatedAnimation`

**Optional:** Yes

### shadow_in_motion

Only the first frame of the animation is drawn. This means that the graphics for the in_motion state cannot be animated.

**Type:** `RotatedAnimation`

**Optional:** Yes

### destroy_action

Applied when the robot expires (runs out of energy and [FlyingRobotPrototype::speed_multiplier_when_out_of_energy](prototype:FlyingRobotPrototype::speed_multiplier_when_out_of_energy) is 0).

**Type:** `Trigger`

**Optional:** Yes

### draw_cargo

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### charging_sound

**Type:** `InterruptibleSound`

**Optional:** Yes

