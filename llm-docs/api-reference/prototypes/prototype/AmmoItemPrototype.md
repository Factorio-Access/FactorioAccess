# AmmoItemPrototype

Ammo used for a gun.

**Parent:** [ItemPrototype](ItemPrototype.md)
**Type name:** `ammo`

## Properties

### ammo_type

When using a plain [AmmoType](prototype:AmmoType) (no array), the ammo type applies to everything (`"default"`).

When using an array of AmmoTypes, they have the additional [AmmoType::source_type](prototype:AmmoType::source_type) property.

**Type:** `AmmoType` | Array[`AmmoType`]

**Required:** Yes

### magazine_size

Number of shots before ammo item is consumed. Must be >= `1`.

**Type:** `float`

**Optional:** Yes

**Default:** 1

### reload_time

Amount of extra time (in ticks) it takes to reload the weapon after depleting the magazine. Must be >= `0`.

**Type:** `float`

**Optional:** Yes

**Default:** 0

### ammo_category

**Type:** `AmmoCategoryID`

**Required:** Yes

### shoot_protected

**Type:** `boolean`

**Optional:** Yes

**Default:** False

