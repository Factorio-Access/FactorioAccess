# LuaTile

A single "square" on the map.

## Methods

### cancel_deconstruction

Cancels deconstruction if it is scheduled, does nothing otherwise.

**Parameters:**

- `force` `ForceID`: The force who did the deconstruction order.
- `player` `PlayerIdentification` _(optional)_: The player to set the last_user to if any.

### collides_with

What type of things can collide with this tile?

**Parameters:**

- `layer` `CollisionLayerID`: 

**Returns:**

- `boolean`: 

### get_tile_ghosts

Gets all tile ghosts on this tile.

**Parameters:**

- `force` `ForceID` _(optional)_: Get tile ghosts of this force.

**Returns:**

- ``LuaEntity`[]`: The tile ghosts.

### has_tile_ghost

Does this tile have any tile ghosts on it.

**Parameters:**

- `force` `ForceID` _(optional)_: Check for tile ghosts of this force.

**Returns:**

- `boolean`: 

### order_deconstruction

Orders deconstruction of this tile by the given force.

**Parameters:**

- `force` `ForceID`: The force whose robots are supposed to do the deconstruction.
- `player` `PlayerIdentification` _(optional)_: The player to set the last_user to if any.

**Returns:**

- `LuaEntity`: The deconstructible tile proxy created, if any.

### to_be_deconstructed

Is this tile marked for deconstruction?

**Parameters:**

- `force` `ForceID` _(optional)_: The force whose robots are supposed to do the deconstruction. If not given, checks if to be deconstructed by any force.

**Returns:**

- `boolean`: 

## Attributes

### double_hidden_tile

**Type:** `string` _(read-only)_

The name of the [LuaTilePrototype](runtime:LuaTilePrototype) double hidden under this tile or `nil` if there is no double hidden tile.

During normal gameplay, only [non-mineable](runtime:LuaTilePrototype::mineable_properties) tiles can become double hidden. This can however be circumvented with [LuaSurface::set_double_hidden_tile](runtime:LuaSurface::set_double_hidden_tile).

### hidden_tile

**Type:** `string` _(read-only)_

The name of the [LuaTilePrototype](runtime:LuaTilePrototype) hidden under this tile, if any.

During normal gameplay, only [non-mineable](runtime:LuaTilePrototype::mineable_properties) or [foundation](runtime:LuaTilePrototype::is_foundation) tiles can become hidden. This can however be circumvented with [LuaSurface::set_hidden_tile](runtime:LuaSurface::set_hidden_tile).

### name

**Type:** `string` _(read-only)_

Prototype name of this tile. E.g. `"sand-3"` or `"grass-2"`.

### object_name

**Type:** `string` _(read-only)_

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

### position

**Type:** `TilePosition` _(read-only)_

The position this tile references.

### prototype

**Type:** `LuaTilePrototype` _(read-only)_



### surface

**Type:** `LuaSurface` _(read-only)_

The surface this tile is on.

### valid

**Type:** `boolean` _(read-only)_

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

