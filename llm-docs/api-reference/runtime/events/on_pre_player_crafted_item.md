# on_pre_player_crafted_item

Called when a player queues something to be crafted.

## Event Data

### items

**Type:** `LuaInventory`

The items removed from the players inventory to do the crafting.

### name

**Type:** `defines.events`

Identifier of the event

### player_index

**Type:** `uint`

The player doing the crafting.

### queued_count

**Type:** `uint`

The number of times the recipe is being queued.

### recipe

**Type:** `LuaRecipe`

The recipe being queued.

### tick

**Type:** `uint`

Tick the event was generated.

