# CargoBayPrototype



**Parent:** `EntityWithOwnerPrototype`

## Properties

### Mandatory Properties

#### inventory_size_bonus

**Type:** `ItemStackIndex`

Cannot be 0.

### Optional Properties

#### build_grid_size

**Type:** `2`

Has to be 2 for 2x2 grid.

**Default:** `{'complex_type': 'literal', 'value': 2}`

#### graphics_set

**Type:** `CargoBayConnectableGraphicsSet`



#### hatch_definitions

**Type:** ``CargoHatchDefinition`[]`



#### platform_graphics_set

**Type:** `CargoBayConnectableGraphicsSet`

A special variant which renders on space platforms. If not specified, the game will fall back to the regular graphics set.

