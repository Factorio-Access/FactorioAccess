# on_selected_entity_changed

Called after the selected entity changes for a given player.

## Event Data

### last_entity

**Type:** `LuaEntity` *(optional)*

The last selected entity if it still exists and there was one.

### name

**Type:** `defines.events`

Identifier of the event

### player_index

**Type:** `uint`

The player whose selected entity changed.

### tick

**Type:** `uint`

Tick the event was generated.

