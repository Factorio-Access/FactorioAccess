# on_pre_permission_group_deleted

Called directly before a permission group is deleted.

## Event Data

### group

**Type:** `LuaPermissionGroup`

The group to be deleted.

### name

**Type:** `defines.events`

Identifier of the event

### player_index

**Type:** `uint32` *(optional)*

The player doing the deletion or `nil` if by a mod.

### tick

**Type:** `uint32`

Tick the event was generated.

