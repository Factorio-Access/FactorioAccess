# FlyingRobotPrototype

Abstract base for construction/logistics and combat robots.

**Parent:** `EntityWithOwnerPrototype`

## Properties

### Mandatory Properties

#### speed

**Type:** `double`

The flying speed of the robot, in tiles/tick.

### Optional Properties

#### energy_per_move

**Type:** `Energy`

How much energy does it cost to move 1 tile.

Used only by [robots with logistic interface](prototype:RobotWithLogisticInterfacePrototype).

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### energy_per_tick

**Type:** `Energy`

How much energy does it cost to fly for 1 tick.

Used only by [robots with logistic interface](prototype:RobotWithLogisticInterfacePrototype).

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### is_military_target

**Type:** `boolean`

Whether this prototype should be a high priority target for enemy forces. See [Military units and structures](https://wiki.factorio.com/Military_units_and_structures).

**Default:** `{'complex_type': 'literal', 'value': True}`

#### max_energy

**Type:** `Energy`

How much energy can be stored in the batteries.

Used only by [robots with logistic interface](prototype:RobotWithLogisticInterfacePrototype).

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### max_speed

**Type:** `double`

The maximum flying speed of the robot, including bonuses, in tiles/tick. Useful to limit the impact of [worker robot speed research](prototype:WorkerRobotSpeedModifier).

**Default:** `max double`

#### max_to_charge

**Type:** `float`

If the robot's battery fill ratio is more than this, it does not need to charge before stationing.

Used only by [robots with logistic interface](prototype:RobotWithLogisticInterfacePrototype).

**Default:** `{'complex_type': 'literal', 'value': 0.95}`

#### min_to_charge

**Type:** `float`

The robot will go to charge when its battery fill ratio is less than this.

Used only by [robots with logistic interface](prototype:RobotWithLogisticInterfacePrototype).

**Default:** `{'complex_type': 'literal', 'value': 0.2}`

#### speed_multiplier_when_out_of_energy

**Type:** `float`

Some robots simply crash, some slowdown but keep going. 0 means crash.

Used only by [robots with logistic interface](prototype:RobotWithLogisticInterfacePrototype).

**Default:** `{'complex_type': 'literal', 'value': 0}`

