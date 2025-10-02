# DeciderCombinatorOutput

**Type:** Table

## Parameters

### constant

The value to output when not copying input. Defaults to `1`.

**Type:** `int`

**Optional:** Yes

### copy_count_from_input

Defaults to `true`. When `false`, will output the value from `constant` for the given `output_signal`.

**Type:** `boolean`

**Optional:** Yes

### networks

Sets which input network to read the value of `signal` from if `copy_count_from_input` is `true`. Defaults to both.

**Type:** `CircuitNetworkSelection`

**Optional:** Yes

### signal

Specifies a signal to output.

**Type:** `SignalID`

**Required:** Yes

