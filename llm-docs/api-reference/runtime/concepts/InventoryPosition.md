# InventoryPosition

**Type:** Table

## Parameters

### count

How many items to insert. Defaults to `1`.

**Type:** `ItemCountType`

**Optional:** Yes

### inventory

The ID of the inventory to insert into.

**Type:** `defines.inventory`

**Required:** Yes

### stack

The stack index of the inventory to insert into. Uses 0-based indexing, in contrast to the 1-based indexing of most other inventory-related functions.

**Type:** `ItemStackIndex`

**Required:** Yes

