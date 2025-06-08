# GatePrototype

A [gate](https://wiki.factorio.com/Gate).

**Parent:** `EntityWithOwnerPrototype`

## Properties

### Mandatory Properties

#### activation_distance

**Type:** `double`



#### opening_speed

**Type:** `float`



#### timeout_to_close

**Type:** `uint32`



### Optional Properties

#### closing_sound

**Type:** `Sound`

Played when the gate closes.

#### fadeout_interval

**Type:** `uint32`



**Default:** `{'complex_type': 'literal', 'value': 0}`

#### horizontal_animation

**Type:** `Animation`



#### horizontal_rail_animation_left

**Type:** `Animation`



#### horizontal_rail_animation_right

**Type:** `Animation`



#### horizontal_rail_base

**Type:** `Animation`



#### opened_collision_mask

**Type:** `CollisionMaskConnector`

This collision mask is used when the gate is open.

Defaults to the mask from [UtilityConstants::default_collision_masks](prototype:UtilityConstants::default_collision_masks) when indexed by `"gate/opened"`.

#### opening_sound

**Type:** `Sound`

Played when the gate opens.

#### vertical_animation

**Type:** `Animation`



#### vertical_rail_animation_left

**Type:** `Animation`



#### vertical_rail_animation_right

**Type:** `Animation`



#### vertical_rail_base

**Type:** `Animation`



#### wall_patch

**Type:** `Animation`



