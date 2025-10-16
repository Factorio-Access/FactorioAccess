# SegmentPrototype

Entity representing an individual segment in a [SegmentedUnitPrototype](prototype:SegmentedUnitPrototype)

**Parent:** [EntityWithOwnerPrototype](EntityWithOwnerPrototype.md)
**Type name:** `segment`
**Visibility:** space_age

## Properties

### dying_sound

The sound to play when the entity dies.

If not specified, [UtilitySounds::segment_dying_sound](prototype:UtilitySounds::segment_dying_sound) is used.

**Type:** `Sound`

**Optional:** Yes

### dying_sound_volume_modifier

**Type:** `float`

**Optional:** Yes

**Default:** 1.0

### animation

The animation to use of the entity.

**Type:** `RotatedAnimation`

**Required:** Yes

### render_layer

The layer to render the entity in.

**Type:** `RenderLayer`

**Optional:** Yes

**Default:** "object"

### forward_overlap

The number of segments ahead of this one that should always be rendered atop this one, giving the illusion that at all orientations, those preceding segments overlap this current segment.

Must be 0 or greater, and the sum of `forward_overlap` and `backward_overlap` must be less than or equal to 4.

**Type:** `uint8`

**Optional:** Yes

**Default:** 0

### backward_overlap

The number of segments behind this one that should always be rendered atop this one, giving the illusion that at all orientations, those following segments overlap this current segment.

Must be 0 or greater, and the sum of `forward_overlap` and `backward_overlap` must be less than or equal to 4.

**Type:** `uint8`

**Optional:** Yes

**Default:** 0

### forward_padding

The number of tiles of spacing to add in front of this segment. Can be negative. Scales with the segment scale when used in a [SegmentEngineSpecification](prototype:SegmentEngineSpecification).

**Type:** `double`

**Optional:** Yes

**Default:** 0

### backward_padding

The number of tiles of spacing to add behind this segment. Can be negative. Scales with the segment scale when used in a [SegmentEngineSpecification](prototype:SegmentEngineSpecification).

**Type:** `double`

**Optional:** Yes

**Default:** 0

### update_effects

The effects to trigger every tick.

**Type:** Array[`TriggerEffectWithCooldown`]

**Optional:** Yes

### update_effects_while_enraged

The effects to trigger every tick while enraged, in addition to `update_effects`.

**Type:** Array[`TriggerEffectWithCooldown`]

**Optional:** Yes

