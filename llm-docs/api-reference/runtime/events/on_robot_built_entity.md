# on_robot_built_entity

Called when a construction robot builds an entity.

## Event Data

### entity

**Type:** `LuaEntity`

The entity built.

### name

**Type:** `defines.events`

Identifier of the event

### robot

**Type:** `LuaEntity`

The robot that did the building.

### stack

**Type:** `LuaItemStack`

The item used to do the building.

### tags

**Type:** `Tags` *(optional)*

The tags associated with this entity if any.

### tick

**Type:** `uint`

Tick the event was generated.

