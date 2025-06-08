# LuaWallControlBehavior

Control behavior for walls.

**Parent:** `LuaControlBehavior`

## Attributes

### circuit_condition

**Type:** `CircuitConditionDefinition`

The circuit condition.

### object_name

**Type:** `string` _(read-only)_

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

### open_gate

**Type:** `boolean`



### output_signal

**Type:** `SignalID`



### read_sensor

**Type:** `boolean`



### valid

**Type:** `boolean` _(read-only)_

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

