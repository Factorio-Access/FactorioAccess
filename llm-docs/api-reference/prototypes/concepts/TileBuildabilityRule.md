# TileBuildabilityRule

Defines restrictions on what tiles an entity can or must be built on.

Note that once the entity has been placed, placing new tiles is not always restricted by these rules for performance reasons. In particular, for most entities these rules are only checked when placing tiles within the collision box of the entity. The exception to this are thrusters and asteroid collectors, for which the rules are always checked.

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### area

**Type:** `SimpleBoundingBox`

**Required:** Yes

### required_tiles

**Type:** `CollisionMaskConnector`

**Optional:** Yes

**Default:** "Any mask"

### colliding_tiles

**Type:** `CollisionMaskConnector`

**Optional:** Yes

**Default:** "No masks"

### remove_on_collision

**Type:** `boolean`

**Optional:** Yes

**Default:** False

