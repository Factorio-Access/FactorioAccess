# on_build_base_arrived

Called when a [defines.command.build_base](runtime:defines.command.build_base) command reaches its destination, and before building starts.

## Event Data

### group

**Type:** `LuaCommandable` *(optional)*

The unit group the command was assigned to.

### name

**Type:** `defines.events`

Identifier of the event

### tick

**Type:** `uint`

Tick the event was generated.

### unit

**Type:** `LuaEntity` *(optional)*

The unit the command was assigned to.

