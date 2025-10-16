# LightningPrototype

Lightning randomly hits entities on planets with [lightning_properties](prototype:PlanetPrototype::lightning_properties).

If a [lightning attractor](prototype:LightningAttractorPrototype) is hit by lightning it will absorb the lightning hit for energy.

If a something that is not an attractor is hit by lightning it will be damaged by the strike.

**Parent:** [EntityPrototype](EntityPrototype.md)
**Type name:** `lightning`
**Visibility:** space_age

## Properties

### graphics_set

**Type:** `LightningGraphicsSet`

**Optional:** Yes

### sound

**Type:** `Sound`

**Optional:** Yes

### attracted_volume_modifier

**Type:** `float`

**Optional:** Yes

**Default:** 1.0

### strike_effect

Effect that is triggered when lightning strikes something that is not a lightning attractor. Triggered before `damage` is applied.

**Type:** `Trigger`

**Optional:** Yes

### attractor_hit_effect

Effect that is triggered when lightning hits  a [lightning attractor](prototype:LightningAttractorPrototype). Triggered after the attractor is charged by the lightning hit.

**Type:** `Trigger`

**Optional:** Yes

### source_offset

**Type:** `Vector`

**Optional:** Yes

### source_variance

**Type:** `Vector`

**Optional:** Yes

### damage

When lightning strikes something that is not a lightning attractor, this damage is applied to the target.

**Type:** `double`

**Optional:** Yes

**Default:** 100

### energy

When lightning hits a [lightning attractor](prototype:LightningAttractorPrototype), this amount of energy is transferred to the lightning attractor.

**Type:** `Energy`

**Optional:** Yes

**Default:** "Max double"

### time_to_damage

Must be less than or equal to `effect_duration`.

**Type:** `uint16`

**Optional:** Yes

**Default:** 0

### effect_duration

**Type:** `uint16`

**Required:** Yes

