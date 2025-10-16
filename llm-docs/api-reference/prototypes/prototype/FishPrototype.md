# FishPrototype

Entity that spawns in water tiles, which can be mined. Moves around unless deactivated with [LuaEntity::active](runtime:LuaEntity::active) = false.

**Parent:** [EntityWithHealthPrototype](EntityWithHealthPrototype.md)
**Type name:** `fish`

## Examples

```
{
  type = "fish",
  name = "fish",
  icon = "__base__/graphics/icons/fish.png",
  icon_size = 64,
  flags = { "placeable-neutral", "not-on-map" },
  minable = { mining_time = 1, result = "raw-fish", count = 5 },
  max_health = 20,
  subgroup = "creatures",
  order = "b-a",
  collision_box = { {-0.75, -0.75}, {0.75, 0.75} },
  selection_box = { {-0.5, -0.3}, {0.5, 0.3} },
  pictures =
  {
    {
      filename = "__base__/graphics/entity/fish/fish-1.png",
      priority = "extra-high",
      width = 22,
      height = 36
    },
    {
      filename = "__base__/graphics/entity/fish/fish-2.png",
      priority = "extra-high",
      width = 32,
      height = 32
    }
  },
  autoplace = { influence = 0.01 },
  protected_from_tile_building = false
}
```

## Properties

### pictures

**Type:** `SpriteVariations`

**Optional:** Yes

