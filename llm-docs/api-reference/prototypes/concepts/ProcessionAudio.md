# ProcessionAudio

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### type

**Type:** `ProcessionAudioType`

**Required:** Yes

### sound

Mandatory if `type` is `"sound"`.

**Type:** `Sound`

**Optional:** Yes

### looped_sound

Mandatory if `type` is `"looped-sound"`.

**Type:** `InterruptibleSound`

**Optional:** Yes

### catalogue_id

Mandatory if `type` is `"pod_catalogue"` or `type` is `"location_catalogue"`.

**Type:** `uint32`

**Optional:** Yes

