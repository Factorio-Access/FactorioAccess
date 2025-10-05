# EntitySearchFilters

**Type:** Table

## Parameters

### area

**Type:** `BoundingBox`

**Optional:** Yes

### collision_mask

**Type:** `CollisionLayerID` | Array[`CollisionLayerID`] | Dictionary[`CollisionLayerID`, `True`]

**Optional:** Yes

### direction

**Type:** `defines.direction` | Array[`defines.direction`]

**Optional:** Yes

### force

**Type:** `ForceSet`

**Optional:** Yes

### ghost_name

An empty array means nothing matches the ghost_name filter.

**Type:** `EntityID` | Array[`EntityID`]

**Optional:** Yes

### ghost_type

An empty array means nothing matches the ghost_type filter.

**Type:** `string` | Array[`string`]

**Optional:** Yes

### has_item_inside

**Type:** `ItemWithQualityID`

**Optional:** Yes

### invert

Whether the filters should be inverted.

**Type:** `boolean`

**Optional:** Yes

### is_military_target

**Type:** `boolean`

**Optional:** Yes

### limit

**Type:** `uint32`

**Optional:** Yes

### name

An empty array means nothing matches the name filter.

**Type:** `EntityID` | Array[`EntityID`]

**Optional:** Yes

### position

Has precedence over area field.

**Type:** `MapPosition`

**Optional:** Yes

### quality

**Type:** `QualityCondition`

**Optional:** Yes

### radius

If given with position, will return all entities within the radius of the position.

**Type:** `double`

**Optional:** Yes

### to_be_deconstructed

**Type:** `boolean`

**Optional:** Yes

### to_be_upgraded

**Type:** `boolean`

**Optional:** Yes

### type

An empty array means nothing matches the type filter.

**Type:** `string` | Array[`string`]

**Optional:** Yes

