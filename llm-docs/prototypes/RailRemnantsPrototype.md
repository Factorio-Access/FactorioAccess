# RailRemnantsPrototype

Used for rail corpses.

**Parent:** `CorpsePrototype`

## Properties

### Mandatory Properties

#### pictures

**Type:** `RailPictureSet`



#### related_rail

**Type:** `EntityID`



### Optional Properties

#### build_grid_size

**Type:** `2`

Has to be 2 for 2x2 grid.

**Default:** `{'complex_type': 'literal', 'value': 2}`

#### collision_box

**Type:** `BoundingBox`

"Rail remnant entities must have a non-zero [collision_box](prototype:EntityPrototype::collision_box) defined.

**Default:** `Empty = `{{0, 0}, {0, 0}}``

#### secondary_collision_box

**Type:** `BoundingBox`



