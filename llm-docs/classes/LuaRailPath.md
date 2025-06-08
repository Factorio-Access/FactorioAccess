# LuaRailPath

A rail path.

## Attributes

### current

**Type:** `uint` _(read-only)_

The current rail index.

### is_front

**Type:** `boolean` _(read-only)_

If the path goes from the front of the train

### object_name

**Type:** `string` _(read-only)_

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

### rails

**Type:** `LuaCustomTable<`uint`, `LuaEntity`>` _(read-only)_

Array of the rails that this path travels over.

### size

**Type:** `uint` _(read-only)_

The total number of rails in this path.

### total_distance

**Type:** `double` _(read-only)_

The total path distance.

### travelled_distance

**Type:** `double` _(read-only)_

The total distance traveled.

### valid

**Type:** `boolean` _(read-only)_

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

