# WorkingSound

This type is used to produce sound from in-game entities when they are working/idle.

**Type:** `Struct` (see below for attributes) | `Sound`

## Properties

*These properties apply when the value is a struct/table.*

### main_sounds

If this property is defined, all properties inherited from MainSound (and not overridden here) are ignored.

**Type:** `MainSound` | Array[`MainSound`]

**Optional:** Yes

### max_sounds_per_prototype

Sets a maximum limit on how many entities of the same prototype will play their working sound.

Inactive entities without an `idle_sound` don't count towards this limit.

Entities with their working sound fading out don't count towards this limit.

Unused when `persistent` is `true`.

**Type:** `uint8`

**Optional:** Yes

### extra_sounds_ignore_limit

If `true`, entities playing their extra sound don't count towards `max_sounds_per_prototype` limit. 'extra sound' refers to `idle_sound`, `activate_sound` or `deactivate_sound`.

Unused when `persistent` is `true`.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### persistent

When `true`, working sounds for all entities of the same prototype are combined into one.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### use_doppler_shift

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### idle_sound

The sound to be played when the entity is idle. Might not work with all entities that use working_sound.

Unused when `persistent` is `true`.

**Type:** `Sound`

**Optional:** Yes

### activate_sound

Might not work with all entities that use working_sound.

Unused when `persistent` is `true`.

**Type:** `Sound`

**Optional:** Yes

### deactivate_sound

Might not work with all entities that use working_sound.

Unused when `persistent` is `true`.

**Type:** `Sound`

**Optional:** Yes

### sound_accents

Unused when `persistent` is `true`.

**Type:** `SoundAccent` | Array[`SoundAccent`]

**Optional:** Yes

## Examples

```
```
-- refinery
working_sound =
{
  sound = {filename = "__base__/sound/oil-refinery.ogg"},
  idle_sound = {filename = "__base__/sound/idle1.ogg", volume = 0.6},
}
```
```

```
```
-- roboport
working_sound =
{
  sound = {filename = "__base__/sound/roboport-working.ogg", volume = 0.6, audible_distance_modifier = 0.5},
  max_sounds_per_prototype = 3,
  probability = 1 / (5 * 60) -- average pause between the sound is 5 seconds
}
```
```

