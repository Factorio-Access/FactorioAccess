# AsteroidPrototype

**Parent:** [EntityWithOwnerPrototype](EntityWithOwnerPrototype.md)
**Type name:** `asteroid`
**Visibility:** space_age

## Properties

### mass

**Type:** `double`

**Optional:** Yes

**Default:** 1.0

### graphics_set

**Type:** `AsteroidGraphicsSet`

**Optional:** Yes

### emissions_per_second

Emissions cannot be larger than zero, asteroids cannot produce pollution.

**Type:** Dictionary[`AirbornePollutantID`, `double`]

**Optional:** Yes

**Overrides parent:** Yes

