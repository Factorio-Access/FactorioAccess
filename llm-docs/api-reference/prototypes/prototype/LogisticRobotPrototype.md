# LogisticRobotPrototype

A [logistic robot](https://wiki.factorio.com/Logistic_robot).

**Parent:** [RobotWithLogisticInterfacePrototype](RobotWithLogisticInterfacePrototype.md)
**Type name:** `logistic-robot`

## Properties

### idle_with_cargo

Only the first frame of the animation is drawn. This means that the graphics for the idle state cannot be animated.

**Type:** `RotatedAnimation`

**Optional:** Yes

### in_motion_with_cargo

Only the first frame of the animation is drawn. This means that the graphics for the in_motion state cannot be animated.

**Type:** `RotatedAnimation`

**Optional:** Yes

### shadow_idle_with_cargo

Only the first frame of the animation is drawn. This means that the graphics for the idle state cannot be animated.

**Type:** `RotatedAnimation`

**Optional:** Yes

### shadow_in_motion_with_cargo

Only the first frame of the animation is drawn. This means that the graphics for the in_motion state cannot be animated.

**Type:** `RotatedAnimation`

**Optional:** Yes

### collision_box

Must have a collision box size of zero.

**Type:** `BoundingBox`

**Optional:** Yes

**Default:** "Empty = `{{0, 0}, {0, 0}}`"

**Overrides parent:** Yes

**Examples:**

```
collision_box = {{0, 0}, {0, 0}}
```

