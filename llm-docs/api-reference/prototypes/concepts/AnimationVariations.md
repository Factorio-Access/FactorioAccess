# AnimationVariations

**Type:** `Struct` (see below for attributes) | `Animation` | Array[`Animation`]

## Properties

*These properties apply when the value is a struct/table.*

### sheet

The variations are arranged vertically in the file, one row for each variation.

**Type:** `AnimationSheet`

**Optional:** Yes

### sheets

Only loaded if `sheet` is not defined.

**Type:** Array[`AnimationSheet`]

**Optional:** Yes

## Examples

```
```
-- array of animations
animations =
{
  {
    filename = "__base__/graphics/entity/explosion-gunshot/explosion-gunshot.png",
    draw_as_glow = true,
    priority = "extra-high",
    width = 34,
    height = 38,
    frame_count = 2,
    animation_speed = 1.5,
    shift = {0, 0}
  },
  {
    filename = "__base__/graphics/entity/explosion-gunshot/explosion-gunshot.png",
    draw_as_glow = true,
    priority = "extra-high",
    width = 34,
    height = 38,
    x = 34 * 2,
    frame_count = 2,
    animation_speed = 1.5,
    shift = {0, 0}
  },
  -- [...]
}
```
```

```
```
-- animation sheet using "sheet"
pictures =
{
  sheet =
  {
    filename = "__base__/graphics/entity/character/footprints.png",
    line_length = 2,
    frame_count = 2,
    width = 30,
    height = 22,
    shift = util.by_pixel(0.25, 0.25),
    scale = 0.5,
    variation_count = 8
  }
}
```
```

