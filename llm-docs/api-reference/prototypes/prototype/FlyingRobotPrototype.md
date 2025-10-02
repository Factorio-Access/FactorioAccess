# FlyingRobotPrototype

Abstract base for construction/logistics and combat robots.

**Parent:** [EntityWithOwnerPrototype](EntityWithOwnerPrototype.md)
**Abstract:** Yes

## Properties

### speed

The flying speed of the robot, in tiles/tick.

**Type:** `double`

**Required:** Yes

### max_speed

The maximum flying speed of the robot, including bonuses, in tiles/tick. Useful to limit the impact of [worker robot speed research](prototype:WorkerRobotSpeedModifier).

**Type:** `double`

**Optional:** Yes

**Default:** "max double"

### max_energy

How much energy can be stored in the batteries.

Used only by [robots with logistic interface](prototype:RobotWithLogisticInterfacePrototype).

**Type:** `Energy`

**Optional:** Yes

**Default:** 0

**Examples:**

```
max_energy = "1.5MJ"
```

### energy_per_move

How much energy does it cost to move 1 tile.

Used only by [robots with logistic interface](prototype:RobotWithLogisticInterfacePrototype).

**Type:** `Energy`

**Optional:** Yes

**Default:** 0

**Examples:**

```
energy_per_move = "5kJ"
```

### energy_per_tick

How much energy does it cost to fly for 1 tick.

Used only by [robots with logistic interface](prototype:RobotWithLogisticInterfacePrototype).

**Type:** `Energy`

**Optional:** Yes

**Default:** 0

**Examples:**

```
energy_per_tick = "0.05kJ"
```

### min_to_charge

The robot will go to charge when its battery fill ratio is less than this.

Used only by [robots with logistic interface](prototype:RobotWithLogisticInterfacePrototype).

**Type:** `float`

**Optional:** Yes

**Default:** 0.2

### max_to_charge

If the robot's battery fill ratio is more than this, it does not need to charge before stationing.

Used only by [robots with logistic interface](prototype:RobotWithLogisticInterfacePrototype).

**Type:** `float`

**Optional:** Yes

**Default:** 0.95

### speed_multiplier_when_out_of_energy

Some robots simply crash, some slowdown but keep going. 0 means crash.

Used only by [robots with logistic interface](prototype:RobotWithLogisticInterfacePrototype).

**Type:** `float`

**Optional:** Yes

**Default:** 0

**Examples:**

```
speed_multiplier_when_out_of_energy = 0.2
```

### is_military_target

Whether this prototype should be a high priority target for enemy forces. See [Military units and structures](https://wiki.factorio.com/Military_units_and_structures).

**Type:** `boolean`

**Optional:** Yes

**Default:** True

**Overrides parent:** Yes

