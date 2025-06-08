# LuaPermissionGroups

All permission groups.

## Methods

### create_group

Creates a new permission group.

**Parameters:**

- `name` `string` _(optional)_: 

**Returns:**

- `LuaPermissionGroup`: `nil` if the calling player doesn't have permission to make groups.

### get_group

Gets the permission group with the given name or group ID.

**Parameters:**

- `group` : 

**Returns:**

- `LuaPermissionGroup`: `nil` if there is no matching group.

## Attributes

### groups

**Type:** ``LuaPermissionGroup`[]` _(read-only)_

All of the permission groups.

### object_name

**Type:** `string` _(read-only)_

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

### valid

**Type:** `boolean` _(read-only)_

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

