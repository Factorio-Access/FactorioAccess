# GunSpeedModifier

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### type

**Type:** `"gun-speed"`

**Required:** Yes

### infer_icon

If set to `false`, use the icon from [UtilitySprites](prototype:UtilitySprites) for this technology effect icon.

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### use_icon_overlay_constant

If `false`, do not draw the small "constant" icon over the technology effect icon.

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### ammo_category

Name of the [AmmoCategory](prototype:AmmoCategory) that is affected.

**Type:** `AmmoCategoryID`

**Required:** Yes

### modifier

Modification value, which will be added to the current gun speed modifier upon researching.

**Type:** `double`

**Required:** Yes

