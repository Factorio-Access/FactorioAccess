# LuaRailSignalBaseControlBehavior

Control behavior for rail signals and rail chain signals.

**Parent:** [LuaControlBehavior](LuaControlBehavior.md)

## Attributes

### red_signal

**Read type:** `SignalID`

**Write type:** `SignalID`

**Optional:** Yes

### orange_signal

**Read type:** `SignalID`

**Write type:** `SignalID`

**Optional:** Yes

### green_signal

**Read type:** `SignalID`

**Write type:** `SignalID`

**Optional:** Yes

### blue_signal

**Read type:** `SignalID`

**Write type:** `SignalID`

**Optional:** Yes

### close_signal

If this will close the rail signal based off the circuit condition.

**Read type:** `boolean`

**Write type:** `boolean`

### read_signal

If this will read the rail signal state.

**Read type:** `boolean`

**Write type:** `boolean`

### circuit_condition

The circuit condition when controlling the signal through the circuit network.

**Read type:** `CircuitConditionDefinition`

**Write type:** `CircuitConditionDefinition`

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

