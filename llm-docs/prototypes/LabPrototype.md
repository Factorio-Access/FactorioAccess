# LabPrototype

A [lab](https://wiki.factorio.com/Lab). It consumes [science packs](prototype:ToolPrototype) to research [technologies](prototype:TechnologyPrototype).

**Parent:** `EntityWithOwnerPrototype`

## Properties

### Mandatory Properties

#### energy_source

**Type:** `EnergySource`

Defines how this lab gets energy.

#### energy_usage

**Type:** `Energy`

The amount of energy this lab uses.

#### inputs

**Type:** ``ItemID`[]`

A list of the names of science packs that can be used in this lab.

If a technology requires other types of science packs, it cannot be researched in this lab.

### Optional Properties

#### allowed_effects

**Type:** `EffectTypeLimitation`

Sets the [modules](prototype:ModulePrototype) and [beacon](prototype:BeaconPrototype) effects that are allowed to be used on this lab.

**Default:** `All effects except quality are allowed`

#### allowed_module_categories

**Type:** ``ModuleCategoryID`[]`

Sets the [module categories](prototype:ModuleCategory) that are allowed to be inserted into this machine.

**Default:** `All module categories are allowed`

#### effect_receiver

**Type:** `EffectReceiver`



#### frozen_patch

**Type:** `Sprite`



#### light

**Type:** `LightDefinition`



#### module_slots

**Type:** `ItemStackIndex`

The number of module slots in this lab.

#### off_animation

**Type:** `Animation`

The animation that plays when the lab is idle.

#### on_animation

**Type:** `Animation`

The animation that plays when the lab is active.

#### researching_speed

**Type:** `double`



**Default:** `{'complex_type': 'literal', 'value': 1}`

#### science_pack_drain_rate_percent

**Type:** `uint8`

May not be `0` or larger than `100`.

**Default:** `{'complex_type': 'literal', 'value': 100}`

#### trash_inventory_size

**Type:** `ItemStackIndex`



#### uses_quality_drain_modifier

**Type:** `boolean`

Whether the [QualityPrototype::science_pack_drain_multiplier](prototype:QualityPrototype::science_pack_drain_multiplier) of the quality of the science pack should be considered by the lab.

**Default:** `{'complex_type': 'literal', 'value': False}`

