# AchievementPrototype

This prototype definition is used for the in-game achievements.

**Parent:** [Prototype](Prototype.md)
**Type name:** `achievement`

## Examples

```
{
  type = "achievement",
  name = "so-long-and-thanks-for-all-the-fish",
  order = "g[secret]-a[so-long-and-thanks-for-all-the-fish]",
  icon = "__base__/graphics/achievement/so-long-and-thanks-for-all-the-fish.png",
  icon_size = 128
}
```

## Properties

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

The base game uses 128px icons for achievements.

Only loaded if `icons` is not defined.

**Type:** `SpriteSizeType`

**Optional:** Yes

**Default:** 64

### steam_stats_name

Unusable by mods, as this refers to unlocking the achievement through Steam.

**Type:** `string`

**Optional:** Yes

**Default:** ""

### allowed_without_fight

If this is set to `false`, it is not possible to complete the achievement on the peaceful difficulty setting or when the enemy base generation settings have been changed.

**Type:** `boolean`

**Optional:** Yes

**Default:** True

