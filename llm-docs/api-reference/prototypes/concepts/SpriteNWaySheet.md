# SpriteNWaySheet

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### frames

Specifies how many of the directions of the SpriteNWay are filled up with this sheet.

**Type:** `uint32`

**Optional:** Yes

**Default:** "4 if used in Sprite4Way, 8 if used in Sprite8Way"

### generate_sdf

Unused.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

## Examples

```
```
sheet =
{
  filename = "__base__/graphics/entity/burner-inserter/burner-inserter-platform.png",
  priority = "extra-high",
  width = 105,
  height = 79,
  shift = util.by_pixel(1.5, 7.5-1),
  scale = 0.5
}
```
```

