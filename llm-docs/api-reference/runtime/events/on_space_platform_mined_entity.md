# on_space_platform_mined_entity

Called after the results of an entity being mined are collected just before the entity is destroyed.

After this event any items in the buffer will be transferred into the platform as if they came from mining the entity.

The buffer inventory is special in that it's only valid during this event and has a dynamic size expanding as more items are transferred into it.

## Event Data

### buffer

**Type:** `LuaInventory`

The temporary inventory that holds the result of mining the entity.

### entity

**Type:** `LuaEntity`

The entity that has been mined.

### name

**Type:** `defines.events`

Identifier of the event

### platform

**Type:** `LuaSpacePlatform`

The platform doing the mining.

### tick

**Type:** `uint32`

Tick the event was generated.

