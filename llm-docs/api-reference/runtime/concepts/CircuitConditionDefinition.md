# CircuitConditionDefinition

**Type:** Table

## Parameters

### comparator

Specifies how the inputs should be compared. If not specified, defaults to `"<"`.

**Type:** `ComparatorString`

**Optional:** Yes

### constant

Constant to compare `first_signal` to. Has no effect when `second_signal` is set. When neither `second_signal` nor `constant` are specified, the effect is as though `constant` were specified with the value `0`.

**Type:** `int`

**Optional:** Yes

### first_signal

Defaults to blank.

**Type:** `SignalID`

**Optional:** Yes

### fulfilled

Whether the condition is currently fulfilled.

**Type:** `boolean`

**Optional:** Yes

### second_signal

What to compare `first_signal` to. If not specified, `first_signal` will be compared to `constant`.

**Type:** `SignalID`

**Optional:** Yes

