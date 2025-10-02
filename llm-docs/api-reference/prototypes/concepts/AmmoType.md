# AmmoType

Definition of actual parameters used in attack.

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### action

Describes actions taken upon attack happening.

**Type:** `Trigger`

**Optional:** Yes

### clamp_position

When true, the gun will be able to shoot even when the target is out of range. Only applies when `target_type` equals `"position"`. The gun will fire at the maximum range in the direction of the target position.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### energy_consumption

Energy consumption of a single shot, if applicable.

**Type:** `Energy`

**Optional:** Yes

### range_modifier

Affects the `range` value of the shooting gun prototype's [BaseAttackParameters](prototype:BaseAttackParameters) to give a modified maximum range. The `min_range` value of the gun is unaffected.

This has no effect on artillery turrets and wagons even though the bonus appears in the GUI. [Forum thread](https://forums.factorio.com/103658).

**Type:** `double`

**Optional:** Yes

**Default:** 1

### cooldown_modifier

**Type:** `double`

**Optional:** Yes

**Default:** 1

### consumption_modifier

**Type:** `float`

**Optional:** Yes

**Default:** 1

### target_type

`"entity"` fires at an entity, `"position"` fires directly at a position, `"direction"` fires in a direction.

If this is `"entity"`, `clamp_position` is forced to be `false`.

**Type:** `"entity"` | `"position"` | `"direction"`

**Optional:** Yes

**Default:** "entity"

### source_type

Only exists (and is then mandatory) if the [AmmoItemPrototype::ammo_type](prototype:AmmoItemPrototype::ammo_type) this AmmoType is defined on has multiple ammo types.

Defines for which kind of entity this ammo type applies. Each entity kind can only be used once per array.

**Type:** `AmmoSourceType`

**Optional:** Yes

### target_filter

List of entities that can be targeted by this ammo type.

**Type:** Array[`EntityID`]

**Optional:** Yes

