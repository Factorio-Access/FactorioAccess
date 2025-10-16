# on_player_pipette

Called when a player invokes the "smart pipette" over an entity.

## Event Data

### item

**Type:** `LuaItemPrototype`

The item put in the cursor

### name

**Type:** `defines.events`

Identifier of the event

### player_index

**Type:** `uint32`

The player

### quality

**Type:** `LuaQualityPrototype`

The item quality put in the cursor

### tick

**Type:** `uint32`

Tick the event was generated.

### used_cheat_mode

**Type:** `boolean`

If cheat mode was used to give a free stack of the item.

