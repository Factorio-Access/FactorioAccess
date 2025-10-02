# on_player_rotated_entity

Called when the player rotates an entity. This event is only fired when the entity actually changes its orientation -- pressing the rotate key on an entity that can't be rotated won't fire this event.

Entities being flipped will not fire this event, even if the flip involves rotating. See [on_player_flipped_entity](runtime:on_player_flipped_entity).

## Event Data

### entity

**Type:** `LuaEntity`

The rotated entity.

### name

**Type:** `defines.events`

Identifier of the event

### player_index

**Type:** `uint`

### previous_direction

**Type:** `defines.direction`

The previous direction

### tick

**Type:** `uint`

Tick the event was generated.

