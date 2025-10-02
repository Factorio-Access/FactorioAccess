# PumpConnectorGraphics

A mapping of arrays of [PumpConnectorGraphicsAnimations](prototype:PumpConnectorGraphicsAnimation) to all 4 directions of the pump connection (to a fluid wagon).

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### north

Size of the array must be 6 or more.

**Type:** Array[`PumpConnectorGraphicsAnimation`]

**Required:** Yes

### east

Size of the array must be 6 or more.

**Type:** Array[`PumpConnectorGraphicsAnimation`]

**Required:** Yes

### south

Size of the array must be 6 or more.

**Type:** Array[`PumpConnectorGraphicsAnimation`]

**Required:** Yes

### west

Size of the array must be 6 or more.

**Type:** Array[`PumpConnectorGraphicsAnimation`]

**Required:** Yes

## Examples

```
```
load_animations =
{
  west =
  {
    [1] =
    {
      standup_base =
      {
        filename = "__base__/graphics/entity/pump/connector/V-R-135-load-standup-base.png",
        width = 110,
        height = 126,
        scale = 0.5,
        line_length = 1,
        frame_count = 20,
        shift = util.by_pixel(-23.5, -13.5)
      },
      standup_shadow =
      {
        filename = "__base__/graphics/entity/pump/connector/V-R-1-load-standup-base-shadow.png",
        width = 157,
        height = 136,
        scale = 0.5,
        line_length = 1,
        frame_count = 20,
        shift = util.by_pixel(-8.75, 8.5)
      },
    },
    [2] =
    {
      standup_base = { ... },
      standup_shadow = { ... },
      connector_shadow = { ... },
    },
    [3] = { ... },
    [4] = { ... },
    [5] = { ... },
    [6] = { ... },
  },
  north = { ... },
  east = { ... },
  south = { ... },
}
```
```

