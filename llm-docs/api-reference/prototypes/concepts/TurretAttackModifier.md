# TurretAttackModifier

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### type

**Type:** `"turret-attack"`

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

### turret_id

Name of the [EntityPrototype](prototype:EntityPrototype) that is affected. This also works for non-turrets such as tanks, however, the bonus does not appear in the entity's tooltips.

**Type:** `EntityID`

**Required:** Yes

### modifier

Modification value, which will be added to the current turret attack modifier upon researching.

**Type:** `double`

**Required:** Yes

