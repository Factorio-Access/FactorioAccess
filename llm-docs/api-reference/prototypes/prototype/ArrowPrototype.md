# ArrowPrototype

The arrows used for example in the campaign, they are literally just arrows.

**Parent:** [EntityPrototype](EntityPrototype.md)
**Type name:** `arrow`

## Examples

```
{
  type = "arrow",
  name = "orange-arrow-with-circle",
  flags = { "placeable-off-grid", "not-on-map" },
  blinking = true,
  arrow_picture =
  {
    filename = "__core__/graphics/arrows/gui-arrow-medium.png",
    priority = "low",
    width = 58,
    height = 62
  },
  circle_picture =
  {
    filename = "__core__/graphics/arrows/gui-arrow-circle.png",
    priority = "low",
    width = 50,
    height = 50
  }
}
```

## Properties

### arrow_picture

**Type:** `Sprite`

**Required:** Yes

### circle_picture

**Type:** `Sprite`

**Optional:** Yes

### blinking

**Type:** `boolean`

**Optional:** Yes

**Default:** False

