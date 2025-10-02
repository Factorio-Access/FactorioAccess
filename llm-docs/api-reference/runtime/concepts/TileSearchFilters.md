# TileSearchFilters

**Type:** Table

## Parameters

### area

**Type:** `BoundingBox`

**Optional:** Yes

### collision_mask

**Type:** `CollisionLayerID` | Array[`CollisionLayerID`] | Dictionary[`CollisionLayerID`, `True`]

**Optional:** Yes

### force

**Type:** `ForceSet`

**Optional:** Yes

### has_double_hidden_tile

Can be further filtered by supplying a `force` filter.

**Type:** `boolean`

**Optional:** Yes

### has_hidden_tile

**Type:** `boolean`

**Optional:** Yes

### has_tile_ghost

Can be further filtered by supplying a `force` filter.

**Type:** `boolean`

**Optional:** Yes

### invert

If the filters should be inverted.

**Type:** `boolean`

**Optional:** Yes

### limit

**Type:** `uint`

**Optional:** Yes

### name

An empty array means nothing matches the name filter.

**Type:** `TileID` | Array[`TileID`]

**Optional:** Yes

### position

Ignored if not given with radius.

**Type:** `MapPosition`

**Optional:** Yes

### radius

If given with position, will return all tiles within the radius of the position.

**Type:** `double`

**Optional:** Yes

### to_be_deconstructed

Can be further filtered by supplying a `force` filter.

**Type:** `boolean`

**Optional:** Yes

