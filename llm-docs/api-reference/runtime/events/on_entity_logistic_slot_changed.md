# on_entity_logistic_slot_changed

Called when one of an entity's logistic slots changes.

## Event Data

### entity

**Type:** `LuaEntity`

The entity for whom a logistic slot was changed.

### name

**Type:** `defines.events`

Identifier of the event

### player_index

**Type:** `uint` *(optional)*

The player who changed the slot, or `nil` if changed by script.

### section

**Type:** `LuaLogisticSection`

The section changed.

### slot_index

**Type:** `uint`

The slot index that was changed.

### tick

**Type:** `uint`

Tick the event was generated.

