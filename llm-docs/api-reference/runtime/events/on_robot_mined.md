# on_robot_mined

Called when a robot mines an entity.

## Event Data

### item_stack

**Type:** `ItemWithQualityCount`

The entity the robot just picked up.

### name

**Type:** `defines.events`

Identifier of the event

### robot

**Type:** `LuaEntity`

The robot that did the mining.

### tick

**Type:** `uint`

Tick the event was generated.

