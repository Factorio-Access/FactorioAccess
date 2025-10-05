# on_entity_renamed

Called after an entity has been renamed either by the player or through script.

## Event Data

### by_script

**Type:** `boolean`

### entity

**Type:** `LuaEntity`

### name

**Type:** `defines.events`

Identifier of the event

### old_name

**Type:** `string`

### player_index

**Type:** `uint32` *(optional)*

If by_script is true this will not be included.

### tick

**Type:** `uint32`

Tick the event was generated.

