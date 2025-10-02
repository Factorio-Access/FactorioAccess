# PipeConnectionDefinition

**Type:** Table

## Parameters

### connection_category

**Type:** Array[`string`]

**Required:** Yes

### connection_type

**Type:** `PipeConnectionType`

**Required:** Yes

### direction

**Type:** `defines.direction`

**Required:** Yes

### flow_direction

**Type:** `FluidFlowDirection`

**Required:** Yes

### linked_connection_id

Only supplied if `connection_type` is `"linked"`.

**Type:** `uint`

**Optional:** Yes

### max_underground_distance

The maximum tile distance this underground connection can connect.

**Type:** `uint`

**Optional:** Yes

### positions

The 4 cardinal direction connection points for this pipe.

**Type:** Array[`MapPosition`]

**Required:** Yes

