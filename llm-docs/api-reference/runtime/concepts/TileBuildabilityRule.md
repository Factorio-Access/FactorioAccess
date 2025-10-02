# TileBuildabilityRule

A runtime representation of [TileBuildabilityRule](prototype:TileBuildabilityRule).

**Type:** Table

## Parameters

### area

The area that this rule applies to.

**Type:** `BoundingBox`

**Required:** Yes

### colliding_tiles

The tiles that this rule collides with.

**Type:** `CollisionMask`

**Required:** Yes

### remove_on_collision

If the entity should be removed upon collision.

**Type:** `boolean`

**Required:** Yes

### required_tiles

The tiles that this rule requires to be present.

**Type:** `CollisionMask`

**Required:** Yes

