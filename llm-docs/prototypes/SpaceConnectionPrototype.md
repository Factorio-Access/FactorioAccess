# SpaceConnectionPrototype



**Parent:** `Prototype`

## Properties

### Mandatory Properties

#### from

**Type:** `SpaceLocationID`



#### to

**Type:** `SpaceLocationID`



### Optional Properties

#### asteroid_spawn_definitions

**Type:** ``SpaceConnectionAsteroidSpawnDefinition`[]`



#### icon

**Type:** `FileName`

Path to the icon file.

Mandatory if `icons` is not defined.

#### icon_size

**Type:** `SpriteSizeType`

The size of the square icon, in pixels. E.g. `32` for a 32px by 32px icon. Must be larger than `0`.

Only loaded if `icons` is not defined.

**Default:** `{'complex_type': 'literal', 'value': 64}`

#### icons

**Type:** ``IconData`[]`

Can't be an empty array.

#### length

**Type:** `uint32`

Cannot be 0.

**Default:** `{'complex_type': 'literal', 'value': 600}`

