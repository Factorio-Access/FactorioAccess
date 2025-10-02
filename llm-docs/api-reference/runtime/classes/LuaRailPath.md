# LuaRailPath

A rail path.

## Attributes

### size

The total number of rails in this path.

**Read type:** `uint`

### current

The current rail index.

**Read type:** `uint`

### total_distance

The total path distance.

**Read type:** `double`

### travelled_distance

The total distance traveled.

**Read type:** `double`

### rails

Array of the rails that this path travels over.

**Read type:** LuaCustomTable[`uint`, `LuaEntity`]

### is_front

If the path goes from the front of the train

**Read type:** `boolean`

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

