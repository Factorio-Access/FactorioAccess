# FluidStreamPrototype

Used for example for the handheld flamethrower.

**Parent:** [EntityPrototype](EntityPrototype.md)
**Type name:** `stream`

## Properties

### particle_spawn_interval

The stream will spawn one particle every `particle_spawn_interval` ticks until the `particle_spawn_timeout` is reached. The first particle will trigger an `initial_action` upon landing. Each particle triggers an `action` upon landing. Particles spawned within a single `particle_spawn_timeout` interval will be connected by a stretched `spine_animation`.

**Type:** `uint16`

**Required:** Yes

### particle_horizontal_speed

Must be larger than 0. `particle_horizontal_speed` has to be greater than `particle_horizontal_speed_deviation`.

**Type:** `float`

**Required:** Yes

### particle_horizontal_speed_deviation

**Type:** `float`

**Required:** Yes

### particle_vertical_acceleration

**Type:** `float`

**Required:** Yes

### initial_action

Action that is triggered when the first particle lands.

**Type:** `Trigger`

**Optional:** Yes

### action

Action that is triggered every time a particle lands. Not triggered for the first particle if `initial_action` is non-empty.

**Type:** `Trigger`

**Optional:** Yes

### special_neutral_target_damage

**Type:** `DamageParameters`

**Optional:** Yes

### width

**Type:** `float`

**Optional:** Yes

**Default:** 0.5

### particle_buffer_size

Number of spawned child particles of the stream. Must be greater than 0 and less than 256.

**Type:** `uint32`

**Optional:** Yes

**Default:** 20

### particle_spawn_timeout

**Type:** `uint16`

**Optional:** Yes

**Default:** "4 * `particle_spawn_interval`"

### particle_start_alpha

**Type:** `float`

**Optional:** Yes

**Default:** 1

### particle_end_alpha

**Type:** `float`

**Optional:** Yes

**Default:** 1

### particle_start_scale

**Type:** `float`

**Optional:** Yes

**Default:** 1

### particle_alpha_per_part

**Type:** `float`

**Optional:** Yes

**Default:** 1

### particle_scale_per_part

**Type:** `float`

**Optional:** Yes

**Default:** 1

### particle_fade_out_threshold

Value between 0 and 1.

**Type:** `float`

**Optional:** Yes

**Default:** 1

### particle_loop_exit_threshold

Value between 0 and 1.

**Type:** `float`

**Optional:** Yes

**Default:** 0

### particle_loop_frame_count

Will be set to 1 by the game if less than 1.

**Type:** `uint16`

**Optional:** Yes

**Default:** 1

### particle_fade_out_duration

Will be set to 1 by the game if less than 1.

**Type:** `uint16`

**Optional:** Yes

**Default:** 65535

### spine_animation

**Type:** `Animation`

**Optional:** Yes

### particle

**Type:** `Animation`

**Optional:** Yes

### shadow

**Type:** `Animation`

**Optional:** Yes

### smoke_sources

Smoke spawning is controlled by `progress_to_create_smoke`.

**Type:** Array[`SmokeSource`]

**Optional:** Yes

### progress_to_create_smoke

The point in the particles projectile arc to start spawning smoke. 0.5 (the default) starts spawning smoke at the halfway point between the source and target.

**Type:** `float`

**Optional:** Yes

**Default:** 0.5

### stream_light

**Type:** `LightDefinition`

**Optional:** Yes

### ground_light

**Type:** `LightDefinition`

**Optional:** Yes

### target_position_deviation

**Type:** `double`

**Optional:** Yes

**Default:** 0

### oriented_particle

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### shadow_scale_enabled

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### target_initial_position_only

**Type:** `boolean`

**Optional:** Yes

**Default:** False

