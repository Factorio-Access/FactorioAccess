# on_built_entity

Called when player builds something.

## Event Data

### consumed_items

**Type:** `LuaInventory`

A temporary inventory containing all items that the game used to build the entity. This inventory is temporary and thus invalidated after the event.

### entity

**Type:** `LuaEntity`

The entity that was built.

### name

**Type:** `defines.events`

Identifier of the event

### player_index

**Type:** `uint`

The player who did the building.

### tags

**Type:** `Tags` *(optional)*

The tags associated with this entity if any.

### tick

**Type:** `uint`

Tick the event was generated.

