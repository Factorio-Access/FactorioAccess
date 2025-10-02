# ItemWithEntityDataPrototype

ItemWithEntityData saves data associated with the entity that it represents, for example the content of the equipment grid of a car.

**Parent:** [ItemPrototype](ItemPrototype.md)
**Type name:** `item-with-entity-data`

## Properties

### icon_tintable_masks

Can't be an empty array.

Only loaded if `icon_tintable` is defined.

**Type:** Array[`IconData`]

**Optional:** Yes

### icon_tintable_mask

Path to the icon file.

Only loaded if `icon_tintable_masks` is not defined and `icon_tintable` is defined.

**Type:** `FileName`

**Optional:** Yes

### icon_tintable_mask_size

The size of the square icon, in pixels. E.g. `32` for a 32px by 32px icon. Must be larger than `0`.

Only loaded if `icon_tintable_masks` is not defined and `icon_tintable` is defined.

**Type:** `SpriteSizeType`

**Optional:** Yes

**Default:** 64

### icon_tintables

Can't be an empty array.

Only loaded if `icon_tintable` is defined (`icon_tintables` takes precedence over `icon_tintable`).

**Type:** Array[`IconData`]

**Optional:** Yes

### icon_tintable

Path to the icon file.

Only loaded if `icon_tintables` is not defined.

**Type:** `FileName`

**Optional:** Yes

### icon_tintable_size

The size of the square icon, in pixels. E.g. `32` for a 32px by 32px icon. Must be larger than `0`.

Only loaded if `icon_tintables` is not defined and `icon_tintable` is defined.

**Type:** `SpriteSizeType`

**Optional:** Yes

**Default:** 64

