# LabPrototype

A [lab](https://wiki.factorio.com/Lab). It consumes [science packs](prototype:ToolPrototype) to research [technologies](prototype:TechnologyPrototype).

**Parent:** [EntityWithOwnerPrototype](EntityWithOwnerPrototype.md)
**Type name:** `lab`

## Properties

### energy_usage

The amount of energy this lab uses.

**Type:** `Energy`

**Required:** Yes

### energy_source

Defines how this lab gets energy.

**Type:** `EnergySource`

**Required:** Yes

### on_animation

The animation that plays when the lab is active.

**Type:** `Animation`

**Optional:** Yes

### off_animation

The animation that plays when the lab is idle.

**Type:** `Animation`

**Optional:** Yes

### frozen_patch

**Type:** `Sprite`

**Optional:** Yes

### inputs

A list of the names of science packs that can be used in this lab.

If a technology requires other types of science packs, it cannot be researched in this lab.

**Type:** Array[`ItemID`]

**Required:** Yes

**Examples:**

```
inputs = {"automation-science-pack", "logistic-science-pack", "chemical-science-pack", "military-science-pack", "production-science-pack", "utility-science-pack", "space-science-pack"}
```

### researching_speed

**Type:** `double`

**Optional:** Yes

**Default:** 1

### effect_receiver

**Type:** `EffectReceiver`

**Optional:** Yes

### module_slots

The number of module slots in this lab.

**Type:** `ItemStackIndex`

**Optional:** Yes

### quality_affects_module_slots

If set, [QualityPrototype::lab_module_slots_bonus](prototype:QualityPrototype::lab_module_slots_bonus) will be added to module slots count.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### uses_quality_drain_modifier

Whether the [QualityPrototype::science_pack_drain_multiplier](prototype:QualityPrototype::science_pack_drain_multiplier) of the quality of this lab should affect how much science is consumed to research one unit of technology.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### science_pack_drain_rate_percent

May not be `0` or larger than `100`.

**Type:** `uint8`

**Optional:** Yes

**Default:** 100

### allowed_effects

Sets the [modules](prototype:ModulePrototype) and [beacon](prototype:BeaconPrototype) effects that are allowed to be used on this lab.

**Type:** `EffectTypeLimitation`

**Optional:** Yes

**Default:** "All effects except quality are allowed"

### allowed_module_categories

Sets the [module categories](prototype:ModuleCategory) that are allowed to be inserted into this machine.

**Type:** Array[`ModuleCategoryID`]

**Optional:** Yes

**Default:** "All module categories are allowed"

### light

**Type:** `LightDefinition`

**Optional:** Yes

### trash_inventory_size

**Type:** `ItemStackIndex`

**Optional:** Yes

