# LuaTrainStopControlBehavior

Control behavior for train stops.

**Parent:** `LuaGenericOnOffControlBehavior`

## Attributes

### object_name

**Type:** `string` _(read-only)_

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

### priority_signal

**Type:** `SignalID`

The signal to be used by set-priority change priority of the train stop

### read_from_train

**Type:** `boolean`

`true` if the train stop should send the train contents to the circuit network.

### read_stopped_train

**Type:** `boolean`

`true` if the train stop should send the stopped train id to the circuit network.

### read_trains_count

**Type:** `boolean`

`true` if the train stop should send amount of incoming trains to the circuit network.

### send_to_train

**Type:** `boolean`

`true` if the train stop should send the circuit network contents to the train to use.

### set_priority

**Type:** `boolean`

`true` if the priority_signal is used to set a priority of the train stop.

### set_trains_limit

**Type:** `boolean`

`true` if the trains_limit_signal is used to set a limit of trains incoming for train stop.

### stopped_train_signal

**Type:** `SignalID`

The signal that will be sent when using the send-train-id option.

### trains_count_signal

**Type:** `SignalID`

The signal that will be sent when using the read-trains-count option.

### trains_limit_signal

**Type:** `SignalID`

The signal to be used by set-trains-limit to limit amount of incoming trains

### valid

**Type:** `boolean` _(read-only)_

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

