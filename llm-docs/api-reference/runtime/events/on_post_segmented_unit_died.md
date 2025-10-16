# on_post_segmented_unit_died

Called after a segmented unit dies.

## Event Data

### damage_type

**Type:** `LuaDamagePrototype` *(optional)*

The damage type that did the killing if any.

### force

**Type:** `LuaForce` *(optional)*

The force that did the killing if any.

### name

**Type:** `defines.events`

Identifier of the event

### prototype

**Type:** `LuaEntityPrototype`

The prototype of the unit that died.

### quality

**Type:** `LuaQualityPrototype`

The quality of the unit that died.

### segments

**Type:** `PostSegmentDiedData`

Information about each of the unit's individual segments when it died.

### surface_index

**Type:** `uint32`

The surface the entity was on.

### tick

**Type:** `uint32`

Tick the event was generated.

### unit_number

**Type:** `uint32`

The unit number of the unit that died.

