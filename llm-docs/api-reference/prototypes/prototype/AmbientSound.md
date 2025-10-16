# AmbientSound

This prototype is used to make sound while playing the game. This includes the game's [music](https://store.steampowered.com/app/436090/Factorio__Soundtrack/), composed by Daniel James Taylor.

**Type name:** `ambient-sound`

## Examples

```
{
  type = "ambient-sound",
  name = "world-ambience-4",
  track_type = "interlude",
  sound =
  {
    filename = "__base__/sound/ambient/world-ambience-4.ogg",
    volume = 1.2
  }
}
```

## Properties

### type

Specification of the type of the prototype.

**Type:** `"ambient-sound"`

**Required:** Yes

### name

Unique textual identification of the prototype.

**Type:** `string`

**Required:** Yes

### weight

Cannot be less than zero.

Cannot be defined if `track_type` is `"hero-track"`.

**Type:** `double`

**Optional:** Yes

**Default:** 1

### track_type

**Type:** `AmbientSoundType`

**Required:** Yes

### planet

Track without a planet is bound to space platforms.

**Type:** `SpaceLocationID`

**Optional:** Yes

### sound

Static music track.

One of `sound` or `variable_sound` must be defined. Both cannot be defined together.

**Type:** `Sound`

**Optional:** Yes

### variable_sound

Variable music track.

One of `sound` or `variable_sound` must be defined. Both cannot be defined together.

**Type:** `VariableAmbientSoundVariableSound`

**Optional:** Yes

