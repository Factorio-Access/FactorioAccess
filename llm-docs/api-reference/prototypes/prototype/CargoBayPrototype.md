# CargoBayPrototype

**Parent:** [EntityWithOwnerPrototype](EntityWithOwnerPrototype.md)
**Type name:** `cargo-bay`
**Visibility:** space_age

## Properties

### graphics_set

**Type:** `CargoBayConnectableGraphicsSet`

**Optional:** Yes

### platform_graphics_set

A special variant which renders on space platforms. If not specified, the game will fall back to the regular graphics set.

**Type:** `CargoBayConnectableGraphicsSet`

**Optional:** Yes

### inventory_size_bonus

Cannot be 0.

**Type:** `ItemStackIndex`

**Required:** Yes

### hatch_definitions

**Type:** Array[`CargoHatchDefinition`]

**Optional:** Yes

### build_grid_size

Has to be 2 for 2x2 grid.

**Type:** `2`

**Optional:** Yes

**Default:** 2

**Overrides parent:** Yes

