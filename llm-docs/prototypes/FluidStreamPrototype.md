# FluidStreamPrototype

Used for example for the handheld flamethrower.

**Parent:** `EntityPrototype`

## Properties

### Mandatory Properties

#### particle_horizontal_speed

**Type:** `float`

Must be larger than 0. `particle_horizontal_speed` has to be greater than `particle_horizontal_speed_deviation`.

#### particle_horizontal_speed_deviation

**Type:** `float`



#### particle_spawn_interval

**Type:** `uint16`

The stream will spawn one particle every `particle_spawn_interval` ticks until the `particle_spawn_timeout` is reached. The first particle will trigger an `initial_action` upon landing. Each particle triggers an `action` upon landing. Particles spawned within a single `particle_spawn_timeout` interval will be connected by a stretched `spine_animation`.

#### particle_vertical_acceleration

**Type:** `float`



### Optional Properties

#### action

**Type:** `Trigger`

Action that is triggered every time a particle lands. Not triggered for the first particle if `initial_action` is non-empty.

#### ground_light

**Type:** `LightDefinition`



#### initial_action

**Type:** `Trigger`

Action that is triggered when the first particle lands.

#### oriented_particle

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': False}`

#### particle

**Type:** `Animation`



#### particle_alpha_per_part

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 1}`

#### particle_buffer_size

**Type:** `uint32`

Number of spawned child particles of the stream. Must be greater than 0 and less than 256.

**Default:** `{'complex_type': 'literal', 'value': 20}`

#### particle_end_alpha

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 1}`

#### particle_fade_out_duration

**Type:** `uint16`

Will be set to 1 by the game if less than 1.

**Default:** `{'complex_type': 'literal', 'value': 65535}`

#### particle_fade_out_threshold

**Type:** `float`

Value between 0 and 1.

**Default:** `{'complex_type': 'literal', 'value': 1}`

#### particle_loop_exit_threshold

**Type:** `float`

Value between 0 and 1.

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### particle_loop_frame_count

**Type:** `uint16`

Will be set to 1 by the game if less than 1.

**Default:** `{'complex_type': 'literal', 'value': 1}`

#### particle_scale_per_part

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 1}`

#### particle_spawn_timeout

**Type:** `uint16`



**Default:** `4 * `particle_spawn_interval``

#### particle_start_alpha

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 1}`

#### particle_start_scale

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 1}`

#### progress_to_create_smoke

**Type:** `float`

The point in the particles projectile arc to start spawning smoke. 0.5 (the default) starts spawning smoke at the halfway point between the source and target.

**Default:** `{'complex_type': 'literal', 'value': 0.5}`

#### shadow

**Type:** `Animation`



#### shadow_scale_enabled

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': False}`

#### smoke_sources

**Type:** ``SmokeSource`[]`

Smoke spawning is controlled by `progress_to_create_smoke`.

#### special_neutral_target_damage

**Type:** `DamageParameters`



#### spine_animation

**Type:** `Animation`



#### stream_light

**Type:** `LightDefinition`



#### target_initial_position_only

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': False}`

#### target_position_deviation

**Type:** `double`



**Default:** `{'complex_type': 'literal', 'value': 0}`

#### width

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 0.5}`

