# VariableAmbientSoundLayerStateProperties

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### enabled

**Type:** `boolean`

**Optional:** Yes

### variant

Index of a layer's variant.

Cannot be zero.

**Type:** `uint8`

**Optional:** Yes

### sequence_length

Number of samples in a sequence.

The minimum cannot be zero.

Mandatory for layers with `"semi-randomized"` [VariableAmbientSoundCompositionMode](prototype:VariableAmbientSoundCompositionMode).

Applicable for layers with `"randomized"` [VariableAmbientSoundCompositionMode](prototype:VariableAmbientSoundCompositionMode).

Cannot be defined for layers with `"shuffled"` [VariableAmbientSoundCompositionMode](prototype:VariableAmbientSoundCompositionMode).

**Type:** `RandomRange`

**Optional:** Yes

### number_of_repetitions

The number of times a layer repeats itself until it's considered finished. If it's not defined, the layer never finishes on its own. What counts as repetition depends on the [VariableAmbientSoundCompositionMode](prototype:VariableAmbientSoundCompositionMode).

Each sample played is counted as a repetition of `"randomized"` layer.

Repetition of `"semi-randomized"` layer is counted when its sequence is finished.

Repetition of `"shuffled"` layer is counted when all samples play once.

Each sample played is counted as a repetition of `"layer-controlled"` layer.

If `number_of_repetitions` of [VariableAmbientSoundLayer::control_layer](prototype:VariableAmbientSoundLayer::control_layer) of `"layer-controlled"` layer is smaller than `number_of_repetitions` of the controlled layer, `number_of_repetitions` of the control layer is used for the purposes of `pause_between_repetitions` and `end_pause`.

Cannot be zero.

**Type:** `RandomRange` | `ProbabilityTable`

**Optional:** Yes

### start_pause

Pause before a layer starts playing.

**Type:** `RandomRange`

**Optional:** Yes

### pause_between_samples

Pause between individual samples within a sequence.

Cannot be defined for `"randomized"` layers without defining `sequence_length` as well. Alternatively, use `pause_between_repetitions` instead.

Cannot be defined for layers with `sublayer_offset` defined.

**Type:** `RandomRange`

**Optional:** Yes

### pause_between_repetitions

Pause between each repetition of a layer. The repetition is not counted until the pause finishes.

**Type:** `RandomRange`

**Optional:** Yes

### end_pause

Pause before a layer finishes playing. The last repetition and consequently the layer being finished is not counted until the pause finishes.

**Type:** `RandomRange`

**Optional:** Yes

### silence_instead_of_sample_probability

A sample replaced by silence still counts as played for the purposes of sequence count, repetition count, pauses, etc.

Must be in the `[0.0, 1.0]` interval.

**Type:** `float`

**Optional:** Yes

**Default:** 0.0

