# LuaSpacePlatform

A space platform.

## Methods

### apply_starter_pack

Applies the starter pack for this platform if it hasn't already been applied.

**Returns:**

- `LuaEntity`: The platform hub.

### can_leave_current_location

Returns `true` when the space platform isn't waiting on any delivery from the planet.

**Returns:**

- `boolean`: 

### cancel_deletion

Cancels deletion of this space platform if it was scheduled for deletion.

### clear_ejected_items

Removes all ejected items from this space platform.

### create_asteroid_chunks

Creates the given asteroid chunks on this platform.

**Parameters:**

- `asteroid_chunks` ``AsteroidChunk`[]`: 

### damage_tile

Damages the given tile if it exists, the chunk is generated, and it is a platform foundation tile.

**Parameters:**

- `cause` `LuaEntity` _(optional)_: 
- `damage` `float`: 
- `position` `TilePosition`: 

### destroy

Schedules this space platform for deletion.

**Parameters:**

- `ticks` `uint` _(optional)_: The number of ticks from now when this platform will be deleted.

### destroy_asteroid_chunks

Destroys all asteroid chunks from the given area. If no area and no position are given, then the entire surface is searched.

**Parameters:**

- `area` `BoundingBox` _(optional)_: 
- `invert` `boolean` _(optional)_: If the filters should be inverted.
- `limit` `uint` _(optional)_: 
- `name`  _(optional)_: 
- `position` `MapPosition` _(optional)_: 

### eject_item

Ejects an item into space on this space platform.

If a LuaItemStack is provided, the actual item is ejected and removed from the source.

**Parameters:**

- `item` `ItemStackIdentification`: 
- `movement` `Vector`: When inserters drop items into space, the [InserterPrototype::insert_position](prototype:InserterPrototype::insert_position) rotated to the inserter direction is used.
- `position` `MapPosition`: 

### find_asteroid_chunks_filtered

Find asteroid chunks of a given name in a given area.

If no filters are given, returns all asteroid chunks in the search area. If multiple filters are specified, returns only asteroid chunks matching every given filter. If no area and no position are given, the entire surface is searched.

**Parameters:**

- `area` `BoundingBox` _(optional)_: 
- `invert` `boolean` _(optional)_: If the filters should be inverted.
- `limit` `uint` _(optional)_: 
- `name`  _(optional)_: 
- `position` `MapPosition` _(optional)_: 

**Returns:**

- ``AsteroidChunk`[]`: 

### get_schedule



**Returns:**

- `LuaSchedule`: 

### repair_tile

Repairs the given tile if it's damaged.

**Parameters:**

- `amount` `float` _(optional)_: 
- `position` `TilePosition`: 

## Attributes

### damaged_tiles

**Type:** ``unknown`[]` _(read-only)_

The damaged tiles on this platform.

### distance

**Type:** `double`

The point on space connection this platform is at or `nil`.

It is represented as a number in range `[0, 1]`, with 0 being [LuaSpaceConnectionPrototype::from](runtime:LuaSpaceConnectionPrototype::from) and 1 being [LuaSpaceConnectionPrototype::to](runtime:LuaSpaceConnectionPrototype::to).

### ejected_items

**Type:** ``EjectedItem`[]` _(read-only)_

All items that have been thrown overboard.

### force

**Type:** `LuaForce` _(read-only)_

The force of this space platform.

### hub

**Type:** `LuaEntity` _(read-only)_

The hub on this platform. `nil` if the platform has not had the starter pack applied or hub was destroyed but the platform not yet deleted.

If the hub is destroyed the platform will be deleted at the end of the tick but is otherwise valid to use until that point.

### index

**Type:** `uint` _(read-only)_

The unique index of this space platform.

### last_visited_space_location

**Type:** `LuaSpaceLocationPrototype` _(read-only)_

The space location this space platform previously went through or stopped at.

### name

**Type:** `string`

The name of this space platform.

### object_name

**Type:** `string` _(read-only)_

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

### paused

**Type:** `boolean`

When `true`, the platform has paused thrust and does not advance its schedule.

### schedule

**Type:** `PlatformSchedule`

This platform's current schedule, if any. Set to `nil` to clear.

The schedule can't be changed by modifying the returned table. Instead, changes must be made by assigning a new table to this attribute.

### scheduled_for_deletion

**Type:** `uint` _(read-only)_

If this platform is scheduled for deletion.

Returns how many ticks are left before the platform will be deleted. 0 if not scheduled for deletion.

### space_connection

**Type:** `LuaSpaceConnectionPrototype`

The space connection this space platform is traveling through or `nil`.

Write operation requires a valid space connection and it sets the distance to 0.5.

### space_location

**Type:** `LuaSpaceLocationPrototype`

The space location this space platform is stopped at or `nil`.

Write operation requires a valid space location and will cancel pending item requests.

### speed

**Type:** `double`



### starter_pack

**Type:** `ItemIDAndQualityIDPair` _(read-only)_

The starter pack used to create this space platform.

### state

**Type:** `defines.space_platform_state` _(read-only)_

The current state of this space platform.

### surface

**Type:** `LuaSurface` _(read-only)_

The surface that belongs to this platform (if it has been created yet).

### valid

**Type:** `boolean` _(read-only)_

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

### weight

**Type:** `uint` _(read-only)_

The total weight of the platform.

