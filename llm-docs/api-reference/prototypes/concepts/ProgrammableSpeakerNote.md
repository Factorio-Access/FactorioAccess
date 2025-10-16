# ProgrammableSpeakerNote

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### name

**Type:** `string`

**Required:** Yes

### sound

Cannot contain aggregation.

One of `sound` or `cyclic_sound` must be defined. Both cannot be defined together.

**Type:** `Sound`

**Optional:** Yes

### cyclic_sound

Cannot contain aggregations.

One of `sound` or `cyclic_sound` must be defined. Both cannot be defined together.

**Type:** `CyclicSound`

**Optional:** Yes

