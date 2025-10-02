# LuaSegment

An individual segment of a [LuaSegmentedUnit](runtime:LuaSegmentedUnit). If the segment exists in a generated chunk, you can access the entity representation using [LuaSegment::entity](runtime:LuaSegment::entity).

## Attributes

### prototype

The prototype for the entity representation of the segment.

**Read type:** `LuaEntityPrototype`

### unit

The segmented unit that owns the segment.

**Read type:** `LuaSegmentedUnit`

### entity

The actual entity representation of the segment if it exists. A segment's entity will be automatically destroyed if the segment moves into chunks that have not yet been fully generated or onto "out-of-map" tiles. Conversely, if a segment moves into a chunk that is fully generated and onto a non-"out-of-map" tile, then its entity will be created if it doesn't exist yet.

**Read type:** `LuaEntity`

**Optional:** Yes

### position

The position of the segment if one has been assigned. A position may not be assigned if the unit's number of body nodes is fewer than [LuaSegmentedUnit::max_body_nodes](runtime:LuaSegmentedUnit::max_body_nodes).

This position may be in an un-generated chunk. Use [LuaSurface::is_chunk_generated](runtime:LuaSurface::is_chunk_generated) to check before attempting to access the chunk.

If [LuaSegment::entity](runtime:LuaSegment::entity) is non-nil, this returns that entity's [LuaEntity::position](runtime:LuaEntity::position). If the entity is `nil`, then reading this field calculates the entity's would-be position if it existed. This can be expensive to compute, so avoid reading this field too often unless it is really necessary.

**Read type:** `MapPosition`

**Optional:** Yes

### orientation

The relative orientation of the segment if one has been assigned. An orientation may not be assigned if the unit's number of body nodes is fewer than [LuaSegmentedUnit::max_body_nodes](runtime:LuaSegmentedUnit::max_body_nodes).

If [LuaSegment::entity](runtime:LuaSegment::entity) is non-nil, this returns that entity's [LuaEntity::orientation](runtime:LuaEntity::orientation). If the entity is `nil`, then reading this field calculates the entity's would-be position if it existed. This can be expensive to compute, so avoid reading this field too often unless it is really necessary.

**Read type:** `RealOrientation`

**Optional:** Yes

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

