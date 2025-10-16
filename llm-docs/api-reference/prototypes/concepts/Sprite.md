# Sprite

Specifies one picture that can be used in the game.

When there is more than one sprite or [Animation](prototype:Animation) frame with the same source file and dimensions/position in the game, they all share the same memory.

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### layers

If this property is present, all Sprite definitions have to be placed as entries in the array, and they will all be loaded from there. `layers` may not be an empty table. Each definition in the array may also have the `layers` property.

If this property is present, all other properties, including those inherited from SpriteParameters, are ignored.

**Type:** Array[`Sprite`]

**Optional:** Yes

### filename

Only loaded, and mandatory if `layers` is not defined.

The path to the sprite file to use.

**Type:** `FileName`

**Optional:** Yes

### dice

Only loaded if `layers` is not defined.

Number of slices this is sliced into when using the "optimized atlas packing" option. If you are a modder, you can just ignore this property. Example: If this is 4, the sprite will be sliced into a 4x4 grid.

**Type:** `SpriteSizeType`

**Optional:** Yes

### dice_x

Only loaded if `layers` is not defined.

Same as `dice` above, but this specifies only how many slices there are on the x axis.

**Type:** `SpriteSizeType`

**Optional:** Yes

### dice_y

Only loaded if `layers` is not defined.

Same as `dice` above, but this specifies only how many slices there are on the y axis.

**Type:** `SpriteSizeType`

**Optional:** Yes

## Examples

```
```
-- simple sprite
picture_set_enemy =
{
  filename = "__base__/graphics/entity/land-mine/land-mine-set-enemy.png",
  priority = "medium",
  width = 32,
  height = 32
}
```
```

```
```
-- sprite with layers
picture =
{
  layers =
  {
    {
      filename = "__base__/graphics/entity/wooden-chest/wooden-chest.png",
      priority = "extra-high",
      width = 62,
      height = 72,
      shift = util.by_pixel(0.5, -2),
      scale = 0.5
    },
    {
      filename = "__base__/graphics/entity/wooden-chest/wooden-chest-shadow.png",
      priority = "extra-high",
      width = 104,
      height = 40,
      shift = util.by_pixel(10, 6.5),
      draw_as_shadow = true,
      scale = 0.5
    }
  }
}
```
```

