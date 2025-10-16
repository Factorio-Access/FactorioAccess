# EquipmentShape

The shape and dimensions of an equipment module.

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### width

**Type:** `uint32`

**Required:** Yes

### height

**Type:** `uint32`

**Required:** Yes

### type

The shape. When using "manual", `points` must be defined.

**Type:** `"full"` | `"manual"`

**Required:** Yes

### points

Only used when when `type` is `"manual"`. Each inner array is a "position" inside width×height of the equipment. Each positions that is defined is a filled squares of the equipment shape. `{0, 0}` is the upper left corner of the equipment.

**Type:** Array[Array[`uint32`]]

**Optional:** Yes

