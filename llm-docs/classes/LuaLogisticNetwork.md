# LuaLogisticNetwork

A single logistic network of a given force on a given surface.

## Methods

### can_satisfy_request

Can the network satisfy a request for a given item and count.

**Parameters:**

- `count` `uint` _(optional)_: Count to check. Defaults to 1.
- `include_buffers` `boolean` _(optional)_: Should buffers be considered? Defaults to false.
- `item` `ItemWithQualityID`: Item name to check.

**Returns:**

- `boolean`: Whether the network can satisfy the request.

### find_cell_closest_to

Find logistic cell closest to a given position.

**Parameters:**

- `position` `MapPosition`: 

**Returns:**

- `LuaLogisticCell`: `nil` if no cell was found.

### get_contents

Get item counts for the entire network, similar to how [LuaInventory::get_contents](runtime:LuaInventory::get_contents) does.

**Returns:**

- ``ItemWithQualityCounts`[]`: List of all items in the network.

### get_item_count

Count given or all items in the network or given members.

**Parameters:**

- `item` `ItemWithQualityID` _(optional)_: Item name to count. If not given, gives counts of all items in the network.
- `member`  _(optional)_: Logistic members to check. If not given, gives count in the entire network.

**Returns:**

- `int`: 

### get_supply_counts

Get the amount of items of the given type indexed by the storage member.

**Parameters:**

- `item` `ItemWithQualityID`: Item name to check.

**Returns:**

- `LogisticsNetworkSupplyCounts`: 

### get_supply_points

Gets the logistic points with of the given type indexed by the storage member.

**Parameters:**

- `item` `ItemWithQualityID`: Item name to check.

**Returns:**

- `LogisticsNetworkSupplyPoints`: 

### insert

Insert items into the logistic network. This will actually insert the items into some logistic chests.

**Parameters:**

- `item` `ItemStackIdentification`: What to insert.
- `members`  _(optional)_: Which logistic members to insert the items to. `"storage-empty"` inserts into storage chests that are completely empty, `"storage-empty-slot"` inserts into storage chests that have an empty slot. If not specified, inserts items into the logistic network in the usual order.

**Returns:**

- `uint`: Number of items actually inserted.

### remove_item

Remove items from the logistic network. This will actually remove the items from some logistic chests.

**Parameters:**

- `item` `ItemStackIdentification`: What to remove.
- `members`  _(optional)_: Which logistic members to remove from. If not specified, removes from the network in the usual order.

**Returns:**

- `uint`: Number of items removed.

### select_drop_point

Find a logistic point to drop the specific item stack.

**Parameters:**

- `members`  _(optional)_: When given, it will find from only the specific type of member. If not specified, selects with normal priorities.
- `stack` `ItemStackIdentification`: Name of the item to drop off.

**Returns:**

- `LuaLogisticPoint`: `nil` if no point was found.

### select_pickup_point

Find the 'best' logistic point with this item ID and from the given position or from given chest type.

**Parameters:**

- `include_buffers` `boolean` _(optional)_: Whether to consider buffer chests or not. Defaults to false. Only considered if selecting with position.
- `members`  _(optional)_: When given, it will find from only the specific type of member. If not specified, selects with normal priorities. Not considered if position is specified.
- `name` `ItemWithQualityID`: Name of the item to pick up.
- `position` `MapPosition` _(optional)_: When given, it will find the storage 'best' storage point from this position.

**Returns:**

- `LuaLogisticPoint`: `nil` if no point was found.

## Attributes

### active_provider_points

**Type:** ``LuaLogisticPoint`[]` _(read-only)_

All active provider points in this network.

### all_construction_robots

**Type:** `uint` _(read-only)_

The total number of construction robots in the network (idle and active + in roboports).

### all_logistic_robots

**Type:** `uint` _(read-only)_

The total number of logistic robots in the network (idle and active + in roboports).

### available_construction_robots

**Type:** `uint` _(read-only)_

Number of construction robots available for a job.

### available_logistic_robots

**Type:** `uint` _(read-only)_

Number of logistic robots available for a job.

### cells

**Type:** ``LuaLogisticCell`[]` _(read-only)_

All cells in this network.

### construction_robots

**Type:** ``LuaEntity`[]` _(read-only)_

All construction robots in this logistic network.

### empty_provider_points

**Type:** ``LuaLogisticPoint`[]` _(read-only)_

All things that have empty provider points in this network.

### empty_providers

**Type:** ``LuaEntity`[]` _(read-only)_

All entities that have empty logistic provider points in this network.

### force

**Type:** `LuaForce` _(read-only)_

The force this logistic network belongs to.

### logistic_members

**Type:** ``LuaEntity`[]` _(read-only)_

All other entities that have logistic points in this network (inserters mostly).

### logistic_robots

**Type:** ``LuaEntity`[]` _(read-only)_

All logistic robots in this logistic network.

### network_id

**Type:** `uint` _(read-only)_

The unique logistic network ID.

### object_name

**Type:** `string` _(read-only)_

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

### passive_provider_points

**Type:** ``LuaLogisticPoint`[]` _(read-only)_

All passive provider points in this network.

### provider_points

**Type:** ``LuaLogisticPoint`[]` _(read-only)_

All things that have provider points in this network.

### providers

**Type:** ``LuaEntity`[]` _(read-only)_

All entities that have logistic provider points in this network.

### requester_points

**Type:** ``LuaLogisticPoint`[]` _(read-only)_

All things that have requester points in this network.

### requesters

**Type:** ``LuaEntity`[]` _(read-only)_

All entities that have logistic requester points in this network.

### robot_limit

**Type:** `uint` _(read-only)_

Maximum number of robots the network can work with. Currently only used for the personal roboport.

### robots

**Type:** ``LuaEntity`[]` _(read-only)_

All robots in this logistic network.

### storage_points

**Type:** ``LuaLogisticPoint`[]` _(read-only)_

All things that have storage points in this network.

### storages

**Type:** ``LuaEntity`[]` _(read-only)_

All entities that have logistic storage points in this network.

### valid

**Type:** `boolean` _(read-only)_

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

