# on_segmented_unit_created

Called when a segmented unit is created for any reason.

## Event Data

### cause

**Type:** `defines.segmented_unit_created_cause`

The reason that the segmented unit was created.

### clone_source

**Type:** `LuaSegmentedUnit` *(optional)*

If the new segmented unit was cloned, the segmented unit from which the new unit was cloned.

### name

**Type:** `defines.events`

Identifier of the event

### segmented_unit

**Type:** `LuaSegmentedUnit`

The segmented unit that was created.

### tick

**Type:** `uint32`

Tick the event was generated.

