# UnitPrototype

Entity that moves around and attacks players, for example [biters and spitters](https://wiki.factorio.com/Enemies#Creatures).

**Parent:** `EntityWithOwnerPrototype`

## Properties

### Mandatory Properties

#### attack_parameters

**Type:** `AttackParameters`

Requires animation in attack_parameters. Requires ammo_type in attack_parameters.

#### distance_per_frame

**Type:** `float`

How fast the `run_animation` frames are advanced. The animations are advanced animation_speed frames per `distance_per_frame` that the unit moves.

`frames_advanced = (distance_moved ÷ distance_per_frame) * animation_speed`

#### distraction_cooldown

**Type:** `uint32`



#### movement_speed

**Type:** `float`

Movement speed of the unit in the world, in tiles per tick. Must be equal to or greater than 0.

#### run_animation

**Type:** `RotatedAnimation`



#### vision_distance

**Type:** `double`

Max is 100.

Note: Setting to 50 or above can lead to undocumented behavior of individual units creating groups on their own when attacking or being attacked.

### Optional Properties

#### absorptions_to_join_attack

**Type:** `dictionary<`AirbornePollutantID`, `float`>`



#### affected_by_tiles

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': False}`

#### ai_settings

**Type:** `UnitAISettings`



#### allow_run_time_change_of_is_military_target

**Type:** `False`

If this is true, this entities `is_military_target property` can be changed runtime (on the entity, not on the prototype itself).

**Default:** `{'complex_type': 'literal', 'value': False}`

#### alternative_attacking_frame_sequence

**Type:** `UnitAlternativeFrameSequence`



#### can_open_gates

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': False}`

#### dying_sound

**Type:** `Sound`

The sound file to play when entity dies.

#### has_belt_immunity

**Type:** `boolean`

If the unit is immune to movement by belts.

**Default:** `{'complex_type': 'literal', 'value': False}`

#### is_military_target

**Type:** `True`

Whether this prototype should be a high priority target for enemy forces. See [Military units and structures](https://wiki.factorio.com/Military_units_and_structures).

**Default:** `{'complex_type': 'literal', 'value': True}`

#### light

**Type:** `LightDefinition`



#### max_pursue_distance

**Type:** `double`



**Default:** `{'complex_type': 'literal', 'value': 50}`

#### min_pursue_time

**Type:** `uint32`

In ticks.

**Default:** `{'complex_type': 'literal', 'value': 600}`

#### move_while_shooting

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': False}`

#### radar_range

**Type:** `uint32`



**Default:** `{'complex_type': 'literal', 'value': 0}`

#### render_layer

**Type:** `RenderLayer`



**Default:** `{'complex_type': 'literal', 'value': 'object'}`

#### rotation_speed

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 0.025}`

#### running_sound_animation_positions

**Type:** ``float`[]`

Only loaded if `walking_sound` is defined.

#### spawning_time_modifier

**Type:** `double`



**Default:** `{'complex_type': 'literal', 'value': 1}`

#### walking_sound

**Type:** `Sound`



#### warcry

**Type:** `Sound`

A sound the unit makes when it sets out to attack.

