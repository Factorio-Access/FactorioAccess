# ConstructionRobotPrototype

A [construction robot](https://wiki.factorio.com/Construction_robot).

**Parent:** [RobotWithLogisticInterfacePrototype](RobotWithLogisticInterfacePrototype.md)
**Type name:** `construction-robot`

## Properties

### construction_vector

**Type:** `Vector`

**Required:** Yes

### working

**Type:** `RotatedAnimation`

**Optional:** Yes

### shadow_working

**Type:** `RotatedAnimation`

**Optional:** Yes

### smoke

**Type:** `Animation`

**Optional:** Yes

### sparks

**Type:** `AnimationVariations`

**Optional:** Yes

### repairing_sound

**Type:** `Sound`

**Optional:** Yes

### mined_sound_volume_modifier

**Type:** `float`

**Optional:** Yes

**Default:** 1.0

### working_light

**Type:** `LightDefinition`

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

