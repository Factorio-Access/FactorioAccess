# on_permission_group_added

Called directly after a permission group is added.

## Event Data

### group

**Type:** `LuaPermissionGroup`

The group added.

### name

**Type:** `defines.events`

Identifier of the event

### player_index

**Type:** `uint` *(optional)*

The player that added the group or `nil` if by a mod.

### tick

**Type:** `uint`

Tick the event was generated.

