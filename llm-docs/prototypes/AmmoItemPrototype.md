# AmmoItemPrototype

Ammo used for a gun.

**Parent:** `ItemPrototype`

## Properties

### Mandatory Properties

#### ammo_category

**Type:** `AmmoCategoryID`



#### ammo_type

**Type:** 

When using a plain [AmmoType](prototype:AmmoType) (no array), the ammo type applies to everything (`"default"`).

When using an array of AmmoTypes, they have the additional [AmmoType::source_type](prototype:AmmoType::source_type) property.

### Optional Properties

#### magazine_size

**Type:** `float`

Number of shots before ammo item is consumed. Must be >= `1`.

**Default:** `{'complex_type': 'literal', 'value': 1}`

#### reload_time

**Type:** `float`

Amount of extra time (in ticks) it takes to reload the weapon after depleting the magazine. Must be >= `0`.

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### shoot_protected

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': False}`

