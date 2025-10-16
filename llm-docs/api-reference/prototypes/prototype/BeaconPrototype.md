# BeaconPrototype

Entity with the ability to transfer [module](prototype:ModulePrototype) effects to its neighboring entities.

**Parent:** [EntityWithOwnerPrototype](EntityWithOwnerPrototype.md)
**Type name:** `beacon`

## Properties

### energy_usage

The constant power usage of this beacon.

**Type:** `Energy`

**Required:** Yes

**Examples:**

```
energy_usage = "480kW"
```

### energy_source

**Type:** `ElectricEnergySource` | `VoidEnergySource`

**Required:** Yes

### supply_area_distance

The maximum distance that this beacon can supply its neighbors with its module's effects. Max distance is 64.

**Type:** `uint32`

**Required:** Yes

### distribution_effectivity

The multiplier of the module's effects, when shared between neighbors.

**Type:** `double`

**Required:** Yes

### distribution_effectivity_bonus_per_quality_level

Must be 0 or positive.

**Type:** `double`

**Optional:** Yes

### module_slots

The number of module slots in this beacon.

**Type:** `ItemStackIndex`

**Required:** Yes

### quality_affects_module_slots

If set, [QualityPrototype::beacon_module_slots_bonus](prototype:QualityPrototype::beacon_module_slots_bonus) will be added to module slots count.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### quality_affects_supply_area_distance

If set, [QualityPrototype::beacon_supply_area_distance_bonus](prototype:QualityPrototype::beacon_supply_area_distance_bonus) will be added to supply_area_distance. Total value will be clamped to be within range `[0, 64]`.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### graphics_set

The graphics for the beacon.

**Type:** `BeaconGraphicsSet`

**Optional:** Yes

### animation

Only loaded if `graphics_set` is not defined.

The animation for the beacon, when in use.

**Type:** `Animation`

**Optional:** Yes

### base_picture

Only loaded if `graphics_set` is not defined.

The picture of the beacon when it is not on.

**Type:** `Animation`

**Optional:** Yes

### perceived_performance

Affects animation speed.

**Type:** `PerceivedPerformance`

**Optional:** Yes

### radius_visualisation_picture

**Type:** `Sprite`

**Optional:** Yes

### allowed_effects

The types of [modules](prototype:ModulePrototype) that a player can place inside of the beacon.

**Type:** `EffectTypeLimitation`

**Optional:** Yes

**Default:** "No effects are allowed"

### allowed_module_categories

Sets the [module categories](prototype:ModuleCategory) that are allowed to be inserted into this machine.

**Type:** Array[`ModuleCategoryID`]

**Optional:** Yes

**Default:** "All module categories are allowed"

### profile

Extra multiplier applied to the effects received from beacon by the effect receiver based on amount of beacons that are in range of that effect receiver.

If there are more beacons that reach the effect receiver than there are entries in this array, then the last entry in the array is used for the multiplier.

If this is not defined, then an implicit profile of `{1}` will be used.

**Type:** Array[`double`]

**Optional:** Yes

**Examples:**

```
profile = {1, 0} -- entities do not receive any effects when they are in range of more than one beacon
```

### beacon_counter

The beacon counter used by effect receiver when deciding which sample to take from `profile`.

**Type:** `"total"` | `"same_type"`

**Optional:** Yes

**Default:** "total"

