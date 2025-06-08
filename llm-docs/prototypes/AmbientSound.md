# AmbientSound

This prototype is used to make sound while playing the game. This includes the game's [music](https://store.steampowered.com/app/436090/Factorio__Soundtrack/), composed by Daniel James Taylor.

## Properties

### Mandatory Properties

#### name

**Type:** `string`

Unique textual identification of the prototype.

#### track_type

**Type:** `AmbientSoundType`



#### type

**Type:** `ambient-sound`

Specification of the type of the prototype.

### Optional Properties

#### planet

**Type:** `SpaceLocationID`

Track without a planet is bound to space platforms.

#### sound

**Type:** `Sound`

Static music track.

One of `sound` or `variable_sound` must be defined. Both cannot be defined together.

#### variable_sound

**Type:** `VariableAmbientSoundVariableSound`

Variable music track.

One of `sound` or `variable_sound` must be defined. Both cannot be defined together.

#### weight

**Type:** `double`

Cannot be less than zero.

Cannot be defined if `track_type` is `"hero-track"`.

**Default:** `{'complex_type': 'literal', 'value': 1}`

