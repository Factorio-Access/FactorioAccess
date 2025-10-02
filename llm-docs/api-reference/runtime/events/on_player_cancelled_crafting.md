# on_player_cancelled_crafting

Called when a player cancels crafting.

## Event Data

### cancel_count

**Type:** `uint`

The number of crafts that have been cancelled.

### items

**Type:** `LuaInventory`

The crafting items returned to the player's inventory.

### name

**Type:** `defines.events`

Identifier of the event

### player_index

**Type:** `uint`

The player that did the crafting.

### recipe

**Type:** `LuaRecipe`

The recipe that has been cancelled.

### tick

**Type:** `uint`

Tick the event was generated.

