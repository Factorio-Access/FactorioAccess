# QualityPrototype



**Parent:** `Prototype`

## Properties

### Mandatory Properties

#### color

**Type:** `Color`



#### level

**Type:** `uint32`

Requires Space Age to use level greater than `0`.

#### name

**Type:** `string`

Unique textual identification of the prototype. May only contain alphanumeric characters, dashes and underscores. May not exceed a length of 200 characters.

Requires Space Age to create prototypes with name other than `normal` or `quality-unknown`.

### Optional Properties

#### beacon_power_usage_multiplier

**Type:** `float`

Must be >= 0.

**Default:** `{'complex_type': 'literal', 'value': 1}`

#### draw_sprite_by_default

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### icon

**Type:** `FileName`

Path to the icon file.

Mandatory if `icons` is not defined.

#### icon_size

**Type:** `SpriteSizeType`

The size of the square icon, in pixels. E.g. `32` for a 32px by 32px icon. Must be larger than `0`.

Only loaded if `icons` is not defined.

**Default:** `{'complex_type': 'literal', 'value': 64}`

#### icons

**Type:** ``IconData`[]`

Can't be an empty array.

#### mining_drill_resource_drain_multiplier

**Type:** `float`

Must be in range `[0, 1]`.

**Default:** `{'complex_type': 'literal', 'value': 1}`

#### next

**Type:** `QualityID`



#### next_probability

**Type:** `double`

Must be in range [0, 1.0].

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### science_pack_drain_multiplier

**Type:** `float`

Must be in range `[0, 1]`.

**Default:** `{'complex_type': 'literal', 'value': 1}`

