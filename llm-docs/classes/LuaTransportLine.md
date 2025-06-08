# LuaTransportLine

One line on a transport belt.

## Methods

### can_insert_at

Can an item be inserted at a given position?

**Parameters:**

- `position` `float`: Where to insert an item.

**Returns:**

- `boolean`: 

### can_insert_at_back

Can an item be inserted at the back of this line?

**Returns:**

- `boolean`: 

### clear

Remove all items from this transport line.

### force_insert_at

Force insert item at a given position. Inserts item onto a transport line. If a position is out of range, it is clamped to a closest valid position on the transport line. Item will be inserted regardless of other items nearby, possibly forcing items to become squashed.

**Parameters:**

- `belt_stack_size` `uint8` _(optional)_: Maximum size of stack created on belt
- `items` `ItemStackIdentification`: Items to insert.
- `position` `float`: Where on the line to insert the items.

### get_contents

Get counts of all items on this line, similar to how [LuaInventory::get_contents](runtime:LuaInventory::get_contents) does.

**Returns:**

- ``ItemWithQualityCounts`[]`: List of all items on this line.

### get_detailed_contents

Get detailed information of items on this line, such as their position.

**Returns:**

- ``DetailedItemOnLine`[]`: 

### get_item_count

Count some or all items on this line, similar to how [LuaInventory::get_item_count](runtime:LuaInventory::get_item_count) does.

**Parameters:**

- `item` `ItemFilter` _(optional)_: If not specified, count all items.

**Returns:**

- `uint`: 

### get_line_item_position

Get a map position related to a position on a transport line.

**Parameters:**

- `position` `float`: Linear position along the transport line. Clamped to the transport line range.

**Returns:**

- `MapPosition`: 

### insert_at

Insert items at a given position.

**Parameters:**

- `belt_stack_size` `uint8` _(optional)_: Maximum size of stack created on belt
- `items` `ItemStackIdentification`: Items to insert.
- `position` `float`: Where on the line to insert the items.

**Returns:**

- `boolean`: Were the items inserted successfully?

### insert_at_back

Insert items at the back of this line.

**Parameters:**

- `belt_stack_size` `uint8` _(optional)_: Maximum size of stack created on belt
- `items` `ItemStackIdentification`: 

**Returns:**

- `boolean`: Were the items inserted successfully?

### line_equals

Returns whether the associated internal transport line of this line is the same as the others associated internal transport line.

This can return true even when the [LuaTransportLine::owner](runtime:LuaTransportLine::owner)s are different (so `this == other` is false), because the internal transport lines can span multiple tiles.

**Parameters:**

- `other` `LuaTransportLine`: 

**Returns:**

- `boolean`: 

### remove_item

Remove some items from this line.

**Parameters:**

- `items` `ItemStackIdentification`: Items to remove.

**Returns:**

- `uint`: Number of items actually removed.

## Attributes

### input_lines

**Type:** ``LuaTransportLine`[]` _(read-only)_

The transport lines that this transport line is fed by or an empty table if none.

### line_length

**Type:** `float` _(read-only)_

Length of the transport line. Items can be inserted at line position from 0 up to returned value

### object_name

**Type:** `string` _(read-only)_

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

### output_lines

**Type:** ``LuaTransportLine`[]` _(read-only)_

The transport lines that this transport line outputs items to or an empty table if none.

### owner

**Type:** `LuaEntity` _(read-only)_

The entity this transport line belongs to.

### total_segment_length

**Type:** `double` _(read-only)_

Total length of segment which consists of this line, all lines in front and lines in the back directly connected.

### valid

**Type:** `boolean` _(read-only)_

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

