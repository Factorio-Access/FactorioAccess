# FontPrototype

Fonts are used in all GUIs in the game.

## Properties

### Mandatory Properties

#### from

**Type:** `string`

The name of the fonts .ttf descriptor. This descriptor must be defined in the locale info.json. Refer to `data/core/locale/_language_/info.json` for examples.

#### name

**Type:** `string`

Name of the font.

#### size

**Type:** `int32`

Size of the font.

#### type

**Type:** `font`



### Optional Properties

#### border

**Type:** `boolean`

Whether the font has a border.

**Default:** `{'complex_type': 'literal', 'value': False}`

#### border_color

**Type:** `Color`

The color of the border, if enabled.

#### filtered

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': False}`

#### spacing

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 0}`

