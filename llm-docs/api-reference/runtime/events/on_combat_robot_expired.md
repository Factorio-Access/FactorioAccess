# on_combat_robot_expired

Called when a combat robot expires through a lack of energy, or timeout.

## Event Data

### name

**Type:** `defines.events`

Identifier of the event

### owner

**Type:** `LuaEntity` *(optional)*

The entity that owns the robot if any.

### robot

**Type:** `LuaEntity`

### tick

**Type:** `uint`

Tick the event was generated.

