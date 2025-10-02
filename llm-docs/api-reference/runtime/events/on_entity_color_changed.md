# on_entity_color_changed

Called after an entity has been recolored either by the player or through script.

Automatic recoloring due to [LuaPlayer::color](runtime:LuaPlayer::color) will not raise events, as that is a separate mechanism.

## Event Data

### entity

**Type:** `LuaEntity`

The entity that was recolored.

### name

**Type:** `defines.events`

Identifier of the event

### tick

**Type:** `uint`

Tick the event was generated.

