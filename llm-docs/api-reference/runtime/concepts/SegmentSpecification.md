# SegmentSpecification

A runtime representation of [SegmentSpecification](prototype:SegmentSpecification).

**Type:** Table

## Parameters

### distance_from_head

The distance (in tiles) along the unit's body between this segment's center and the head [SegmentedUnitPrototype](prototype:SegmentedUnitPrototype)'s center. This value is automatically pre-calculated after the prototype phase.

**Type:** `double`

**Required:** Yes

### segment

The [SegmentPrototype](prototype:SegmentPrototype) at this position in the unit.

**Type:** `LuaEntityPrototype`

**Required:** Yes

