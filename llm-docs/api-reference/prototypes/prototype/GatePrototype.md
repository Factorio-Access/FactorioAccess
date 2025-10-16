# GatePrototype

A [gate](https://wiki.factorio.com/Gate).

**Parent:** [EntityWithOwnerPrototype](EntityWithOwnerPrototype.md)
**Type name:** `gate`

## Properties

### vertical_animation

**Type:** `Animation`

**Optional:** Yes

### horizontal_animation

**Type:** `Animation`

**Optional:** Yes

### vertical_rail_animation_left

**Type:** `Animation`

**Optional:** Yes

### vertical_rail_animation_right

**Type:** `Animation`

**Optional:** Yes

### horizontal_rail_animation_left

**Type:** `Animation`

**Optional:** Yes

### horizontal_rail_animation_right

**Type:** `Animation`

**Optional:** Yes

### vertical_rail_base

**Type:** `Animation`

**Optional:** Yes

### horizontal_rail_base

**Type:** `Animation`

**Optional:** Yes

### wall_patch

**Type:** `Animation`

**Optional:** Yes

### opening_speed

**Type:** `float`

**Required:** Yes

### activation_distance

**Type:** `double`

**Required:** Yes

### timeout_to_close

**Type:** `uint32`

**Required:** Yes

### opening_sound

Played when the gate opens.

**Type:** `Sound`

**Optional:** Yes

### closing_sound

Played when the gate closes.

**Type:** `Sound`

**Optional:** Yes

### fadeout_interval

**Type:** `uint32`

**Optional:** Yes

**Default:** 0

### opened_collision_mask

This collision mask is used when the gate is open.

Defaults to the mask from [UtilityConstants::default_collision_masks](prototype:UtilityConstants::default_collision_masks) when indexed by `"gate/opened"`.

**Type:** `CollisionMaskConnector`

**Optional:** Yes

