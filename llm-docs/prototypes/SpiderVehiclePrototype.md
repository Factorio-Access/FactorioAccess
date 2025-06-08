# SpiderVehiclePrototype

A [spidertron](https://wiki.factorio.com/Spidertron).

**Parent:** `VehiclePrototype`

## Properties

### Mandatory Properties

#### automatic_weapon_cycling

**Type:** `boolean`



#### chain_shooting_cooldown_modifier

**Type:** `float`

This is applied whenever the spider shoots (manual and automatic targeting), `automatic_weapon_cycling` is true and the next gun in line (which is then selected) has ammo. When all of the above is the case, the chain_shooting_cooldown_modifier is a multiplier on the remaining shooting cooldown: `cooldown = (remaining_cooldown × chain_shooting_cooldown_modifier)`.

chain_shooting_cooldown_modifier is intended to be in the range of 0 to 1. This means that setting chain_shooting_cooldown_modifier to 0 reduces the remaining shooting cooldown to 0 while a chain_shooting_cooldown_modifier of 1 does not affect the remaining shooting cooldown at all.

#### energy_source

**Type:** 



#### height

**Type:** `float`

The height of the spider affects the shooting height and the drawing of the graphics and lights.

#### inventory_size

**Type:** `ItemStackIndex`



#### movement_energy_consumption

**Type:** `Energy`



#### spider_engine

**Type:** `SpiderEngineSpecification`



### Optional Properties

#### graphics_set

**Type:** `SpiderVehicleGraphicsSet`



#### guns

**Type:** ``ItemID`[]`

The guns this spider vehicle uses.

#### torso_bob_speed

**Type:** `float`

Cannot be negative.

**Default:** `{'complex_type': 'literal', 'value': 1}`

#### torso_rotation_speed

**Type:** `float`

The orientation of the torso of the spider affects the shooting direction and the drawing of the graphics and lights.

**Default:** `{'complex_type': 'literal', 'value': 1}`

#### trash_inventory_size

**Type:** `ItemStackIndex`

If set to 0 then the spider will not have a Logistics tab.

**Default:** `{'complex_type': 'literal', 'value': 0}`

