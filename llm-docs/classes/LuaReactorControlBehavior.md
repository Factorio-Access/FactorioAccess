# LuaReactorControlBehavior

Control behavior for Reactor

**Parent:** `LuaControlBehavior`

## Attributes

### object_name

**Type:** `string` _(read-only)_

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

### read_fuel

**Type:** `boolean`

If this will read fuel inventory and currently burning fuel

### read_temperature

**Type:** `boolean`

If this will read temperature of the reactor

### temperature_signal

**Type:** `SignalID`



### valid

**Type:** `boolean` _(read-only)_

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

