# ArtilleryFlarePrototype

The entity spawned by the [artillery targeting remote](https://wiki.factorio.com/Artillery_targeting_remote).

**Parent:** [EntityPrototype](EntityPrototype.md)
**Type name:** `artillery-flare`

## Properties

### pictures

Picture variation count and individual frame count must be equal to shadow variation count.

**Type:** `AnimationVariations`

**Optional:** Yes

### life_time

**Type:** `uint16`

**Required:** Yes

### shadows

Shadow variation variation count and individual frame count must be equal to picture variation count.

**Type:** `AnimationVariations`

**Optional:** Yes

### render_layer

**Type:** `RenderLayer`

**Optional:** Yes

**Default:** "object"

### render_layer_when_on_ground

**Type:** `RenderLayer`

**Optional:** Yes

**Default:** "lower-object"

### regular_trigger_effect

**Type:** `TriggerEffect`

**Optional:** Yes

### regular_trigger_effect_frequency

**Type:** `uint32`

**Optional:** Yes

**Default:** 0

### ended_in_water_trigger_effect

**Type:** `TriggerEffect`

**Optional:** Yes

### movement_modifier_when_on_ground

**Type:** `double`

**Optional:** Yes

**Default:** 0.8

### movement_modifier

**Type:** `double`

**Optional:** Yes

**Default:** 1

### creation_shift

**Type:** `Vector`

**Optional:** Yes

### initial_speed

**Type:** `Vector`

**Optional:** Yes

### initial_height

**Type:** `float`

**Optional:** Yes

**Default:** 0

### initial_vertical_speed

**Type:** `float`

**Optional:** Yes

**Default:** 0

### initial_frame_speed

**Type:** `float`

**Optional:** Yes

**Default:** 1

### shots_per_flare

How many artillery shots should be fired at the position of this flare.

**Type:** `uint32`

**Optional:** Yes

**Default:** 1

### early_death_ticks

How long this flare stays alive after `shots_per_flare` amount of shots have been shot at it.

**Type:** `uint32`

**Optional:** Yes

**Default:** 180

### shot_category

Only artillery turrets/wagons whose ammo's [ammo_category](prototype:AmmoItemPrototype::ammo_category) matches this category will shoot at this flare. Defaults to all ammo categories being able to shoot at this flare.

**Type:** `AmmoCategoryID`

**Optional:** Yes

### map_color

**Type:** `Color`

**Required:** Yes

**Overrides parent:** Yes

### selection_priority

The entity with the higher number is selectable before the entity with the lower number.

The value `0` will be treated the same as `nil`.

**Type:** `uint8`

**Optional:** Yes

**Default:** 48

**Overrides parent:** Yes

