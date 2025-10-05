# PipeConnection

A single pipe connection for a given fluidbox.

**Type:** Table

## Parameters

### connection_type

**Type:** `PipeConnectionType`

**Required:** Yes

### flow_direction

**Type:** `FluidFlowDirection`

**Required:** Yes

### position

The absolute position of this connection within the entity.

**Type:** `MapPosition`

**Required:** Yes

### target

The connected fluidbox, if any.

**Type:** `LuaFluidBox`

**Optional:** Yes

### target_fluidbox_index

The index of the target fluidbox, if any.

**Type:** `uint32`

**Optional:** Yes

### target_pipe_connection_index

The index of the target fluidbox pipe connection, if any.

**Type:** `uint32`

**Optional:** Yes

### target_position

The absolute position of the connection's intended target.

**Type:** `MapPosition`

**Required:** Yes

