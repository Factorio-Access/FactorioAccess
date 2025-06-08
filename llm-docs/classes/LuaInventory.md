# LuaInventory

A storage of item stacks.

## Methods

### can_insert

Can at least some items be inserted?

**Parameters:**

- `items` `ItemStackIdentification`: Items that would be inserted.

**Returns:**

- `boolean`: `true` if at least a part of the given items could be inserted into this inventory.

### can_set_filter

If the given inventory slot filter can be set to the given filter.

**Parameters:**

- `filter` `ItemFilter`: The item filter
- `index` `uint`: The item stack index

**Returns:**

- `boolean`: 

### clear

Make this inventory empty.

### count_empty_stacks

Counts the number of empty stacks.

**Parameters:**

- `include_bar` `boolean` _(optional)_: If true, slots blocked by the current bar will be included. Defaults to true.
- `include_filtered` `boolean` _(optional)_: If true, filtered slots will be included. Defaults to false.

**Returns:**

- `uint`: 

### destroy

Destroys this inventory.

Only inventories created by [LuaGameScript::create_inventory](runtime:LuaGameScript::create_inventory) can be destroyed this way.

### find_empty_stack

Finds the first empty stack. Filtered slots are excluded unless a filter item is given.

**Parameters:**

- `item` `ItemWithQualityID` _(optional)_: If given, empty stacks that are filtered for this item will be included.

**Returns:**

- `LuaItemStack`: The first empty stack, or `nil` if there aren't any empty stacks.
- `uint`: The stack index of the matching stack, if any is found.

### find_item_stack

Finds the first LuaItemStack in the inventory that matches the given item name.

**Parameters:**

- `item` `ItemWithQualityID`: The item to find

**Returns:**

- `LuaItemStack`: The first matching stack, or `nil` if none match.
- `uint`: The stack index of the matching stack, if any is found.

### get_bar

Get the current bar. This is the index at which the red area starts.

Only useable if this inventory supports having a bar.

**Returns:**

- `uint`: 

### get_contents

Get counts of all items in this inventory.

**Returns:**

- ``ItemWithQualityCounts`[]`: List of all items in the inventory.

### get_filter

Gets the filter for the given item stack index.

**Parameters:**

- `index` `uint`: The item stack index

**Returns:**

- `ItemFilter`: The current filter or `nil` if none.

### get_insertable_count

Gets the number of the given item that can be inserted into this inventory.

This is a "best guess" number; things like assembling machine filtered slots, module slots, items with durability, and items with mixed health will cause the result to be inaccurate. The main use for this is in checking how many of a basic item can fit into a basic inventory.

This accounts for the 'bar' on the inventory.

**Parameters:**

- `item` `ItemWithQualityID`: The item to check.

**Returns:**

- `uint`: 

### get_item_count

Get the number of all or some items in this inventory.

**Parameters:**

- `item` `ItemWithQualityID` _(optional)_: The item to count. If not specified, count all items.

**Returns:**

- `uint`: 

### insert

Insert items into this inventory.

**Parameters:**

- `items` `ItemStackIdentification`: Items to insert.

**Returns:**

- `uint`: Number of items actually inserted.

### is_empty

Does this inventory contain nothing?

**Returns:**

- `boolean`: 

### is_filtered

If this inventory supports filters and has at least 1 filter set.

**Returns:**

- `boolean`: 

### is_full

Is every stack in this inventory full? Ignores stacks blocked by the current bar.

**Returns:**

- `boolean`: 

### remove

Remove items from this inventory.

**Parameters:**

- `items` `ItemStackIdentification`: Items to remove.

**Returns:**

- `uint`: Number of items actually removed.

### resize

Resizes the inventory.

Items in slots beyond the new capacity are deleted.

Only inventories created by [LuaGameScript::create_inventory](runtime:LuaGameScript::create_inventory) can be resized.

**Parameters:**

- `size` `uint16`: New size of a inventory

### set_bar

Set the current bar.

Only useable if this inventory supports having a bar.

**Parameters:**

- `bar` `uint` _(optional)_: The new limit. Omitting this parameter will clear the limit.

### set_filter

Sets the filter for the given item stack index.

Some inventory slots don't allow some filters (gun ammo can't be filtered for non-ammo).

**Parameters:**

- `filter` : The new filter. `nil` erases any existing filter.
- `index` `uint`: The item stack index.

**Returns:**

- `boolean`: If the filter was allowed to be set.

### sort_and_merge

Sorts and merges the items in this inventory.

### supports_bar

Does this inventory support a bar? Bar is the draggable red thing, found for example on chests, that limits the portion of the inventory that may be manipulated by machines.

"Supporting a bar" doesn't mean that the bar is set to some nontrivial value. Supporting a bar means the inventory supports having this limit at all. The character's inventory is an example of an inventory without a bar; the wooden chest's inventory is an example of one with a bar.

**Returns:**

- `boolean`: 

### supports_filters

If this inventory supports filters.

**Returns:**

- `boolean`: 

## Attributes

### entity_owner

**Type:** `LuaEntity` _(read-only)_

The entity that owns this inventory, if any.

### equipment_owner

**Type:** `LuaEquipment` _(read-only)_

The equipment that owns this inventory, if any.

### index

**Type:** `defines.inventory` _(read-only)_

The inventory index this inventory uses, if any.

### mod_owner

**Type:** `string` _(read-only)_

The mod that owns this inventory, if any.

### name

**Type:** `string` _(read-only)_

Name of this inventory, if any. Names match keys of [defines.inventory](runtime:defines.inventory).

### object_name

**Type:** `string` _(read-only)_

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

### player_owner

**Type:** `LuaPlayer` _(read-only)_

The player that owns this inventory, if any.

### valid

**Type:** `boolean` _(read-only)_

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

