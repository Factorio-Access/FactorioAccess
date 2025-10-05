# LightningGraphicsSet

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### shader_configuration

If not empty, enables the lightning shader.

**Type:** Array[`LightningShaderConfiguration`]

**Optional:** Yes

### bolt_half_width

**Type:** `float`

**Optional:** Yes

**Default:** 0.005

### bolt_midpoint_variance

**Type:** `float`

**Optional:** Yes

**Default:** 0.05

### max_bolt_offset

**Type:** `float`

**Optional:** Yes

**Default:** 0.35

### max_fork_probability

**Type:** `float`

**Optional:** Yes

**Default:** 0.9

### min_relative_fork_length

**Type:** `float`

**Optional:** Yes

**Default:** 0.5

### max_relative_fork_length

**Type:** `float`

**Optional:** Yes

**Default:** 0.7

### fork_orientation_variance

**Type:** `float`

**Optional:** Yes

**Default:** 0.05

### fork_intensity_multiplier

Cannot be 1.

**Type:** `float`

**Optional:** Yes

**Default:** 0.7

### relative_cloud_fork_length

**Type:** `float`

**Optional:** Yes

**Default:** 0.2

### cloud_fork_orientation_variance

**Type:** `float`

**Optional:** Yes

**Default:** 0.015

### min_ground_streamer_distance

**Type:** `float`

**Optional:** Yes

**Default:** 2

### max_ground_streamer_distance

**Type:** `float`

**Optional:** Yes

**Default:** 4

### ground_streamer_variance

**Type:** `float`

**Optional:** Yes

**Default:** 1

### cloud_forks

Cannot be 255.

**Type:** `uint8`

**Optional:** Yes

**Default:** 5

### cloud_detail_level

Must be less than or equal to `bolt_detail_level`.

**Type:** `uint8`

**Optional:** Yes

**Default:** 3

### bolt_detail_level

**Type:** `uint8`

**Optional:** Yes

**Default:** 6

### cloud_background

**Type:** `Animation`

**Optional:** Yes

### explosion

**Type:** `AnimationVariations`

**Optional:** Yes

### attractor_hit_animation

**Type:** `Animation`

**Optional:** Yes

### ground_streamers

**Type:** Array[`Animation`]

**Optional:** Yes

### light

**Type:** `LightDefinition`

**Optional:** Yes

### water_reflection

Refer to [EntityPrototype::water_reflection](prototype:EntityPrototype::water_reflection).

**Type:** `WaterReflectionDefinition`

**Optional:** Yes

