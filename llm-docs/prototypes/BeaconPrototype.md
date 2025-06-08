# BeaconPrototype

Entity with the ability to transfer [module](prototype:ModulePrototype) effects to its neighboring entities.

**Parent:** `EntityWithOwnerPrototype`

## Properties

### Mandatory Properties

#### distribution_effectivity

**Type:** `double`

The multiplier of the module's effects, when shared between neighbors.

#### energy_source

**Type:** 



#### energy_usage

**Type:** `Energy`

The constant power usage of this beacon.

#### module_slots

**Type:** `ItemStackIndex`

The number of module slots in this beacon.

#### supply_area_distance

**Type:** `uint32`

The maximum distance that this beacon can supply its neighbors with its module's effects. Max distance is 64.

### Optional Properties

#### allowed_effects

**Type:** `EffectTypeLimitation`

The types of [modules](prototype:ModulePrototype) that a player can place inside of the beacon.

**Default:** `No effects are allowed`

#### allowed_module_categories

**Type:** ``ModuleCategoryID`[]`

Sets the [module categories](prototype:ModuleCategory) that are allowed to be inserted into this machine.

**Default:** `All module categories are allowed`

#### animation

**Type:** `Animation`

Only loaded if `graphics_set` is not defined.

The animation for the beacon, when in use.

#### base_picture

**Type:** `Animation`

Only loaded if `graphics_set` is not defined.

The picture of the beacon when it is not on.

#### beacon_counter

**Type:** 

The beacon counter used by effect receiver when deciding which sample to take from `profile`.

**Default:** `{'complex_type': 'literal', 'value': 'total'}`

#### distribution_effectivity_bonus_per_quality_level

**Type:** `double`

Must be 0 or positive.

#### graphics_set

**Type:** `BeaconGraphicsSet`

The graphics for the beacon.

#### perceived_performance

**Type:** `PerceivedPerformance`

Affects animation speed.

#### profile

**Type:** ``double`[]`

Extra multiplier applied to the effects received from beacon by the effect receiver based on amount of beacons that are in range of that effect receiver.

If there are more beacons that reach the effect receiver than there are entries in this array, then the last entry in the array is used for the multiplier.

If this is not defined, then an implicit profile of `{1}` will be used.

#### radius_visualisation_picture

**Type:** `Sprite`



