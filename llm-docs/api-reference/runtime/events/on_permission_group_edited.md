# on_permission_group_edited

Called directly after a permission group is edited in some way.

## Event Data

### action

**Type:** `defines.input_action`

The action when the `type` is `"add-permission"` or `"remove-permission"`.

### group

**Type:** `LuaPermissionGroup`

The group being edited.

### name

**Type:** `defines.events`

Identifier of the event

### new_name

**Type:** `string`

The new group name when the `type` is `"rename"`.

### old_name

**Type:** `string`

The old group name when the `type` is `"rename"`.

### other_player_index

**Type:** `uint32`

The other player when the `type` is `"add-player"` or `"remove-player"`.

### player_index

**Type:** `uint32` *(optional)*

The player that did the editing or `nil` if by a mod.

### tick

**Type:** `uint32`

Tick the event was generated.

### type

**Type:** `"add-permission"` | `"remove-permission"` | `"enable-all"` | `"disable-all"` | `"add-player"` | `"remove-player"` | `"rename"`

The edit type.

