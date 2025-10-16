# LuaRoboportControlBehavior

Control behavior for roboports.

**Parent:** [LuaControlBehavior](LuaControlBehavior.md)

## Attributes

### read_items_mode

Selects contents that are to be read from the roboport

**Read type:** `defines.control_behavior.roboport.read_items_mode`

**Write type:** `defines.control_behavior.roboport.read_items_mode`

### read_logistics

Legacy field, please use LuaRoboportControlBehavior::read_items_mode instead. `true` if the roboport should report the logistics network content to the circuit network.

**Read type:** `boolean`

**Write type:** `boolean`

### read_robot_stats

`true` if the roboport should report the robot statistics to the circuit network.

**Read type:** `boolean`

**Write type:** `boolean`

### available_logistic_output_signal

**Read type:** `SignalID`

**Write type:** `SignalID`

**Optional:** Yes

### total_logistic_output_signal

**Read type:** `SignalID`

**Write type:** `SignalID`

**Optional:** Yes

### available_construction_output_signal

**Read type:** `SignalID`

**Write type:** `SignalID`

**Optional:** Yes

### total_construction_output_signal

**Read type:** `SignalID`

**Write type:** `SignalID`

**Optional:** Yes

### roboport_count_output_signal

**Read type:** `SignalID`

**Write type:** `SignalID`

**Optional:** Yes

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

