# TechnologyPrototype

A [technology](https://wiki.factorio.com/Technologies).

**Parent:** `Prototype`

## Properties

### Mandatory Properties

#### name

**Type:** `string`

If this name ends with `-`, that number is ignored for localization purposes. E.g. if the name is `technology-3`, the game looks for the `technology-name.technology` localization. The technology tree will also show the number on the technology icon.

### Optional Properties

#### allows_productivity

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### effects

**Type:** ``Modifier`[]`

List of effects of the technology (applied when the technology is researched).

#### enabled

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### essential

**Type:** `boolean`

Whether the technology should be shown in the technology tree GUI when "Show only essential technologies" is enabled.

**Default:** `{'complex_type': 'literal', 'value': False}`

#### icon

**Type:** `FileName`

Path to the icon file.

Mandatory if `icons` is not defined.

#### icon_size

**Type:** `SpriteSizeType`

The size of the square icon, in pixels. E.g. `32` for a 32px by 32px icon. Must be larger than `0`.

The base game uses 256px icons for technologies.

Only loaded if `icons` is not defined.

**Default:** `{'complex_type': 'literal', 'value': 64}`

#### icons

**Type:** ``IconData`[]`

Can't be an empty array.

#### ignore_tech_cost_multiplier

**Type:** `boolean`

Controls whether the technology cost ignores the tech cost multiplier set in the [DifficultySettings](runtime:DifficultySettings). E.g. `4` for the default expensive difficulty.

**Default:** `{'complex_type': 'literal', 'value': False}`

#### max_level

**Type:** 

`"infinite"` for infinite technologies, otherwise `uint32`.

Defaults to the same level as the technology, which is `0` for non-upgrades, and the level of the upgrade for upgrades.

#### prerequisites

**Type:** ``TechnologyID`[]`

List of technologies needed to be researched before this one can be researched.

#### research_trigger

**Type:** `TechnologyTrigger`

Mandatory if `unit` is not defined.

#### show_levels_info

**Type:** `boolean`

Can be used to enable or disable showing levels info in technology slot.

#### unit

**Type:** `TechnologyUnit`

Determines the cost in items and time of the technology.

Mandatory if `research_trigger` is not defined.

#### upgrade

**Type:** `boolean`

When set to true, and the technology contains several levels, only the relevant one is displayed in the technology screen.

**Default:** `{'complex_type': 'literal', 'value': False}`

#### visible_when_disabled

**Type:** `boolean`

Controls whether the technology is shown in the tech GUI when it is not `enabled`.

**Default:** `{'complex_type': 'literal', 'value': False}`

