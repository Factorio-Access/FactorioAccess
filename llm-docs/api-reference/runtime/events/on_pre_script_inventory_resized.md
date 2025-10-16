# on_pre_script_inventory_resized

Called just before a script inventory is resized.

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

**Type:** `uint32`

The new inventory size.

### old_size

**Type:** `uint32`

The old inventory size.

### player_index

**Type:** `uint32` *(optional)*

If done by console command; the player who ran the command.

### tick

**Type:** `uint32`

Tick the event was generated.

