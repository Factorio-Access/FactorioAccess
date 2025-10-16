# RailRemnantsPrototype

Used for rail corpses.

**Parent:** [CorpsePrototype](CorpsePrototype.md)
**Type name:** `rail-remnants`

## Properties

### pictures

**Type:** `RailPictureSet`

**Required:** Yes

### related_rail

**Type:** `EntityID`

**Required:** Yes

### secondary_collision_box

**Type:** `BoundingBox`

**Optional:** Yes

### build_grid_size

Has to be 2 for 2x2 grid.

**Type:** `2`

**Optional:** Yes

**Default:** 2

**Overrides parent:** Yes

### collision_box

"Rail remnant entities must have a non-zero [collision_box](prototype:EntityPrototype::collision_box) defined.

**Type:** `BoundingBox`

**Optional:** Yes

**Default:** "Empty = `{{0, 0}, {0, 0}}`"

**Overrides parent:** Yes

