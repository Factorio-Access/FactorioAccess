# LuaCombinatorControlBehavior

**Parent:** [LuaControlBehavior](LuaControlBehavior.md)

**Abstract:** Yes

## Attributes

### signals_last_tick

The circuit network signals sent by this combinator last tick.

**Read type:** Array[`Signal`]

## Methods

### get_signal_last_tick

Gets the value of a specific signal sent by this combinator behavior last tick or `nil` if the signal didn't exist.

**Parameters:**

- `signal` `SignalID` - The signal to get

**Returns:**

- `int` *(optional)*

