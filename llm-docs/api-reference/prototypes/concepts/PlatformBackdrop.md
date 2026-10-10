# PlatformBackdrop

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### position

**Type:** `Vector`

**Optional:** Yes

**Default:** "`{-450.0, -50.0}`"

### radius

**Type:** `float`

**Optional:** Yes

**Default:** 400.0

### planet_surface

Wrapped around the surface of the sphere using equirectangular projection.

**Type:** `EffectTexture`

**Optional:** Yes

### planet_normal

Normal map of the surface deforming local sphere normal.

**Type:** `EffectTexture`

**Optional:** Yes

### planet_reflectivity

Glossiness of the surface in red channel.

**Type:** `EffectTexture`

**Optional:** Yes

### planet_emission

Emissive light added to the surface. Can be disabled on lit side using the `emission_scales_with_shadow` property.

**Type:** `EffectTexture`

**Optional:** Yes

### global_cloud

Cloud mapped over the planet as the surface texture.

**Type:** `EffectTexture`

**Optional:** Yes

### global_cloud_normal

**Type:** `EffectTexture`

**Optional:** Yes

### global_cloud_flow

Flow map distorting the global cloud.

**Type:** `EffectTexture`

**Optional:** Yes

### hero_clouds

Individual Hero Cloud decals over the planet surface. The maximum number is four.

**Type:** Array[`PlatformBackdropHeroCloud`]

**Optional:** Yes

### hero_cloud_texture_1

Sprite or Animation to be referenced by `hero_clouds` definitions with `sprite_index` 1.

**Type:** `Animation`

**Optional:** Yes

### hero_cloud_texture_2

Sprite or Animation to be referenced by `hero_clouds` definitions with `sprite_index` 2.

**Type:** `Animation`

**Optional:** Yes

### hero_cloud_texture_3

Sprite or Animation to be referenced by `hero_clouds` definitions with `sprite_index` 3.

**Type:** `Animation`

**Optional:** Yes

### rotation_seconds

How many seconds it takes for the planet to do one revolution.

**Type:** `float`

**Optional:** Yes

**Default:** 340.0

### planet_axis

Tilt and pitch of the planet axis.

**Type:** `Vector`

**Optional:** Yes

**Default:** "`{-30.0, 20.0}`"

### planet_axis_deviation_amplitude

How much tilt and pitch vary over time.

**Type:** `Vector`

**Optional:** Yes

**Default:** "`{0.0, 0.0}`"

### planet_axis_deviation_seconds

Number of seconds it takes for tilt and pitch to complete one cycle of deviation.

**Type:** `Vector`

**Optional:** Yes

**Default:** "`{609.2, 712.7}`"

### parallax_strength

How strongly the planet moves with camera. `{1.0, 1.0}` means it tracks the starfield. `{0.0, 0.0}` means it tracks the foreground tiles.

**Type:** `Vector`

**Optional:** Yes

**Default:** "`{1.0, 1.0}`"

### flight_approach_speed

Scales the speed at which the planet appears in view when flown towards.

**Type:** `float`

**Optional:** Yes

**Default:** 1.0

### emission_scales_with_shadow

When true only the dark side will receive emission.

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### hero_clouds_are_emissive

When true the hero clouds will add their color to emission as well.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### atmosphere_thickness

Width of the atmosphere layer as portion of the total radius.

**Type:** `float`

**Optional:** Yes

**Default:** 0.02

### atmosphere_color

Color of atmospheric light. Multiplied by 10 in shader.

**Type:** `Color`

**Optional:** Yes

**Default:** "`{0.095, 0.15, 0.19, 1.0}`"

### specular_color

Color of specular light.

**Type:** `Color`

**Optional:** Yes

**Default:** "`{1.0, 1.0, 1.0, 1.0}`"

### light_color

Color of light.

**Type:** `Color`

**Optional:** Yes

**Default:** "`{0.9804, 1.0, 1.0, 1.0}`"

### light_direction

**Type:** `Vector3D`

**Optional:** Yes

**Default:** "`{-1.0, 0.0, 0.5}`"

### atmosphere_ray_light_color_1

Color of dawn side of terminator light. Multiplied by 10 in shader.

**Type:** `Color`

**Optional:** Yes

**Default:** "`{0.5, 0.26665, 0.0, 1.0}`"

### atmosphere_ray_light_color_2

Color of dusk side of terminator light. Multiplied by 10 in shader.

**Type:** `Color`

**Optional:** Yes

**Default:** "`{0.1, 0.08431, 0.05059, 1.0}`"

### surface_normal_intensity

**Type:** `float`

**Optional:** Yes

**Default:** 0.1

### cloud_normal_intensity

**Type:** `float`

**Optional:** Yes

**Default:** 1.0

### specular_intensity

**Type:** `float`

**Optional:** Yes

**Default:** 1.0

### cloudiness

Amount of cloud texture to be used based off of the alpha channel of the cloud texture.

**Type:** `float`

**Optional:** Yes

**Default:** 1

### emission_scalar

**Type:** `float`

**Optional:** Yes

**Default:** 2.0

### light_radius

Perceived size of the light. Also affects size of the specular spot.

**Type:** `float`

**Optional:** Yes

**Default:** 9.9

### light_intensity_contrast

Harshness of the terminator. Functions like atmosphere thickness.

**Type:** `float`

**Optional:** Yes

**Default:** 0.7

### surface_vertical_offset

How far below the atmosphere layer should the surface be.

**Type:** `float`

**Optional:** Yes

**Default:** 0.1

### cloud_vertical_offset

How far below the atmosphere layer should the clouds be.

**Type:** `float`

**Optional:** Yes

**Default:** 0.015

### cloud_flow_intensity

Intensity of the flow map effect. Begins to degenerate at high values.

**Type:** `float`

**Optional:** Yes

**Default:** 0.3

### cloud_flow_seconds

How many seconds it takes the flow effect to loop.

**Type:** `float`

**Optional:** Yes

**Default:** 32.0

### cloud_panning_rate

Rotational speed of the clouds laterally across the planet relative to `rotation_seconds` of the planet. `-1.0` means it counteracts the rotation rate and makes clouds remain in place. `0.0` means it drifts along with planet surface.

**Type:** `float`

**Optional:** Yes

**Default:** 0.0

