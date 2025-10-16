# LuaTrainStopControlBehavior

Control behavior for train stops.

**Parent:** [LuaGenericOnOffControlBehavior](LuaGenericOnOffControlBehavior.md)

## Attributes

### send_to_train

`true` if the train stop should send the circuit network contents to the train to use.

**Read type:** `boolean`

**Write type:** `boolean`

### read_from_train

`true` if the train stop should send the train contents to the circuit network.

**Read type:** `boolean`

**Write type:** `boolean`

### read_stopped_train

`true` if the train stop should send the stopped train id to the circuit network.

**Read type:** `boolean`

**Write type:** `boolean`

### set_trains_limit

`true` if the trains_limit_signal is used to set a limit of trains incoming for train stop.

**Read type:** `boolean`

**Write type:** `boolean`

### read_trains_count

`true` if the train stop should send amount of incoming trains to the circuit network.

**Read type:** `boolean`

**Write type:** `boolean`

### stopped_train_signal

The signal that will be sent when using the send-train-id option.

**Read type:** `SignalID`

**Write type:** `SignalID`

**Optional:** Yes

### trains_count_signal

The signal that will be sent when using the read-trains-count option.

**Read type:** `SignalID`

**Write type:** `SignalID`

**Optional:** Yes

### trains_limit_signal

The signal to be used by set-trains-limit to limit amount of incoming trains

**Read type:** `SignalID`

**Write type:** `SignalID`

**Optional:** Yes

### set_priority

`true` if the priority_signal is used to set a priority of the train stop.

**Read type:** `boolean`

**Write type:** `boolean`

### priority_signal

The signal to be used by set-priority change priority of the train stop

**Read type:** `SignalID`

**Write type:** `SignalID`

**Optional:** Yes

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

