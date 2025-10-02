# ItemEntityPrototype

The entity used for items on the ground.

**Parent:** [EntityPrototype](EntityPrototype.md)
**Type name:** `item-entity`

## Examples

```
{
  type = "item-entity",
  name = "item-on-ground",
  flags = { "placeable-off-grid", "not-on-map" },
  collision_box = { {-0.14, -0.14}, {0.14, 0.14} },
  selection_box = { {-0.17, -0.17}, {0.17, 0.17} },
  minable = { mining_time = 0.025 }
}
```

## Properties

### collision_box

Item entity collision box has to have same width as height.

Specification of the entity collision boundaries. Empty collision box means no collision and is used for smoke, projectiles, particles, explosions etc.

The `{0,0}` coordinate in the collision box will match the entity position. It should be near the center of the collision box, to keep correct entity drawing order. The bounding box must include the `{0,0}` coordinate.

Note, that for buildings, it is customary to leave 0.1 wide border between the edge of the tile and the edge of the building, this lets the player move between the building and electric poles/inserters etc.

**Type:** `BoundingBox`

**Optional:** Yes

**Default:** "Empty = `{{0, 0}, {0, 0}}`"

**Overrides parent:** Yes

**Examples:**

```
collision_box = {{-0.4, -0.4}, {0.4, 0.4}}
```

