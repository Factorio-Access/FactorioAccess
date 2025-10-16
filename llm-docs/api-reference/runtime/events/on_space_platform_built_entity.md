# on_space_platform_built_entity

Called when a space platform builds an entity.

## Event Data

### entity

**Type:** `LuaEntity`

The entity built.

### name

**Type:** `defines.events`

Identifier of the event

### platform

**Type:** `LuaSpacePlatform`

The platform that did the building.

### stack

**Type:** `LuaItemStack`

The item used to do the building.

### tags

**Type:** `Tags` *(optional)*

The tags associated with this entity if any.

### tick

**Type:** `uint32`

Tick the event was generated.

