# Sprite4Way

Sprites for the 4 major directions of the entity. If this is loaded as a single Sprite, it applies to all directions.

This struct is either loaded as `sheets` or `sheet` or a map of one sprite per direction. For per direction sprites, the sprites are loaded via `north`, `east`, `south` and `west`.

**Type:** `Struct` (see below for attributes) | `Sprite`

## Properties

*These properties apply when the value is a struct/table.*

### sheets

**Type:** Array[`SpriteNWaySheet`]

**Optional:** Yes

### sheet

Only loaded if `sheets` is not defined.

**Type:** `SpriteNWaySheet`

**Optional:** Yes

### north

Only loaded if both `sheets` and `sheet` are not defined.

**Type:** `Sprite`

**Optional:** Yes

### east

Only loaded, and mandatory if both `sheets` and `sheet` are not defined.

Only loaded if `north` is defined.

**Type:** `Sprite`

**Optional:** Yes

### south

Only loaded, and mandatory if both `sheets` and `sheet` are not defined.

Only loaded if `north` is defined.

**Type:** `Sprite`

**Optional:** Yes

### west

Only loaded, and mandatory if both `sheets` and `sheet` are not defined.

Only loaded if `north` is defined.

**Type:** `Sprite`

**Optional:** Yes

## Examples

```
```
-- separate sprites per direction
{
  north =
  {
    filename = "__base__/graphics/entity/assembling-machine-3/assembling-machine-3-pipe-N.png",
    priority = "extra-high",
    width = 71,
    height = 38,
    shift = util.by_pixel(2.25, 13.5),
    scale = 0.5
  },
  east =
  {
    filename = "__base__/graphics/entity/assembling-machine-3/assembling-machine-3-pipe-E.png",
    priority = "extra-high",
    width = 42,
    height = 76,
    shift = util.by_pixel(-24.5, 1),
    scale = 0.5
  },
  south =
  {
    filename = "__base__/graphics/entity/assembling-machine-3/assembling-machine-3-pipe-S.png",
    priority = "extra-high",
    width = 88,
    height = 61,
    shift = util.by_pixel(0, -31.25),
    scale = 0.5
  },
  west =
  {
    filename = "__base__/graphics/entity/assembling-machine-3/assembling-machine-3-pipe-W.png",
    priority = "extra-high",
    width = 39,
    height = 73,
    shift = util.by_pixel(25.75, 1.25),
    scale = 0.5
  }
}
```
```

