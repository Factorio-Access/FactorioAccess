# LuaSpacePlatform

A space platform.

## Attributes

### force

The force of this space platform.

**Read type:** `LuaForce`

### name

The name of this space platform.

**Read type:** `string`

**Write type:** `string`

### index

The unique index of this space platform.

**Read type:** `uint`

### space_location

The space location this space platform is stopped at or `nil`.

Write operation requires a valid space location and will cancel pending item requests.

**Read type:** `LuaSpaceLocationPrototype`

**Write type:** `LuaSpaceLocationPrototype`

**Optional:** Yes

### last_visited_space_location

The space location this space platform previously went through or stopped at.

**Read type:** `LuaSpaceLocationPrototype`

**Optional:** Yes

### space_connection

The space connection this space platform is traveling through or `nil`.

Write operation requires a valid space connection and it sets the distance to 0.5.

**Read type:** `LuaSpaceConnectionPrototype`

**Write type:** `LuaSpaceConnectionPrototype`

**Optional:** Yes

### distance

The point on space connection this platform is at or `nil`.

It is represented as a number in range `[0, 1]`, with 0 being [LuaSpaceConnectionPrototype::from](runtime:LuaSpaceConnectionPrototype::from) and 1 being [LuaSpaceConnectionPrototype::to](runtime:LuaSpaceConnectionPrototype::to).

**Read type:** `double`

**Write type:** `double`

**Optional:** Yes

### state

The current state of this space platform.

**Read type:** `defines.space_platform_state`

### paused

When `true`, the platform has paused thrust and does not advance its schedule.

**Read type:** `boolean`

**Write type:** `boolean`

### starter_pack

The starter pack used to create this space platform.

**Read type:** `ItemIDAndQualityIDPair`

**Optional:** Yes

### surface

The surface that belongs to this platform (if it has been created yet).

**Read type:** `LuaSurface`

### hub

The hub on this platform. `nil` if the platform has not had the starter pack applied or hub was destroyed but the platform not yet deleted.

If the hub is destroyed the platform will be deleted at the end of the tick but is otherwise valid to use until that point.

**Read type:** `LuaEntity`

**Optional:** Yes

### schedule

This platform's current schedule, if any. Set to `nil` to clear.

The schedule can't be changed by modifying the returned table. Instead, changes must be made by assigning a new table to this attribute.

**Read type:** `PlatformSchedule`

**Write type:** `PlatformSchedule`

**Optional:** Yes

### speed

**Read type:** `double`

**Write type:** `double`

### scheduled_for_deletion

If this platform is scheduled for deletion.

Returns how many ticks are left before the platform will be deleted. 0 if not scheduled for deletion.

**Read type:** `uint`

### weight

The total weight of the platform.

**Read type:** `Weight`

### damaged_tiles

The damaged tiles on this platform.

**Read type:** Array[Table (see below for parameters)]

### ejected_items

All items that have been thrown overboard.

**Read type:** Array[`EjectedItem`]

### hidden

If this platform is hidden from the remote view surface list.

**Read type:** `boolean`

**Write type:** `boolean`

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

## Methods

### destroy

Schedules this space platform for deletion.

**Parameters:**

- `ticks` `uint` *(optional)* - The number of ticks from now when this platform will be deleted.

### cancel_deletion

Cancels deletion of this space platform if it was scheduled for deletion.

### apply_starter_pack

Applies the starter pack for this platform if it hasn't already been applied.

**Returns:**

- `LuaEntity` *(optional)* - The platform hub.

### damage_tile

Damages the given tile if it exists, the chunk is generated, and it is a platform foundation tile.

**Parameters:**

- `cause` `LuaEntity` *(optional)*
- `damage` `float`
- `position` `TilePosition`

### repair_tile

Repairs the given tile if it's damaged.

**Parameters:**

- `amount` `float` *(optional)*
- `position` `TilePosition`

### destroy_asteroid_chunks

Destroys all asteroid chunks from the given area. If no area and no position are given, then the entire surface is searched.

**Parameters:**

- `area` `BoundingBox` *(optional)*
- `invert` `boolean` *(optional)* - If the filters should be inverted.
- `limit` `uint` *(optional)*
- `name` `AsteroidChunkID` | Array[`AsteroidChunkID`] *(optional)*
- `position` `MapPosition` *(optional)*

### create_asteroid_chunks

Creates the given asteroid chunks on this platform.

**Parameters:**

- `asteroid_chunks` Array[`AsteroidChunk`]

### find_asteroid_chunks_filtered

Find asteroid chunks of a given name in a given area.

If no filters are given, returns all asteroid chunks in the search area. If multiple filters are specified, returns only asteroid chunks matching every given filter. If no area and no position are given, the entire surface is searched.

**Parameters:**

- `area` `BoundingBox` *(optional)*
- `invert` `boolean` *(optional)* - If the filters should be inverted.
- `limit` `uint` *(optional)*
- `name` `AsteroidChunkID` | Array[`AsteroidChunkID`] *(optional)*
- `position` `MapPosition` *(optional)*

**Returns:**

- Array[`AsteroidChunk`]

**Examples:**

```
game.forces.player.platforms[1].find_asteroid_chunks_filtered{area = {{-10, -10}, {10, 10}}, name = "carbonic-asteroid"} -- gets all asteroids with the given name in the rectangle
game.forces.player.platforms[1].find_asteroid_chunks_filtered{area = {{-10, -10}, {10, 10}}, limit = 5}  -- gets the first 5 asteroid chunks in the rectangle
```

### can_leave_current_location

Returns `true` when the space platform isn't waiting on any delivery from the planet.

**Returns:**

- `boolean`

### get_schedule

**Returns:**

- `LuaSchedule`

### eject_item

Ejects an item into space on this space platform.

If a LuaItemStack is provided, the actual item is ejected and removed from the source.

**Parameters:**

- `item` `ItemStackIdentification`
- `movement` `Vector` - When inserters drop items into space, the [InserterPrototype::insert_position](prototype:InserterPrototype::insert_position) rotated to the inserter direction is used.
- `position` `MapPosition`

### clear_ejected_items

Removes all ejected items from this space platform.

