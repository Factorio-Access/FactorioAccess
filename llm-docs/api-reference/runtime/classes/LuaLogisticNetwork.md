# LuaLogisticNetwork

A single logistic network of a given force on a given surface.

## Attributes

### network_id

The unique logistic network ID.

**Read type:** `uint`

### force

The force this logistic network belongs to.

**Read type:** `LuaForce`

### available_logistic_robots

Number of logistic robots available for a job.

**Read type:** `uint`

### all_logistic_robots

The total number of logistic robots in the network (idle and active + in roboports).

**Read type:** `uint`

### available_construction_robots

Number of construction robots available for a job.

**Read type:** `uint`

### all_construction_robots

The total number of construction robots in the network (idle and active + in roboports).

**Read type:** `uint`

### robot_limit

Maximum number of robots the network can work with. Currently only used for the personal roboport.

**Read type:** `uint`

### cells

All cells in this network.

**Read type:** Array[`LuaLogisticCell`]

### providers

All entities that have logistic provider points in this network.

**Read type:** Array[`LuaEntity`]

### empty_providers

All entities that have empty logistic provider points in this network.

**Read type:** Array[`LuaEntity`]

### requesters

All entities that have logistic requester points in this network.

**Read type:** Array[`LuaEntity`]

### storages

All entities that have logistic storage points in this network.

**Read type:** Array[`LuaEntity`]

### logistic_members

All other entities that have logistic points in this network (inserters mostly).

**Read type:** Array[`LuaEntity`]

### provider_points

All things that have provider points in this network.

**Read type:** Array[`LuaLogisticPoint`]

### passive_provider_points

All passive provider points in this network.

**Read type:** Array[`LuaLogisticPoint`]

### active_provider_points

All active provider points in this network.

**Read type:** Array[`LuaLogisticPoint`]

### empty_provider_points

All things that have empty provider points in this network.

**Read type:** Array[`LuaLogisticPoint`]

### requester_points

All things that have requester points in this network.

**Read type:** Array[`LuaLogisticPoint`]

### storage_points

All things that have storage points in this network.

**Read type:** Array[`LuaLogisticPoint`]

### robots

All robots in this logistic network.

**Read type:** Array[`LuaEntity`]

### construction_robots

All construction robots in this logistic network.

**Read type:** Array[`LuaEntity`]

### logistic_robots

All logistic robots in this logistic network.

**Read type:** Array[`LuaEntity`]

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

## Methods

### get_item_count

Count given or all items in the network or given members.

**Parameters:**

- `item` `ItemWithQualityID` *(optional)* - Item name to count. If not given, gives counts of all items in the network.
- `member` `"storage"` | `"providers"` *(optional)* - Logistic members to check. If not given, gives count in the entire network.

**Returns:**

- `int`

### get_contents

Get item counts for the entire network, similar to how [LuaInventory::get_contents](runtime:LuaInventory::get_contents) does.

**Parameters:**

- `member` `"storage"` | `"providers"` *(optional)* - Logistic members to check. If not given, gives item counts for the entire network.

**Returns:**

- `ItemWithQualityCounts` - List of all items in the network.

### remove_item

Remove items from the logistic network. This will actually remove the items from some logistic chests.

**Parameters:**

- `item` `ItemStackIdentification` - What to remove.
- `members` `"active-provider"` | `"passive-provider"` | `"buffer"` | `"storage"` *(optional)* - Which logistic members to remove from. If not specified, removes from the network in the usual order.

**Returns:**

- `uint` - Number of items removed.

### insert

Insert items into the logistic network. This will actually insert the items into some logistic chests.

**Parameters:**

- `item` `ItemStackIdentification` - What to insert.
- `members` `"storage"` | `"storage-empty"` | `"storage-empty-slot"` | `"requester"` *(optional)* - Which logistic members to insert the items to. `"storage-empty"` inserts into storage chests that are completely empty, `"storage-empty-slot"` inserts into storage chests that have an empty slot. If not specified, inserts items into the logistic network in the usual order.

**Returns:**

- `uint` - Number of items actually inserted.

### find_cell_closest_to

Find logistic cell closest to a given position.

**Parameters:**

- `position` `MapPosition`

**Returns:**

- `LuaLogisticCell` *(optional)* - `nil` if no cell was found.

### select_pickup_point

Find the 'best' logistic point with this item ID and from the given position or from given chest type.

**Parameters:**

- `include_buffers` `boolean` *(optional)* - Whether to consider buffer chests or not. Defaults to false. Only considered if selecting with position.
- `members` `"active-provider"` | `"passive-provider"` | `"buffer"` | `"storage"` *(optional)* - When given, it will find from only the specific type of member. If not specified, selects with normal priorities. Not considered if position is specified.
- `name` `ItemWithQualityID` - Name of the item to pick up.
- `position` `MapPosition` *(optional)* - When given, it will find the storage 'best' storage point from this position.

**Returns:**

- `LuaLogisticPoint` *(optional)* - `nil` if no point was found.

### select_drop_point

Find a logistic point to drop the specific item stack.

**Parameters:**

- `members` `"storage"` | `"storage-empty"` | `"storage-empty-slot"` | `"requester"` *(optional)* - When given, it will find from only the specific type of member. If not specified, selects with normal priorities.
- `stack` `ItemStackIdentification` - Name of the item to drop off.

**Returns:**

- `LuaLogisticPoint` *(optional)* - `nil` if no point was found.

### can_satisfy_request

Can the network satisfy a request for a given item and count.

**Parameters:**

- `count` `uint` *(optional)* - Count to check. Defaults to 1.
- `include_buffers` `boolean` *(optional)* - Should buffers be considered? Defaults to false.
- `item` `ItemWithQualityID` - Item name to check.

**Returns:**

- `boolean` - Whether the network can satisfy the request.

### get_supply_counts

Get the amount of items of the given type indexed by the storage member.

**Parameters:**

- `item` `ItemWithQualityID` - Item name to check.

**Returns:**

- `LogisticsNetworkSupplyCounts`

### get_supply_points

Gets the logistic points with of the given type indexed by the storage member.

**Parameters:**

- `item` `ItemWithQualityID` - Item name to check.

**Returns:**

- `LogisticsNetworkSupplyPoints`

