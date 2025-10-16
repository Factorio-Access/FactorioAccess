# PrintSettings

**Type:** Table

## Parameters

### color

Color of the message to print. Defaults to white.

**Type:** `Color`

**Optional:** Yes

### game_state

If set to false, message will not be part of game state and will disappear from output console after save-load. Defaults to `true`.

**Type:** `boolean`

**Optional:** Yes

### skip

Condition when to skip adding message. Defaults to `defines.print_skip.if_redundant`.

**Type:** `defines.print_skip`

**Optional:** Yes

### sound

If a sound should be emitted for this message. Defaults to `defines.print_sound.use_player_settings`.

**Type:** `defines.print_sound`

**Optional:** Yes

### sound_path

The sound to play. If not given, [UtilitySounds::console_message](prototype:UtilitySounds::console_message) will be used instead.

**Type:** `SoundPath`

**Optional:** Yes

### volume_modifier

The volume of the sound to play. Must be between 0 and 1 inclusive. Defaults to 1.

**Type:** `float`

**Optional:** Yes

