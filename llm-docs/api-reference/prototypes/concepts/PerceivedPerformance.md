# PerceivedPerformance

Not all prototypes that use this type are affected by all properties.

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### minimum

Affects animation speed.

Must be less than or equal to `maximum`.

**Type:** `double`

**Optional:** Yes

**Default:** 0

### maximum

Affects animation speed.

**Type:** `double`

**Optional:** Yes

**Default:** "Max double"

### performance_to_activity_rate

Affects [MainSound](prototype:MainSound) if [MainSound::match_progress_to_activity](prototype:MainSound::match_progress_to_activity), [MainSound::match_volume_to_activity](prototype:MainSound::match_volume_to_activity) or [MainSound::match_speed_to_activity](prototype:MainSound::match_speed_to_activity) is `true`.

**Type:** `double`

**Optional:** Yes

**Default:** 1

