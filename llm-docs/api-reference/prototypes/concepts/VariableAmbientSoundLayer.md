# VariableAmbientSoundLayer

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### name

Name has to be unique across all layers.

**Type:** `string`

**Required:** Yes

### variants

Cannot be empty.

Samples within a layer are the [Sound::variations](prototype:Sound::variations).

Number of samples must be the same across all variants.

Samples cannot have variable volume and all samples must have the same default volume.

**Type:** Array[`Sound`]

**Required:** Yes

### composition_mode

**Type:** `VariableAmbientSoundCompositionMode`

**Required:** Yes

### control_layer

Name of a layer which controls this layer, a layer cannot control itself.

Only loaded, and mandatory if `composition_mode` is `"layer-controlled"`.

**Type:** `string`

**Optional:** Yes

### control_layer_sample_mapping

Defines a mapping between controlling layer's samples and this (controlled) layer's samples. The number of items in the mapping must be the same as the number of samples in the controlling layer. Item in the mapping with index N defines which samples of this layer can play when the sample N is playing in the controlling layer.

Only loaded, and mandatory if `composition_mode` is `"layer-controlled"`.

**Type:** Array[Array[`uint8`]]

**Optional:** Yes

### has_start_sample

If `true`, the first of [Sound::variations](prototype:Sound::variations) is played at the start of a sequence. The start sample counts towards the [VariableAmbientSoundLayerStateProperties::sequence_length](prototype:VariableAmbientSoundLayerStateProperties::sequence_length)

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### has_end_sample

If `true`, the last of [Sound::variations](prototype:Sound::variations) is played at the end of a sequence (if the sequence is long enough). The end sample counts towards the [VariableAmbientSoundLayerStateProperties::sequence_length](prototype:VariableAmbientSoundLayerStateProperties::sequence_length).

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### number_of_sublayers

If greater than one, samples are composed in overlapping sub-layers, offset from each other.

If greater than one, one of `sublayer_starting_offset` or `sublayer_offset` must be defined. Both cannot be defined together.

Cannot be defined for layers with `"shuffled"` `composition_mode`.

Cannot be zero.

**Type:** `uint8`

**Optional:** Yes

**Default:** 1

### sublayer_starting_offset

Specifies starting offset of the second sub-layer.

Only loaded if `number_of_sublayers` is greater than one.

Cannot be defined together with `sublayer_offset`.

The minimum of [RandomRange](prototype:RandomRange) variant cannot be zero.

**Type:** `RandomRange` | `ProbabilityTable`

**Optional:** Yes

### sublayer_offset

Specifies offset between two sub-layers' samples.

This implicitly dictates the sample lengths as two sub-layer offsets.

Only loaded if `number_of_sublayers` is greater than one.

Cannot be defined together with `sublayer_starting_offset`.

The minimum of [RandomRange](prototype:RandomRange) variant cannot be zero.

**Type:** `RandomRange` | `ProbabilityTable`

**Optional:** Yes

### sample_length

Explicitly defines sample lengths. The whole sample is played when this is not specified.

Cannot be defined together with `sublayer_offset`.

The minimum cannot be zero.

**Type:** `RandomRange`

**Optional:** Yes

