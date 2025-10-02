# on_script_inventory_resized

Called just after a script inventory is resized.

## Event Data

### inventory

**Type:** `LuaInventory`

### mod

**Type:** `string`

The mod that did the resizing. This will be `"core"` if done by console command or scenario script.

### name

**Type:** `defines.events`

Identifier of the event

### new_size

**Type:** `uint`

The new inventory size.

### old_size

**Type:** `uint`

The old inventory size.

### overflow_inventory

**Type:** `LuaInventory`

Any items which didn't fit into the new inventory size.

### player_index

**Type:** `uint` *(optional)*

If done by console command; the player who ran the command.

### tick

**Type:** `uint`

Tick the event was generated.

