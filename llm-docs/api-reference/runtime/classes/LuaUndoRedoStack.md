# LuaUndoRedoStack

The undo queue for a player. The term `item_index` refers to the index of an undo item in the queue, while `action_index` refers to the index of one of the individual actions that make up an undo item.

Items are added to the undo queue through player actions and Lua methods that emulate player actions like [LuaEntity::order_upgrade](runtime:LuaEntity::order_upgrade).

## Attributes

### player_index

The index of the player to whom this stack belongs to.

**Read type:** `uint32`

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

## Methods

### get_undo_item

Gets an undo item from the undo stack.

**Parameters:**

- `index` `uint32` - The index of the undo item to get, ordered from most recent to oldest.

**Returns:**

- Array[`UndoRedoAction`]

### get_undo_item_count

The number undo items in the undo stack.

**Returns:**

- `uint32`

### remove_undo_item

Removes an undo item from the undo stack.

**Parameters:**

- `index` `uint32` - The index of the undo item to remove, ordered from most recent to oldest.

### remove_undo_action

Removes an undo action from the specified undo item on the undo stack.

**Parameters:**

- `action_index` `uint32` - The index of the undo action to remove.
- `item_index` `uint32` - The index of the undo item to change, ordered from most recent to oldest.

### get_redo_item

Gets an undo item from the redo stack.

**Parameters:**

- `index` `uint32` - The index of the item to get, ordered from most recent to oldest.

**Returns:**

- Array[`UndoRedoAction`]

### get_redo_item_count

The number of undo items in the redo stack.

**Returns:**

- `uint32`

### remove_redo_item

Removes an undo item from the redo stack.

**Parameters:**

- `index` `uint32` - The index of the undo item to remove, ordered from most recent to oldest.

### remove_redo_action

Removes an undo action from the specified undo item on the redo stack.

**Parameters:**

- `action_index` `uint32` - The index of the undo action to remove.
- `item_index` `uint32` - The index of the undo item to change, ordered from most recent to oldest.

### get_undo_tags

Gets all tags for the given undo action.

**Parameters:**

- `action_index` `uint32` - The index of the undo action.
- `item_index` `uint32` - The index of the undo item, ordered from most recent to oldest.

**Returns:**

- `Tags`

### get_undo_tag

Gets the tag with the given name from a specific undo item action, or `nil` if it doesn't exist.

**Parameters:**

- `action_index` `uint32` - The index of the undo action.
- `item_index` `uint32` - The index of the undo item, ordered from most recent to oldest.
- `tag_name` `string` - The name of the tag to get.

**Returns:**

- `AnyBasic`

### set_undo_tag

Sets a new tag with the given name and value on the specified undo item action.

**Parameters:**

- `action_index` `uint32` - The index of the undo action.
- `item_index` `uint32` - The index of the undo item, ordered from most recent to oldest.
- `tag` `AnyBasic` - The contents of the new tag.
- `tag_name` `string` - The name of the tag to set.

### remove_undo_tag

Removes a tag with the given name from the specified undo item.

**Parameters:**

- `action_index` `uint32` - The index of the undo action.
- `item_index` `uint32` - The index of the undo item, ordered from most recent to oldest.
- `tag` `string` - The name of the tag to remove.

**Returns:**

- `boolean` - Whether the tag existed and was successfully removed.

### get_redo_tags

Gets all tags for the given redo action.

**Parameters:**

- `action_index` `uint32` - The index of the redo action.
- `item_index` `uint32` - The index of the redo item, ordered from most recent to oldest.

**Returns:**

- `Tags`

### get_redo_tag

Gets the tag with the given name from a specific redo item action, or `nil` if it doesn't exist.

**Parameters:**

- `action_index` `uint32` - The index of the redo action.
- `item_index` `uint32` - The index of the redo item, ordered from most recent to oldest.
- `tag_name` `string` - The name of the tag to get.

**Returns:**

- `AnyBasic`

### set_redo_tag

Sets a new tag with the given name and value on the specified redo item action.

**Parameters:**

- `action_index` `uint32` - The index of the redo action.
- `item_index` `uint32` - The index of the redo item, ordered from most recent to oldest.
- `tag` `AnyBasic` - The contents of the new tag.
- `tag_name` `string` - The name of the tag to set.

### remove_redo_tag

Removes a tag with the given name from the specified redo item.

**Parameters:**

- `action_index` `uint32` - The index of the redo action.
- `item_index` `uint32` - The index of the redo item, ordered from most recent to oldest.
- `tag` `string` - The name of the tag to remove.

**Returns:**

- `boolean` - Whether the tag existed and was successfully removed.

