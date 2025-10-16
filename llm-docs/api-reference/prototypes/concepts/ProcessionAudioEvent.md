# ProcessionAudioEvent

Controls sounds during procession.

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### type

**Type:** `ProcessionAudioEventType`

**Required:** Yes

### usage

Has to be defined unless the type is "stop-looped-sound".

**Type:** `ProcessionAudioUsage`

**Optional:** Yes

### audio

Has to be defined unless the type is "stop-looped-sound".

**Type:** `ProcessionAudio`

**Optional:** Yes

### loop_id

Has to be defined unless the type is "play-sound".

**Type:** `uint32`

**Optional:** Yes

