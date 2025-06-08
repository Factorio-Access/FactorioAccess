# AchievementPrototype

This prototype definition is used for the in-game achievements.

**Parent:** `Prototype`

## Properties

### Optional Properties

#### allowed_without_fight

**Type:** `boolean`

If this is set to `false`, it is not possible to complete the achievement on the peaceful difficulty setting or when the enemy base generation settings have been changed.

**Default:** `{'complex_type': 'literal', 'value': True}`

#### icon

**Type:** `FileName`

Path to the icon file.

Mandatory if `icons` is not defined.

#### icon_size

**Type:** `SpriteSizeType`

The size of the square icon, in pixels. E.g. `32` for a 32px by 32px icon. Must be larger than `0`.

The base game uses 128px icons for achievements.

Only loaded if `icons` is not defined.

**Default:** `{'complex_type': 'literal', 'value': 64}`

#### icons

**Type:** ``IconData`[]`

Can't be an empty array.

#### steam_stats_name

**Type:** `string`

Unusable by mods, as this refers to unlocking the achievement through Steam.

**Default:** `{'complex_type': 'literal', 'value': ''}`

