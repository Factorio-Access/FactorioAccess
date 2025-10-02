# on_player_flipped_entity

Called when the player flips an entity. This event is only fired when the entity actually changes its orientation or mirroring, so it won't be triggered when pressing the flip keys on an entity that can't be flipped.

This event reflects a change in the [LuaEntity::mirroring](runtime:LuaEntity::mirroring) property.

## Event Data

### entity

**Type:** `LuaEntity`

The flipped entity.

### horizontal

**Type:** `boolean`

The enacted flip. `true` means a horizontal flip, `false` a vertical one.

### name

**Type:** `defines.events`

Identifier of the event

### player_index

**Type:** `uint`

### tick

**Type:** `uint`

Tick the event was generated.

