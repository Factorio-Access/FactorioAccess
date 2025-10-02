# VariableAmbientSoundVariableSound

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### layers

Cannot be empty.

**Type:** Array[`VariableAmbientSoundLayer`]

**Required:** Yes

### intermezzo

**Type:** `Sound`

**Optional:** Yes

### states

The first state is used as the starting state and cannot be an intermezzo state.

Cannot be empty.

**Type:** Array[`VariableAmbientSoundState`]

**Required:** Yes

### length_seconds

Cannot be zero.

**Type:** `uint32`

**Required:** Yes

### alignment_samples

Number of audio signal samples (default sampling frequency is 44.1kHz) defining a time grid. Music samples are aligned with this grid when queued.

**Type:** `uint32`

**Optional:** Yes

**Default:** 12600

