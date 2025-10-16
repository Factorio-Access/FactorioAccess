# FontPrototype

Fonts are used in all GUIs in the game.

**Type name:** `font`

## Examples

```
{
  type = "font",
  name = "default-button",
  from = "default-bold",
  size = 18
}
```

## Properties

### type

**Type:** `"font"`

**Required:** Yes

### name

Name of the font.

**Type:** `string`

**Required:** Yes

### size

Size of the font.

**Type:** `int32`

**Required:** Yes

### from

The name of the fonts .ttf descriptor. This descriptor must be defined in the locale info.json. Refer to `data/core/locale/_language_/info.json` for examples.

**Type:** `string`

**Required:** Yes

### spacing

**Type:** `float`

**Optional:** Yes

**Default:** 0

### border

Whether the font has a border.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### filtered

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### border_color

The color of the border, if enabled.

**Type:** `Color`

**Optional:** Yes

