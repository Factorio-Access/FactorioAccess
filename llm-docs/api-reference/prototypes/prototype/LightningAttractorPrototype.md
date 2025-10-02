# LightningAttractorPrototype

**Parent:** [EntityWithOwnerPrototype](EntityWithOwnerPrototype.md)
**Type name:** `lightning-attractor`
**Visibility:** space_age

## Properties

### chargable_graphics

**Type:** `ChargableGraphics`

**Optional:** Yes

### lightning_strike_offset

**Type:** `MapPosition`

**Optional:** Yes

### efficiency

Cannot be less than 0.

**Type:** `double`

**Optional:** Yes

**Default:** 0

### range_elongation

**Type:** `double`

**Optional:** Yes

**Default:** 0

### energy_source

Mandatory if `efficiency` is larger than 0. May not be defined if `efficiency` is 0.

**Type:** `ElectricEnergySource`

**Optional:** Yes

