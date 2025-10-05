# LuaPrototypeBase

Base for all prototype classes.

**Abstract:** Yes

## Attributes

### type

Type of this prototype.

**Read type:** `string`

### name

Name of this prototype.

**Read type:** `string`

### order

The string used to alphabetically sort these prototypes. It is a simple string that has no additional semantic meaning.

**Read type:** `string`

### localised_name

**Read type:** `LocalisedString`

### localised_description

**Read type:** `LocalisedString`

### factoriopedia_description

Provides additional description used in factoriopedia.

**Read type:** `LocalisedString`

### group

Group of this prototype.

**Read type:** `LuaGroup`

### subgroup

Subgroup of this prototype.

**Read type:** `LuaGroup`

### hidden

**Read type:** `boolean`

### hidden_in_factoriopedia

**Read type:** `boolean`

### parameter

**Read type:** `boolean`

### custom_tooltip_fields

Extra description items in the tooltip and Factoriopedia.

**Read type:** Array[`CustomTooltipField`]

**Optional:** Yes

