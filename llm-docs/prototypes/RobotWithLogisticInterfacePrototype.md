# RobotWithLogisticInterfacePrototype

The common properties of logistic and construction robots represented by an abstract prototype.

**Parent:** `FlyingRobotPrototype`

## Properties

### Mandatory Properties

#### max_payload_size

**Type:** `ItemCountType`

The robot's cargo carrying capacity. Can be increased by [worker robot cargo size research](prototype:WorkerRobotStorageModifier).

### Optional Properties

#### charging_sound

**Type:** `InterruptibleSound`



#### destroy_action

**Type:** `Trigger`

Applied when the robot expires (runs out of energy and [FlyingRobotPrototype::speed_multiplier_when_out_of_energy](prototype:FlyingRobotPrototype::speed_multiplier_when_out_of_energy) is 0).

#### draw_cargo

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### idle

**Type:** `RotatedAnimation`

Only the first frame of the animation is drawn. This means that the graphics for the idle state cannot be animated.

#### in_motion

**Type:** `RotatedAnimation`

Only the first frame of the animation is drawn. This means that the graphics for the in_motion state cannot be animated.

#### shadow_idle

**Type:** `RotatedAnimation`

Only the first frame of the animation is drawn. This means that the graphics for the idle state cannot be animated.

#### shadow_in_motion

**Type:** `RotatedAnimation`

Only the first frame of the animation is drawn. This means that the graphics for the in_motion state cannot be animated.

