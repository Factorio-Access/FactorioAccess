# LuaInventory

A storage of item stacks.

## Attributes

### index

The inventory index this inventory uses, if any.

**Read type:** `defines.inventory`

**Optional:** Yes

### name

Name of this inventory, if any. Names match keys of [defines.inventory](runtime:defines.inventory).

**Read type:** `string`

**Optional:** Yes

### entity_owner

The entity that owns this inventory, if any.

**Read type:** `LuaEntity`

**Optional:** Yes

### player_owner

The player that owns this inventory, if any.

**Read type:** `LuaPlayer`

**Optional:** Yes

### equipment_owner

The equipment that owns this inventory, if any.

**Read type:** `LuaEquipment`

**Optional:** Yes

### mod_owner

The mod that owns this inventory, if any.

**Read type:** `string`

**Optional:** Yes

### weight

Gives a total weight of all items currently in this inventory.

**Read type:** `Weight`

### max_weight

Gives a maximum weight of items that can be inserted into this inventory.

**Read type:** `Weight`

**Optional:** Yes

**Subclasses:** InventoryWithWeightLimit

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

## Methods

### clear

Make this inventory empty.

### can_insert

Can at least some items be inserted?

**Parameters:**

- `items` `ItemStackIdentification` - Items that would be inserted.

**Returns:**

- `boolean` - `true` if at least a part of the given items could be inserted into this inventory.

### insert

Insert items into this inventory.

**Parameters:**

- `items` `ItemStackIdentification` - Items to insert.

**Returns:**

- `uint` - Number of items actually inserted.

### remove

Remove items from this inventory.

**Parameters:**

- `items` `ItemStackIdentification` - Items to remove.

**Returns:**

- `uint` - Number of items actually removed.

### get_item_count

Get the number of all or some items in this inventory.

**Parameters:**

- `item` `ItemWithQualityID` *(optional)* - The item to count. If not specified, count all items.

**Returns:**

- `uint`

### is_empty

Does this inventory contain nothing?

**Returns:**

- `boolean`

### is_full

Is every stack in this inventory full? Ignores stacks blocked by the current bar.

For the input slots of crafting machines that allow counts larger than the item stack size, this may return true even when more items can still be inserted.

**Returns:**

- `boolean`

### get_contents

Get counts of all items in this inventory.

**Returns:**

- `ItemWithQualityCounts` - List of all items in the inventory.

### supports_bar

Does this inventory support a bar? Bar is the draggable red thing, found for example on chests, that limits the portion of the inventory that may be manipulated by machines.

"Supporting a bar" doesn't mean that the bar is set to some nontrivial value. Supporting a bar means the inventory supports having this limit at all. The character's inventory is an example of an inventory without a bar; the wooden chest's inventory is an example of one with a bar.

**Returns:**

- `boolean`

### get_bar

Get the current bar. This is the index at which the red area starts.

Only useable if this inventory supports having a bar.

**Returns:**

- `uint`

### set_bar

Set the current bar.

Only useable if this inventory supports having a bar.

**Parameters:**

- `bar` `uint` *(optional)* - The new limit. Omitting this parameter or passing `nil` will clear the limit.

### supports_filters

If this inventory supports filters.

**Returns:**

- `boolean`

### is_filtered

If this inventory supports filters and has at least 1 filter set.

**Returns:**

- `boolean`

### can_set_filter

If the given inventory slot filter can be set to the given filter.

**Parameters:**

- `filter` `ItemFilter` - The item filter
- `index` `uint` - The item stack index

**Returns:**

- `boolean`

### get_filter

Gets the filter for the given item stack index.

**Parameters:**

- `index` `uint` - The item stack index

**Returns:**

- `ItemFilter` *(optional)* - The current filter or `nil` if none.

### set_filter

Sets the filter for the given item stack index.

Some inventory slots don't allow some filters (gun ammo can't be filtered for non-ammo).

**Parameters:**

- `filter` `ItemFilter` | `nil` - The new filter. `nil` erases any existing filter.
- `index` `uint` - The item stack index.

**Returns:**

- `boolean` - If the filter was allowed to be set.

### find_item_stack

Finds the first LuaItemStack in the inventory that matches the given item name.

**Parameters:**

- `item` `ItemWithQualityID` - The item to find

**Returns:**

- `LuaItemStack` *(optional)* - The first matching stack, or `nil` if none match.
- `uint` *(optional)* - The stack index of the matching stack, if any is found.

### find_empty_stack

Finds the first empty stack. Filtered slots are excluded unless a filter item is given.

**Parameters:**

- `item` `ItemWithQualityID` *(optional)* - If given, empty stacks that are filtered for this item will be included.

**Returns:**

- `LuaItemStack` *(optional)* - The first empty stack, or `nil` if there aren't any empty stacks.
- `uint` *(optional)* - The stack index of the matching stack, if any is found.

### count_empty_stacks

Counts the number of empty stacks.

**Parameters:**

- `include_bar` `boolean` *(optional)* - If true, slots blocked by the current bar will be included. Defaults to true.
- `include_filtered` `boolean` *(optional)* - If true, filtered slots will be included. Defaults to false.

**Returns:**

- `uint`

### get_insertable_count

Gets the number of the given item that can be inserted into this inventory.

This is a "best guess" number; things like assembling machine filtered slots, module slots, items with durability, and items with mixed health will cause the result to be inaccurate. The main use for this is in checking how many of a basic item can fit into a basic inventory.

This accounts for the 'bar' on the inventory.

**Parameters:**

- `item` `ItemWithQualityID` - The item to check.

**Returns:**

- `uint`

### sort_and_merge

Sorts and merges the items in this inventory.

### resize

Resizes the inventory.

Items in slots beyond the new capacity are deleted.

Only inventories created by [LuaGameScript::create_inventory](runtime:LuaGameScript::create_inventory) can be resized.

**Parameters:**

- `size` `uint16` - New size of a inventory

### destroy

Destroys this inventory.

Only inventories created by [LuaGameScript::create_inventory](runtime:LuaGameScript::create_inventory) can be destroyed this way.

## Operators

### index

The indexing operator.

### length

Get the number of slots in this inventory.

