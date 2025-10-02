# TechnologyPrototype

A [technology](https://wiki.factorio.com/Technologies).

**Parent:** [Prototype](Prototype.md)
**Type name:** `technology`

## Examples

```
{
  type = "technology",
  name = "steel-processing",
  icon_size = 256,
  icon = "__base__/graphics/technology/steel-processing.png",
  effects =
  {
    {
      type = "unlock-recipe",
      recipe = "steel-plate"
    },
    {
      type = "unlock-recipe",
      recipe = "steel-chest"
    }
  },
  unit =
  {
    count = 50,
    ingredients = {{"automation-science-pack", 1}},
    time = 5
  },
  order = "c-a"
}
```

## Properties

### name

If this name ends with `-<number>`, that number is ignored for localization purposes. E.g. if the name is `technology-3`, the game looks for the `technology-name.technology` localization. The technology tree will also show the number on the technology icon.

**Type:** `string`

**Required:** Yes

**Overrides parent:** Yes

### icons

Can't be an empty array.

**Type:** Array[`IconData`]

**Optional:** Yes

### icon

Path to the icon file.

Only loaded, and mandatory if `icons` is not defined.

**Type:** `FileName`

**Optional:** Yes

### icon_size

The size of the square icon, in pixels. E.g. `32` for a 32px by 32px icon. Must be larger than `0`.

The base game uses 256px icons for technologies.

Only loaded if `icons` is not defined.

**Type:** `SpriteSizeType`

**Optional:** Yes

**Default:** 64

### upgrade

When set to true, and the technology contains several levels, only the relevant one is displayed in the technology screen.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

**Examples:**

```
{
  type = "technology",
  name = "physical-projectile-damage-2",
  [...]
  upgrade = true
}
```

### enabled

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### essential

Whether the technology should be shown in the technology tree GUI when "Show only essential technologies" is enabled.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### visible_when_disabled

Controls whether the technology is shown in the tech GUI when it is not `enabled`.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### ignore_tech_cost_multiplier

Controls whether the technology cost ignores the tech cost multiplier set in the [DifficultySettings](runtime:DifficultySettings). E.g. `4` for the default expensive difficulty.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### allows_productivity

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### research_trigger

Mandatory if `unit` is not defined.

**Type:** `TechnologyTrigger`

**Optional:** Yes

### unit

Determines the cost in items and time of the technology.

Mandatory if `research_trigger` is not defined.

**Type:** `TechnologyUnit`

**Optional:** Yes

### max_level

`"infinite"` for infinite technologies, otherwise `uint32`.

Defaults to the same level as the technology, which is `0` for non-upgrades, and the level of the upgrade for upgrades.

**Type:** `uint32` | `"infinite"`

**Optional:** Yes

### prerequisites

List of technologies needed to be researched before this one can be researched.

**Type:** Array[`TechnologyID`]

**Optional:** Yes

**Examples:**

```
prerequisites = {"explosives", "military-2"}
```

### show_levels_info

Can be used to enable or disable showing levels info in technology slot.

**Type:** `boolean`

**Optional:** Yes

### effects

List of effects of the technology (applied when the technology is researched).

**Type:** Array[`Modifier`]

**Optional:** Yes

**Examples:**

```
{
  {
    type  = "unlock-recipe",
    recipe = "land-mine"
  }
}
```

