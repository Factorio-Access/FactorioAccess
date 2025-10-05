# on_player_crafted_item

Called when the player finishes crafting an item. This event fires just before the results are inserted into the player's inventory, not when the crafting is queued (see [on_pre_player_crafted_item](runtime:on_pre_player_crafted_item)).

## Event Data

### item_stack

**Type:** `LuaItemStack`

The item that has been crafted.

### name

**Type:** `defines.events`

Identifier of the event

### player_index

**Type:** `uint32`

The player doing the crafting.

### recipe

**Type:** `LuaRecipe`

The recipe used to craft this item.

### tick

**Type:** `uint32`

Tick the event was generated.

