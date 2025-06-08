# AmmoCategory

An ammo category. Each weapon has an ammo category, and can use any ammo with the same ammo category. Ammo categories can also be upgraded by technologies.

**Parent:** `Prototype`

## Properties

### Optional Properties

#### bonus_gui_order

**Type:** `Order`



**Default:** `{'complex_type': 'literal', 'value': ''}`

#### icon

**Type:** `FileName`

Path to the icon file.

Only loaded if `icons` is not defined.

#### icon_size

**Type:** `SpriteSizeType`

The size of the square icon, in pixels. E.g. `32` for a 32px by 32px icon. Must be larger than `0`.

Only loaded if `icons` is not defined.

**Default:** `{'complex_type': 'literal', 'value': 64}`

#### icons

**Type:** ``IconData`[]`

Can't be an empty array.

