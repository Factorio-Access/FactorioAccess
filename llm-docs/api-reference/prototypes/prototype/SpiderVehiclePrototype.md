# SpiderVehiclePrototype

A [spidertron](https://wiki.factorio.com/Spidertron).

**Parent:** [VehiclePrototype](VehiclePrototype.md)
**Type name:** `spider-vehicle`

## Properties

### energy_source

**Type:** `BurnerEnergySource` | `VoidEnergySource`

**Required:** Yes

### inventory_size

**Type:** `ItemStackIndex`

**Required:** Yes

### graphics_set

**Type:** `SpiderVehicleGraphicsSet`

**Optional:** Yes

### spider_engine

**Type:** `SpiderEngineSpecification`

**Required:** Yes

### height

The height of the spider affects the shooting height and the drawing of the graphics and lights.

**Type:** `float`

**Required:** Yes

### movement_energy_consumption

**Type:** `Energy`

**Required:** Yes

### automatic_weapon_cycling

**Type:** `boolean`

**Required:** Yes

### chain_shooting_cooldown_modifier

This is applied whenever the spider shoots (manual and automatic targeting), `automatic_weapon_cycling` is true and the next gun in line (which is then selected) has ammo. When all of the above is the case, the chain_shooting_cooldown_modifier is a multiplier on the remaining shooting cooldown: `cooldown = (remaining_cooldown × chain_shooting_cooldown_modifier)`.

chain_shooting_cooldown_modifier is intended to be in the range of 0 to 1. This means that setting chain_shooting_cooldown_modifier to 0 reduces the remaining shooting cooldown to 0 while a chain_shooting_cooldown_modifier of 1 does not affect the remaining shooting cooldown at all.

**Type:** `float`

**Required:** Yes

### torso_rotation_speed

The orientation of the torso of the spider affects the shooting direction and the drawing of the graphics and lights.

**Type:** `float`

**Optional:** Yes

**Default:** 1

### torso_bob_speed

Cannot be negative.

**Type:** `float`

**Optional:** Yes

**Default:** 1

### trash_inventory_size

If set to 0 then the spider will not have a Logistics tab.

**Type:** `ItemStackIndex`

**Optional:** Yes

**Default:** 0

### guns

The guns this spider vehicle uses.

**Type:** Array[`ItemID`]

**Optional:** Yes

