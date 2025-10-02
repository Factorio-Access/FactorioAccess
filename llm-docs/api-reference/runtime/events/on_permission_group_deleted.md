# on_permission_group_deleted

Called directly after a permission group is deleted.

## Event Data

### group_name

**Type:** `string`

The group that was deleted.

### id

**Type:** `uint`

The group id that was deleted.

### name

**Type:** `defines.events`

Identifier of the event

### player_index

**Type:** `uint` *(optional)*

The player doing the deletion or `nil` if by a mod.

### tick

**Type:** `uint`

Tick the event was generated.

