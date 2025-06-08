# LuaRoboportControlBehavior

Control behavior for roboports.

**Parent:** `LuaControlBehavior`

## Attributes

### available_construction_output_signal

**Type:** `SignalID`



### available_logistic_output_signal

**Type:** `SignalID`



### object_name

**Type:** `string` _(read-only)_

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

### read_items_mode

**Type:** `defines.control_behavior.roboport.read_items_mode`

Selects contents that are to be read from the roboport

### read_logistics

**Type:** `boolean`

Legacy field, please use LuaRoboportControlBehavior::read_items_mode instead. `true` if the roboport should report the logistics network content to the circuit network.

### read_robot_stats

**Type:** `boolean`

`true` if the roboport should report the robot statistics to the circuit network.

### roboport_count_output_signal

**Type:** `SignalID`



### total_construction_output_signal

**Type:** `SignalID`



### total_logistic_output_signal

**Type:** `SignalID`



### valid

**Type:** `boolean` _(read-only)_

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

