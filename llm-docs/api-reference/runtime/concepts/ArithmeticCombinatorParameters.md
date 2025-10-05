# ArithmeticCombinatorParameters

**Type:** Table

## Parameters

### first_constant

Constant to use as the first argument of the operation. Has no effect when `first_signal` is set. Defaults to `0`.

**Type:** `int32`

**Optional:** Yes

### first_signal

First signal to use in an operation. If not specified, the second argument will be the value of `first_constant`.

**Type:** `SignalID`

**Optional:** Yes

### first_signal_networks

Which circuit networks (red/green) to read `first_signal` from. Defaults to both.

**Type:** `CircuitNetworkSelection`

**Optional:** Yes

### operation

When not specified, defaults to `"*"`.

**Type:** `ArithmeticCombinatorParameterOperation`

**Optional:** Yes

### output_signal

Specifies the signal to output.

**Type:** `SignalID`

**Optional:** Yes

### second_constant

Constant to use as the second argument of the operation. Has no effect when `second_signal` is set. Defaults to `0`.

**Type:** `int32`

**Optional:** Yes

### second_signal

Second signal to use in an operation. If not specified, the second argument will be the value of `second_constant`.

**Type:** `SignalID`

**Optional:** Yes

### second_signal_networks

Which circuit networks (red/green) to read `second_signal` from. Defaults to both.

**Type:** `CircuitNetworkSelection`

**Optional:** Yes

