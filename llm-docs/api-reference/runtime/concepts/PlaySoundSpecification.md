# PlaySoundSpecification

**Type:** Table

## Parameters

### override_sound_type

The volume mixer to play the sound through. Defaults to the default mixer for the given sound type.

**Type:** `SoundType`

**Optional:** Yes

### path

The sound to play.

**Type:** `SoundPath`

**Required:** Yes

### position

Where the sound should be played. If not given, it's played globally on the player's controller's surface.

**Type:** `MapPosition`

**Optional:** Yes

### volume_modifier

The volume of the sound to play. Must be between 0 and 1 inclusive.

**Type:** `double`

**Optional:** Yes

