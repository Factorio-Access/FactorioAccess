# VariableAmbientSoundState

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### name

Name has to be unique across all states.

**Type:** `string`

**Required:** Yes

### type

**Type:** `VariableAmbientSoundStateType`

**Optional:** Yes

**Default:** "regular"

### next_state

Cannot be defined if `next_states` is defined.

Doesn't need to be defined if there is only one state.

**Type:** `string`

**Optional:** Yes

### next_states

Cannot be defined if `next_state` is defined.

Cannot be defined if there is only one state.

Cannot be empty.

**Type:** Array[`VariableAmbientSoundNextStateItem`]

**Optional:** Yes

### next_state_trigger

Mandatory if there is more than one state or if the only state transitions to itself.

Can be defined for `regular` states only.

**Type:** `VariableAmbientSoundNextStateTrigger`

**Optional:** Yes

### next_state_layers_finished_layers

List of name of layers used to trigger state transition.

Only loaded, and mandatory if `next_state_trigger` is `"layers-finished"`.

**Type:** Array[`string`]

**Optional:** Yes

### state_duration_seconds

Defines for how long this state will be active.

Mandatory if `next_state_trigger` is `"duration"`.

Optionally loaded for `intermezzo` states.

**Type:** `uint32`

**Optional:** Yes

### layers_properties

Must contain as many items as there is layers in the variable track. The items themselves can be empty. The order of items corresponds to the order of layers as they appear in the prototype definition.

Mandatory for `regular` and `final` states.

Cannot be defined for `intermezzo` or `stop` states.

**Type:** Array[`VariableAmbientSoundLayerStateProperties`]

**Optional:** Yes

### start_pause

Pause before a layer starts playing.

Optionally loaded for `intermezzo` states.

**Type:** `RandomRange`

**Optional:** Yes

### end_pause

Pause before a layer finishes playing. The layer being finished is not counted until the pause finishes.

Optionally loaded for `intermezzo` states.

**Type:** `RandomRange`

**Optional:** Yes

### number_of_enabled_layers

Defines how many layers will be playing. Which layers will be playing is selected randomly.

The minimum cannot be zero, the maximum cannot be greater than the number of layers.

Cannot be defined if any of `layers_properties` define the `enabled` property.

Cannot be defined for `intermezzo` or `stop` states.

**Type:** `RandomRange`

**Optional:** Yes

