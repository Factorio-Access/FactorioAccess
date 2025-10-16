# TrainStopFilter

**Type:** Table

## Parameters

### force

ForceID the train stop must have to pass

**Type:** `ForceID`

**Optional:** Yes

### is_connected_to_rail

Checks if train stop has a rail next to it.

**Type:** `boolean`

**Optional:** Yes

### is_disabled

If train stop is disabled by a control behavior

**Type:** `boolean`

**Optional:** Yes

### is_full

Checks if train stop is full (trains count >= trains limit or disabled) or not full.

**Type:** `boolean`

**Optional:** Yes

### limit_set_by_control_behavior

If train stop has limit set by control behavior

**Type:** `boolean`

**Optional:** Yes

### station_name

Train stop must belong to given station name to pass

**Type:** `string` | Array[`string`]

**Optional:** Yes

### surface

Surface the train stop must be on in order to pass

**Type:** `SurfaceIdentification`

**Optional:** Yes

### type

If given, only train stops of this type will pass

**Type:** `EntityID` | Array[`EntityID`]

**Optional:** Yes

