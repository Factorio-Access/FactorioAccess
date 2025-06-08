# FluidTurretPrototype

A turret that uses [fluid](prototype:FluidPrototype) as ammunition.

**Parent:** `TurretPrototype`

## Properties

### Mandatory Properties

#### activation_buffer_ratio

**Type:** `FluidAmount`

Before an turret that was out of fluid ammunition is able to fire again, the `fluid_buffer_size` must fill to this proportion.

#### attack_parameters

**Type:** `StreamAttackParameters`

Requires ammo_type in attack_parameters.

#### fluid_box

**Type:** `FluidBox`



#### fluid_buffer_input_flow

**Type:** `FluidAmount`



#### fluid_buffer_size

**Type:** `FluidAmount`



#### turret_base_has_direction

**Type:** `True`

Always `true`, forcing the turret's collision box to be affected by its rotation.

### Optional Properties

#### attacking_muzzle_animation_shift

**Type:** `AnimatedVector`



#### ending_attack_muzzle_animation_shift

**Type:** `AnimatedVector`



#### enough_fuel_indicator_light

**Type:** `LightDefinition`



#### enough_fuel_indicator_picture

**Type:** `Sprite4Way`



#### folded_muzzle_animation_shift

**Type:** `AnimatedVector`



#### folding_muzzle_animation_shift

**Type:** `AnimatedVector`



#### muzzle_animation

**Type:** `Animation`



#### muzzle_light

**Type:** `LightDefinition`



#### not_enough_fuel_indicator_light

**Type:** `LightDefinition`



#### not_enough_fuel_indicator_picture

**Type:** `Sprite4Way`



#### out_of_ammo_alert_icon

**Type:** `Sprite`

The sprite will be drawn on top of fluid turrets that are out of fluid ammunition. If the `out_of_ammo_alert_icon` is not set, [UtilitySprites::fluid_icon](prototype:UtilitySprites::fluid_icon) will be used instead.

#### prepared_muzzle_animation_shift

**Type:** `AnimatedVector`



#### preparing_muzzle_animation_shift

**Type:** `AnimatedVector`



#### starting_attack_muzzle_animation_shift

**Type:** `AnimatedVector`



