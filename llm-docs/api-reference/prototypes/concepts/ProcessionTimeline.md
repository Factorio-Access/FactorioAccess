# ProcessionTimeline

A wrapper for a collection of [ProcessionLayers](prototype:ProcessionLayer).

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### duration

The time to play this cutscene regardless of individual layer durations.

**Type:** `MapTick`

**Required:** Yes

### special_action_tick

Time to initiate usage specific actions:

- Ascending animation will detach from rocket on this tick.

- Descending animation will request hatch to be opened.

**Type:** `MapTick`

**Optional:** Yes

**Default:** "1/2 of duration"

### draw_switch_tick

During procession, the pod will at some point start being drawn above the rest of the game:

- When ascending this tick will go from world to above.

- When descending this tick will go from above to world.

Notably, LUT override won't be applied until the pod is drawn above the game.

**Type:** `MapTick`

**Optional:** Yes

**Default:** "1/2 of duration"

### intermezzo_min_duration

The real duration of the intermezzo playing will be above this value.

**Type:** `MapTick`

**Optional:** Yes

**Default:** 0

### intermezzo_max_duration

The real duration of the intermezzo playing will be below this value.

**Type:** `MapTick`

**Optional:** Yes

**Default:** 0

### layers

**Type:** Array[`ProcessionLayer`]

**Required:** Yes

### audio_events

**Type:** Array[`ProcessionAudioEvent`]

**Optional:** Yes

