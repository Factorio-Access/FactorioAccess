# FluidTurretPrototype

A turret that uses [fluid](prototype:FluidPrototype) as ammunition.

**Parent:** [TurretPrototype](TurretPrototype.md)
**Type name:** `fluid-turret`

## Properties

### fluid_buffer_size

**Type:** `FluidAmount`

**Required:** Yes

### fluid_buffer_input_flow

**Type:** `FluidAmount`

**Required:** Yes

### activation_buffer_ratio

Before an turret that was out of fluid ammunition is able to fire again, the `fluid_buffer_size` must fill to this proportion.

**Type:** `FluidAmount`

**Required:** Yes

### fluid_box

**Type:** `FluidBox`

**Required:** Yes

### muzzle_light

**Type:** `LightDefinition`

**Optional:** Yes

### enough_fuel_indicator_light

**Type:** `LightDefinition`

**Optional:** Yes

### not_enough_fuel_indicator_light

**Type:** `LightDefinition`

**Optional:** Yes

### muzzle_animation

**Type:** `Animation`

**Optional:** Yes

### folded_muzzle_animation_shift

**Type:** `AnimatedVector`

**Optional:** Yes

### preparing_muzzle_animation_shift

**Type:** `AnimatedVector`

**Optional:** Yes

### prepared_muzzle_animation_shift

**Type:** `AnimatedVector`

**Optional:** Yes

### starting_attack_muzzle_animation_shift

**Type:** `AnimatedVector`

**Optional:** Yes

### attacking_muzzle_animation_shift

**Type:** `AnimatedVector`

**Optional:** Yes

### ending_attack_muzzle_animation_shift

**Type:** `AnimatedVector`

**Optional:** Yes

### folding_muzzle_animation_shift

**Type:** `AnimatedVector`

**Optional:** Yes

### enough_fuel_indicator_picture

**Type:** `Sprite4Way`

**Optional:** Yes

### not_enough_fuel_indicator_picture

**Type:** `Sprite4Way`

**Optional:** Yes

### out_of_ammo_alert_icon

The sprite will be drawn on top of fluid turrets that are out of fluid ammunition. If the `out_of_ammo_alert_icon` is not set, [UtilitySprites::fluid_icon](prototype:UtilitySprites::fluid_icon) will be used instead.

**Type:** `Sprite`

**Optional:** Yes

### turret_base_has_direction

Always `true`, forcing the turret's collision box to be affected by its rotation.

**Type:** `True`

**Required:** Yes

**Overrides parent:** Yes

### attack_parameters

Requires ammo_type in attack_parameters.

**Type:** `StreamAttackParameters`

**Required:** Yes

**Overrides parent:** Yes

