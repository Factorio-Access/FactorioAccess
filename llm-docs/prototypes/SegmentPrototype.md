# SegmentPrototype

Entity representing an individual segment in a [SegmentedUnitPrototype](prototype:SegmentedUnitPrototype)

**Parent:** `EntityWithOwnerPrototype`

## Properties

### Mandatory Properties

#### animation

**Type:** `RotatedAnimation`

The animation to use of the entity.

### Optional Properties

#### backward_overlap

**Type:** `uint8`

The number of segments behind this one that should always be rendered atop this one, giving the illusion that at all orientations, those following segments overlap this current segment.

Must be 0 or greater, and the sum of `forward_overlap` and `backward_overlap` must be less than or equal to 4.

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### backward_padding

**Type:** `double`

The number of tiles of spacing to add behind this segment. Can be negative. Scales with the segment scale when used in a [SegmentEngineSpecification](prototype:SegmentEngineSpecification).

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### dying_sound

**Type:** `Sound`

The sound to play when the entity dies.

If not specified, [UtilitySounds::segment_dying_sound](prototype:UtilitySounds::segment_dying_sound) is used.

#### dying_sound_volume_modifier

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 1.0}`

#### forward_overlap

**Type:** `uint8`

The number of segments ahead of this one that should always be rendered atop this one, giving the illusion that at all orientations, those preceding segments overlap this current segment.

Must be 0 or greater, and the sum of `forward_overlap` and `backward_overlap` must be less than or equal to 4.

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### forward_padding

**Type:** `double`

The number of tiles of spacing to add in front of this segment. Can be negative. Scales with the segment scale when used in a [SegmentEngineSpecification](prototype:SegmentEngineSpecification).

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### render_layer

**Type:** `RenderLayer`

The layer to render the entity in.

**Default:** `{'complex_type': 'literal', 'value': 'object'}`

#### update_effects

**Type:** ``TriggerEffectWithCooldown`[]`

The effects to trigger every tick.

#### update_effects_while_enraged

**Type:** ``TriggerEffectWithCooldown`[]`

The effects to trigger every tick while enraged, in addition to `update_effects`.

