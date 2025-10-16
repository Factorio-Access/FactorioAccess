# ArtilleryProjectilePrototype

The projectile shot by [artillery](https://wiki.factorio.com/Artillery).

**Parent:** [EntityPrototype](EntityPrototype.md)
**Type name:** `artillery-projectile`

## Properties

### reveal_map

**Type:** `boolean`

**Required:** Yes

### picture

**Type:** `Sprite`

**Optional:** Yes

### shadow

**Type:** `Sprite`

**Optional:** Yes

### chart_picture

**Type:** `Sprite`

**Optional:** Yes

### action

**Type:** `Trigger`

**Optional:** Yes

### final_action

**Type:** `Trigger`

**Optional:** Yes

### height_from_ground

**Type:** `float`

**Optional:** Yes

**Default:** 1

### rotatable

Whether the picture of the projectile is rotated to match the direction of travel.

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### map_color

**Type:** `Color`

**Required:** Yes

**Overrides parent:** Yes

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

